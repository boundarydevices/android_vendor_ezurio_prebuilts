#!/bin/sh

help() {
cat << EOF

Usage: $0 <options>

options:
  -h                displays this help message
  -d <directory>    the directory of images (default: \$OUT)
  -D                disables verity verification
  -u                do NOT erase userdata during the flashing process

EOF
}

# Parse parameters
skip_userdata=0
disable_verity=""
while [ $# -gt 0 ]; do
	case $1 in
		-h) help; exit ;;
		-d) OUT=$2; shift;;
		-D) disable_verity="--disable-verity";;
		-p) product=$2; shift;;
		-u) skip_userdata=1 ;;
		*)  echo "$1 is not a known option";
			help; exit;;
	esac
	shift
done

if [ -z "$OUT" ]; then OUT=$PWD; fi

fastboot flash mmc0 $OUT/MBR_EMMC
if ! [ $? -eq 0 ] ; then echo "Failed to flash GPT"; exit 1; fi
fastboot flash mmc0boot0 $OUT/mtk-boot.bin
if ! [ $? -eq 0 ] ; then echo "Failed to flash BL2"; exit 1; fi
fastboot flash mmc0boot1 $OUT/u-boot-env.bin
if ! [ $? -eq 0 ] ; then echo "Failed to flash uboot env"; exit 1; fi
fastboot flash bootloaders $OUT/bootloaders.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash bootloaders"; exit 1; fi
fastboot flash persist $OUT/persist.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash persist"; exit 1; fi
fastboot flash boot_a $OUT/boot.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash boot"; exit 1; fi
fastboot flash init_boot_a $OUT/init_boot.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash init_boot"; exit 1; fi
fastboot flash vendor_boot_a $OUT/vendor_boot.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash vendor_boot"; exit 1; fi
fastboot flash dtbo_a $OUT/dtbo.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash dtbo"; exit 1; fi
fastboot flash vbmeta_a $OUT/vbmeta.img $disable_verity
if ! [ $? -eq 0 ] ; then echo "Failed to flash vbmeta"; exit 1; fi
fastboot flash vbmeta_vendor_dlkm_a $OUT/vbmeta_vendor_dlkm.img $disable_verity
if ! [ $? -eq 0 ] ; then echo "Failed to flash vbmeta_vendor_dlkm"; exit 1; fi
fastboot flash super $OUT/super.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash super"; exit 1; fi
if ! [ ${skip_userdata} -eq 1 ] ; then
	fastboot erase userdata
	if ! [ $? -eq 0 ] ; then echo "Failed to erase userdata"; exit 1; fi
	fastboot erase metadata
	if ! [ $? -eq 0 ] ; then echo "Failed to erase metadata"; exit 1; fi
	fastboot erase misc
	if ! [ $? -eq 0 ] ; then echo "Failed to erase misc"; exit 1; fi
fi
fastboot reboot
