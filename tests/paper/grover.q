(* A minimal grover search over a two-qubit, four-element, database. The search
 * routine discovers the distinguished element in cell |11>. *)

type addr = (qubit & qubit)<P>

type oracle = (qubit & qubit)<P> -> (qubit & qubit)<P>

(* Initialize a new database address *)
fun init_addr () : addr = entangle<P>(H qinit(), H qinit ())

(* Apply the grover diffusion operator to a database address *)
fun diffuse (p : addr) : addr =
    let (p0 : qubit<M>, p1 : qubit<M>) = p in
    let (p0 : qubit<M>, p1 : qubit<M>) = (H p0, H p1) in
    let (p0 : qubit<M>, p1 : qubit<M>) = (Z p0, Z p1) in
    let (p0 : qubit<M>, p1 : qubit<M>) = CZ (p0, p1) in
    let (p0 : qubit<M>, p1 : qubit<M>) = (H p0, H p1) in
    let p = entangle<M>(p0, p1) in
    cast<P>p

fun grover (f : oracle) : addr =
       let addr = init_addr () in
       let addr = f (addr) in
       let addr = diffuse (addr) in
       addr

(* Pick out the |11> address *)
fun final_addr (p : addr) : addr = (CZ (p))

fun main () : addr = grover (final_addr)
