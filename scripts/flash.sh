#!/bin/sh

help() {
cat << EOF

Usage: $0 <options>

options:
  -h                displays this help message
  -d <directory>    the directory of images (default: \$ANDROID_PRODUCT_OUT)
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
		-d) ANDROID_PRODUCT_OUT=$2; shift;;
		-D) disable_verity="--disable-verity";;
		-p) product=$2; shift;;
		-u) skip_userdata=1 ;;
		*)  echo "$1 is not a known option";
			help; exit;;
	esac
	shift
done

if [ -z "$ANDROID_PRODUCT_OUT" ]; then ANDROID_PRODUCT_OUT=$PWD; fi

fastboot flash mmc0 $ANDROID_PRODUCT_OUT/MBR_EMMC
if ! [ $? -eq 0 ] ; then echo "Failed to flash GPT"; exit 1; fi
fastboot flash mmc0boot0 $ANDROID_PRODUCT_OUT/mtk-boot.bin
if ! [ $? -eq 0 ] ; then echo "Failed to flash BL2"; exit 1; fi
fastboot flash mmc0boot1 $ANDROID_PRODUCT_OUT/u-boot-env.bin
if ! [ $? -eq 0 ] ; then echo "Failed to flash uboot env"; exit 1; fi
fastboot flash bootloaders $ANDROID_PRODUCT_OUT/bootloaders.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash bootloaders"; exit 1; fi
fastboot flash persist $ANDROID_PRODUCT_OUT/persist.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash persist"; exit 1; fi
fastboot flashall --force --skip-reboot $disable_verity
if ! [ $? -eq 0 ] ; then echo "Failed to flash the OS, check your fastboot tool version!"; exit 1; fi
if ! [ ${skip_userdata} -eq 1 ] ; then
	fastboot reboot bootloader
	fastboot erase userdata
	if ! [ $? -eq 0 ] ; then echo "Failed to erase userdata"; exit 1; fi
	fastboot erase metadata
	if ! [ $? -eq 0 ] ; then echo "Failed to erase metadata"; exit 1; fi
	fastboot erase misc
	if ! [ $? -eq 0 ] ; then echo "Failed to erase misc"; exit 1; fi
fi
fastboot reboot
