open Core
open Ast
module VarMap = String.Map
module Sim = Sim_dmat

let rec qubits = function
  | Qref q -> [ q ]
  | Qepair (q1, q2) -> qubits q1 @ qubits q2
;;

let rec update_ctx ctx p e =
  match p with
  | Pid (key, _) | Pinfer key -> VarMap.add_exn (VarMap.remove ctx key) ~key ~data:e
  | Punit -> ctx
  | Ppair (p1, p2) ->
    (match e with
    | Epair (e1, e2) -> update_ctx (update_ctx ctx p1 e1) p2 e2
    | _ -> assert false)
;;

let rec interp tctx ctx state = function
  | Evar x -> interp tctx ctx state (VarMap.find_exn ctx x)
  | Elam (p, e) -> Elam (p, e)
  | Eapp (e1, e2) ->
    let e1 = interp tctx ctx state e1 in
    let e2 = interp tctx ctx state e2 in
    let t1 = Check.quick_synth ctx VarMap.empty e1 in
    let t2 = Check.quick_synth ctx VarMap.empty e2 in
    (match t1 with
    | Tfun (t1', t2') ->
      let _, m = Inst.inst t1' t2' t2 (fun x -> x) in
      (match e1 with
      | Elam (p, e) ->
        interp
          (VarMap.merge tctx m ~f:(fun ~key:_ -> function
             | `Left a | `Right a | `Both (_, a) -> Some a))
          (update_ctx ctx p e2)
          state
          e
      | _ -> assert false)
    | _ -> assert false)
  | Elet (p, e1, e2) ->
    let e1 = interp tctx ctx state e1 in
    interp tctx (update_ctx ctx p e1) state e2
  | Epair (e1, e2) ->
    let e1 = interp tctx ctx state e1 in
    let e2 = interp tctx ctx state e2 in
    Epair (e1, e2)
  | Eunit -> Eunit
  | Eqinit ->
    let q = Sim.qinit state in
    Equantum (Ppure, Qref q)
  | Eunitary (u, e) ->
    let e = interp tctx ctx state e in
    (match e with
    | Equantum (_, Qref q) ->
      Sim.unitary1 state u q;
      e
    | Equantum (_, Qepair (Qref q1, Qref q2)) ->
      Sim.unitary2 state u (q1, q2);
      e
    | Equantum (_, Qepair (Qref q1, Qepair (Qref q2, Qref q3))) ->
      Sim.unitary3 state u (q1, q2, q3);
      e
    | _ -> assert false)
  | Eentangle (p, e) ->
    let e = interp tctx ctx state e in
    (match e with
    | Epair (Equantum (_, q1), Equantum (_, q2)) -> Equantum (p, Qepair (q1, q2))
    | _ -> assert false)
  | Esplit (Pmixed, e) ->
    let e = interp tctx ctx state e in
    (match e with
    | Equantum (_, Qepair (q1, q2)) -> Epair (Equantum (Pmixed, q1), Equantum (Pmixed, q2))
    | _ -> assert false)
  | Esplit (Ppure, e) ->
    let e = interp tctx ctx state e in
    (match e with
    | Equantum (_, Qepair (q1, q2)) ->
      if not (Sim.separable state (qubits q1) && Sim.separable state (qubits q2))
      then raise Errors.SeparabilityError
      else Epair (Equantum (Ppure, q1), Equantum (Ppure, q2))
    | _ -> assert false)
  | Esplit (_, _) -> assert false
  | Ecast (Ppure, e) ->
    let e = interp tctx ctx state e in
    (match e with
    | Equantum (_, q) ->
      if not (Sim.separable state (qubits q))
      then raise Errors.SeparabilityError
      else Equantum (Ppure, q)
    | _ -> assert false)
  | Ecast (Pvar v, e) -> interp tctx ctx state (Ecast (VarMap.find_exn tctx v, e))
  | Ecast (Pmixed, e) -> interp tctx ctx state e
  | Equantum (p, q) -> Equantum (p, q)
  | Ebool b -> Ebool b
  | Eif (e, e1, e2) ->
    let e = interp tctx ctx state e in
    (match e with
    | Equantum (_, Qref q) ->
      Sim.measure
        state
        q
        (fun state -> interp tctx ctx state e1)
        (fun state -> interp tctx ctx state e2)
        (function
          | Equantum (_, q) -> qubits q
          | _ -> assert false)
    | Ebool true -> interp tctx ctx state e1
    | Ebool false -> interp tctx ctx state e2
    | _ -> assert false)
  | Emeasure e -> interp tctx ctx state e
;;

let interp ((decls, e) : program) state =
  let ctx =
    List.fold_left
      ~init:VarMap.empty
      ~f:(fun ctx (key, _, data) -> VarMap.add_exn ctx ~key ~data)
      decls
  in
  interp VarMap.empty ctx state e
;;
