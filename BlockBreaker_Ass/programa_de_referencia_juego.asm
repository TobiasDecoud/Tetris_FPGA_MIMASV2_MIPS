.data
	dirVGA:		.word 	0xFFFFA000
	dir7seg:	.word 	0xFFFFE000
	dirLEDS:	.word 	0xFFFF8000
	dirEntradas:	.word 	0xFFFFD000
	dirMillis:	.word 	0xFFFFB000
	platform:	.word	0x0000F000
	limiteIzq:	.word	0x80000000
	limiteDer:	.word	0x00000001
	
.text
	jal data		##Se cargan todos los datos en la memoria donde se necesitan
	jal drawBlank		##Se carga el frameBuffer con ceros
	jal drawPlatform	##Se dibuja la plataforma
	
	##secuencia sencilla para mover la plataforma de izquiera a derecha
whileMain:
	jal leerEntradas
	addi $t0,$zero,100	##Para comparar 100 ms
	lw $t1,dirMillis	##Se carga la direccion del contador milisegundos
while100ms:
	lw $t2,0($t1)
	bne $t2,$t0,while100ms	##se repite el bucle y se lee otra vez el contador si es que no son iguales a 100
	
	j whileMain		##Se repite el main
	
	
	
leerEntradas:
	lw $t9,dirEntradas	##Se carga la direccion de las entradas
	lw $t9,0($t9)		##Se cargan las entradas teniendo la dirección
	lw $t8,dirVGA		##Se carga la dirección del VGA
	lw $t7,92($t8)		##Se carga la línea de la plataforma
	andi $t0,$t9,1		##se hace un andi entre las entradas y la posición 1
	beq $t0,$zero,next1	##Si es igual a cero, entonces no se presionó izquierda y se busca otro botón
		lw $t6,limiteIzq
		and $t6,$t6,$t7	##Se hace un and entre el limite izquierdo y la plataforma para ver si ya se llegó al límite
		bne $t6,$zero,finLeerEntradas	##Se salta al final si no es cero: la plataforma está al limite izquierdo
			sll $t7,$t7,1
			j finLeerEntradas	##Se terminó de hacer los cambios necesarios
next1:
	andi $t0,$t9,2		##se hace un andi entre las entradas y la posición 2
	beq $t0,$zero,next2	##Si es igual a cero, entonces no se presionó derecha y se busca otro botón
		lw $t6,limiteDer
		and $t6,$t6,$t7	##Se hace un and entre el limite derecho y la plataforma para ver si ya se llegó al límite
		bne $t6,$zero,finLeerEntradas	##Se salta al final si no es cero: la plataforma está al limite derecho
			srl $t7,$t7,1
			j finLeerEntradas	##Se terminó de hacer los cambios necesarios
next2:
	##Si no se presionó ningún botón para mover la plataforma o no se puede más mover, ésta permanece intacta
finLeerEntradas:
	sw $t7,92($t8)	##Se escribe la nueva plataforma en la imagen
	jr $ra		##Se retorna al main
	
	
	
drawPlatform:
	lw $t0,dirVGA		##Direccion del VGA (primera línea)
	lw $t1,platform
	sw $t1,92($t0)		##Se escribe la plataforma en la última línea
	jr $ra
	
drawBlank:
	lw $t0,dirVGA		##Direccion del VGA (primera línea)
	addi $t1,$zero,24	##lineas totales
	addi $t2,$zero,0	##linea actual
	whileDrawBlank:
		beq $t2,$t1,finWhileDrawBlank
		sw $zero,0($t0)
		addi $t0,$t0,4
		addi $t2,$t2,1
		j whileDrawBlank
finWhileDrawBlank:
	jr $ra
		
	
data:
	##Segmento donde se cargan las constantes a la memoria
	lui	$t0,0x1001
	ori 	$t0, $t0, 0x0000 ##primera direccion en la memoria de .data
	# dirVGA:		.word 0xFFFFA000
	lui 	$t1,0xFFFF
	ori 	$t1, $t1, 0xA000 
	sw 	$t1,0($t0)
	
	# dir7seg:	.word 0xFFFFE000
	addi	$t0,$t0,4
	lui	$t1,0xFFFF
	ori 	$t1, $t1, 0xE000 
	sw 	$t1,0($t0)
	
	# dirLEDS:	.word 0xFFFF8000
	addi 	$t0,$t0,4
	lui 	$t1,0xFFFF
	ori 	$t1, $t1, 0x8000 
	sw 	$t1,0($t0)
	
	# dirEntradas:	.word 0xFFFFD000
	addi 	$t0,$t0,4
	lui 	$t1,0xFFFF
	ori 	$t1, $t1, 0xD000 
	sw 	$t1,0($t0)
	
	# dirMillis:	.word 0xFFFFB000
	addi 	$t0,$t0,4
	lui 	$t1,0xFFFF
	ori 	$t1, $t1, 0xB000 
	sw 	$t1,0($t0)
	
	# platform:	.word	0x0007E000
	addi 	$t0,$t0,4
	lui 	$t1,0x0007
	ori 	$t1, $t1, 0xE000
	sw 	$t1,0($t0)
	
	# limiteizq:	.word	0x80000000
	addi 	$t0,$t0,4
	lui 	$t1,0x8000
	ori 	$t1, $t1, 0x0000
	sw 	$t1,0($t0)
	
	# limiteder:	.word	0x00000001
	addi 	$t0,$t0,4
	lui 	$t1,0x0000
	ori 	$t1, $t1, 0x0001
	sw 	$t1,0($t0)

	jr	$ra
