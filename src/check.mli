open Core

exception TypeError of string

module VarMap = String.Map

val synth
  :  Ast.purity Ast.typ VarMap.t
  -> Ast.purity Ast.typ VarMap.t
  -> Ast.exp
  -> Ast.purity Ast.typ VarMap.t * Ast.purity Ast.typ * Ast.exp

val check : Ast.decl list -> Ast.program
