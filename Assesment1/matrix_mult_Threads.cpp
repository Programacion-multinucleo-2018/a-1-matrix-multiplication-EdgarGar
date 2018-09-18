#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <chrono>
#include <omp.h>

// Uso de OMP
void multiply_matrix_omp(long *matA, long *matB, long *matC, int N) {
    int i = 0;
    #pragma omp parallel for private(i) shared(matA, matB, matC)
    for(i = 0; i<N; i++) {
        for(int j=0; j<N; j++) {
            for(int k=0; k<N; k++) {
                matC[i*N+j] += matA[i*N+k] * matB[j+k*N];
            }
        }
    }
}

//multiplicacion de matrices
void multMatrix(long *matA, long *matB, long *matC, int N) {
    for(int i = 0; i<N; i++) {
        for(int j=0; j<N; j++) {
            for(int k=0; k<N; k++) {
                matC[i*N+j] += matA[i*N+k] * matB[j+k*N];
            }
        }
    }
}

// Comparacion de matrices
void checkResult(long *matrix_a, long *matrix_b, const int N) {
    double epsilon = 1.0E-8;
    bool match = 1;

    for (int i = 0; i < N*N; i++) {
        if (abs(matrix_a[i] - matrix_b[i]) > epsilon) {
            match = 0;
            break;
        }
    }

    if (match)
      printf("Matrix match.\n\n");
    else
      printf("Matrix does not not match.\n\n");
}

int main(int argc, char* argv[]) {
    // Size of matrix
    int N = 1000;
    int bytes = N * N * sizeof(long*);

    // Input matrix pointers
    long* h_A = (long *)malloc(bytes);
    long* h_B = (long *)malloc(bytes);
    long* h_A1 = (long *)malloc(bytes);
    long* h_B2 = (long *)malloc(bytes);

    // Output matrix pointer
    long* h_C = (long *)malloc(bytes);
    long* h_C2 = (long *)malloc(bytes);

    // Initialize matrix
    for(int i = 0; i < N*N; i++ ) {
        h_A[i] = i+1;
        h_A1[i] = i+1;
        h_B[i] = i+1;
        h_B2[i] = i+1;
    }

    // Multiply matrix without threads
    auto start_cpu =  std::chrono::high_resolution_clock::now();
    multMatrix(h_A, h_B, h_C, N);
    auto end_cpu =  std::chrono::high_resolution_clock::now();

    // Measure total time in CPU
    std::chrono::duration<float, std::milli> duration_ms = end_cpu - start_cpu;
    printf("multiply_matrix elapsed %f ms\n", duration_ms.count());

    // Multiply matrix with threads
    start_cpu =  std::chrono::high_resolution_clock::now();
    multiply_matrix_omp(h_A1, h_B2, h_C2, N);
    end_cpu =  std::chrono::high_resolution_clock::now();

    // Measure total time in CPU with threads
    duration_ms = end_cpu - start_cpu;
    printf("multiply_matrix_omp elapsed %f ms\n", duration_ms.count());

    // Check results
    checkResult(h_C, h_C2, N);

    // Free memory
    free(h_A);
    free(h_B);
    free(h_C);
    free(h_A1);
    free(h_B2);
    free(h_C2);

    return 0;
}
