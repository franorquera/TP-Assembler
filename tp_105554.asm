;****************************************************************************;
; Trabajo Numero 1 Organizacion del Computador                               ;
; Francisco Orquera Lorda, 105554                                            ;  
;****************************************************************************;

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
    msjErrorRegistroInvalido db "El operando u operacion no es valido",0
    msjErrorOperandoInicialInvalido db "El operando ingresado es invalido",0
    registrosId dq 0

    ;resultadoParcial times 16 db ' '

    comparacionOperacionesUno db "1", 0 ; lo uso en el and
    comparacionOperacionesCero db "0", 0

    msjErrorPrueba db "ERRORRRRR",0

    ; Opcional msj debug:
    msjAperturaCorrecta db "El archivo se pudo abrir correctamente",0
    msjLecturaDeRegistro db "El registro esta siendo leido",0
    msjRegistroValido db "El operando y operacion es valido",0

    ; Lugar donde voy a copiar los registros:
    ;registros		times	0 	db ''	;Longitud total del registro: 17
	;  operando		times	16	db ' '
	;  operacion		times	1	db ' '

    ; Variables para comparar si los registros son validos:
    operacionesValidas db "XON",0
    operandosValidos db "01",0
    primerOperandoValido db "0",0
    segundoOperandoValido db "1",0
    resetOperacion db ' ',0

    bufferRegistro times 17 db ' ' 
    operando times 16 db ' '
    operacion times 1 db ' '

section .bss
    operandoInicial resb 16
    resultadoParcial resb 16
    registroValido resb 1
    datoValido resb 1 ; para que mierda tengo esto aca
    operacionAAplicar resb 1

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

    ; Chequeo que el operando ingresado sea valido
    mov byte[registroValido], "N" ; el registro comienza no siendo valido

    call validarOperandoInicial
    cmp byte[registroValido], "N"
    jle finValidarOperandoInicial

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
    mov rcx, bufferRegistro
    mov rdx, 18 ; lee 17 caracteres
    mov r8, [registrosId]
    sub		rsp,32
    call	fgets
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
    ;mov rcx, bufferRegistro
    ;sub		rsp,32
    ;call	puts
    ;add		rsp,32

    call copiarOperando

    mov rcx, operando
    sub		rsp,32
    call	puts
    add		rsp,32

    call copiarOperacion

    mov rcx, operacion
    sub		rsp,32
    call	puts
    add		rsp,32

    ; Valido los registros
    call validarRegistros
    
    ; Aplico los operandos entre el operando inicial y los del registro
    call aplicarOperacion

    mov rcx, resultadoParcial
    sub		rsp,32
    call	puts
    add		rsp,32
    
    call borrarContenidoOperacion ; CHEQUEAR ESTO!
    
    ; Leo el siguiente registro:
    jmp leerSiguienteRegistro
    call cerrarRegistros


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

;------------------------------------------------------
; Aplico la operacion entre los operandos
aplicarOperacion:
    ;1000111100001111 ACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    ;cmp byte[operacion], "N"
    cmp byte[operacion], "N"
    jle aplicarOperacionAnd

    ;cmp byte[operacion], "O"
    ;jle aplicarOperacionOr

    ;cmp byte[operacion], "X"
    ;jle aplicarOperacionXOr

    ret

    aplicarOperacionAnd:
    mov rbx, 0

     ; RESOLVER ESTO!
    mov rcx, operando
    sub	rsp,32
    call	puts
    add	rsp,32

    mov rcx, 16

    andProxComparacion:
    push rcx
    mov rcx, 1 ; comparacion
    lea rsi, [operandoInicial + rbx]
    lea rdi, [operando + rbx]
    cmpsb 
    je andSonIguales
    ; no son iguales
    lea rsi, [comparacionOperacionesCero]
    lea rdi, [resultadoParcial + rbx]
    movsb
    andProx:
    add rbx, 1
    pop rcx
    loop andProxComparacion
    ret


    andSonIguales:
    ; caso los dos son 1
    lea rdi, [comparacionOperacionesUno]
    cmpsb ; significa que es un 1
    je andAmbosSonUno
    ;caso los dos son 0
    lea rdi, [resultadoParcial + rbx]
    movsb
    jmp andProx
    ret

    andAmbosSonUno:
    lea rdi, [resultadoParcial + rbx]
    movsb
    jmp andProx
    ret

