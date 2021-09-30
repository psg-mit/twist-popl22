open Core
open Ast

exception TypeError = Inst.TypeError

module VarMap = String.Map
module VarSet = String.Set
module QubitSet = Int.Set

let rec is_classical = function
  | Tquantum (_, _) -> false
  | Tbool -> true
  | Tpair (t1, t2) -> is_classical t1 && is_classical t2
  | Tunit -> true
  | Tfun (_, _) -> false
;;

let rec can_consume = function
  | Tquantum (Ppure, _) -> true
  | Tquantum (_, _) -> false
  | Tbool -> true
  | Tpair (t1, t2) -> can_consume t1 && can_consume t2
  | Tunit -> true
  | Tfun (_, _) -> false
;;

let rec shadowed = function
  | Pid (x, _) | Pinfer x -> VarSet.singleton x
  | Ppair (p1, p2) ->
    let s1 = shadowed p1 in
    let s2 = shadowed p2 in
    if not (VarSet.is_empty (VarSet.inter s1 s2))
    then raise (TypeError "Pattern binds variable more than once.")
    else VarSet.union s1 s2
  | Punit -> VarSet.empty
;;

let rec update_ctx ctx = function
  | Pid (key, data) ->
    (match VarMap.add (VarMap.remove ctx key) ~key ~data with
    | `Ok a -> a
    | `Duplicate -> raise (TypeError ("Duplicate variable in pattern " ^ key)))
  | Ppair (t1, t2) -> update_ctx (update_ctx ctx t1) t2
  | Punit -> ctx
  | Pinfer _ -> raise (TypeError "Missing type annotation.")
;;

let rec synth_p = function
  | Pid (_, t) -> t
  | Ppair (p1, p2) -> Tpair (synth_p p1, synth_p p2)
  | Punit -> Tunit
  | Pinfer _ -> raise (TypeError "Missing type annotation.")
;;

let rec synth_q rctx = function
  | Qref a ->
    ( QubitSet.remove rctx a
    , if QubitSet.mem rctx a then Tqubit else raise (TypeError "Unknown qubit.") )
  | Qepair (q1, q2) ->
    let rctx, t1 = synth_q rctx q1 in
    let rctx, t2 = synth_q rctx q2 in
    rctx, Tepair (t1, t2)
;;

let rec classical = function
  | Tqubit -> Tbool
  | Tepair (t1, t2) -> Tpair (classical t1, classical t2)
;;

let rec mix = function
  | Tquantum (_, q) -> Tquantum (Pmixed, q)
  | Tpair (t1, t2) -> Tpair (mix t1, mix t2)
  | Tfun (t1, t2) -> Tfun (t1, mix t2)
  | t -> t
;;

let rec check_t seen = function
  | Tquantum (Pvar x, _) ->
    if VarSet.mem seen x
    then raise (TypeError ("Duplicate use of generic purity parameter " ^ x))
    else VarSet.add seen x
  | Tquantum (_, _) -> seen
  | Tpair (t1, t2) | Tfun (t1, t2) -> check_t (check_t seen t1) t2
  | Tbool | Tunit -> seen
;;

let rec check_p seen = function
  | Pinfer _ | Punit -> seen
  | Ppair (p1, p2) -> check_p (check_p seen p1) p2
  | Pid (_, t) -> check_t seen t
;;

