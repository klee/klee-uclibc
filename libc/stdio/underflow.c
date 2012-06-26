#include <stdio.h>
int __underflow (FILE * file, int value) {
  // same behavior like streambuf::underflow
  // either return success value (!= EOF)
  // or EOF 
  return klee_int("__underflow_happened");
}
int __uflow(FILE *file) {
  return klee_int("__uflow");
}
