//LOS CODIGOS FUERON MODIFICADOS DEL MATERIAL DADOD EN CLASE CON EL OBJETIVO DE QUE FUERA MAS FACIL COMPRENDER
//SE USARON ALGUNAS PAGINAS DE INTERNET Y LIBROS Y CODIGO COMENTADO, LAS REFENECIAS ESTAN EN EL REPORTE Y EN CODIGO

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <chrono>

using namespace std;

//Multiplicaion en CPU
void matrixMultOnHost(long * A, long * B, long * C, const int N)
{
  for (int i = 0; i < N; ++) {
    for (int j = 0; j < N; j++) {
      for (int k = 0; k < N; k++){
        //Operacion para hacer la regla del karatzo fila por culumna
        C[i * N + j] += A[i * N * k] * B[j + k * N];
      }
    }
  }
}

//verificacion que la multiplicacion se puede realizar, de lo cual regresa
//un verdade o un falso en el caso que si o no
void checkResult(long *hostRef, long *gpuRef, const int N){
  double epsilon = 1.0E-8;
  bool match = 1;
  for (int i = 0; i < N; i++){
    if (abs(hostRef[i] - gpuRef[i]) > epsilon){
      match = 0;
      printf("host %f gpu %f\n", hostRef[i], gpuRef[i]);
      break;
    }
  }
  if (match)
    printf("Matrix match.\n\n");
  else
    printf("Matrix do not match.\n\n");
}

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

//Multiplicacion de matrices
__global__ void matrixMultOnHost2D(long *MatA, long *MatB, long *MatC const int N){
    //col
  unsigned int ix = threadIdx.x + blockIdx.x * blockDim.x;
    //fil
  unsigned int iy = threadIdx.y + blockIdx.y * blockDim.y;

  if (ix < N && iy < N){
    for(int in = 0; in < N; in++){
        //sum += a[fil * N + k] * b[k * N + col];
        MatC[iy * N + ix] += MatA[iy * N + in] * MatB[in * N +ix];
    }
  }
}

int main(int argc, char *argv[])
{
    printf("%s Starting...\n", argv[0]);

    // set up device
    int dev = 0;
    cudaDeviceProp deviceProp;
    SAFE_CALL(cudaGetDeviceProperties(&deviceProp, dev), "Error device prop");
    printf("Using Device %d: %s\n", dev, deviceProp.name);
    SAFE_CALL(cudaSetDevice(dev), "Error setting device");

    // set up data size of matrix
    int N = 2000;
    int nx = N;
    int ny = N;

    int nxy = nx * ny;
    int nBytes = nxy * sizeof(long);
    printf("Matrix size: nx %d ny %d\n", nx, ny);

    // malloc host memory
    long *h_A, *h_B, *hostRef, *gpuRef;
    h_A = (long *)malloc(nBytes);
    h_B = (long *)malloc(nBytes);
    hostRef = (long *)malloc(nBytes);
    gpuRef = (long *)malloc(nBytes);

    // Llenado de matriz
    for(int i = 0; i < N * N; i++ ) {
        h_A[i] = i+1;
        h_B[i] = i+1;
    }

    memset(hostRef, 0, nBytes);
    memset(gpuRef, 0, nBytes);

    // add matrix at host side for result SAFE_CALLs
    auto start_cpu =  chrono::high_resolution_clock::now();
    matrixMultOnHost(h_A, h_B, hostRef, N);
    auto end_cpu =  chrono::high_resolution_clock::now();

    chrono::duration<long, std::milli> duration_ms = end_cpu - start_cpu;
    printf("sumMatrixOnHost elapsed %f ms\n", duration_ms.count());

    // malloc device global memory
    long *d_MatA, *d_MatB, *d_MatC;
    SAFE_CALL(cudaMalloc((void **)&d_MatA, nBytes), "Error allocating d_MatA");
    SAFE_CALL(cudaMalloc((void **)&d_MatB, nBytes), "Error allocating d_MatB");
    SAFE_CALL(cudaMalloc((void **)&d_MatC, nBytes), "Error allocating d_MatC");

    // transfer data from host to device
    SAFE_CALL(cudaMemcpy(d_MatA, h_A, nBytes, cudaMemcpyHostToDevice), "Error copying d_MatA");
    SAFE_CALL(cudaMemcpy(d_MatB, h_B, nBytes, cudaMemcpyHostToDevice), "Error copying d_MatB");

    // invoke kernel at host side
    int dimx = 128;
    dim3 block((n + block.x - 1) / block.x));
    printf("grid.x %d block.x %d \n", grid.x, block.x);

    //kernel
    start_cpu =  chrono::high_resolution_clock::now();
    matrixMultOnHost2D<<<grid, block>>>(d_MatA, d_MatB, d_MatC, N);
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
    if(checkResult(hostRef, gpuRef))
      printf("They are equal\n");
    else
      printf("They are different\n");

    // free device global memory
    SAFE_CALL(cudaFree(d_MatA), "Error freeing memory");
    SAFE_CALL(cudaFree(d_MatB), "Error freeing memory");
    SAFE_CALL(cudaFree(d_MatC), "Error freeing memory");

    // free host memory
    free(h_A);
    free(h_B);
    free(hostRef);
    free(gpuRef);

    // reset device
    SAFE_CALL(cudaDeviceReset(), "Error reseting");

    return (0);
}