let synth decls ctx rctx e =
  let rec synth_quantum ctx rctx e =
    let ctx', rctx', t, e' = synth ctx rctx e in
    match t with
    | Tquantum (_, _) -> ctx', rctx', t, e'
    | _ ->
      let e' =
        try Convert.convert_to_quantum t e' with
        | Convert.NoConversion ->
          raise
            (TypeError
               (Format.asprintf
                  "Quantum operator applied to non-quantum value %a."
                  pp_exp
                  e))
      in
      let ctx'', rctx'', t, _ = synth ctx rctx e' in
      assert (VarMap.equal (equal_typ equal_purity) ctx' ctx'' && Set.equal rctx' rctx'');
      (match t with
      | Tquantum (_, _) -> ctx'', rctx'', t, e'
      | _ -> assert false)
  and synth_convert ctx rctx p e =
    let ctx', rctx', t, e' = synth ctx rctx e in
    if try equal_typ equal_purity t (synth_p p) with
       | TypeError _ -> true
    then ctx', rctx', t, e'
    else (
      let lhs = synth_p p in
      let e' =
        try Convert.convert lhs t e' with
        | Convert.NoConversion ->
          raise
            (TypeError
               (Format.asprintf
                  "Binding argument %a incompatible with pattern %a."
                  pp_exp
                  e
                  pp_patt
                  p))
      in
      let ctx'', rctx'', t, _ = synth ctx rctx e' in
      assert (
        VarMap.equal (equal_typ equal_purity) ctx' ctx''
        && Set.equal rctx' rctx''
        && equal_typ equal_purity t lhs);
      ctx'', rctx'', t, e')
  and synth_discard ctx rctx shadowed e =
    let ctx', rctx', t', e' = synth ctx rctx e in
    let unconsumed =
      Set.filter
        (Set.inter shadowed (VarMap.key_set ctx'))
        ~f:(fun x -> not (is_classical (VarMap.find_exn ctx' x)))
    in
    if Set.is_empty unconsumed
    then ctx', rctx', t', e'
    else (
      Set.iter
        ~f:(fun x ->
          let t = VarMap.find_exn ctx' x in
          if not (can_consume t)
          then
            raise
              (TypeError
                 (Format.asprintf
                    "Binding variable %s of linear type %a was not consumed."
                    x
                    (pp_typ pp_purity)
                    t)))
        unconsumed;
      let e' =
        try Convert.convert_consume unconsumed ctx' e' with
        | Convert.NoConversion -> assert false
      in
      let ctx'', rctx'', t, _ = synth ctx rctx e' in
      assert (Set.equal rctx' rctx'' && equal_typ equal_purity t' t);
      ctx'', rctx'', t, e')
  and synth ctx rctx e =
    match e with
    | Evar x ->
      let t =
        match VarMap.find ctx x with
        | Some t -> t
        | None ->
          (match VarMap.find decls x with
          | Some t -> t
          | None ->
            raise (TypeError (Format.sprintf "Used unknown or consumed variable %s." x)))
      in
      let ctx = if is_classical t then ctx else VarMap.remove ctx x in
      ctx, rctx, t, e
    | Eapp (e1, e2) ->
      let ctx, rctx, t1, e1' = synth ctx rctx e1 in
      let ctx, rctx, t2, e2' = synth ctx rctx e2 in
      (match t1 with
      | Tfun (t1', t2') ->
        let t2' = Inst.inst t1' t2' t2 (fun x -> x) in
        ctx, rctx, t2', Eapp (e1', e2')
      | _ ->
        raise
          (TypeError
             (Format.asprintf
                "Attempted to call non-function type %a."
                (pp_typ pp_purity)
                t1)))
    | Epair (e1, e2) ->
      let ctx, rctx, t1, e1' = synth ctx rctx e1 in
      let ctx, rctx, t2, e2' = synth ctx rctx e2 in
      ctx, rctx, Tpair (t1, t2), Epair (e1', e2')
    | Eunit -> ctx, rctx, Tunit, e
    | Ebool _ -> ctx, rctx, Tbool, e
    | Elam (p, e) ->
      let shadowed = shadowed p in
      let (_ : VarSet.t) = check_p VarSet.empty p in
      let t = synth_p p in
      let ctx' = update_ctx ctx p in
      let ctx'', rctx, t', e' = synth_discard ctx' rctx shadowed e in
      let ctx =
        VarMap.filter_keys ctx ~f:(fun x -> VarMap.mem ctx'' x || VarSet.mem shadowed x)
      in
      ctx, rctx, Tfun (t, t'), Elam (p, e')
    | Elet (p, e1, e2) ->
      let shadowed = shadowed p in
      let ctx, rctx, t, e1' = synth_convert ctx rctx p e1 in
      let ctx' =
        try update_ctx ctx p with
        | TypeError _ ->
          (match p with
          | Pinfer key -> VarMap.add_exn (VarMap.remove ctx key) ~key ~data:t
          | _ ->
            raise
              (TypeError
                 (Format.asprintf
                    "Missing type annotation in pattern %a which could not be inferred."
                    pp_patt
                    p)))
      in
      let ctx'', rctx, t', e2' = synth_discard ctx' rctx shadowed e2 in
      let ctx' =
        VarMap.filter_keys ctx ~f:(fun x -> VarMap.mem ctx'' x || VarSet.mem shadowed x)
      in
      ctx', rctx, t', Elet (p, e1', e2')
    | Eqinit -> ctx, rctx, Tquantum (Ppure, Tqubit), e
    | Eunitary (u, e) ->
      let ctx', rctx', t, e' = synth_quantum ctx rctx e in
      (match t with
      | Tquantum (_, Tqubit)
      | Tquantum (_, Tepair (Tqubit, Tqubit))
      | Tquantum (_, Tepair (Tqubit, Tepair (Tqubit, Tqubit))) ->
        ctx', rctx', t, Eunitary (u, e')
      | _ ->
        raise
          (TypeError
             (Format.asprintf
                "Unitary %a requires one, two, or three qubits."
                Qpp.Gate.pp
                u)))
    | Eentangle (p, e) ->
      let ctx, rctx, t, e' = synth ctx rctx e in
      (match t with
      | Tpair (Tquantum (p1, t1), Tquantum (p2, t2)) ->
        if equal_purity p p1 && equal_purity p p2
        then ctx, rctx, Tquantum (p, Tepair (t1, t2)), Eentangle (p, e')
        else
          raise
            (TypeError
               (Format.asprintf
                  "entangle<%a> arguments must also have purity %a, but have %a and %a."
                  pp_purity
                  p
                  pp_purity
                  p
                  pp_purity
                  p1
                  pp_purity
                  p2))
      | _ -> raise (TypeError "Entangle requires two qubit or entangled pair arguments."))
    | Esplit (Pmixed, e) ->
      let ctx, rctx, t, e' = synth ctx rctx e in
      (match t with
      | Tquantum (Pmixed, Tepair (t1, t2)) ->
        ( ctx
        , rctx
        , Tpair (Tquantum (Pmixed, t1), Tquantum (Pmixed, t2))
        , Esplit (Pmixed, e') )
      | Tquantum (_, Tepair (_, _)) ->
        raise (TypeError "split<M> argument must be mixed.")
      | _ -> raise (TypeError "Split requires entangled pair argument."))
    | Esplit (Ppure, e) ->
      let ctx, rctx, t, e' = synth ctx rctx e in
      (match t with
      | Tquantum (Ppure, Tepair (t1, t2)) ->
        ctx, rctx, Tpair (Tquantum (Ppure, t1), Tquantum (Ppure, t2)), Esplit (Ppure, e')
      | Tquantum (_, Tepair (_, _)) ->
        raise (TypeError "split<P> argument must be pure.")
      | _ -> raise (TypeError "Split requires entangled pair argument."))
    | Esplit (_, _) -> raise (TypeError "Split requires mixed or pure annotation.")
    | Ecast (p, e) ->
      let ctx, rctx, t, e' = synth ctx rctx e in
      (match t with
      | Tquantum (_, t) -> ctx, rctx, Tquantum (p, t), Ecast (p, e')
      | _ -> raise (TypeError "Cast requires qubit or entangled pair argument."))
    | Equantum (p, q) ->
      let rctx, t = synth_q rctx q in
      ctx, rctx, Tquantum (p, t), e
    | Eif (e, e1, e2) ->
      let ctx, rctx, t, e' = synth ctx rctx e in
      let ctx', rctx', t1, e1' = synth ctx rctx e1 in
      let ctx'', rctx'', t2, e2' = synth ctx rctx e2 in
      (match t with
      | Tbool ->
        if equal_typ equal_purity t1 t2
           && VarMap.equal (equal_typ equal_purity) ctx' ctx''
           && QubitSet.equal rctx' rctx''
        then ctx', rctx', mix t1, Eif (e', e1', e2')
        else
          raise
            (TypeError "If requires branches to be same type and consume same variables.")
      | _ ->
        raise
          (TypeError
             (Format.asprintf
                "If requires Boolean condition, got %a"
                (pp_typ pp_purity)
                t)))
    | Emeasure e ->
      let ctx, rctx, t, e' = synth ctx rctx e in
      (match t with
      | Tquantum (_, t) -> ctx, rctx, classical t, Emeasure e'
      | _ ->
        raise
          (TypeError
             (Format.asprintf
                "Measure requires qubit or entangled pair argument, got %a"
                (pp_typ pp_purity)
                t)))
  in
  synth ctx rctx e
;;

let synth decls ctx e =
  let ctx, (_ : QubitSet.t), t, e' = synth decls ctx QubitSet.empty e in
  ctx, t, e'
;;

let check decls : program =
  let program, ctx =
    List.fold_left decls ~init:([], VarMap.empty) ~f:(fun (program, ctx) (key, t, e) ->
        let _, data, e' = synth ctx VarMap.empty e in
        let () =
          match data with
          | Tfun (_, t2) ->
            if equal_typ equal_purity t2 t
            then ()
            else
              raise
                (TypeError
                   (Format.asprintf
                      "Function with return type %a does not match declared return type \
                       %a."
                      (pp_typ pp_purity)
                      t2
                      (pp_typ pp_purity)
                      t))
          | _ -> assert false
        in
        (key, t, e') :: program, VarMap.add_exn ctx ~key ~data)
  in
  let e =
    match List.rev decls with
    | ("main", _, Elam (Punit, e)) :: _ -> e
    | _ -> raise (TypeError "Program does not end in declaration of main ().")
  in
  let _, (_ : purity typ), e' = synth ctx VarMap.empty e in
  List.rev program, e'
;;
