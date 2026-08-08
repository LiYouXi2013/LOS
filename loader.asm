%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR

[bits 16]

db "27MARK11"

jmp main16

gdt:
;0描述符
	dd	0x00000000
	dd	0x00000000
;1描述符(4GB代码段描述符)
	dd	0x0000ffff
	dd	0x00cf9800
;2描述符(4GB数据段描述符)
	dd	0x0000ffff
	dd	0x00cf9200
;3描述符(28Kb的视频段描述符)
	dd	0x80000007
	dd	0x00c0920b

lgdt_value:
	dw $-gdt-1	;高16位表示表的最后一个字节的偏移（表的大小-1） 
	dd gdt		;低32位表示起始位置（GDT的物理地址）

SELECTOR_CODE	equ	0x0001<<3
SELECTOR_DATA	equ	0x0002<<3
SELECTOR_VIDEO	equ	0x0003<<3
STACK_TOP equ 0x90000


main16:
    mov byte [gs:0xA0],'['
    mov byte [gs:0xA2],'O'
    mov byte [gs:0xA4],'K'
    mov byte [gs:0xA6],']'
    mov byte [gs:0xA8],' '  
    mov byte [gs:0xAA],'L'
    mov byte [gs:0xAC],'O'
    mov byte [gs:0xAE],'A' 
    mov byte [gs:0xB0],'D'
    mov byte [gs:0xB2],'E'
    mov byte [gs:0xB4],'R'
    mov byte [gs:0xB6],'1'
    mov byte [gs:0xB8],'6'

    lgdt [lgdt_value]
	in al,0x92
	or al,0000_0010b
	out 0x92,al
	cli
	mov eax,cr0
	or eax,1
	mov cr0,eax
	
	jmp dword SELECTOR_CODE:main32

[bits 32]

main32:
    mov ax,SELECTOR_DATA
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x90000
    mov ax,SELECTOR_VIDEO
    mov gs,ax

    mov byte [gs:0xA0],'['
    mov byte [gs:0xA2],'O'
    mov byte [gs:0xA4],'K'
    mov byte [gs:0xA6],']'
    mov byte [gs:0xA8],' '  
    mov byte [gs:0xAA],'L'
    mov byte [gs:0xAC],'O'
    mov byte [gs:0xAE],'A' 
    mov byte [gs:0xB0],'D'
    mov byte [gs:0xB2],'E'
    mov byte [gs:0xB4],'R'
    mov byte [gs:0xB6],'3'
    mov byte [gs:0xB8],'2'

;页表
    