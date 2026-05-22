# =================================================================
# TETRIS - MIPS Assembly para FPGA MimasV2
# Adaptado para proyecto BlockBreaker (vga_gen_imagen formato word)
# =================================================================
#
# ARQUITECTURA DE PANTALLA:
#   Pantalla fisica : 24 filas x 32 columnas de pixeles
#   Tablero logico  : 28 filas x 12 columnas
#     - Filas  0..3  : zona oculta (aparicion de piezas)
#     - Filas  4..27 : zona visible (24 filas en pantalla)
#     - Fila   27    : piso solido
#   Bordes laterales: columnas 0 y 11 en filas 0..26
#
# FORMATO VGA (BlockBreaker):
#   Buffer: 24 words de 32 bits (1 word por fila visible)
#   Escritura: sw <word>, 0(dirVGA + fila*4)
#   Bit [31-col_pantalla] = pixel de la columna col_pantalla
#   Tablero (cols 0..11) -> pantalla cols 10..21 -> bits 21..10
#
# MAPA DE MEMORIA (base en $s4 = 0x10010000):
#   offset   0 : dirVGA        -> 0xFFFFA000
#   offset   4 : dir7seg       -> 0xFFFFE000
#   offset   8 : dirEntradas   -> 0xFFFFD000
#   offset  12 : dirMillis     -> 0xFFFFB000
#   offset  16 : filaActual    (fila logica de la pieza)
#   offset  20 : colActual     (columna de la pieza)
#   offset  24 : tablaPieza[4][4]  -> 16 words = 64 bytes
#   offset  88 : tablero[28][12]   -> 336 words = 1344 bytes
#   offset 1432: guardaRA      (almacenamiento temporal de $ra)
#
# CONTROLES (switches):
#   bit 0 : mover izquierda
#   bit 1 : mover derecha
#   bit 2 : bajar rapido (acelera caida mientras se mantiene)
#   bit 3 : rotar
#
# REGISTRO GLOBAL:
#   $s4 = base de datos del juego
# =================================================================

# -----------------------------------------------------------------
# INICIO: configurar base de datos y perifericos
# -----------------------------------------------------------------
inicio:
    lui  $s4, 0x1001
    ori  $s4, $s4, 0x0000      # $s4 = 0x10010000 (base global)

    # Configurar direcciones de perifericos
    lui  $t1, 0xFFFF
    ori  $t1, $t1, 0xA000
    sw   $t1, 0($s4)           # dirVGA = 0xFFFFA000

    lui  $t1, 0xFFFF
    ori  $t1, $t1, 0xE000
    sw   $t1, 4($s4)           # dir7seg = 0xFFFFE000

    lui  $t1, 0xFFFF
    ori  $t1, $t1, 0xD000
    sw   $t1, 8($s4)           # dirEntradas = 0xFFFFD000

    lui  $t1, 0xFFFF
    ori  $t1, $t1, 0xB000
    sw   $t1, 12($s4)          # dirMillis = 0xFFFFB000

    # Inicializar posicion de la pieza en (0,0)
    sw   $0, 16($s4)           # filaActual = 0
    sw   $0, 20($s4)           # colActual  = 0

    # Limpiar tablaPieza[4][4] (16 words desde offset 24)
    addi $t1, $s4, 24
    addi $t2, $s4, 88
    limpiarPieza:
        sw   $0, 0($t1)
        addi $t1, $t1, 4
        bne  $t1, $t2, limpiarPieza

