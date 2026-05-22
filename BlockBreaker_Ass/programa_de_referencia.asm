.data
	dirVGA:		.word 	0xFFFFA000
	dir7seg:	.word 	0xFFFFE000
	dirLEDS:	.word 	0xFFFF8000
	dirEntradas:	.word 	0xFFFFD000
	dirMillis:	.word 	0xFFFFB000
	platform:	.word	0x0000F000
	
.text
	jal data

	#Se carga en el 7 seg
	addi	$t0, $zero, 169
	lw	$t1,dir7seg
	sw	$t0, 0($t1)
	#Se carga en los LEDs
	addi 	$t0, $zero, 0x00A7
	lw 	$t1,dirLEDS
	sw 	$t0, 0($t1)
	
	##Se imprime la primera pantalla de VGA
	addi	$t0, $zero, 1
	lw 	$t1,dirVGA
	addi 	$t2,$zero,25
	
while:	sw 	$t0, 0($t1)
	addi 	$t1,$t1,4
	addi	$t0,$t0,1
	bne	$t0,$t2,while
	
	##Se sale cuando se terminó de escribir el buffer de imagen con los valores de las líneas
	lw 	$t1,dirMillis
	sw 	$t0, 0($t1)	##Se escribe algo en el millis para resetear la cuenta
	addi 	$s0, $zero, 1000	#Se esperará 1 segundo para realizar cambios
	
esperar:
	lw 	$t0, 0($t1)	##Se lee el valor del contador de millis
	bne 	$t0, $s0,esperar	##Se espera hasta que los millis sean 1 segundo
	sw 	$t0, 0($t1)	##Se escribe algo en el millis para resetear la cuenta
	
	#Se cargan los valores iniciales
	addi	$t1,$zero,0	#en t1 el valor para el 7seg
	addi	$t2,$zero,0x00A7	#en t2 para los LED
	addi	$t3, $t1,24	#en t3 para el VGA
	add 	$t4,$zero,$zero	#en t4 la ubi de la linea del vga
	add	$t5,$zero,$zero	#en t5 la lectura de los botones
	
	
	##Se leen las entradas
	##Primero el 7 segmentos
bucle:	lw 	$t0,dir7seg
	sw	$t1, 0($t0)
	addi 	$t1,$t1,1
	##Segundo, los LEDs
	andi 	$t6,$t1,0x0001
	beq 	$t6,$zero,shl
	
shr:	sll	$t2,$t2,3
	j 	next
	
shl:	srl 	$t2,$t2,3

next:	lw 	$t0,dirLEDS
	sw 	$t2, 0($t0)
	##Tercero, el VGA
	lw 	$t0,dirVGA
	#add $t0,$t4,$zero
	lw 	$t7,dirEntradas
	lw	$t5,0($t7)
	beq 	$t5,$zero,opc1
	
opc0:	sw 	$t5,0($t0)
	j 	fine
	
opc1:	addi 	$t3,$t1,23
	sw	$t3,0($t0)
	
fine:	addi 	$t8,$zero,92
	beq 	$t8,$t4,reset
	
noreset:addi 	$t4,$t4,4
	j 	esperar1seg
	
reset:	add 	$t4,$zero,$zero

esperar1seg:
	lw 	$t0,dirMillis
	lw 	$t9,0($t0)
	bne 	$t9, $s0,esperar1seg	##Se espera hasta que los millis sean 1 segundo
	sw 	$t0, 0($t0)	##Se escribe algo en el millis para resetear la cuenta
	j bucle
	
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
	
	# platform:	.word	0x0000F000
	addi 	$t0,$t0,4
	lui 	$t1,0x0000
	ori 	$t1, $t1, 0xF000 
	sw 	$t1,0($t0)

	jr	$ra
