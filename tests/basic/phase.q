fun main () : (qubit & qubit)<P> =
  let x = qinit () in
  let x = PHASE 0.333 (x) in
  let y = qinit () in
  CPHASE 0.456 (x, y)
