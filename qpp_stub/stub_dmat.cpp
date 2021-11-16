#include <omp.h>

#include <Eigen/Dense>
#include <iostream>
#include <set>
#include <tuple>

#include "qpp.h"

using namespace qpp;
using uint = unsigned int;

struct SimStateDmat {
  cmat state = cmat::Zero(1, 1);
  int num_qubits = 0;
  SimStateDmat() { state << 1; }
};

typedef SimStateDmat* state_t;

extern "C" state_t empty_dmat() { return new SimStateDmat; }

extern "C" void discard_dmat(state_t s) { delete s; }

extern "C" int qinit_dmat(state_t s) {
  s->state = kron(s->state, prj(0_ket));
  return s->num_qubits++;
}

enum Gate : int {
  X = 0,
  Y = 1,
  Z = 2,
  H = 3,
  CNOT = 4,
  CZ = 5,
  TOF = 6,
  FRED = 7,
  PHASE = 8,
  CPHASE = 9
};

extern "C" void unitary1_dmat(state_t s, Gate g, uint q) {
  cmat u;
  switch (g) {
    case X:
      u = gt.X;
      break;
    case Y:
      u = gt.Y;
      break;
    case Z:
      u = gt.Z;
      break;
    case H:
      u = gt.H;
      break;
    default:
      abort();
  }
  s->state = apply(s->state, u, {q});
}

extern "C" void unitary2_dmat(state_t s, Gate g, uint q1, uint q2) {
  cmat u;
  switch (g) {
    case CNOT:
      u = gt.CNOT;
      break;
    case CZ:
      u = gt.CZ;
      break;
    default:
      abort();
  }
  s->state = apply(s->state, u, {q1, q2});
}

extern "C" void unitary3_dmat(state_t s, Gate g, uint q1, uint q2, uint q3) {
  cmat u;
  switch (g) {
    case TOF:
      u = gt.TOF;
      break;
    case FRED:
      u = gt.FRED;
      break;
    default:
      abort();
  }
  s->state = apply(s->state, u, {q1, q2, q3});
}

extern "C" void punitary1_dmat(state_t s, Gate g, uint q, double p) {
  cmat u = std::polar(1.0, M_PI * p) * gt.RZ(2 * M_PI * p);
  switch (g) {
    case PHASE:
      break;
    default:
      abort();
  }
  s->state = apply(s->state, u, {q});
}

extern "C" void punitary2_dmat(state_t s, Gate g, uint q1, uint q2, double p) {
  cmat u = std::polar(1.0, M_PI * p) * gt.RZ(2 * M_PI * p);
  switch (g) {
    case CPHASE:
      break;
    default:
      abort();
  }
  s->state = applyCTRL(s->state, u, {q1}, {q2});
}

extern "C" void measure_dmat(state_t s, uint q, bool outcome) {
  cmat p = cmat::Zero(2, 2);
  if (outcome) {
    p << 1, 0, 0, 0;
  } else {
    p << 0, 0, 0, 1;
  }
  s->state = apply(s->state, p, {q});
}

inline bool is_pure(const cmat& t) {
  return std::norm((t * t).trace() - std::complex<double>(1.0f)) < 1e-5;
}

extern "C" bool separable_dmat(state_t s, const uint* const qs, uint n) {
  if (n == s->num_qubits) {
    return is_pure(s->state);
  }
  std::set<idx> target;
  for (idx i = 0; i < s->num_qubits; ++i) {
    target.insert(i);
  }
  for (int i = 0; i < n; ++i) {
    target.erase(qs[i]);
  }
  return is_pure(ptrace(s->state, std::vector<idx>(target.begin(), target.end())));
}

extern "C" state_t clone_dmat(state_t s) {
  state_t t = new SimStateDmat;
  t->state = s->state;
  t->num_qubits = s->num_qubits;
  return t;
}

inline uint swap_bits(uint x, uint p1, uint p2) {
  const uint y = ((x >> p1) & 1) ^ ((x >> p2) & 1);
  return x ^ ((y << p1) | (y << p2));
}

inline void swap(cmat& state, const idx numdims, const uint* const q1, const uint* const q2, uint n) {
  using namespace Eigen;
  PermutationMatrix<Dynamic, Dynamic> perm(1UL << numdims);

#ifdef HAS_OPENMP
#pragma omp parallel for
#endif
  for (idx i = 0; i < 1UL << numdims; ++i) {
    idx j = i;
    for (uint k = 0; k < n; ++k) {
      j = swap_bits(j, q2[k], q1[k]);
    }
    perm.indices()[i] = j;
  }

  state = perm * state * perm.transpose();
}

extern "C" void sum_dmat(state_t s1, state_t s2, const uint* const q1, const uint* const q2, uint nqs) {
  while (s1->num_qubits > s2->num_qubits) {
    s2->state = kron(s2->state, prj(0_ket));
    s2->num_qubits++;
  }
  while (s2->num_qubits > s1->num_qubits) {
    s1->state = kron(s1->state, prj(0_ket));
    s1->num_qubits++;
  }
  swap(s2->state, s2->num_qubits, q1, q2, nqs);
  s1->state += s2->state;
  delete s2;
}

extern "C" void print_dmat(state_t s) {
  if (s->state.size() <= 1) {
    std::cout << "(empty)" << std::endl;
  } else {
    std::cout << disp(s->state) << std::endl;
  }
}
