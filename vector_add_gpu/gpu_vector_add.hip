#include "hip/hip_runtime.h"
#include <stdio.h>
#include <stdlib.h>



#define HIP_CHECK_ERROR(X)({\
    if((X) != hipSuccess){\
        fprintf(stderr, "HIP error %d (%s:%d): %s\n", (X),  __FILE__, __LINE__, hipGetErrorString((hipError_t)(X)));\
        exit(1);\
    }\
})



#define MALLOC_CHECK_ERROR(X)({\
    if ((X) == 0){\
        fprintf(stderr, "Malloc error (%s:%d): %i\n", __FILE__, __LINE__, (X));\
        exit(1);\
    }\
})


// Returns True if |a - b| <= eps
inline bool compare_float(float a, float b){
    const float eps = 1e-7f;
    if (a  > b) return a - b <= eps;
    else return b - a <= eps;
}



// Initialise the vector v of n elements to random values
void init_vec(float *v, int n){
    for(int i = 0; i < n; i++){
        v[i] = rand() % 100 * 0.3234f;
    }
}


// kernel to perform vector addition
__global__ void vector_add(float *a, float *b, float *c, int n){
    unsigned int i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i < n)
        c[i] = a[i] + b[i];
}



int main(void){
    int n = 2000000;
    float *A = (float*) malloc(n * sizeof(float));
    float *B = (float*) malloc(n * sizeof(float));
    float *C = (float*) malloc(n * sizeof(float));
    MALLOC_CHECK_ERROR(A && B && C);
    init_vec(A, n);
    init_vec(B, n);
    float *dev_A, *dev_B, *dev_C;
    hipEvent_t start, stop;
    HIP_CHECK_ERROR(hipEventCreate(&start));
    HIP_CHECK_ERROR(hipEventCreate(&stop));
    HIP_CHECK_ERROR(hipEventRecord(start));
    HIP_CHECK_ERROR(hipMalloc(&dev_A, sizeof(float) * n));
    HIP_CHECK_ERROR(hipMalloc(&dev_B, sizeof(float) * n));
    HIP_CHECK_ERROR(hipMalloc(&dev_C, sizeof(float) * n));
    HIP_CHECK_ERROR(hipMemcpy(dev_A, A, sizeof(float) * n, hipMemcpyHostToDevice));
    HIP_CHECK_ERROR(hipMemcpy(dev_B, B, sizeof(float) * n, hipMemcpyHostToDevice));
    int nThreads = 1024;
    int nBlocks = (n + nThreads - 1) / nThreads;
    hipLaunchKernelGGL(vector_add, dim3(nBlocks), dim3(nThreads), 0, 0, dev_A, dev_B, dev_C, n);
    HIP_CHECK_ERROR((hipError_t)hipGetLastError());
    HIP_CHECK_ERROR(hipDeviceSynchronize());
    HIP_CHECK_ERROR(hipMemcpy(C, dev_C, sizeof(float) * n, hipMemcpyDeviceToHost));
    HIP_CHECK_ERROR(hipDeviceSynchronize());
    HIP_CHECK_ERROR(hipEventRecord(stop));
    float elapsed;
    HIP_CHECK_ERROR(hipDeviceSynchronize());
    HIP_CHECK_ERROR(hipEventElapsedTime(&elapsed, start, stop));
    printf("GPU computation took %.5f ms\n", elapsed); 
    // check the result is correct
    for(int i = 0; i < n; i++){
        bool sums_equal = compare_float(C[i], A[i] + B[i]);
        if(!sums_equal){
            fprintf(stderr, "Sum is not correct.\n");
            hipFree(dev_A);
            hipFree(dev_B);
            hipFree(dev_C);
            free(A);
            free(B);
            free(C);
            return 1;
        }
    }
    HIP_CHECK_ERROR(hipFree(dev_A));
    HIP_CHECK_ERROR(hipFree(dev_B));
    HIP_CHECK_ERROR(hipFree(dev_C));
    free(A);
    free(B);
    free(C);
    printf("All good.\n");
    return 0;
}
