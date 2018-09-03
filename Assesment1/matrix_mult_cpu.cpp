//Para ayuda de este programa se consulto el siguiente libro Professional programing for cudaFree
//http://www.hds.bme.hu/~fhegedus/C++/Professional%20CUDA%20C%20Programming.pdf
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
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
void matrixMult(long * A, long * B, long * C const int N){
  for(i = 0; i < n; i++) {
       for(int j = 0; j < n; j++) {
         for(int k = 0; k < n; k++) {
        //Operacion para hacer la regla del karatzo fila por culumna
        C[i * N + j] += A[i * N + k] * B[j + k * N];
      }
    }
  }
}

//No cambiar valores con H_ preguntara para que sirev la h en el main ya que todos los archivos la traen :/
int main(int argc, char* argv[]){
    //Tamaño de la matriz
    int N = 2000

    //Codigo de vectores
    int nx = N;
    int ny = N;

    int nxy = nx * ny;
    int nBytes = nxy * sizeof(int);

    //llenado de la matriz
    for(int i = 0; i < N * N; i++ ) {
      a[i] = i+1;
      b[i] = i+1;
    }

    //malloc
    long *h_A, *h_B, *h_C;
    h_A = (long*)malloc(nBytes);
    h_B = (long*)malloc(nBytes);
    h_C = (long*)malloc(nBytes);

    fillMatrices(h_A, nxy);
    fillMatrices(h_B, nxy);

    auto startTime = chrono::high_resolution_clock::now();
    matrixMult(h_A, h_B, h_C, N);
    auto endTime = chrono::high_resolution_clock::now();
    chrono::duration<long, std::milli> duration_ms = endTime - startTime;


    free(h_A);
    free(h_B);
    free(h_C);

    printf("Tiempo %d repeticiones:  %f matriz donde x: %d y: %d", repeticiones, promedio, tam, tam);
    return 0;
}
