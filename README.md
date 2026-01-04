# AI_Infra_Handbook

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLUSTER VALIDATION FLOW                      │
└─────────────────────────────────────────────────────────────────┘

Phase 1: SINGLE-NODE VALIDATION (Per Server)
├── 1 Single-Node Stress Test (DCGM)
├── 2 HPL Single-Node
└── 3 NCCL Single-Node (Verify NVLink)
         ↓ ALL NODES PASS?
         
Phase 2: INFRASTRUCTURE VALIDATION
├── 4 Cable Signal Quality Validation
├── 5 Verify Correct Cabling
├── 6 Switch Firmware/Software Validation
├── 7 BlueField DPU Firmware Validation
└── 8 Transceiver Firmware Validation
         ↓ ALL INFRASTRUCTURE PASS?
         
Phase 3: CLUSTER INTEGRATION
├── 9 ClusterKit Multi-Node Assessment
└── 10 NCCL East-West Fabric Bandwidth
         ↓ CLUSTER INTEGRATED?
         
Phase 4: BURN-IN & PRODUCTION READINESS
├── 11 NCCL Burn-In (Multi-node communication)
├── 12 HPL Burn-In (Compute stability)
├── 13 NeMo Burn-In (Real AI workload)
└── 14 Storage Validation
         ↓ ALL BURN-IN PASS?
         
✅ CLUSTER PRODUCTION READY
Yes! Let me map out where ALL the remaining steps belong in the validation framework:

---

## **Complete Step Classification**

| **Step** | **Title** | **Phase/Category** | **What It Tests** | **Primary Tools** |
|----------|-----------|-------------------|-------------------|-------------------|
| **1** | Perform single-node stress test | **Phase 1: Single-Node GPU Validation** | GPU compute, memory, thermal, power on ONE node | DCGM diag, nvidia-smi, gpu-burn |
| **2** | Execute HPL (High-Performance Linpack) | **Phase 1: Single-Node GPU Validation** | FP64 compute performance, stability | HPL benchmark |
| **3** | Perform single-node NCCL (verify NVLink™ Switch) | **Phase 1: Single-Node GPU Validation** | Intra-node GPU-to-GPU interconnect (NVLink/NVSwitch) | NCCL tests (nccl-test suite) |
| **4** | Validate cables by verifying signal quality | **Phase 2: Infrastructure Validation** | InfiniBand/Ethernet cable BER, errors, link health | mlxlink, UFM Cable Validation, ibcheckerrors |
| **5** | Confirm cabling is correct | **Phase 2: Infrastructure Validation** | Topology correctness (port-to-port mapping) | ibnetdiscover, iblinkinfo, UFM topology compare |
| **6** | Confirm FW/SW on switches | **Phase 2: Infrastructure Validation** | Switch firmware/software version compliance | Switch CLI (show version), UFM inventory |
| **7** | Confirm FW/SW on BlueField 3 | **Phase 2: Infrastructure Validation** | DPU firmware/software version compliance | flint, mlxfwmanager, mst status |
| **8** | Confirm FW on transceivers | **Phase 2: Infrastructure Validation** | Optical/cable module firmware compliance | mlxcables, mlxlink -m |
| **9** | Run ClusterKit multifaceted node assessment | **Phase 1: Single-Node GPU Validation** (extended) | Comprehensive single-node health check | ClusterKit tool |
| **10** | Run NCCL to verify E/W fabric bandwidth | **Phase 3: Multi-Node Validation** | East-West inter-node bandwidth (fabric performance) | NCCL tests across nodes, perftest |
| **11** | Perform NCCL burn-in | **Phase 3: Multi-Node Validation** | Multi-node interconnect stability under sustained load | NCCL tests (long-duration) |
| **12** | Perform HPL burn-in | **Phase 3: Multi-Node Validation** | Multi-node compute stability and performance | HPL (multi-node configuration) |
| **13** | Perform Nemo burn-in | **Phase 4: Application Validation** | Real-world AI workload stability (LLM training) | NVIDIA NeMo framework |
| **14** | Test storage | **Phase 2/4: Infrastructure + Application** | Storage I/O performance and reliability | fio, dd, mdadm, NFS tests |

---

## **Detailed Breakdown by Phase**

### **PHASE 1: Single-Node GPU Validation (Steps 1-3, 9)**

These validate **individual nodes in isolation** before connecting them to the fabric.

| **Step** | **What It Validates** | **Tools** | **Duration** | **Pass Criteria** |
|----------|----------------------|-----------|--------------|-------------------|
| **1** | GPU health: compute, memory, thermal, power | DCGM diag (`dcgmi diag -r 3`), gpu-burn | 15-60 min | No GPU errors, temps <85°C, no throttling |
| **2** | FP64 compute performance | HPL (single-node) | 30-60 min | Achieves 80-95% of theoretical TFLOPS |
| **3** | Intra-node GPU interconnect (NVLink/NVSwitch) | NCCL tests (all-reduce within node) | 5-15 min | Near-peak NVLink BW, no hangs |
| **9** | Comprehensive node health | ClusterKit (NVIDIA tool) | 20-40 min | All subsystems pass (GPU, CPU, mem, storage, BMC) |

**Why these come first:**
- No point testing fabric if individual GPUs are broken
- Eliminates "bad node" variables before multi-node testing
- Faster to debug single-node issues in isolation

---

### **PHASE 2: Infrastructure Validation (Steps 4-8, partial 14)**

These validate **network fabric and infrastructure** connecting nodes.

| **Step** | **What It Validates** | **Already Covered Above** |
|----------|----------------------|---------------------------|
| **4** | Cable signal quality (BER, errors) | ✅ Yes |
| **5** | Topology correctness | ✅ Yes |
| **6** | Switch firmware versions | ✅ Yes |
| **7** | BlueField DPU firmware | ✅ Yes |
| **8** | Transceiver firmware | ✅ Yes |
| **14** (partial) | Storage infrastructure (RAID health, NFS mounts) | New - see below |

---

### **PHASE 3: Multi-Node Validation (Steps 10-12)**

These validate **inter-node communication and scaling** across the cluster.

| **Step** | **What It Validates** | **Tools** | **Duration** | **Pass Criteria** |
|----------|----------------------|-----------|--------------|-------------------|
| **10** | East-West fabric bandwidth | NCCL all-reduce across nodes, perftest (ib_write_bw) | 10-30 min | Achieves expected inter-node BW based on topology |
| **11** | Multi-node interconnect stability | NCCL tests (long-duration, hours) | 2-24 hours | No hangs, consistent performance, no errors |
| **12** | Multi-node compute stability | HPL (full cluster or large subset) | 2-24 hours | Consistent TFLOPS, no node drops, stable temps |

**Key distinction from Phase 1:**
- **2 (HPL single-node)**: Tests ONE node's GPUs
- **12 (HPL burn-in)**: Tests MANY nodes working together over network

- **3 (NCCL single-node)**: Tests GPUs within ONE node (NVLink)
- **10/4.11 (NCCL multi-node)**: Tests GPUs across MULTIPLE nodes (InfiniBand/Ethernet fabric)

---

### **PHASE 4: Application Validation (Steps 13, partial 14)**

These validate **real-world workloads** on the cluster.

| **Step** | **What It Validates** | **Tools** | **Duration** | **Pass Criteria** |
|----------|----------------------|-----------|--------------|-------------------|
| **13** | AI training workload stability | NVIDIA NeMo (LLM training) | 4-72 hours | Training progresses, no OOMs, loss decreases, no node failures |
| **14** (partial) | Storage I/O for training data | fio, dd, dataset loading benchmarks | 1-4 hours | Achieves required GB/s per GPU, no I/O bottlenecks |

**Why NeMo matters:**
- Tests the **full stack** (GPUs + interconnect + storage + software)
- Validates you can actually run production workloads
- Often reveals issues that synthetic benchmarks miss (e.g., memory leaks, data pipeline bottlenecks)

---

## **Step 9 (ClusterKit) - Details**

**What is ClusterKit?**
- NVIDIA's comprehensive node health assessment tool
- Runs a battery of tests across all subsystems
- More thorough than DCGM diag alone

**What ClusterKit tests:**

| **Component** | **Tests Performed** |
|---------------|-------------------|
| **GPUs** | Compute, memory, ECC, thermal, power, clocks |
| **NVLink/NVSwitch** | Intra-node bandwidth, topology verification |
| **CPUs** | Burn-in, memory bandwidth, instruction sets |
| **System Memory** | memtest-style validation |
| **Storage** | RAID health, disk SMART status, basic I/O |
| **BMC/IPMI** | Firmware versions, sensor readings |
| **Network** | Basic connectivity checks |

**When to use it:**
- Initial node acceptance testing
- After hardware replacement
- Periodic health checks

**Typical command:**
```bash
clusterkit -a  # Run all tests
```

---

## **Step 10 vs 11 - NCCL Tests Explained**

### **10: Verify E/W Fabric Bandwidth (Quick Test)**

**Purpose:** Confirm fabric can deliver expected bandwidth  
**Duration:** 10-30 minutes  
**What it does:**
- Runs NCCL all-reduce across multiple nodes
- Measures bus bandwidth and algorithm bandwidth
- Quick pass/fail on fabric performance

**Example command:**
```bash
# Run NCCL all-reduce test across 8 nodes, 8 GPUs each
mpirun -np 64 -H node1:8,node2:8,...,node8:8 \
  /usr/local/nccl-tests/build/all_reduce_perf -b 8 -e 8G -f 2 -g 1
```

**Expected output (example for 400G InfiniBand):**
```
#      size     time   algbw   busbw
#   (bytes)    (us)   (GB/s)  (GB/s)
  134217728   2245.6   59.77   112.07  ← Should be near-peak
```

### **11: NCCL Burn-In (Stress Test)**

**Purpose:** Prove fabric stability under sustained load  
**Duration:** 2-24 hours  
**What it does:**
- Same NCCL tests, but run continuously
- Monitors for hangs, timeouts, performance degradation
- Thermal stress on switches/cables

**Example command:**
```bash
# Run for 12 hours
for i in {1..720}; do
  mpirun -np 64 ... /usr/local/nccl-tests/build/all_reduce_perf ...
  sleep 60  # 1 minute between runs
done
```

**What you're watching for:**
- Consistent performance across iterations
- No NCCL timeouts or hangs
- No thermal throttling on switches
- No CRC/error counter increases

---

## **Step 14 (Test Storage) - Complete Picture**

Storage testing happens in **two phases**:

### **Phase 2 (Infrastructure): Storage Infrastructure**

**What:** Validate storage subsystem is healthy  
**Tests:**
- RAID array health: `mdadm --detail /dev/md0`
- Disk SMART status: `smartctl -a /dev/nvme0n1`
- NFS mount validation: `mount | grep nfs`
- Basic I/O: `dd if=/dev/zero of=/raid/testfile bs=1M count=10000`

**Pass criteria:**
- RAID array state: clean, all disks active
- No SMART errors on drives
- NFS mounts accessible
- Basic I/O works without errors

### **Phase 4 (Application): Storage Performance**

**What:** Validate storage can feed GPUs fast enough  
**Tests:**
- Sequential read bandwidth: `fio --name=seqread --rw=read --bs=4M ...`
- Random read IOPS: `fio --name=randread --rw=randread --bs=4k ...`
- Dataset loading time: Time actual training data loading
- Multi-threaded access: Concurrent reads from multiple processes

**Pass criteria (example):**
- Sequential read: >3 GB/s per node (for 1080p images)
- Random read: >100k IOPS (for small file access)
- Dataset loads in acceptable time for workflow
- No I/O wait spikes during training

---

## **Complete Workflow Diagram**

