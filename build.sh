#!/bin/bash
set -e

TMPDIR="$(mktemp -d)"

cleanup() {
    rm -rf "${TMPDIR}"
}

trap cleanup EXIT

# Save current working directory
cwd=$(pwd)

version="0.0.2"
dependencies=(
    "autoconf"
    "automake"
    "build-essential"
    "cmake"
    "doxygen"
    "gfortran"
    "git"
    "graphviz"
    "imagemagick"
    "libasound2-dev"
    "libasound2-dev"
    "libass-dev"
    "libatlas-base-dev"
    "libavcodec-dev"
    "libavdevice-dev"
    "libavfilter-dev"
    "libavformat-dev"
    "libavutil-dev"
    "libcurl4-openssl-dev"
    "libdc1394-22-dev"
    "libfontconfig1-dev"
    "libfreetype6-dev"
    "libgl1-mesa-dev"
    "libgmp-dev"
    "libgstreamer-plugins-base1.0-dev"
    "libgstreamer1.0-dev"
    "libgtk-3-dev"
    "libjack-jackd2-dev"
    "libjansson-dev"
    "libjasper-dev"
    "libjpeg-dev"
    "liblapacke-dev"
    "libluajit-5.1-dev"
    "libmbedtls-dev"
    "libmp3lame-dev"
    "libopencore-amrnb-dev"
    "libopencore-amrwb-dev"
    "libopenexr-dev"
    "libopus-dev"
    "libpng-dev"
    "libpulse-dev"
    "libqt5svg5-dev"
    "libqt5x11extras5-dev"
    "librtmp-dev"
    "libsdl2-dev"
    "libsdl2-image-dev"
    "libsdl2-mixer-dev"
    "libsdl2-net-dev"
    "libsdl2-ttf-dev"
    "libsnappy-dev"
    "libsoxr-dev"
    "libspeexdsp-dev"
    "libssh-dev"
    "libssl-dev"
    "libswresample-dev"
    "libswscale-dev"
    "libtiff-dev"
    "libtool"
    "libudev-dev"
    "libv4l-dev"
    "libva-dev"
    "libvdpau-dev"
    "libvlc-dev"
    "libvo-amrwbenc-dev"
    "libvorbis-dev"
    "libwebp-dev"
    "libx11-dev"
    "libx11-xcb-dev"
    "libx11-xcb1"
    "libx264-dev"
    "libx265-dev"
    "libxcb-randr0"
    "libxcb-randr0-dev"
    "libxcb-shape0-dev"
    "libxcb-shm0-dev"
    "libxcb-xfixes0"
    "libxcb-xfixes0-dev"
    "libxcb-xinerama0-dev"
    "libxcb-xinput-dev"
    "libxcb-xinput0"
    "libxcb1-dev"
    "libxcomposite-dev"
    "libxinerama-dev"
    "libxml2-dev"
    "libxvidcore-dev"
    "lzma-dev"
    "meson"
    "nasm"
    "pkg-config"
    "python3-dev"
    "python3-pip"
    "python3-pyqt5"
    "qtbase5-dev"
    "qtbase5-private-dev"
    "swig"
    "texinfo"
    "wget"
    "yasm"
    "zlib1g-dev"
)

my_date() {
  date "+%H:%M:%S %d-%m-%y "
}

print_info() {
    echo "================================="
    echo "OBS4Pi4: Building Script v$version "
    echo "================================="
    echo ""
    echo "OS: $(uname -s) $(uname -r) $(uname -m)"
    echo $(lsb_release -d)
    echo "Compilation timestamp: $(my_date)"
    echo ""
}

install_dependencies() {
    echo "Update and upgrade list of installed packages"
    echo ""
    sudo apt-get update -qq && sudo apt-get -y upgrade
    echo ""
    echo "Install missing dependencies"
    for pkg in ${dependencies[@]}; do

        is_pkg_installed=$(dpkg-query -W --showformat='${Status}\n' ${pkg} | grep "install ok installed")

        if [ "${is_pkg_installed}" == "install ok installed" ]; then
            echo ${pkg} is installed.
        fi
    done
}

