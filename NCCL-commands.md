# NCCL Test Flags — Hands-On 

**Setup**: 4 GPUs. Run inside the NCCL-tests compiled binaries from `nccl-tests/build/`.

---

## Setup

```
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

### Run:
```bash
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 1 -n 50 -w 10
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 2 -n 50 -w 10
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 4 -n 50 -w 10
```
<img width="785" height="784" alt="Screenshot 2026-05-09 at 8 28 03 PM" src="https://github.com/user-attachments/assets/5bcf5fa3-78f3-47ab-ba20-f388208534e0" />

The takeaway: time grows with -g (more GPUs = more comm steps), algbw drops (more redundant data per reduce), but busbw stays flat at ~24 GB/s because the per-link rate of the underlying hardware doesn't change. busbw is the number to compare across configurations.

<img width="589" height="172" alt="Screenshot 2026-05-10 at 9 06 15 AM" src="https://github.com/user-attachments/assets/7d7b09e3-21d3-47dc-875e-337915da0a89" />

Lock-in: `-g` controls **how many GPUs participate**. busbw factor depends on it.

---

## Drill 2 — `-b` and `-e` (size range) — the BW/latency curve

**Predict**: Where on the size axis does busbw transition from latency-bound (low) to bandwidth-bound (plateau)?

### Run:
```bash
# Full sweep, 8 B → 1 GB, powers of 2
$NTEST/all_reduce_perf -b 8 -e 1G -f 2 -g 4 -n 20 -w 5
```

<img width="785" height="634" alt="Screenshot 2026-05-09 at 8 30 16 PM" src="https://github.com/user-attachments/assets/35d38394-949f-4680-a34d-338977e31945" />

### What to extract:
Look at the table output. to Find:
- The smallest size (8 B) → record `time` and `busbw`.
- 1 KB → time, busbw
- 64 KB → time, busbw
- 1 MB → time, busbw
- 16 MB → time, busbw
- 1 GB → time, busbw

<img width="569" height="353" alt="Screenshot 2026-05-10 at 9 08 25 AM" src="https://github.com/user-attachments/assets/44a41e3a-7781-470e-a904-9d8ec0d2b46c" />

### Three regions
1) Latency-bound (8 B to ~32 KB): time stays ~25–50 μs no matter the size. Fixed overheads — kernel launch, ring setup, sync — dominate. busbw is tiny because you're transferring almost no bytes per unit time.
   
2)  Knee (~64 KB to ~4 MB): time starts scaling with size; busbw climbs from 4 → 22 GB/s. There's a small dip at 256 KB where NCCL switches its internal algorithm — totally normal.
  
3) Bandwidth-bound (~4 MB and up): time scales linearly with size, busbw plateaus at ~24 GB/s.

The takeaway: small-message workloads are latency-limited; large-message workloads are bandwidth-limited. The crossover is the knee. For training workloads with large gradient buffers, you operate firmly in the plateau region — which is why ML BW reports always cite peak busbw.

Lock-in: `-b` = min size, `-e` = max size. Small msg → latency. Large msg → bandwidth. Knee at ~MB scale.

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

<img width="785" height="284" alt="Screenshot 2026-05-09 at 8 30 51 PM" src="https://github.com/user-attachments/assets/a026b860-cd17-437c-9837-0fa7951dc9f8" />

<img width="785" height="284" alt="Screenshot 2026-05-09 at 8 31 26 PM" src="https://github.com/user-attachments/assets/a57fc784-49e9-409a-9c37-61f79796e4f8" />

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 32 24 PM" src="https://github.com/user-attachments/assets/7d8d0f36-a4a1-4809-a88f-1a80beccfa58" />


### Fill in:
| -n | -w | time (us) | busbw (GB/s) |
|----|----|-----------|--------------|
| 5  | 0  |           |   23.86      |
| 50 | 10 |           |   24.29      |
| 200| 20 |           |   24.04      |

-n is the number of timed iterations averaged, -w is the number of throwaway warmup iterations before timing starts. The drill predicted -w 0 would show 5–15% lower busbw because NCCL does init work on the first iteration. Yours only dropped ~2%. Why? Even with -w 0, you ran 5 iterations — 4 of them clean. The warmup cost gets diluted across the 5-iteration average. With -n 1 -w 0 you'd see the effect clearly.

The takeaway: always use -w ≥ 5, and pick -n based on how stable you need the average. -n 50 with -w 10 is the sweet spot for normal benchmarking. -n 1000 for soak/burn-in.

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

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 33 07 PM" src="https://github.com/user-attachments/assets/f1c5756e-1ed1-49d7-a752-07a0b24e559b" />

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 33 45 PM" src="https://github.com/user-attachments/assets/11bc35bf-0407-4bfa-8ce9-69b1d3f4c903" />


| -c | busbw (GB/s) |
|  0 | 24.13
|  1 | 24.22

-c 0 skips the validation step; -c 1 runs it and counts mismatches. The drill predicted 5–15% overhead from validation. Yours showed essentially zero. Why? Validation runs once at the end of all 50 iterations, not per iteration. At 1 GB and -n 50, the network time (3.3 seconds total) completely swallows the validation copy (microseconds). With smaller messages or fewer iterations, you'd see the overhead.

The takeaway: -c 0 for clean peak BW measurement, -c 1 for burn-in or anytime you want to catch silent data corruption. The 0 in the #wrong column is your hardware health signal — if it's ever non-zero, your GPUs or interconnect are flaky.
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

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 34 45 PM" src="https://github.com/user-attachments/assets/07858f24-64c9-4639-aed3-41f4df0d37b5" />

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 35 13 PM" src="https://github.com/user-attachments/assets/28829f91-a64d-4f6d-8cb4-e65645c387cd" />

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 35 51 PM" src="https://github.com/user-attachments/assets/a6436bfa-24ba-4098-8214-24a557ab9cb5" />

<img width="865" height="288" alt="Screenshot 2026-05-09 at 8 36 21 PM" src="https://github.com/user-attachments/assets/fbc90c32-f504-4229-bb25-5b7220d03590" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 38 53 PM" src="https://github.com/user-attachments/assets/9f1a115f-fe10-41e9-91d3-555f9670385b" />

### Fill in:
| -o   | busbw (GB/s) |
|------|--------------|
| sum  |    24.23     |
| min  |    24.51     |
| max  |    24.65     |
| prod |    24.23     |
| avg  |    24.46     |

All within ~2% of each other — basically noise. The reduction operation runs in a fused GPU kernel alongside the network transfer, and modern GPUs do min/max/sum/prod at speeds that are completely overshadowed by network time. The drill predicted avg would be slightly lower because of the post-divide; in your data it's actually mid-pack, so even that small effect is below the run-to-run variance.

The takeaway: changing -o does not move the BW needle. 

---

## Drill 7 — `-d` (data type) — bytes are bytes

**Predict**: Does `half` (FP16) give double the busbw vs `float` (FP32) since elements are smaller?

### Run:
```bash
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d float

