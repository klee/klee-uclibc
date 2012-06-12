#include <stdio.h>
int __overflow (FILE * file, int value) {
	// same behavior like streambuf::overflow
	// either return success value (!= EOF)
	// or EOF 
	return klee_int("__overflow_happened");
}
