1) NVIDIA-SMI
a)nvidia-smi
```
shadeform@brev-7hpnmoj9o:~$ nvidia-smi
Mon Jun 15 02:50:06 2026       
+---------------------------------------------------------------------------------------+
| NVIDIA-SMI 535.161.08             Driver Version: 535.161.08   CUDA Version: 12.2     |
|-----------------------------------------+----------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
|                                         |                      |               MIG M. |
|=========================================+======================+======================|
|   0  NVIDIA A100-SXM4-40GB          On  | 00000000:0A:00.0 Off |                    0 |
| N/A   47C    P0              58W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   1  NVIDIA A100-SXM4-40GB          On  | 00000000:0B:00.0 Off |                    0 |
| N/A   48C    P0              57W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   2  NVIDIA A100-SXM4-40GB          On  | 00000000:0C:00.0 Off |                    0 |
| N/A   46C    P0              62W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   3  NVIDIA A100-SXM4-40GB          On  | 00000000:0D:00.0 Off |                    0 |
| N/A   47C    P0              60W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   4  NVIDIA A100-SXM4-40GB          On  | 00000000:0E:00.0 Off |                    0 |
| N/A   49C    P0              66W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   5  NVIDIA A100-SXM4-40GB          On  | 00000000:0F:00.0 Off |                    0 |
| N/A   51C    P0              72W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   6  NVIDIA A100-SXM4-40GB          On  | 00000000:10:00.0 Off |                    0 |
| N/A   48C    P0              64W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
|   7  NVIDIA A100-SXM4-40GB          On  | 00000000:11:00.0 Off |                    0 |
| N/A   45C    P0              57W / 400W |      0MiB / 40960MiB |      0%      Default |
|                                         |                      |             Disabled |
+-----------------------------------------+----------------------+----------------------+
                                                                                         
+---------------------------------------------------------------------------------------+
| Processes:                                                                            |
|  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
|        ID   ID                                                             Usage      |
|=======================================================================================|
|  No running processes found                                                           |
+---------------------------------------------------------------------------------------+
```

b) nvidia-smi topo -m
```
nvidia-smi topo -m
	GPU0	GPU1	GPU2	GPU3	GPU4	GPU5	GPU6	GPU7	NIC0	NIC1	NIC2	NIC3	NIC4	NIC5	NIC6	NIC7	CPU Affinity	NUMA Affinity	GPU NUMA ID
GPU0	 X 	NV12	NV12	NV12	NV12	NV12	NV12	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU1	NV12	 X 	NV12	NV12	NV12	NV12	NV12	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU2	NV12	NV12	 X 	NV12	NV12	NV12	NV12	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU3	NV12	NV12	NV12	 X 	NV12	NV12	NV12	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU4	NV12	NV12	NV12	NV12	 X 	NV12	NV12	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU5	NV12	NV12	NV12	NV12	NV12	 X 	NV12	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU6	NV12	NV12	NV12	NV12	NV12	NV12	 X 	NV12	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
GPU7	NV12	NV12	NV12	NV12	NV12	NV12	NV12	 X 	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PH0-115	0-3		N/A
NIC0	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB	PHB	PHB	PHB	PHB	PHB	PHB
NIC1	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB	PHB	PHB	PHB	PHB	PHB
NIC2	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB	PHB	PHB	PHB	PHB
NIC3	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB	PHB	PHB	PHB
NIC4	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB	PHB	PHB
NIC5	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB	PHB
NIC6	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 	PHB
NIC7	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	PHB	 X 

Legend:

  X    = Self
  SYS  = Connection traversing PCIe as well as the SMP interconnect between NUMA nodes (e.g., QPI/UPI)
  NODE = Connection traversing PCIe as well as the interconnect between PCIe Host Bridges within a NUMA node
  PHB  = Connection traversing PCIe as well as a PCIe Host Bridge (typically the CPU)
  PXB  = Connection traversing multiple PCIe bridges (without traversing the PCIe Host Bridge)
  PIX  = Connection traversing at most a single PCIe bridge
  NV#  = Connection traversing a bonded set of # NVLinks

NIC Legend:

  NIC0: mlx5_0
  NIC1: mlx5_1
  NIC2: mlx5_2
  NIC3: mlx5_3
  NIC4: mlx5_4
  NIC5: mlx5_5
  NIC6: mlx5_6
  NIC7: mlx5_7
```

c) nvidia-smi nvlink -s -i 0
```
shadeform@brev-7hpnmoj9o:~$ nvidia-smi nvlink -s -i 0
GPU 0: NVIDIA A100-SXM4-40GB (UUID: GPU-fde0a018-ad1a-bbec-ccf6-50a9f64bd178)
	 Link 0: 25 GB/s
	 Link 1: 25 GB/s
	 Link 2: 25 GB/s
	 Link 3: 25 GB/s
	 Link 4: 25 GB/s
	 Link 5: 25 GB/s
	 Link 6: 25 GB/s
	 Link 7: 25 GB/s
	 Link 8: 25 GB/s
	 Link 9: 25 GB/s
	 Link 10: 25 GB/s
	 Link 11: 25 GB/s

```