$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d half

$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d bfloat16

$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -d int8

```
<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 39 11 PM" src="https://github.com/user-attachments/assets/ea40e851-cec4-442a-b51c-5b11b204b17b" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 39 50 PM" src="https://github.com/user-attachments/assets/f53bc0d4-5273-4bc0-a2cd-5cf0f77b06ba" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 40 31 PM" src="https://github.com/user-attachments/assets/9fb704ac-e833-4f96-8e58-f259c1f51c8a" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 41 08 PM" src="https://github.com/user-attachments/assets/f0a42e62-5f22-4f28-adf8-f2117a5953f9" />

### Fill in:
|       -d     | element count | busbw (GB/s) |
|--------------|---------------|--------------|
| float(FP32)  |   268M        |   24.06      |
| half(FP16)   |   537M        |   24.12      |
| bfloat16     |   537M        |   24.14      |
| int8         |   1074M       |   23.75      |


This one is brilliantly counter-intuitive. All four are essentially identical — and that's the whole point. -b and -e are in bytes, not elements. 1 GB of FP32 contains 256M elements; 1 GB of int8 contains 1B elements. Same byte volume → same network time → same busbw.
The count column shifts to keep the byte size constant (look at it in your output: 268M / 537M / 1B). The wire only sees bytes; it doesn't care what those bytes mean.

The takeaway: busbw is bytes/second. Changing -d changes element count, not byte count. If someone tells you "switching to FP16 doubled my comms throughput," they almost certainly halved their message volume, not their wire speed.

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

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 42 46 PM" src="https://github.com/user-attachments/assets/501f383c-a696-4900-82c8-5cc30e7d9296" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 43 19 PM" src="https://github.com/user-attachments/assets/b9f737d3-490b-4497-b32b-967eed08730d" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 43 53 PM" src="https://github.com/user-attachments/assets/2444d507-fb4d-487c-a450-2f16276e1cb1" />


### Fill in:
| -g | -t | totalGPUs | busbw (GB/s) |
|----|----|-----------|--------------|
| 1  | 4  |   4       |   23.86      |
| 2  | 1  |   4       |   24.29      |
| 4  | 2  |   4       |   24.04      |

-g is GPUs-per-thread, -t is threads-per-process. Total GPUs engaged = g × t. All three configurations engage the same 4 GPUs and produce the same busbw. They differ only in how NCCL's internal communicators are constructed — with -t > 1, multiple host threads each manage their own subset of GPUs.

In real distributed training, you almost always run multi-process with one GPU per process (via MPI or torchrun), which is -g 1 -t 1 on each rank. The -t > 1 mode is more of a debugging/exploration knob.

The takeaway: g × t = total GPUs. Most of the time use -t 1.

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
<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 44 33 PM" src="https://github.com/user-attachments/assets/5ce129a9-7fce-4d7f-9669-20afa20d3b00" />

<img width="865" height="289" alt="Screenshot 2026-05-09 at 8 45 00 PM" src="https://github.com/user-attachments/assets/01946e20-4a73-4340-857f-81c65ca6171f" />

### Fill in:
|       -z     | busbw         | mode                  |
|--------------|---------------|-----------------------|
|     0        |   24.48       |   busy-wait(default)  |
|     1        |   24.33       |   blocking            |

Notice the Blocking Enabled: wait for completion and barrier after each collective line in your -z 1 output — that's the flag taking effect. With -z 0 (default), the CPU spins waiting for GPU completion (high CPU%, low latency). With -z 1, the CPU sleeps and gets woken by the kernel (lower CPU%, slightly higher latency). At 1 GB messages, the latency difference vanishes into the network time, so busbw is basically unchanged.
You didn't run top in a second terminal to compare CPU usage, but if you had, you'd have seen -z 0 pinning a core at 100% while -z 1 stayed near idle.

The takeaway: -z 1 saves CPU at small latency cost. Almost never the bottleneck — leave it at default.

---

## Drill 10 — `-p` (parallel init)

```bash
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -p 0
$NTEST/all_reduce_perf -b 1G -e 1G -g 4 -n 50 -w 10 -p 1
```

<img width="865" height="289" alt="Screenshot 2026-05-09 at 8 45 32 PM" src="https://github.com/user-attachments/assets/6da069db-1766-489d-abe0-787f11953776" />

<img width="865" height="289" alt="Screenshot 2026-05-09 at 8 45 57 PM" src="https://github.com/user-attachments/assets/38e727a7-3b4d-4f35-beee-23f7408484eb" />

### Fill in:
| -p   | busbw (GB/s) |
|------|--------------|
| 0    |    24.09     |
| 1    |    24.23     |

-p 1 parallelizes the call to ncclCommInitRank, which makes the initial communicator setup faster on big jobs. It does not affect steady-state collective performance — your numbers confirm it (both ~24 GB/s within noise). On a 4-GPU pod the init delta is unmeasurable; on a 1000-GPU job it can shave seconds off startup.

The takeaway: -p is a startup-time optimization, not a runtime one.

---

## Drill 11 — Combine flags: realistic burn-in command

Now build the command yourself. Goal: **30-second burn-in stress on all 4 GPUs, 1 GB messages, validating correctness, lots of iterations, plenty of warmup**.

<details>
<summary>Solution</summary>

```bash
$NTEST/all_reduce_perf -b 1G -e 1G -f 2 -g 4 -n 1000 -w 20 -c 1 -o sum -d float
```

<img width="865" height="289" alt="Screenshot 2026-05-09 at 8 49 47 PM" src="https://github.com/user-attachments/assets/c5c8847d-cb92-4a2e-8105-7680be28f9f3" />

### Fill in:
| size   | busbw (GB/s) |
|--------|--------------|
|  1GB   |    23.97     |
|  2GB   |    24.26     |
|  4GB   |    24.22     |
|  8GB   |    24.43     |

This is the long-running stress test: 1000 iterations × 67 ms ≈ 67 seconds of continuous all-reduce on 1 GB buffers, with validation enabled. Your result: busbw 24.00, #wrong = 0. That tells you two things: (1) sustained throughput matches single-shot throughput, no thermal or memory-pressure regression; (2) zero silent data corruption events across ~67 GB of validated transfers. Hardware healthy.

---

## Drill 12 — Build the "peak BW measurement" command

Goal: **measure peak busbw with no validation overhead, sweep all sizes, factor 2, 50 iterations, 10 warmup**.

<details>
<summary>Solution</summary>

```bash
$NTEST/all_reduce_perf -b 8 -e 8G -f 2 -g 4 -n 50 -w 10 -c 0
```
<img width="865" height="662" alt="Screenshot 2026-05-09 at 8 51 41 PM" src="https://github.com/user-attachments/assets/f083f2fa-8882-4ac6-a72e-dc73af91fddb" />

The plateau is real and you're not going to extract more BW by going bigger. ~24 GB/s is the ceiling of your hardware path. Useful confirmation: many people stop at 1 GB and wonder if they're missing peak — you've shown you're not.
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

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 52 13 PM" src="https://github.com/user-attachments/assets/373850ac-3cf0-4761-9333-7bfcf177e4a1" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 52 39 PM" src="https://github.com/user-attachments/assets/10e50dbd-ea9a-42e4-ba49-ba2a5d840fff" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 52 57 PM" src="https://github.com/user-attachments/assets/1a85d13a-f8e8-4ddb-a0ab-5a75360ffe85" />

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 53 18 PM" src="https://github.com/user-attachments/assets/acc65d5c-7316-4cd6-b47e-5b767b11452b" />


### What you should see:
- **algbw varies** between collectives because each does different amounts of work.
- **busbw should be similar** for all 4 — it's normalized to per-link.
- For all_reduce on 4 GPUs: busbw = algbw × 1.5.
- For all_gather/reduce_scatter: busbw = algbw × 0.75.
- For broadcast: busbw = algbw.

Every factor checks out to within decimal precision. The reason algbw varies wildly (16, 30, 30, 27) but busbw clusters at 23–27 is that algbw measures "how fast does the user-visible operation complete," while busbw measures "how saturated is each physical link." Different collectives push different amounts of data through the ring per byte of user output. The factor compensates.
Broadcast is slightly higher (26.7) than the others (~24) because it has fewer hops per element — it doesn't have to do both a scatter and a gather phase like all_reduce conceptually does.

Lock-in: **busbw is the link-level rate**, regardless of collective. The factor compensates.

---

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

<img width="865" height="281" alt="Screenshot 2026-05-09 at 8 53 44 PM" src="https://github.com/user-attachments/assets/5ab9b226-b6f7-495d-aecb-740f969f5e71" />

<img width="865" height="440" alt="Screenshot 2026-05-09 at 8 54 05 PM" src="https://github.com/user-attachments/assets/7368a2e6-acfb-41a4-8a57-ec7c7574a05f" />

<img width="865" height="284" alt="Screenshot 2026-05-09 at 8 54 32 PM" src="https://github.com/user-attachments/assets/d1373e8c-0767-49f9-b539-f6393ef6d08e" />


A — -b 1M -e 1M -g 4 -n 100 -w 20 -c 1 -d half: 14.26 GB/s busbw. 1 MB sits right in the middle of the knee (look back at Drill 2: 1 MB gave 13.97 GB/s busbw). FP16 doesn't change byte volume so it doesn't change busbw. The 14.26 result is consistent with everything else.
B — broadcast -b 8 -e 1G -f 4 -g 4: At each size, output shows algbw == busbw (e.g., 1 GB row: 26.56 26.56). Confirms the broadcast factor of 1.0 across the entire size range.
C — all_gather -g 2 -t 2 -n 50 -w 10 -c 0: 22.84 GB/s busbw, algbw 30.45. Check: 30.45 × 0.75 = 22.84. ✓ Same as Drill 13's all_gather row, just running through the g × t = 4 route instead of g 4 t 1. Same hardware engaged → same number.

- **A**: All-reduce, fixed 1 MB size, 4 GPUs, 100 iter, validate correctness, FP16. Outputs sum-reduced FP16 buffers; checks for SDC; useful for medium-msg burn-in. busbw should be ~75-85% of NVLink peak.

- **B**: Broadcast, 8 B → 1 GB sweep with factor 4 (so ~16 size points), 4 GPUs, default everything else. Tests broadcast latency-to-BW curve. busbw factor = 1, so busbw == algbw.

- **C**: All-gather, fixed 1 GB, **using all 4 GPUs** (g×t=4), in a 2-thread × 2-GPU layout, no validation. Tests all-gather peak BW with multi-thread comm setup. busbw factor for n=4 = 0.75.


---

```
nvidia-smi topo -m
```

<img width="865" height="303" alt="Screenshot 2026-05-09 at 8 58 14 PM" src="https://github.com/user-attachments/assets/e5985d6c-6229-48ea-8fdb-ab40cdeb7c1e" />


**The mental model to hold**: each flag is a knob on **one of three axes**:
- **Workload shape**: `-b`, `-e`, `-f` (size sweep), `-g`, `-t` (parallelism)
- **Measurement quality**: `-n`, `-w`, `-c`, `-z`
- **Workload content**: `-o`, `-d`, `-p`
