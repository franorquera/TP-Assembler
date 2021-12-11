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
    ; Mensajes y manejo de archivos
    archivoRegistros db "registros.txt",0
    modoLecturaRegistros db "r",0
    msjErrorAperturaRegistros db "❌Error al intentar abrir el archivo Registros",0
    msjErrorRegistroInvalido db "❌El operando u operacion no es valido",0
    msjErrorOperandoInicialInvalido db "❌El operando ingresado es invalido",0
    msjFinDelPrograma db "Fin del programa", 0
    registrosId dq 0
    
    ; Mensajes para imprimir las operaciones entre registros
    msjOperandoInicial db "➜ Operando inical = %s",10,10,0
    msjOperandoRegistro db "◉ Operando Registro %lli = %s",10,0
    msjOperacionRegistro db "◉ Operacion Registro %lli = %s",10,0
    msjResultadoParcial db "✅Resultado Parcial = %s",10,10,0
    cantidadRegistros dq 1

    ; Comparacion para las operaciones
    comparacionOperacionesUno db "1", 0
    comparacionOperacionesCero db "0", 0

    ; Variables para comparar si los registros son validos:
    operacionesValidas db "XON",0
    primerOperandoValido db "0",0
    segundoOperandoValido db "1",0
    resetOperacion db ' ',0

    ; Lugar donde voy a copiar los registros:
    bufferRegistro times 17 db ' ' 
    operando times 16 db ' ', 0
    operacion times 1 db ' ', 0

    ; Resultado parcial y operando inicial
    resultadoParcial times 16 db ' ', 0
    operandoInicial times 16 db ' ', 0

section .bss
    registroValido resb 1
    operacionAAplicar resb 1

section .text    

main:
    mov rcx, operandoInicial
    sub rsp, 32
    call gets
    add rsp, 32

    mov rcx, msjOperandoInicial
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

    call copiarOperando

    mov rcx, msjOperandoRegistro
    mov rdx, [cantidadRegistros]
    mov r8, operando
    sub	rsp, 32
	call printf
	add	rsp, 32

    call copiarOperacion

    mov rcx, msjOperacionRegistro
    mov rdx, [cantidadRegistros]
    mov r8, operacion
    sub	rsp, 32
	call printf
	add	rsp, 32

    ; Valido los registros
    call validarRegistros
    
    ; Aplico los operandos entre el operando inicial y los del registro
    call aplicarOperacion

    ; Imprimo el resultado parcial por pantalla
    mov rcx, msjResultadoParcial
    mov rdx, resultadoParcial
    sub	rsp, 32
	call printf
	add	rsp, 32

    ; me guardo el resultado parcial en el operando inicial para la prox operacion
    mov rcx, 16
    lea rsi, [resultadoParcial]
    lea rdi, [operandoInicial]
    repe movsb
    
    ; borro el contenido xq si no se pisa
    call borrarContenidoOperacion
    
    ; Leo el siguiente registro:
    mov rbx, [cantidadRegistros]
    add rbx, 1
    mov [cantidadRegistros], rbx
    jmp leerSiguienteRegistro

;------------------------------------------------------
; Error y finalizacion del programa
errorAbrirRegistros:
    mov rcx, msjErrorAperturaRegistros
    sub	rsp,32
    call puts
    add	rsp,32
    jmp terminarPrograma

cerrarRegistros:
    mov rcx, [registrosId]
    sub	rsp,32
    call fclose
    add	rsp,32
    jmp terminarPrograma

terminarPrograma:
    mov rcx, msjFinDelPrograma
    sub rsp, 32
    call puts
    add rsp, 32
    ret

;------------------------------------------------------
; Aplico la operacion entre los operandos
aplicarOperacion:
    cmp byte[operacion], "N"
    jle aplicarOperacionAnd

    cmp byte[operacion], "O"
    jle aplicarOperacionOr

    cmp byte[operacion], "X"
    jle aplicarOperacionXOr

    ret

; Aplico la operacion And entre los operandos
    aplicarOperacionAnd:
    mov rbx, 0
    mov rcx, 16

    andProxComparacion:
    push rcx
    mov rcx, 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [operando + rbx]
    cmpsb 
    je andSonIguales
    ; no son iguales
    lea rsi, [comparacionOperacionesCero] ; agrego un cero
    lea rdi, [resultadoParcial + rbx]
    movsb
    andProx:
    add rbx, 1
    pop rcx
    loop andProxComparacion
    ret

    andSonIguales:
    ; caso los dos son 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [comparacionOperacionesUno]
    cmpsb
    je andAmbosSonUno ; significa que es un 1
    ;caso los dos son 0
    lea rsi, [operandoInicial + rbx] ; agrego un cero
    lea rdi, [resultadoParcial + rbx] 
    movsb
    jmp andProx

    andAmbosSonUno:
    lea rsi, [comparacionOperacionesUno] ; agrego un uno
    lea rdi, [resultadoParcial + rbx]
    movsb
    jmp andProx

; Aplico la operacion Or entre los operandos
    aplicarOperacionOr:
    mov rbx, 0
    mov rcx, 16

    orProxComparacion:
    push rcx
    mov rcx, 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [operando + rbx]
    cmpsb 
    je orSonIguales
    ; no son iguales
    lea rsi, [comparacionOperacionesUno]
    lea rdi, [resultadoParcial + rbx]
    movsb
    orProx:
    add rbx, 1
    pop rcx
    loop orProxComparacion
    ret

    orSonIguales:
    ; caso los dos son 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [comparacionOperacionesUno]
    cmpsb
    je orAmbosSonUno ; significa que es un 1
    ;caso los dos son 0
    lea rsi, [operandoInicial + rbx] ; agrego el cero
    lea rdi, [resultadoParcial + rbx] 
    movsb
    jmp orProx

    orAmbosSonUno:
    lea rsi, [comparacionOperacionesUno]
    lea rdi, [resultadoParcial + rbx]
    movsb
    jmp orProx

; Aplico la operacion Xor entre los operandos
    aplicarOperacionXOr:
    mov rbx, 0
    mov rcx, 16

    xOrProxOperacion:
    push rcx
    mov rcx, 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [operando + rbx]
    cmpsb 
    je xOrSonIguales
    ; no son iguales
    lea rsi, [comparacionOperacionesUno] ; agrego un uno
    lea rdi, [resultadoParcial + rbx]
    movsb
    xOrProx:
    add rbx, 1
    pop rcx
    loop xOrProxOperacion
    ret

    xOrSonIguales:
    ; caso los dos son 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [comparacionOperacionesUno]
    cmpsb
    je xOrAmbosSonUno ; significa que es un 1
    ;caso los dos son 0
    lea rsi, [operandoInicial + rbx] ; agrego el cero
    lea rdi, [resultadoParcial + rbx] 
    movsb
    jmp xOrProx

    xOrAmbosSonUno:
    lea rsi, [comparacionOperacionesCero] ; agrego un cero
    lea rdi, [resultadoParcial + rbx]
    movsb
    jmp xOrProx

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
    
    _proximoOperando:
    push rcx
    mov rcx, 1
    lea rsi, [operandoInicial + rbx]
    lea rdi, [primerOperandoValido]
    repe cmpsb
    pop rcx
    jne _segudnoOperando
    _proximaComparacion:
    add rbx, 1
    loop _proximoOperando
    mov byte[registroValido], "S" ; PUEDO SACAR ESTO ????
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
    
    proximoOperando:
    push rcx
    mov rcx, 1
    lea rsi, [operando + rbx]
    lea rdi, [primerOperandoValido]
    repe cmpsb
    pop rcx
    jne segudnoOperando
    proximaComparacion:
    add rbx, 1
    loop proximoOperando
    mov byte[registroValido], "S" ; PUEDO SACAR ESTO????
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
    mov rcx, 3 ; 3 operandos en total
    
    proximaOperacion:
    push rcx
    mov rcx, 1
    lea rsi, [operacion]
    lea rdi, [operacionesValidas + rbx]
    repe cmpsb
    pop rcx

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