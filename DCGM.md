```
 dcgmi discovery -l
1 GPU found.
+--------+----------------------------------------------------------------------+
| GPU ID | Device Information                                                   |
+--------+----------------------------------------------------------------------+
| 0      | Name: Tesla V100-PCIE-16GB                                           |
|        | PCI Bus ID: 00000000:60:00.0                                         |
|        | Device UUID: GPU-ef97eb30-627e-f4cd-11b2-37b04ef508ba                |
+--------+----------------------------------------------------------------------+
0 NvSwitches found.
+-----------+
| Switch ID |
+-----------+
+-----------+
0 CPUs found.
+--------+----------------------------------------------------------------------+
| CPU ID | Device Information                                                   |
+--------+----------------------------------------------------------------------+
+--------+----------------------------------------------------------------------+
root@5128e2f4e9d5:/# sudo dcgmi diag -r 1
Successfully ran diagnostic for group.
+---------------------------+------------------------------------------------+
| Diagnostic                | Result                                         |
+===========================+================================================+
|-----  Metadata  ----------+------------------------------------------------|
| DCGM Version              | 3.3.9                                          |
| Driver Version Detected   | 560.35.03                                      |
| GPU Device IDs Detected   | 1db4                                           |
|-----  Deployment  --------+------------------------------------------------|
| Denylist                  | Pass                                           |
| NVML Library              | Pass                                           |
| CUDA Main Library         | Pass                                           |
| Permissions and OS Blocks | Pass                                           |
| Persistence Mode          | Pass                                           |
| Environment Variables     | Pass                                           |
| Page Retirement/Row Remap | Pass                                           |
| Graphics Processes        | Pass                                           |
| Inforom                   | Pass                                           |
+---------------------------+------------------------------------------------+
root@5128e2f4e9d5:/# sudo dcgmi diag -r 2
Successfully ran diagnostic for group.
+---------------------------+------------------------------------------------+
| Diagnostic                | Result                                         |
+===========================+================================================+
|-----  Metadata  ----------+------------------------------------------------|
| DCGM Version              | 3.3.9                                          |
| Driver Version Detected   | 560.35.03                                      |
| GPU Device IDs Detected   | 1db4                                           |
|-----  Deployment  --------+------------------------------------------------|
| Denylist                  | Pass                                           |
| NVML Library              | Pass                                           |
| CUDA Main Library         | Pass                                           |
| Permissions and OS Blocks | Pass                                           |
| Persistence Mode          | Pass                                           |
| Environment Variables     | Pass                                           |
| Page Retirement/Row Remap | Pass                                           |
| Graphics Processes        | Pass                                           |
| Inforom                   | Pass                                           |
+-----  Integration  -------+------------------------------------------------+
| PCIe                      | Pass - All                                     |
+-----  Hardware  ----------+------------------------------------------------+
| GPU Memory                | Pass - All                                     |
+-----  Stress  ------------+------------------------------------------------+
+---------------------------+----------------
```

Lets see the verbose to understand better
```
sudo dcgmi diag -r 2 -v
Successfully ran diagnostic for group.
+---------------------------+------------------------------------------------+
| Diagnostic                | Result                                         |
+===========================+================================================+
|-----  Metadata  ----------+------------------------------------------------|
| DCGM Version              | 3.3.9                                          |
| Driver Version Detected   | 560.35.03                                      |
| GPU Device IDs Detected   | 1db4                                           |
|-----  Deployment  --------+------------------------------------------------|
| Denylist                  | Pass                                           |
| NVML Library              | Pass                                           |
| CUDA Main Library         | Pass                                           |
| Permissions and OS Blocks | Pass                                           |
| Persistence Mode          | Pass                                           |
| Environment Variables     | Pass                                           |
| Page Retirement/Row Remap | Pass                                           |
| Graphics Processes        | Pass                                           |
| Inforom                   | Pass                                           |
+-----  Integration  -------+------------------------------------------------+
| PCIe                      | Pass - All                                     |
| Info                      | GPU 0 GPU to Host bandwidth:  13.13 GB/s, GPU  |
|                           |  0 Host to GPU bandwidth:  12.37 GB/s, GPU 0   |
|                           | bidirectional bandwidth: 22.39 GB/s, GPU 0 GP  |
|                           | U to Host latency:  2.078 us, GPU 0 Host to G  |
|                           | PU latency:  2.211 us, GPU 0 bidirectional la  |
|                           | tency:  3.957 us                               |
+-----  Hardware  ----------+------------------------------------------------+
| GPU Memory                | Pass - All                                     |
| Info                      | GPU 0 Allocated 16435239282 bytes (97.1%)      |
+-----  Stress  ------------+------------------------------------------------+
+---------------------------+------------------------------------------------+
```

