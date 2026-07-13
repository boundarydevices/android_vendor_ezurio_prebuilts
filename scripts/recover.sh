#!/bin/sh

if [ -z "$ANDROID_PRODUCT_OUT" ]; then export ANDROID_PRODUCT_OUT=$PWD; fi

fastboot erase mmc0
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
fastboot erase metadata
fastboot erase misc
fastboot erase userdata