d) nvidia-smi nvlink -e -i $i
```
for i in $(seq 0 7); do
  echo "=== GPU $i NVLink Errors ==="
  nvidia-smi nvlink -e -i $i
done
=== GPU 0 NVLink Errors ===
GPU 0: NVIDIA A100-SXM4-40GB (UUID: GPU-fde0a018-ad1a-bbec-ccf6-50a9f64bd178)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 1 NVLink Errors ===
GPU 1: NVIDIA A100-SXM4-40GB (UUID: GPU-264fc0d9-c23f-c1eb-4fc3-40237af3cebc)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 2 NVLink Errors ===
GPU 2: NVIDIA A100-SXM4-40GB (UUID: GPU-0cc8109e-9c4f-eb6f-9379-df66f71f032c)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 3 NVLink Errors ===
GPU 3: NVIDIA A100-SXM4-40GB (UUID: GPU-46a33459-81fa-9dcf-9ed9-9a9425a4abf5)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 4 NVLink Errors ===
GPU 4: NVIDIA A100-SXM4-40GB (UUID: GPU-578ff5a4-ba53-9afa-62a7-0f5fa921b3b7)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 5 NVLink Errors ===
GPU 5: NVIDIA A100-SXM4-40GB (UUID: GPU-a049b8b0-031a-a816-36af-036fbb15fa9b)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 6 NVLink Errors ===
GPU 6: NVIDIA A100-SXM4-40GB (UUID: GPU-36aca86d-d88e-2763-af0f-7844243707f4)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

=== GPU 7 NVLink Errors ===
GPU 7: NVIDIA A100-SXM4-40GB (UUID: GPU-63a54e17-d900-3b99-c42a-4506beaaa446)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
	 Link 1: Recovery Errors: 0
	 Link 1: CRC Errors: 0

	 Link 2: Replay Errors: 0
	 Link 2: Recovery Errors: 0
	 Link 2: CRC Errors: 0

	 Link 3: Replay Errors: 0
	 Link 3: Recovery Errors: 0
	 Link 3: CRC Errors: 0

	 Link 4: Replay Errors: 0
	 Link 4: Recovery Errors: 0
	 Link 4: CRC Errors: 0

	 Link 5: Replay Errors: 0
	 Link 5: Recovery Errors: 0
	 Link 5: CRC Errors: 0

	 Link 6: Replay Errors: 0
	 Link 6: Recovery Errors: 0
	 Link 6: CRC Errors: 0

	 Link 7: Replay Errors: 0
	 Link 7: Recovery Errors: 0
	 Link 7: CRC Errors: 0

	 Link 8: Replay Errors: 0
	 Link 8: Recovery Errors: 0
	 Link 8: CRC Errors: 0

	 Link 9: Replay Errors: 0
	 Link 9: Recovery Errors: 0
	 Link 9: CRC Errors: 0

	 Link 10: Replay Errors: 0
	 Link 10: Recovery Errors: 0
	 Link 10: CRC Errors: 0

	 Link 11: Replay Errors: 0
	 Link 11: Recovery Errors: 0
	 Link 11: CRC Errors: 0

```
e) nvidia-smi -q -d ECC
```
nvidia-smi -q -d ECC

==============NVSMI LOG==============

Timestamp                                 : Mon Jun 15 02:56:17 2026
Driver Version                            : 535.161.08
CUDA Version                              : 12.2

Attached GPUs                             : 8
GPU 00000000:0A:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:0B:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 87
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:0C:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:0D:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:0E:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:0F:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:10:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

GPU 00000000:11:00.0
    ECC Mode
        Current                           : Enabled
        Pending                           : Enabled
    ECC Errors
        Volatile
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
        Aggregate
            SRAM Correctable              : 0
            SRAM Uncorrectable Parity     : 0
            SRAM Uncorrectable SEC-DED    : 0
            DRAM Correctable              : 0
            DRAM Uncorrectable            : 0
            SRAM Threshold Exceeded       : No
        Aggregate Uncorrectable SRAM Sources
            SRAM L2                       : 0
            SRAM SM                       : 0
            SRAM Microcontroller          : 0
            SRAM PCIE                     : 0
            SRAM Other                    : 0

```

