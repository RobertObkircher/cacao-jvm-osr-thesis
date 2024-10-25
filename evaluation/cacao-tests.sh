#!/bin/bash

autoreconf --install --force --verbose
cd build
/bin/sh "../configure" \
--disable-optimizations \
--enable-debug \
--enable-disassembler \
--enable-replacement \
--enable-compiler2 \
--enable-logging \
--enable-maintainer-mode \
--enable-countdown-traps=yes \
--enable-statistics \
--with-java-runtime-library=gnuclasspath \
--with-java-runtime-library-prefix=/usr/local/classpath \
--with-junit-jar=/usr/share/java/junit4.jar:/usr/share/java/hamcrest.jar
make -j 12
make check
