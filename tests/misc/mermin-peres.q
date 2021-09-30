(* Mermin-Peres Magic Square Game
 *
 * Two players, Alice and Bob, each receive ternary referee signals s_a, s_b in
 * {0, 1, 2}, and must produce three bits (a_0, a_1, a_2) and (b_0, b_1, b_2)
 * such that xor_i a_i = 0, xor_j b_j = 1, and a_s_b = b_s_a.
 *
 * If Alice and Bob share two Bell pairs, they can succeed at this task with
 * probability 1 by measuring the operators in row s_a (resp. column s_b) of the
 * matrix below:
 *
 *    0 0   0 1   1 0   1 1
 *  +-----+-----+-----+
 *  | +IZ | +ZI | +ZZ | 1 0
 *  +-----+-----+-----+
 *  | +XI | +IX | +XX | 0 1
 *  +-----+-----+-----+
 *  | -XZ | -ZX | +YY | 0 0
 *  +-----+-----+-----+
 *
 * This implementation works, but the example illustrates a limitation of the
 * present system: It is not yet possible to express the entanglement pattern of
 * Alice and Bob's bits as they really are: namely, that the two bits held by
 * Alice (resp. Bob) are not mutually entangled. *)


(* Signal sent from the referee to the two players.
 *
 * Each of the two pairs of `bool`s encodes a row or column,
 * with one leftover invalid state. *)
type signals = ((bool * bool) * (bool * bool))


(* Signal to a single player*)
type signal = (bool * bool)


