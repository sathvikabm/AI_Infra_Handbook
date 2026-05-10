# NCCL Test Flags — Hands-On 

**Setup**: 4 GPUs. Run inside the NCCL-tests container or compiled binaries from `nccl-tests/build/`.

---

## One-time setup (5 min)

```bash
# Container approach (easiest)
docker run --gpus all --rm -it --shm-size=1g \
  --ulimit memlock=-1 --ulimit stack=67108864 \
  nvcr.io/nvidia/pytorch:24.07-py3 bash

# Inside container, find the binaries
which all_reduce_perf || find / -name "all_reduce_perf" 2>/dev/null
# Typically /opt/nccl-tests/build/ or build manually:

git clone https://github.com/NVIDIA/nccl-tests
cd nccl-tests && make -j
export NTEST=$PWD/build
ls $NTEST
# all_gather_perf  all_reduce_perf  alltoall_perf  broadcast_perf
# gather_perf      hypercube_perf   reduce_perf    reduce_scatter_perf
# scatter_perf     sendrecv_perf
```

Open a second terminal for `nvidia-smi dmon -s pucvmet -d 1` to watch live during runs.

---

## Drill 1 — `-g` (GPUs per process) — **most important**

**Predict**: If I run `all_reduce_perf -b 1G -e 1G -g 1`, then `-g 2`, then `-g 4`, what happens to **algbw**? to **busbw**? to **time**?

Write down your guess: ____________________

### Run:
```bash
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 1 -n 50 -w 10
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 2 -n 50 -w 10
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 4 -n 50 -w 10
```

### Fill in:
| -g | time (us) | algbw (GB/s) | busbw (GB/s) | #wrong |
|----|-----------|--------------|--------------|--------|
| 1  |           |              |              |        |
| 2  |           |              |              |        |
| 4  |           |              |              |        |

### What you should see:
- **`-g 1`**: busbw is essentially 0 or meaningless. With 1 GPU, "all_reduce" has nothing to reduce. algbw still measures something but it's noise.
- **`-g 2`**: busbw factor = 2(2-1)/2 = **1.0**, so busbw == algbw. Two GPUs talk over one NVLink pair.
- **`-g 4`**: busbw factor = 2(4-1)/4 = **1.5**, so busbw = algbw × 1.5. All 4 GPUs in a ring.
- **time grows** with -g (more comm), but **busbw stays roughly the same** because it normalizes per-link.

### Lock-in: `-g` controls **how many GPUs participate**. busbw factor depends on it.

---

## Drill 2 — `-b` and `-e` (size range) — the BW/latency curve

**Predict**: Where on the size axis does busbw transition from latency-bound (low) to bandwidth-bound (plateau)?

Your guess: __________ KB? __________ MB?

### Run:
```bash
# Full sweep, 8 B → 1 GB, powers of 2
$NTEST/all_reduce_perf -b 8 -e 1G -f 2 -g 4 -n 20 -w 5
```

### What to extract:
Look at the table output. Find:
- The smallest size (8 B) → record `time` and `busbw`.
- 1 KB → time, busbw
- 64 KB → time, busbw
- 1 MB → time, busbw
- 16 MB → time, busbw
- 1 GB → time, busbw

| size | time (us) | busbw (GB/s) |
|------|-----------|--------------|
| 8 B  |           |              |
| 1 KB |           |              |
| 64 KB|           |              |
| 1 MB |           |              |
| 16 MB|           |              |
| 1 GB |           |              |

### What you should see:
- **8 B → 64 KB**: time stays nearly flat at **~10–30 μs** (latency floor). busbw is tiny.
- **64 KB → 1 MB**: transition zone. busbw climbing fast.
- **> 1 MB**: bandwidth-bound regime. busbw plateaus near peak NVLink BW.
- The curve has a **knee around 64 KB–1 MB**.

### Lock-in: `-b` = min size, `-e` = max size. Small msg → latency. Large msg → bandwidth. Knee at ~MB scale.

---

## Drill 3 — `-f` (factor) — sweep resolution

**Predict**: Does `-f` change BW numbers, or just the granularity of measurement points?

