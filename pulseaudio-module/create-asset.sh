#!/bin/bash

mkdir -p pulseaudio/modules/arm64
mkdir -p pulseaudio/modules/armhf

cp -a ../output/aarch64-linux-gnu/modules/libprotocol-native.so pulseaudio/modules/arm64
cp -a ../output/aarch64-linux-gnu/modules/module-native-protocol-unix.so pulseaudio/modules/arm64

cp -a ../output/arm-linux-gnueabihf/modules/libprotocol-native.so pulseaudio/modules/armhf
cp -a ../output/arm-linux-gnueabihf/modules/module-native-protocol-unix.so pulseaudio/modules/armhf

cp -a build64/module-aaudio-sink.so pulseaudio/modules/arm64
cp -a build/module-aaudio-sink.so pulseaudio/modules/armhf

tar -I 'zstd -19' -cf pulseaudio.tzst -C pulseaudio .

rm -r pulseaudio
