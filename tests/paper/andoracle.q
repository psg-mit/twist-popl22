fun and_oracle (p0 : qubit<P>, p1 : qubit<P>) : (qubit & qubit)<P> =
  let x = qinit () in
  let (p0 : qubit<M>, (p1 : qubit<M>, x : qubit<M>)) =
    TOF (p0, (p1, x)) in
  let (p0 : qubit<M>, (p1 : qubit<M>, x : qubit<M>)) =
    TOF (p0, (p1, x)) in
  let qs : (qubit & (qubit & qubit))<P> = (x, (p0, p1)) in
  let (x : qubit<P>, rest : (qubit & qubit)<P>) = qs in
  rest

fun main () : (qubit & qubit)<P> = and_oracle (H (qinit ()), X (qinit ()))
