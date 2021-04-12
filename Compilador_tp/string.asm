;************************************************************
; devuelve en BX la cantidad de caracteres que tiene un string
; DS:SI apunta al string.
;************************************************************
STRLEN PROC
    mov bx,0

STRL01:
    cmp BYTE PTR [SI+BX],'$'
    je STREND
    inc BX
    jmp STRL01
STREND:
    ret

STRLEN ENDP

;************************************************************
; copia DS:SI a ES:DI; busca la cantidad de caracteres
;************************************************************
COPIAR PROC
    call STRLEN    ; busco la cantidad de caracteres
    cmp bx,MAXTEXTSIZE
    jle COPIARSIZEOK

    mov bx,MAXTEXTSIZE

COPIARSIZEOK:
    mov cx,bx
    cld

    rep movsb
    mov al,'$'
    mov BYTE PTR [DI],al

    ret
COPIAR ENDP