# -----------------------------------------------------------------
# REINICIO DEL TABLERO: bordes, piso y area de juego limpia
# -----------------------------------------------------------------
reiniciarTablero:
    addi $t3, $0, 1            # valor solido = 1

    # 1) Limpiar toda el area del tablero
    addi $t1, $s4, 88
    addi $t2, $s4, 1432        # fin del tablero: 88 + 28*12*4
    limpiarTablero:
        sw   $0, 0($t1)
        addi $t1, $t1, 4
        bne  $t1, $t2, limpiarTablero

    # 2) Colocar bordes laterales en filas 0..26
    addi $t1, $s4, 88          # inicio fila 0, col 0
    addi $t2, $s4, 1384        # inicio fila 27 (no incluida)
    colocarBordes:
        sw   $t3, 0($t1)       # borde izquierdo (col 0)
        addi $t1, $t1, 44      # saltar a col 11 (11*4 = 44 bytes)
        sw   $t3, 0($t1)       # borde derecho (col 11)
        addi $t1, $t1, 4       # avanzar a la siguiente fila
        bne  $t1, $t2, colocarBordes

    # 3) Rellenar piso solido en fila 27
    addi $t2, $s4, 1432
    colocarPiso:
        sw   $t3, 0($t1)
        addi $t1, $t1, 4
        bne  $t1, $t2, colocarPiso

j main


# =================================================================
# SUBRUTINA: rotarPieza
#   Aplica una rotacion de 90 grados en sentido horario
#   a la tablaPieza[4][4] mediante transposicion + reflexion.
#   No recibe parametros. Modifica directamente la memoria.
# =================================================================
rotarPieza:
    addi $t9, $s4, 24          # puntero al inicio de tablaPieza

    # Anillo exterior
    lw $t0,  4($t9)
    lw $t1, 32($t9)
    lw $t2, 56($t9)
    lw $t3, 28($t9)
    sw $t1,  4($t9)
    sw $t2, 32($t9)
    sw $t3, 56($t9)
    sw $t0, 28($t9)

    lw $t0,  8($t9)
    lw $t1, 16($t9)
    lw $t2, 52($t9)
    lw $t3, 44($t9)
    sw $t1,  8($t9)
    sw $t2, 16($t9)
    sw $t3, 52($t9)
    sw $t0, 44($t9)

    # Anillo interior
    lw $t0, 20($t9)
    lw $t1, 36($t9)
    lw $t2, 40($t9)
    lw $t3, 24($t9)
    sw $t1, 20($t9)
    sw $t2, 36($t9)
    sw $t3, 40($t9)
    sw $t0, 24($t9)

    jr $ra


# =================================================================
# SUBRUTINA: intentarRotar
#   Rota la pieza e intenta acomodarla si colisiona.
#   Si ningun ajuste es posible, revierte la rotacion.
#   Preserva $ra usando offset 1432 (fuera del tablero).
# =================================================================
intentarRotar:
    sw $ra, 1432($s4)          # preservar $ra

    jal rotarPieza             # aplicar rotacion

    # Intento 1: misma fila, una columna a la izquierda
    lw   $a0, 16($s4)
    lw   $a1, 20($s4)
    addi $a1, $a1, -1
    addi $a2, $0, 1
    jal  verificarMovimiento

    beq $v0, 1, finRotar

    # Intento 2: una fila arriba, una columna a la izquierda
    lw   $a0, 16($s4)
    lw   $a1, 20($s4)
    addi $a0, $a0, -1
    addi $a1, $a1, -1
    addi $a2, $0, 1
    jal  verificarMovimiento

    beq $v0, 0, ajuste2intentarRotar
        lw   $t1, 16($s4)
        addi $t1, $t1, -1
        sw   $t1, 16($s4)
        j finRotar

    ajuste2intentarRotar:

    # Intento 3: misma fila, misma columna
    lw   $a0, 16($s4)
    lw   $a1, 20($s4)
    addi $a2, $0, 0
    jal  verificarMovimiento

    beq $v0, 0, ajuste3intentarRotar
        lw   $t1, 20($s4)
        addi $t1, $t1, -1
        sw   $t1, 20($s4)
        j finRotar

    ajuste3intentarRotar:

    # Intento 4: misma fila, una columna a la derecha
    lw   $a0, 16($s4)
    lw   $a1, 20($s4)
    addi $a2, $0, 1
    jal  verificarMovimiento

    beq $v0, 0, revertirRotar
        lw   $t1, 20($s4)
        addi $t1, $t1, 1
        sw   $t1, 20($s4)
        j finRotar

    revertirRotar:
        # Ningún ajuste funciono: revertir con 3 rotaciones mas
        jal rotarPieza
        jal rotarPieza
        jal rotarPieza

    finRotar:
    lw  $ra, 1432($s4)
    jr  $ra