dcgmi diag -r 3
```
sudo dcgmi diag -r 3
Successfully ran diagnostic for group.
+---------------------------+------------------------------------------------+
| Diagnostic                | Result                                         |
+===========================+================================================+
|-----  Metadata  ----------+------------------------------------------------|
| DCGM Version              | 3.3.9                                          |
| Driver Version Detected   | 560.35.03                                      |
| GPU Device IDs Detected   | 1db4                                           |
|-----  Deployment  --------+------------------------------------------------|
| Denylist                  | Pass                                           |
| NVML Library              | Pass                                           |
| CUDA Main Library         | Pass                                           |
| Permissions and OS Blocks | Pass                                           |
| Persistence Mode          | Pass                                           |
| Environment Variables     | Pass                                           |
| Page Retirement/Row Remap | Pass                                           |
| Graphics Processes        | Pass                                           |
| Inforom                   | Pass                                           |
+-----  Integration  -------+------------------------------------------------+
| PCIe                      | Pass - All                                     |
+-----  Hardware  ----------+------------------------------------------------+
| GPU Memory                | Pass - All                                     |
| Diagnostic                | Pass - All                                     |
+-----  Stress  ------------+------------------------------------------------+
| Targeted Stress           | Pass - All                                     |
| Targeted Power            | Pass - All                                     |
| Memory Bandwidth          | Pass - All                                     |
| EUD Test                  | Skip - All                                     |
+---------------------------+------------------------------------------------+
```


```
sudo dcgmi diag -r 3 -v
Successfully ran diagnostic for group.
+---------------------------+------------------------------------------------+
| Diagnostic                | Result                                         |
+===========================+================================================+
|-----  Metadata  ----------+------------------------------------------------|
| DCGM Version              | 3.3.9                                          |
| Driver Version Detected   | 560.35.03                                      |
| GPU Device IDs Detected   | 1db4                                           |
|-----  Deployment  --------+------------------------------------------------|
| Denylist                  | Pass                                           |
| NVML Library              | Pass                                           |
| CUDA Main Library         | Pass                                           |
| Permissions and OS Blocks | Pass                                           |
| Persistence Mode          | Pass                                           |
| Environment Variables     | Pass                                           |
| Page Retirement/Row Remap | Pass                                           |
| Graphics Processes        | Pass                                           |
| Inforom                   | Pass                                           |
+-----  Integration  -------+------------------------------------------------+
| PCIe                      | Pass - All                                     |
| Info                      | GPU 0 GPU to Host bandwidth:  13.14 GB/s, GPU  |
|                           |  0 Host to GPU bandwidth:  12.37 GB/s, GPU 0   |
|                           | bidirectional bandwidth: 22.42 GB/s, GPU 0 GP  |
|                           | U to Host latency:  2.028 us, GPU 0 Host to G  |
|                           | PU latency:  2.127 us, GPU 0 bidirectional la  |
|                           | tency:  3.865 us                               |
+-----  Hardware  ----------+------------------------------------------------+
| GPU Memory                | Pass - All                                     |
| Info                      | GPU 0 Allocated 16435239282 bytes (97.1%)      |
| Diagnostic                | Pass - All                                     |
| Info                      | GPU 0 Allocated space for 441 output matricie  |
|                           | s from 14943014092 bytes available., GPU 0 Ru  |
|                           | nning with precisions: FP64 1, FP32 1, FP16 1  |
|                           | , GPU 0 GPU 0 calculated at approximately 216  |
|                           | 88.18 gigaflops during this test               |
+-----  Stress  ------------+------------------------------------------------+
| Targeted Stress           | Pass - All                                     |
| Info                      | GPU 0 GPU 0 relative stress level 1929         |
| Targeted Power            | Pass - All                                     |
| Info                      | GPU 0 GPU 0 max power: 251.0 W average power   |
|                           | usage: 247.8 W                                 |
| Memory Bandwidth          | Pass - All                                     |
| EUD Test                  | Skip - All                                     |
+---------------------------+------------------------------------------------+
root@5128e2f4e9d5:/# 
```



watch with watch -n 1 nvidia-smi on another terminal
wht happened and was noticable evidently was temperature went up and came down 
Persistence-MPwr:Usage/Cap - this also fluctuated 

```
Fri May 22 00:33:23 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-PCIE-16GB           On  |   00000000:60:00.0 Off |                    0 |
| N/A   66C    P0            239W /  250W |   14546MiB /  16384MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
+-----------------------------------------------------------------------------------------+

Fri May 22 00:33:41 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-PCIE-16GB           On  |   00000000:60:00.0 Off |                    0 |
| N/A   73C    P0            232W /  250W |   14546MiB /  16384MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
+-----------------------------------------------------------------------------------------+

Fri May 22 00:34:39 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-PCIE-16GB           On  |   00000000:60:00.0 Off |                    0 |
| N/A   70C    P0            225W /  250W |   14546MiB /  16384MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
+-----------------------------------------------------------------------------------------+

Fri May 22 00:36:52 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-PCIE-16GB           On  |   00000000:60:00.0 Off |                    0 |
| N/A   60C    P0            247W /  250W |    9538MiB /  16384MiB |    100%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
+-----------------------------------------------------------------------------------------+

Fri May 22 00:39:33 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  Tesla V100-PCIE-16GB           On  |   00000000:60:00.0 Off |                    0 |
| N/A   39C    P0             27W /  250W |       1MiB /  16384MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found            



