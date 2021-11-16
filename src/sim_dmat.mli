type state
type qubit = int

val with_state : (state -> unit) -> float
val qinit : state -> qubit
val unitary1 : state -> Qpp.Gate.t -> qubit -> unit
val unitary2 : state -> Qpp.Gate.t -> qubit * qubit -> unit
val unitary3 : state -> Qpp.Gate.t -> qubit * qubit * qubit -> unit
val measure : state -> qubit -> (state -> 'a) -> (state -> 'a) -> ('a -> qubit list) -> 'a
val separable : state -> qubit list -> bool
val print : state -> unit