# =================================================================
# SUBRUTINA: cargarForma
#   Carga la forma de la pieza indicada en tablaPieza[4][4].
#   $a0 = identificador de pieza (0=I, 1=O, 2=L, 3=S, 4=J, 5=Z, 6=T)
# =================================================================
cargarForma:
    # Limpiar tablaPieza antes de cargar la nueva forma
    addi $t3, $s4, 24
    addi $t9, $0, 0
    borrarFormaAnterior:
        slti $t0, $t9, 16
        beq  $t0, $0, finBorrarForma
        sw   $0, 0($t3)
        addi $t3, $t3, 4
        addi $t9, $t9, 1
        j borrarFormaAnterior
    finBorrarForma:

    li   $t0, 1
    addi $t3, $s4, 24

    beq $a0, 0, piezaI
    beq $a0, 1, piezaO
    beq $a0, 2, piezaL
    beq $a0, 3, piezaS
    beq $a0, 4, piezaJ
    beq $a0, 5, piezaZ

    # Pieza T (por defecto si $a0 >= 6)
    piezaT:
        sw $t0, 24($t3)
        sw $t0, 36($t3)
        sw $t0, 40($t3)
        sw $t0, 44($t3)
        jr $ra
    piezaI:
        sw $t0,  8($t3)
        sw $t0, 24($t3)
        sw $t0, 40($t3)
        sw $t0, 56($t3)
        jr $ra
    piezaO:
        sw $t0, 20($t3)
        sw $t0, 24($t3)
        sw $t0, 36($t3)
        sw $t0, 40($t3)
        jr $ra
    piezaL:
        sw $t0,  4($t3)
        sw $t0, 20($t3)
        sw $t0, 36($t3)
        sw $t0, 40($t3)
        jr $ra
    piezaS:
        sw $t0, 20($t3)
        sw $t0, 24($t3)
        sw $t0, 40($t3)
        sw $t0, 44($t3)
        jr $ra
    piezaJ:
        sw $t0,  8($t3)
        sw $t0, 24($t3)
        sw $t0, 40($t3)
        sw $t0, 36($t3)
        jr $ra
    piezaZ:
        sw $t0, 24($t3)
        sw $t0, 28($t3)
        sw $t0, 36($t3)
        sw $t0, 40($t3)
        jr $ra


