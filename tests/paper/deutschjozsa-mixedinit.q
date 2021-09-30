(* A Deutsch-Jozsa algorithm implementation with oracle `n |-> n % 2` *)

type oracle = ((qubit & qubit) & qubit)<P> -> ((qubit & qubit) & qubit)<P>

type domain = (qubit & qubit)<P>

(* An (entangled) domain-codomain pair *)
type graph_pt = ((qubit & qubit) & qubit)<P>

(* Prepare domain qubits in |0> + |1> *)
fun init_domain () : (qubit<M> * qubit<M>) =
    let (x : qubit<M>, y : qubit<M>) = CNOT (H (qinit ()), qinit ()) in
    let _ = measure (y) in
    (x, cast<M>(qinit ()))

(* Prepare output qubit in |0> - |1> *)
fun init_output () : qubit<P> =
    (H (X qinit ()))

fun test_oracle (f : oracle) : graph_pt =
    let out : qubit<P> = init_output () in
    let dom : (qubit<M> * qubit<M>) = init_domain () in
    let all : graph_pt = (dom, out) in
    let inout : graph_pt = f (all) in
    let ((d0 : qubit<M>, d1 : qubit<M>), out: qubit<M>) = inout in
    (* Hadamard the domain qubits *)
    let (inout_post : ((qubit & qubit) & qubit)<M>) = (((H d0), (H d1)), out) in
    cast<P>inout_post

(* A balanced function {0, 1}^2 -> {0, 1} that selects states with second
   qubit |1> *)
fun is_odd (pt : graph_pt) : graph_pt =
    let ((d0 : qubit<M>, d1 : qubit<M>), out : qubit<M>) = pt in

    (* Comment out this line for the constant 0 function *)
    let (d1 : qubit<M>, out : qubit<M>) = (CNOT (d1, out)) in

    let (inout : ((qubit & qubit) & qubit)<M>) = ((d0, d1), out) in
    cast<P>inout

fun main () : graph_pt =
    test_oracle (is_odd)