;------------------------------------------------------
; Validacion de los registros
validarRegistros:
    mov byte[registroValido], "N" ; el registro comienza no siendo valido

    call validarOperacion
    cmp byte[registroValido], "N"
    jle finValidarRegistro

    call validarOperando
    cmp byte[registroValido], "N"
    jle finValidarRegistro

    mov byte[registroValido], "S" ; si llego hasta aca quiere decir que el registro es valido

    mov rcx, msjRegistroValido
    sub		rsp,32
    call	puts
    add		rsp,32

    ret

;------------------------------------------------------
; Copio los valores del buffer al operando y la operacion
copiarOperando:
    mov rcx, 16
    lea rsi, [bufferRegistro]
    lea rdi, [operando]
    repe movsb 
    ret

copiarOperacion:
    mov rcx, 1
    mov rbx, 16
    lea rsi, [bufferRegistro + rbx]
    lea rdi, [operacion]
    repe movsb
    ret

;------------------------------------------------------
; Borro el contenido de la operacion para la nueva iteracion
borrarContenidoOperacion:
    mov rcx, 1
    lea rsi, [resetOperacion]
    lea rdi, [operacion]
    repe movsb
    ret


;------------------------------------------------------
; Validar Operando Inicial
validarOperandoInicial:
    mov byte[registroValido], "S"
    mov rbx, 0
    mov rcx, 16
    
    _proximaOperando:
    push rcx
    mov rcx, 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [primerOperandoValido]
    repe cmpsb
    pop rcx
    jne _segudnoOperando
    _proximaComparacion:
    add rbx, 1
    loop _proximaOperando
    mov byte[registroValido], "S"
    ret

    _segudnoOperando:
    lea rsi, [operandoInicial + rbx]
    lea rdi, [segundoOperandoValido]
    cmpsb
    jne _operandoNoValido
    jmp _proximaComparacion

    _operandoNoValido:
    mov byte[registroValido], "N"
    ret

;------------------------------------------------------
;VALIDAR Operando
validarOperando:
    mov byte[registroValido], "S"
    mov rbx, 0
    mov rcx, 16
    
    proximaOperando:
    push rcx
    mov rcx, 1
    lea rsi, [operando + rbx]
    lea rdi, [primerOperandoValido]
    repe cmpsb
    pop rcx
    jne segudnoOperando
    proximaComparacion:
    add rbx, 1
    loop proximaOperando
    mov byte[registroValido], "S"
    ret

    segudnoOperando:
    lea rsi, [operando + rbx]
    lea rdi, [segundoOperandoValido]
    cmpsb
    jne operandoNoValido
    jmp proximaComparacion

    operandoNoValido:
    mov byte[registroValido], "N"
    ret

;------------------------------------------------------
;VALIDAR Operacion
validarOperacion:
    mov byte[registroValido], "S"
    mov rbx, 0
    mov rcx, 3 ; para el loop --> 3 operanods en total
    
    proximaOperacion:
    push rcx ; me guardo el 3 del loop
    mov rcx, 1 ; saltos que pego para comparar
    lea rsi, [operacion]
    lea rdi, [operacionesValidas + rbx]
    repe cmpsb
    pop rcx ; vuelve el valor del loop

    je operacionOk ; si lo encontre dejo de iterar
    add rbx, 1
    ; genero el ciclo:
    loop proximaOperacion
    mov byte[registroValido], "N"

    operacionOk:
    ret

;------------------------------------------------------
; Mensajes de Error
finValidarOperandoInicial:
    mov rcx, msjErrorOperandoInicialInvalido
    sub		rsp,32
    call	puts
    add		rsp,32
    ret

finValidarRegistro:
    mov rcx, msjErrorRegistroInvalido
    sub		rsp,32
    call	puts
    add		rsp,32
    ret