fun main () : qubit<P> =
  let x = H (qinit ()) in
  let y = (true, H (qinit ())) in
  x
