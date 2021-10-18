#!/usr/bin/env python3
import os
import subprocess
import sys

if not os.path.exists("./twist"):
    print("Error: Please execute `make` to produce the `twist` binary first.")
    sys.exit(1)

tests = [
    ("Teleport", "paper/teleport.q", True),
    ("Teleport-NoCZ", "paper/teleport-noCZ.q", False),
    ("Teleport-Measure", "paper/teleport-measure.q", True),
    ("AndOracle", "paper/andoracle.q", True),
    ("AndOracle-NotUncomputed", "paper/andoracle-notuncomputed.q", False),
    ("Bell-GHZ", "paper/bell-ghz.q", False),
    ("Deutsch", "paper/deutsch.q", True),
    ("Deutsch-MissingH", "paper/deutsch-missingH.q", False),
    ("DeutschJozsa", "paper/deutschjozsa.q", True),
    ("DeutschJozsa-MixedInit", "paper/deutschjozsa-mixedinit.q", False),
    ("Grover", "paper/grover.q", True),
    ("Grover-BadOracle", "paper/grover-badoracle.q", False),
    ("QFT", "paper/qft.q", True),
    ("ShorCode", "paper/shorcode.q", True),
    ("ShorCode-Drop", "paper/shorcode-drop.q", False),
    ("ModMul(4)", "multiply/multiply4.q", True),
    ("ModMul(4)-NotInverse", "multiply/multiply4-notinverse.q", False),
    ("ModMul(12)", "multiply/multiply12.q", True),
    ("ModMul(12)-NotInverse", "multiply/multiply12-notinverse.q", False),
]

print(f'Executing the Twist interpreter on {len(tests)} benchmarks and parsing outputs.')
print('Results:\n')
print('| Paper Benchmark         | Filename                           | Valid | Types | Static | Dynamic |')
print('| ----------------------- | ---------------------------------- | ----- | ----- | ------ | ------- |')

for (name, test, valid) in tests:
    result = subprocess.run(["./twist", "-no_print", "tests/" + test], capture_output=True, text=True).stdout.split("\n")[1:-1]
    types = 'Type checking successful' in result
    static = 'Static analysis successful' in result
    dynamic = 'Program executed successfully.' in result
    def fmt(prev, x):
        if x: return ' o '
        elif prev: return ' x '
        else: return 'N/A'
    print(f'| {name:23} | {"`" + test + "`":34} | {" " + fmt(True, valid) + " "} | {" " + fmt(True, types) + " "} | {" " + fmt(types, static) + "  "} | {"  " + fmt(types and static, dynamic) + "  "} |')
