Ran on Mac -> refer the DockerFile and Make file in the repo 

# Start a lab session
docker run --rm -it -v ~/hpl-lab/exercises:/workspace hpl-lab

# Create the helper script (first time only)
# See run_hpl.sh in the exercises folder

# Usage
./run_hpl.sh <N> <NB> <P> <Q> [PFACT] [RFACT] [BCAST] [THRESHOLD]

```
sbmhpl-lab%docker build -t hpl-lab .
[+] Building 23.0s (13/13) FINISHED                   docker:desktop-linux
 => [internal] load build definition from Dockerfile                  0.0s
 => => transferring dockerfile: 716B                                  0.0s
 => [internal] load metadata for docker.io/library/ubuntu:22.04       0.4s
 => [internal] load .dockerignore                                     0.0s
 => => transferring context: 2B                                       0.0s
 => CACHED [1/8] FROM docker.io/library/ubuntu:22.04@sha256:4f838adc  0.0s
 => [internal] load build context                                     0.0s
 => => transferring context: 1.41kB                                   0.0s
 => [2/8] RUN apt-get update && apt-get install -y     build-essent  15.3s
 => [3/8] WORKDIR /opt                                                0.0s 
 => [4/8] RUN wget https://www.netlib.org/benchmark/hpl/hpl-2.3.tar.  0.6s 
 => [5/8] COPY Make.linux /opt/hpl-2.3/Make.linux                     0.0s 
 => [6/8] RUN cd /opt/hpl-2.3 && make arch=linux                      5.3s 
 => [7/8] WORKDIR /workspace                                          0.0s 
 => [8/8] RUN cp /opt/hpl-2.3/bin/linux/xhpl /usr/local/bin/xhpl      0.1s 
 => exporting to image                                                1.1s 
 => => exporting layers                                               1.1s 
 => => writing image sha256:90d711c65d4da7f22430ca896a1b9b00b83ff6f5  0.0s 
 => => naming to docker.io/library/hpl-lab                            0.0s 

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/xb89goecpp4q7s6018k4rrr0x

What's next:
    View a summary of image vulnerabilities and recommendations → docker scout quickview 
sbmhpl-lab%docker run --rm -it hpl-lab which xhpl
/usr/local/bin/xhpl
sbmhpl-lab%mkdir -p ~/hpl-lab/exercises
sbmhpl-lab%docker run --rm -it -v ~/hpl-lab/exercises:/workspace hpl-lab
root@3956ac9cd507:/workspace# cat > /workspace/run_hpl.sh << 'SCRIPT'
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
> 
> 
> 
> 
> cat > HPL.dat << EOF                   
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
SCRIPTE "^W|PASSED|FAILED" /tmp/hpl_last.out.out" THRESH=$THRESH"
root@3956ac9cd507:/workspace# chmod +x /workspace/run_hpl.sh
root@3956ac9cd507:/workspace# ls
run_hpl.sh
```

```
root@3956ac9cd507:/workspace# ./run_hpl.sh 1000 128 1 1
==========================================
  N=1000  NB=128  P=1  Q=1  np=1
  PFACT=1  RFACT=1  BCAST=0  THRESH=16.0
==========================================
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark  --   December 2, 2018
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

N      :    1000 
NB     :     128 
PMAP   : Row-major process mapping
P      :       1 
Q      :       1 
PFACT  :   Crout 
NBMIN  :       4 
NDIV   :       2 
RFACT  :   Crout 
BCAST  :   1ring 
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

Column=000000128 Fraction=12.8% Gflops=3.955e+01
Column=000000256 Fraction=25.6% Gflops=3.972e+01
Column=000000384 Fraction=38.4% Gflops=3.944e+01
Column=000000512 Fraction=51.2% Gflops=3.899e+01
Column=000000640 Fraction=64.0% Gflops=3.841e+01
Column=000000768 Fraction=76.8% Gflops=3.752e+01
Column=000000896 Fraction=89.6% Gflops=3.690e+01
================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR10C2C4        1000   128     1     1               0.02             3.6022e+01
HPL_pdgesv() start time Mon May 18 01:10:27 2026

HPL_pdgesv() end time   Mon May 18 01:10:27 2026

--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV-
Max aggregated wall time rfact . . . :               0.00
+ Max aggregated wall time pfact . . :               0.00
+ Max aggregated wall time mxswp . . :               0.00
Max aggregated wall time update  . . :               0.01
+ Max aggregated wall time laswp . . :               0.00
Max aggregated wall time up tr sv  . :               0.00
--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   5.88022081e-03 ...... PASSED
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================

--- SUMMARY ---
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
WR10C2C4        1000   128     1     1               0.02             3.6022e+01
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   5.88022081e-03 ...... PASSED
```

