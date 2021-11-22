#include <stdlib.h>
#include <stdio.h>
#include "../common/array.h"


#define MALLOC_CHECK_ERROR(X)({\
    if ((X) == 0){\
        fprintf(stderr, "Malloc error (%s:%d): %i\n", __FILE__, __LINE__, (X));\
        exit(1);\
    }\
})



// initialise a vector of length n with random values.
void init_vec(float *v, int n){
    for(int i = 0; i < n; i++){
        v[i] = rand() % 100 * 0.3234f;
    }
}


// adds two vectors of length n.
void vector_add(float *a, float *b, float *c, int n){
    for(int i = 0; i < n; i++)
        c[i] = a[i] + b[i];
}



int main(void){
    int n = 100;
    float *A = (float*) malloc(n * sizeof(float));
    float *B = (float*) malloc(n * sizeof(float));
    float *C = (float*) malloc(n * sizeof(float));
    MALLOC_CHECK_ERROR(A && B && C);

    init_vec(A, n);
    init_vec(B, n);
    vector_add(A, B, C, n);
    
    printf("Vector A:\n");
    print_array_terse(A, 100, 3);
    printf("Vector B:\n");
    print_array_terse(B, 100, 3);
    printf("Vector C:\n");
    print_array_terse(C, 100, 3);
    free(A);
    free(B);
    free(C); 
    return 0;    
}
