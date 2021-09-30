%{
  open Ast
  module Hashtbl = Core.Hashtbl
  let type_aliases = TypeAliases.type_aliases
%}

%token <bool> BOOL
%token <string> IDENT
%token <string> PURITY
%token PHASE CPHASE
%token <Qpp.Gate.t> UNITARY
%token <float> FLOAT

%token LET IN FUN
%token IF THEN ELSE BOOLT UNITT
%token QUBIT PURE MIXED
%token QINIT ENTANGLE SPLIT CAST MEASURE
%token TRUE FALSE
%token TYPE

%token EQUAL DARROW
%token LPAREN RPAREN LANGLE RANGLE
%token COMMA
%token COLON
%token STAR AMPERSAND ARROW
%left ARROW

%token EOF

%start <Ast.decl list> program

%%

program:
| list(typdecl) p = list(decl) EOF
    { p }

typdecl:
| TYPE key = IDENT EQUAL data = typ
    { match Hashtbl.add type_aliases ~key ~data with
      | `Ok -> () 
      | `Duplicate -> raise (Parse_error.DuplicateTypeAlias key) }

decl:
| FUN f = IDENT x = patt COLON t = typ EQUAL e = expr
    { (f, t, Elam (x, e)) }

simple_expr:
(* Parenthesized expression *)
| LPAREN e = expr RPAREN
    { e }
(* Constants *)
| b = BOOL
    { Ebool b }
(* Variable *)
| x = IDENT
    { Evar x }
(* Unit *)
| LPAREN RPAREN 
    { Eunit }
(* Pair *)
| LPAREN e1 = expr COMMA e2 = expr RPAREN
    { Epair (e1, e2) }
(* App *)
| e1 = simple_expr LPAREN e2 = expr RPAREN
    { Eapp (e1, e2) }
| e1 = simple_expr LPAREN RPAREN
    { Eapp (e1, Eunit) }
| e1 = simple_expr LPAREN e2 = expr COMMA e3 = expr RPAREN
    { Eapp (e1, Epair (e2, e3)) }
(* Qinit *)
| QINIT LPAREN RPAREN { Eqinit }
(* Bool *)
| TRUE { Ebool true } | FALSE { Ebool false }

purity:
| PURE { Ppure }
| MIXED { Pmixed }
| x = PURITY { Pvar x }

expr:
| e = simple_expr
    { e }
(* Conditional *)
| IF e = expr THEN e1 = expr ELSE e2 = expr
    { Eif (e, e1, e2) }
(* Local binding *)
| LET x = patt EQUAL e1 = expr IN e2 = expr
    { Elet (x, e1, e2) }
| LET x = IDENT EQUAL e1 = expr IN e2 = expr
    { Elet (Pinfer x, e1, e2) }
(* Lambda *)
| FUN x = patt DARROW e = expr
    { Elam (x, e) }
(* Unitary *)
| u = UNITARY e = expr
    { Eunitary (u, e) }
(* Phase gate *)
| PHASE f = FLOAT e = expr
    { Eunitary (Qpp.Gate.PHASE f, e) }
(* Conditional Phase gate *)
| CPHASE f = FLOAT e = expr
    { Eunitary (Qpp.Gate.CPHASE f, e) }
(* Entangle *)
| ENTANGLE LANGLE p = purity RANGLE e = expr
    { Eentangle (p, e) }
(* Split *)
| SPLIT LANGLE p = purity RANGLE e = expr
    { Esplit (p, e) }
(* Cast *)
| CAST LANGLE p = purity RANGLE e = expr
    { Ecast (p, e) }
(* Measure *)
| MEASURE e = expr
    { Emeasure e }

patt:
| LPAREN p = patt RPAREN
    { p }
| LPAREN p1 = patt COMMA p2 = patt RPAREN
    { Ppair (p1, p2) }
| LPAREN RPAREN 
    { Punit }
| x = IDENT COLON t = typ 
    { Pid (x, t) }

typ:
| x = IDENT
    { match Hashtbl.find type_aliases x with 
      | Some t -> t 
      | None -> raise (Parse_error.UnknownTypeAlias x) }
| LPAREN t = typ RPAREN
    { t }
| BOOLT
    { Tbool }
| UNITT
    { Tunit }
| q = qtyp LANGLE p = purity RANGLE
    { Tquantum (p, q) }
| LPAREN t1 = typ STAR t2 = typ RPAREN
    { Tpair (t1, t2) }
| t1 = typ ARROW t2 = typ
    { Tfun (t1, t2) }

qtyp:
| QUBIT
    { Tqubit }
| LPAREN q1 = qtyp AMPERSAND q2 = qtyp RPAREN
    { Tepair (q1, q2) }