### Run:
```bash
# 8 → 1G with factor 2 (lots of points)
$NTEST/all_reduce_perf -b 8 -e 1G -f 2 -g 4 -n 10 -w 3 | wc -l

# Same range with factor 4 (fewer points)
$NTEST/all_reduce_perf -b 8 -e 1G -f 4 -g 4 -n 10 -w 3 | wc -l

# Factor 8 (even fewer)
$NTEST/all_reduce_perf -b 8 -e 1G -f 8 -g 4 -n 10 -w 3 | wc -l
```

### What you should see:
- More lines in the output table for `-f 2` (every doubling).
- Same peak busbw at 1 GB regardless of `-f`.
- `-f 2`: 28 size points (8, 16, 32, ..., 1G).
- `-f 4`: 16 points.
- `-f 8`: 11 points.

### Lock-in: `-f` only changes how many size points you sample. **Does not affect performance**, just measurement resolution.

---

## Drill 4 — `-n` and `-w` (iterations / warmup)

**Predict**: How does increasing `-n` change the reported BW? What about removing warmup with `-w 0`?

### Run:
```bash
# No warmup, few iterations — first-iter overhead included
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 5 -w 0

# Standard
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10

# Lots of iterations, plenty of warmup
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 200 -w 20
```

### Fill in:
| -n | -w | time (us) | busbw (GB/s) |
|----|----|-----------|--------------|
| 5  | 0  |           |              |
| 50 | 10 |           |              |
| 200| 20 |           |              |

### What you should see:
- `-w 0` first run: busbw appears **lower** (often 5–15% lower). NCCL has init/connection-setup overhead on first iteration that pollutes the average.
- More `-n`: tighter average, smaller run-to-run variance.
- `-w 10` and `-w 20` give similar busbw; both are "enough" warmup.

### Lock-in: **`-w` skips first iterations** so init overhead doesn't pollute the measurement. **`-n` is the sample count** for the average. Always use `-w >= 5`. For burn-in: `-n 1000000`.

---

## Drill 5 — `-c` (correctness check) — the perf vs validation tradeoff

**Predict**: How much overhead does `-c 1` add at 1 GB messages?

### Run:
```bash
# No check (raw perf)
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -c 0

# With check
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -c 1
```

### What you should see:
- **`-c 0`**: highest busbw, `#wrong` column is just `N/A` or `-`.
- **`-c 1`**: busbw drops 5–15% (validation copy + compare overhead). `#wrong` column shows `0`.
- If `#wrong` is **non-zero** → silent data corruption. Hardware suspect.

### Lock-in: **`-c 0` for benchmarking peak, `-c 1` for burn-in / soak**. The `#wrong` counter is your SDC alarm.

---

## Drill 6 — `-o` (operation type) — does op affect BW?

**Predict**: Will `min` be slower than `sum`? `prod` slower than both?

### Run:
```bash
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -o sum
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -o min
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -o max
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -o prod
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -o avg
```

### Fill in:
| -o | busbw (GB/s) |
|------|--------------|
| sum  |              |
| min  |              |
| max  |              |
| prod |              |
| avg  |              |

### What you should see:
- **sum, min, max, prod all give virtually identical busbw**. Compute is trivial vs network.
- **avg slightly lower** because of post-divide.

### Lock-in: **op type does not move the needle on BW**. Trick question on the exam: "would changing -o sum to -o min affect throughput?" → **No** (within margin).

---

## Drill 7 — `-d` (data type) — bytes are bytes

**Predict**: Does `half` (FP16) give you double the busbw vs `float` (FP32) since elements are smaller?

### Run:
```bash
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d float
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d half
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d bfloat16
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d int8
```

### What you should see:
- **All give the same busbw in GB/s.** Why? `-b` and `-e` are in **bytes**, not elements. 1 GB of float = 1 GB of half = 1 GB of int8. Same byte volume → same network time.
- The `count` column changes (256M elements for FP32, 512M for FP16, 1B for int8) but `size` is fixed at 1 GB.

### Lock-in: **busbw is in bytes/sec**. Changing `-d` changes element count, not bytes. Classic exam trap.

---

