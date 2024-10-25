# Source code overview

- `src/cacao`: Entrypoint
- `src/classes`: Java code
- `src/fdlibm`: (part of?) the fdlibm math library
- `src/mm`: Memory management. `boehm-gc`, `cacao-gc`
- `src/native`: Native implementation of certain java methods that provide things like reflection and calling native methods. This includes functions from gnuclasspath.
- `src/thread`: Synchronization primitives and threads
- `src/toolbox`: Utilities such as assert macros and datastructures.
- `src/vm`: The files in this directory mostly represent the VM state.
- `src/vm/jit` The baseline compiler.
    - replace.cpp: **on stack replacement**
- `src/vm/jit/compiler2` The second stage compiler

If you see `Option<T>` that is a command line parameter, not an `std::optional`!


# Setup development environment

1. Run `sh dev/dev.sh bash` to create the docker container and start a shell in it:
- Create a new ssh key using `ssh-keygen` and add the output of `cat .ssh/id_rsa.pub` to Bitbucket under `Personal settings/SSH keys` (or `Repository settings/Access keys` for read only access)
- `git clone git@bitbucket.org:RobertObkircher/cacao.git cacao`

2. From now on CLion can be launched with `sh dev/dev.sh` script
   Initial setup:
- Login with JetBrains Account
- Customize: theme and keymap
- Plugins: IdeaVim, Grazie
- Open project
- Settings:
- C++ Code Style
- use tab
- else on new line
- show whitespace

## CLion Makefile settings

Build options: `--makefile=Makefile -j 12`

Pre-configuration commands executed to generate the Makefile:
```sh
which autoreconf >/dev/null && autoreconf --install --force --verbose "${PROJECT_DIR:-..}" 2>&1; /bin/sh "${PROJECT_DIR:-..}/configure"   --disable-optimizations   --enable-debug   --enable-disassembler   --enable-replacement   --enable-compiler2   --enable-logging   --enable-maintainer-mode --enable-countdown-traps=yes --enable-statistics --with-java-runtime-library=gnuclasspath   --with-java-runtime-library-prefix=/usr/local/classpath  --with-junit-jar=/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar 
```
## Debugging with GDB in CLion

Cacao uses certain signals for control flow.

They can be ignored with the following gdb command.

```gdb
handle SIGSEGV SIGILL SIGPWR SIGXCPU noprint nostop
```

You probably want to add this the `~/.gdbinit` file.

### CLion run configuration for running a test

Program arguments:
```
-Xbootclasspath:../../../src/classes/classes:/usr/local/classpath/share/classpath/glibj.zip
-Xbootclasspath/a:/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar:.
-DTIMING=
org.cacaojvm.compiler2.test.CacaoJUnitCore
org.cacaojvm.compiler2.test.Permut
```

Environment variables:
`LD_LIBRARY_PATH=/root/cacao/build/src/cacao/.libs`

Warning: you have to manually run `make check` in `build/tests/compiler2` to recompile java files.


## Configure

GNU Classpath
```sh
./configure \
  --disable-optimizations \
  --enable-debug \
  --enable-disassembler \
  --enable-replacement \
  --enable-compiler2 \
  --enable-logging \
  --enable-maintainer-mode \
  --with-java-runtime-library=gnuclasspath \
  --with-java-runtime-library-prefix=/usr/local/classpath \
  --with-junit-jar=/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar \
&& make clean && make -j 12 all
```

OpenJDK7

It seems like for `--enable-jre-layout` we have to download the jdk sources

zulu+openjdk jdk7 ( note the tests don't work with this configuration but libjvm.so can be used by with `-XXAltJvm` to run specjvm)
```sh
./configure \
  --disable-optimizations \
  --enable-debug \
  --enable-disassembler \
  --enable-replacement \
  --enable-compiler2 \
  --enable-logging \
  --enable-maintainer-mode \
  --enable-jre-layout \
  --with-java-runtime-library=openjdk7 \
  --with-build-java-runtime-library-classes=/usr/lib/jvm/zulu7/jre/lib/rt.jar \
  --with-java-runtime-library-libdir=/usr/lib/jvm/zulu7/jre/lib/amd64 \
  --libdir=/usr/lib/jvm/zulu7/jre/lib/\
  --prefix=/usr/lib/jvm/zulu7/jre/\
  --with-java-runtime-library-prefix=/dependencies/jdk7 \
  --with-junit-jar=/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar \
&& make clean && make -j 12 all
```

## Interesting options

```sh
#./configure \
#  --disable-optimizations \
#  --enable-debug \
#  --enable-dump \
#  --enable-memcheck \
#  --enable-logging \
#  --enable-disassembler \
#  --enable-statistics \
#  --enable-verifier \
#  --enable-replacement \
#  --enable-inlining \
#  --enable-inlining-debug \
#  --enable-replacement \
#  --enable-countdown-traps \
#  --enable-compiler2 \
#  --enable-loop \
#  --enable-lsra \
#  --enable-profiling \
#  --enable-scheduler \
#  --enable-test-dependency-checks \
#  --enable-expensive-assert \
#  --with-java-runtime-library=gnuclasspath \
#  --with-java-runtime-library-prefix=/usr/local/classpath \
#  --with-junit-jar=/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar
```

