# HPL Benchmark 

## What HPL Does

HPL solves `Ax = b` where A is a random N×N matrix (FP64). Nobody needs the answer — it's a stress test. The score is **Gflops** (billions of floating-point ops per second). Total work ≈ `2/3·N³ + 2·N²`.

The algorithm: **LU factorization with partial pivoting**. Decompose A into L (lower triangular) × U (upper triangular), then solve via forward/backward substitution. The factorization is where all the compute happens.

HPL is the TOP500 benchmark.

---

## HPL.dat Parameters

```
N       — matrix dimension (A is N×N, uses N²×8 bytes of memory)
NB      — block/tile size for 2D block-cyclic distribution
P × Q   — process grid (must equal total MPI ranks / GPUs)
PFACT   — panel factorization algorithm (0=Left, 1=Crout, 2=Right)
RFACT   — recursive panel factorization algorithm (same options)
BCAST   — broadcast algorithm (0=1rg, 1=1rM, 2=2rg, 3=2rM, 4=Lng, 5=LnM)
DEPTH   — lookahead depth
SWAP    — swapping algorithm (0=bin-exch, 1=long, 2=mix)
Threshold — residual pass/fail gate (default 16.0)
```

---

## Scientific Notation Quick Reference

| Notation | Value | Meaning |
|---|---|---|
| `1.11e-16` | 0.000000000000000111 | Machine epsilon (tiny) |
| `5.05e-03` | 0.00505 | Residual (small) |
| `4.41e+01` | 44.1 | Gflops (normal) |

Negative exponent = tiny. Positive = big. Bigger negative = tinier.

---

## Machine Epsilon & Residual Check

```
eps = 1.110223e-16
```

This is the smallest FP64 gap near 1.0 — hardware constant, always the same.

**Residual formula:**

```
||Ax-b||∞ / (eps × (||A||∞ × ||x||∞ + ||b||∞) × N)
```

This ratio must be **< threshold (16.0)** to PASS.

**Why threshold = 16×eps?** Each floating-point operation introduces tiny rounding error. Over N³ operations, errors accumulate. 16× gives headroom for normal numerical drift.

**PASS** = normal FP noise. **FAIL** = something broken (bad memory, ECC errors, overheating) OR misconfigured threshold.

### Examples

| Expected | Computed | Residual | vs 16×eps (1.78e-15) | Result |
|---|---|---|---|---|
| 5.0 | 5.0000000000000008 | 8e-16 | below | PASS |
| 1000.0 | 1000.00000001 | 1e-8 | way above | FAIL |
| 0.1+0.2 | 0.30000000000000004 | 4e-17 | below | PASS |

Parallel GPUs can produce different results because `(a+b)+c ≠ a+(b+c)` in floating point — thread scheduling, reduction trees, and fused multiply-add all cause tiny drift.

---

## HPL Output Anatomy

```
T/V                N    NB     P     Q               Time                 Gflops
WR10C2C4        4000   192     1     1               0.97             4.4105e+01
```

**T/V code `WR10C2C4`:** W=wall time, R=row-major, 1=BCAST variant, 0=lookahead depth, C=Crout PFACT, 2=mix swap, C=Crout RFACT, 4=detail.

**Progress lines** (`Column=... Fraction=... Gflops=...`): one line per NB-wide panel processed. Fraction = Column/N. Gflops = cumulative average, not instantaneous.

**VVV timing breakdown:**

| Field | What it measures |
|---|---|
| rfact | Recursive panel factorization (serial bottleneck) |
| pfact | Panel factorization within rfact |
| mxswp | Pivot row swaps during factorization |
| update | Trailing matrix update (parallel DGEMM — the bulk) |
| laswp | Row swaps during update |
| up tr sv | Upper triangular solve (back-substitution) |

These overlap, so they don't sum to total Time.

---

## Experiment Results (macOS Docker, Apple Silicon)

### Setup

Docker container with netlib HPL 2.3 + OpenBLAS + OpenMPI. See `Dockerfile` and `Make.linux`.

```bash
docker run --rm -it -v ~/hpl-lab/exercises:/workspace hpl-lab
./run_hpl.sh <N> <NB> <P> <Q> [PFACT] [RFACT] [BCAST] [THRESHOLD]
```

---

### Experiment A — Block Size (NB) Sweep

**Fixed:** N=4000, P=1, Q=1

| NB | Gflops | vs Best | rfact (s) | update (s) |
|---|---|---|---|---|
| 64 | 42.49 | -5.1% | 0.03 | 0.97 |
| 128 | 44.27 | -1.2% | 0.04 | 0.92 |
| 192 | 44.50 | -0.7% | 0.05 | 0.90 |
| **256** | **44.80** | **BEST** | 0.07 | 0.88 |
| 384 | 44.60 | -0.4% | 0.10 | 0.86 |
| 512 | 43.57 | -2.7% | 0.12 | 0.85 |