## Drill 8 — `-t` (threads per process)

**Predict**: With `-g 4 -t 1` vs `-g 2 -t 2`, do I use the same 4 GPUs? Same perf?

### Run:
```bash
# 1 process, 4 threads, each thread owns 1 GPU = 4 GPUs total
$NTEST/all_reduce_perf -b 1G -e 1G -g 1 -t 4 -n 50 -w 10

# 1 process, 1 thread, 4 GPUs in that thread = 4 GPUs total
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -t 1 -n 50 -w 10

# 1 process, 2 threads, 2 GPUs per thread = 4 GPUs total
$NTEST/all_reduce_perf -b 1G -e 1G -g 2 -t 2 -n 50 -w 10
```

### What you should see:
- All three engage 4 GPUs total (`-g × -t = total`).
- busbw similar across all three (same hardware path).
- The 3 cases differ in **how NCCL communicators are constructed**: with `-t > 1`, multiple threads each manage their own set of GPUs. Real ML workloads typically use **multi-process (MPI), 1 GPU per rank**, so `-g 1 -t 1` with `mpirun -np 4`.

### Lock-in: `-g × -t = total GPUs engaged`. You'll almost always use `-t 1` and either bump `-g` or use MPI processes.

---

## Drill 9 — `-z` (blocking sync) — the niche flag

**Predict**: Will `-z 1` (blocking) vs `-z 0` (busy-wait/spin) change BW or just CPU usage?

### Run:
```bash
# Default (busy-wait)
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -z 0

# Blocking sync — releases CPU between events
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -z 1
```

In a separate terminal during each: `top -p $(pgrep all_reduce)` and watch %CPU.

### What you should see:
- **`-z 0`** (default): high CPU% per process (busy-spinning waiting for completion).
- **`-z 1`**: lower CPU%, slightly higher latency (kernel wakeup overhead). At 1 GB messages, busbw difference is tiny. At small msgs, `-z 1` adds latency.

### Lock-in: `-z 1` saves CPU at the cost of latency. **Almost never changed** in practice.

---

## Drill 10 — `-p` (parallel init)

```bash
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -p 0
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -p 1
```

`-p 1` parallelizes the NCCL communicator initialization. Makes startup slightly faster on big jobs. **Does not change steady-state BW**. Single drill, single observation: **same busbw, marginally faster init**.

---

## Drill 11 — Combine flags: realistic burn-in command

Now build the command yourself. Goal: **30-second burn-in stress on all 4 GPUs, 1 GB messages, validating correctness, lots of iterations, plenty of warmup**.

Write your answer here: __________________________

<details>
<summary>Solution</summary>

```bash
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 4 -n 1000 -w 20 -c 1 -o sum -d float
```

Why: fixed 1G size (no sweep), all 4 GPUs, 1000 iterations (long), warmup 20, check correctness (catches SDC), default sum/float.
</details>

---

## Drill 12 — Build the "peak BW measurement" command

Goal: **measure peak busbw with no validation overhead, sweep all sizes, factor 2, 50 iterations, 10 warmup**.

Write your answer: __________________________

<details>
<summary>Solution</summary>

```bash
$NTEST/all_reduce_perf -b 8 -e 8G -f 2 -g 4 -n 50 -w 10 -c 0
```

Why: full sweep so you see latency-to-BW curve, `-c 0` for raw perf, all 4 GPUs.
</details>

---

## Drill 13 — Cross-collective: same flags, different busbw factor

The flags are identical across `all_reduce_perf`, `all_gather_perf`, `broadcast_perf`, etc. But the busbw factor changes!

### Run all 4:
```bash
$NTEST/all_reduce_perf      -b 1G -e 1G -g 4 -n 30 -w 5
$NTEST/all_gather_perf      -b 1G -e 1G -g 4 -n 30 -w 5
$NTEST/reduce_scatter_perf  -b 1G -e 1G -g 4 -n 30 -w 5
$NTEST/broadcast_perf       -b 1G -e 1G -g 4 -n 30 -w 5
```

