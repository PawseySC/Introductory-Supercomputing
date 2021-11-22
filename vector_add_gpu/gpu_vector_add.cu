#include <stdio.h>
#include <stdlib.h>



#define CUDA_CHECK_ERROR(X)({\
    if((X) != cudaSuccess){\
        fprintf(stderr, "CUDA error %d (%s:%d): %s\n", (X),  __FILE__, __LINE__, cudaGetErrorString((cudaError_t)(X)));\
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
    int n = 2000;
    float *A = (float*) malloc(n * sizeof(float));
    float *B = (float*) malloc(n * sizeof(float));
    float *C = (float*) malloc(n * sizeof(float));
    MALLOC_CHECK_ERROR(A && B && C);
    init_vec(A, n);
    init_vec(B, n);
    float *dev_A, *dev_B, *dev_C;
    CUDA_CHECK_ERROR(cudaMalloc(&dev_A, sizeof(float) * n));
    CUDA_CHECK_ERROR(cudaMalloc(&dev_B, sizeof(float) * n));
    CUDA_CHECK_ERROR(cudaMalloc(&dev_C, sizeof(float) * n));
    CUDA_CHECK_ERROR(cudaMemcpy(dev_A, A, sizeof(float) * n, cudaMemcpyHostToDevice));
    CUDA_CHECK_ERROR(cudaMemcpy(dev_B, B, sizeof(float) * n, cudaMemcpyHostToDevice));
    int nThreads = 1024;
    int nBlocks = (n + nThreads - 1) / nThreads;
    vector_add<<<nBlocks, nThreads>>>(dev_A, dev_B, dev_C, n);
    CUDA_CHECK_ERROR((cudaError_t)cudaGetLastError());
    CUDA_CHECK_ERROR(cudaDeviceSynchronize());
    CUDA_CHECK_ERROR(cudaMemcpy(C, dev_C, sizeof(float) * n, cudaMemcpyDeviceToHost));
    CUDA_CHECK_ERROR(cudaDeviceSynchronize());
    
    // check the result is correct
    for(int i = 0; i < n; i++){
        bool sums_equal = compare_float(C[i], A[i] + B[i]);
        if(!sums_equal){
            fprintf(stderr, "Sum is not correct.\n");
            cudaFree(dev_A);
            cudaFree(dev_B);
            cudaFree(dev_C);
            free(A);
            free(B);
            free(C);
            return 1;
        }
    }
    CUDA_CHECK_ERROR(cudaFree(dev_A));
    CUDA_CHECK_ERROR(cudaFree(dev_B));
    CUDA_CHECK_ERROR(cudaFree(dev_C));
    free(A);
    free(B);
    free(C);
    printf("All good.\n");
    return 0;
}
