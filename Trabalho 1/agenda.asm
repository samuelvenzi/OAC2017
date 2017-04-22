.data

buffer: .space 4
register: .space 512
id: .word 0x21212121
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
	jal open_file_w
	jal close_file
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
	jal generate_id
	
	jal open_file_w
	la $a1, id
	jal write
	
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
   	addi $a3, $a3, 3
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
	mul $t2, $a3, 4 
	addi $t5, $a3, -1
	addi $t2, $t2, -4
	addi $t4, $0, 0
	la $t0, register 
	char_loop:		# char loop makes sure only one register is read
		
		li   $v0, 14       # system call for reading from file 
		move $a0, $s6      # file descriptor 
		la $a1, buffer
		la $a2, 1
		syscall            # read from file 
		
		beq $v0, -1, almost
		beq $v0, 0, almost
		
		lb $t1, buffer
		bne $t1, 0xA, bora
		addi $t4, $t4, 1   # counts new line 
		la $t0, register 
		
		bora:
		beq $t1, $0, gogo     # condition so it doesn't save \0 to the memory     
		
		vamo:
		beq $t4, $a3, char_end
		beq $t1, 0xA, gogo
		
		bgt $t4, $t5, gogo
		sb $t1, 0($t0)
		addi $t0, $t0, 1
		gogo:
		j char_loop
		almost:
		add $t0, $0, $0
		sb $t0, buffer
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
   		beq $t1, $0, end_loop
   		addi $t8, $t8, 1
   		j loop
   	end_loop:
   	lb $t1, delimeter
   	sb $t1, 0($t8)
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file
	jr $ra


generate_id:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	jal open_file_r
	addi $a3, $0, 1
	lw $s0, id
	id_loop:
		jal read
		bne $v0, $0, next
		bne $v0, -1, next
		lw $s0, id
		next:
		la $t0, register
		lw $t0, 0($t0)
		blt $t0, $s0, id_cont
		addi $t0, $t0, 1
		move $s0, $t0
		id_cont:
		addi $a3, $a3, 1
		beq $v0, $0, end_id
		j id_loop
	end_id:
	sw $s0, id
	
	jal close_file
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
