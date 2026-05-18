# HPL Hands-On Lab — NCP-AII Exam Prep

## What You're About to Learn

HPL (High Performance Linpack) solves a **dense system of linear equations** `Ax = b` where:

- **A** is an N×N matrix of random double-precision (FP64) numbers
- **x** is the unknown vector (N×1)
- **b** is the right-hand side vector (N×1)
- The solver uses **LU factorization with partial pivoting**: decompose A into L (lower triangular) and U (upper triangular) so that PA = LU, then solve by forward/backward substitution

The benchmark measures how many **floating-point operations per second (GFLOPS)** the system achieves. The total work is approximately `2/3·N³ + 2·N²` operations. After solving, it checks correctness via a **residual test**.

---

## PHASE 0 — Setup on macOS ✅ DONE

You've already completed setup. For reference, here's what you built:

**Your `~/hpl-lab/` folder contains two files:**
- `Dockerfile` — builds Ubuntu 22.04 with OpenMPI + OpenBLAS + HPL 2.3
- `Make.linux` — the HPL build config (architecture-independent, works on Apple Silicon)

**Your image is ready:** `hpl-lab`

**To start a lab session, run this every time:**

```bash
mkdir -p ~/hpl-lab/exercises
docker run --rm -it -v ~/hpl-lab/exercises:/workspace hpl-lab
```

