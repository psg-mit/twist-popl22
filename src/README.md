# Twist

This directory contains the source code for the Twist interpreter in OCaml. The Twist source is organized as follows.

First, we depend on two directories in the parent directory:

- `../qpp/` should contain a copy of the Quantum++ library. If it is absent, download it from [this GitHub commit](https://github.com/softwareQinc/qpp/tree/7c91b065d0536f45b962ad742ac94857deae6a37) and extract it into that directory.
- `./qpp_stub/` contains a stub that allows the OCaml code to interoperate with the C++ quantum simulator library.
    - `dune` specifies C++ compiler and linker flags that are platform-dependent.
    - `stub.cpp` implements the C++ routines of the stub.
    - `stub.ml` and `gate.ml` implement the OCaml bindings.

The main sources of Twist are in `src/`:

- `dune` specifies C++ compiler and linker flags that are platform-dependent.
- `parser.mly` and `lexer.mll` are a Menhir lexer/parser for the Twist syntax.
- `ast.ml` defines the Twist abstract syntax tree.
- `check.ml` contains the Twist type checker.
- `convert.ml` implements the Twist conversion operator inference mechanism.
- `static.ml` implements the Twist purity static analysis.
- `interp.ml` implements the Twist interpreter.
- `sim.ml` implements the OCaml interface of the quantum simulator, and invokes to the Quantum++ stub routines.
- `main.ml` is the entry point of the interpreter.

Other files are OCaml interface files and dependent modules of the above components of the interpreter.
