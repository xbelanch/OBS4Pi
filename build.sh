#!/bin/bash

TMPDIR="$(mktemp -d)"

function cleanup {
    rm -rf "${TMPDIR}"
}

trap cleanup EXIT


echo "================================="
echo "OBS4Pi4: Building Script v.0.0.1 "
echo "================================="
echo ""
echo ""
echo "-----------------------------------"
echo "Preparing FFMPEG Dependencies"
echo "-----------------------------------"
echo ""

# Install Dependencies
sudo apt-get update -qq && sudo apt-get -y install \
    autoconf \
    automake \
    build-essential \
    cmake \
    doxygen \
    git \
    graphviz \
    imagemagick \
    libasound2-dev \
    libass-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libfreetype6-dev \
    libgmp-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopus-dev \
    librtmp-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-net-dev \
    libsdl2-ttf-dev \
    libsnappy-dev \
    libsoxr-dev \
    libssh-dev \
    libssl-dev \
    libtool \
    libv4l-dev \
    libva-dev \
    libvdpau-dev \
    libvo-amrwbenc-dev \
    libvorbis-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-xfixes0-dev \
    libxcb1-dev \
    libxml2-dev \
    lzma-dev \
    meson \
    nasm \
    pkg-config \
    python3-dev \
    python3-pip \
    texinfo \
    wget \
    yasm \
    zlib1g-dev

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

echo "-----------------------------------"
echo "Get and build libdav1d"
echo "-----------------------------------"
# AV1
# To disable remove --enable-libdav1d
git clone --depth 1 https://code.videolan.org/videolan/dav1d.git "${TMPDIR}/dav1d" && mkdir "${TMPDIR}/dav1d/build" && cd "${TMPDIR}/dav1d/build" \
    && meson .. \
    && ninja \
    && sudo ninja install

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

echo "-----------------------------------"
echo "Get and build libvpx"
echo "-----------------------------------"
# VP8 and VP9
# To disable remove --enable-libvpx
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx "${TMPDIR}/libvpx" && cd "${TMPDIR}/libvpx" \
    && ./configure --disable-examples --disable-tools --disable-unit_tests --disable-docs --enable-shared \
    && make -j$(nproc) \
    && sudo make install

echo "-----------------------------------"
echo "Get and build libaom"
echo "-----------------------------------"
# AP1
# To disable remove --enable-libaom
git clone --depth 1 https://aomedia.googlesource.com/aom "${TMPDIR}/aom" && mkdir "${TMPDIR}/aom/aom_build" && cd "${TMPDIR}/aom/aom_build" \
    && git checkout $(git rev-list -1 --before="Dec 15 2019" master) \
    && cmake -G "Unix Makefiles" AOM_SRC -DENABLE_NASM=on -DPYTHON_EXECUTABLE="$(which python3)" -DCMAKE_C_FLAGS="-mfpu=vfp -mfloat-abi=hard" .. \
    && sed -i 's/ENABLE_NEON:BOOL=ON/ENABLE_NEON:BOOL=OFF/' CMakeCache.txt \
    && ./configure --enable-shared \
    && make -j$(nproc) \
    && sudo make install

echo "-----------------------------------"
echo "Get and build zimg"
echo "-----------------------------------"
# ZIMG
git clone --depth 1 https://github.com/sekrit-twc/zimg.git "${TMPDIR}/zimg" &&  cd "${TMPDIR}/zimg" \
  && ./autogen.sh \
  && ./configure --enable-shared \
  && make -j$(nproc) \
  && sudo make install

echo "-----------------------------------"
echo "Get and build x264"
echo "-----------------------------------"

wget http://anduin.linuxfromscratch.org/BLFS/x264/x264-20200218.tar.xz
tar -xf x264-20200218.tar.xz
cd x264-20200218 \
    && ./configure --enable-shared --enable-pic --disable-cli \
    && make -j$(nproc) \
    && sudo make install