# =================================================================
# SUBRUTINA: dibujarPantalla
#   Recorre las 24 filas visibles (filas logicas 4..27) y construye
#   una word de 32 bits por fila para la memoria VGA, formato
#   BlockBreaker: 24 filas x 32 bits (1 sw por fila).
#   El tablero de 12 cols se centra en columnas de pantalla 10..21,
#   que corresponden a los bits 21..10 de cada word
#   (pixel = bit[31-col_pantalla]; col_pantalla = col_tablero + 10).
#   $a0 = fila logica actual de la pieza
#   $a1 = columna actual de la pieza
#   Usa $t7 como acumulador y $v0 como mascara de bit.
# =================================================================
dibujarPantalla:
    lw   $t1, 0($s4)           # direccion base VGA (fila 0 = offset 0)

    addi $t2, $s4, 88
    addi $t2, $t2, 192         # apuntar a fila logica 4 en tablero

    addi $t3, $s4, 24          # puntero a tablaPieza

    addi $t9, $0, 4            # i = 4 (primera fila visible)

    filaVGA:
        addi $t7, $0, 0        # acumulador 32 bits para esta fila
        lui  $v0, 0x0020       # mascara inicial: bit 21 (col 0 del tablero)
        addi $t8, $0, 0        # columna = 0
        slti $t0, $t9, 28
        beq  $t0, $0, finFilaVGA

    columnaVGA:
        slti $t0, $t8, 12
        beq  $t0, $0, finColumnaVGA

        lw   $t4, 0($t2)       # celda del tablero estatico

        # Verificar si la celda esta dentro de la ventana de la pieza
        subi $t6, $a0, 5
        slt  $t5, $t9, $a0
        slt  $t6, $t6, $t9
        and  $t5, $t6, $t5

        addi $t6, $a1, 5
        slt  $t6, $t8, $t6
        slt  $t0, $a1, $t8
        and  $t6, $t6, $t0

        and  $t0, $t5, $t6

        bne $t0, 1, verificarPixel
            # Calcular indice en tablaPieza y superponer
            addi $t5, $t9, 4
            sub  $t5, $t5, $a0
            sll  $t5, $t5, 2
            subi $t6, $t8, 1
            sub  $t6, $t6, $a1
            add  $t5, $t5, $t6
            sll  $t5, $t5, 2
            add  $t3, $t3, $t5
            lw   $t5, 0($t3)
            addi $t3, $s4, 24
            add  $t4, $t4, $t5

        verificarPixel:
            beq  $t4, $0, pixelApagado
            or   $t7, $t7, $v0 # encender bit en acumulador

        pixelApagado:
            srl  $v0, $v0, 1   # desplazar mascara a la siguiente columna

        addi $t2, $t2, 4
        addi $t8, $t8, 1
        j columnaVGA

    finColumnaVGA:
        sw   $t7, 0($t1)       # escribir word de 32 bits para esta fila
        addi $t1, $t1, 4       # avanzar a la siguiente fila VGA
        addi $t9, $t9, 1
        j filaVGA

    finFilaVGA:
        jr $ra


# =================================================================
# SUBRUTINA: fijarPieza
#   Transfiere las celdas activas de tablaPieza al tablero estatico.
#   $a0 = fila logica actual
#   $a1 = columna actual
# =================================================================
fijarPieza:
    addi $t9, $s4, 24
    addi $t6, $s4, 88
    addi $t8, $0, 0

    filaFijar:
        addi $t7, $0, 0
        slti $t0, $t8, 4
        beq  $t0, $0, finFilaFijar

    columnaFijar:
        slti $t0, $t7, 4
        beq  $t0, $0, finColumnaFijar

        add  $t1, $a0, $t8
        addi $t1, $t1, -3
        slt  $t1, $t1, $0
        add  $t2, $a1, $t7
        slt  $t3, $t2, $0
        li   $t4, 9
        slt  $t4, $t4, $t2
        or   $t1, $t1, $t3
        or   $t1, $t1, $t4

        beq $t1, 1, siguienteColumnaFijar
            add  $t1, $a0, $t8
            addi $t1, $t1, -4
            sll  $t1, $t1, 2
            sll  $t3, $t1, 1
            add  $t1, $t1, $t3
            add  $t2, $a1, $t7
            addi $t2, $t2, 1
            add  $t1, $t1, $t2
            sll  $t1, $t1, 2
            add  $t6, $t6, $t1
            lw   $t1, 0($t6)
            lw   $t2, 0($t9)
            add  $t1, $t1, $t2
            sw   $t1, 0($t6)
            addi $t6, $s4, 88

        siguienteColumnaFijar:
        addi $t9, $t9, 4
        addi $t7, $t7, 1
        j columnaFijar

    finColumnaFijar:
        addi $t8, $t8, 1
        j filaFijar

    finFilaFijar:
        jr $ra


