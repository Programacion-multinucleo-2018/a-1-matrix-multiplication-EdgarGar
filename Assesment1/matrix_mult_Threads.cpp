//LOS CODIGOS FUERON MODIFICADOS DEL MATERIAL DADOD EN CLASE CON EL OBJETIVO DE QUE FUERA MAS FACIL COMPRENDER
//SE USARON ALGUNAS PAGINAS DE INTERNET Y LIBROS Y CODIGO COMENTADO, LAS REFENECIAS ESTAN EN EL REPORTE Y EN CODIGO

#include <cstdlib>
#include <cstdio>
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
//multiplicacion de matriz usando threads
//PD. TIENE UN PEQUEÑO ERROR
void matrixMult(long * A, long * B, long * C const int N){
  int threadID, totalThreads;
  #pragma omp parallel for private(i) shared(A, B, C)
  for (int j = 0; j < N; j++) {
    for (int k = 0; k < N; k++) {
      for (int i = 0; i < N; i++{
        //Operacion para hacer la regla del karatzo fila por culumna
        C[i * N + j] += A[i * N + k] * B[j + k * N];
      }
    }
  }
}

void checkResult(long *matrix_a, long *matrix_b, const int n) {
  double epsilon = 1.0E-8;
  bool match = 1;
  for (int i = 0; i < n*n; i++) {
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

//No cambiar valores con H_ preguntara para que sirev la h en el main ya que todos los archivos la traen :/
int main(int argc, char* argv[]){
  //Tamaño de la matriz
  int N = 2000;
  int nx = N;
  int ny = N;

  int nxy = nx * ny;
  int nBytes = nxy * sizeof(long);

  // malloc
  long *h_A *h_B, *h_C;
  h_A = (long *)malloc(nBytes);
  h_B = (long *)malloc(nBytes);
  h_C = (long *)malloc(nBytes);

  // Llenado de matriz
   for(int i = 0; i < N * N; i++ ) {
       a[i] = i+1;
       b[i] = i+1;
    }

//Promedio para mediante la formula da por el documento
  auto start_cpu =  chrono::high_resolution_clock::now();
  matrixMult(h_A, h_B, h_C, N);
  auto end_cpu =  chrono::high_resolution_clock::now();
  chrono::duration<long, std::milli> duration_ms = end_cpu - start_cpu;

  if(checkResult(hostRef, gpuRef))
    printf("They are equal\n");
  else
    printf("They are different\n");

  //Free arrays memory
  free(h_A);
  free(h_B);
  free(h_C);


  return 0;
}
