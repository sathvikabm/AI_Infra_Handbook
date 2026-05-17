What is HPL?
HPL (High-Performance Linpack) is a benchmark program that measures how fast a computer cluster can solve a massive system of linear equations. 
It's the classic test used to rank the world's fastest supercomputers on the TOP500 list.

The core idea: take a giant matrix equation Ax = b, factor it into simpler pieces (LU factorization), then solve. 
The bigger the matrix you can solve, and the faster you solve it, the better your score measured in Gflops (billions of floating-point operations per second).
The entire point is to measure how many floating-point operations your machine can do per second (Gflops). The matrix is just the workload, the exercise that makes the machine sweat.

Here's the key insight: HPL is not solving a real scientific problem. Nobody actually needs the answer x. 
The matrix A is randomly generated, b is randomly generated, and the solution x gets thrown away after checking it's correct.
The entire point is to measure how many floating-point operations your machine can do per second (Gflops). The matrix is just the workload — the exercise that makes the machine sweat.
So why vary N? Because the performance number changes with N, and you want the peak performance — the highest Gflops your machine can achieve. Here's why N affects it:
For small N (say 1,000), the matrix fits entirely in cache. Sounds great, but the total work is tiny — about 670 million operations. The overhead of setting up MPI communication, distributing data, and synchronizing processors eats into that small amount of work. Your Gflops number looks bad.
For medium N (say 50,000), you're doing real work — about 83 trillion operations. The communication overhead is now a tiny fraction of total work. Gflops go up.
For the largest N that fits in memory, you get the best ratio of useful work to overhead. That's your peak benchmark number.
But if N is too large and exceeds your RAM, the operating system starts swapping data to disk, and performance collapses.
So the goal is: find the largest N that fits in about 80% of your total RAM, because that gives the highest Gflops.
You test a few values of N near that maximum to confirm you've found the sweet spot.


How We Solve It: The Algorithm

Ax = b 

A is always square in HPL. 
A is N-by-N, x is N-by-1, and b is N-by-1.

The standard method is called LU factorization, and here's the core idea:
Instead of solving Ax equals b directly (which would take forever), you decompose A into two simpler matrices: L and U. 
L is lower triangular (zeros above the diagonal), U is upper triangular (zeros below the diagonal). The magic is that multiplying L times U gives you back A.
Once you have L times U times x equals b, you solve it in two quick steps:
First, solve L times y equals b for y (easy because L is triangular).
Then, solve U times x equals y for x (easy because U is triangular).
Each triangular solve is straightforward — just forward or backward substitution.
The hard part is computing L and U from A. That's where the floating-point operations come from. For an N-by-N matrix, computing the LU factorization involves roughly two-thirds times N cubed operations. 
So if N is 100,000, that's about 660 billion operations. 
At 10 billion operations per second, that's 66 seconds of pure compute.


You're running a standardized stress test on your machine. The workflow is:

1) HPL generates a random N-by-N matrix A and a random vector b.
2) It distributes the data across your P-by-Q grid of processors in blocks of size NB.
3) It performs LU factorization — the heavy computation — measuring how many operations per second it achieves.
4) It solves for x using backward substitution.
5) It regenerates A and b, multiplies A times x, and checks if the result matches b (within floating-point rounding error).
6) It reports the Gflops achieved.



Where Block Size NB Comes In
Now here's the problem: if your computer has a cache (which it does), you want to keep reusing data that's already loaded into fast memory. If you process the matrix one row at a time, you're constantly loading new data.
NB is the block size — the number of rows and columns you process together in one chunk.
When NB is 64, you take a 64-by-64 square of the matrix, load it into cache, and do all your operations on that chunk before moving to the next chunk. This is way faster than processing one row at a time because the CPU doesn't constantly wait for data from main memory.
Typical values: NB is usually between 32 and 256. On modern hardware, 64 or 128 is common.
The tradeoff: if NB is too small, you get poor cache efficiency. If NB is too large, load balancing across processors gets worse (some processors finish their block while others are still working on theirs).
N — The Problem Size
N is the dimension of your matrix. If N equals 10,000, your matrix is 10,000 by 10,000.
Here's the critical insight: bigger N means better performance numbers because you're doing more work per unit of communication overhead.
Imagine sending a message across your network takes 1 millisecond. If your block is tiny, you spend most of your time waiting for messages. If your block is huge, you do billions of operations between messages, so the communication cost becomes negligible.
That's why in the performance tables you saw earlier, the Gflops go up as N increases — the algorithm gets more efficient, not because the hardware got faster, but because the ratio of compute to communication improved.
How do you choose N? The HPL documentation recommends starting with the largest N that fits in your available memory. If you've got 64 gigabytes, and each number in the matrix takes 8 bytes (double precision floating point), you can fit roughly 8 billion numbers. Since the matrix is square, N-squared must be around 8 billion, so N is roughly 90,000.
But here's the practical rule: use about 80 percent of your available memory. This gives you headroom for the operating system and temporary arrays that HPL allocates during the factorization.
P and Q — The Process Grid
Now you've got multiple processors (maybe 256 of them). You can't just give each processor one row — you need a way to divide the work logically.
HPL arranges your P total processors into a P-by-Q grid. If you have 256 processors, you might arrange them as 16-by-16 (so P equals 16 and Q equals 16). Or 8-by-32. Or even 1-by-256 if you wanted (though that's terrible).
Here's why the grid matters: the LU factorization proceeds column by column. In each step:

One column of the processor grid (called the "panel") factors a vertical slice of the matrix.
That column broadcasts the results across rows (horizontally) so all processors get the data they need.
All processors then update their local piece of the matrix in parallel.

If your grid is 1-by-256 (one row, 256 columns), then only one processor is factoring the panel at any given moment. The other 255 are idle. That's horrible — you've got 99.6% idle time.
If your grid is 16-by-16, work is distributed better. The factorization step involves 16 processors working together, and the broadcast happens to 16 processors in parallel.
The rule of thumb: make P and Q roughly equal, or let Q be slightly larger than P. So for 256 processors, 16-by-16 is good. For 128 processors, 8-by-16 beats 4-by-32.

