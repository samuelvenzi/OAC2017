.data

menu_string: .asciiz "\nSelecione uma opção:\n1. Buscar contato\n2. Criar contato\n3. Sair\n\nOpção:"

.text 
main:
jal menu



menu:
	li $v0, 4
	la $a0, menu_string
	syscall   # prints menu
	
	li   $v0, 12       
 	syscall	  # gets option
 	
 	slti $t0, $v0, 0x31
 	slti $t1, $v0, 0x34
	xor $t3, $t1, $t0
	
	bne $t1, 1, menu

open_file:



close_file:



create:



edit:



delete:
