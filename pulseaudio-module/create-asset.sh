#!/bin/bash

mkdir -p pulseaudio/modules

cp -a ../output/aarch64-linux-gnu/modules/libprotocol-native.so pulseaudio/modules
cp -a ../output/aarch64-linux-gnu/modules/module-native-protocol-unix.so pulseaudio/modules

cp -a build64/module-aaudio-sink.so pulseaudio/modules

tar -I 'zstd --ultra -22' -cf pulseaudio.tzst -C pulseaudio .

rm -r pulseaudio
