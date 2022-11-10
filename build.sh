#!/bin/bash
set -e
export LD_LIBRARY_PATH=/usr/local/lib/
TMPDIR="$(mktemp -d)"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)
CYAN=$(tput setaf 6)
DEFAULT=$(tput sgr0)
FFMPEG_TAG=n5.0
OBS_TAG=28.0.0

cleanup() {
    rm -rf "${TMPDIR}"
}

trap cleanup EXIT

# Save current working directory
cwd=$(pwd)

version="0.0.3"
dependencies=(
    "autoconf"
    "automake"
    "bison"
    "build-essential"
    "v4l2loopback-dkms"
    "cmake"
    "doxygen"
    "flex"
    "git"
    "graphviz"
    "imagemagick"
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
    "libdrm-dev"
    "libfontconfig1-dev"
    "libfreetype6-dev"
    "libgl1-mesa-dev"
    "libgmp-dev"
    "libgstreamer-plugins-base1.0-dev"
    "libgstreamer1.0-dev"
    "libgtk-3-dev"
    "libjack-jackd2-dev"
    "libjansson-dev"
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
    "libboost-all-dev"
    "qt5-image-formats-plugins"
    "qtcreator"
    "qtbase5-dev"
    "qtdeclarative5-dev"
    "libxcb-composite0-dev"
    "libpci-dev"
)

my_date() {
  date "+%H:%M:%S %d-%m-%y "
}

print_info() {
    echo "${GREEN}"
    echo "________ __________  _________   _______________.__   _____  "
    echo "\_____  \\______   \/   _____/  /  |  \______   \__| /  |  | "
    echo " /   |   \|    |  _/\_____  \  /   |  ||     ___/  |/   |  |_"
    echo "${PURPLE}/    |    \    |   \/        \/    ^   /    |   |  /    ^   /"
    echo "\_______  /______  /_______  /\____   ||____|   |__\____   | "
    echo "        \/       \/        \/      |__|                 |__| "
    echo "${DEFAULT}"

    echo "================================================================"
    echo "    FFmpeg and OBS Studio Building Script v$version for Pi4"
    echo "================================================================"
    echo ""
    echo "${RED}OS${DEFAULT}: $(lsb_release -d | grep -oP "(?<=\s)(.*)")"
    echo "${RED}Kernel${DEFAULT}: $(uname -s) $(uname -r) $(uname -m)"
    echo "${RED}Timestamp${DEFAULT}: $(my_date)"
    echo "${RED}FFmpeg tag source version${DEFAULT}: ${FFMPEG_TAG}"
    echo "${RED}OBS tag source version${DEFAULT}: ${OBS_TAG}"
    echo ""
}

install_dependencies() {
    # If you're interested on improving this
    # take a look at https://stackoverflow.com/questions/1298066/how-to-check-if-package-installed-and-install-it-if-not
    echo "${YELLOW}"
    echo "Update and upgrade list of installed packages"
    echo ""
    sudo apt-get update -qq && sudo apt-get -y upgrade
    echo ""
    echo "Install missing dependencies"
    echo "${DEFAULT}"
    for pkg in ${dependencies[@]}; do
        if [ $(dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            printf "${RED}Package: %-35s NOT INSTALLED${DEFAULT}\n" $pkg;
            sudo apt-get install -y "${pkg}";
        else
            printf "Package: ${PURPLE}%-35s ${GREEN}OK${DEFAULT}\n" $pkg;
        fi
    done
}

check_os_version() {
    os_version=$(($(lsb_release -sr) + 0))
    [[ $os_version -eq 11 ]] || { echo >&2 "${RED}!!!!!You must update Debian version to ${CYAN}bullseye${RED} before you execute again the script!!!!!${DEFAULT}" ; exit 1; }
}

get_and_build_pipewire() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build Pipewire"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    git clone https://gitlab.freedesktop.org/pipewire/pipewire.git "${TMPDIR}/pipewire" \
    && cd "${TMPDIR}/pipewire" \
    && git checkout 0.3.43 \
    && ./autogen.sh \
    && make -j$(nproc) \
    && sudo make install
}

get_and_build_libfdk_aac() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build libfdk-aac"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    # AAC
    # To disable remove --enable-libfdk-aac
    git clone --depth 1 https://github.com/mstorsjo/fdk-aac "${TMPDIR}/fdk-aac" && cd "${TMPDIR}/fdk-aac" \
        && autoreconf -fiv \
        && ./configure --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_libdav1d() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build libdav1d"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    # AV1
    # To disable remove --enable-libdav1d
    git clone --depth 1 https://code.videolan.org/videolan/dav1d.git "${TMPDIR}/dav1d" && mkdir "${TMPDIR}/dav1d/build" && cd "${TMPDIR}/dav1d/build" \
        && meson .. \
        && ninja \
        && sudo ninja install
}

