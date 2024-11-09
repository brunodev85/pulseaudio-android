#!/bin/bash

while getopts "a:" option
do 
    case "${option}"
        in
        a)arch=${OPTARG};;
    esac
done

export NDK_PATH="/root/tools/android-ndk"
export BASE_DIR="$PWD"
export ROOT_DIR="$BASE_DIR/root-$arch"
export PATH=$ROOT_DIR/bin:$PATH
export PKG_CONFIG_PATH=$ROOT_DIR/lib/pkgconfig
export ACLOCAL_PATH=$ROOT_DIR/share/aclocal
export CFLAGS="-O2 -I$ROOT_DIR/include"

export ALLOW_UNRESOLVED_SYMBOLS=1
export ac_cv_func_mkfifo=no
export ac_cv_func_getuid=no
export ac_cv_func_getuid=seteuid
export ax_cv_PTHREAD_PRIO_INHERIT=no
export ac_cv_header_glob_h=no
export ac_cv_func_malloc_0_nonnull=yes
export ac_cv_func_realloc_0_nonnull=yes
export ac_cv_lib_ltdl_lt_dladvise_init=yes

if [ $arch = "arm64" ]; then
	BUILDCHAIN=aarch64-linux-android
	OUTPUT_DIR="$BASE_DIR/output/aarch64-linux-gnu"
else
	BUILDCHAIN=armv7a-linux-androideabi
	OUTPUT_DIR="$BASE_DIR/output/arm-linux-gnueabihf"
fi

export TOOLCHAIN="$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64/bin"
export CC="$TOOLCHAIN/${BUILDCHAIN}26-clang"
export CXX="$TOOLCHAIN/${BUILDCHAIN}26-clang++"

if [ ! -e "$ROOT_DIR/lib/libltdl.so" ] ; then
	mkdir -p libtool/build-$arch
	pushd libtool/build-$arch
	../configure --host=$BUILDCHAIN --prefix=$ROOT_DIR HELP2MAN=/bin/true MAKEINFO=/bin/true
	make
	make install
	popd
fi

export LIBTOOLIZE=$ROOT_DIR/bin/libtoolize

if [ ! -e "$ROOT_DIR/lib/libsndfile.so" ] ; then
	mkdir -p libsndfile/build-$arch
	pushd libsndfile/build-$arch
	../configure --host=$BUILDCHAIN --prefix=$ROOT_DIR --disable-external-libs --disable-alsa --disable-sqlite
	perl -pi -e 's/ examples / /g' Makefile
	make
	make install
	popd
fi

pushd pulseaudio
env NOCONFIGURE=1 bash -x ./bootstrap.sh
popd

rm -r pulseaudio/build-$arch
mkdir -p pulseaudio/build-$arch
pushd pulseaudio/build-$arch
../configure --host=$BUILDCHAIN --prefix=$ROOT_DIR --disable-static --enable-shared --disable-rpath --disable-nls --disable-x11 --disable-oss-wrapper --disable-alsa --disable-esound --disable-waveout --disable-glib2 --disable-gtk3 --disable-gconf --disable-avahi --disable-jack --disable-asyncns --disable-tcpwrap --disable-lirc --disable-dbus --disable-bluez5 --disable-udev --disable-openssl --disable-manpages --disable-samplerate --without-speex --with-database=simple --disable-orc --without-caps --without-fftw --disable-systemd-daemon --disable-systemd-login --disable-systemd-journal --disable-webrtc-aec --disable-tests --disable-neon-opt --disable-gsettings

make
make install

rm -r $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $OUTPUT_DIR/modules

cp -a $ROOT_DIR/bin/pulseaudio $OUTPUT_DIR/libpulseaudio.so
cp -a $ROOT_DIR/lib/pulseaudio/libpulsecommon-13.0.so $OUTPUT_DIR/libpulsecommon-13.0.so
cp -a $ROOT_DIR/lib/pulseaudio/libpulsecore-13.0.so $OUTPUT_DIR/libpulsecore-13.0.so
cp -a $ROOT_DIR/lib/libpulse.so $OUTPUT_DIR/libpulse.so
cp -a $ROOT_DIR/lib/libsndfile.so $OUTPUT_DIR/libsndfile.so
cp -a $ROOT_DIR/lib/libltdl.so $OUTPUT_DIR/libltdl.so
cp -a $ROOT_DIR/lib/pulse-13.0/modules/libprotocol-native.so $OUTPUT_DIR/modules/libprotocol-native.so
cp -a $ROOT_DIR/lib/pulse-13.0/modules/module-native-protocol-unix.so $OUTPUT_DIR/modules/module-native-protocol-unix.so