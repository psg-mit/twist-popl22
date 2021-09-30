// This file describes the C interface of stub.cpp.
// Do not #include it in stub.cpp.

typedef void* state_t;

state_t empty();

void discard(state_t s);

int qinit(state_t s);

enum Gate { X = 0, Y = 1, Z = 2, H = 3, CNOT = 4, CZ = 5, TOF = 6, FRED = 7, PHASE = 8, CPHASE = 9 };

void unitary1(state_t s, Gate g, int q);

void unitary2(state_t s, Gate g, int q1, int q2);

void unitary3(state_t s, Gate g, int q1, int q2, int q3);

void punitary1(state_t s, Gate g, int q, double p);

void punitary2(state_t s, Gate g, int q1, int q2, double p);

bool measure(state_t s, int q);

bool separable(state_t s, const int* qs, int nqs);

void print(state_t s);
