#!/usr/bin/env python3
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import numpy as np
import os
import re
import subprocess
import sys

if not os.path.exists("./twist"):
    print("Error: Please execute `make` to produce the `twist` binary first.")
    sys.exit(1)

if len(sys.argv) < 2:
    print("Usage: bench.py [max number of qubits] [-mixed]")
    sys.exit(1)

try:
    N = int(sys.argv[1])
except ValueError:
    print("Usage: bench.py [max number of qubits] [-mixed]")
    sys.exit(1)

if N < 4 or N > 24:
    print("Error: Supported number of qubits is between 4 and 24.")
    sys.exit(1)

all_run_time = []
all_run_time_ste = []
all_frac = []
all_frac_err = []

use_mixed = "-mixed" in sys.argv

print("Executing each test for 10 runs.")
print(" # qubits:          run time           fraction in dynamic check")
for i in range(4, N + 1):
    result = subprocess.run(["./twist", "-bench"] + (["-mixed"] if use_mixed else []) + ["tests/multiply/multiply" + str(i) + ".q"], capture_output=True, text=True).stdout.split("\n")[1:-1]
    run_times = []
    sep_times = []
    for line in result:
        res = re.search("Run time: ([0-9\.]*)ms.*dynamic time: ([0-9\.]*)ms", line, re.IGNORECASE)
        run_time, sep_time = res.groups()
        run_times.append(float(run_time))
        sep_times.append(float(sep_time))
    run_time_mean = np.mean(run_times)
    sep_time_mean = np.mean(sep_times)
    run_time_ste = np.std(run_times, ddof=1) / np.sqrt(len(result))
    sep_time_ste = np.std(sep_times, ddof=1) / np.sqrt(len(result))
    frac = sep_time_mean / run_time_mean
    frac_err = sep_time_ste / run_time_mean
    all_run_time.append(run_time_mean)
    all_run_time_ste.append(run_time_ste)
    all_frac.append(frac * 100)
    all_frac_err.append(frac_err * 100)
    print(f"{i:2} qubits: {run_time_mean:10.3f} +/- {run_time_ste:6.3f} ms       {frac * 100:5.3f} +/- {frac_err * 100:5.3f}%")

x = np.arange(4, N+1)

fig, (ax1, ax2) = plt.subplots(1, 2,figsize=(15,7))
ax1.errorbar(x, np.array(all_run_time), yerr=np.array(all_run_time_ste), fmt='o-')
ax1.set_title('Total execution time of ModMul(n) programs')
ax1.set_xlabel('Number of qubits')
ax1.set_ylabel('Total execution time (ms)')
ax1.set_yscale('log')

ax2.errorbar(x, np.array(all_frac), yerr=np.array(all_frac_err), fmt='o-')
ax2.set_title('Runtime check overhead of ModMul(n) programs')
ax2.set_xlabel('Number of qubits')
ax2.set_ylabel('Runtime check overhead')
ax2.yaxis.set_major_formatter(mtick.PercentFormatter())

fig.savefig('bench.pdf')
print("Plots saved to bench.pdf.")