# =================================================================
# SUBRUTINA: verificarMovimiento
#   Verifica si la pieza puede moverse sin colisionar.
#   $a0 = fila logica actual
#   $a1 = columna actual
#   $a2 = direccion: 0=izquierda, 1=derecha, otro=abajo
#   Retorna: $v0 = 1 movimiento valido, $v0 = 0 colision
# =================================================================
verificarMovimiento:
    beq $a2, 1, moverADerecha
    beq $a2, 0, moverAIzquierda
    addi $a0, $a0, 1
    j iniciarVerificacion
    moverADerecha:
        addi $a1, $a1, 1
        j iniciarVerificacion
    moverAIzquierda:
        addi $a1, $a1, -1

    iniciarVerificacion:
    addi $t9, $s4, 24
    addi $t6, $s4, 88
    addi $t8, $0, 0

    filaVerificar:
        addi $t7, $0, 0
        slti $t0, $t8, 4
        beq  $t0, $0, movimientoValido

    columnaVerificar:
        slti $t0, $t7, 4
        beq  $t0, $0, finColumnaVerificar

        add  $t1, $a0, $t8
        addi $t1, $t1, -4
        slt  $t1, $t1, $0
        add  $t2, $a1, $t7
        slti $t3, $t2, -1
        li   $t4, 10
        slt  $t4, $t4, $t2
        or   $t1, $t1, $t3
        or   $t1, $t1, $t4

        beq $t1, 1, siguienteColumnaVerificar
            add  $t1, $a0, $t8
            addi $t1, $t1, -4
            sll  $t1, $t1, 2
            sll  $t3, $t1, 1
            add  $t1, $t1, $t3
            add  $t2, $a1, $t7
            addi $t2, $t2, 1
            add  $t1, $t1, $t2
            sll  $t1, $t1, 2
            add  $t6, $t6, $t1
            lw   $t1, 0($t6)
            lw   $t2, 0($t9)

            bne $t1, 0, hayColision
            j siguienteColumnaVerificar
            hayColision:
            bne $t2, 0, reportarColision
            j siguienteColumnaVerificar
            reportarColision:
                li  $v0, 0
                jr  $ra

        siguienteColumnaVerificar:
        addi $t6, $s4, 88
        addi $t9, $t9, 4
        addi $t7, $t7, 1
        j columnaVerificar

    finColumnaVerificar:
        addi $t8, $t8, 1
        j filaVerificar

    movimientoValido:
        li  $v0, 1
        jr  $ra


# =================================================================
# SUBRUTINA: eliminarLineas
#   Elimina filas completas del tablero visible (filas 4..26)
#   desplazando las superiores hacia abajo.
#   Retorna: $v0 = cantidad de lineas eliminadas
# =================================================================
eliminarLineas:
    li   $t1, 0
    li   $v0, 0

    addi $t9, $s4, 88
    addi $t9, $t9, 196         # col 1 de la fila 4 visible

    addi $t8, $0, 4

    revisarFila:
        addi $t7, $0, 1
        li   $t1, 0
        slti $t0, $t8, 27
        beq  $t0, $0, finRevisarFila

    contarCeldas:
        slti $t0, $t7, 11
        beq  $t0, $0, evaluarFila
        lw   $t3, 0($t9)
        beq  $t3, 0, siguienteCelda
        addi $t1, $t1, 1
        siguienteCelda:
        addi $t9, $t9, 4
        addi $t7, $t7, 1
        j contarCeldas

    evaluarFila:
        bne $t1, 10, siguienteFila

        addi $v0, $v0, 1

        addi $t5, $t8, 0
        addi $t6, $t9, -40

        bajarFilas:
            addi $t7, $0, 1
            slt  $t0, $0, $t5
            beq  $t0, $0, finBajarFilas

            copiarFila:
                slti $t0, $t7, 11
                beq  $t0, $0, finCopiarFila
                lw   $t1, -48($t6)
                sw   $t1, 0($t6)
                addi $t6, $t6, 4
                addi $t7, $t7, 1
                j copiarFila

            finCopiarFila:
            addi $t5, $t5, -1
            addi $t6, $t6, -88
            j bajarFilas

        finBajarFilas:

        addi $t6, $s4, 88
        addi $t6, $t6, 4
        addi $t7, $0, 1
        limpiarFilaOculta:
            slti $t0, $t7, 11
            beq  $t0, $0, siguienteFila
            sw   $0, 0($t6)
            addi $t6, $t6, 4
            addi $t7, $t7, 1
            j limpiarFilaOculta

    siguienteFila:
        addi $t8, $t8, 1
        addi $t9, $t9, 8
        j revisarFila

    finRevisarFila:
        jr $ra


