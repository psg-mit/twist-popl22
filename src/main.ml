open Core
open Format

exception Error of string

let print_position _ lexbuf =
  let open Lexing in
  let pos = lexbuf.lex_curr_p in
  sprintf "%s:%d:%d" pos.pos_fname pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)
;;

let parse parsing_fun lexing_fun source_name =
  let ic = In_channel.create source_name in
  let lexbuf = Lexing.from_channel ic in
  lexbuf.Lexing.lex_curr_p
    <- { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = source_name };
  try
    let p = parsing_fun lexing_fun lexbuf in
    In_channel.close ic;
    p
  with
  | Lexer.Lexical_error err ->
    In_channel.close ic;
    raise (Error (sprintf "%a: %s\n" print_position lexbuf err))
  | Parser.Error ->
    In_channel.close ic;
    raise (Error (sprintf "%a: Syntax error.\n" print_position lexbuf))
  | Errors.UnknownTypeAlias x ->
    In_channel.close ic;
    raise (Error (sprintf "%a: Unknown type alias %s.\n" print_position lexbuf x))
  | Errors.NoEntryPoint ->
    In_channel.close ic;
    raise
      (Error
         (sprintf
            "%a: Program does not terminate in an entry point return declaration.\n"
            print_position
            lexbuf))
  | Errors.DuplicateTypeAlias x ->
    In_channel.close ic;
    raise (Error (sprintf "%a: Cannot redefine type alias %s.\n" print_position lexbuf x))
;;

let run_file file =
  if not !Args.bench then Printf.printf "Reading %s\n%!" file;
  Hashtbl.clear TypeAliases.type_aliases;
  let decls = parse Parser.program (Lexer.token ()) file in
  let start = Unix.gettimeofday () in
  let p =
    try Check.check decls with
    | Check.TypeError s -> raise (Error (sprintf "Type error: %s\n" s))
  in
  if not !Args.bench then Printf.printf "Type checking successful\n%!";
  (try Static.check p with
  | Static.Error s ->
    if (not !Args.no_static) && not !Args.bench
    then raise (Error (sprintf "Static analysis error: %s\n" s)));
  if (not !Args.bench) && not !Args.no_static
  then Printf.printf "Static analysis successful\n%!";
  let static_end = Unix.gettimeofday () in
  let exec interp with_state print =
    let sim state =
      let e =
        try interp p state with
        | Errors.SeparabilityError ->
          raise (Error "Runtime error: Failed runtime separability condition.\n")
      in
      if !Args.no_print
      then (if not !Args.bench then print_endline "Program executed successfully.")
      else (
        Format.printf "Final result: %a\n%!" Ast.pp_exp e;
        Format.printf "Quantum state:\n%!";
        print state)
    in
    let sep_time = with_state sim in
    let run_end = Unix.gettimeofday () in
    let static_time = static_end -. start in
    let run_time = run_end -. static_end in
    Some (run_time, static_time, sep_time)
  in
  if !Args.sim
  then (
    if not !Args.bench then Printf.printf "Executing program\n%!";
    if !Args.mixed
    then exec Interp_dmat.interp Sim_dmat.with_state Sim_dmat.print
    else exec Interp.interp Sim.with_state Sim.print)
  else None
;;

let bench_file test =
  Args.no_sep := false;
  try
    Printf.printf "Reading %s\n%!" test;
    let rec loop = function
      | 0 -> ()
      | n ->
        let run_time, static_time, sep_time = Option.value_exn (run_file test) in
        Format.printf
          "Run time: %fms, static time: %fms, dynamic time: %fms\n%!"
          (run_time *. 1000.)
          (static_time *. 1000.)
          (sep_time *. 1000.);
        loop (n - 1)
    in
    loop 10
  with
  | Error s -> print_endline s
;;

let run_file test =
  if !Args.bench
  then (
    Args.sim := true;
    Args.convert := true;
    Args.no_print := true;
    bench_file test)
  else ignore (run_file test : (float * float * float) option)
;;

let () =
  let desc =
    Format.sprintf
      "The interpreter for the Twist quantum programming language.\n\
       Usage: %s <options> [program] \n\
       Options are:"
      (Sys.get_argv ()).(0)
  in
  try Arg.parse Args.speclist run_file desc with
  | Error s ->
    fprintf std_formatter "%s" s;
    exit 1
;;