This drops you into `/workspace` inside the container. Files you create here persist on your Mac at `~/hpl-lab/exercises/` (so you don't lose results when the container exits).

**To exit the container:** type `exit` or press Ctrl+D.
**To re-enter:** just run the `docker run` command again.

---

## START HERE → Launch your lab session

Open Terminal on your Mac and run:

```bash
docker run --rm -it -v ~/hpl-lab/exercises:/workspace hpl-lab
```

You're now inside the container. First, create a helper script that makes running experiments much faster:

```bash
cat > /workspace/run_hpl.sh << 'SCRIPT'
#!/bin/bash
# Usage: ./run_hpl.sh <N> <NB> <P> <Q> [PFACT] [RFACT] [BCAST] [THRESHOLD]
#
# Example: ./run_hpl.sh 4000 192 1 1
# Example: ./run_hpl.sh 4000 192 2 2 1 1 0 16.0

N=${1:-1000}
NB=${2:-128}
P=${3:-1}
Q=${4:-1}
PFACT=${5:-1}
RFACT=${6:-1}
BCAST=${7:-0}
THRESH=${8:-16.0}
NP=$((P * Q))

cat > HPL.dat << EOF
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
${N}         Ns
1            # of NBs
${NB}        NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
${P}         Ps
${Q}         Qs
${THRESH}    threshold
1            # of panel fact
${PFACT}     PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
${RFACT}     RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
${BCAST}     BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF

echo "=========================================="
echo "  N=$N  NB=$NB  P=$P  Q=$Q  np=$NP"
echo "  PFACT=$PFACT  RFACT=$RFACT  BCAST=$BCAST  THRESH=$THRESH"
echo "=========================================="
mpirun -np $NP xhpl 2>&1 | tee /tmp/hpl_last.out
echo ""
echo "--- SUMMARY ---"
grep -E "^W|PASSED|FAILED" /tmp/hpl_last.out
SCRIPT
chmod +x /workspace/run_hpl.sh
```

**Now you can run any experiment in one line:**

```bash
./run_hpl.sh 1000 128 1 1              # basic run
./run_hpl.sh 4000 192 1 1              # bigger N
./run_hpl.sh 8000 192 2 2              # multi-process
./run_hpl.sh 4000 192 1 1 0 0 0 16.0   # left/left factorization
./run_hpl.sh 4000 192 1 1 1 1 0 0.001  # tight threshold → FAILED
```

Arguments in order: `N  NB  P  Q  [PFACT]  [RFACT]  [BCAST]  [THRESHOLD]`

---

## PHASE 1 — First Run: Understand the Input/Output (45 min)

### Exercise 1.1: Your first HPL.dat

Inside the container, create your first input file:

```bash
cat > HPL.dat << 'EOF'
HPLinpack benchmark input file
Innovative Computing Laboratory, University of Tennessee
HPL.out      output file name (if any)
6            device out (6=stdout,7=stderr,file)
1            # of problems sizes (N)
1000         Ns
1            # of NBs
128          NBs
0            PMAP process mapping (0=Row-,1=Column-major)
1            # of process grids (P x Q)
1            Ps
1            Qs
16.0         threshold
1            # of panel fact
1            PFACTs (0=left, 1=Crout, 2=Right)
1            # of recursive stopping criterium
4            NBMINs (>= 1)
1            # of panels in recursion
2            NDIVs
1            # of recursive panel fact.
1            RFACTs (0=left, 1=Crout, 2=Right)
1            # of broadcast
0            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)
1            # of lookahead depth
1            DEPTHs (>=0)
2            SWAP (0=bin-exch,1=long,2=mix)
64           swapping threshold
0            L1 in (0=transposed,1=no-transposed) form
0            U  in (0=transposed,1=no-transposed) form
1            Equilibration (0=no,1=yes)
8            memory alignment in double (> 0)
EOF
```

### Exercise 1.2: Run it and read every line

```bash
mpirun -np 1 xhpl
```

**What to look for in the output (annotated):**

```
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark  --   December 2, 2018
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
================================================================================

...input file echo...

N      :    1000        ← matrix size (your "A" is 1000×1000)
NB     :     128        ← block size for distribution
PMAP   : Row-major      ← how processes map to the grid
P      :       1        ← process grid rows
Q      :       1        ← process grid columns
...
================================================================================
T/V    N    NB   P   Q      Time     Gflops
--------------------------------------------------------------------------------
WC00L2L2  1000  128  1   1      0.28     2.38e+00
...
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N) =  0.0061520 ...... PASSED
================================================================================
```

**Decode the T/V code `WC00L2L2`:**
- `W` = Wall-clock time (vs `C` for CPU time)
- `C` = Column-major storage
- `0` = Row-major process mapping
- `0` = specific BCAST variant
- `L` = Left-looking panel factorization
- `2` = mix swap
- `L` = Left-looking recursive panel fact
- `2` = mix swap

**Decode the residual line:**
```
||Ax-b||_oo / (eps * (||A||_oo * ||x||_oo + ||b||_oo) * N) = 0.0061520
```

- `||Ax-b||_oo` = the infinity norm of the residual (max absolute error across all equations)
- `eps` = machine epsilon for FP64 (~2.2e-16)
- `||A||_oo`, `||x||_oo`, `||b||_oo` = infinity norms of matrix A, solution x, right-hand side b
- `N` = matrix size
- This ratio must be **< threshold (16.0)** to PASS
- The smaller this number, the more accurate the solution

📝 **Write down:** Your N, NB, P, Q, Time, Gflops, and residual value.

### Exercise 1.3: Understand the memory footprint

The matrix A alone occupies: `N² × 8 bytes`

For N=1000: `1000² × 8 = 8,000,000 bytes ≈ 7.6 MB`

With the vectors, workspace, and panel buffers, total is roughly `N² × 8 × 1.1` bytes.

**Calculate for yourself:**

| N | Matrix A size | Approx total memory |
|---|---|---|
| 1,000 | 7.6 MB | ~8.4 MB |
| 5,000 | 190 MB | ~210 MB |
| 10,000 | 763 MB | ~840 MB |
| 20,000 | 3.05 GB | ~3.4 GB |
| 40,000 | 12.2 GB | ~13.4 GB |

This is **why N is the most critical parameter**: it determines both the work done (N³) and the memory needed (N²). On a real DGX H100 with 80 GB per GPU, max N per GPU ≈ ~100,000.

### Exercise 1.4: Force a FAILED result

Edit HPL.dat — change only the threshold line:

```
0.0000001    threshold
```

Run again. The residual value won't change (same math), but now the gate is impossibly tight. You'll see **FAILED**. This teaches you that FAILED doesn't always mean broken hardware — it can be a misconfigured threshold.

Reset threshold back to 16.0 before continuing.

---

## PHASE 2 — Parameter Sweep Experiments (2–2.5 hours)

**Golden rule: change ONE thing per run.** This is exactly how exam questions work: "You changed X, what happens to Y?"

Create a results tracking file:

```bash
cat > results.csv << 'EOF'
experiment,N,NB,P,Q,np,PFACT,BCAST,Time,Gflops,Residual,Pass
EOF
```

After each run, append your result.

---

### Experiment A: Block Size (NB) Sweep

**Why this matters:** NB controls how the matrix is decomposed into tiles. Each tile is NB×NB. The BLAS DGEMM kernel operates on these tiles. Too small = too many tiny DGEMM calls with overhead. Too big = poor load balancing and L2 cache misses.

**Hold constant:** N=4000, P=1, Q=1

Run each one and record the Gflops from the summary line:

```bash
./run_hpl.sh 4000 32  1 1    # A1
./run_hpl.sh 4000 64  1 1    # A2
./run_hpl.sh 4000 128 1 1    # A3
./run_hpl.sh 4000 192 1 1    # A4
./run_hpl.sh 4000 256 1 1    # A5
./run_hpl.sh 4000 384 1 1    # A6
./run_hpl.sh 4000 512 1 1    # A7
```

| Run | NB | Your Gflops | Expected behavior |
|---|---|---|---|
| A1 | 32 | _____ | Low — tiles too small, DGEMM overhead |
| A2 | 64 | _____ | Better |
| A3 | 128 | _____ | Approaching sweet spot |
| A4 | 192 | _____ | Often optimal on modern CPUs |
| A5 | 256 | _____ | May be optimal or start declining |
| A6 | 384 | _____ | Likely declining — tiles too big for cache |
| A7 | 512 | _____ | Usually worse |

📝 **Record:** NB vs Gflops. You should see a curve that rises, peaks, then falls.

**Exam-style question this answers:** *"An engineer changed NB from 192 to 512. Performance dropped by 20%. Why?"* → Tiles exceeded L2 cache capacity; DGEMM efficiency dropped.

---

### Experiment B: Problem Size (N) Sweep

**Why this matters:** N determines total work (∝ N³) and memory (∝ N²). Small N → the overhead of factorization setup, pivoting, and MPI communication dominates. Large N → computation dominates and you approach peak FLOPS. But too large → OOM.

**Hold constant:** NB=192, P=1, Q=1

```bash
./run_hpl.sh 500   192 1 1    # B1
./run_hpl.sh 1000  192 1 1    # B2
./run_hpl.sh 2000  192 1 1    # B3
./run_hpl.sh 4000  192 1 1    # B4
./run_hpl.sh 8000  192 1 1    # B5  (takes ~30-60 sec)
./run_hpl.sh 12000 192 1 1    # B6  (takes a few minutes)
./run_hpl.sh 16000 192 1 1    # B7  (takes longer, skip if impatient)
```

| Run | N | Matrix size | Your Gflops | Your Time |
|---|---|---|---|---|
| B1 | 500 | 1.9 MB | _____ | _____ |
| B2 | 1000 | 7.6 MB | _____ | _____ |
| B3 | 2000 | 30.5 MB | _____ | _____ |
| B4 | 4000 | 122 MB | _____ | _____ |
| B5 | 8000 | 488 MB | _____ | _____ |
| B6 | 12000 | 1.1 GB | _____ | _____ |
| B7 | 16000 | 1.95 GB | _____ | _____ |

**Quick run:**

```bash
# If B7 takes too long or crashes with OOM, that's fine — skip it
# The learning is in the trend from B1→B6
```

⚠️ **Warning:** If Docker only has 4 GB RAM, N=16000 (needs ~2 GB + overhead) should still work. N=20000+ may OOM. If you see `Killed` or `SIGKILL`, reduce N.

📝 **Record:** N vs Gflops AND N vs Time. Notice:
- Gflops **increases** with N (better compute/comm ratio)
- Time increases as **N³** (cube law — doubling N makes it ~8× slower)

**Exam-style question:** *"Why does HPL recommend using 70-80% of total memory?"* → Maximizes N (more work, better efficiency) while leaving headroom for the OS, buffers, and panel workspace.

---

### Experiment C: Process Grid (P × Q) — Multi-Process

**Why this matters:** In a real cluster, P×Q = total MPI ranks = total GPUs. The matrix is distributed across the grid using **2D block-cyclic distribution**. P = rows in process grid, Q = columns. Communication patterns differ:

- **Panel broadcast** goes along columns (affected by P)
- **Row swaps** go along rows (affected by Q)
- Square grids (P ≈ Q) balance both
- NVIDIA recommends P ≥ Q for their Ozaki-II scheme

**Hold constant:** N=8000, NB=192

```bash
./run_hpl.sh 8000 192 1 1    # C1 — baseline
./run_hpl.sh 8000 192 1 2    # C2 — 2 procs, wide
./run_hpl.sh 8000 192 2 1    # C3 — 2 procs, tall
./run_hpl.sh 8000 192 2 2    # C4 — 4 procs, square
./run_hpl.sh 8000 192 1 4    # C5 — 4 procs, very wide
./run_hpl.sh 8000 192 4 1    # C6 — 4 procs, very tall
```

| Run | P | Q | np (P×Q) | Your Gflops | Expected |
|---|---|---|---|---|---|
| C1 | 1 | 1 | 1 | _____ | Baseline |
| C2 | 1 | 2 | 2 | _____ | Faster than C1 but not 2× |
| C3 | 2 | 1 | 2 | _____ | Compare to C2 — different! |
| C4 | 2 | 2 | 4 | _____ | Best with 4 processes |
| C5 | 1 | 4 | 4 | _____ | Worse than C4 — unbalanced |
| C6 | 4 | 1 | 4 | _____ | Worse than C4 — unbalanced |

⚠️ **Critical:** `np` in `mpirun -np X` MUST equal `P × Q`. If they don't match, HPL will crash or give garbage. This is a common exam trick question.

📝 **Key insight to record:** 
- 2×2 beats both 1×4 and 4×1 (square is balanced)
- Going from 1→2→4 processes does NOT give 1×→2×→4× speedup (Amdahl's law + comm overhead)
- On your laptop, overhead may actually make more processes slower (they share the same CPU cores, unlike a real cluster)

**Exam-style question:** *"A cluster has 8 GPUs. Which P×Q is optimal: 1×8, 2×4, 4×2, or 8×1?"* → 2×4 or 4×2 (near-square), with P≥Q preferred on NVIDIA for Ozaki-II → 4×2.

---

### Experiment D: Panel Factorization Variants

**Why this matters:** The panel factorization is the serial bottleneck — it factors a narrow vertical slice of the matrix before the rest can be updated. Different algorithms have different numerical and performance characteristics.

**Hold constant:** N=4000, NB=192, P=1, Q=1

```bash
./run_hpl.sh 4000 192 1 1 0 0    # D1 — Left/Left
./run_hpl.sh 4000 192 1 1 1 1    # D2 — Crout/Crout
./run_hpl.sh 4000 192 1 1 2 2    # D3 — Right/Right
./run_hpl.sh 4000 192 1 1 0 2    # D4 — Left/Right (mixed)
```

| Run | PFACT | RFACT | Name | Your Gflops |
|---|---|---|---|---|
| D1 | 0 | 0 | Left-looking / Left-looking | _____ |
| D2 | 1 | 1 | Crout / Crout | _____ |
| D3 | 2 | 2 | Right-looking / Right-looking | _____ |
| D4 | 0 | 2 | Left / Right (mixed) | _____ |

📝 **Record:** Differences will be small (1-5%) on CPU, bigger on GPU. The exam asks you to *know they exist and what they do*, not to predict exact numbers.

---

### Experiment E: Broadcast Algorithm

**Why this matters:** After each panel is factored, it must be sent to all process columns. On a real cluster with hundreds of GPUs, this is a major bottleneck. The algorithm choice affects latency vs bandwidth trade-offs.

**Hold constant:** N=8000, NB=192, P=2, Q=2

```bash
./run_hpl.sh 8000 192 2 2 1 1 0    # E1 — 1-ring
./run_hpl.sh 8000 192 2 2 1 1 1    # E2 — 1-ring Modified
./run_hpl.sh 8000 192 2 2 1 1 2    # E3 — 2-ring
./run_hpl.sh 8000 192 2 2 1 1 3    # E4 — 2-ring Modified
./run_hpl.sh 8000 192 2 2 1 1 4    # E5 — Long
./run_hpl.sh 8000 192 2 2 1 1 5    # E6 — Long Modified
```

| Run | BCAST | Algorithm | Your Gflops | Best for |
|---|---|---|---|---|
| E1 | 0 | 1-ring | _____ | Small panels, low latency |
| E2 | 1 | 1-ring Modified | _____ | Overlap friendly |
| E3 | 2 | 2-ring | _____ | Larger panels |
| E4 | 3 | 2-ring Modified | _____ | Large clusters |
| E5 | 4 | Long | _____ | Bandwidth-bound cases |
| E6 | 5 | Long Modified | _____ | Bandwidth + overlap |

Edit line 23 of HPL.dat:

```
1            # of broadcast
3            BCASTs (0=1rg,1=1rM,2=2rg,3=2rM,4=Lng,5=LnM)  ← change
```

📝 With only 4 processes on a laptop you won't see big differences, but on 256+ GPUs this choice can swing Gflops by 10-15%. Know the concepts.

---

### Experiment F: N Not Divisible by NB

**Why this matters:** When N is evenly divisible by NB, every tile is the same size and DGEMM runs at peak. When it's not, the last tile is a "runt" — smaller, less efficient.

**Hold constant:** NB=192, P=1, Q=1

```bash
./run_hpl.sh 3840 192 1 1    # F1 — 3840/192 = 20.0 (clean)
./run_hpl.sh 3800 192 1 1    # F2 — 3800/192 = 19.79 (runt)
./run_hpl.sh 3900 192 1 1    # F3 — 3900/192 = 20.31 (runt)
./run_hpl.sh 4032 192 1 1    # F4 — 4032/192 = 21.0 (clean)
```

| Run | N | N/NB | N mod NB | Your Gflops | Expected |
|---|---|---|---|---|---|
| F1 | 3840 | 20.0 | 0 | _____ | Clean, good perf |
| F2 | 3800 | 19.79 | 152 | _____ | Slightly worse |
| F3 | 3900 | 20.31 | 60 | _____ | Slightly worse |
| F4 | 4032 | 21.0 | 0 | _____ | Clean, good perf |

📝 The difference might be small (1-3%) but on a $200M supercomputer, that's real money. This is why tuning guides say "make N divisible by NB".

---

### Experiment G: Threshold and the Residual Check

**Why this matters:** The threshold determines PASS/FAIL. The actual residual is a measure of numerical accuracy. Understanding this formula is critical for exam questions.

```
||Ax-b||_oo / (eps * (||A||_oo * ||x||_oo + ||b||_oo) * N)
```

**Breakdown:**
- After solving, HPL computes x̂ (computed solution)
- It then computes Ax̂ - b (the residual — should be zero in exact arithmetic)
- `||Ax-b||_oo` = max row sum of the residual = how wrong the answer is
- The denominator scales this by problem size and machine precision
- A value < 16.0 means "the error is within 16× the best we could theoretically expect"

**Hold constant:** N=4000, NB=192, P=1, Q=1

```bash
./run_hpl.sh 4000 192 1 1 1 1 0 16.0       # G1 — standard threshold
./run_hpl.sh 4000 192 1 1 1 1 0 100.0      # G2 — very lenient
./run_hpl.sh 4000 192 1 1 1 1 0 1.0        # G3 — tight
./run_hpl.sh 4000 192 1 1 1 1 0 0.001      # G4 — very tight
./run_hpl.sh 4000 192 1 1 1 1 0 0.0000001  # G5 — impossible
```

| Run | Threshold | Your Residual | PASSED/FAILED | Expected |
|---|---|---|---|---|
| G1 | 16.0 | _____ | _____ | PASSED (standard) |
| G2 | 100.0 | _____ | _____ | PASSED (very lenient) |
| G3 | 1.0 | _____ | _____ | Probably PASSED (tight but feasible) |
| G4 | 0.001 | _____ | _____ | Probably FAILED (too tight) |
| G5 | 0.0000001 | _____ | _____ | Definitely FAILED |

📝 **Key insight:** The *residual value itself doesn't change* between G1-G5 (same math, same matrix). Only the gate changes. This is why FAILED doesn't always mean hardware failure.

**Real hardware failures** show residual values that are wildly high (like 1000+) or NaN — that's ECC errors, bad GPU memory, or overheating causing bit flips.

---

## Summary: Your Recording Sheet

After all experiments, fill in this table:

```
EXPERIMENT A - NB SWEEP (N=4000, P=1, Q=1)
NB=32:   _____ Gflops
NB=64:   _____ Gflops
NB=128:  _____ Gflops
NB=192:  _____ Gflops
NB=256:  _____ Gflops
NB=384:  _____ Gflops
NB=512:  _____ Gflops
→ Optimal NB on my system: _____

EXPERIMENT B - N SWEEP (NB=192, P=1, Q=1)
N=500:   _____ Gflops, _____ sec
N=1000:  _____ Gflops, _____ sec
N=2000:  _____ Gflops, _____ sec
N=4000:  _____ Gflops, _____ sec
N=8000:  _____ Gflops, _____ sec
N=12000: _____ Gflops, _____ sec
→ Does doubling N ~8x the time? _____

EXPERIMENT C - P×Q GRID (N=8000, NB=192)
1×1 (np=1): _____ Gflops
1×2 (np=2): _____ Gflops
2×1 (np=2): _____ Gflops
2×2 (np=4): _____ Gflops
1×4 (np=4): _____ Gflops
4×1 (np=4): _____ Gflops
→ Best grid shape: _____

EXPERIMENT D - PFACT/RFACT (N=4000, NB=192)
Left/Left:   _____ Gflops
Crout/Crout: _____ Gflops
Right/Right: _____ Gflops
→ Difference range: _____% 

EXPERIMENT E - BCAST (N=8000, NB=192, P=2, Q=2)
1rg:  _____ Gflops
1rM:  _____ Gflops
2rg:  _____ Gflops
2rM:  _____ Gflops
Lng:  _____ Gflops
LnM:  _____ Gflops

EXPERIMENT F - DIVISIBILITY (NB=192, P=1, Q=1)
N=3840 (clean): _____ Gflops
N=3800 (runt):  _____ Gflops
N=3900 (runt):  _____ Gflops
N=4032 (clean): _____ Gflops

EXPERIMENT G - THRESHOLD (N=4000)
Residual value (same every run): _____
Threshold=16.0:      PASSED / FAILED
Threshold=0.001:     PASSED / FAILED
Threshold=0.0000001: PASSED / FAILED
```

---

## Quick Reference: HPL.dat Line Map

| Line | Parameter | What it controls | Exam hot? |
|---|---|---|---|
| 5-6 | N (Ns) | Problem/matrix size | 🔥🔥🔥 |
| 7-8 | NB (NBs) | Block/tile size | 🔥🔥🔥 |
| 9 | PMAP | Row vs column process mapping | 🔥 |
| 10-12 | P, Q | Process grid dimensions | 🔥🔥🔥 |
| 13 | Threshold | Residual pass/fail gate | 🔥🔥 |
| 14-15 | PFACT | Panel factorization algorithm | 🔥 |
| 16-17 | NBMIN | Recursive stopping point | ⚪ |
| 18-19 | NDIV | Recursive panel divisions | ⚪ |
| 20-21 | RFACT | Recursive panel fact. algorithm | 🔥 |
| 22-23 | BCAST | Broadcast algorithm | 🔥🔥 |
| 24-25 | DEPTH | Lookahead depth | 🔥 |
| 26 | SWAP | Swapping algorithm | ⚪ |
| 27 | Swap threshold | When to switch swap algo | ⚪ |
| 28 | L1 form | Transposed or not | ⚪ |
| 29 | U form | Transposed or not | ⚪ |
| 30 | Equilibration | Row equilibration | ⚪ |
| 31 | Alignment | Memory alignment | ⚪ |

🔥🔥🔥 = expect multiple exam questions  
🔥🔥 = expect at least one question  
🔥 = know the concept  
⚪ = just know it exists

---

## What's Next (Phase 3+)

Once you've completed these experiments and shared your results with me, we'll move to:

- **Phase 3:** Single GPU run on NVIDIA's container (hpl.sh, --cpu-affinity, --gpu-affinity)
- **Phase 4:** Multi-GPU P×Q on real hardware
- **Phase 5:** Failure modes, ECC errors, burn-in testing, OOC mode
- **Phase 6:** Adjacent tools (NCCL-tests, ClusterKit, DCGM)

Come back with your filled-in recording sheet and we'll analyze your results together. 🚀
