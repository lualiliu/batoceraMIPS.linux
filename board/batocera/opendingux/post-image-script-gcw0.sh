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

for each in \
	${BINARIES_DIR}/uzImage.bin \
	${BINARIES_DIR}/modules.squashfs \
	${BINARIES_DIR}/rootfs.squashfs \
	${BINARIES_DIR}/mininit-syspart \
	${BINARIES_DIR}/ubiboot-*.bin \
	${BINARIES_DIR}/*.dtb
do
	if [ -r $each ] ; then
		each_name=`basename $each`
		cp -lf $each ${BINARIES_DIR}/boot/${each_name}
		each_sha1=${BINARIES_DIR}/boot/${each_name}.sha1
		sha1sum $each | cut -d' ' -f1 > $each_sha1
	fi
done

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