```
./run_hpl.sh 8000 192 2 1 
==========================================
  N=8000  NB=192  P=2  Q=1  np=2
  PFACT=1  RFACT=1  BCAST=0  THRESH=16.0
==========================================
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark  --   December 2, 2018
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

N      :    8000 
NB     :     192 
PMAP   : Row-major process mapping
P      :       2 
Q      :       1 
PFACT  :   Crout 
NBMIN  :       4 
NDIV   :       2 
RFACT  :   Crout 
BCAST  :   1ring 
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

Column=000000192 Fraction= 2.4% Gflops=8.368e+01
Column=000000384 Fraction= 4.8% Gflops=8.226e+01
Column=000000576 Fraction= 7.2% Gflops=8.286e+01
Column=000000768 Fraction= 9.6% Gflops=8.237e+01
Column=000000960 Fraction=12.0% Gflops=8.250e+01
Column=000001152 Fraction=14.4% Gflops=8.231e+01
Column=000001344 Fraction=16.8% Gflops=8.248e+01
Column=000001536 Fraction=19.2% Gflops=8.230e+01
Column=000001728 Fraction=21.6% Gflops=8.244e+01
Column=000001920 Fraction=24.0% Gflops=8.220e+01
Column=000002112 Fraction=26.4% Gflops=8.224e+01
Column=000002304 Fraction=28.8% Gflops=8.203e+01
Column=000002496 Fraction=31.2% Gflops=8.203e+01
Column=000002688 Fraction=33.6% Gflops=8.177e+01
Column=000002880 Fraction=36.0% Gflops=8.178e+01
Column=000003072 Fraction=38.4% Gflops=8.156e+01
Column=000003264 Fraction=40.8% Gflops=8.151e+01
Column=000003456 Fraction=43.2% Gflops=8.131e+01
Column=000003648 Fraction=45.6% Gflops=8.129e+01
Column=000003840 Fraction=48.0% Gflops=8.108e+01
Column=000004032 Fraction=50.4% Gflops=8.103e+01
Column=000004224 Fraction=52.8% Gflops=8.088e+01
Column=000004416 Fraction=55.2% Gflops=8.084e+01
Column=000004608 Fraction=57.6% Gflops=8.065e+01
Column=000004800 Fraction=60.0% Gflops=8.062e+01
Column=000004992 Fraction=62.4% Gflops=8.044e+01
Column=000005184 Fraction=64.8% Gflops=8.039e+01
Column=000005376 Fraction=67.2% Gflops=8.025e+01
Column=000005568 Fraction=69.6% Gflops=8.019e+01
Column=000005760 Fraction=72.0% Gflops=8.009e+01
Column=000005952 Fraction=74.4% Gflops=8.005e+01
Column=000006144 Fraction=76.8% Gflops=7.993e+01
Column=000006336 Fraction=79.2% Gflops=7.991e+01
Column=000006528 Fraction=81.6% Gflops=7.982e+01
Column=000006720 Fraction=84.0% Gflops=7.979e+01
Column=000006912 Fraction=86.4% Gflops=7.972e+01
Column=000007104 Fraction=88.8% Gflops=7.970e+01
Column=000007296 Fraction=91.2% Gflops=7.965e+01
Column=000007488 Fraction=93.6% Gflops=7.963e+01
Column=000007680 Fraction=96.0% Gflops=7.960e+01
Column=000007872 Fraction=98.4% Gflops=7.958e+01
================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR10C2C4        8000   192     2     1               4.30             7.9431e+01
HPL_pdgesv() start time Wed May 20 02:35:38 2026

HPL_pdgesv() end time   Wed May 20 02:35:42 2026

--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV-
Max aggregated wall time rfact . . . :               0.18
+ Max aggregated wall time pfact . . :               0.11
+ Max aggregated wall time mxswp . . :               0.09
Max aggregated wall time update  . . :               4.14
+ Max aggregated wall time laswp . . :               0.25
Max aggregated wall time up tr sv  . :               0.01
--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   4.91833025e-03 ...... PASSED
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================

--- SUMMARY ---
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
WR10C2C4        8000   192     2     1               4.30             7.9431e+01
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   4.91833025e-03 ...... PASSED
root@3956ac9cd507:/workspace# ./run_hpl.sh 8000 192 2 2 
==========================================
  N=8000  NB=192  P=2  Q=2  np=4
  PFACT=1  RFACT=1  BCAST=0  THRESH=16.0
==========================================
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark  --   December 2, 2018
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

N      :    8000 
NB     :     192 
PMAP   : Row-major process mapping
P      :       2 
Q      :       2 
PFACT  :   Crout 
NBMIN  :       4 
NDIV   :       2 
RFACT  :   Crout 
BCAST  :   1ring 
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

Column=000000192 Fraction= 2.4% Gflops=1.286e+02
Column=000000384 Fraction= 4.8% Gflops=1.146e+01
Column=000000576 Fraction= 7.2% Gflops=7.996e+00
Column=000000768 Fraction= 9.6% Gflops=7.218e+00
Column=000000960 Fraction=12.0% Gflops=6.717e+00
Column=000001152 Fraction=14.4% Gflops=6.807e+00
Column=000001344 Fraction=16.8% Gflops=6.412e+00
Column=000001536 Fraction=19.2% Gflops=6.415e+00
Column=000001728 Fraction=21.6% Gflops=6.404e+00
Column=000001920 Fraction=24.0% Gflops=6.436e+00
Column=000002112 Fraction=26.4% Gflops=6.436e+00
Column=000002304 Fraction=28.8% Gflops=6.549e+00
Column=000002496 Fraction=31.2% Gflops=6.245e+00
Column=000002688 Fraction=33.6% Gflops=6.292e+00
Column=000002880 Fraction=36.0% Gflops=6.169e+00
Column=000003072 Fraction=38.4% Gflops=6.136e+00
Column=000003264 Fraction=40.8% Gflops=6.025e+00
Column=000003456 Fraction=43.2% Gflops=6.125e+00
Column=000003648 Fraction=45.6% Gflops=6.105e+00
Column=000003840 Fraction=48.0% Gflops=5.288e+00
Column=000004032 Fraction=50.4% Gflops=4.996e+00
Column=000004224 Fraction=52.8% Gflops=5.035e+00
Column=000004416 Fraction=55.2% Gflops=4.994e+00
Column=000004608 Fraction=57.6% Gflops=4.985e+00
Column=000004800 Fraction=60.0% Gflops=4.879e+00
Column=000004992 Fraction=62.4% Gflops=4.913e+00
Column=000005184 Fraction=64.8% Gflops=4.891e+00
Column=000005376 Fraction=67.2% Gflops=4.893e+00
Column=000005568 Fraction=69.6% Gflops=4.876e+00
Column=000005760 Fraction=72.0% Gflops=4.855e+00
Column=000005952 Fraction=74.4% Gflops=4.749e+00
Column=000006144 Fraction=76.8% Gflops=4.731e+00
Column=000006336 Fraction=79.2% Gflops=4.695e+00
Column=000006528 Fraction=81.6% Gflops=4.643e+00
Column=000006720 Fraction=84.0% Gflops=4.605e+00
Column=000006912 Fraction=86.4% Gflops=4.571e+00
Column=000007104 Fraction=88.8% Gflops=4.531e+00
Column=000007296 Fraction=91.2% Gflops=4.513e+00
Column=000007488 Fraction=93.6% Gflops=4.427e+00
Column=000007680 Fraction=96.0% Gflops=4.408e+00
Column=000007872 Fraction=98.4% Gflops=4.312e+00
================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR10C2C4        8000   192     2     2              82.04             4.1617e+00
HPL_pdgesv() start time Wed May 20 02:36:00 2026

HPL_pdgesv() end time   Wed May 20 02:37:22 2026

--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV-
Max aggregated wall time rfact . . . :              40.94
+ Max aggregated wall time pfact . . :              29.40
+ Max aggregated wall time mxswp . . :              23.75
Max aggregated wall time update  . . :              46.18
+ Max aggregated wall time laswp . . :               3.34
Max aggregated wall time up tr sv  . :               2.69
--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   5.04393380e-03 ...... PASSED
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================

--- SUMMARY ---
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
WR10C2C4        8000   192     2     2              82.04             4.1617e+00
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   5.04393380e-03 ...... PASSED
root@3956ac9cd507:/workspace# ./run_hpl.sh 8000 192 1 4
==========================================
  N=8000  NB=192  P=1  Q=4  np=4
  PFACT=1  RFACT=1  BCAST=0  THRESH=16.0
==========================================
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark  --   December 2, 2018
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

N      :    8000 
NB     :     192 
PMAP   : Row-major process mapping
P      :       1 
Q      :       4 
PFACT  :   Crout 
NBMIN  :       4 
NDIV   :       2 
RFACT  :   Crout 
BCAST  :   1ring 
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

Column=000000192 Fraction= 2.4% Gflops=2.808e+02
Column=000000384 Fraction= 4.8% Gflops=3.913e+01
Column=000000576 Fraction= 7.2% Gflops=2.415e+01
Column=000000768 Fraction= 9.6% Gflops=2.365e+01
Column=000000960 Fraction=12.0% Gflops=2.243e+01
Column=000001152 Fraction=14.4% Gflops=2.145e+01
Column=000001344 Fraction=16.8% Gflops=2.132e+01
Column=000001536 Fraction=19.2% Gflops=2.124e+01
Column=000001728 Fraction=21.6% Gflops=1.971e+01
Column=000001920 Fraction=24.0% Gflops=1.944e+01
Column=000002112 Fraction=26.4% Gflops=1.796e+01
Column=000002304 Fraction=28.8% Gflops=1.759e+01
Column=000002496 Fraction=31.2% Gflops=1.722e+01
Column=000002688 Fraction=33.6% Gflops=1.623e+01
Column=000002880 Fraction=36.0% Gflops=1.598e+01
Column=000003072 Fraction=38.4% Gflops=1.528e+01
Column=000003264 Fraction=40.8% Gflops=1.522e+01
Column=000003456 Fraction=43.2% Gflops=1.526e+01
Column=000003648 Fraction=45.6% Gflops=1.521e+01
Column=000003840 Fraction=48.0% Gflops=1.516e+01
Column=000004032 Fraction=50.4% Gflops=1.485e+01
Column=000004224 Fraction=52.8% Gflops=1.493e+01
Column=000004416 Fraction=55.2% Gflops=1.491e+01
Column=000004608 Fraction=57.6% Gflops=1.478e+01
Column=000004800 Fraction=60.0% Gflops=1.476e+01
Column=000004992 Fraction=62.4% Gflops=1.459e+01
Column=000005184 Fraction=64.8% Gflops=1.175e+01
Column=000005376 Fraction=67.2% Gflops=1.168e+01
Column=000005568 Fraction=69.6% Gflops=1.155e+01
Column=000005760 Fraction=72.0% Gflops=1.157e+01
Column=000005952 Fraction=74.4% Gflops=1.153e+01
Column=000006144 Fraction=76.8% Gflops=1.145e+01
Column=000006336 Fraction=79.2% Gflops=1.065e+01
Column=000006528 Fraction=81.6% Gflops=1.063e+01
Column=000006720 Fraction=84.0% Gflops=1.057e+01
Column=000006912 Fraction=86.4% Gflops=1.056e+01
Column=000007104 Fraction=88.8% Gflops=1.032e+01
Column=000007296 Fraction=91.2% Gflops=1.029e+01
Column=000007488 Fraction=93.6% Gflops=1.021e+01
Column=000007680 Fraction=96.0% Gflops=1.013e+01
Column=000007872 Fraction=98.4% Gflops=1.009e+01
================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR10C2C4        8000   192     1     4              35.37             9.6519e+00
HPL_pdgesv() start time Wed May 20 02:37:33 2026

HPL_pdgesv() end time   Wed May 20 02:38:08 2026

--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV-
Max aggregated wall time rfact . . . :               4.16
+ Max aggregated wall time pfact . . :               1.48
+ Max aggregated wall time mxswp . . :               0.01
Max aggregated wall time update  . . :              32.08
+ Max aggregated wall time laswp . . :              10.16
Max aggregated wall time up tr sv  . :               1.55
--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   4.08738968e-03 ...... PASSED
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================

--- SUMMARY ---
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
WR10C2C4        8000   192     1     4              35.37             9.6519e+00
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   4.08738968e-03 ...... PASSED
root@3956ac9cd507:/workspace# ./run_hpl.sh 8000 192 4 1
==========================================
  N=8000  NB=192  P=4  Q=1  np=4
  PFACT=1  RFACT=1  BCAST=0  THRESH=16.0
==========================================
================================================================================
HPLinpack 2.3  --  High-Performance Linpack benchmark  --   December 2, 2018
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

N      :    8000 
NB     :     192 
PMAP   : Row-major process mapping
P      :       4 
Q      :       1 
PFACT  :   Crout 
NBMIN  :       4 
NDIV   :       2 
RFACT  :   Crout 
BCAST  :   1ring 
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

Column=000000192 Fraction= 2.4% Gflops=3.036e+00
Column=000000384 Fraction= 4.8% Gflops=3.555e+00
Column=000000576 Fraction= 7.2% Gflops=3.981e+00
Column=000000768 Fraction= 9.6% Gflops=3.032e+00
Column=000000960 Fraction=12.0% Gflops=3.385e+00
Column=000001152 Fraction=14.4% Gflops=3.720e+00
Column=000001344 Fraction=16.8% Gflops=3.992e+00
Column=000001536 Fraction=19.2% Gflops=4.226e+00
Column=000001728 Fraction=21.6% Gflops=4.424e+00
Column=000001920 Fraction=24.0% Gflops=4.626e+00
Column=000002112 Fraction=26.4% Gflops=4.510e+00
Column=000002304 Fraction=28.8% Gflops=4.566e+00
Column=000002496 Fraction=31.2% Gflops=4.587e+00
Column=000002688 Fraction=33.6% Gflops=4.598e+00
Column=000002880 Fraction=36.0% Gflops=4.635e+00
Column=000003072 Fraction=38.4% Gflops=4.350e+00
Column=000003264 Fraction=40.8% Gflops=4.276e+00
Column=000003456 Fraction=43.2% Gflops=4.224e+00
Column=000003648 Fraction=45.6% Gflops=4.051e+00
Column=000003840 Fraction=48.0% Gflops=4.068e+00
Column=000004032 Fraction=50.4% Gflops=4.034e+00
Column=000004224 Fraction=52.8% Gflops=4.042e+00
Column=000004416 Fraction=55.2% Gflops=4.026e+00
Column=000004608 Fraction=57.6% Gflops=3.990e+00
Column=000004800 Fraction=60.0% Gflops=3.948e+00
Column=000004992 Fraction=62.4% Gflops=3.925e+00
Column=000005184 Fraction=64.8% Gflops=3.907e+00
Column=000005376 Fraction=67.2% Gflops=3.786e+00
Column=000005568 Fraction=69.6% Gflops=3.700e+00
Column=000005760 Fraction=72.0% Gflops=3.659e+00
Column=000005952 Fraction=74.4% Gflops=3.615e+00
Column=000006144 Fraction=76.8% Gflops=3.535e+00
Column=000006336 Fraction=79.2% Gflops=3.504e+00
Column=000006528 Fraction=81.6% Gflops=3.433e+00
Column=000006720 Fraction=84.0% Gflops=3.416e+00
Column=000006912 Fraction=86.4% Gflops=3.348e+00
Column=000007104 Fraction=88.8% Gflops=3.317e+00
Column=000007296 Fraction=91.2% Gflops=3.279e+00
Column=000007488 Fraction=93.6% Gflops=3.258e+00
Column=000007680 Fraction=96.0% Gflops=3.237e+00
Column=000007872 Fraction=98.4% Gflops=3.229e+00
================================================================================
T/V                N    NB     P     Q               Time                 Gflops
--------------------------------------------------------------------------------
WR10C2C4        8000   192     4     1             109.47             3.1188e+00
HPL_pdgesv() start time Wed May 20 02:38:19 2026

HPL_pdgesv() end time   Wed May 20 02:40:09 2026

--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV--VVV-
Max aggregated wall time rfact . . . :              93.80
+ Max aggregated wall time pfact . . :              65.77
+ Max aggregated wall time mxswp . . :              65.70
Max aggregated wall time update  . . :              14.14
+ Max aggregated wall time laswp . . :               0.78
Max aggregated wall time up tr sv  . :               3.55
--------------------------------------------------------------------------------
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   4.91833025e-03 ...... PASSED
================================================================================

Finished      1 tests with the following results:
              1 tests completed and passed residual checks,
              0 tests completed and failed residual checks,
              0 tests skipped because of illegal input values.
--------------------------------------------------------------------------------

End of Tests.
================================================================================

--- SUMMARY ---
Written by A. Petitet and R. Clint Whaley,  Innovative Computing Laboratory, UTK
WR10C2C4        8000   192     4     1             109.47             3.1188e+00
||Ax-b||_oo/(eps*(||A||_oo*||x||_oo+||b||_oo)*N)=   4.91833025e-03 ...... PASSED
root@3956ac9cd507:/workspace# 

```