**Pattern:** rfact grows with NB (bigger panels to factor), update shrinks (fewer but more efficient DGEMM calls). Peak is where the tradeoff balances — NB=256 on this hardware.

**Exam answer:** "NB changed from 256→512, perf dropped" → tiles exceeded cache capacity, panel factorization cost grew faster than DGEMM efficiency gained.

---

### Experiment B — Problem Size (N) Sweep

**Fixed:** NB=192, P=1, Q=1

| N | Memory | Gflops | Time (s) |
|---|---|---|---|
| 500 | 1.9 MB | 22.83 | 0.00 |
| 1000 | 7.6 MB | 34.33 | 0.02 |
| 2000 | 30.5 MB | 41.31 | 0.13 |
| 4000 | 122 MB | 44.16 | 0.97 |
| 8000 | 488 MB | 45.97 | 7.43 |
| 12000 | 1.1 GB | 46.47 | 24.80 |

**Pattern 1 — Gflops rises then plateaus.** Small N = overhead dominates (49% efficiency at N=500). Large N = near peak (99% at N=12000). This is why you use ~80% of available memory.

**Pattern 2 — Time grows as N³.** Doubling N ≈ 8× time:

| N doubled | Time ratio | Expected |
|---|---|---|
| 1000→2000 | 6.5× | 8× |
| 2000→4000 | 7.5× | 8× |
| 4000→8000 | 7.7× | 8× |

---

### Experiment C — Process Grid (P×Q) Sweep

**Fixed:** N=8000, NB=192

| P×Q | np | Gflops | Time (s) | rfact (s) | mxswp (s) | update (s) |
|---|---|---|---|---|---|---|
| 1×1 | 1 | 44.13 | 7.74 | 0.20 | 0.01 | 7.53 |
| **1×2** | **2** | **80.08** | **4.26** | **0.13** | **0.01** | **4.14** |
| 2×1 | 2 | 79.43 | 4.30 | 0.18 | 0.09 | 4.14 |
| 2×2 | 4 | 4.16 | 82.04 | 40.94 | 23.75 | 46.18 |
| 1×4 | 4 | 9.65 | 35.37 | 4.16 | 0.01 | 32.08 |
| 4×1 | 4 | 3.12 | 109.47 | 93.80 | 65.70 | 14.14 |

**Why np=2 helped but np=4 collapsed:** Mac has 2 performance cores — 2 processes get real parallelism. 4 processes on 2 cores = pure contention. On a real cluster with separate GPUs, more processes = faster.

**Why P×Q orientation matters — the mxswp column tells the story:**

- **4×1** (P=4): `mxswp = 65.70s` — 4 processes swapping pivot rows vertically, thrashing
- **1×4** (Q=4): `mxswp = 0.01s` — only 1 process in the panel column, no vertical swaps
- **2×2**: `mxswp = 23.75s` — middle ground

**How P and Q work in the algorithm:**

P = processes sharing a block-column, talking **vertically** (panel broadcast + pivot swaps). This direction is used heavily → more P = more vertical communication = slower.

Q = processes sharing a block-row, talking **horizontally** (trailing update distribution). Used less frequently → more Q = less painful.

**Exam rule for real clusters:** near-square grid, P ≥ Q for NVIDIA Ozaki-II. 8 GPUs → 4×2. 32 GPUs → 8×4.

---

## Memory Sizing

```
Matrix A = N² × 8 bytes
Total with workspace ≈ N² × 8 × 1.1
Target N: use ~80% of available GPU/system memory
```

| Memory | Max N (approx) |
|---|---|
| 8 GB | ~30,000 |
| 40 GB (A100) | ~67,000 |
| 80 GB (H100) | ~95,000 |

---

## Exam Cheat Sheet

| Parameter | Key fact |
|---|---|
| N | Bigger = higher Gflops (better compute/comm ratio). Use 80% of memory. Time ∝ N³. |
| NB | Sweet spot exists (cache vs DGEMM efficiency). Typical: 192/256/448 on GPUs. N should be divisible by NB. |
| P×Q | Must equal GPU count. Near-square. P ≥ Q on NVIDIA. Mismatch with `-np` → crash. |
| PFACT/RFACT | Left/Crout/Right — small impact (1-5%), know they exist. |
| BCAST | 6 algorithms (1rg through LnM). Matters at 256+ GPUs. |
| Threshold | 16.0 default. Residual doesn't change when you change threshold — only the gate does. |
| FAILED | Could be bad threshold OR real hardware issue (ECC errors, overheating → residual is NaN or 1000+). |
| eps | 1.11e-16 always. Hardware constant. Can't change it. |

---

## Lab Setup Reference

```bash
# Build (one time)
cd ~/hpl-lab
docker build -t hpl-lab .

# Run
docker run --rm -it -v ~/hpl-lab/exercises:/workspace hpl-lab
./run_hpl.sh 4000 192 1 1                    # basic
./run_hpl.sh 4000 192 1 1 0 0 0 0.001        # force FAIL
```
