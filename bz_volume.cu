#include <stdio.h>
#include <cuda_runtime.h>

#define NUMS 4900

#define XMIN 0.
#define XMAX 3.
#define YMIN 0.
#define YMAX 3.

#define Z00	0.
#define Z10	1.
#define Z20	0.
#define Z30	0.

#define Z01	1.
#define Z11	6.
#define Z21	1.
#define Z31	0.

#define Z02	0.
#define Z12	1.
#define Z22	0.
#define Z32	4.

#define Z03	3.
#define Z13	2.
#define Z23	3.
#define Z33	3.

__device__ float Height(int iu, int iv);
__device__ float Height(int iu, int iv)// iu,iv = 0 .. NUMS-1
{
	float u = (float)iu / (float)(NUMS - 1);
	float v = (float)iv / (float)(NUMS - 1);

	// the basis functions:

	float bu0 = (1. - u) * (1. - u) * (1. - u);
	float bu1 = 3. * u * (1. - u) * (1. - u);
	float bu2 = 3. * u * u * (1. - u);
	float bu3 = u * u * u;

	float bv0 = (1. - v) * (1. - v) * (1. - v);
	float bv1 = 3. * v * (1. - v) * (1. - v);
	float bv2 = 3. * v * v * (1. - v);
	float bv3 = v * v * v;

	// finally, we get to compute something:

	float height = bu0 * (bv0*Z00 + bv1*Z01 + bv2*Z02 + bv3*Z03)
		+ bu1 * (bv0*Z10 + bv1*Z11 + bv2*Z12 + bv3*Z13)
		+ bu2 * (bv0*Z20 + bv1*Z21 + bv2*Z22 + bv3*Z23)
		+ bu3 * (bv0*Z30 + bv1*Z31 + bv2*Z32 + bv3*Z33);

	return height;
}


__global__ void bezierVolumeKernel(float *dev_volume) {
    extern __shared__ float partialSum[];
    
    unsigned int tid = threadIdx.x;
    unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
    
    float myPartialSum = 0.0f;
    float fullTileArea = (((XMAX - XMIN) / (float)(NUMS - 1))  *  ((YMAX - YMIN) / (float)(NUMS - 1))); // 假設全尺寸格點區域面積為1
    
    if (i < NUMS * NUMS) {
        int iu = i % NUMS;
        int iv = i / NUMS;
        
        // Corner...1/4 Area
        if (((iv == 0) && (iu == 0)) || ((iv == 0) && (iu == (NUMS - 1))) ||
            ((iv == (NUMS - 1)) && (iu == 0)) || ((iv == (NUMS - 1)) && (iu == (NUMS - 1)))) {
            myPartialSum = Height(iu, iv) * 0.25f * fullTileArea;
        }
        // Half size tile
        else if (((iv == 0) && ((iu != 0) || (iu != (NUMS - 1)))) ||
                 ((iv == (NUMS - 1)) && ((iu != 0) || (iu != (NUMS - 1)))) ||
                 ((iu == 0) && ((iv != 0) || (iv != (NUMS - 1)))) ||
                 ((iu == (NUMS - 1)) && ((iv != 0) || (iv != (NUMS - 1))))) {
            myPartialSum = Height(iu, iv) * 0.5f * fullTileArea;
        }
        // Full size tile
        else {
            myPartialSum = Height(iu, iv) * fullTileArea;
        }
        
        partialSum[tid] = myPartialSum;
        __syncthreads();
    }
    
    // 使用平行化減法樹來求和
    unsigned int stride = blockDim.x / 2;
    while (stride > 0) {
        if (tid < stride) {
            partialSum[tid] += partialSum[tid + stride];
        }
        __syncthreads();
        stride /= 2;
    }
    
    if (tid == 0) {
        atomicAdd(dev_volume, partialSum[0]);
    }
}

int main() {

    printf("computing with cuda\n");

    float *dev_volume;
    cudaMalloc(&dev_volume, sizeof(float));
    cudaMemset(dev_volume, 0, sizeof(float));
    
    dim3 blockSize(1024);
    dim3 gridSize((NUMS * NUMS + blockSize.x - 1) / blockSize.x);
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    bezierVolumeKernel<<<gridSize, blockSize, blockSize.x * sizeof(float)>>>(dev_volume);
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop); 
    // Compute execution time
    float gpu_time_use;
    cudaEventElapsedTime(&gpu_time_use, start, stop);
    gpu_time_use = gpu_time_use / 1000.0;

    float volume = 0.0f;
    cudaMemcpy(&volume, dev_volume, sizeof(float), cudaMemcpyDeviceToHost);
    
    printf("Performance = %8.2lf MegaHeights/Sec\n", (NUMS * NUMS) / gpu_time_use / 1000000);
    printf("Total time :%8.4f seconds\n", gpu_time_use);
    printf("Total Volume of bezier surface:  %f\n", volume);
    
    cudaFree(dev_volume);
    
    return 0;
}