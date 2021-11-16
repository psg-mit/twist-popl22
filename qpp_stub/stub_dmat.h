// This file describes the C interface of stub_dmat.cpp.
// Do not #include it in stub_dmat.cpp.

typedef void* state_t;

state_t empty();

void discard_dmat(state_t s);

int qinit_dmat(state_t s);

enum Gate { X = 0, Y = 1, Z = 2, H = 3, CNOT = 4, CZ = 5, TOF = 6, FRED = 7, PHASE = 8, CPHASE = 9 };

void unitary1_dmat(state_t s, Gate g, int q);

void unitary2_dmat(state_t s, Gate g, int q1, int q2);

void unitary3_dmat(state_t s, Gate g, int q1, int q2, int q3);

void punitary1_dmat(state_t s, Gate g, int q, double p);

void punitary2_dmat(state_t s, Gate g, int q1, int q2, double p);

void measure_dmat(state_t s, int q, bool outcome);

state_t clone_dmat(state_t s);

void sum_dmat(state_t s1, state_t s2, const int* q1, const int* q2, int nqs);

bool separable_dmat(state_t s, const int* qs, int nqs);

void print_dmat(state_t s);
