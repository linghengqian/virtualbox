#!/bin/sh
# $Id$
## @file
# VirtualBox WSL kernel header setup helper.
#

#
# Copyright (C) 2024-2026 Oracle and/or its affiliates.
#
# This file is part of VirtualBox base platform packages, as
# available from https://www.virtualbox.org.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, in version 3 of the
# License.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <https://www.gnu.org/licenses>.
#
# SPDX-License-Identifier: GPL-3.0-only
#

PATH=$PATH:/bin:/sbin:/usr/sbin

USAGE_MESSAGE="Usage: $(basename "$0") [--help]
Print WSL kernel build preparation steps for VirtualBox.
This script only prints instructions and does not modify the system."

case "${1}" in
    -h|--help)
        echo "${USAGE_MESSAGE}"
        exit 0 ;;
esac

KERNEL_VERSION=$(uname -r 2>/dev/null)
if test -z "${KERNEL_VERSION}"; then
    KERNEL_VERSION="<uname -r>"
    WSL_BASE_VERSION="<wsl-kernel-version>"
else
    WSL_BASE_VERSION="${KERNEL_VERSION%%-*}"
fi
PWD_EXAMPLE='$PWD'

cat << EOF
WSL kernel build preparation steps for VirtualBox:

Detected WSL kernel version: ${KERNEL_VERSION}

1) Install the build dependencies (example for Ubuntu 24.04 WSL):
   sudo apt update && sudo apt upgrade --assume-yes
   sudo apt install --assume-yes build-essential flex bison dwarves libssl-dev \\
     libelf-dev cpio qemu-utils

2) Download the matching WSL2 kernel source (example):
   git clone --depth 1 --branch "linux-msft-wsl-${WSL_BASE_VERSION}" \\
     https://github.com/microsoft/WSL2-Linux-Kernel.git wsl2-kernel

3) Enter the source tree and ensure the config matches the running kernel
   (example using /proc/config.gz when available; otherwise use the WSL2 kernel
     tree config in arch/x86/configs/config-wsl):
   cd wsl2-kernel
   zcat /proc/config.gz > .config

4) Prepare the kernel build tree (headers_install alone is not enough):
   make prepare
   make modules_prepare

5) Point the module build link at the prepared source tree (example):
   sudo ln -snf "${PWD_EXAMPLE}" "/lib/modules/${KERNEL_VERSION}/build"
EOF
