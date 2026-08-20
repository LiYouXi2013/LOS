%include "../include/macros.inc"

section loader vstart=LOADER_BASE_ADDR

[bits 16]

db "27MARK11" ;检测是否加载成功的标识

jmp main16

gdt:
;0描述符
	dd	0x00000000
	dd	0x00000000
;1描述符(32bit代码段描述符)
	dd	0x0000ffff
	dd	0x00cf9800
;2描述符(32bit数据段描述符)
	dd	0x0000ffff
	dd	0x00cf9200
;3描述符(28Kb的视频段描述符)
    dd	0x80006fff
    dd	0x0040920b

lgdt_value:
	dw $-gdt-1	;高16位表示表的最后一个字节的偏移（表的大小-1） 
	dd gdt		;低32位表示起始位置（GDT的物理地址）

idt_ptr:
    dw IDT_LIMIT
    dd IDT_BASE

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
    mov byte [gs:0xB8],'1'
    mov byte [gs:0xBA],'6'

    lgdt [lgdt_value]
	in al,0x92
	or al,0000_0010b
	out 0x92,al
	cli
	mov eax,cr0
	or eax,1
	mov cr0,eax
	
	jmp dword SELECTOR_CODE32:main32

[bits 32]

main32:
    mov ax,SELECTOR_DATA32
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov esp,0x90000
    mov ax,SELECTOR_VIDEO
    mov gs,ax

    call init_idt
    lidt [idt_ptr]

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
    mov byte [gs:0xB8],'3'
    mov byte [gs:0xBA],'2'

    db 0x0f,0x0b

.halt:
    hlt
    jmp .halt

init_idt:
    mov edi,IDT_BASE
    mov ecx,256
    mov ebx,exception_default

.set_gate:
    mov eax,ebx
    mov word [edi],ax
    mov word [edi+2],SELECTOR_CODE32
    mov byte [edi+4],0
    mov byte [edi+5],0x8e
    shr eax,16
    mov word [edi+6],ax
    add edi,8
    loop .set_gate
    ret

exception_default:
    cli
    mov ax,SELECTOR_VIDEO
    mov gs,ax
    mov word [gs:0xF00],0x4f5b
    mov word [gs:0xF02],0x4f45
    mov word [gs:0xF04],0x4f58
    mov word [gs:0xF06],0x4f43
    mov word [gs:0xF08],0x4f45
    mov word [gs:0xF0A],0x4f50
    mov word [gs:0xF0C],0x4f54
    mov word [gs:0xF0E],0x4f5d

.halt:
    hlt
    jmp .halt
