#include <omp.h>

#include <Eigen/Dense>
#include <bitset>
#include <iostream>
#include <tuple>

#include "qpp.h"

using namespace qpp;
using uint = unsigned int;

struct SimState {
  ket state = ket::Zero(1);
  int num_qubits = 0;
  SimState() { state << 1; }
};

typedef SimState* state_t;

extern "C" state_t empty() { return new SimState; }

extern "C" void discard(state_t s) { delete s; }

extern "C" int qinit(state_t s) {
  s->state = kron(s->state, 0_ket);
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

extern "C" void unitary1(state_t s, Gate g, uint q) {
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

extern "C" void unitary2(state_t s, Gate g, uint q1, uint q2) {
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

extern "C" void unitary3(state_t s, Gate g, uint q1, uint q2, uint q3) {
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

extern "C" void punitary1(state_t s, Gate g, uint q, double p) {
  cmat u = std::polar(1.0, M_PI * p) * gt.RZ(2 * M_PI * p);
  switch (g) {
    case PHASE:
      break;
    default:
      abort();
  }
  s->state = apply(s->state, u, {q});
}

extern "C" void punitary2(state_t s, Gate g, uint q1, uint q2, double p) {
  cmat u = std::polar(1.0, M_PI * p) * gt.RZ(2 * M_PI * p);
  switch (g) {
    case CPHASE:
      break;
    default:
      abort();
  }
  s->state = applyCTRL(s->state, u, {q1}, {q2});
}

extern "C" bool measure(state_t s, uint q) {
  --s->num_qubits;
  auto measured = measure_seq(s->state, {q});
  s->state = std::get<ST>(measured);
  return std::get<RES>(measured)[0];
}

inline uint swap_bits(uint x, uint p1, uint p2) {
  const uint y = ((x >> p1) & 1) ^ ((x >> p2) & 1);
  return x ^ ((y << p1) | (y << p2));
}

inline void swap(ket& state, const idx numdims, const uint* const qs, uint n) {
  using namespace Eigen;
  PermutationMatrix<Dynamic, Dynamic> perm(1UL << numdims);

#ifdef HAS_OPENMP
#pragma omp parallel for
#endif
  for (idx i = 0; i < 1UL << numdims; ++i) {
    idx j = i;
    for (uint k = 0; k < n; ++k) {
      j = swap_bits(j, numdims - qs[n - k - 1] - 1, k);
    }
    perm.indices()[i] = j;
  }

  state = perm * state;
}

extern "C" bool separable(state_t s, const uint* const qs, uint n) {
  ket k = s->state;
  swap(k, s->num_qubits, qs, n);
  const idx dim = 1UL << n;
  const idx rem = 1UL << (s->num_qubits - n);
  auto coeffs = schmidtcoeffs(k, {rem, dim});
  return std::count_if(coeffs.data(), coeffs.data() + coeffs.size(),
                       [](double coeff) { return fabs(coeff) > chop; }) == 1;
}

extern "C" void print(state_t s) {
  if (s->state.size() < 2) {
    std::cout << "(empty)" << std::endl;
  } else {
    for (idx i = 0; i < s->state.size(); ++i) {
      std::bitset<32> bs(i);
      std::cout << "|";
      for (int j = s->num_qubits - 1; j >= 0; --j) {
        std::cout << bs[j];
      }
      std::cout << "> : " << s->state[i].real() << " + " << s->state[i].imag()
                << "i" << std::endl;
    }
  }
}