```
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 1: Single-Node GPU Validation                             │
│ (Validate each node independently)                              │
└─────────────────────────────────────────────────────────────────┘
    ├─ 1: Single-node stress test (DCGM diag)
    ├─ 2: HPL single-node (FP64 compute)
    ├─ 3: Single-node NCCL (NVLink/NVSwitch intra-node)
    └─ 9: ClusterKit (comprehensive node health)
              ↓
              ↓ ALL nodes pass Phase 1
              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 2: Infrastructure Validation                              │
│ (Validate network fabric + infrastructure)                      │
└─────────────────────────────────────────────────────────────────┘
    ├─ 4: Validate cable signal quality (BER, errors)
    ├─ 5: Confirm topology correctness (port mapping)
    ├─ 6: Confirm switch firmware versions
    ├─ 7: Confirm BlueField DPU firmware
    ├─ 8: Confirm transceiver firmware
    └─ 14 (part 1): Test storage infrastructure (RAID, NFS)
              ↓
              ↓ Infrastructure healthy
              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 3: Multi-Node Validation                                  │
│ (Validate inter-node communication + scaling)                   │
└─────────────────────────────────────────────────────────────────┘
    ├─ 10: NCCL E/W fabric bandwidth (quick test)
    ├─ 11: NCCL burn-in (long-duration stability)
    └─ 12: HPL burn-in (multi-node compute stability)
              ↓
              ↓ Multi-node tests pass
              ↓
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 4: Application Validation                                 │
│ (Validate real-world workloads)                                 │
└─────────────────────────────────────────────────────────────────┘
    ├─ 13: NeMo burn-in (real AI training workload)
    └─ 14 (part 2): Test storage performance (I/O for training)
              ↓
              ↓ SUCCESS
              ↓
         ✅ Cluster ready for production
```

---

## **Quick Reference: Tool-to-Step Mapping**

| **Tool/Command** | **Used in Steps** | **Purpose** |
|------------------|-------------------|-------------|
| **DCGM diag** | 1 | GPU stress testing |
| **HPL** | 2 (single), 12 (multi) | FP64 compute benchmark |
| **NCCL tests** | 3 (single), 4.10, 4.11 (multi) | GPU communication |
| **ClusterKit** | 9 | Comprehensive node health |
| **mlxlink** | 4 | Cable signal quality |
| **ibnetdiscover** | 5 | Topology discovery |
| **show version** | 6 | Switch firmware check |
| **flint** | 7 | BlueField firmware check |
| **mlxcables** | 8 | Transceiver firmware |
| **perftest** | 10 | RDMA bandwidth (complement to NCCL) |
| **NeMo** | 13 | AI training workload |
| **fio / mdadm** | 14 | Storage validation |

---

**Summary:**

- **1-3, 9** → Phase 1 (Single-Node)
- **4-8** → Phase 2 (Infrastructure)  
- **10-12** → Phase 3 (Multi-Node)
- **13** → Phase 4 (Application)
- **14** → Phase 2 + Phase 4 (Infrastructure + Performance)
```

---

## PHASE 1: Single-Node Validation

### Goal: Validate each server independently before cluster integration

---

### 1 Single-Node Stress Test (DCGM Diagnostic)

What is a "Single Node"?
One physical server that contains:

1 or more GPUs (e.g., a DGX H100 has 8 GPUs in one server)
CPU(s)
Memory (RAM)
Storage
Network interfaces
Power supplies
Cooling systems

Examples of single nodes:

1x DGX H100 server (contains 8x H100 GPUs)
1x DGX A100 server (contains 8x A100 GPUs)
1x standard server with 4x L40S GPUs
1x workstation with 2x RTX GPUs
What's Being Tested:
1. Compute Stress:

Run intensive mathematical operations on all GPU cores
Engage Tensor Cores with matrix multiplications
Max out FP64, FP32, FP16, INT8 operations
Goal: Verify compute performance matches spec sheet

2. Memory Stress:

Fill GPU memory (HBM2e/HBM3) completely
Perform rapid read/write operations
Check for ECC (Error Correction Code) errors
Test memory bandwidth (TB/s)
Goal: Ensure memory is error-free and fast

3. Interconnect Stress:

Test NVLink bandwidth between all GPU pairs
Test NVSwitch (if present, like in DGX H100)
Test PCIe lanes to CPU
Goal: Verify all GPUs can communicate at full speed

4. Thermal Stress:

Run GPUs at maximum power draw
Monitor temperatures across all sensors
Verify cooling system keeps temps in safe range (typically <85°C)
Goal: Prevent thermal throttling during real workloads

5. Power Delivery Stress:

Draw maximum power from power supplies
Test power management/capping features
Verify voltage stability
Goal: Ensure power systems won't fail under load

**Purpose:** Comprehensive hardware validation of individual server

**Prerequisites:**
- Server physically installed and powered on
- BMC/OOB configured 
- OS installed 
- NVIDIA drivers installed
- DCGM installed

**Command Sequence:**

```bash
# 1. Verify GPU detection
dcgmi discovery -l

# Expected output: All GPUs detected (e.g., 8x H100)
# Note GPU IDs, PCI Bus IDs, UUIDs

# 2. Check initial GPU health
nvidia-smi

# Verify:
# - All GPUs listed
# - Driver version correct
# - No immediate errors

# 3. Start monitoring in separate terminal
nvidia-smi dmon -s pucvmet -d 1

# 4. Run comprehensive diagnostic (Level 3)
dcgmi diag -r 3

# Test duration: 15-25 minutes
# Tests performed:
#   - Software stack validation
#   - GPU memory integrity
#   - Compute performance (all precisions)
#   - NVLink bandwidth (intra-node)
#   - PCIe bandwidth
#   - Thermal performance
#   - Power delivery
```

**What's Being Tested:**

```
┌───────────────────────────────────┐
│     Single Server (DGX H100)      │
├───────────────────────────────────┤
│  GPU 0 ◄──NVLink──► GPU 1        │
│    ↕                   ↕           │
│  GPU 2 ◄──NVLink──► GPU 3        │
│    ↕                   ↕           │
│  GPU 4 ◄──NVLink──► GPU 5        │  ← NVLink mesh via NVSwitch
│    ↕                   ↕           │
│  GPU 6 ◄──NVLink──► GPU 7        │
│         ↓                          │
│    PCIe to CPU/System             │  ← PCIe Gen5 x16 per GPU
│                                    │
│  Power: 2x 3000W PSU              │  ← Power delivery test
│  Cooling: 8x high-flow fans       │  ← Thermal test
└───────────────────────────────────┘
```

```dcgmi diag -r 3
```

### **Timeline of Events:**

**Minute 0-1: Initialization**
```
[DCGM] Starting diagnostic level 3...
[DCGM] Detected 8 GPUs in node
[DCGM] GPU 0: NVIDIA H100 80GB HBM3
[DCGM] GPU 1: NVIDIA H100 80GB HBM3
...
[DCGM] Checking initial health...
```

**Minute 1-5: Memory Test**
```
[DCGM] Running memory test on all GPUs...
- Allocating 80GB on each GPU
- Writing patterns to memory
- Reading back and verifying
- Checking for ECC errors
[GPU 0] Memory bandwidth: 3.35 TB/s ✓ PASS
[GPU 1] Memory bandwidth: 3.34 TB/s ✓ PASS
[GPU 2] ECC error detected! ✗ FAIL
```

**Minute 5-15: Compute Stress**
```
[DCGM] Running compute stress test...
- All GPUs at 100% utilization
- Temperatures rising: 75°C → 82°C
- Power draw: 700W per GPU
- TFLOPS achieved vs expected
[GPU 0] FP64: 34 TFLOPS ✓ PASS
[GPU 0] FP16: 1979 TFLOPS ✓ PASS
```

**Minute 15-20: Interconnect Test**
```
[DCGM] Testing NVLink connectivity...
- GPU 0 ↔ GPU 1: 900 GB/s ✓ PASS
- GPU 0 ↔ GPU 2: 450 GB/s ✗ WARNING (expected 900 GB/s)
- Testing all GPU pairs...
```

**Minute 20-25: PCIe Test**
```
[DCGM] Testing PCIe bandwidth...
- GPU 0 → CPU: 63 GB/s (PCIe Gen5 x16) ✓ PASS
- GPU 1 → CPU: 31 GB/s ✗ WARNING (running at x8?)
```

**Final Result:**
```
========================================
DCGM Diagnostic Summary
========================================
Overall Status: FAIL
- 6/8 GPUs passed all tests
- GPU 2: Memory errors detected
- GPU 1: PCIe bandwidth degraded
- Thermal: All GPUs within limits
- Power: Stable

