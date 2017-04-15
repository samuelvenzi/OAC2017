.data

menu_string: .asciiz "\nSelecione uma opção:\n1. Visualizar agenda\n2. Buscar contato\n3. Criar contato\n4. Sair\n\nOpção:"
invalid_msg: .asciiz "\n\nOpção inválida. Digite uma opção do menu!\n"
.text 
main:
	jal open_file
	jal menu


	li $v0, 10
	syscall
menu:
	li $v0, 4
	la $a0, menu_string
	syscall   # prints menu
	
	li $v0, 12       
 	syscall	  # gets option
 	
 	slti $t0, $v0, 0x31
 	slti $t1, $v0, 0x35
	xor $t2, $t1, $t0
	
	beq $t2, 1, continue
	li $v0, 4
	la $a0, invalid_msg
	syscall   # prints message
	j menu
	continue:
	

open_file:

	jr $ra
	
close_file:

	jr $ra

create:



edit:



delete:
