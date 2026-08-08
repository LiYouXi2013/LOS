compile:
	./tools/nasm boot.asm -o boot.bin
	./tools/nasm loader.asm -o loader.bin

build: boot.bin
	./tools/dd if=/dev/zero of=./LOS.img bs=512 count=16
	./tools/dd conv=notrunc if=boot.bin of=LOS.img
	./tools/dd conv=notrunc if=loader.bin of=LOS.img seek=1

run: LOS.img
	./tools/qemu-system-i386 LOS.img

all: compile build run
	
debug: compile build
	start_debug.bat
	