Recommendation: Replace GPU 2, check PCIe connection on GPU 1
========================================
```
## GPU Stress Testing Complete Reference Table

| **Test Category** | **What It Tests** | **How to Run It** | **What to Measure** | **Good Results Look Like** | **Bad Results Look Like** | **What Bad Results Mean** |
|-------------------|-------------------|-------------------|---------------------|---------------------------|---------------------------|---------------------------|
| **FP64 Compute** | Double-precision math capability (scientific/HPC workloads) | Run FP64 GEMM benchmarks or HPL (High Performance Linpack) continuously for hours | • TFLOPS achieved<br>• GPU clocks stability<br>• Temperature<br>• No errors in logs | • Achieves 80-95% of spec TFLOPS<br>• Clocks stay high and stable<br>• No crashes or driver resets | • TFLOPS far below spec<br>• Clocks dropping<br>• Xid errors in logs<br>• GPU hangs/crashes | • Thermal throttling<br>• Power limiting<br>• Marginal GPU silicon<br>• Driver/firmware issues |
| **FP32 Compute** | Single-precision CUDA cores (general compute) | Run FP32 GEMM or general compute burn-in tools | • TFLOPS achieved<br>• Clock stability<br>• Runtime consistency | • Stable high TFLOPS<br>• Consistent run times<br>• Temps under throttle point | • Performance degrades over time<br>• Crashes<br>• Thermal throttling kicks in | • Cooling insufficient<br>• Power delivery issues<br>• GPU degradation |
| **FP16/BF16 Tensor Cores** | Half-precision Tensor Core throughput (AI/ML training) | Run large matrix multiplications (GEMM) specifically using Tensor Core paths with FP16/BF16 inputs | • TFLOPS achieved<br>• Verify Tensor Cores engaged<br>• Sustained performance | • Achieves 100s of TFLOPS (vs ~10s for FP32)<br>• Performance stays constant<br>• No numerical errors | • TFLOPS similar to FP32 (Tensor Cores not engaged)<br>• Crashes during long runs<br>• Numerical instability | • Wrong kernel/library (not using Tensor Cores)<br>• Shape/layout issues<br>• Hardware fault in Tensor units |
| **INT8 Compute** | Integer math for quantized inference | Run INT8 GEMM / inference-style matmul on Tensor Cores | • TOPS (trillions of ops/sec)<br>• Accuracy of results<br>• Stability | • Very high TOPS<br>• Correct mathematical results<br>• No errors | • Low throughput<br>• Wrong results<br>• Crashes | • Not using Tensor Core INT8 path<br>• Hardware issues<br>• Precision/quantization bugs |
| **Memory Capacity Fill** | VRAM can hold data without corruption | Allocate buffers until ~95% VRAM full, write known patterns (zeros, ones, walking bits, random), read back and verify | • ECC Correctable Errors (CE)<br>• ECC Uncorrectable Errors (UE)<br>• Pattern match success rate | • Zero or very few CE per hour<br>• Zero UE<br>• 100% pattern verification pass | • CE count rapidly increasing<br>• Any UE errors<br>• Pattern mismatches<br>• App crashes | • Marginal HBM/GDDR chips<br>• Overheating memory<br>• Manufacturing defect<br>• Aging hardware |
| **Memory Bandwidth (Unidirectional)** | How fast VRAM can stream data in one direction | Run sustained memcpy/streaming read or write kernels continuously | • GB/s or TB/s throughput<br>• Compare to spec<br>• Stability over time | • Achieves 85-95% of rated bandwidth<br>• Stays consistent for hours<br>• Low latency variance | • BW well below spec<br>• BW degrades over time<br>• High latency spikes | • Memory throttling (thermal)<br>• Bad memory controller<br>• Power limiting<br>• Interference from other issues |
| **Memory Bandwidth (Bidirectional)** | Full-duplex memory capability under contention | Run simultaneous read AND write operations | • Total bidirectional BW<br>• Contention handling<br>• Error rates | • Sum of both directions near spec<br>• No errors<br>• Stable performance | • Can't sustain bidirectional<br>• Errors appear under bidirectional load<br>• Much worse than 2x unidirectional | • Internal bus contention<br>• Marginal signaling<br>• Buffer/flow control issues |
| **Memory Random Access** | Memory subsystem under worst-case access patterns | Run kernels with random address patterns hammering memory controllers | • Latency distribution<br>• Throughput under random access<br>• Error rates | • Reasonable throughput<br>• Predictable latency<br>• No ECC errors | • Very slow vs sequential<br>• Timeout errors<br>• ECC errors spike | • Bad memory controller paths<br>• TLB issues<br>• Specific address ranges faulty |
| **NVLink/NVSwitch Bandwidth** | GPU-to-GPU interconnect speed (if present) | Run P2P bandwidth tests between GPU pairs, NCCL all-reduce/all-to-all operations | • GB/s per link<br>• Total fabric BW<br>• CRC errors<br>• Replay counts | • Matches spec (900 GB/s per link for NVLink 4.0, etc.)<br>• Zero CRC/replay errors<br>• Topology correct | • BW below spec<br>• Rising CRC/replay errors<br>• Links dropping<br>• NCCL hangs | • Poor signal integrity<br>• Cable/connector issues<br>• NVSwitch overheating<br>• Firmware mismatches |
| **PCIe Bandwidth & Stability** | CPU-to-GPU and GPU-to-GPU over PCIe | Run PCIe bandwidth benchmarks, check link generation/width | • GB/s (Gen4x16 = ~32GB/s unidirectional)<br>• Link gen and width<br>• AER errors | • Achieves near-theoretical BW<br>• Runs at correct Gen/width<br>• Zero PCIe AER errors | • Downtraining (Gen5→Gen4, x16→x8)<br>• Low bandwidth<br>• AER errors in logs<br>• GPUs dropping offline | • Poor PCIe seating<br>• Bad riser cards<br>• BIOS settings wrong<br>• Motherboard issues |
| **NCCL Collectives** | Multi-GPU communication for distributed training | Run NCCL all-reduce, all-gather, reduce-scatter across all GPUs for extended periods | • Busbandwidth (GB/s)<br>• Algbandwidth (GB/s)<br>• No hangs<br>• Scaling efficiency | • Scales well with GPU count<br>• No timeouts<br>• Performance matches topology<br>• Completes without errors | • NCCL hangs<br>• Timeouts<br>• Poor scaling<br>• Inconsistent run times | • Interconnect issues<br>• Topology misconfiguration<br>• Network contention<br>• Driver/NCCL version mismatch |
| **Thermal Sustained Load** | Cooling system keeps GPUs below throttle point | Run max power workload (compute + memory + interconnect) for hours | • GPU temp<br>• Hotspot temp<br>• Memory temp<br>• Clock frequencies<br>• Throttle reasons | • Temps stay <85°C (or below your GPU's throttle point with headroom)<br>• Clocks stay at boost<br>• Fans <90% speed | • Temps at/above throttle point<br>• Clocks dropping<br>• Fans at 100%<br>• "Thermal" throttle reason in logs | • Insufficient airflow<br>• Blocked vents<br>• Fan failure<br>• High ambient temp<br>• Bad thermal paste/contact |
| **Power Draw Stability** | PSUs/PDUs/VRMs handle peak and transient loads | Pull near-max node power repeatedly, test power capping, monitor during load spikes | • Power draw (Watts)<br>• Rail voltages<br>• Throttle reasons<br>• Event logs | • Stable power delivery<br>• No power-limit throttling<br>• No brownouts/resets<br>• PSUs balanced (if redundant) | • Power-limit throttling<br>• Sudden node resets<br>• PSU alarms<br>• One PSU overloaded, other idle | • Weak/failing PSU<br>• Undersized PDU/circuit<br>• Loose power cables<br>• No redundancy configured<br>• VRM issues |
| **Power Redundancy** | A/B power paths work independently | Unplug one PSU while under load (if redundant PSUs present) | • System stays up<br>• No service interruption<br>• Load balances to remaining PSU | • Node continues running<br>• Automatic failover<br>• No impact to workload | • Node crashes when one PSU unplugged<br>• Alarm but degraded performance<br>• PSUs not load-balancing | • Redundancy not configured<br>• Single PSU failure point<br>• Wrong PSU mode (combined vs redundant) |
| **Software/Firmware Stability** | Driver/CUDA/NCCL/firmware stack compatible and stable | Run same tests after reboots, cold starts, across different workloads | • Reproducible results<br>• Clean logs<br>• Consistent performance | • Results identical across runs<br>• No version-related crashes<br>• No weird "works sometimes" issues | • Crashes only after reboot<br>• Performance varies wildly<br>• Version-dependent failures<br>• "Works cold, fails warm" | • Driver/CUDA/NCCL mismatch<br>• BIOS/firmware outdated<br>• Container config issues<br>• Kernel module problems |

---

**Key Terms Quick Reference:**

- **CE (Correctable ECC Error)**: Memory bit flip that was auto-fixed; monitor rate
- **UE (Uncorrectable ECC Error)**: Fatal memory error; usually crashes app
- **Xid Error**: NVIDIA GPU error code in system logs (means GPU fault)
- **Throttling**: GPU automatically reduces clocks due to thermal/power limits
- **P2P**: Peer-to-peer (direct GPU-to-GPU communication)
- **NCCL**: NVIDIA Collective Communications Library (for multi-GPU ops)

**Success Criteria:**

```bash
# Check results
dcgmi diag -r 3 | grep "Test Result"

# Expected:
# +---------------------------+------------------------+
# | Test Result               | PASS                   |
# +---------------------------+------------------------+
```

**Pass Criteria:**
- ✅ All GPUs detected and responsive
- ✅ Compute performance ≥90% of spec
- ✅ Memory bandwidth ≥95% of spec (3.3+ TB/s for H100)
- ✅ NVLink bandwidth ≥90% of spec (900 GB/s for H100)
- ✅ PCIe bandwidth ≥90% of spec (60+ GB/s for Gen5 x16)
- ✅ Peak temps <85°C
- ✅ 0 double-bit ECC errors
- ✅ Power draw within limits

**Common Failures & Actions:**

| Failure | Cause | Action |
|---------|-------|--------|
| Memory ECC errors | Faulty GPU memory | Replace GPU |
| NVLink bandwidth low | Cable issue, NVSwitch problem | Reseat cables, check NVSwitch |
| PCIe bandwidth low | BIOS setting, slot issue | Check BIOS, reseat GPU |
| Thermal throttling | Cooling insufficient | Check fans, airflow, thermal paste |
| Low compute performance | Misconfiguration, defective GPU | Check clocks, replace if defective |

**Next Step:** If PASS → Proceed to 2 HPL  
**If FAIL:** Troubleshoot (Section 5), fix, retest

*ECC error (Error Correcting Code)*
ECC is extra “check bits” stored with memory so the GPU can detect (and often fix) bit flips.
Two main types you’ll hear:
Correctable ECC (CE): a bit flipped but was fixed automatically; you keep running. 
Uncorrectable ECC (UE): can’t fix; usually the app crashes or the GPU gets reset/marked unhealthy. 

What an “ECC error” means in practice:
CE increasing slowly over months can be “background reality.”
CE increasing fast during stress is a big warning.
Any UE during stress is basically “this GPU/memory path is not production-safe.”

*Memory Stress*
“How do we fill GPU memory and stress it?”
You stress GPU memory by doing TWO things:
Capacity pressure (fill it)
Allocate buffers until you’re near full VRAM (leave a little headroom so the driver doesn’t OOM).
Integrity pressure (prove bits don’t flip)

Write known patterns (all-zeros, all-ones, walking ones, random).
Read back and verify.
Repeat under heat (that’s when marginal memory shows itself).

Then add bandwidth pressure:
Run big streaming reads/writes (like memcpy kernels) continuously.
Run random-access patterns too (more “worst case” for some paths).
What “rapid read/write” really means:
Not “copy one time.”
It’s repeated, sustained loops that keep memory controllers busy 100% for minutes/hours.
What you watch during this:
ECC CE/UE counters
Perf stability (bandwidth should stay near expected; not drop due to throttling)


*Compute stress: how do you “check FP64/FP32/FP16/INT8”?*

Think of these as “different math engines” inside the GPU:
FP64 (double precision)
Mostly CUDA cores (and only some GPUs have strong FP64).
Used in scientific/HPC workloads (HPL FP64 is a classic).
FP32 (single precision)
CUDA cores (general purpose).
FP16 / BF16
Can run on CUDA cores, but the huge throughput numbers on spec sheets assume Tensor Cores.
INT8
Mostly Tensor Cores (quantized math), but only if the kernel is using the right instructions/paths.

So “how to test each” is really:
Run kernels that FORCE that datatype and engine.

Practical approach:
FP64: run FP64 GEMM / HPL (that’s basically the standard).
FP32: run FP32 GEMM / general compute burn (many burn tools are FP32-heavy).
FP16/BF16: run Tensor Core GEMM (large matrix multiplications) with FP16/BF16 inputs.
INT8: run INT8 GEMM / inference-style matmul (again tensor-core path).

What to measure:
Throughput (TFLOPS / TOPS)
Clocks (staying high)
No crashes / no Xid resets 

*Interconnect stress: what are we testing exactly?*
A) Reachability / topology correctness
Can GPU0 talk to GPU1 at all?
Is P2P enabled where it should be?
Is the NVLink/NVSwitch fabric “as wired”?

B) Speed (bandwidth) and latency
NVLink BW should be much higher than PCIe GPU↔GPU paths (on systems that have it).
PCIe gen/width should match expectation (no downtraining). 

C) Reliability under load
No CRC/replay errors on NVLink.
No PCIe AER spam.
No hangs during heavy collective communication.

*Thermal stress: what happens and how do we test it?*

What happens physically:
Compute + memory traffic turns into heat.
If cooling can’t remove it fast enough, GPU hits thermal limits.
Then the GPU protects itself by lowering clocks (thermal throttling). 

How you test it (conceptually):
Run a workload that keeps:
compute busy
memory busy
interconnect busy (optional but often makes it hotter at system level)

Monitor:
GPU temp + hotspot (and sometimes memory temp depending on GPU)
clocks (do they stay stable?)
throttling reasons (thermal vs power)

“<85C” rule:
It’s a decent beginner heuristic, but the real rule is:
stay below the throttle point with comfortable headroom
avoid running pinned at the limit for long durations

*Power delivery stress: PDU vs PSU, redundancy, phases*

PSU (Power Supply Unit)
Inside the server.
Converts AC (from the wall/PDU) into DC rails the motherboard/GPU VRMs use.

PDU (Power Distribution Unit)
Rack-level power strip/controller.
Takes building power and distributes it to servers (often with monitoring, breakers, sometimes metering per outlet).

VRM (Voltage Regulator Module)
On the motherboard / GPU board.
Converts DC rails into the very low, very high-current voltage the GPU actually uses.

What “power delivery stress” is catching:
Under load, GPUs can create fast power transients (big rapid changes in draw).

If PSUs, cables, connectors, PDUs, or circuits are marginal:
you’ll see power-limit throttling (soft)
or sudden resets/reboots (hard). 
About “different phases / different sources”
In datacenters, power is commonly 3-phase AC.

Redundancy is usually “A/B power”:
Server has 2 (or more) PSUs.
PSU1 plugs into PDU-A (fed by one UPS/generator path).
PSU2 plugs into PDU-B (a separate independent path).

Goal:
If a PDU or upstream circuit fails, the server stays up.
Important pushback:
A/B power redundancy helps you survive POWER PATH failures (PDU/UPS/circuit/PSU).
It does not “handle GPU failure.” If a GPU dies, redundancy is at the software/system level (job restarts, spare nodes, replica training, etc.).

What you measure during power stress:
Whether clocks drop due to power capping
Whether the node reboots / GPUs reset under spikes
Whether PSUs report alarms, or one PSU is overloaded while the other is idle

### 2 Execute HPL (High-Performance Linpack) - Single Node

**Purpose:** Stress test compute performance and stability with real mathematical workload

**What is HPL?**
- Industry-standard benchmark for HPC systems
- Solves dense linear algebra equations (Ax = b)
- Stresses: GPU compute, memory, and intra-node communication
- Measures: TFLOPS (floating-point operations per second)

**Prerequisites:**
- Section 1 DCGM test PASSED
- HPL benchmark installed (usually via NGC container)

**Command Sequence:**

```bash
# 1. Pull HPL container from NGC
docker pull nvcr.io/nvidia/hpc-benchmarks:latest

# 2. Run single-node HPL test
docker run --rm -it \
  --gpus all \
  --shm-size=1g \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  nvcr.io/nvidia/hpc-benchmarks:latest \
  hpl.sh --dat /workspace/hpl-linux-x86_64/sample-dat/HPL-dgx-h100-8gpu.dat

# Alternative: Using Slurm (if cluster software installed)
srun -N 1 --ntasks-per-node=8 \
  --container-image=nvcr.io/nvidia/hpc-benchmarks:latest \
  hpl.sh --dat HPL-dgx-h100-8gpu.dat