(* The qubits held by both players.
 *
 * The type system is not yet quite powerful enough to express the finer
 * entanglement relationships, namely that Alice's qubits are mutually
 * unentangled, as are Bob's. *)
type players = ((qubit & qubit) & (qubit & qubit))<P>


(* The qubits held by a single player. Despite the type,
 * these are difinitely mutually unentangled. *)
type player = (qubit & qubit)<M>


(* Measurement results by a single player *)
type mments = ((bool * bool) * bool)

(* A helper function for computing play outputs: boolean NOT *)
fun not (b : bool) : bool =
    if b then
       false
    else
        true

(* Boolean XOR *)
fun xor (bs : (bool * bool)) : bool =
    let (b0 : bool, b1 : bool) = bs in
    if b0 then
        if b1 then
            false
        else
            true
    else
        if b1 then
            true
        else
            false


(* Boolean AND *)
fun and (bs : (bool * bool)) : bool =
    let (b0 : bool, b1 : bool) = bs in
    if b0 then
        if b1 then
            true
        else
            false
    else
        if b1 then
            false
        else
            false


(* Boolean equality *)
fun eq (bs : (bool * bool)) : bool =
    not (xor (bs))


(* Create an entangled pair |++> + |--> = |00> + |11> *)
fun ebit () : (qubit & qubit)<P> =
    let qs = entangle<P>(H (qinit ()), qinit ()) in CNOT qs


(* Initialize the player states in the Mermin-Peres game. *)
fun init_players () : players =
    let (a0 : qubit<M>, b0 : qubit<M>) = ebit () in
    let (a1 : qubit<M>, b1 : qubit<M>) = ebit () in
    let players : ((qubit & qubit) & (qubit & qubit))<P> = ((a0, a1), (b0, b1)) in
    players


fun meas_x (q : qubit<M>) : bool =
    measure (H q)


fun meas_z (q : qubit<M>) : bool =
    measure q


fun meas_i (q : qubit<M>) : bool =
    (* Measure the qubit, but discard the result *)
    let b = measure q in
    true


(* Measure in the Bell entangled basis used by Bob *)
fun meas_bell (qs : (qubit & qubit)<M>) : (bool * bool) =
    let (q0 : qubit<M>, q1 : qubit<M>) = CNOT qs in
    let q0 = H q0 in
    (measure q1, measure q0)


(* Measure in the X-Y entangled basis used by Alice *)
fun meas_xy (qs : (qubit & qubit)<M>) : (bool * bool) =
    let (q0 : qubit<M>, q1 : qubit<M>) = qs in
    let q1 = H q1 in
    let (q0 : qubit<M>, q1 : qubit<M>) = CNOT (entangle<M>(q0, q1)) in
    let q0= H q0 in
    (not (measure q0), not (measure q1))


(* Select a measurement for Alice, who performs the measurements in a row
 * of the magic square *)
fun meas_row (ps : (player * signal)) : mments =
    let (qs : player, sig : signal) = ps in
    let (q0 : qubit<M>, q1 : qubit<M>) = qs in
    let (s0 : bool, s1 : bool) = sig in

    if s0 then
        if s1 then
            (* 11: Invalid signal state *)
            ((meas_i (q0), meas_i (q1)), true)
        else
            (* 10: In the third row, Alice must measure in a Bell basis *)
            let (b0 : bool, b1 : bool) = meas_xy (entangle<M>(q0, q1)) in
            ((b0, b1), xor ((b0, b1)))
    else
        if s1 then
            (* 01: In the second row, Alice must measure in the (X, X) basis *)
            let (b0 : bool, b1 : bool) = (meas_x (q0), meas_x (q1)) in
            ((b0, b1), xor ((b0, b1)))
        else
            (* 00: In the first row, Alice must measure in the (Z, Z) basis *)
            let (b0 : bool, b1 : bool) = (meas_z (q0), meas_z (q1)) in
            ((b1, b0), xor ((b0, b1)))


(* Select a measurement for Bob, who performs the measurements in a column
 * of the magic square *)
fun meas_col (ps : (player * signal)) : mments =
    let (qs : player, sig : signal) = ps in
    let (q0 : qubit<M>, q1 : qubit<M>) = qs in
    let (s0 : bool, s1 : bool) = sig in

    if s0 then
        if s1 then
            (* 11: Invalid signal state *)
            ((meas_i (q0), meas_i (q1)), true)
        else
            (* 10: In the third col, Bob must measure in a Bell basis *)
            let (b0 : bool, b1 : bool) = meas_bell (entangle<M>(q0, q1)) in
            ((b0, b1), eq ((b0, b1)))
    else
        if s1 then
            (* 01: In the second col, Bob must measure in the (Z, X) basis *)
            let (b0 : bool, b1 : bool) = (meas_z (q0), meas_x (q1)) in
            ((b0, b1), eq ((b0, b1)))
        else
            (* 00: In the first col, Bob must measure in the (X, Z) basis *)
            let (b0 : bool, b1 : bool) = (meas_x (q0), meas_z (q1)) in
            ((b1, b0), eq ((b0, b1)))


(* Play a round of the game, referee signals and initialized player states *)
fun play_round (ps_sigs : (players * signals)) : (mments * mments) =
    let (ps : players, sigs : signals) = ps_sigs in
    let (p0 : player, p1 : player) = ps in
    let (sig0 : signal, sig1 : signal) = sigs in

    (* Alice's measurements *)
    let out0 = meas_row ((p0, sig0)) in

    (* Bob's measurements *)
    let out1 = meas_col ((p1, sig1)) in

    (out0, out1)


(* Select a measured bit by a signal index *)
fun select_out (os : (mments * signal)) : bool =
    let (out : mments, sig : signal) = os in
    let ((m0 : bool, m1 : bool), m2 : bool) = out in
    let (s0 : bool, s1 : bool) = sig in
    if s0 then
        if s1 then
            (* invalid signal state / index *)
            true
        else
            m2
    else
        if s1 then
            m1
        else
            m0


(* For a given pair of signals, set up and play a game. Return `true` if Alice
 * and Bob win, and `false` if they lose. *)
fun play_validate (sigs : signals) : bool =
    let ps : players = init_players () in
    let (out0 : mments, out1 : mments) = play_round ((ps, sigs)) in
    let (sig0 : signal, sig1 : signal) = sigs in

    (* First condition: at the intersection of Alice's row and Bob's column,
     * their measurements must agree *)
    let intsct0 : bool = select_out ((out0, sig1)) in
    let intsct1 : bool = select_out ((out1, sig0)) in
    let intsct_good : bool = eq ((intsct0, intsct1)) in

    (* Second condition: A must have parity 0, B parity 1 *)
    let ((m00 : bool, m01 : bool), m02 : bool) = out0 in
    let ((m10 : bool, m11 : bool), m12 : bool) = out1 in
    let parity0 = xor ((xor ((m00, m01)), m02)) in
    let parity1 = xor ((xor ((m10, m11)), m12)) in
    let parity_good = and (not (parity0), parity1) in

    and (parity_good, intsct_good)


(* Validate each signal, once. This should print all `true`s on every execution. *)
fun main () : ((((((((bool * bool) * bool) * bool) * bool) * bool) * bool) * bool) * bool)  =
    let v0 = play_validate (((false, false), (false, false))) in
    let v1 = play_validate (((false, true),  (false, false))) in
    let v2 = play_validate (((true, false),  (false, false))) in
    let v3 = play_validate (((false, false), (false, true)))  in
    let v4 = play_validate (((false, true),  (false, true)))  in
    let v5 = play_validate (((true, false),  (false, true)))  in
    let v6 = play_validate (((false, false), (true, false)))  in (**)
    let v7 = play_validate (((false, true),  (true, false)))  in (**)
    let v8 = play_validate (((true, false),  (true, false)))  in
    ((((((((v0, v1), v2), v3), v4), v5), v6), v7), v8)
