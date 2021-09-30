{
  open Core
  open Parser
  exception Lexical_error of string

  let keyword_table =
    let tbl = Hashtbl.create (module String) in
    begin
      List.iter ~f:(fun (key, data) -> Hashtbl.add_exn tbl ~key ~data)
	[   ("let", LET);
	    ("in", IN);
        ("fun", FUN);
        ("if", IF);
        ("then", THEN);
        ("else", ELSE);
        ("bool", BOOLT);
        ("unit", UNITT);
        ("qubit", QUBIT);
        ("qinit", QINIT);
        ("entangle", ENTANGLE);
        ("split", SPLIT);
        ("cast", CAST);
        ("measure", MEASURE);
        ("true", TRUE);
        ("false", FALSE);
        ("type", TYPE);
        ("P", PURE);
        ("M", MIXED);
	]; tbl
    end

  let unitaries =
    let tbl = Hashtbl.create (module String) in
    let open Qpp.Gate in
    begin
      List.iter ~f:(fun (key, data) -> Hashtbl.add_exn tbl ~key ~data)
	[   ("H", H);
        ("X", X);
        ("Y", Y);
        ("Z", Z);
        ("CNOT", CNOT);
        ("CZ", CZ);
        ("TOF", TOF);
        ("FRED", FRED);
	]; tbl
    end
}

let newline = ('\010' | '\013' | "\013\010")
let letter = ['A'-'Z' 'a'-'z']
let identchar = ['A'-'Z' 'a'-'z' '_' '\'' '0'-'9' '.']
let tick = '\''

let digit = ['0'-'9']
let frac = '.' digit*
let exp = ['e' 'E'] ['-' '+']? digit+
let float = digit* (frac exp? | exp)

rule token sbuff = parse
| eof { EOF }
| "=" { EQUAL }
| "->" { ARROW }
| "=>" { DARROW }
| "(" { LPAREN }
| ")" { RPAREN }
| "<" { LANGLE }
| ">" { RANGLE }
| "," { COMMA }
| ":" { COLON }
| "*" { STAR }
| "&" { AMPERSAND }
| [' ' '\t']
    { token sbuff lexbuf }
| newline
    { Lexing.new_line lexbuf; token sbuff lexbuf }
| float as f
    { FLOAT (Float.of_string f) }
| tick letter identchar*
    { match Lexing.lexeme lexbuf with 
      | "'pure" -> PURE 
      | "'mixed" -> MIXED 
      | s -> PURITY s }
| letter identchar*
    { let s = Lexing.lexeme lexbuf in
      match s with
      | "PHASE" -> PHASE
      | "CPHASE" -> CPHASE
      | _ ->
        match Hashtbl.find keyword_table s
        with Some s -> s | None -> 
            match Hashtbl.find unitaries s 
            with Some s -> UNITARY s
            | _ -> IDENT s }
| "_" { IDENT "_" }
| "(*"
    { comment 1 lexbuf; token sbuff lexbuf }
| _
    { raise (Lexical_error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf))) }

and comment cpt = parse
  | "(*"
      { comment (cpt + 1) lexbuf }
  | "*)"
      { if cpt > 1 then comment (cpt - 1) lexbuf }
  | eof
      { raise (Lexical_error "Unterminated comment.\n") }
  | newline
      { Lexing.new_line lexbuf; comment cpt lexbuf }
  | _
      { comment cpt lexbuf }
