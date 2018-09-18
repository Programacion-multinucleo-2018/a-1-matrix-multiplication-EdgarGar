//LOS CODIGOS FUERON MODIFICADOS DEL MATERIAL DADOD EN CLASE CON EL OBJETIVO DE QUE FUERA MAS FACIL COMPRENDER
//SE USARON ALGUNAS PAGINAS DE INTERNET Y LIBROS Y CODIGO COMENTADO, LAS REFENECIAS ESTAN EN EL REPORTE Y EN CODIGO

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <chrono>
#include "common.h"

using namespace std;

/*
__global__ void matrixMultOnHostGPU(int *a, int *b, int *c) {
 int k, sum = 0;
 int col = threadIdx.x + blockDim.x * blockIdx.x;
 int fil = threadIdx.y + blockDim.y * blockIdx.y;

 if (col < N && fil < N) {
  for (k = 0; k < N; k++) {
   sum += a[fil * N + k] * b[k * N + col];
  }
  c[fil * N + col] = sum;
 }
}*/
//Multiplicacion en GPU
__global__ void matrixMultOnHostGPU1D(long *MatA, long *MatB, long *MatC, const int N)
{
  unsigned int ix = threadIdx.x + blockIdx.x * blockDim.x;
  unsigned int iy = blockIdx.y + blockIdx.y * blockDim.y;
  //verificacion de las filas para la multiplicacion
  if (ix < N && iy < N){
    for (int k = 0; k < N; k++){
      //sum += a[fil * N + k] * b[k * N + col];
      MatC[iy * N + ix] += MatA[iy * N + iy] * MatB[k * N +ix];
    }
  }
}

//Multiplicacion en CPU
void matrixMultOnHost(long * A, long * B, long * C, int N)
{
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      for (int k = 0; k < N; k++){
        //Operacion para hacer la regla del karatzo fila por culumna
        C[i * N + j] += A[i * N * k] * B[j + k * N];
      }
    }
  }
}

void checkResult(long *hostRef, long *gpuRef, const int N){
  double epsilon = 1.0E-8;
  bool match = 1;
  for (int i = 0; i < N; i++){
    if (abs(hostRef[i] - gpuRef[i]) > epsilon){
      match = 0;
      printf("host %ld gpu %ld\n", hostRef[i], gpuRef[i]);
      break;
    }
  }
  if (match)
    printf("Matrix match.\n");
  else
    printf("Matrix do not match.\n");
}


int main(int argc, char *argv[])
{
    // set up device
    int dev = 0;
    cudaDeviceProp deviceProp;
    SAFE_CALL(cudaGetDeviceProperties(&deviceProp, dev), "Error device prop");
    printf("Using Device %d: %s\n", dev, deviceProp.name);
    SAFE_CALL(cudaSetDevice(dev), "Error setting device");

    // Tamaño de la matriz
    int N = 1000;
    int nBytes = N * N * sizeof(long);

    // host memory
    long *h_A = (long *)malloc(nBytes);
    long *h_B = (long *)malloc(nBytes);
    long *hostRef = (long *)malloc(nBytes);
    long *gpuRef = (long *)malloc(nBytes);

    // Matriz inicalizada
    for(int i = 0; i < N * N; i++ ) {
        h_A[i] = i+1;
        h_B[i] = i+1;
    }

    memset(hostRef, 0, nBytes);
    memset(gpuRef, 0, nBytes);

    // add matrix at host side for result SAFE_CALLs
    auto start_cpu = chrono::high_resolution_clock::now();
    matrixMultOnHost(h_A, h_B, hostRef, N);
    auto end_cpu = chrono::high_resolution_clock::now();

    chrono::duration<float, milli> duration_ms = end_cpu - start_cpu;
    printf("sumMatrixOnHost elapsed %f ms\n", duration_ms.count());

    // malloc device global memory
    long *d_MatA, *d_MatB, *d_MatC;
    SAFE_CALL(cudaMalloc((void **)&d_MatA, nBytes), "Error allocating d_MatA");
    SAFE_CALL(cudaMalloc((void **)&d_MatB, nBytes), "Error allocating d_MatB");
    SAFE_CALL(cudaMalloc((void **)&d_MatC, nBytes), "Error allocating d_MatC");

    // transfer data from host to device
    SAFE_CALL(cudaMemcpy(d_MatA, h_A, nBytes, cudaMemcpyHostToDevice), "Error copying d_MatA");
    SAFE_CALL(cudaMemcpy(d_MatB, h_B, nBytes, cudaMemcpyHostToDevice), "Error copying d_MatB");
    SAFE_CALL(cudaMemset(d_MatC, 0, nBytes), "");

    // invoke kernel at host side
    dim3 block(32, 32);
    dim3 grid((N + block.x - 1) / block.x, (N + block.y - 1) / block.y);
    printf("grid.x %d grid.y %d block.x %d block.y %d\n", grid.x, grid.y, block.x, block.y);
    //kernel
    start_cpu =  chrono::high_resolution_clock::now();
    matrixMultOnHostGPU1D<<<grid, block>>>(d_MatA, d_MatB, d_MatC, N);
    cudaDeviceSynchronize();
    end_cpu = std::chrono::high_resolution_clock::now();

    //Formula
    duration_ms = end_cpu - start_cpu;
    printf("Multiplicacionelapsed %f ms\n", duration_ms.count());


    // SAFE_CALL kernel error
    SAFE_CALL(cudaGetLastError(), "Error with last error");

    // copy kernel result back to host side
    SAFE_CALL(cudaMemcpy(gpuRef, d_MatC, nBytes, cudaMemcpyDeviceToHost), "Error copying d_MatC");

    // Compare results
    checkResult(hostRef, gpuRef, N);

    // free device global memory
    SAFE_CALL(cudaFree(d_MatA), "Error freeing memory");
    SAFE_CALL(cudaFree(d_MatB), "Error freeing memory");
    SAFE_CALL(cudaFree(d_MatC), "Error freeing memory");

    // free host memory
    cudaFree(d_MatA);
    cudaFree(d_MatB);
    cudaFree(d_MatC);
    free(h_A);
    free(h_B);
    free(hostRef);
    free(gpuRef);

    // reset device
    SAFE_CALL(cudaDeviceReset(), "Error reseting");

    return 0;
}
