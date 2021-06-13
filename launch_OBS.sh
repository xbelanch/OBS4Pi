#!/bin/sh

export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libGL.so
MESA_GL_VERSION_OVERRIDE=3.3 obs