### Fill in:
| collective | algbw | busbw | bw factor |
|------------|-------|-------|-----------|
| all_reduce |       |       | 2(n-1)/n = **1.5** for n=4 |
| all_gather |       |       | (n-1)/n = **0.75** for n=4 |
| reduce_scatter |   |       | (n-1)/n = **0.75** for n=4 |
| broadcast  |       |       | × 1 |

### What you should see:
- **algbw varies** between collectives because each does different amounts of work.
- **busbw should be similar** for all 4 — it's normalized to per-link.
- For all_reduce on 4 GPUs: busbw = algbw × 1.5.
- For all_gather/reduce_scatter: busbw = algbw × 0.75.
- For broadcast: busbw = algbw.

### Lock-in: **busbw is the link-level rate**, regardless of collective. The factor compensates.

---

## Rapid-fire memory quiz (cover the answers!)

Test yourself. Goal: under 5 seconds per question, no notes.

1. What does `-b` mean? `___________________` *(begin / min message size)*
2. What does `-e` mean? `___________________` *(end / max message size)*
3. What does `-f` mean? `___________________` *(factor between sizes)*
4. What does `-g` mean? `___________________` *(GPUs per process)*
5. What does `-t` mean? `___________________` *(threads per process)*
6. What does `-n` mean? `___________________` *(iterations)*
7. What does `-w` mean? `___________________` *(warmup iterations)*
8. What does `-c` mean? `___________________` *(check correctness 0/1)*
9. What does `-o` mean? `___________________` *(reduction op)*
10. What does `-d` mean? `___________________` *(data type)*
11. What does `-z` mean? `___________________` *(blocking sync)*
12. What does `-p` mean? `___________________` *(parallel init)*

Now harder:
13. Burn-in command for 4 GPUs, 1 GB, 1000 iter? `_____________`
14. Default value of `-c`? `___` *(0 — raw perf is default)*
15. Total GPUs used = `___ × ___` *(g × t)*
16. Which flag does NOT affect BW: `-d`? `-o`? `-c`? `-g`? `_____________` *(`-d` and `-o` don't; `-c` does add overhead; `-g` definitely does)*
17. busbw factor for all_reduce on 8 GPUs? `_____` *(2(8-1)/8 = 1.75)*
18. busbw factor for all_gather on 8 GPUs? `_____` *((8-1)/8 = 0.875)*
19. To eliminate first-iteration overhead, use which flag? `___` *(-w)*
20. Where is the latency-to-bandwidth knee in the size curve? `_____` *(~64 KB to 1 MB)*

If you get 18+/20 without notes, you own this section.

---

## Final synthesis exercise

Without running anything, predict what these commands do:

```bash
# A
$NTEST/all_reduce_perf -b 1M -e 1M -g 4 -n 100 -w 20 -c 1 -d half

# B
$NTEST/broadcast_perf -b 8 -e 1G -f 4 -g 4 -n 20 -w 5

# C
$NTEST/all_gather_perf -b 1G -e 1G -g 2 -t 2 -n 50 -w 10 -c 0
```

<details>
<summary>Answers</summary>

- **A**: All-reduce, fixed 1 MB size, 4 GPUs, 100 iter, validate correctness, FP16. Outputs sum-reduced FP16 buffers; checks for SDC; useful for medium-msg burn-in. busbw should be ~75-85% of NVLink peak.

- **B**: Broadcast, 8 B → 1 GB sweep with factor 4 (so ~16 size points), 4 GPUs, default everything else. Tests broadcast latency-to-BW curve. busbw factor = 1, so busbw == algbw.

- **C**: All-gather, fixed 1 GB, **using all 4 GPUs** (g×t=4), in a 2-thread × 2-GPU layout, no validation. Tests all-gather peak BW with multi-thread comm setup. busbw factor for n=4 = 0.75.

</details>

---

**The mental model to hold**: each flag is a knob on **one of three axes**:
- **Workload shape**: `-b`, `-e`, `-f` (size sweep), `-g`, `-t` (parallelism)
- **Measurement quality**: `-n`, `-w`, `-c`, `-z`
- **Workload content**: `-o`, `-d`, `-p`

When the exam gives you a scenario, classify the flag mentioned into one of these three buckets first.