sudo ldconfig

echo "-----------------------------------"
echo "Get and build FFMPEG"
echo "-----------------------------------"

# Compile FFmpeg
git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git "${TMPDIR}/FFmpeg" && cd "${TMPDIR}/FFmpeg" \
    && ./configure \
        --extra-cflags="-I/usr/local/include" \
        --extra-ldflags="-L/usr/local/lib -latomic" \
        --extra-libs="-lpthread -lm" \
        --arch=armel \
        --enable-shared \
        --enable-libv4l2 \
        --enable-gmp \
        --enable-gpl \
        --enable-libaom \
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


sudo ldconfig

# Clean build directories
rm -rf obs-studio

# Save current working directory
cwd=$(pwd)

# Step 1: Update packages

echo "-----------------------------------"
echo "Update OS packages"
echo "-----------------------------------"

sudo apt -y update
sudo apt -y upgrade

echo "Complete"

# Step 2: Install OS libraries
echo "-----------------------------------"
echo "Installing OS libraries"
echo "-----------------------------------"

sudo apt -y remove x264 libx264-dev

## Install dependencies
sudo apt -y install cmake build-essential pkg-config git
sudo apt -y install libjpeg-dev libtiff-dev libjasper-dev libpng-dev libwebp-dev libopenexr-dev
sudo apt -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libdc1394-22-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
sudo apt -y install libgtk-3-dev libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5
sudo apt -y install libatlas-base-dev liblapacke-dev gfortran
sudo apt -y install libhdf5-dev libhdf5-103

# Step 3: Install Python libraries
echo "-----------------------------------"
echo "Install Python libraries"
echo "-----------------------------------"

sudo apt -y install python3-dev python3-pip python3-numpy

echo "-----------------------------------"
echo "Complete"
echo "-----------------------------------"

# Step 4: Download OBS

echo "-----------------------------------"
echo "Compiling and installing OBS"
echo "-----------------------------------"


sudo apt-get update
sudo apt-get -y install \
     build-essential \
     checkinstall \
     cmake \
     git \
     libmbedtls-dev \
     libasound2-dev \
     libavcodec-dev \
     libavdevice-dev \
     libavfilter-dev \
     libavformat-dev \
     libavutil-dev \
     libcurl4-openssl-dev \
     libfontconfig1-dev \
     libfreetype6-dev \
     libgl1-mesa-dev \
     libjack-jackd2-dev \
     libjansson-dev \
     libluajit-5.1-dev \
     libpulse-dev \
     libqt5x11extras5-dev \
     libspeexdsp-dev \
     libswresample-dev \
     libswscale-dev \
     libudev-dev \
     libv4l-dev \
     libvlc-dev \
     libx11-dev \
     libx11-xcb1 \
     libx11-xcb-dev \
     libxcb-xinput0 \
     libxcb-xinput-dev \
     libxcb-randr0 \
     libxcb-randr0-dev \
     libxcb-xfixes0 \
     libxcb-xfixes0-dev \
     libx264-dev \
     libxcb-shm0-dev \
     libxcb-xinerama0-dev \
     libxcomposite-dev \
     libxinerama-dev \
     pkg-config \
     python3-dev \
     qtbase5-dev \
     libqt5svg5-dev \
     swig

echo "-----------------------------------"
echo "        Getting OBS Source"
echo "-----------------------------------"

git clone --recursive https://github.com/obsproject/obs-studio.git

echo "-----------------------------------"
echo "         Preparing build"
echo "-----------------------------------"

cd obs-studio
mkdir build && cd build
cmake -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=/usr ..

echo "-----------------------------------"
echo "             Building"
echo "-----------------------------------"

make -j4
sudo make install
sudo ldconfig

cd $cwd

echo ""
echo "All done..........!"
echo "Remember you need MESA_GL_VERSION_OVERRIDE=3.3 obs to start OBS!"
echo "Read the README.md for more information"
exit 0
