#!/bin/bash

clear

rm -r build64
rm -r build
mkdir build64
mkdir build

export NDK_PATH="/root/tools/ndk"
export TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin"

export CC="$TOOLCHAIN/aarch64-linux-android26-clang"
export CFLAGS="-I../pulseaudio/build-arm64 -I../pulseaudio/src -I../root-arm64/include"
export LDFLAGS="-L../root-arm64/lib/pulseaudio -L../root-arm64/lib"

$CC -g -shared -fPIC $CFLAGS $LDFLAGS -lpulsecore-13.0 -lpulsecommon-13.0 -lpulse -laaudio -o build64/module-aaudio-sink.so module-aaudio-sink.c

export CC="$TOOLCHAIN/armv7a-linux-androideabi26-clang"
export CFLAGS="-I../pulseaudio/build-armhf -I../pulseaudio/src -I../root-armhf/include"
export LDFLAGS="-L../root-armhf/lib/pulseaudio -L../root-armhf/lib"

$CC -g -shared -fPIC $CFLAGS $LDFLAGS -lpulsecore-13.0 -lpulsecommon-13.0 -lpulse -laaudio -o build/module-aaudio-sink.so module-aaudio-sink.c