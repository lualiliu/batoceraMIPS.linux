#!/bin/bash -e

# HOST_DIR = host dir
# BOARD_DIR = board specific dir
# BUILD_DIR = base dir/build
# BINARIES_DIR = images dir
# TARGET_DIR = target dir
# BATOCERA_BINARIES_DIR = batocera binaries sub directory
# BATOCERA_TARGET_DIR = batocera target sub directory

HOST_DIR=$1
BOARD_DIR=$2
BUILD_DIR=$3
BINARIES_DIR=$4
TARGET_DIR=$5
BATOCERA_BINARIES_DIR=$6
BATOCERA_TARGET_DIR=$7

# /boot
rm -rf "${BINARIES_DIR}/boot"     || exit 1
mkdir -p "${BINARIES_DIR}/boot"     || exit 1

mkdir "${BINARIES_DIR}/boot/proc"     || exit 1
mkdir "${BINARIES_DIR}/boot/dev"     || exit 1
mkdir "${BINARIES_DIR}/boot/root"     || exit 1

# boot.tar.xz
cp "${BINARIES_DIR}/rootfs.squashfs" "${BINARIES_DIR}/boot/batocera" || exit 1
cp "${BINARIES_DIR}/uzImage.bin"                "${BINARIES_DIR}/boot/uzImage.bin.source"                || exit 1
cp "${BOARD_DIR}/mininit-syspart" "${BINARIES_DIR}/boot/mininit-syspart"   || exit 1
cp "${BOARD_DIR}/batocera-boot.conf" "${BINARIES_DIR}/boot/batocera-boot.conf" || exit 1
cp "${BOARD_DIR}/ubiboot.bin" "${BINARIES_DIR}/boot/ubiboot.bin" || exit 1
cp "${BINARIES_DIR}/gcw0_proto.dtb" "${BINARIES_DIR}/boot/gcw0_proto.dtb" || exit 1
cp "${BINARIES_DIR}/gcw0.dtb" "${BINARIES_DIR}/boot/gcw0.dtb" || exit 1
cp "${BINARIES_DIR}/rg350.dtb" "${BINARIES_DIR}/boot/rg350.dtb" || exit 1
cp "${BINARIES_DIR}/rg350m.dtb" "${BINARIES_DIR}/boot/rg350m.dtb" || exit 1
cp "${BINARIES_DIR}/rg280m.dtb" "${BINARIES_DIR}/boot/rg280m.dtb" || exit 1
cp "${BINARIES_DIR}/rg280v.dtb" "${BINARIES_DIR}/boot/rg280v.dtb" || exit 1
cp -pr "${BINARIES_DIR}/tools"             "${BINARIES_DIR}/boot/"                     || exit 1



# model select(rg350,rg350m,rg280m,rg280v,gcw0(no test))
cat "${BINARIES_DIR}/boot/uzImage.bin.source" "${BINARIES_DIR}/boot/rg280v.dtb" > "${BINARIES_DIR}/boot/uzImage.bin" || exit 1
# boot.tar.xz
#echo "creating boot.tar.xz"
#(cd "${BINARIES_DIR}/boot" && tar -I "xz -T0" -cf "${BATOCERA_BINARIES_DIR}/boot.tar.xz" batocera mininit-syspart batocera-boot.conf uzImage.bin tools gcw0_proto.dtb gcw0.dtb rg350.dtb rg350m.dtb rg280m.dtb rg280v.dtb proc dev root) || exit 1

# batocera.img
# rename the squashfs : the .update is the version that will be renamed at boot to replace the old version
#mv "${BINARIES_DIR}/boot/boot/batocera.update" "${BINARIES_DIR}/boot/boot/batocera" || exit 1
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
BATOCERAIMG="${BATOCERA_BINARIES_DIR}/batocera.img"
rm -rf "${GENIMAGE_TMP}" || exit 1
cp "${BOARD_DIR}/genimage.cfg" "${BINARIES_DIR}" || exit 1
echo "generating image"
genimage --rootpath="${TARGET_DIR}" --inputpath="${BINARIES_DIR}/boot" --outputpath="${BATOCERA_BINARIES_DIR}" --config="${BINARIES_DIR}/genimage.cfg" --tmppath="${GENIMAGE_TMP}" || exit 1
rm -f "${BATOCERA_BINARIES_DIR}/boot.vfat" || exit 1
rm -f "${BATOCERA_BINARIES_DIR}/userdata.ext4" || exit 1
sync || exit 1
