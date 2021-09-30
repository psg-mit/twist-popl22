#!/usr/bin/env python3
import os
import subprocess
import sys

if not os.path.exists("./twist"):
    print("Error: Please execute `make` to produce the `twist` binary first.")
    sys.exit(1)

tests = [
    ("Teleport", "paper/teleport.q"),
    ("Teleport-NoCZ", "paper/teleport-noCZ.q"),
    ("Teleport-Measure", "paper/teleport-measure.q"),
    ("AndOracle", "paper/andoracle.q"),
    ("AndOracle-NotUncomputed", "paper/andoracle-notuncomputed.q"),
    ("Bell-GHZ", "paper/bell-ghz.q"),
    ("Deutsch", "paper/deutsch.q"),
    ("Deutsch-MissingH", "paper/deutsch-missingH.q"),
    ("DeutschJozsa", "paper/deutschjozsa.q"),
    ("DeutschJozsa-MixedInit", "paper/deutschjozsa-mixedinit.q"),
    ("Grover", "paper/grover.q"),
    ("Grover-BadOracle", "paper/grover-badoracle.q"),
    ("QFT", "paper/qft.q"),
    ("ShorCode", "paper/shorcode.q"),
    ("ShorCode-Drop", "paper/shorcode-drop.q"),
    ("ModMul(4)", "multiply/multiply4.q"),
    ("ModMul(4)-NotInverse", "multiply/multiply4-notinverse.q"),
    ("ModMul(12)", "multiply/multiply12.q"),
    ("ModMul(12)-NotInverse", "multiply/multiply12-notinverse.q"),
]

print(f'Executing the Twist interpreter on {len(tests)} benchmarks and parsing outputs.')
print('Results:\n')
print('| Paper Benchmark         | Filename                           | Valid | Types | Static | Dynamic |')
print('| ----------------------- | ---------------------------------- | ----- | ----- | ------ | ------- |')

for (name, test) in tests:
    result = subprocess.run(["./twist", "-no_print", "tests/" + test], capture_output=True, text=True).stdout.split("\n")[1:-1]
    types = 'Type checking successful' in result
    static = 'Static analysis successful' in result
    dynamic = 'Program executed successfully.' in result
    valid = types and static and dynamic
    def fmt(prev, x):
        if x: return ' o '
        elif prev: return ' x '
        else: return 'N/A'
    print(f'| {name:23} | {"`" + test + "`":34} | {" " + fmt(True, valid) + " "} | {" " + fmt(True, types) + " "} | {" " + fmt(types, static) + "  "} | {"  " + fmt(types and static, dynamic) + "  "} |')
