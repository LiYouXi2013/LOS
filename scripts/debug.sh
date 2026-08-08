#!/bin/bash

qemu-system-i386 build/LOS.img -s -S -d int,mmu