2) DCGMI
a) dcgmi dmon -e 150,155,156,203,252
```
shadeform@brev-7hpnmoj9o:~$ dcgmi dmon -e 150,155,156,203,252
#Entity   TMPTR        POWER             TOTEC                   GPUTL             FBUSD             
ID         C            W                 mJ                                                         
GPU 7     45           57.430            108702777               0                 0                 
GPU 6     48           64.237            121075349               0                 0                 
GPU 5     51           72.371            136324526               0                 0                 
GPU 4     49           66.667            125834493               0                 0                 
GPU 3     47           60.035            113483247               0                 0                 
GPU 2     46           62.356            117755182               0                 0                 
GPU 1     48           57.430            109018692               0                 0                 
GPU 0     47           58.490            110887367               0                 0                 
GPU 7     45           57.430            108760502               0                 0                 
GPU 6     48           64.237            121140022               0                 0                 
GPU 5     51           72.371            136397252               0                 0                 
GPU 4     49           66.667            125901422               0                 0                 
GPU 3     47           59.699            113543469               0                 0                 
GPU 2     46           62.356            117817878               0                 0                 
GPU 1     48           57.430            109076423               0                 0                 
GPU 0     47           58.490            110946157               0                 0                 
GPU 7     45           57.489            108760502               0                 0                 
GPU 6     48           64.237            121204519               0                 0                 
GPU 5     51           72.643            136469953               0                 0                 
GPU 4     49           66.667            125968390               0                 0                 
GPU 3     47           60.035            113603636               0                 0                 
GPU 2     46           62.356            117880535               0                 0                 
GPU 1     48           57.430            109134129               0                 0                 
GPU 0     47           58.490            111004945               0                 0                 
GPU 7     45           57.489            108818180               0                 0                 
GPU 6     48           64.237            121204519               0                 0                 
GPU 5     51           72.643            136469953               0                 0                 
GPU 4     49           66.667            125968390               0                 0                 
GPU 3     47           60.035            113603636               0                 0                 
GPU 2     46           62.356            117880535               0                 0                 
GPU 1     48           57.430            109134129               0                 0                 
GPU 0     47           66.181            111004945               0                 0                 
GPU 7     45           57.489            108916255               0                 0                 
GPU 6     48           64.237            121314310               0                 0                 
GPU 5     51           72.371            136593496               0                 0                 
GPU 4     49           66.667            126082222               0                 0                 
GPU 3     47           60.035            113724490               0                 0                 
GPU 2     46           62.954            117987823               0                 0                 
GPU 1     48           57.430            109235191               0                 0                 
GPU 0     47           66.181            111109281               0                 0                 
GPU 7     45           57.489            108916255               0                 0                 
GPU 6     48           64.237            121314310               0                 0                 
GPU 5     51           72.371            136593496               0                 0                 
GPU 4     49           82.641            126082222               0                 0                 
GPU 3     48           73.017            113724490               0                 0                 
GPU 2     46           67.060            117987823               0                 0                 
GPU 1     48           62.692            109235191               0                 0                            
```

3) ibstat
```
CA 'mlx5_0'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x1070fd0300a41f36
	System image GUID: 0x1070fd0300a41f36
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 176
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x1070fd0300a41f36
		Link layer: InfiniBand
CA 'mlx5_1'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x1070fd0300a41ec2
	System image GUID: 0x1070fd0300a41ec2
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 89
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x1070fd0300a41ec2
		Link layer: InfiniBand
CA 'mlx5_2'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x08c0eb03005d3de4
	System image GUID: 0x08c0eb03005d3de4
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 105
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x08c0eb03005d3de4
		Link layer: InfiniBand
CA 'mlx5_3'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x1070fd0300a4110a
	System image GUID: 0x1070fd0300a4110a
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 163
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x1070fd0300a4110a
		Link layer: InfiniBand
CA 'mlx5_4'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x08c0eb0300523a38
	System image GUID: 0x08c0eb0300523a38
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 168
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x08c0eb0300523a38
		Link layer: InfiniBand
CA 'mlx5_5'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x1070fd0300a41106
	System image GUID: 0x1070fd0300a41106
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 3
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x1070fd0300a41106
		Link layer: InfiniBand
CA 'mlx5_6'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x1070fd0300a4103a
	System image GUID: 0x1070fd0300a4103a
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 25
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x1070fd0300a4103a
		Link layer: InfiniBand
CA 'mlx5_7'
	CA type: MT4123
	Number of ports: 1
	Firmware version: 20.36.1010
	Hardware version: 0
	Node GUID: 0x1070fd0300a41eca
	System image GUID: 0x1070fd0300a41eca
	Port 1:
		State: Active
		Physical state: LinkUp
		Rate: 100
		Base lid: 184
		LMC: 0
		SM lid: 104
		Capability mask: 0xa651e848
		Port GUID: 0x1070fd0300a41eca
		Link layer: InfiniBand
```

4)perfquery
```
shadeform@brev-7hpnmoj9o:~/nccl-tests$ sudo perfquery -C mlx5_0 1
# Port counters: Lid 1 port 0 (CapMask: 0x5300)
PortSelect:......................0
CounterSelect:...................0x0000
SymbolErrorCounter:..............0
LinkErrorRecoveryCounter:........0
LinkDownedCounter:...............0
PortRcvErrors:...................0
PortRcvRemotePhysicalErrors:.....0
PortRcvSwitchRelayErrors:........6
PortXmitDiscards:................0
PortXmitConstraintErrors:........0
PortRcvConstraintErrors:.........0
CounterSelect2:..................0x00
LocalLinkIntegrityErrors:........0
ExcessiveBufferOverrunErrors:....0
QP1Dropped:......................0
VL15Dropped:.....................0
PortXmitData:....................50334712
PortRcvData:.....................50322429
PortXmitPkts:....................699290
PortRcvPkts:.....................698925
PortXmitWait:....................0
```

