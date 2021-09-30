open Core

let type_aliases : (string, Ast.purity Ast.typ) Hashtbl.t = Hashtbl.create (module String)
