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
    msjOperandoIngresado db	"Usted ingreso el operando inicial: %s ",10,0
    archivoRegistros db "registros.txt",0
    modoLecturaRegistros db "r",0
    msjErrorAperturaRegistros db "Error al intentar abrir el archivo Registros",0
    registrosId dq 0

    ; Opcional msj debug:
    msjAperturaCorrecta db "El archivo se pudo abrir correctamente",0
    msjLecturaDeRegistro db "El registro esta siendo leido",0

    ; Lugar donde voy a copiar los registros:
    registros		times	0 	db ''	;Longitud total del registro: 17
	  operando		times	16	db ' '
	  operacion		times	1	db ' '

section .bss
    operandoInicial resb 16
    registroValido resb 1
    datoValido resb 1

section .text    

main:
    mov rcx, operandoInicial
    sub rsp, 32
    call gets
    add rsp, 32
    
    mov rcx, msjOperandoIngresado
    mov rdx, operandoInicial
    sub	rsp, 32
	call printf
	add	rsp, 32

    ; Abro el archivo con los operando
    mov rcx, archivoRegistros
    mov rdx, modoLecturaRegistros
    sub		rsp,32
	call	fopen
	add		rsp,32

    cmp rax, 0
    jle errorAbrirRegistros
    mov [registrosId], rax

    mov rcx, msjAperturaCorrecta
    sub		rsp,32
    call	puts
    add		rsp,32

    ; Empiezo a leer el registro
leerSiguienteRegistro:
    mov rcx, registros
    mov rdx, 17
    mov r8, [registrosId]
    sub		rsp,32
    call	fgets ; AHHHHHHHHHHHHHHHHHHHHHHHHHH
    add		rsp,32
    
    ; Llegue al final del archivo?
    cmp rax, 0
    jle cerrarRegistros


    ; Mensaje de lectura de un SOLO registro:
    mov rcx, msjLecturaDeRegistro
    sub		rsp,32
    call	puts
    add		rsp,32

    ; Solo para chequear, imprimo el operando y la operacion
    mov rcx, operando
    sub		rsp,32
    call	puts
    add		rsp,32

    mov rcx, operacion
    sub		rsp,32
    call	puts
    add		rsp,32


    ; Valido los registros
    ;call validarRegistros

    ; Leo el siguiente registro:
    jmp leerSiguienteRegistro

errorAbrirRegistros:
        mov rcx, msjErrorAperturaRegistros
        sub		rsp,32
        call	puts
        add		rsp,32
        jmp terminarPrograma

cerrarRegistros:
        mov rcx, [registrosId]
        sub		rsp,32
        call	fclose
        add		rsp,32
        jmp terminarPrograma

terminarPrograma:
        ret

validarRegistros:
    mov byte[registroValido], "N" ; el registro comienza no siendo valido

    call validarOperando
    cmp byte[datoValido], "N"
    jle finValidarRegistro

    call validarOperacion
    mov byte[registroValido], "S" ; si llego hasta aca quiere decir que el registro es valido

finValidarRegistro:
    ret

validarOperando:
    mov byte[registroValido], "S"

    ret

validarOperacion:

    ret