5) mlxlink 
```
shadeform@brev-7hpnmoj9o:~/nccl-tests$ for i in $(seq 0 7); do
  echo "========== mt4123_pciconf$i =========="
  sudo mlxlink -d /dev/mst/mt4123_pciconf$i --show_ber_monitor 2>&1
done
========== mt4123_pciconf0 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf1 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf2 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf3 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf4 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf5 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf6 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA
 
========== mt4123_pciconf7 ==========

Operational Info
----------------
State                           : Active
Physical state                  : LinkUp
Speed                           : IB-HDR
Width                           : 2x
FEC                             : RS-FEC - (544,514) + PLR
Loopback Mode                   : No Loopback
Auto Negotiation                : ON

Supported Info
--------------
Enabled Link Speed              : 0x00000075 (HDR,EDR,FDR,QDR,SDR)
Supported Cable Speed           : 0x0000007f (HDR,EDR,FDR,FDR10,QDR,DDR,SDR)

Troubleshooting Info
--------------------
Status Opcode                   : 0
Group Opcode                    : N/A
Recommendation                  : No issue was observed

Tool Information
----------------
Firmware Version                : 20.36.1010
amBER Version                   : 2.13
MFT Version                     : mft 4.24.0-72
 
-E- "--show_ber_monitor" option is not supported for HCA

shadeform@brev-7hpnmoj9o:~/nccl-tests$ for i in $(seq 0 7); do
  echo "========== mlx5_$i FEC Counters =========="
  sudo mlxlink -d /dev/mst/mt4123_pciconf$i --show_counters 2>&1 | grep -i -E "error|discard|drop|fec|ber|symbol|corrected"
done
========== mlx5_0 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 3183333,242074
Raw Physical BER                : 1E-8
Link Error Recovery Counter     : 0
========== mlx5_1 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 2361678,219959
Raw Physical BER                : 9E-9
Link Error Recovery Counter     : 0
========== mlx5_2 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 10214417,628099
Raw Physical BER                : 3E-8
Link Error Recovery Counter     : 0
========== mlx5_3 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 32379149,224947
Raw Physical BER                : 1E-7
Link Error Recovery Counter     : 0
========== mlx5_4 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 5811465,2509001
Raw Physical BER                : 2E-8
Link Error Recovery Counter     : 0
========== mlx5_5 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 4014318,15682171
Raw Physical BER                : 6E-8
Link Error Recovery Counter     : 0
========== mlx5_6 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 1068084,136509
Raw Physical BER                : 4E-9
Link Error Recovery Counter     : 0
========== mlx5_7 FEC Counters ==========
FEC                             : RS-FEC - (544,514) + PLR
amBER Version                   : 2.13
Physical Counters and BER Info
Symbol Errors                   : 0
Symbol BER                      : 15E-255
Effective Physical Errors       : 0
Effective Physical BER          : 15E-255
Raw Physical Errors Per Lane    : 5015610,1687775
Raw Physical BER                : 2E-8
Link Error Recovery Counter     : 0
shadeform@brev-7hpnmoj9o:~/nccl-tests$ for i in $(seq 0 7); do
  echo "========== GPU $i NVLink Errors =========="
  nvidia-smi nvlink -e -i $i
done
========== GPU 0 NVLink Errors ==========
GPU 0: NVIDIA A100-SXM4-40GB (UUID: GPU-fde0a018-ad1a-bbec-ccf6-50a9f64bd178)
	 Link 0: Replay Errors: 0
	 Link 0: Recovery Errors: 0
	 Link 0: CRC Errors: 0

	 Link 1: Replay Errors: 0
   
```

) LSPCI/LSCPU
```
lspci | grep -i mellanox
12:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
13:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
14:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
15:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
16:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
17:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
18:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
19:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
shadeform@brev-7hpnmoj9o:~$ lspci | grep -i nvidia
0a:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
0b:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
0c:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
0d:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
0e:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
0f:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
10:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
11:00.0 3D controller: NVIDIA Corporation GA100 [A100 SXM4 40GB] (rev a1)
1a:00.0 Bridge: NVIDIA Corporation Device 1af1 (rev a1)
1b:00.0 Bridge: NVIDIA Corporation Device 1af1 (rev a1)
1c:00.0 Bridge: NVIDIA Corporation Device 1af1 (rev a1)
1d:00.0 Bridge: NVIDIA Corporation Device 1af1 (rev a1)
1e:00.0 Bridge: NVIDIA Corporation Device 1af1 (rev a1)
1f:00.0 Bridge: NVIDIA Corporation Device 1af1 (rev a1)
shadeform@brev-7hpnmoj9o:~$ lscpu | grep -E "Socket|NUMA|Core"
Core(s) per socket:                 1
Socket(s):                          116
NUMA node(s):                       4
NUMA node0 CPU(s):                  0-27
NUMA node1 CPU(s):                  28-57
NUMA node2 CPU(s):                  58-87
NUMA node3 CPU(s):                  88-115
```
two nodes
```
root@node-1:/# lspci | grep -i mellanox
0c:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
12:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
4b:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
54:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
61:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
61:00.1 Ethernet controller: Mellanox Technologies MT28908 Family [ConnectX-6]
8d:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
94:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
ba:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
cc:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
e1:00.0 Infiniband controller: Mellanox Technologies MT28908 Family [ConnectX-6]
```