get_and_build_libkvazaar() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build libkvazaar"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    # HEVC
    # To disable remove --enable-libkvazaar
    git clone --depth 1 https://github.com/ultravideo/kvazaar.git "${TMPDIR}/kvazaar" && cd "${TMPDIR}/kvazaar" \
        && ./autogen.sh \
        && ./configure --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_libvpx() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build libvpx"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    # VP8 and VP9
    # To disable remove --enable-libvpx
    git clone --depth 1 https://chromium.googlesource.com/webm/libvpx "${TMPDIR}/libvpx" && cd "${TMPDIR}/libvpx" \
        && ./configure --disable-examples --disable-tools --disable-unit_tests --disable-docs --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_libaom() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build libaom"
    echo "-----------------------------------"
    echo "${DEFAULT}"
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
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build zimg"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    # ZIMG
    git clone --recurse-submodules https://github.com/sekrit-twc/zimg.git "${TMPDIR}/zimg" &&  cd "${TMPDIR}/zimg" \
        && ./autogen.sh \
        && ./configure --enable-shared \
        && make -j$(nproc) \
        && sudo make install
}

get_and_build_x264() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build x264"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    git clone https://code.videolan.org/videolan/x264.git "${TMPDIR}/x264" && cd "${TMPDIR}/x264" \
	&& git checkout stable \
        && ./configure --enable-shared --enable-pic --disable-cli \
        && make -j$(nproc) \
        && sudo make install
}

# Stolen from: https://github.com/PietroAvolio/Building-Gstreamer-Raspberry-Pi-With-SRT-Support/blob/master/gstreamer-build.sh
# git clone git://anongit.freedesktop.org/git/gstreamer/gstreamer
get_and_build_gstreamer() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build gstreamer"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    git clone https://gitlab.freedesktop.org/gstreamer/gstreamer.git "${TMPDIR}/gstreamer" && cd "${TMPDIR}/gstreamer" \
    && git checkout tags/1.19.2 \
    && meson build \
    && ninja -C build \
    && sudo ninja -C build install
}

get_and_build_obs_gstreamer() {
    echo "${YELLOW}"
    echo "------------------------------------------"
    echo "Get and build obs-gstreamer v0.2.0  plugin"
    echo "------------------------------------------"
    echo "${DEFAULT}"
    git clone https://github.com/fzwoch/obs-gstreamer.git "${TMPDIR}/obs-gstreamer" && cd "${TMPDIR}/obs-gstreamer" \
    && git checkout tags/v0.2.0 \
    && meson --buildtype=release build \
    && ninja -C build \
    && sudo ninja -C build install \
    && sudo ln -sf /usr/local/lib/arm-linux-gnueabihf/obs-plugins/obs-gstreamer.so /usr/lib/obs-plugins/obs-gstreamer.so
}

get_and_build_ffmpeg() {
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build FFMPEG ${FFMPEG_TAG}"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    git clone --depth 1 --branch ${FFMPEG_TAG} https://github.com/FFmpeg/FFmpeg.git "${TMPDIR}/FFmpeg" && cd "${TMPDIR}/FFmpeg" \
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
    echo "${YELLOW}"
    echo "-----------------------------------"
    echo "Get and build OBS Studio ${OBS_TAG}"
    echo "-----------------------------------"
    echo "${DEFAULT}"
    git clone --recursive https://github.com/obsproject/obs-studio.git "${TMPDIR}/OBS" && cd "${TMPDIR}/OBS" \
        && mkdir build32 && cd build32 \
        && cmake -DENABLE_NEW_MPEGTS_OUTPUT=OFF -DENABLE_BROWSER=OFF -DUNIX_STRUCTURE=1 -DCMAKE_INSTALL_PREFIX=/usr .. \
        && make -j4 \
        && sudo make install \
        && sudo ldconfig
}

main() {
    clear
    print_info
    check_os_version
    install_dependencies
    get_and_build_pipewire
    get_and_build_libfdk_aac
    get_and_build_libdav1d
    get_and_build_libkvazaar
    get_and_build_libvpx
    get_and_build_libaom
    get_and_build_zimg
    get_and_build_x264
    get_and_build_gstreamer
    sudo ldconfig
    get_and_build_ffmpeg
    get_and_build_obs
    get_and_build_obs_gstreamer
    sudo ldconfig
    cleanup
}

time main

cd $cwd

echo "${YELLOW}"
echo "All done!"
echo "Cross your fingers and run ./launch_OBS.sh script to launch OBS"
echo "${DEFAULT}"
exit 0
