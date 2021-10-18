# POPL 2022 Artifact: Twist

This artifact is being submitted to support the POPL'22 paper "Twist: Sound Reasoning for Purity and Entanglement in Quantum Programs" by Charles Yuan, Chris McNally, and Michael Carbin. The artifact contains:

- `README.md`, this document
- `twist.ova`, a virtual machine containing source code, pre-built binaries, and tests
- The directory `popl22-artifact`, a copy of the contents of the virtual machine, containing the source code of the Twist language interpreter (`src/`) and the tests (`tests/`)

This document describes:

- The claims of the paper this artifact supports
- The kick-the-tires instructions for reviewers
- How to review the artifact for functionality
- How to review the artifact for reusability
- Detailed instructions for building the artifact and executing benchmarks

The contents of this artifact, and the sources of the Twist programming language, are available on [GitHub](https://github.com/psg-mit/twist-popl22).

## Claims Supported by Artifact

This artifact supports the three claims in Section 8 (Evaluation) of the paper:

1. (Section 8.4) Twist is expressive enough to permit writing standard quantum algorithms. Additionally, writing purity specifications for them enables detecting programming errors.

This claim is evaluated by Step 2 of the section "Validating the Paper's Claims" below. The artifact provides the test cases of Table 1 of the paper, listed in the section "Benchmarks Included in Artifact" below, and an interpreter for Twist that executes them, outputting the table of results of our analyses on each program.

2. (Section 8.5) Runtime separability checks can execute in simulation for complex programs without excessive runtime overhead.

This claim is evaluated by Step 3 of the section "Validating the Paper's Claims" below. The artifact provides performance benchmark programs and a means of generating the performance plots of Figure 13 of the paper.

3. (Section 8.6) Purity guarantees enable expressing semantically valid programs that existing languages disallow.

The portion of the artifact evaluating this claim is the same as for the first claim. As noted in Section 8.2 (Methodology) of the paper, we compare the results of the analyses on the benchmark programs to Silq, a recent quantum programming language. Because Silq does not support the purity annotations that we extensively utilize, we did not translate the benchmark programs to Silq, and instead reasoned about whether Silq would accept an equivalent program. In the process of evaluating the first claim above, we confirm that Twist accepts the three programs _Teleport_, _Deutsch_, and _ShorCode_ that would be rejected by Silq.

### Differences from Paper Submission

This artifact includes two corrections from the original paper submission. The final version of the paper will include these corrections and be consistent with the artifact.

1. The source of the _DeutschJozsa-MixedInit_ example in Appendix F.10 of the submitted paper was out of date. The correct version is included in this artifact, as `tests/paper/deutschjozsa-mixedinit.q`. The final version of the paper will include this correct version in the appendix.
2. As pointed out by Reviewer C of the paper, Table 1 of the submitted paper included an error that stated that _Deutsch-MissingH_ failed the static analysis when, in fact, it passes the static analysis and fails the dynamic analysis. The interpreter included in this artifact correctly indicates a runtime error when executed on this test case, `tests/paper/deutsch-missingH.q`. The final version of the paper will correct this error in Table 1.

In addition to the above two corrections, this artifact includes a performance evaluation based on wall-clock execution timings, which will differ from the graph in Figure 13 of the submitted paper. As discussed in Section 8.2 (Methodology), our original hardware configuration was a MacBook Pro with 2.4GHz 8-Core Intel Core i9 processor and 64 GB of RAM with OpenMP enabled. The virtual machine may execute under significantly limited hardware specifications. We expect that running the quantum simulator in a virtual machine with fewer CPU cores, less physical RAM, and virtualization overhead compared to our original configuration will result in slower execution. In particular, the test cases on >20 qubits may take unreasonably long to execute in the VM.

### Benchmarks Included in Artifact

The artifact includes the following benchmarks in the `tests/` directory. First, it includes each of the benchmarks of Table 1 in the `tests/paper/` directory, except the _ModMul(n)_ programs, which are in `tests/multiply/`. We include _ModMul(n)_ programs for values of _n_ between 4 and 24, as well as _ModMul(n)-NotInverse_ for _n_ = 4 and 12.

The following table, adapted from Table 1 of the paper, depicts the expected results of the Twist analyses on each program.
Because the results of the analysis are the same for each value of _n_, we display only the cases for _n_ = 4 and 12 in the table.

| Paper Benchmark         | Filename                           | Valid | Types | Static | Dynamic |
| ----------------------- | ---------------------------------- | ----- | ----- | ------ | ------- |
| Teleport                | `paper/teleport.q`                 |   o   |   o   |   o    |    o    |
| Teleport-NoCZ           | `paper/teleport-noCZ.q`            |   x   |   o   |   o    |    x    |
| Teleport-Measure        | `paper/teleport-measure.q`         |   o   |   x   |  N/A   |   N/A   |
| AndOracle               | `paper/andoracle.q`                |   o   |   o   |   o    |    o    |
| AndOracle-NotUncomputed | `paper/andoracle-notuncomputed.q`  |   x   |   x   |  N/A   |   N/A   |
| Bell-GHZ                | `paper/bell-ghz.q`                 |   x   |   x   |  N/A   |   N/A   |
| Deutsch                 | `paper/deutsch.q`                  |   o   |   o   |   o    |    o    |
| Deutsch-MissingH        | `paper/deutsch-missingH.q`         |   x   |   o   |   o    |    x    |
| DeutschJozsa            | `paper/deutschjozsa.q`             |   o   |   o   |   o    |    o    |
| DeutschJozsa-MixedInit  | `paper/deutschjozsa-mixedinit.q`   |   x   |   o   |   x    |   N/A   |
| Grover                  | `paper/grover.q`                   |   o   |   o   |   o    |    o    |
| Grover-BadOracle        | `paper/grover-badoracle.q`         |   x   |   o   |   x    |   N/A   |
| QFT                     | `paper/qft.q`                      |   o   |   o   |   o    |    o    |
| ShorCode                | `paper/shorcode.q`                 |   o   |   o   |   o    |    o    |
| ShorCode-Drop           | `paper/shorcode-drop.q`            |   x   |   x   |  N/A   |   N/A   |
| ModMul(4)               | `multiply/multiply4.q`             |   o   |   o   |   o    |    o    |
| ModMul(4)-NotInverse    | `multiply/multiply4-notinverse.q`  |   x   |   o   |   o    |    x    |
| ModMul(12)              | `multiply/multiply12.q`            |   o   |   o   |   o    |    o    |
| ModMul(12)-NotInverse   | `multiply/multiply12-notinverse.q` |   x   |   o   |   o    |    x    |

The artifact also includes additional tests not described in the paper. These tests are in `tests/basic/` (valid programs), `tests/bad/` (invalid programs), and `tests/misc/` (other tests not described in the paper).

## Kick-the-Tires: Getting Started with the Artifact

First, import `twist.ova` into your virtualization software. In our testing, we used [VirtualBox](https://www.virtualbox.org) 6.1.26 on macOS Big Sur. This VM is packaged in the Open Virtual Appliance format and can be imported into VirtualBox through `File -> Import Appliance`. The VM contains an installation of Debian Linux. Because the artifact is computationally intensive, we recommend allocating the VM ample CPU cores and physical RAM, and have used 4 cores and 8 GB memory in our own testing. The VM has no particular network requirements.

Once the VM boots, it should automatically log in as the user `user`. The password for `user` is `user` and the root password is `root`, in case it is ever required.

The artifact is in the `popl22-artifact/` directory inside the home directory of `user`, inside which the interpreter for Twist is already installed as `./twist`.

```shell
$ cd ~/popl22-artifact/
$ ./twist -help
The interpreter for the Twist quantum programming language.
Usage: ./twist <options> [program]
Options are:
  -bench Run in benchmark mode. Outputs timing statistics for 10 runs.
  -no_print Do not print the final quantum state. Useful for large states that would take too long to print.
  -no_sim Do not run the quantum simulator to interpret the program. The interpreter will exit after static analyses.
  -no_dynamic Advanced: do not execute dynamic checks. The program will continue to execute in an unsafe manner.
  -no_static Advanced: do not execute the static analysis. The program will execute in an unsafe manner.
  -no_convert Advanced: do not attempt to automatically infer conversion operators. Programs that utilize this feature will be rejected.
  -help  Display this list of options
  --help  Display this list of options
```

The `tests/` directory contains a set of `.q` programs corresponding to the benchmarks in the paper.
To quickly check that the artifact is functional, execute the interpreter on the _Teleport_ example:

```shell
$ ./twist tests/paper/teleport.q
Reading tests/paper/teleport.q
Type checking successful
Static analysis successful
Executing program
Final result: (Ast.Equantum (Ast.Ppure, (Ast.Qref 2)))
Quantum state:
|0> : 0.707107 + 0i
|1> : 0.707107 + 0i
```

## Functionality: Validating the Paper's Claims

The easiest way to validate the paper's claims is to do the following in the `popl22-artifact/` directory:

1. Ensure the interpreter `./twist` is present.

If it is not, rebuild it from source by invoking `make` (for more instructions, see the "Detailed Instructions" section).

2. Run the analysis on the paper benchmark programs using `./check.py`. The script will execute the interpreter on each program and print a table of results.

We expect the output of the script to confirm that some of the provided benchmarks are valid under their purity specifications, and some are invalid due to failing specific analyses. To validate the claim, compare the output of `./check.py` to the table in the section "Benchmarks Included in Artifact" above.
A saved copy of the output of `./check.py` is stored in the file `check.out`.

3. Run the performance benchmark using `./bench.py <n>`, where `<n>` is a number of qubits between 4 and 24. The script will execute the performance tests of up to `<n>` qubits, report the timing results of the programs, and plot the total execution time and runtime check overhead. The output will be stored in a file `bench.pdf`, which can be viewed using the system PDF viewer with

```shell
evince bench.pdf
```

To evaluate the claim, compare the two plots in `bench.pdf` to Figure 13 of the paper.
We expect the output of the script to be similar to Figure 13. First, the total execution time of the benchmark programs should increase exponentially with the number of qubits. Furthermore, despite hardware differences, we expect the relative overhead of the runtime check to remain below 5%. This overhead may appear higher than the 3.5% claimed in the paper, because the relative overhead is larger on the smaller test cases that are more vulnerable to noise and sensitive to machine specifications.
A saved copy of the output of `./bench.py 20` is stored in the files `bench.out` and `bench.out.pdf`. Note that the larger tests may take a significant time to execute on the VM. For example, `./bench.py 20` took about 18 minutes to execute for us.

## Reusability: Writing Twist Programs

The Twist interpreter included in the artifact makes it possible to write new Twist programs and extend the functionality of the language.
The file `src/README.md` describes the organization of the Twist interpreter sources, should you wish to modify the code. The source code of Twist is also available on [GitHub](https://github.com/psg-mit/twist-popl22).

To execute a Twist program, supply it as an argument to the interpreter, for example:

```shell
./twist tests/paper/teleport.q
```

The interpreter will:

1. Display the results of type checking and the static analysis
2. Execute the program using the quantum simulator
3. Print the final value to which the program evaluates, along with the final quantum state.

Note that the final value to which the program evaluates is printed in an internal form and may not be immediately human-readable.

If the program fails an analysis, an error message is printed:

```shell
$ ./twist tests/paper/deutsch-missingH.q
Reading tests/paper/deutsch-missingH.q
Type checking successful
Static analysis successful
Executing program
Runtime error: Failed runtime separability condition.
```

The examples in `tests/` are the best way to understand the syntax accepted by this implementation of Twist. All programs are a series of function declarations using the `fun` keyword, with the final declaration required to be `fun main ()`, serving as the entry point of the program. While qubit types are linear and cannot be duplicated or discarded, function and Boolean types can be duplicated and discarded.

Twist supports generic purity annotations, an example of which can be seen in `tests/paper/shorcode.q`.
The purity annotations supported are `P` (or `'pure`), `M` (or `'mixed`), and generic purity `'p`, `'q`, etc. Only top level function declarations may be polymorphic.
Generic purity annotations cannot be used as the argument to `split`, only `P` and `M`. A generic purity used as the argument to `cast` will be statically checked.

This implementation of Twist supports Toffoli (`TOF`) and Fredkin (`FRED`) gates; see `tests/multiply/multiply4.q` for an example. It also supports arbitrary (controlled) phase rotation gates; see `tests/paper/qft.q` for an example.

The operator inference mechanism of Twist allows type annotations on `let`-bindings to automatically infer `cast`, `split`, and `entangle` operators that should be inserted into the bound expression to convert it to the appropriate type. The inference may insert an inefficient sequence of operators for complex patterns, and if this happens, breaking them into multiple more explicit `let`-bindings can force the expected set of conversions.

## Detailed Instructions

The following sections describe in detail how to build the Twist interpreter from source and execute performance benchmarks on individual programs.

### Building the Interpreter

In the provided VM, simply run `make` within `popl22-artifact` to build the interpreter from source.

To build the interpreter outside of the VM, first install OCaml version 4.12.0 and the libraries `core`, `ctypes`, `ctypes-foreign`, `menhir`, `ppx_deriving`, and `zarith`.
The recommended way to install OCaml and the dependent libraries is via [OPAM](http://opam.ocaml.org).

We use the quantum simulator [Quantum++](https://github.com/softwareQinc/qpp/tree/7c91b065d0536f45b962ad742ac94857deae6a37), specifically commit `7c91b065d0`, which must be extracted into a directory named `qpp/` in the same directory as `src/`.
It requires Eigen 3 as well as OpenMP to be installed on the system, following the directions [here](https://github.com/softwareQinc/qpp/blob/main/INSTALL.md).
We assume that Eigen is installed at `/usr/include/eigen3`, and that `cc` on your system is a C++11 compliant version of `g++`.
If your system is configured differently, you should update the C++ compiler and linker flags in `qpp_stub/dune` and `src/dune`. We have provided alternative flags for LLVM/Clang++ as comments in the files.

Finally, to build the interpreter `./twist`, simply run `make`.

### Running the Performance Benchmarks

The performance benchmarks are a family of programs in the `tests/multiply/` directory. There is a `multiply*.q` program for every number of qubits from 4 to 24, along with two programs that fail the dynamic separability check, `multiply4-notinverse.q` and `multiply12-notinverse.q`.

The easiest way to execute the benchmark is to use the script `./bench.py` as described above, which automates the process. You may also manually collect timing statistics for a particular program using the `-bench` flag to the interpreter:

```shell
$ ./twist -bench tests/multiply/multiply9.q
Reading tests/multiply/multiply9.q
Run time: 5.387068ms, static time: 2.899885ms, dynamic time: 0.105143ms
Run time: 5.968094ms, static time: 2.468109ms, dynamic time: 0.112057ms
Run time: 4.842043ms, static time: 4.004002ms, dynamic time: 0.128984ms
Run time: 3.175020ms, static time: 2.264977ms, dynamic time: 0.079155ms
Run time: 5.632877ms, static time: 3.769159ms, dynamic time: 0.082970ms
Run time: 3.649950ms, static time: 2.295971ms, dynamic time: 0.076056ms
Run time: 5.694866ms, static time: 3.759146ms, dynamic time: 0.082016ms
Run time: 7.096052ms, static time: 2.180099ms, dynamic time: 0.113010ms
Run time: 6.632090ms, static time: 2.214909ms, dynamic time: 0.096083ms
Run time: 5.896091ms, static time: 2.185822ms, dynamic time: 0.110865ms
```

The interpreter reports timing statistics for 10 runs of the program. Here, run time denotes the total time used to interpret the program (after parsing), including type checking, static analyses, and dynamic analysis. Static time denotes the time taken by the type checker and static analysis. Dynamic time denotes the time taken by the runtime separability check.
