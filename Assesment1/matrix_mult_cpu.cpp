//Para ayuda de este programa se consulto el siguiente libro Professional programing for cudaFree
//http://www.hds.bme.hu/~fhegedus/C++/Professional%20CUDA%20C%20Programming.pdf
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <chrono>

using namespace std;


/*void sumMatrixOnHost(long *A, long *B, long *C, const int nx,
                     const int ny)
{
    long *ia = A;
    long *ib = B;
    long *ic = C;

    for (int iy = 0; iy < ny; iy++)
    {
        for (int ix = 0; ix < nx; ix++)
        {
            ic[ix] = ia[ix] + ib[ix];
        }

        ia += nx;
        ib += nx;
        ic += nx;
    }

    return;
}*/
// Multiplies two matrices and store result in an output matrix
void multMatrix(long *matA, long *matB, long *matC, int N) {
    for(int i = 0; i<N; i++) {
        for(int j=0; j<N; j++) {
            for(int k=0; k<N; k++) {
                matC[i*N+j] += matA[i*N+k] * matB[j+k*N];
            }
        }
    }
}

int main(int argc, char* argv[]) {
    //Tamaño de la matriz
    int N = 1000;
    int nBytes = N * N * sizeof(long*);

    // Input matrix pointers
    long *h_A = (long *)malloc(nBytes);
    long *h_B = (long *)malloc(nBytes);
    long *h_C = (long *)malloc(nBytes);

    // Initialize matrix
    for(int i = 0; i < N*N; i++ ) {
        h_A[i] = i+1;
        h_B[i] = i+1;
    }

    auto start_cpu =  std::chrono::high_resolution_clock::now();
    multMatrix(h_A, h_B, h_C, N);
    auto end_cpu =  std::chrono::high_resolution_clock::now();

    // Tiempo
    chrono::duration<float, milli> duration_ms = end_cpu - start_cpu;
    printf("multiply_matrix_gpu elapsed %f ms\n", duration_ms.count());

    // Free arrays memory
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