2NODES Command run 
1)
```
root@node-0:/# ib_write_bw -d mlx5_0 -a 10.65.0.3
---------------------------------------------------------------------------------------
                    RDMA_Write BW Test
 Dual-port       : OFF		Device         : mlx5_0
 Number of qps   : 1		Transport type : IB
 Connection type : RC		Using SRQ      : OFF
 PCIe relax order: ON
 ibv_wr* API     : ON
 TX depth        : 128
 CQ Moderation   : 100
 Mtu             : 4096[B]
 Link type       : IB
 Max inline data : 0[B]
 rdma_cm QPs	 : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0x40 QPN 0x038d PSN 0xb5f720 RKey 0x1fffcd VAddr 0x007da37cbc1000
 remote address: LID 0x6e QPN 0x0561 PSN 0xec3d98 RKey 0x1fffce VAddr 0x00773e257be000
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[MB/sec]    BW average[MB/sec]   MsgRate[Mpps]
Conflicting CPU frequency values detected: 3393.665000 != 1500.000000. CPU Frequency is not max.
 2          5000             4.96               4.94   		   2.588087
Conflicting CPU frequency values detected: 3393.696000 != 1500.000000. CPU Frequency is not max.
 4          5000             9.93               9.90   		   2.596330
Conflicting CPU frequency values detected: 3393.677000 != 1500.000000. CPU Frequency is not max.
 8          5000             21.23              21.19  		   2.777945
Conflicting CPU frequency values detected: 3393.671000 != 1500.000000. CPU Frequency is not max.
 16         5000             39.66              39.53  		   2.590839
Conflicting CPU frequency values detected: 3392.633000 != 1500.000000. CPU Frequency is not max.
 32         5000             79.32              79.22  		   2.595942
Conflicting CPU frequency values detected: 3393.676000 != 1500.000000. CPU Frequency is not max.
 64         5000             158.46             158.25 		   2.592846
Conflicting CPU frequency values detected: 3393.685000 != 1500.000000. CPU Frequency is not max.
 128        5000             316.92             315.80 		   2.587063
Conflicting CPU frequency values detected: 3393.652000 != 1500.000000. CPU Frequency is not max.
 256        5000             633.11             632.53 		   2.590858
Conflicting CPU frequency values detected: 3393.699000 != 1500.000000. CPU Frequency is not max.
 512        5000             1256.07            1255.66		   2.571593
Conflicting CPU frequency values detected: 3393.698000 != 1500.000000. CPU Frequency is not max.
 1024       5000             2515.03            2506.75		   2.566911
Conflicting CPU frequency values detected: 3392.609000 != 1500.000000. CPU Frequency is not max.
 2048       5000             4950.58            4939.87		   2.529212
Conflicting CPU frequency values detected: 3393.701000 != 1500.000000. CPU Frequency is not max.
 4096       5000             12938.64            10281.32		   2.632019
Conflicting CPU frequency values detected: 3393.680000 != 1500.000000. CPU Frequency is not max.
 8192       5000             21163.79            17540.85		   2.245229
Conflicting CPU frequency values detected: 3392.600000 != 1500.000000. CPU Frequency is not max.
 16384      5000             23238.21            20503.19		   1.312204
Conflicting CPU frequency values detected: 3393.673000 != 1500.000000. CPU Frequency is not max.
 32768      5000             23299.93            21969.46		   0.703023
Conflicting CPU frequency values detected: 3393.680000 != 1500.000000. CPU Frequency is not max.
 65536      5000             23323.12            22714.61		   0.363434
Conflicting CPU frequency values detected: 3393.682000 != 1500.000000. CPU Frequency is not max.
 131072     5000             23324.96            23105.45		   0.184844
Conflicting CPU frequency values detected: 3393.657000 != 1500.000000. CPU Frequency is not max.
 262144     5000             23163.46            23106.48		   0.092426
Conflicting CPU frequency values detected: 3393.655000 != 1500.000000. CPU Frequency is not max.
 524288     5000             23300.41            23300.33		   0.046601
Conflicting CPU frequency values detected: 3393.700000 != 1500.000000. CPU Frequency is not max.
 1048576    5000             23296.58            23296.34		   0.023296
Conflicting CPU frequency values detected: 3393.692000 != 1500.000000. CPU Frequency is not max.
 2097152    5000             23328.86            23324.61		   0.011662
Conflicting CPU frequency values detected: 3393.675000 != 1500.000000. CPU Frequency is not max.
 4194304    5000             23325.25            23318.75		   0.005830
Conflicting CPU frequency values detected: 3393.702000 != 1500.000000. CPU Frequency is not max.
 8388608    5000             23326.82            23317.65		   0.002915
---------------------------------------------------------------------------------------
```

