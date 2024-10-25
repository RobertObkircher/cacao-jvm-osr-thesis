#!/usr/bin/env bash
set -o errexit -o pipefail -o xtrace

readonly SPECJVM_PATH="$HOME/SPECjvm2008"
readonly PROJECT_PATH="$HOME/cacao"
readonly OSR_BUILD_PATH="$HOME/build-osr"
readonly BASELINE_BUILD_PATH="$HOME/build-baseline"
readonly JRE_PATH="/usr/lib/jvm/zulu7/jre/"

if false; then
  debug_xx_options=" -XX:DebugName="compiler2" -XX:DebugVerbose=3 "
  debug_configure=" --enable-logging --disable-optimizations "
else
  debug_xx_options=" "
  debug_configure=" "
fi

benchmark_osr() {
  mkdir -p "${OSR_BUILD_PATH}"
  pushd "${OSR_BUILD_PATH}"

  # workloads
  W=""
  W+=\ startup.helloworld
  W+=\ startup.compiler.compiler
  W+=\ startup.compiler.sunflow
  W+=\ startup.compress
  W+=\ startup.crypto.aes
  W+=\ startup.crypto.rsa
  W+=\ startup.crypto.signverify
  W+=\ startup.mpegaudio
  W+=\ startup.scimark.fft
  W+=\ startup.scimark.lu
  W+=\ startup.scimark.monte_carlo
  W+=\ startup.scimark.sor
  W+=\ startup.scimark.sparse
  W+=\ startup.serial
  W+=\ startup.sunflow
  W+=\ startup.xml.transform
  W+=\ startup.xml.validation
  #W+=\ compiler.compiler # exit code 4 after some internal exception
  W+=\ compiler.sunflow
  W+=\ compress
  W+=\ crypto.aes
  W+=\ crypto.rsa
  W+=\ crypto.signverify
  #W+=\ derby # doesn't terminate
  W+=\ mpegaudio
  W+=\ scimark.fft.large
  W+=\ scimark.lu.large
  W+=\ scimark.sor.large
  W+=\ scimark.sparse.large
  W+=\ scimark.fft.small
  W+=\ scimark.lu.small
  W+=\ scimark.sor.small
  W+=\ scimark.sparse.small
  W+=\ scimark.monte_carlo
  W+=\ serial
  #W+=\ sunflow # doesn't crash but not valid
  W+=\ xml.transform
  W+=\ xml.validation

  #W=-ikv\ compiler.compiler

  case "$1" in
  "configure")
    /bin/sh "${PROJECT_PATH}/configure" $debug_configure \
      --enable-statistics \
      --enable-replacement \
      --enable-compiler2 \
      --enable-countdown-traps=yes \
      --enable-jre-layout \
      --with-java-runtime-library=openjdk7 \
      --with-build-java-runtime-library-classes=$JRE/lib/rt.jar \
      --with-java-runtime-library-libdir=$JRE/lib/amd64 $EXTRA \
      --libdir=$JRE/lib/ \
      --prefix=$JRE \
      --with-java-runtime-library-prefix=/dependencies/jdk7
    make clean
    ;&
  "make")
    make -j 12
    ;&
  "run")
    pushd "${SPECJVM_PATH}"

    # -Xmx10000 gave gc_out_of_memory, with -Xmx15000m I got an exception about fonts not being found, -Xmx14300m it works.
    # -XX:InitialHitCount=10000
    # -XX:+RegallocSpillAll
    # -XX:+InliningPass
    # -ikv --iterations 1 --iterationTime 5s --warmupTime 5s --contintueOnError

    time java -Xmx14300m "-XXaltjvm=${OSR_BUILD_PATH}/src/cacao/.libs" $debug_xx_options -XX:InitialHitCount=100000 -jar "SPECjvm2008.jar" $W

    mv "statistics.log" "statistics-osr.log"
    ;;
  *)
    echo "Usage: $0 osr [configure|make|run]"
    exit 1
    ;;
  esac
}

benchmark_baseline() {
  mkdir -p "${BASELINE_BUILD_PATH}"
  pushd "${BASELINE_BUILD_PATH}"

  case "$1" in
  "configure")
    /bin/sh "${PROJECT_PATH}/configure" $debug_configure \
      --enable-statistics \
      --enable-jre-layout \
      --with-java-runtime-library=openjdk7 \
      --with-build-java-runtime-library-classes=$JRE/lib/rt.jar \
      --with-java-runtime-library-libdir=$JRE/lib/amd64 \
      --libdir=$JRE/lib/ \
      --prefix=$JRE \
      --with-java-runtime-library-prefix=/dependencies/jdk7
    make clean
    ;&
  "make")
    make -j 12
    ;&
  "run")
    pushd "${SPECJVM_PATH}"
    time java -Xmx14300m "-XXaltjvm=${BASELINE_BUILD_PATH}/src/cacao/.libs" -jar "SPECjvm2008.jar"
    mv "statistics.log" "statistics-baseline.log"
    ;;
  *)
    echo "Usage: $0 baseline [configure|make|run]"
    exit 1
    ;;
  esac
}

benchmark_system() {
  pushd "${SPECJVM_PATH}"
  time java -jar "SPECjvm2008.jar"
}

case "$1" in
"osr")
  benchmark_osr "$2"
  ;;
"baseline")
  benchmark_baseline "$2"
  ;;
"system")
  benchmark_system
  ;;
"")
  benchmark_osr configure      |& tee "$SPECJVM_PATH/benchmark_osr.log"
  benchmark_baseline configure |& tee "$SPECJVM_PATH/benchmark_baseline.log"
  benchmark_system             |& tee "$SPECJVM_PATH/benchmark_system.log"
  ;;
*)
  echo "Usage: $0 [osr|baseline|system]"
  exit 1
  ;;
esac
