.data

buffer: .space 1
register: .space 512
name: .space 150 
short_name: .space 30
phone: .space 14
email: .space 100
menu_string: .asciiz "\nSelecione uma opção:\n1. Visualizar agenda\n2. Buscar contato\n3. Criar contato\n4. Sair\n\nOpção: "
invalid_msg: .asciiz "\n\nOpção inválida. Digite uma opção do menu!\n"
name_msg: .asciiz "\nInsira o nome completo: "
short_name_msg: .asciiz "\nInsira o nome curto: "
phone_msg: .asciiz "\nInsira o número de telefone: "
email_msg: .asciiz "\nInsira o endereço de email: "
fout: .asciiz "db.txt" 
delimeter: .asciiz ";"
nl: .asciiz "\n"

.text 
main:
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

open_file_w:
	li   $v0, 13       
  	la   $a0, fout     
  	li   $a1, 9       
  	li   $a2, 0       
  	syscall	# opens file for writing
  	move $s6, $v0   
  	jr $ra
  
 open_file_r:	
  	li   $v0, 13       
  	la   $a0, fout     
  	li   $a1, 0    
  	li   $a2, 0       
  	syscall	# opens file for reading
  	move $s6, $v0 
  	   
	jr $ra
	
close_file:

	li   $v0, 16 # system call for close file
	move $a0, $s6 # file descriptor to close
	syscall	# close file
	jr $ra

create:
	jal open_file_w
	li $v0, 4
	la $a0, name_msg
	syscall   # prints name messsage
	
	la $a0, name
    	li $a1, 150
    	li $v0, 8	
   	syscall		# gets name
   	
   	la $a1, name
	jal write
	
	li $v0, 4
	la $a0, short_name_msg
	syscall   # prints short name message
	
	la $a0, short_name
    	li $a1, 30
    	li $v0, 8
   	syscall		# gets short name
   	la $a1, short_name
   	jal write
   	
   	li $v0, 4
	la $a0, phone_msg
	syscall   # prints short name message
	
	la $a0, phone
    	li $a1, 14
    	li $v0, 8
   	syscall		# gets phone number
   	la $a1, phone
	jal write
   	
   	li $v0, 4
	la $a0, email_msg
	syscall   # prints short name message
	
	la $a0, email
    	li $a1, 100
    	li $v0, 8
   	syscall		# gets email address
   	la $a1, email
   	jal write
   	
   	la $a1, nl	   # jumps a line at the end of the register
   	li $a2, 1
   	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file
	
	jal close_file
   	addi $v0, $zero, 1 # sets v0 to 1 so when it returns to continue the branches are not triggered
	j continue
	
edit:


	jr $ra
delete:


	jr $ra
	
	
seek:	
	addi $v0, $zero, 1 # sets v0 to 1 so when it returns to continue the branches are not triggered
   	jal open_file_r
	jal read
	jal close_file
	j continue

view:
	addi $v0, $zero, 1 # sets v0 to 1 so when it returns to continue the branches are not triggered
   	jal open_file_r
   	jal read
   	jal close_file
	j continue

read:	
	la $t0, register 
	char_loop:		# char loop makes sure only one register is read
		beq $t1, 0xA, char_end
		li   $v0, 14       # system call for reading from file 
		move $a0, $s6      # file descriptor 
		la $a1, buffer
		la $a2, 1
		syscall            # read from file 
		lb $t1, buffer
		beq $t1, $0, bora
		sb $t1, 0($t0)
		addi $t0, $t0, 1
		bora:
		j char_loop
	char_end:
	jr $ra

write:
	add $t0, $0, $0
   	move $t1, $a1
   	count:    # counts how many chars must be written in file so it does not write \0
   		lb $t2, 0($t1)
   		beq $t2, $0, out
   		addi $t1, $t1, 1
   		addi $t0, $t0, 1
   		j count
   	out:
   	move $a2, $t0
	move $t8, $a1
   	loop: 
   		lb $t1, 0($t8)
   		beq $t1, 0xA, end_loop
   		addi $t8, $t8, 1
   		j loop
   	end_loop:
   	lb $t1, delimeter
   	sb $t1, 0($t8)
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file
	jr $ra
