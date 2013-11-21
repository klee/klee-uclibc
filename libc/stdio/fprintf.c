/* Copyright (C) 2004       Manuel Novoa III    <mjn3@codepoet.org>
 *
 * GNU Library General Public License (LGPL) version 2 or later.
 *
 * Dedicated to Toni.  See uClibc/DEDICATION.mjn3 for details.
 */

#include "_stdio.h"
#include <stdarg.h>

libc_hidden_proto(vfprintf)

libc_hidden_proto(fprintf)
int fprintf(FILE * __restrict stream, const char * __restrict format, ...)
{
	va_list arg;
	int rv;

	va_start(arg, format);

/* DWD/CrC/PG */

  //rv = vfprintf(stream, format, arg);

// ok, this is really subtle, but if we are NOT running with symbolic
// printfs (for improved speed), we should simply print stdout and
// stderr to native stdout using vprintf, but if we are running with
// symbolic printfs (for completeness, esp. for cross-checking), we
// should always run instrumented code (e.g., vfprintf)
#ifdef KLEE_SYM_PRINTF
        if (0) {
#else
        if (stream==stdout || stream==stderr) {
#endif
          rv = vprintf(format, arg);
        } else {
          rv = vfprintf(stream, format, arg);
        }
	va_end(arg);

	return rv;
}
libc_hidden_def(fprintf)
