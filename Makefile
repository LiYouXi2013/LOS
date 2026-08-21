.SILENT:

all: run

compile: 
	echo =================== Compile ===================
	nasm src/boot/boot.asm -i src/include/ -o build/boot.bin -l debug/boot.lst
	nasm src/loader/loader.asm -i src/include/ -o build/loader.bin -l debug/loader.lst

build: compile
	echo =================== Build =====================
	dd if=/dev/zero of=build/LOS.img bs=512 count=16
	dd if=build/boot.bin of=build/LOS.img
	dd if=build/loader.bin of=build/LOS.img seek=1

run: build
	echo =================== Run =======================
	qemu-system-i386 -drive format=raw,file=build/LOS.img