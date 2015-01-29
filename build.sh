#!/bin/sh

if [ -z $1 ];
then
	echo ""
	echo "  Usage:"
	echo "    `basename $0` $SERIAL_PORT_DEVICE"
	echo ""
	exit
fi



SERIAL_DEVICE=$1

PROJECT=`pwd`

SRC=$PROJECT/nodemcu-firmware
ESPTOOL=$PROJECT/esptool-ck/esptool
ESPTOOL_PY=$PROJECT/esptool_py/esptool.py


cd $SRC

#make clean
make

if [ $? -ne 0 ];
then
	echo ""
	echo "    COMPILE Failed!"
	echo ""
	exit
fi

cd $SRC/bin
$ESPTOOL -eo $SRC/app/.output/eagle/debug/image/eagle.app.v6.out -bo eagle.app.v6.flash.bin -bs .text -bs .data -bs .rodata -bc -ec
xtensa-lx106-elf-objcopy --only-section .irom0.text -O binary $SRC/app/.output/eagle/debug/image/eagle.app.v6.out eagle.app.v6.irom0text.bin

$ESPTOOL_PY --port $SERIAL_DEVICE write_flash \
              0x00000 eagle.app.v6.flash.bin \
              0x10000 eagle.app.v6.irom0text.bin \
              0x7c000 esp_init_data_default.bin \
              0x7e000 blank.bin
