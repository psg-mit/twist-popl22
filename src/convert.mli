open Core
module VarMap = String.Map
module VarSet = String.Set

exception NoConversion

val convert_to_quantum : Ast.purity Ast.typ -> Ast.exp -> Ast.exp
val convert_consume : VarSet.t -> Ast.purity Ast.typ VarMap.t -> Ast.exp -> Ast.exp
val convert : Ast.purity Ast.typ -> Ast.purity Ast.typ -> Ast.exp -> Ast.exp