```

**What Happens During HPL:**

```
Timeline of HPL Execution:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

00:00 - Initialization
  - Allocate memory on all 8 GPUs
  - Generate random matrix A
  - Problem size: N=300000 (adjustable)
  
00:01-05:00 - Matrix Factorization (LU decomposition)
  - Heavy compute phase
  - All GPUs at 100% utilization
  - Extensive GPU-GPU communication via NVLink
  - Power: ~700W per GPU
  - Temperature: Rising to 75-80°C
  
05:00-05:30 - Solution & Verification
  - Solve for x
  - Verify solution accuracy
  - Calculate residual error
  
05:30 - Results
  - Performance in TFLOPS
  - Time to solution
  - Residual check (accuracy)
```

**Sample Output:**

```
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
Modified by Piotr Luszczek, Innovative Computing Laboratory, UTK
Modified by Julien Langou, University of Colorado Denver
================================================================================

An explanation of the input/output parameters follows:
T/V    : Wall time / encoded variant.
N      : The order of the coefficient matrix A.
NB     : The partitioning blocking factor.
P      : The number of process rows.
Q      : The number of process columns.
Time   : Time in seconds to solve the linear system.
Gflops : Rate of execution for solving the linear system.

The following parameter values will be used:

N      :  300000 
NB     :    1024 
PMAP   : Row-major process mapping
P      :       2 
Q      :       4 
PFACT  :   Crout 
NBMIN  :       8 
NDIV   :       2 
RFACT  :   Right 
BCAST  :  1ringM 
DEPTH  :       1 
SWAP   : Mix (threshold = 64)
L1     : transposed form
U      : transposed form
EQUIL  : yes
ALIGN  : 8 double precision words

--------------------------------------------------------------------------------

- The matrix A is randomly generated for each test.
- The following scaled residual check will be computed:
      ||Ax-b||_oo / ( eps * ( || x ||_oo * || A ||_oo + || b ||_oo ) * N )
- The relative machine precision (eps) is taken to be               1.110223e-16
- Computational tests pass if scaled residuals are less than                16.0

================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR11C2R4      300000  1024     2     4             326.89              1.651e+04
HPL_pdgesv() start time Wed Jan  3 10:15:23 2026

HPL_pdgesv() end time   Wed Jan  3 10:20:50 2026

--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   2.84659321e-03 ...... PASSED
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================
```
**Understanding the Output:**

| Metric | Meaning | H100 8-GPU Expected | Pass Criteria |
|--------|---------|---------------------|---------------|
| **Gflops** | Billions of FLOPS achieved | ~16-18 TFLOPS | ≥90% of theoretical |
| **Time** | Execution time (seconds) | ~300-400s | Reasonable for problem size |
| **Residual** | Solution accuracy | <1e-2 | PASSED (<16.0) |

**Theoretical Peak Performance:**
```
H100 GPU Specs:
  FP64: 34 TFLOPS per GPU
  8 GPUs: 34 × 8 = 272 TFLOPS theoretical peak
  
HPL Achievable:
  Typical efficiency: 60-70% of peak
  Expected: 16-18 TFLOPS (160-180 PFLOPS total)
  
Why not 100%?
  - Communication overhead (NVLink transfers)
  - Memory access patterns
  - Load balancing
```

### 1. **What's in the HPL Container?**

```
NGC HPL Container Contents:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Binaries
   └─ xhpl (pre-compiled HPL executable)

📚 Math Libraries  
   ├─ cuBLAS (GPU matrix operations)
   ├─ cuSOLVER (linear algebra solvers)
   └─ NCCL (GPU-to-GPU communication)

📄 Configuration Files
   └─ HPL.dat files for different GPU configs

🔧 Runtime Environment
   ├─ CUDA Toolkit
   ├─ MPI (multi-process coordination)
   └─ Linux base OS with dependencies

🚀 Launch Scripts
   └─ hpl.sh (wrapper to configure & run)
```

### 2. **What HPL Actually Does - Simple Version**

```
Imagine you have this equation:
   A × x = b
   
Where:
   A = A huge matrix (300,000 × 300,000 = 90 BILLION numbers!)
   x = Unknown vector you're solving for
   b = Known result

HPL's job:
   Step 1: Generate random A and b
   Step 2: Break A into pieces (LU factorization) ← 99% of work!
   Step 3: Use those pieces to find x
   Step 4: Check if x is correct (residual check)

Why this is hard:
   - 18 quintillion calculations needed
   - Must coordinate 8 GPUs working together
   - Uses 576GB of GPU memory
   - Takes billions of GPU-GPU data transfers