# =================================================================
# SUBRUTINA: verificarDerrota
#   Revisa las filas ocultas (0..3). Si hay bloques, es game over.
#   Retorna: $v0 = 1 derrota, $v0 = 0 sin derrota
# =================================================================
verificarDerrota:
    addi $t9, $s4, 88
    addi $t9, $t9, 4

    addi $t8, $0, 0

    filaOculta:
        addi $t7, $0, 1
        slti $t0, $t8, 4
        beq  $t0, $0, sinDerrota

    celdaOculta:
        slti $t0, $t7, 11
        beq  $t0, $0, finCeldaOculta
        lw   $t3, 0($t9)
        beq  $t3, 0, siguienteCeldaOculta
        li   $v0, 1
        jr   $ra

        siguienteCeldaOculta:
        addi $t9, $t9, 4
        addi $t7, $t7, 1
        j celdaOculta

    finCeldaOculta:
        addi $t8, $t8, 1
        addi $t9, $t9, 8
        j filaOculta

    sinDerrota:
        li  $v0, 0
        jr  $ra


# =================================================================
# PROGRAMA PRINCIPAL
# =================================================================
main:
    esperarInicio:
    lw  $t9, 8($s4)
    lw  $t9, 0($t9)
    beq $t9, $zero, esperarInicio

    addi $s2, $0, 3            # forma inicial
    addi $s5, $0, 0            # puntaje = 0

    lw  $t1, 4($s4)
    sw  $s5, 0($t1)            # mostrar puntaje inicial en 7seg

    addi $s6, $0, 0            # flag: botones soltados
    addi $s7, $0, 1000         # velocidad inicial (ms)

    # ---------------------------------------------------------------
    # Bucle principal: genera y controla cada pieza
    # ---------------------------------------------------------------
    bucleNuevaPieza:
        li  $s0, 4             # fila de aparicion
        li  $s1, 4             # columna de aparicion
        sw  $s0, 16($s4)
        sw  $s1, 20($s4)

        addi $a0, $s2, 0
        jal  cargarForma

        lw  $t9, 12($s4)
        sw  $0, 0($t9)
        lw  $s3, 0($t9)        # tiempo de referencia

        # -----------------------------------------------------------
        # Bucle de caida: controla la pieza hasta que aterriza
        # -----------------------------------------------------------
        bucleCaida:
            addi $a0, $s0, 0
            addi $a1, $s1, 0
            jal  dibujarPantalla

            # -------------------------------------------------------
            # Esperar tick de tiempo o entrada de usuario
            # -------------------------------------------------------
            esperarTiempo:
            lw   $t9, 12($s4)
            lw   $t9, 0($t9)   # leer milisegundos actuales

            # Determinar delay activo segun boton de bajar rapido
            lw   $t2, 8($s4)
            lw   $t2, 0($t2)   # leer estado de switches
            andi $t2, $t2, 4   # aislar bit 2 (bajar rapido)
            beq  $t2, $0, delayNormal
            addi $t3, $0, 50   # delay rapido = 50ms
            j    verificarDelay
            delayNormal:
            addi $t3, $s7, 0   # delay normal = $s7 ms
            verificarDelay:
            slt  $t0, $t9, $t3
            beq  $t0, $0, caerUnaFila  # tiempo cumplido: bajar una fila

            # Revisar botones cada 100ms
            sub  $t1, $t9, $s3
            slti $t0, $t1, 100
            bne  $t0, $0, esperarTiempo

            # Leer botones
            lw   $t9, 8($s4)
            lw   $t9, ($t9)

            # Anti-repeticion: esperar que se suelten antes de aceptar
            bne  $t9, $0, procesarBotones
            addi $s6, $0, 1    # botones soltados
            procesarBotones:
            bne  $s6, 1, esperarTiempo

            # Decodificar botones (bit 3 ya es manejado por delay rapido)
            andi $t8, $t9, 1
            bne  $t8, $zero, accionIzquierda
            andi $t8, $t9, 2
            bne  $t8, $zero, accionDerecha
            andi $t8, $t9, 8
            bne  $t8, $zero, accionRotar

            j esperarTiempo

            # -------------------------------------------------------
            # Bajar automaticamente una fila
            # -------------------------------------------------------
            caerUnaFila:
                addi $a0, $s0, 0
                addi $a1, $s1, 0
                addi $a2, $0, 2        # direccion: abajo
                jal  verificarMovimiento
                beq  $v0, 0, aterrizarPieza
                addi $s0, $s0, 1       # actualizar fila
                sw   $s0, 16($s4)
                lw   $t9, 12($s4)
                sw   $0, 0($t9)        # reiniciar temporizador
                lw   $s3, 0($t9)
                j bucleCaida

            # -------------------------------------------------------
            # Acciones del jugador
            # -------------------------------------------------------
            accionIzquierda:
                addi $a0, $s0, 0
                addi $a1, $s1, 0
                addi $a2, $0, 0
                jal  verificarMovimiento
                beq  $v0, 0, reiniciarEntrada
                addi $s1, $s1, -1
                sw   $s1, 20($s4)
                j reiniciarEntrada

            accionDerecha:
                addi $a0, $s0, 0
                addi $a1, $s1, 0
                addi $a2, $0, 1
                jal  verificarMovimiento
                beq  $v0, 0, reiniciarEntrada
                addi $s1, $s1, 1
                sw   $s1, 20($s4)
                j reiniciarEntrada

            accionRotar:
                jal  intentarRotar
                lw   $s0, 16($s4)
                lw   $s1, 20($s4)
                j reiniciarEntrada

        reiniciarEntrada:
            lw   $t9, 12($s4)
            lw   $s3, 0($t9)   # actualizar tiempo de referencia
            addi $s6, $0, 0    # resetear flag de botones
            j bucleCaida

        # -----------------------------------------------------------
        # La pieza aterrizo: procesar y lanzar la siguiente
        # -----------------------------------------------------------
        aterrizarPieza:
        addi $s6, $0, 0
        addi $s7, $s7, -1      # aumentar velocidad base

        addi $a0, $s0, 0
        addi $a1, $s1, 0
        jal  verificarDerrota
        beq  $v0, 1, gameOver

        addi $a0, $s0, 0
        addi $a1, $s1, 0
        jal  fijarPieza
        jal  eliminarLineas

        # Puntaje = lineas_eliminadas^2
        addi $t8, $v0, 0
        add  $v0, $0, $0
        addi $t7, $0, 0
        calcularPuntaje:
            slt  $t0, $t7, $t8
            beq  $t0, $0, finCalcularPuntaje
            add  $v0, $v0, $t8
            addi $t7, $t7, 1
            j calcularPuntaje
        finCalcularPuntaje:
        add $s5, $s5, $v0

        lw  $t1, 4($s4)
        sw  $s5, 0($t1)        # actualizar puntaje en 7seg

        # Avanzar al siguiente tipo de pieza (ciclico 0..6)
        addi $s2, $s2, 1
        beq  $s2, 7, reiniciarCiclo
        j bucleNuevaPieza
        reiniciarCiclo:
            addi $s2, $0, 0
            j bucleNuevaPieza

# =================================================================
# GAME OVER: mostrar estado final y reiniciar tras 1 segundo
# =================================================================
gameOver:
    addi $a0, $0, 0
    addi $a1, $0, 0
    jal  dibujarPantalla       # mostrar pantalla final

    lw  $t9, 12($s4)
    sw  $0, 0($t9)             # reiniciar temporizador

    esperarGameOver:
    lw  $t9, 12($s4)
    lw  $t9, 0($t9)
    slti $t0, $t9, 1000
    bne  $t0, $0, esperarGameOver

    j reiniciarTablero         # reiniciar juego completo