get_and_build_pipewire() {
    echo "-----------------------------------"
    echo "Get and build pipewire"
    echo "-----------------------------------"
    git clone https://gitlab.freedesktop.org/pipewire/pipewire.git "${TMPDIR}/pipewire" && cd "${TMPDIR}/pipewire" \
        && ./autogen.sh \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_libfdk_acc() {
    echo "-----------------------------------"
    echo "Get and build libfdk-aac"
    echo "-----------------------------------"

    # AAC
    # To disable remove --enable-libfdk-aac
    git clone --depth 1 https://github.com/mstorsjo/fdk-aac "${TMPDIR}/fdk-aac" && cd "${TMPDIR}/fdk-aac" \
        && autoreconf -fiv \
        && ./configure --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_libdav1d() {
    echo "-----------------------------------"
    echo "Get and build libdav1d"
    echo "-----------------------------------"
    # AV1
    # To disable remove --enable-libdav1d
    git clone --depth 1 https://code.videolan.org/videolan/dav1d.git "${TMPDIR}/dav1d" && mkdir "${TMPDIR}/dav1d/build" && cd "${TMPDIR}/dav1d/build" \
        && meson .. \
        && ninja \
        && sudo ninja install
}

get_and_build_libkvazaar() {
    echo "-----------------------------------"
    echo "Get and build libkvazaar"
    echo "-----------------------------------"
    # HEVC
    # To disable remove --enable-libkvazaar
    git clone --depth 1 https://github.com/ultravideo/kvazaar.git "${TMPDIR}/kvazaar" && cd "${TMPDIR}/kvazaar" \
        && ./autogen.sh \
        && ./configure --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_libvpx() {
    echo "-----------------------------------"
    echo "Get and build libvpx"
    echo "-----------------------------------"
    # VP8 and VP9
    # To disable remove --enable-libvpx
    git clone --depth 1 https://chromium.googlesource.com/webm/libvpx "${TMPDIR}/libvpx" && cd "${TMPDIR}/libvpx" \
        && ./configure --disable-examples --disable-tools --disable-unit_tests --disable-docs --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

function get_and_build_libaom {
    echo "-----------------------------------"
    echo "Get and build libaom"
    echo "-----------------------------------"
    # AP1
    # To disable remove --enable-libaom
    git clone --depth 1 --branch v3.0.0 https://aomedia.googlesource.com/aom "${TMPDIR}/aom" \
        && mkdir "${TMPDIR}/aom/aom_build" \
        && cd "${TMPDIR}/aom/aom_build" \
        && cmake -G "Unix Makefiles" AOM_SRC -DENABLE_NASM=on -DPYTHON_EXECUTABLE="$(which python3)" -DCMAKE_C_FLAGS="-mfpu=vfp -mfloat-abi=hard" .. \
        && sed -i 's/ENABLE_NEON:BOOL=ON/ENABLE_NEON:BOOL=OFF/' CMakeCache.txt \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_zimg() {
    echo "-----------------------------------"
    echo "Get and build zimg"
    echo "-----------------------------------"
    # ZIMG
    git clone --depth 1 https://github.com/sekrit-twc/zimg.git "${TMPDIR}/zimg" &&  cd "${TMPDIR}/zimg" \
        && ./autogen.sh \
        && ./configure --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_x264() {
    echo "-----------------------------------"
    echo "Get and build x264"
    echo "-----------------------------------"
    wget https://anduin.linuxfromscratch.org/BLFS/x264/x264-20210211.tar.xz
    tar -xf x264-20210211.tar.xz
    cd x264-20210211 \
        && ./configure --enable-shared --enable-pic --disable-cli \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_ffmpeg() {
    echo "-----------------------------------"
    echo "Get and build FFMPEG"
    echo "-----------------------------------"
    git clone --depth 1 --branch n4.3.2 https://github.com/FFmpeg/FFmpeg.git "${TMPDIR}/FFmpeg" && cd "${TMPDIR}/FFmpeg" \
        && ./configure \
               --extra-cflags='-I/usr/local/include -march=armv8-a+crc+simd -mfloat-abi=hard -mfpu=neon-fp-armv8 -mtune=cortex-a72' \
               --extra-libs='-lpthread -lm -latomic' \
               --arch=armv7l \
               --enable-shared \
               --enable-libv4l2 \
               --enable-libaom \
               --enable-version3 \
               --enable-gpl \
               --enable-libass \
               --enable-libdav1d \
               --enable-libdrm \
               --enable-libfdk-aac \
               --enable-libfreetype \
               --enable-libkvazaar \
               --enable-libmp3lame \
               --enable-libopencore-amrnb \
               --enable-libopencore-amrwb \
               --enable-libopus \
               --enable-librtmp \
               --enable-libsnappy \
               --enable-libsoxr \
               --enable-libssh \
               --enable-libvorbis \
               --enable-libvpx \
               --enable-libwebp \
               --enable-libzimg \
               --enable-libx264 \
               --enable-libx265 \
               --enable-libxml2 \
               --enable-mmal \
               --enable-nonfree \
               --enable-omx \
               --enable-omx-rpi \
               --enable-version3 \
               --target-os=linux \
               --enable-pthreads \
               --enable-openssl \
               --enable-hardcoded-tables \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_obs() {
    git clone --branch 26.1.1 https://github.com/obsproject/obs-studio.git "${TMPDIR}/OBS" && cd "${TMPDIR}/OBS" \
        && mkdir build32 && cd build32 \
        && cmake -DBUILD_BROWSER=OFF -DBUILD_VST=OFF -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=/usr .. \
        && make -j4 \
        && sudo make install \
        && sudo ldconfig
}

main() {
    print_info
    install_dependencies
    get_and_build_pipewire
    get_and_build_libfdk_acc
    get_and_build_libdav1d
    get_and_build_libkvazaar
    get_and_build_libvpx
    get_and_build_libaom
    get_and_build_zimg
    get_and_build_x264
    get_and_build_ffmpeg
    get_and_build_obs
    cleanup
}

time main

cd $cwd

echo ""
echo "All done!"
echo "Remember you need MESA_GL_VERSION_OVERRIDE=3.3 obs to start OBS!"
echo "If you get an opengl seg fault try to fix it with"
echo "export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libGL.so"
echo "before launch OBS"
echo ""
echo "Read the README.md for more information"
exit 0