```
root@node-0:/# ib_write_lat -d mlx5_0 -a 10.65.0.3
---------------------------------------------------------------------------------------
                    RDMA_Write Latency Test
 Dual-port       : OFF		Device         : mlx5_0
 Number of qps   : 1		Transport type : IB
 Connection type : RC		Using SRQ      : OFF
 PCIe relax order: OFF
 ibv_wr* API     : ON
 TX depth        : 1
 Mtu             : 4096[B]
 Link type       : IB
 Max inline data : 220[B]
 rdma_cm QPs	 : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0x40 QPN 0x038e PSN 0x85d384 RKey 0x1812d1 VAddr 0x007a176aa8c000
 remote address: LID 0x6e QPN 0x0562 PSN 0xef405d RKey 0x1832f1 VAddr 0x0073636820b000
---------------------------------------------------------------------------------------
 #bytes #iterations    t_min[usec]    t_max[usec]  t_typical[usec]    t_avg[usec]    t_stdev[usec]   99% percentile[usec]   99.9% percentile[usec] 
Conflicting CPU frequency values detected: 3393.693000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.678000 != 1500.000000. CPU Frequency is not max.
 2       1000          1.79           5.41         1.87     	       1.88        	0.18   		2.03    	5.41   
Conflicting CPU frequency values detected: 3393.644000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.684000 != 1500.000000. CPU Frequency is not max.
 4       1000          1.77           5.14         1.85     	       1.86        	0.14   		2.01    	5.14   
Conflicting CPU frequency values detected: 3376.674000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.676000 != 1500.000000. CPU Frequency is not max.
 8       1000          1.77           4.72         1.88     	       1.88        	0.13   		2.01    	4.72   
Conflicting CPU frequency values detected: 3393.688000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.700000 != 1500.000000. CPU Frequency is not max.
 16      1000          1.80           3.38         1.88     	       1.88        	0.07   		2.04    	3.38   
Conflicting CPU frequency values detected: 3393.698000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.696000 != 1500.000000. CPU Frequency is not max.
 32      1000          1.83           4.03         1.92     	       1.91        	0.07   		2.08    	4.03   
Conflicting CPU frequency values detected: 3393.668000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.686000 != 1500.000000. CPU Frequency is not max.
 64      1000          1.80           4.17         1.91     	       1.90        	0.07   		1.94    	4.17   
Conflicting CPU frequency values detected: 3393.679000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.683000 != 1500.000000. CPU Frequency is not max.
 128     1000          1.88           3.62         1.96     	       1.96        	0.09   		2.00    	3.62   
Conflicting CPU frequency values detected: 3393.674000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3392.604000 != 1500.000000. CPU Frequency is not max.
 256     1000          2.78           4.20         2.87     	       2.86        	0.08   		2.90    	4.20   
Conflicting CPU frequency values detected: 3393.701000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.674000 != 1500.000000. CPU Frequency is not max.
 512     1000          2.87           4.89         2.96     	       2.96        	0.12   		3.13    	4.89   
Conflicting CPU frequency values detected: 3393.679000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.668000 != 1500.000000. CPU Frequency is not max.
 1024    1000          2.96           5.76         3.05     	       3.06        	0.14   		3.38    	5.76   
Conflicting CPU frequency values detected: 3393.670000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.653000 != 1500.000000. CPU Frequency is not max.
 2048    1000          3.11           5.36         3.19     	       3.19        	0.07   		3.32    	5.36   
Conflicting CPU frequency values detected: 3392.620000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.657000 != 1500.000000. CPU Frequency is not max.
 4096    1000          3.74           4.39         3.85     	       3.85        	0.04   		3.93    	4.39   
Conflicting CPU frequency values detected: 3393.682000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.648000 != 1500.000000. CPU Frequency is not max.
 8192    1000          3.67           5.89         4.22     	       4.20        	0.16   		4.53    	5.89   
Conflicting CPU frequency values detected: 3393.694000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.613000 != 1500.000000. CPU Frequency is not max.
 16384   1000          4.27           7.20         4.39     	       4.62        	0.33   		5.05    	7.20   
Conflicting CPU frequency values detected: 3393.657000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3392.617000 != 1500.000000. CPU Frequency is not max.
 32768   1000          5.16           7.58         5.24     	       5.47        	0.42   		6.30    	7.58   
Conflicting CPU frequency values detected: 3393.698000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.670000 != 1500.000000. CPU Frequency is not max.
 65536   1000          6.63           8.33         6.76     	       6.92        	0.47   		8.30    	8.33   
Conflicting CPU frequency values detected: 3393.677000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.695000 != 1500.000000. CPU Frequency is not max.
 131072  1000          9.31           13.25        9.41     	       9.62        	0.65   		11.75   	13.25  
Conflicting CPU frequency values detected: 3393.630000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.655000 != 1500.000000. CPU Frequency is not max.
 262144  1000          14.80          27.40        14.92    	       15.11       	0.81   		18.68   	27.40  
Conflicting CPU frequency values detected: 3393.691000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.697000 != 1500.000000. CPU Frequency is not max.
 524288  1000          25.33          33.24        25.40    	       25.53       	0.88   		32.17   	33.24  
Conflicting CPU frequency values detected: 3393.698000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3392.610000 != 1500.000000. CPU Frequency is not max.
 1048576 1000          46.68          60.92        46.92    	       47.03       	1.13   		49.83   	60.92  
Conflicting CPU frequency values detected: 3393.673000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.701000 != 1500.000000. CPU Frequency is not max.
 2097152 1000          93.19          184.40       93.53    	       93.89       	3.72   		117.23  	184.40 
Conflicting CPU frequency values detected: 3393.693000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3393.654000 != 1500.000000. CPU Frequency is not max.
 4194304 1000          174.57         271.98       175.03   	       176.09      	9.79   		268.49  	271.98 
Conflicting CPU frequency values detected: 3393.684000 != 1500.000000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 3376.697000 != 1500.000000. CPU Frequency is not max.
 8388608 1000          345.23         447.02       345.55   	       348.34      	15.93  		441.71  	447.02 
---------------------------------------------------------------------------------------
```
other node
```
root@node-1:/# ib_write_bw -d mlx5_0 -a

************************************
* Waiting for client to connect... *
************************************
---------------------------------------------------------------------------------------
                    RDMA_Write BW Test
 Dual-port       : OFF		Device         : mlx5_0
 Number of qps   : 1		Transport type : IB
 Connection type : RC		Using SRQ      : OFF
 PCIe relax order: ON
 ibv_wr* API     : ON
 CQ Moderation   : 100
 Mtu             : 4096[B]
 Link type       : IB
 Max inline data : 0[B]
 rdma_cm QPs	 : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0x6e QPN 0x0561 PSN 0xec3d98 RKey 0x1fffce VAddr 0x00773e257be000
 remote address: LID 0x40 QPN 0x038d PSN 0xb5f720 RKey 0x1fffcd VAddr 0x007da37cbc1000
---------------------------------------------------------------------------------------
 #bytes     #iterations    BW peak[MB/sec]    BW average[MB/sec]   MsgRate[Mpps]
 8388608    5000             23326.82            23317.65		   0.002915
---------------------------------------------------------------------------------------
root@node-1:/# ib_write_lat -d mlx5_0 -a

************************************
* Waiting for client to connect... *
************************************
---------------------------------------------------------------------------------------
                    RDMA_Write Latency Test
 Dual-port       : OFF		Device         : mlx5_0
 Number of qps   : 1		Transport type : IB
 Connection type : RC		Using SRQ      : OFF
 PCIe relax order: OFF
 ibv_wr* API     : ON
 Mtu             : 4096[B]
 Link type       : IB
 Max inline data : 220[B]
 rdma_cm QPs	 : OFF
 Data ex. method : Ethernet
---------------------------------------------------------------------------------------
 local address: LID 0x6e QPN 0x0562 PSN 0xef405d RKey 0x1832f1 VAddr 0x0073636820b000
 remote address: LID 0x40 QPN 0x038e PSN 0x85d384 RKey 0x1812d1 VAddr 0x007a176aa8c000
---------------------------------------------------------------------------------------
 #bytes #iterations    t_min[usec]    t_max[usec]  t_typical[usec]    t_avg[usec]    t_stdev[usec]   99% percentile[usec]   99.9% percentile[usec] 
Conflicting CPU frequency values detected: 1500.000000 != 3393.826000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1497.178000 != 3393.830000. CPU Frequency is not max.
 2       1000          1.79           5.36         1.87     	       1.88        	0.19   		2.04    		5.36   
Conflicting CPU frequency values detected: 1496.865000 != 3393.806000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1497.034000 != 3393.857000. CPU Frequency is not max.
 4       1000          1.77           5.32         1.85     	       1.86        	0.17   		1.99    		5.32   
Conflicting CPU frequency values detected: 1492.075000 != 3393.858000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1497.164000 != 3393.823000. CPU Frequency is not max.
 8       1000          1.77           9.58         1.88     	       1.88        	0.16   		2.00    		9.58   
Conflicting CPU frequency values detected: 1492.188000 != 3393.831000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1497.049000 != 3393.820000. CPU Frequency is not max.
 16      1000          1.80           3.39         1.88     	       1.88        	0.07   		2.04    		3.39   
Conflicting CPU frequency values detected: 1497.156000 != 3393.805000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1496.383000 != 3393.844000. CPU Frequency is not max.
 32      1000          1.83           4.27         1.92     	       1.92        	0.09   		2.05    		4.27   
Conflicting CPU frequency values detected: 1496.845000 != 3393.865000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1496.953000 != 3393.820000. CPU Frequency is not max.
 64      1000          1.81           4.33         1.90     	       1.91        	0.10   		1.94    		4.33   
Conflicting CPU frequency values detected: 1500.000000 != 3393.828000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.835000. CPU Frequency is not max.
 128     1000          1.87           3.77         1.96     	       1.96        	0.10   		2.02    		3.77   
Conflicting CPU frequency values detected: 1500.000000 != 3393.837000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.847000. CPU Frequency is not max.
 256     1000          2.79           4.44         2.87     	       2.86        	0.08   		2.90    		4.44   
Conflicting CPU frequency values detected: 1497.075000 != 3393.842000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.844000. CPU Frequency is not max.
 512     1000          2.87           5.65         2.96     	       2.96        	0.13   		3.24    		5.65   
Conflicting CPU frequency values detected: 1500.000000 != 3375.778000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.827000. CPU Frequency is not max.
 1024    1000          2.96           5.72         3.05     	       3.06        	0.16   		3.60    		5.72   
Conflicting CPU frequency values detected: 1500.000000 != 1392.963000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3375.788000. CPU Frequency is not max.
 2048    1000          3.11           5.68         3.19     	       3.20        	0.10   		3.35    		5.68   
Conflicting CPU frequency values detected: 1500.000000 != 3375.759000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.840000. CPU Frequency is not max.
 4096    1000          3.73           4.89         3.85     	       3.85        	0.04   		3.94    		4.89   
Conflicting CPU frequency values detected: 1497.075000 != 3393.838000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.830000. CPU Frequency is not max.
 8192    1000          3.70           5.81         4.22     	       4.20        	0.16   		4.54    		5.81   
Conflicting CPU frequency values detected: 1500.000000 != 3393.817000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.847000. CPU Frequency is not max.
 16384   1000          4.28           7.16         4.39     	       4.62        	0.33   		5.05    		7.16   
Conflicting CPU frequency values detected: 1496.903000 != 3393.826000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1495.581000 != 3393.817000. CPU Frequency is not max.
 32768   1000          5.16           7.56         5.24     	       5.47        	0.43   		6.29    		7.56   
Conflicting CPU frequency values detected: 1500.000000 != 3393.830000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.822000. CPU Frequency is not max.
 65536   1000          6.65           8.33         6.75     	       6.92        	0.47   		8.30    		8.33   
Conflicting CPU frequency values detected: 1500.000000 != 3393.832000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.823000. CPU Frequency is not max.
 131072  1000          9.32           13.26        9.41     	       9.62        	0.65   		11.77   		13.26  
Conflicting CPU frequency values detected: 1500.000000 != 3393.839000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1496.278000 != 3393.807000. CPU Frequency is not max.
 262144  1000          14.81          27.40        14.92    	       15.11       	0.81   		18.69   		27.40  
Conflicting CPU frequency values detected: 1500.000000 != 3393.813000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1495.339000 != 3393.820000. CPU Frequency is not max.
 524288  1000          25.32          33.24        25.40    	       25.54       	0.90   		32.18   		33.24  
Conflicting CPU frequency values detected: 1500.000000 != 3393.847000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.831000. CPU Frequency is not max.
 1048576 1000          46.68          60.99        46.92    	       47.04       	1.19   		49.76   		60.99  
Conflicting CPU frequency values detected: 1417.743000 != 1496.745000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.844000. CPU Frequency is not max.
 2097152 1000          93.15          184.39       93.53    	       93.91       	3.77   		117.14  		184.39 
Conflicting CPU frequency values detected: 1500.000000 != 3393.830000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3375.797000. CPU Frequency is not max.
 4194304 1000          174.71         271.99       175.03   	       176.12      	9.91   		268.54  		271.99 
Conflicting CPU frequency values detected: 1500.000000 != 3393.842000. CPU Frequency is not max.
Conflicting CPU frequency values detected: 1500.000000 != 3393.839000. CPU Frequency is not max.
 8388608 1000          345.22         447.04       345.55   	       348.39      	16.09  		441.72  		447.04 
---------------------------------------------------------------------------------------
```

) ETHTOOL

```
root@node-0:/# ethtool -S eth0 | grep -iE "drop|error|pause|discard"
     rx_queue_0_drops: 0
     rx_queue_0_xdp_drops: 0
     rx_queue_0_xdp_tx_errors: 0
     tx_queue_0_xdp_xmit_errors: 0
```