```

### 3. **Smoke Test vs Burn-In - The Critical Difference**

```
🔥 SMOKE TEST (1-10 minutes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Question: "Does it turn on?"
Catches:
   ✓ Completely dead GPU
   ✓ Driver not installed  
   ✓ Massive performance issue (100x slow)
   
Misses:
   ✗ Marginal components that fail when hot
   ✗ Cooling inadequacy (doesn't run long enough)
   ✗ Intermittent errors (need sustained stress)

───────────────────────────────────────────────

🔥🔥🔥 BURN-IN (4-24 hours)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Question: "Will it survive production?"
Catches:
   ✓ Memory that only fails at 82°C+
   ✓ Power supply that droops after 6 hours
   ✓ Cooling that can't sustain load
   ✓ Cables that accumulate errors over time
   ✓ Rare firmware bugs (1 in 10,000 operations)

Real example:
   • Smoke test: GPU passes
   • Burn-in at hour 11: GPU starts throwing errors
   • Cause: HBM chip fails only when hot
   • Without burn-in: Would fail in production!
```

### 4. **What Each Output Number Means**

```
WR11C2R4  300000  1024   2   4    326.89    1.651e+04
    ↑        ↑      ↑    ↑   ↑       ↑          ↑
    │        │      │    │   │       │          │
Algorithm  Size  Block  P   Q     Time     Performance
variant                Grid        (sec)     (Gflops)
                       2×4=8
                       GPUs

Key metrics:
• Time: 326 seconds = ~5.5 minutes ✓ Good
• Gflops: 16,510 = 16.5 TFLOPS ✓ Reasonable for FP64
• Residual: 0.00285 < 16.0 ✓ PASSED

If you see:
• Time = 900+ seconds → Performance issue!
• Residual ≥ 16.0 → Memory/compute error!
```

### 5. **Why HPL Before Network Tests?**

```
Testing Sequence Logic:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: HPL (Single-Node Compute Test)
   If HPL fails:
      → Bad GPU, memory, or power
      → Fix THIS before testing network
      → Otherwise you're debugging the wrong thing!

Step 2: NCCL (Multi-Node Network Test)  
   Now that compute works:
      → Test if nodes can talk to each other
      → If this fails, it's network/fabric issue
      → Not confused with GPU problems

Analogy:
   1. Check each car's engine (HPL)
   2. Then test the road between them (NCCL)
   
Don't test the road if the cars don't run!
```

### 6. **The Temperature Story**

```
Why Burn-In Reveals Hidden Problems:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Smoke Test Timeline:
   0 min: GPU starts at 35°C
   5 min: GPU reaches 68°C
   Test ends: ✓ PASS

Burn-In Timeline:
   0 min: GPU starts at 35°C
   30 min: GPU at 75°C
   2 hours: GPU at 79°C  
   4 hours: GPU at 82°C
   6 hours: GPU at 85°C ← Marginal HBM starts failing!
   8 hours: Errors accumulate
   Result: ✗ FAIL

The failing component only shows problems at 82°C+
Smoke test never reached that temperature!
```

## The Bottom Line

**HPL is like a stress test for your entire GPU infrastructure:**
- Pushes GPUs to 100% for sustained periods
- Validates compute, memory, communication, cooling, power
- Smoke test = "quick health check"  
- Burn-in = "will it survive real life"

- Know that HPL solves dense linear algebra (Ax=b)
- Understand residual check must be <16.0
- Remember: smoke test catches obvious failures, burn-in catches subtle ones
- Memorize the sequence: DCGM → HPL → NCCL
- Typical single-node HPL: 5-10 minutes for smoke, 24 hours for burn-in


**Success Criteria:**
- ✅ HPL completes without crashes
- ✅ "PASSED" residual check
- ✅ Performance ≥90% of expected for platform
- ✅ No thermal throttling during run
- ✅ Consistent performance across multiple runs

**Next Step:** If PASS → Proceed to 3 NCCL  
**If FAIL:** Check for thermal issues, memory errors, NVLink problems

---

### 3 Perform Single-Node NCCL (Verify NVLink Switch)

**Purpose:** Validate GPU-to-GPU communication performance within the node

**What is NCCL?**
- NVIDIA Collective Communications Library
- Used for multi-GPU training in AI/ML workloads
- Tests: All-reduce, All-gather, Broadcast, Reduce-scatter
- Critical for: Distributed training efficiency

**Prerequisites:**
- Section 1 DCGM test PASSED
- Section 2 HPL PASSED
- NCCL tests installed (via NGC container)

**Command Sequence:**

```bash
# 1. Pull NCCL tests container
docker pull nvcr.io/nvidia/pytorch:24.12-py3

# 2. Run all-reduce test (most common operation in training)
docker run --rm -it \
  --gpus all \
  --shm-size=8g \
  --net=host \
  nvcr.io/nvidia/pytorch:24.12-py3 \
  /workspace/nccl-tests/build/all_reduce_perf -b 8 -e 8G -f 2 -g 8

# Alternative: Using nccl-tests directly
/usr/local/nccl-tests/build/all_reduce_perf \
  -b 8 \        # Start size: 8 bytes
  -e 8G \       # End size: 8 GB
  -f 2 \        # Factor: multiply by 2 each iteration
  -g 8          # Number of GPUs

# 3. Test other collective operations
# All-gather test
all_gather_perf -b 8 -e 8G -f 2 -g 8

# Broadcast test
broadcast_perf -b 8 -e 8G -f 2 -g 8

# Reduce-scatter test
reduce_scatter_perf -b 8 -e 8G -f 2 -g 8
```

**What Happens During NCCL Test:**

```
All-Reduce Operation Example:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each GPU starts with a value:
  GPU 0: [1, 2, 3, 4]
  GPU 1: [5, 6, 7, 8]
  GPU 2: [9, 10, 11, 12]
  ...
  
All-Reduce (SUM):
  1. Each GPU sends its data to all other GPUs via NVLink
  2. Sum computed across all GPUs
  3. Result broadcast back to all GPUs
  
Final result on ALL GPUs:
  GPU 0-7: [sum of all values]

Performance measured:
  - Bandwidth (GB/s)
  - Latency (microseconds)
  - Algorithmic bandwidth (bus bandwidth)
```

**Sample Output:**

```
# nccl-tests: Version 2.13.9
# 
# Using devices
#  Rank  0 Group  0 Pid   1234 on localhost device  0 [0x17] NVIDIA H100 80GB HBM3
#  Rank  1 Group  0 Pid   1234 on localhost device  1 [0x65] NVIDIA H100 80GB HBM3
#  Rank  2 Group  0 Pid   1234 on localhost device  2 [0xca] NVIDIA H100 80GB HBM3
#  Rank  3 Group  0 Pid   1234 on localhost device  3 [0xe3] NVIDIA H100 80GB HBM3
#  Rank  4 Group  0 Pid   1234 on localhost device  4 [0x1a] NVIDIA H100 80GB HBM3
#  Rank  5 Group  0 Pid   1234 on localhost device  5 [0x68] NVIDIA H100 80GB HBM3
#  Rank  6 Group  0 Pid   1234 on localhost device  6 [0xbd] NVIDIA H100 80GB HBM3
#  Rank  7 Group  0 Pid   1234 on localhost device  7 [0xd6] NVIDIA H100 80GB HBM3
#
#                                                              out-of-place                       in-place          
#       size         count      type   redop    root     time   algbw   busbw #wrong     time   algbw   busbw #wrong
#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            (us)  (GB/s)  (GB/s)       
           8             2     float     sum      -1    18.45    0.00    0.00      0    18.12    0.00    0.00      0
          16             4     float     sum      -1    18.34    0.00    0.00      0    18.23    0.00    0.00      0
          32             8     float     sum      -1    18.56    0.00    0.00      0    18.34    0.00    0.00      0
          64            16     float     sum      -1    18.67    0.00    0.01      0    18.45    0.00    0.01      0
         128            32     float     sum      -1    18.89    0.01    0.01      0    18.67    0.01    0.01      0
         256            64     float     sum      -1    19.23    0.01    0.02      0    19.01    0.01    0.02      0
         512           128     float     sum      -1    19.67    0.03    0.05      0    19.45    0.03    0.05      0
        1024           256     float     sum      -1    20.34    0.05    0.09      0    20.12    0.05    0.09      0
        2048           512     float     sum      -1    21.23    0.10    0.17      0    21.01    0.10    0.17      0
        4096          1024     float     sum      -1    22.67    0.18    0.32      0    22.45    0.18    0.32      0
        8192          2048     float     sum      -1    24.56    0.33    0.58      0    24.34    0.34    0.59      0
       16384          4096     float     sum      -1    28.34    0.58    1.01      0    28.12    0.58    1.02      0
       32768          8192     float     sum      -1    35.67    0.92    1.61      0    35.45    0.92    1.61      0
       65536         16384     float     sum      -1    48.23    1.36    2.38      0    48.01    1.37    2.39      0
      131072         32768     float     sum      -1    71.45    1.83    3.21      0    71.23    1.84    3.22      0
      262144         65536     float     sum      -1    115.6    2.27    3.97      0    115.4    2.27    3.98      0
      524288        131072     float     sum      -1    201.3    2.60    4.56      0    201.1    2.61    4.56      0
     1048576        262144     float     sum      -1    367.8    2.85    4.99      0    367.6    2.85    4.99      0
     2097152        524288     float     sum      -1    689.2    3.04    5.32      0    689.0    3.04    5.33      0
     4194304       1048576     float     sum      -1   1298.4    3.23    5.65      0   1298.2    3.23    5.65      0
     8388608       2097152     float     sum      -1   2456.7    3.41    5.97      0   2456.5    3.42    5.98      0
    16777216       4194304     float     sum      -1   4734.5    3.54    6.20      0   4734.3    3.54    6.20      0
    33554432       8388608     float     sum      -1   9187.6    3.65    6.39      0   9187.4    3.65    6.40      0
    67108864      16777216     float     sum      -1  17989.2    3.73    6.53      0  17989.0    3.73    6.53      0
   134217728      33554432     float     sum      -1  35456.3    3.78    6.62      0  35456.1    3.79    6.63      0
   268435456      67108864     float     sum      -1  70234.7    3.82    6.69      0  70234.5    3.82    6.69      0
   536870912     134217728     float     sum      -1 139876.5    3.84    6.72      0 139876.3    3.84    6.72      0
  1073741824     268435456     float     sum      -1 278945.2    3.85    6.74      0 278945.0    3.85    6.74      0
  2147483648     536870912     float     sum      -1 557234.8    3.85    6.74      0 557234.6    3.86    6.75      0
  4294967296    1073741824     float     sum      -1 1113456.2   3.86    6.75      0 1113456.0   3.86    6.75      0
  8589934592    2147483648     float     sum      -1 2225678.4   3.86    6.76      0 2225678.2   3.86    6.76      0
# Out of bounds values : 0 OK
# Avg bus bandwidth    : 4.52531 
#
```

**Understanding NCCL Output:**

| Column | Meaning | What to Look For |
|--------|---------|------------------|
| **size (B)** | Message size being transferred | Progression from 8B to 8GB |
| **time (us)** | Microseconds to complete operation | Lower is better |
| **algbw (GB/s)** | Algorithm bandwidth (actual data moved) | Should increase with size |
| **busbw (GB/s)** | Bus bandwidth (physical wire bandwidth) | Key metric! |
| **#wrong** | Data corruption errors | MUST be 0! |

**Expected Bus Bandwidth (H100 8-GPU with NVSwitch):**

```
Theoretical Maximum:
  NVLink 4.0: 900 GB/s per link × 18 links = 16.2 TB/s per GPU
  8 GPUs all-reduce: ~6-7 GB/s bus bandwidth
  
Actual Achievable:
  Good: 6-7 GB/s (busbw)
  Acceptable: 5-6 GB/s
  Poor: <5 GB/s (indicates NVLink issues)
  
Why not 16 TB/s?
  - All-reduce algorithm overhead
  - Multiple GPUs sharing NVSwitch
  - Protocol overhead
  - Tree-based reduction algorithm
```

**NVLink Verification During NCCL:**

```bash
# While NCCL test is running, check NVLink stats
watch -n 1 'nvidia-smi nvlink -s'

# Expected output (example for GPU 0):
GPU 0: NVIDIA H100 80GB HBM3 (UUID: GPU-...)
         Link 0: <inactive>
         Link 1: <inactive>
         Link 2: <inactive>
         ...
         Link 0, P2P is supported: true
         Link 1, P2P is supported: true
         ...
         NVSwitch connected: Yes
         
# Check link status
nvidia-smi nvlink --status -i 0

# Expected: All links "Active"
```

**Success Criteria:**

- ✅ All GPUs detected and participating
- ✅ Bus bandwidth ≥5 GB/s for large messages (>1GB)
- ✅ **#wrong = 0** for all message sizes (critical!)
- ✅ Bandwidth increases with message size (plateau at ~4-7 GB/s)
- ✅ NVLink links all "Active" during test
- ✅ No error messages or crashes

**Common Issues:**

| Symptom | Cause | Action |
|---------|-------|--------|
| Bus bandwidth <3 GB/s | NVLink degraded/failed | Check `dcgmi diag -r 3`, reseat cables |
| #wrong > 0 | Data corruption | **CRITICAL** - Replace GPU or cables immediately |
| Test hangs | NCCL misconfiguration | Check `NCCL_DEBUG=INFO`, verify network |
| Bandwidth not scaling | NVSwitch issue | Check NVSwitch firmware, topology |

**Next Step:** If all Phase 1 tests PASS → Proceed to Phase 2 (Infrastructure Validation)

---

## PHASE 2: Infrastructure Validation

### Goal: Validate physical infrastructure before multi-node testing

---

### 4 Validate Cables by Verifying Signal Quality

**Purpose:** Ensure InfiniBand/Ethernet cables meet performance standards

**Tools Used:**
- `ibdiagnet` (InfiniBand)
- `ibcheckerrors` (InfiniBand)
- Cable validation utilities

**Command Sequence:**

```bash
# 1. Check InfiniBand link status
ibstat

# Expected output:
# CA 'mlx5_0'
#     Port 1:
#         State: Active
#         Physical state: LinkUp
#         Rate: 400 Gb/sec (8X EDR)
#         Link layer: InfiniBand

# 2. Check for link errors
ibcheckerrors

# Expected: No errors on any links

# 3. Run comprehensive diagnostics
ibdiagnet -ls 10

# This scans fabric, checks:
#   - Link width (should be 4x or 8x)
#   - Link speed (HDR, NDR, etc.)
#   - Error counters
#   - Symbol errors (BER - bit error rate)

# 4. Check specific port counters
perfquery -r

# Look for:
#   - SymbolErrorCounter: should be 0 or very low
#   - LinkErrorRecoveryCounter: should be 0
#   - PortRcvErrors: should be 0
```

**Sample Output:**

```
# ibdiagnet output

-I- Discovering ... 64 nodes discovered.
-I- Traversing Fabric ...
-I- Checking lids ...
-I- Building Network Topology ...

========================================
Link Quality Report
========================================

Good Links: 126
Degraded Links: 2
Failed Links: 0

Degraded Links Details:
----------------------------------------
Link: Node1:Port3 <--> Node2:Port5
  Status: Active but degraded
  Expected: 400 Gb/s (HDR 8X)
  Actual: 200 Gb/s (running at 4X)
  Symbol Errors: 1,234
  Recommendation: Replace cable

Link: Node3:Port1 <--> Switch1:Port12
  Status: Active with errors
  Expected: 400 Gb/s
  Actual: 400 Gb/s
  Symbol Errors: 567
  Bit Error Rate: 1e-10 (threshold: 1e-12)
  Recommendation: Reseat cable, monitor

========================================
```

**Signal Quality Metrics:**

| Metric | Good | Acceptable | Bad | Action |
|--------|------|------------|-----|--------|
| Symbol Errors | 0 | <100 | >100 | Replace cable |
| Bit Error Rate (BER) | <1e-12 | 1e-10 to 1e-12 | >1e-10 | Replace |
| Link Width | 4x/8x as designed | Same | Running at lower | Reseat/replace |
| Link Speed | Full rate (400 Gb/s) | Full rate | Degraded | Replace |


## **Infrastructure Validation Order**

| **Phase** | **Step** | **What You're Checking** | **Primary Tools** | 
|-----------|----------|-------------------------|-------------------|-------------------|
| **Phase 1: Physical Layer** | 4.4 | Cable signal quality (BER, errors, link health) | `mlxlink`, UFM Cable Validation, `ibcheckerrors` | 
| **Phase 1: Physical Layer** | 4.5 | Topology correctness (right ports connected) | `ibnetdiscover`, `iblinkinfo`, UFM topology compare | 
| **Phase 2: Version Compliance** | 4.6 | Switch firmware/software versions | Switch CLI (`show version`), UFM inventory | 
| **Phase 2: Version Compliance** | 4.7 | BlueField DPU firmware/software | `mlxfwmanager`, `flint`, `mst status` | 
| **Phase 2: Version Compliance** | 4.8 | Transceiver/optics firmware | `mlxcables`, `mlxlink` (module info) | 
| **Phase 3: Performance Validation** | After 4.4-4.8 | RDMA functional + performance check | **NOW use perftest** | 

---

## **STEP 4: Validate Cable Signal Quality**

### **What This Actually Tests**
Physical link health: bit error rates, lane stability, optical power levels, module temperatures

### **Command Reference Table**

| **Tool** | **Command** | **What It Shows** | **Good Result** | **Bad Result** | **Action If Bad** |
|----------|-------------|-------------------|-----------------|----------------|-------------------|
| **mlxlink** | `mlxlink -d <device>` | Link status, speed, width, BER, counters | • State: Active<br>• BER: ~0 or <1e-12<br>• No counter increases | • BER >1e-10<br>• Counters climbing<br>• Link flapping | Reseat cable → replace if persists |
| **mlxlink** (extended) | `mlxlink -d <device> -e` | Extended counters: symbol errors, FEC stats | • Symbol errors: 0<br>• FEC corrections: low/stable | • Symbol errors climbing<br>• High FEC correction rate | Check transceiver temp → replace cable |
| **mlxlink** (module) | `mlxlink -d <device> -m` | Optical module diagnostics (temp, TX/RX power) | • Temp: 40-60°C typical<br>• RX/TX power in spec | • Temp >70°C<br>• Low RX power<br>• Module alarms | Check airflow → replace module |
| **ibcheckerrors** | `ibcheckerrors` | Fabric-wide error scan | • All links: "No errors" | • SymbolErrorCounter >0<br>• LinkErrorRecovery >0 | Identify bad links → reseat/replace |
| **ibstat** | `ibstat` | Per-port link status | • State: Active<br>• Physical state: LinkUp<br>• Rate: full (400 Gb/s) | • Rate degraded<br>• Width reduced (8x→4x) | Reseat cable → check switch port |
| **perfquery** | `perfquery -r` | Port error counters | • All counters: 0 or very low | • PortRcvErrors >0<br>• Counters increasing | Check cable → check receiver |
| **UFM Cable Validation** | Via UFM GUI or API | "Golden BER Test" - monitors BER over time under load | • BER stable <1e-12<br>• No errors during test | • BER drift during test<br>• Errors under load | Replace cable (marginal under load) |

### **Key Metrics Decoded**

| **Metric** | **What It Means** | **Threshold** | **If Exceeded** |
|------------|-------------------|---------------|-----------------|
| **BER (Bit Error Rate)** | How many bits flip per bits transmitted | <1e-12 (good)<br>1e-10 to 1e-12 (acceptable)<br>>1e-10 (bad) | Replace cable/transceiver |
| **Symbol Errors** | Physical layer encoding errors | 0 is ideal<br><100 acceptable<br>>100 problem | Reseat → replace |
| **Link Width** | Number of active lanes | 4x or 8x as designed | Running reduced width = bad cable/connector |
| **Link Speed** | Data rate per lane | 400 Gb/s (HDR), 800 Gb/s (NDR) as designed | Downtraining = incompatibility or bad signal |
| **FEC Corrections** | Forward Error Correction events | Low and stable | High/climbing = marginal link |
| **RX Power (optics)** | Received optical power | -2 to -10 dBm typical | Too low = dirty/bad fiber, too high = saturated receiver |
| **Module Temp** | Transceiver temperature | 40-60°C normal | >70°C = cooling issue or failing module |

### **Red Flags That Mean "Replace Cable"**
- BER >1e-10 consistently
- Symbol errors increasing over minutes
- Link flaps (down/up cycling)
- Only fails under sustained load (marginal)
- Running at reduced width/speed
- High FEC correction rate

---

## **STEP 5: Confirm Cabling Topology**

### **What This Actually Tests**
Correct port-to-port connections match your design (not testing speed/errors here, just "is A plugged into B?")

### **Command Reference Table**

| **Tool** | **Command** | **What It Shows** | **How to Use** |
|----------|-------------|-------------------|----------------|
| **ibnetdiscover** | `ibnetdiscover > topology.txt` | Full fabric map: every node, port, GUID, connection | Compare output to your cabling design doc |
| **ibnetdiscover** (ports) | `ibnetdiscover -p > ports.txt` | Port-by-port connectivity | Verify each DGX port → correct switch port |
| **iblinkinfo** | `iblinkinfo` | All links with source/dest, state, speed | Quick visual check: all links active + correct neighbors |
| **UFM Topology View** | Via UFM GUI | Graphical fabric topology | Visual comparison to expected layout |
| **UFM Cable Validation** | Topology compare feature | Compares actual vs expected topology | Flags missing links, wrong connections, unexpected neighbors |

### **Example Verification**

```
Expected Design:
DGX-1 Port 1 → Leaf-1 Port 17
DGX-1 Port 2 → Leaf-2 Port 17
DGX-2 Port 1 → Leaf-1 Port 18
...

iblinkinfo Output Check:
✅ DGX-1 mlx5_0/1 → Leaf-1/17 [ACTIVE, 400G]
✅ DGX-1 mlx5_1/1 → Leaf-2/17 [ACTIVE, 400G]
❌ DGX-2 mlx5_0/1 → Leaf-2/18 [WRONG - should be Leaf-1]
```

### **Checklist**
- ✅ Every DGX port connects to intended leaf switch port
- ✅ Leaf-to-spine uplinks match design
- ✅ No crossed cables (e.g., port 1↔port 2 swapped)
- ✅ Cable types correct (copper vs optical, length appropriate)
- ✅ All expected links present (none missing)

---

## **STEP 6: Switch Firmware/Software**

### **What This Actually Tests**
All switches run certified, compatible firmware versions

### **Command Reference Table**

| **Switch Type** | **Command** | **What to Check** |
|-----------------|-------------|-------------------|
| **NVIDIA Spectrum (ONYX)** | `show version` | Product name, release version, build ID |
| **NVIDIA Cumulus** | `cat /etc/cumulus/etc.replace` or `nv show system` | Cumulus Linux version |
| **Mellanox Neo** | `show version` | MLNX-OS version |

### **Example Output Check**

```bash
switch1# show version
Product name:      SN4600
Product release:   3.10.2008  ← Check this
Build ID:          #1-dev
Hardware revision: A1
```

### **Verification Process**

| **Step** | **Action** | **Tool/Method** |
|----------|-----------|-----------------|
| 1 | Get current version from each switch | SSH + `show version` |
| 2 | Compare to certified matrix | DGX deployment guide / NVIDIA compatibility docs |
| 3 | Flag mismatches | Spreadsheet or UFM inventory report |
| 4 | Upgrade if needed | `image install`, `image boot next`, `reload` |
| 5 | Re-verify after reboot | `show version` again |

### **Certified Version Matrix (Example)**

| **Switch Model** | **Certified FW** | **Min Version** | **Status** |
|------------------|------------------|-----------------|------------|
| SN4600 | 3.10.2008 | 3.10.2000 | ✅ Current |
| SN4700 | 3.10.2106 | 3.10.2000 | ✅ Current |
| QM8700 | 3.10.2210 | 3.10.2200 | ✅ Current |

---

## **STEP 7: BlueField DPU Firmware**

### **What This Actually Tests**
DPU firmware + software matches requirements, consistent across fleet

### **Command Reference Table**

| **Tool** | **Command** | **What It Shows** |
|----------|-------------|-------------------|
| **mst** | `mst status` | MST (Mellanox Software Tools) device status |
| **mlxfwmanager** | `mlxfwmanager` | Installed firmware on all devices |
| **flint** | `flint -d /dev/mst/mt41692_pciconf0 query` | Detailed FW version, PSID, release date |

### **Example Output**

```bash
# flint -d /dev/mst/mt41692_pciconf0 query

Image type:            FS4
FW Version:            24.39.1002  ← Check this
FW Release Date:       6.1.2024
Product Version:       24.39.1002
PSID:                  MT_0000000634  ← Must match certified PSID
Description:           BlueField-3 DPU; 400GbE/NDR; Crypto enabled
```

### **Verification Steps**

| **Step** | **Command/Action** |
|----------|-------------------|
| Check current FW | `flint -d <device> query` |
| Compare to certified version | Reference DGX deployment guide |
| Upgrade if needed | `mlxfwmanager -u -i <firmware.bin>` |
| Reboot DPU | `bfb-power-cycle` or `mlxfwreset -d <device>` |
| Verify after reboot | `flint query` again |

---

## **STEP 8: Transceiver/Optics Firmware**

### **What This Actually Tests**
Optical modules and cables have correct firmware, not marginal

### **Command Reference Table**

| **Tool** | **Command** | **What It Shows** |
|----------|-------------|-------------------|
| **mlxcables** | `mlxcables` | List all connected cables/transceivers |
| **mlxcable** | `mlxcable -d <device>` | Specific cable/transceiver info |
| **mlxlink -m** | `mlxlink -d <device> -m` | Module diagnostics (temp, power, vendor info) |

### **Example: Module Health Check**

```bash
# mlxlink -d mlx5_0 -m

Module Info:
  Type: QSFP56-DD
  Vendor: NVIDIA
  P/N: MCP1650-H001E30
  S/N: MT2134FT12345
  Temperature: 45°C  ← Should be <70°C
  RX Power: -5.2 dBm  ← Should be -2 to -10 dBm
  TX Power: -2.1 dBm
```

### **What to Check**

| **Field** | **Good** | **Bad** | **Action** |
|-----------|----------|---------|------------|
| Temperature | <60°C | >70°C | Check airflow, replace module |
| RX Power | -2 to -10 dBm | Too low or too high | Clean fiber, replace cable |
| Alarms | None | Any alarm flags | Check module diagnostics, replace |
| Firmware version | Matches certified list | Unknown/old | Usually auto-updated by switch FW |

---

## **PERFTEST: Where It Actually Fits**

### **When to Use Perftest**

| **Scenario** | **Use Perftest?** | **Why** |
|--------------|-------------------|---------|
| **Before 4.4-4.8 complete** | ❌ No | Premature - physical layer not validated |
| **After 4.4-4.8 all pass** | ✅ Yes | Confirm RDMA performance end-to-end |
| **To check signal quality (BER)** | ❌ No | Use mlxlink/UFM instead |
| **To verify topology** | ❌ No | Use ibnetdiscover/iblinkinfo |
| **To check firmware versions** | ❌ No | Use version query commands |
| **To prove RDMA works + speed** | ✅ Yes | This is perftest's job |

### **Perftest Command Reference**

| **Command** | **What It Tests** | **Example** |
|-------------|-------------------|-------------|
| `ib_write_bw` | RDMA Write bandwidth | `ib_write_bw -d mlx5_0 -a` (server)<br>`ib_write_bw -d mlx5_0 <server_ip>` (client) |
| `ib_read_bw` | RDMA Read bandwidth | `ib_read_bw -d mlx5_0 -a` |
| `ib_send_bw` | RDMA Send bandwidth | `ib_send_bw -d mlx5_0 -a` |
| `ib_write_lat` | RDMA Write latency | `ib_write_lat -d mlx5_0 -a` |
| `ib_send_lat` | RDMA Send latency | `ib_send_lat -d mlx5_0 -a` |

### **Expected Results (Example for 400G InfiniBand HDR)**

| **Test** | **Expected** | **Red Flag** |
|----------|--------------|-------------|
| **ib_write_bw** | ~45-48 GB/s (single direction) | <40 GB/s |
| **ib_write_bw** (bidirectional `-b`) | ~90-95 GB/s (both directions) | <80 GB/s |
| **ib_write_lat** | <2 microseconds | >5 microseconds |
| **Stability** | Consistent across 10 runs | Jitter >10% run-to-run |

### **How Perftest Helps (Indirectly) With 4.4**

| **Observation in Perftest** | **Possible Signal Quality Issue** | **What to Check** |
|-----------------------------|----------------------------------|-------------------|
| Bandwidth drops randomly | Marginal cable under load | Run mlxlink during perftest, watch BER/errors |
| High latency jitter | Link retraining / instability | Check ibcheckerrors, perfquery counters |
| Occasional timeouts | CRC errors / link flapping | mlxlink extended counters, UFM alarms |
| Can't sustain bidirectional | Flow control / lane issues | mlxlink -e, check for symbol errors |

---

## **QUICK DECISION TREE**

```
Start Here
    ↓
Need to check physical link health (BER, errors)?
    → YES: Use mlxlink, ibcheckerrors, UFM Cable Validation (Step 4.4)
    → NO: ↓
    
Need to verify correct port-to-port connections?
    → YES: Use ibnetdiscover, iblinkinfo (Step 4.5)
    → NO: ↓
    
Need to verify firmware/software versions?
    → YES: Use show version (switches), flint (DPUs), mlxcables (optics) (Steps 4.6-4.8)
    → NO: ↓
    
All above steps PASS, now need to prove RDMA performance?
    → YES: NOW use perftest (ib_write_bw, ib_read_bw, etc.)
    → NO: What are you trying to validate?
```

---

## **SUMMARY: Tool Purpose Map**

| **Tool** | **Primary Purpose** | **NOT For** |
|----------|---------------------|-------------|
| **mlxlink** | Link status, BER, module diagnostics | Topology mapping, version checks |
| **ibnetdiscover** | Topology discovery | Signal quality, performance |
| **iblinkinfo** | Link connectivity quick view | Error details, versions |
| **ibcheckerrors** | Fabric-wide error scan | Performance testing |
| **perfquery** | Port-level error counters | Bandwidth measurement |
| **UFM Cable Validation** | BER testing, topology compare | Performance micro-benchmarking |
| **show version** (switch) | Firmware/software version check | Link health |
| **flint** / **mlxfwmanager** | DPU firmware query/update | Cable testing |
| **mlxcables** | Transceiver inventory/diagnostics | RDMA performance |
| **perftest** (ib_*_bw/lat) | RDMA performance validation | Physical layer validation, version checks |

---

### 5 Confirm Cabling is Correct

**Purpose:** Verify physical topology matches design

**Tools:**
- Network topology diagrams
- Cable labeling documentation
- `ibnetdiscover` (InfiniBand)

**Command Sequence:**

```bash
# 1. Discover network topology
ibnetdiscover > fabric_topology.txt

# 2. Generate topology diagram
ibnetdiscover -p > topology_ports.txt

# 3. Compare against expected topology
# (Use network design documentation)

# 4. Verify specific connections
iblinkinfo

# Shows all links with source/destination info
```

**What to Verify:**

```
Expected Topology (DGX SuperPOD example):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DGX-1 → Port 1 → Leaf Switch 1, Port 17
DGX-1 → Port 2 → Leaf Switch 2, Port 17
DGX-2 → Port 1 → Leaf Switch 1, Port 18
DGX-2 → Port 2 → Leaf Switch 2, Port 18
...

Leaf Switch 1 → Uplink 1 → Spine Switch 1
Leaf Switch 1 → Uplink 2 → Spine Switch 2
Leaf Switch 2 → Uplink 1 → Spine Switch 1
Leaf Switch 2 → Uplink 2 → Spine Switch 2
```

**Verification Checklist:**
- ✅ Each DGX connected to correct leaf switches
- ✅ Leaf-to-spine uplinks correct
- ✅ No crossed cables
- ✅ Cable types match requirements (optical vs. copper, length)
- ✅ All expected links present

---

### 6 Confirm FW/SW on Switches

**Purpose:** Ensure network switches run certified firmware/software

**Command Sequence:**

```bash
# For NVIDIA Spectrum switches (Mellanox ONYX)

# 1. SSH to switch
ssh admin@switch-mgmt-ip

# 2. Check current version
show version

# Expected output:
# Product name:      SN4600
# Product release:   3.10.2008
# Build ID:          #1-dev
# Hardware revision: A1

# 3. Compare against certified versions
# (Reference: DGX SuperPOD deployment guide)

# 4. Upgrade if needed
image install <firmware_url>
image boot next
reload

# 5. Verify after reboot
show version
```

**Certified Firmware Matrix (Example):**

| Switch Model | Certified Firmware | Min Version | Status |
|--------------|-------------------|-------------|--------|
| SN4600 | 3.10.2008 | 3.10.2000 | ✅ Current |
| SN4700 | 3.10.2106 | 3.10.2000 | ✅ Current |
| QM8700 | 3.10.2210 | 3.10.2200 | ✅ Current |

---

### 7 Confirm FW/SW on BlueField 3

**Purpose:** Validate DPU firmware matches requirements

**Command Sequence:**

```bash
# On each DGX with BlueField DPU

# 1. Check BlueField firmware version
mst status
mlxfwmanager

# Expected output shows installed firmware

# 2. Query specific device
flint -d /dev/mst/mt41692_pciconf0 query

# Sample output:
# Image type:            FS4
# FW Version:            24.39.1002
# FW Release Date:       6.1.2024
# Product Version:       24.39.1002
# Rom Info:              type=UEFI version=14.32.17 cpu=AMD64,AARCH64
# Description:           BlueField-3 DPU; 400GbE/NDR; Crypto enabled
# PSID:                  MT_0000000634

# 3. Verify against certified version
# (Check NVIDIA DGX deployment guide)

# 4. Upgrade if needed
mlxfwmanager -u -i <firmware_image>

# 5. Reboot DPU
bfb-power-cycle
```

---

### 8 Confirm FW on Transceivers

**Purpose:** Ensure optical transceivers have correct firmware

**Command Sequence:**

```bash
# 1. List all transceivers
mlxcables

# Output shows all connected cables/transceivers

# 2. Query specific transceiver
mlxcable -d <cable_device>

# 3. Check firmware version
mlxcables -d <device> --cable_prbs show

# 4. Update if needed (rarely required)
# (Transceiver FW updates usually handled by switch FW)
```

## **Topic Classification by Validation Phase**

| **Topic** | **Belongs to Unit/Phase** | **Step Number** | **Category** |
|-----------|---------------------------|-----------------|--------------|
| **Cable Validation (NVIDIA Cable Validation Tool)** | **Phase 2: Infrastructure Validation** | **Step 4.4 & 4.5** | Physical Layer + Topology Verification |
| **InfiniBand Port Counters** | **Phase 2: Infrastructure Validation** | **Step 4.4** | Cable Signal Quality Monitoring |
| **Storage (Internal/External, NFS, RAID)** | **Phase 0: System Configuration** or **Post-Infrastructure** | **Pre-validation setup** | Application/Workload Layer (not part of 4.4-4.8) |
| **UFM (Unified Fabric Manager)** | **Phase 2: Infrastructure Validation** | **Steps 4.4-4.8** | Fabric Management & Monitoring Tool |

---

## **Detailed Breakdown**

### **1. Cable Validation Tool**

**Primary Phase:** Phase 2: Infrastructure Validation  
**Specific Steps:** 4.4 (Signal Quality) + 4.5 (Topology Verification)

**What it does:**
- **Step 4.4 component**: Runs "Golden BER Test" to validate cable signal quality under load
- **Step 4.5 component**: Compares actual deployed topology against expected/planned topology
- Works through switch management interfaces (doesn't require working SM or IB communication)
- Deploys agents on managed switches to discover neighbors and validate connections

**Key features relevant to validation:**
```
Cable Validation = 4.4 (BER/signal quality) + 4.5 (topology correctness)
```

| **Cable Validation Feature** | **Maps to Step** | **What It Validates** |
|------------------------------|------------------|----------------------|
| Golden BER Test | 4.4 | Signal quality, error rates, link stability |
| Neighbor discovery + topology compare | 4.5 | Correct port-to-port connections vs design |
| Agent-based validation | 4.5 | Incremental cluster bring-up validation |
| Report aggregation | 4.4 & 4.5 | Consolidated view of all link/topology issues |

---

### **2. InfiniBand Port Counters**

**Primary Phase:** Phase 2: Infrastructure Validation  
**Specific Step:** 4.4 (Validate Cables by Verifying Signal Quality)

**What it does:**
- Provides the **metrics** used to determine cable/link health
- Accessed via `perfquery`, `mlxlink`, UFM GUI/API, and `ibcheckerrors`
- Used continuously during and after validation

**Mapping to 4.4 validation:**

| **Port Counter Category** | **Purpose in Step 4.4** | **Key Counters** |
|---------------------------|------------------------|------------------|
| **Error Counters** | Detect link quality issues | Symbol Errors, Link Error Recovery, Link Downed, Rcv Errors |
| **Traffic Counters** | Verify data flow + bandwidth utilization | Xmit Data, Rcv Data, Xmit Packets, Rcv Packets |
| **Congestion Counters** | Identify bottlenecks/issues | XmitWait, Xmit Discards, Normalized Congested Bandwidth |
| **Integrity Counters** | Physical layer health | Local Integrity Error, Rcv Remote Physical Error |
| **Calculated Metrics** | Performance analysis | Normalized XmitData (utilization %), Normalized XmitWait (congestion) |

**Red Flag Counters for Step 4.4:**
```
Symbol Errors > 100        → Replace cable
Link Error Recovery > 0    → Reseat/monitor
Link Downed > 0           → Critical: replace cable/check switch port
Rcv Errors increasing     → Signal quality issue
XmitWait high             → Congestion (may indicate fabric issue)
```

---

### **3. Storage (Internal/External, NFS, RAID)**

**Primary Phase:** **Pre-validation / System Configuration** (NOT part of 4.4-4.8)  
**When it matters:** After infrastructure validation, during workload/application deployment

**Why it's NOT in 4.4-4.8:**
- Steps 4.4-4.8 focus on **network infrastructure** (InfiniBand/Ethernet fabric)
- Storage validation would be a **separate phase** covering:
  - RAID array health (`mdadm` status)
  - NFS mount/performance testing
  - Storage bandwidth to GPUs
  - File system integrity

**Where storage fits in the full workflow:**

| **Phase** | **What's Validated** | **Storage Role** |
|-----------|---------------------|------------------|
| Phase 0: Pre-Infrastructure | System installation, OS, RAID setup | ✅ Configure internal RAID-0 arrays |
| Phase 1: Single-Node GPU | GPU health, memory, compute | ❌ Not involved |
| Phase 2: Infrastructure (4.4-4.8) | Network fabric, cables, switches | ❌ Not involved |
| Phase 3: Multi-Node | NCCL, distributed training | ✅ NFS mounts, external storage connections |
| Phase 4: Application | Workload performance | ✅ Storage I/O bandwidth testing |

**Storage validation would include (separate from 4.4-4.8):**
- `mdadm --detail /dev/md0` - RAID health check
- NFS mount tests and bandwidth measurement
- Storage bandwidth benchmarks (e.g., `dd`, `fio`)
- Data loading performance for training workflows

---

### **4. UFM (Unified Fabric Manager)**

**Primary Phase:** Phase 2: Infrastructure Validation  
**Relevant to:** **All of Steps 4.4-4.8**

**What it does:**
- Central fabric management and monitoring platform
- Provides GUI/API access to all validation tools and metrics
- Aggregates port counters, events, alarms across entire fabric

**UFM's role in each step:**

| **Step** | **UFM Feature Used** | **What It Provides** |
|----------|---------------------|---------------------|
| **4.4** | Cable Validation plugin (Golden BER Test), Port counters monitoring | BER testing, error counter aggregation, link health dashboards |
| **4.5** | Topology discovery, Cable Validation topology compare | Graphical topology view, planned vs actual comparison, neighbor discovery |
| **4.6** | Device inventory, firmware tracking | Switch firmware version reporting across fabric |
| **4.7** | Device inventory (if BlueField registered) | DPU firmware visibility (limited) |
| **4.8** | Cable/module inventory, diagnostics | Transceiver info, module health monitoring |

**Key UFM components for validation:**

```
UFM Platform
├── Cable Validation Plugin (4.4 + 4.5)
│   ├── Golden BER Test (signal quality)
│   └── Topology Compare (cabling correctness)
├── Port Counter Monitoring (4.4)
│   ├── Real-time counter displays
│   └── Historical trending
├── Event & Alarm System (4.4, 4.6-4.8)
│   ├── Threshold-based alerts
│   └── Event log aggregation
├── Topology View (4.5)
│   ├── Visual fabric map
│   └── Link status visualization
└── Device Inventory (4.6, 4.8)
    ├── Firmware version tracking
    └── Module/transceiver cataloging
```

---

## **Quick Reference: Where Each Document Topic Fits**

| **Document Topic** | **Validation Phase** | **Steps** | **Purpose** |
|-------------------|---------------------|-----------|-------------|
| Cable Validation Tool guide | Phase 2: Infrastructure | 4.4 + 4.5 | Automate cable/topology validation |
| InfiniBand Port Counters reference | Phase 2: Infrastructure | 4.4 | Define metrics for link health |
| Storage configuration (RAID, NFS) | Phase 0: Pre-Infrastructure<br>Phase 4: Application | N/A (outside 4.4-4.8) | System setup, data pipeline |
| UFM platform documentation | Phase 2: Infrastructure | 4.4-4.8 | Central management tool |

---

## **Visual Workflow**

```
Infrastructure Validation Sequence:

┌─────────────────────────────────────────────────────────┐
│ Phase 2: Infrastructure Validation (Steps 4.4-4.8)      │
└─────────────────────────────────────────────────────────┘
              ↓
    ┌─────────────────────┐
    │ Step 4.4:           │ ← InfiniBand Port Counters (monitoring)
    │ Cable Signal        │ ← Cable Validation Tool (BER testing)
    │ Quality             │ ← UFM (aggregation/alerting)
    └─────────────────────┘
              ↓
    ┌─────────────────────┐
    │ Step 4.5:           │ ← Cable Validation Tool (topology compare)
    │ Topology            │ ← UFM Topology View
    │ Correctness         │ ← ibnetdiscover, iblinkinfo
    └─────────────────────┘
              ↓
    ┌─────────────────────┐
    │ Step 4.6:           │ ← UFM Device Inventory
    │ Switch FW/SW        │ ← Switch CLI (show version)
    └─────────────────────┘
              ↓
    ┌─────────────────────┐
    │ Step 4.7:           │ ← flint, mlxfwmanager
    │ BlueField FW/SW     │
    └─────────────────────┘
              ↓
    ┌─────────────────────┐
    │ Step 4.8:           │ ← mlxcables, mlxlink
    │ Transceiver FW      │ ← UFM Cable Inventory
    └─────────────────────┘

Storage Configuration:
├── Happens BEFORE Phase 2 (system setup)
└── Validated AFTER Phase 2 (application testing)
```
---



























## PHASE 3: Cluster Integration Testing

### Goal: Validate multi-node communication and cluster-wide functionality

---

### 9 Run ClusterKit to Perform Multifaceted Node Assessment

**Purpose:** Comprehensive cluster-wide health check

**What is ClusterKit?**
- NVIDIA's cluster validation framework
- Orchestrates tests across multiple nodes
- Includes: health checks, performance tests, network validation
- Produces comprehensive reports

**Prerequisites:**
- All nodes passed Phase 1 (single-node tests)
- All infrastructure validated (Phase 2)
- ClusterKit installed (part of Base Command Manager or standalone)

**Command Sequence:**

```bash
# 1. Configure ClusterKit inventory
# Create hostfile listing all nodes
cat > /tmp/hostfile << EOF
dgx-01
dgx-02
dgx-03
...
dgx-32
EOF

# 2. Run ClusterKit comprehensive test
clusterkit test \
  --hostfile /tmp/hostfile \
  --test-suite production \
  --output-dir /results/clusterkit-$(date +%Y%m%d)

# Test suite options:
#   quick      - Fast sanity check (15 min)
#   standard   - Standard validation (1-2 hours)
#   production - Comprehensive (4-8 hours) ← Use this for certification
#   burn-in    - Extended stress (24+ hours)

# 3. Monitor progress
clusterkit status

# 4. View results
clusterkit report --latest
```

**What ClusterKit Tests:**

```
ClusterKit Test Matrix:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Node Health
   ├── GPU detection
   ├── Driver version consistency
   ├── CUDA library validation
   ├── DCGM health check
   └── Memory tests

2. Network Connectivity
   ├── InfiniBand fabric validation
   ├── Network topology verification
   ├── Switch connectivity
   └── MPI job launch test

3. Performance Baseline
   ├── Single-node HPL
   ├── Single-node NCCL
   ├── Inter-node NCCL
   └── Storage bandwidth

4. Cluster Software
   ├── Slurm scheduler
   ├── Container runtime
   ├── NGC CLI
   └── Shared filesystem access

5. Integration Tests
   ├── Multi-node job submission
   ├── GPU allocation
   ├── Network performance under load
   └── Storage concurrent access
```

**Sample ClusterKit Report:**

```
================================================================================
ClusterKit Validation Report
Generated: 2026-01-03 14:30:00
Cluster: Production-AI-Cluster-01
Nodes Tested: 32
================================================================================

OVERALL STATUS: PASS (with 2 warnings)

Summary:
--------
Total Tests:        1,248
Passed:            1,244
Failed:                2
Warnings:              2
Skipped:               0

Pass Rate: 99.7%

Node Status:
------------
+----------+--------+----------+---------+
| Node     | Status | Tests    | Issues  |
+----------+--------+----------+---------+
| dgx-01   | PASS   | 39/39    | 0       |
| dgx-02   | PASS   | 39/39    | 0       |
| dgx-03   | WARN   | 38/39    | 1       |
...
| dgx-15   | FAIL   | 37/39    | 2       |
...
| dgx-32   | PASS   | 39/39    | 0       |
+----------+--------+----------+---------+

Failed Tests:
-------------
1. dgx-15: NVLink bandwidth degraded
   - GPU 3 → GPU 5: 450 GB/s (expected 900 GB/s)
   - Action: Replace NVLink cable

2. dgx-15: InfiniBand link errors
   - Port 1: Symbol errors detected (234 errors)
   - Action: Reseat or replace IB cable

Warnings:
---------
1. dgx-03: Slight temperature elevation
   - GPU 7: Peak 81°C (threshold: 80°C)
   - Action: Monitor, verify airflow

2. dgx-03: Single-bit ECC errors
   - GPU 7: 45 single-bit errors
   - Action: Monitor, consider GPU replacement if errors increase

Network Performance:
--------------------
East-West Bandwidth (NCCL All-Reduce):
  2-node:  ~190 GB/s per node ✓
  4-node:  ~185 GB/s per node ✓
  8-node:  ~180 GB/s per node ✓
  16-node: ~175 GB/s per node ✓
  32-node: ~170 GB/s per node ✓

Storage Performance:
--------------------
Sequential Read:   45 GB/s ✓
Sequential Write:  38 GB/s ✓
Random Read (4K):  2.1M IOPS ✓
Random Write (4K): 1.8M IOPS ✓

Cluster Software:
-----------------
Slurm:        PASS (all nodes responding)
Docker:       PASS (runtime functional)
NGC:          PASS (CLI accessible)
Filesystem:   PASS (all mounts present)

================================================================================
RECOMMENDATIONS:
1. Fix dgx-15 NVLink issue (CRITICAL)
2. Fix dgx-15 IB link errors (CRITICAL)
3. Monitor dgx-03 GPU 7 temperature
4. Schedule dgx-03 GPU 7 replacement if ECC errors increase

CLUSTER READY FOR PRODUCTION: NO
Blocking Issues: 2 (dgx-15 requires maintenance)

After fixing dgx-15, cluster will be ready for Phase 4 burn-in testing.
================================================================================
```

---

### 10 Run NCCL to Verify E/W Fabric Bandwidth

**Purpose:** Validate East-West (node-to-node) network performance for distributed training

**What is East-West Fabric?**
- Horizontal communication between compute nodes
- Critical for: Distributed AI training (model parallelism, data parallelism)
- Uses: InfiniBand or high-speed Ethernet (RoCE)

**Command Sequence:**

```bash
# 1. Multi-node NCCL test via Slurm

# Test 2 nodes (16 GPUs total)
srun -N 2 --ntasks-per-node=8 \
  --mpi=pmix \
  --container-image=nvcr.io/nvidia/pytorch:24.12-py3 \
  /workspace/nccl-tests/build/all_reduce_perf -b 8 -e 8G -f 2 -g 8

# Test 4 nodes (32 GPUs total)
srun -N 4 --ntasks-per-node=8 \
  --mpi=pmix \
  --container-image=nvcr.io/nvidia/pytorch:24.12-py3 \
  /workspace/nccl-tests/build/all_reduce_perf -b 8 -e 8G -f 2 -g 8

# Test 8 nodes (64 GPUs total)
srun -N 8 --ntasks-per-node=8 \
  --mpi=pmix \
  --container-image=nvcr.io/nvidia/pytorch:24.12-py3 \
  /workspace/nccl-tests/build/all_reduce_perf -b 8 -e 8G -f 2 -g 8

# Test full cluster (all nodes)
srun -N 32 --ntasks-per-node=8 \
  --mpi=pmix \
  --container-image=nvcr.io/nvidia/pytorch:24.12-py3 \
  /workspace/nccl-tests/build/all_reduce_perf -b 8 -e 8G -f 2 -g 8
```

**Expected Performance:**

```
Network Performance Targets (DGX H100 with 400G IB):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Node Config   │ Expected Bus BW │ Expected Alg BW │ Status
──────────────┼─────────────────┼─────────────────┼────────
2 nodes       │ ~190 GB/s       │ ~24 GB/s        │ Target
4 nodes       │ ~185 GB/s       │ ~23 GB/s        │ Target
8 nodes       │ ~180 GB/s       │ ~22 GB/s        │ Target
16 nodes      │ ~175 GB/s       │ ~21 GB/s        │ Target
32+ nodes     │ ~170 GB/s       │ ~20 GB/s        │ Target

Why bandwidth decreases with more nodes:
  - More hops through network fabric
  - Increased congestion
  - Tree algorithm overhead
  - This is normal and expected!
```

**Sample Multi-Node NCCL Output:**

```
# nccl-tests: 32 nodes, 256 GPUs total

# Using devices across 32 nodes
#  Rank  0 on dgx-01 device  0 [0x17] NVIDIA H100 80GB HBM3
#  Rank  1 on dgx-01 device  1 [0x65] NVIDIA H100 80GB HBM3
   ...
#  Rank  255 on dgx-32 device  7 [0xd6] NVIDIA H100 80GB HBM3

#                                                              out-of-place                       
#       size         count      type   redop    root     time   algbw   busbw #wrong     
#        (B)    (elements)                               (us)  (GB/s)  (GB/s)            
   ...
  1073741824     268435456     float     sum      -1  52456.3   20.47  170.82      0
  2147483648     536870912     float     sum      -1 104523.7   20.54  171.40      0
  4294967296    1073741824     float     sum      -1 208734.2   20.57  171.65      0
  8589934592    2147483648     float     sum      -1 417289.5   20.58  171.72      0
# Out of bounds values : 0 OK
# Avg bus bandwidth    : 171.65 GB/s
```

**Success Criteria:**
- ✅ Bus bandwidth ≥160 GB/s for 32-node cluster
- ✅ Bandwidth scales reasonably with node count
- ✅ #wrong = 0 (no data corruption)
- ✅ All ranks complete successfully
- ✅ No MPI errors or timeouts

---

## PHASE 4: Burn-In & Production Readiness

### Goal: Extended stress testing to ensure long-term stability

---

### 11 Perform NCCL Burn-In

**Purpose:** Extended multi-node communication stress test

**Command:**

```bash
# Run NCCL all-reduce for extended period (8-24 hours)
srun -N 32 --ntasks-per-node=8 \
  --time=24:00:00 \
  --container-image=nvcr.io/nvidia/pytorch:24.12-py3 \
  /workspace/nccl-tests/build/all_reduce_perf \
  -b 1G -e 8G -f 2 -g 8 -n 10000

# -n 10000: Run 10,000 iterations (continuous stress)
```

**Monitors During Burn-In:**
```bash
# In separate terminals:

# 1. Monitor GPU temps/power
watch -n 5 'srun -N 32 nvidia-smi --query-gpu=temperature.gpu,power.draw --format=csv'

# 2. Monitor network errors
watch -n 10 'ibcheckerrors'

# 3. Monitor job status
watch -n 30 'squeue'
```

**Success:** 24-hour run completes with 0 errors

---

### 12 Perform HPL Burn-In

**Purpose:** Extended compute stress across entire cluster

**Command:**

```bash
# Run HPL on full cluster for 24 hours
srun -N 32 --ntasks-per-node=8 \
  --time=24:00:00 \
  --container-image=nvcr.io/nvidia/hpc-benchmarks:latest \
  hpl.sh --dat /workspace/HPL-32node.dat

# HPL will continuously solve large matrix problems
```

**Success:** Consistent TFLOPS performance, no crashes, PASSED residual checks

---

### 13 Perform NeMo Burn-In

**Purpose:** Real AI workload validation

**Command:**

```bash
# Run LLM training for extended period
srun -N 32 --ntasks-per-node=8 \
  --time=24:00:00 \
  --container-image=nvcr.io/nvidia/nemo:24.12 \
  python -m torch.distributed.run \
  --nproc_per_node=8 \
  --nnodes=32 \
  train_gpt.py --config gpt3-175b.yaml

# This simulates real production workload
```

**Success:** Training progresses smoothly, loss decreases, no crashes

---

### 14 Test Storage

**Purpose:** Validate storage performance for AI datasets

**Command Sequence:**

```bash
# 1. Sequential read test
fio --name=seq-read \
    --rw=read \
    --bs=1M \
    --size=100G \
    --numjobs=32 \
    --group_reporting

# Expected: >40 GB/s aggregate

# 2. Sequential write test
fio --name=seq-write \
    --rw=write \
    --bs=1M \
    --size=100G \
    --numjobs=32 \
    --group_reporting

# Expected: >35 GB/s aggregate

# 3. Random read (dataset loading simulation)
fio --name=rand-read \
    --rw=randread \
    --bs=4K \
    --size=100G \
    --numjobs=32 \
    --group_reporting

# Expected: >2M IOPS

# 4. Multi-node concurrent access
srun -N 32 fio --name=multi-node-read \
    --rw=read \
    --bs=1M \
    --size=10G \
    --numjobs=8
```

**Success Criteria:**
- ✅ Meets or exceeds performance targets
- ✅ No I/O errors
- ✅ Consistent performance across nodes
- ✅ Filesystem metadata operations responsive

---

## Final Validation Checklist

Before declaring cluster production-ready:

```
✅ Phase 1: Single-Node Validation
   ✅ All nodes passed DCGM Level 3
   ✅ All nodes passed HPL
   ✅ All nodes passed single-node NCCL
   
✅ Phase 2: Infrastructure Validation
   ✅ All cables pass signal quality test
   ✅ Cabling matches design topology
   ✅ Switch firmware/software certified versions
   ✅ BlueField DPU firmware correct
   ✅ Transceiver firmware validated
   
✅ Phase 3: Cluster Integration
   ✅ ClusterKit comprehensive test PASS
   ✅ Multi-node NCCL meets bandwidth targets
   
✅ Phase 4: Burn-In Testing
   ✅ 24-hour NCCL burn-in completed (0 errors)
   ✅ 24-hour HPL burn-in completed (consistent performance)
   ✅ 24-hour NeMo burn-in completed (training progressed)
   ✅ Storage performance validated
   
✅ Documentation
   ✅ All test results archived
   ✅ Any failures documented with resolution
   ✅ Performance baselines recorded
   ✅ Configuration management database updated
   
🎯 CLUSTER STATUS: PRODUCTION READY
```

---

## Troubleshooting Decision Tree

```
Issue Detected During Validation
         ↓
    Is it a single node?
         ├── YES → Isolate node, run Phase 1 tests
         │         ├── DCGM FAIL → Hardware issue (Section 5.1-5.3)
         │         ├── HPL FAIL → Check thermals/memory
         │         └── NCCL FAIL → NVLink problem
         │
         └── NO → Multiple nodes affected?
                   ├── YES → Infrastructure problem
                   │         ├── Network errors → Section 4.4-4.6
                   │         ├── Performance degradation → Check switches
                   │         └── Intermittent → Cable quality (Section 4.4)
                   │
                   └── Cluster-wide → Configuration issue
                                     ├── Check software versions (3.1-3.7)
                                     ├── Verify cluster config (BCM/Slurm)
                                     └── Review storage settings (4.14)
```

---
