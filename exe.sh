gcc -o bz_ bz_without_openmp.c
gcc -o bz_with_omp_4 bz_4threads.c -fopenmp
gcc -o bz_with_omp_8 bz_8threads.c -fopenmp
gcc -o bz_with_omp_16 bz_16threads.c -fopenmp
nvcc -o bz_with_cuda bz_volume.cu

./bz_
./bz_with_omp_4
./bz_with_omp_8
./bz_with_omp_16
./bz_with_cuda