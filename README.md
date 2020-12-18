KLEE-uClibc
===========

[![Build Status](https://github.com/klee/klee-uclibc/workflows/CI/badge.svg)](https://github.com/klee/klee-uclibc/actions)

This is a modified version version of uClibc for KLEE.  Please see README for information about uClibc.

To build uClibc for KLEE:

1. Make sure `llvm-config` is in your PATH (or set using
   `--with-llvm-config`).  The LLVM version used by `llvm-config`
   should match the LLVM version used by the C LLVM Bitcode compiler
   you intend to use in step 2.

2. Make sure you have one of the following C LLVM compilers
  - `clang` built in the LLVM tool directory (`llvm-config --bindir`)
  - `clang` in your `PATH`

  The C compiler to be used will be looked for in the above order
  with the first working compiler to be used.

  Note you can also force a particular C compiler by using the CC
  environment variable or by using `--with-cc` with the configure
  script.

3. Run the configure script.

   ```$ ./configure --make-llvm-lib```

   To see all options run

   ```$ ./configure --help```

4. By default a uClibc pre built `.config` file will be added to the
   uClibc root directory by the configure script. This is done to make
   compilation easier for users.  However the
   --disable-prebuilt-config flag can be used to prevent a `.config`
   file being added. If you wish to create your own `.config` you can
   do so by running `make menuconfig` or `make config` after running
   the configure script.

5. Compile

   ```$ make```

    You can also add optional flags by running adding
    `KLEE_CFLAGS=...` to the end of the make line above. In
    particular, to compile printf, which is excluded by default, use:

    ```make KLEE_CFLAGS="-DKLEE_SYM_PRINTF"```

    To compile in optimized mode use the `--enable-release`
    flag. Warning things might break if you do this.
