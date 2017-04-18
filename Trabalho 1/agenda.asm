.data

menu_string: .asciiz "\nSelecione uma opção:\n1. Visualizar agenda\n2. Buscar contato\n3. Criar contato\n4. Sair\n\nOpção: "
invalid_msg: .asciiz "\n\nOpção inválida. Digite uma opção do menu!\n"
name_msg: .asciiz "\nInsira o nome completo: "
short_name_msg: .asciiz "\nInsira o nome curto: "
phone_msg: .asciiz "\nInsira o número de telefone: "
email_msg: .asciiz "\nInsira o endereço de email: "
name: .asciiz 
short_name: .asciiz
phone: .asciiz
email: .asciiz
fout: .asciiz "db.txt" 

.text 
main:
	jal open_file
	jal menu

	li $v0, 10
	syscall
menu:
	addi $sp, $sp, -4
	sw $ra, 0($sp)   # pushes return address 
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
	beq $v0, 0x31, view
	beq $v0, 0x32, seek
	beq $v0, 0x33, create
	lw $ra, 0($sp)
	addi $sp, $sp, 4  # pops return address
	jr $ra

open_file:
	
	li   $v0, 13       
  	la   $a0, fout     
  	li   $a1, 1       
  	li   $a2, 0       
  	syscall      	# opens file
  	move $s6, $v0      
	jr $ra
	
close_file:

	li   $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall	# close file
	jr $ra

create:
	li $v0, 4
	la $a0, name_msg
	syscall   # prints name messsage
	
	la $a0, name
    	li $a1, 150
    	li $v0, 8
   	syscall		# gets name
	
	li $v0, 4
	la $a0, short_name_msg
	syscall   # prints short name message
	
	la $a0, short_name
    	li $a1, 30
    	li $v0, 8
   	syscall		# gets short name
   	
   	li $v0, 4
	la $a0, phone_msg
	syscall   # prints short name message
	
	la $a0, phone
    	li $a1, 14
    	li $v0, 8
   	syscall		# gets phone number
   	
   	li $v0, 4
	la $a0, email_msg
	syscall   # prints short name message
	
	la $a0, email
    	li $a1, 100
    	li $v0, 8
   	syscall		# gets email address
   	
   	addi $v0, $zero, 1 # sets v0 to 1 so when it returns to continue the branches are not triggered
   	jal write
	j continue
	
edit:


	jr $ra
delete:


	jr $ra
	
	
seek:	
	addi $v0, $zero, 1 # sets v0 to 1 so when it returns to continue the branches are not triggered
   	jal read
	j continue
view:
	addi $v0, $zero, 1 # sets v0 to 1 so when it returns to continue the branches are not triggered
   	jal read
	j continue
read:
	
	jr $ra

write:

	jr $ra
