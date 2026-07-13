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
wipe_userdata="-w"
disable_verity=""
while [ $# -gt 0 ]; do
	case $1 in
		-h) help; exit ;;
		-d) export ANDROID_PRODUCT_OUT=$2; shift;;
		-D) disable_verity="--disable-verity";;
		-p) product=$2; shift;;
		-u) wipe_userdata="" ;;
		*)  echo "$1 is not a known option";
			help; exit;;
	esac
	shift
done

if [ -z "$ANDROID_PRODUCT_OUT" ]; then export ANDROID_PRODUCT_OUT=$PWD; fi

fastboot flash mmc0 $ANDROID_PRODUCT_OUT/MBR_EMMC
if ! [ $? -eq 0 ] ; then echo "Failed to GPT"; exit 1; fi
fastboot flash mmc0boot0 $ANDROID_PRODUCT_OUT/mtk-boot.bin
if ! [ $? -eq 0 ] ; then echo "Failed to flash BL2"; exit 1; fi
fastboot flash mmc0boot1 $ANDROID_PRODUCT_OUT/u-boot-env.bin
if ! [ $? -eq 0 ] ; then echo "Failed to flash uboot env"; exit 1; fi
fastboot flash bootloaders $ANDROID_PRODUCT_OUT/bootloaders.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash bootloaders"; exit 1; fi
fastboot flash persist $ANDROID_PRODUCT_OUT/persist.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash persist"; exit 1; fi
fastboot flash boot_a $ANDROID_PRODUCT_OUT/boot.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash boot"; exit 1; fi
fastboot flash init_boot_a $ANDROID_PRODUCT_OUT/init_boot.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash boot"; exit 1; fi
fastboot flash dtbo_a $ANDROID_PRODUCT_OUT/dtbo.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash boot"; exit 1; fi
fastboot flash vendor_boot_a $ANDROID_PRODUCT_OUT/vendor_boot.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash vendor_boot"; exit 1; fi
fastboot flash vbmeta_a $ANDROID_PRODUCT_OUT/vbmeta.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash vbmeta"; exit 1; fi
fastboot flash vbmeta_vendor_dlkm_a $ANDROID_PRODUCT_OUT/vbmeta_vendor_dlkm.img
if ! [ $? -eq 0 ] ; then echo "Failed to flash vbmeta_vendor_dlkm"; exit 1; fi
fastboot flashall --force --skip-reboot $wipe_userdata $disable_verity
if ! [ $? -eq 0 ] ; then echo "Failed to flashall"; exit 1; fi
fastboot erase metadata
if ! [ $? -eq 0 ] ; then echo "Failed to erase metadata"; exit 1; fi
fastboot erase misc
if ! [ $? -eq 0 ] ; then echo "Failed to erase misc"; exit 1; fi
fastboot reboot
