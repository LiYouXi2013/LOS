%include "boot.inc"

org 0x7c00

db "27MARK11"

jmp start

rdsk:
    mov esi,eax
    mov di,cx
    
    ;设置欲读取扇区数量
        mov dx,0x1f2
        mov al,cl
        out dx,al

        mov eax,esi ;恢复

    ;写LBA地址
        mov dx,0x1f3
        out dx,al

        mov cl,8
        shr eax,cl
        mov dx,0x1f4
        out dx,al
        
        shr eax,cl
        mov dx,0x1f5
        out dx,al

        shr eax,cl
        and al,0x0f
        or al,0xe0
        mov dx,0x1f6
        out dx,al

    ;写"写"指令
        mov dx,0x1f7
        mov al,0x20
        out dx,al
    
    ;检测状态
    .not_ready:
        nop
        in al,dx
        and al,0x88
        cmp al,0x08
        jnz .not_ready

    ;从0x1f0读数据
        mov ax,di
        mov dx,256
        mul dx
        mov cx,ax

        mov dx,0x1f0

    .go_on_read:
        in ax,dx
        mov [bx],ax
        add bx,2
        
        loop .go_on_read
        ret
    

;============== 主程序 ==============
start:
    ;Init
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    mov ax,0xb800
    mov gs,ax

    mov ah,06h
    mov al,00h
    mov bh,02h
    mov cx,0x0000
    mov dx,0x184F
    int 10h

    mov byte [gs:0x00],'['
    mov byte [gs:0x02],'O'
    mov byte [gs:0x04],'K'
    mov byte [gs:0x06],']'
    mov byte [gs:0x08],' '
    mov byte [gs:0x0A],'M'
    mov byte [gs:0x0C],'B'
    mov byte [gs:0x0E],'R'

    ;Read Loader
    mov eax,LOADER_START_SECTOR	 ; 起始扇区lba地址
    mov bx,LOADER_BASE_ADDR       ; 写入的内存地址
    mov cx,LOADER_SECTORS	 ; 待读入的扇区数
    call rdsk		

    mov ebp,0

    mov ebp,[LOADER_BASE_ADDR]
    cmp ebp,0x414d3732

    jne Error

    jmp 0x0000:LOADER_BASE_ADDR

Error:

    mov byte [gs:0xA0],'['
    mov byte [gs:0xA1],0x04

    mov byte [gs:0xA2],'F'
    mov byte [gs:0xA3],0x04
    
    mov byte [gs:0xA4],'A'
    mov byte [gs:0xA5],0x04

    mov byte [gs:0xA6],'I'
    mov byte [gs:0xA7],0x04

    mov byte [gs:0xA8],'L'
    mov byte [gs:0xA9],0x04

    mov byte [gs:0xAA],']'
    mov byte [gs:0xAB],0x04

    mov byte [gs:0xAC],'L'
    mov byte [gs:0xAD],0x04

    mov byte [gs:0xAE],'O'
    mov byte [gs:0xAF],0x04

    mov byte [gs:0xB0],'A'
    mov byte [gs:0xB1],0x04

    mov byte [gs:0xB2],'D'
    mov byte [gs:0xB3],0x04

    mov byte [gs:0xB4],' '
    mov byte [gs:0xB5],0x04

    mov byte [gs:0xB6],'L'
    mov byte [gs:0xB7],0x04

    mov byte [gs:0xB8],'O'
    mov byte [gs:0xB9],0x04

    mov byte [gs:0xBA],'A'
    mov byte [gs:0xBB],0x04

    mov byte [gs:0xBC],'D'
    mov byte [gs:0xBD],0x04

    mov byte [gs:0xBE],'E'
    mov byte [gs:0xBF],0x04

    mov byte [gs:0xCA],'R'
    mov byte [gs:0xCB],0x04
    
    

halt:
    hlt
    jmp halt

times 446 - ($-$$) db 0

;分区表
times 16 db 0
times 16 db 0
times 16 db 0
times 16 db 0

dw 0xaa55