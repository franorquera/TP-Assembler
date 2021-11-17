;*****************************************************************************
; Trabajo Numero 1 Organizacion del Computador                               ;
; Francisco Orquera Lorda, 105554                                            ;  
;*****************************************************************************

global	main
extern  puts
extern  printf
extern	gets
extern  fopen
extern  fclose
extern  fgets
extern  fputs
extern  sscanf

section .data
    msjIngresarOperando db "Ingrese un operando inicial por teclado",0
    msjOperandoIngresado db	"Usted ingreso: %s ",10,0

section .bss
    operandoInicial resb 500

section .text    

main:
    ; Pido por consola el ingreso del operando incial
    mov rcx, msjIngresarOperando
    sub	rsp, 32
	call puts
	add	rsp, 32

    mov rcx, operandoInicial
    sub rsp, 32
    call gets
    add rsp, 32
    
    mov rcx, msjOperandoIngresado
    mov rdx, operandoInicial
    sub	rsp, 32
	call printf
	add	rsp, 32

    ret