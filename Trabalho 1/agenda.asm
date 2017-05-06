#	OAC
#	Univerdade de Brasília 
#	Samuel Venzi Lima Monteiro de Oliveira - 14/0162241
#	Danielle Almeida Lima - 14/0135740
#
.data

buffer: .space 4
register: .space 296
id: .word 0x3B212121
keep_id: .word 0x00000000
number: .space 4
name: .space 150
short_name: .space 30
phone: .space 15
email: .space 100
menu_string: .asciiz "\nSelecione uma opção:\n1. Visualizar agenda\n2. Buscar contato\n3. Criar contato\n4. Sair\n\nOpção: "
invalid_msg: .asciiz "\n\nOpção inválida. Digite uma opção do menu!\n"
invalid_phone: .asciiz "\n\nFormato de telefone inválido.\n"
name_msg: .asciiz "\nInsira o nome completo: "
short_name_msg: .asciiz "\nInsira o nome curto: "
phone_msg: .asciiz "\nInsira o número de telefone no formato (99)9999-9999: "
email_msg: .asciiz "\nInsira o endereço de email: "
view_msg: .asciiz "Selecione um contato (insira 0 para voltar ao menu): "
seek_msg: .asciiz "Insira a primeira letra do nome do contato que deseja buscar: "
success_msg: .asciiz "\n\nOperação realizada com sucesso!\n\n"
fout: .asciiz "db.txt" 
delimeter: .asciiz ";"
nl: .asciiz "\n"
option: .asciiz ". "
contact_view: .asciiz "Visualização do contato:\n\n"
action_msg: .asciiz "O que deseja fazer?\n\n1. Editar contato\n2. Deletar contato\n3. Voltar ao menu\nOpção: "
misc: .align 2


.text 
main:	
	li $s4, 9
	jal open_file_w
	jal close_file
	menu_loop:
		jal menu
		beq $v0, 4, end_menu
		j menu_loop
	end_menu:
	li $v0, 10
	syscall
menu:
	addi $sp, $sp, -4
	sw $ra, 0($sp)   # pushes return address 
	li $v0, 4
	la $a0, menu_string
	syscall   # prints menu
	
	li $v0, 5       
 	syscall	  # gets option
 	
 	slti $t0, $v0, 1
 	slti $t1, $v0, 5
	xor $t2, $t1, $t0
	
	beq $t2, 1, continue
	li $v0, 4
	la $a0, invalid_msg
	syscall   # prints message
	j menu
	continue:
	beq $v0, 1, view
	beq $v0, 2, seek
	beq $v0, 3, create
	lw $ra, 0($sp)
	addi $sp, $sp, 4  # pops return address
	jr $ra

open_file_w:
	li   $v0, 13       
  	la   $a0, fout     
  	move   $a1, $s4       
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
	
	li $s4, 9
	jal open_file_w
	
	la $a1, keep_id
	jal write
	
	name_loop:
	li $v0, 4
	la $a0, name_msg
	syscall   # prints name messsage
	
	
	la $a0, name
    	li $a1, 150
    	li $v0, 8	
   	syscall		# gets name
   	lb $v0, name
   	beq $v0, 0xA, name_loop
   	
   	la $a1, name
	jal write
	
	shname_loop:
	li $v0, 4
	la $a0, short_name_msg
	syscall   # prints short name message
	
	
	la $a0, short_name
    	li $a1, 30
    	li $v0, 8
   	syscall		# gets short name
   	lb $v0, short_name
   	beq $v0, 0xA, shname_loop
   	la $a1, short_name
   	jal write
   	
   	li $v0, 4
	loop1:
    	li $v0, 4
	la $a0, phone_msg
	syscall   # prints short name message
	la $a0, phone
    	li $a1, 15
    	li $v0, 8
   	syscall		# gets phone number
   	lb $v0, phone
   	beq $v0, 0xA, loop1
   	la $t0, phone
   	add $t1, $0, $0 
	loop2:		#count the number of digits
		bgt $t1, 0xE, phone_invalid
		lb $t2, 0($t0)
		beq $t2, 0xA, loop3
    		beq $t1, $0, L3 		# first element is (
    		beq $t1, 0x3, L4		# third element is )
    		beq $t1, 0x8, L5		# eighth element is -
    		addi $t1, $t1, 1
    		addi $t0, $t0, 1
    		j loop2    			 
    	L3:
    		beq $t2, 0x28, L6
    		j phone_invalid
    		L6:
    			addi $t1, $t1, 1
    			addi $t0, $t0, 1
    			j loop2
    	L4:
    		beq $t2, 0x29, L7
    		j phone_invalid
    		L7:
    			addi $t1, $t1, 1
    			addi $t0, $t0, 1
    			j loop2
    	L5:
    		beq $t2, 0x2D, L8
    		j phone_invalid
    		L8:
    			addi $t1, $t1, 1
    			addi $t0, $t0, 1
    			j loop2
    	phone_invalid:	
		li $v0, 4
		la $a0, invalid_phone
		syscall   # prints message
		j loop1	   	
   		
loop3:
   		la $a1, phone
		jal write
   	
   	email_loop:
   	li $v0, 4
	la $a0, email_msg
	syscall   # prints short name message
	
	
	la $a0, email
    	li $a1, 100
    	li $v0, 8
   	syscall		# gets email address
   	lb $v0, email
   	beq $v0, 0xA, email_loop
   	la $a1, email
   	jal write
   	
   	la $a1, nl	   # jumps a line at the end of the register
   	li $a2, 1
   	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file
	
	jal close_file
	
	li $v0, 4
	la $a0, success_msg
	syscall   # prints menu
	
   	addi $v0, $zero, -1 # sets v0 to 1 so when it returns to continue the branches are not triggered
	j continue
	
edit:

	addi $sp, $sp, -4
	sw $ra, 0($sp)   # pushes return address
	move $s0, $a3
	 
	jal open_file_r
	
   	addi $a3, $0, 1
   	la $s1, register
   	la $s2, misc
   	add $t9, $0, $0  # flag so t4 does not reset
   	add $s4, $0, $0  
   	loop_edit:
   		jal read
   		
   		move_to_misc:
   			beq $v0, $0, move_end2
   			bne $s0, $a3, con
   			addi $s4, $s4, 1
   			bne $s4, 1, con
   			move $s3, $s2	
   			con:
   			lb $t3, 0($s1)
   			beq $t3, $0, move_end
   			sb $t3, 0($s2)
   			addi $s1, $s1, 1
   			addi $s2, $s2, 1
   			
   		j move_to_misc
   		move_end:
   		addi $s2, $s2, -1
   		li $t3, 0xA
   		sb $t3, 0($s2)
   		addi $s2, $s2, 1
   		li $t3, 0xA
   		sb $t3, 0($s2)
   		addi $s2, $s2, 1
   		
   		move_end2:
   		la $s1, register
   		li $t3, 0x3B
   		addi $s2, $s2, -2
   		sb $t3, 0($s2)
   		li $t3, 0xA
   		addi $s2, $s2, 1
   		sb $t3, 0($s2)
   		addi $s2, $s2, 1
   		beq $v0, $0, end_edit
		addi $a3, $a3, 1
   		j loop_edit
   	end_edit:


   	jal close_file
   
	move $a3, $s0

	la $t0, misc
	addi $t5, $a3, 0x3B212120
	sw $t5, keep_id
	
	
	li $s4, 1
	jal open_file_w
	
	sb $0, 0($s3)
	sb $0, 1($s3)
	sb $0, 2($s3)
	sb $0, 3($s3)
	la $a1, misc


	add $t0, $0, $0
   	move $t1, $a1
   	count2:    # counts how many chars must be written in file so it does not write \0
   		lb $t2, 0($t1)
   		beq $t2, $0, out2
   		addi $t1, $t1, 1
   		addi $t0, $t0, 1
   		j count2
   	out2:
   	move $a2, $t0
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall


	la $a1, keep_id
	jal write

	name_loopv:
	li $v0, 4
	la $a0, name_msg
	syscall   # prints name messsage
	
	
	la $a0, name
    	li $a1, 150
    	li $v0, 8	
   	syscall		# gets name
   	lb $v0, name
   	beq $v0, 0xA, name_loopv
	la $a1, name
	jal write

	shname_loopv:
	li $v0, 4
	la $a0, short_name_msg
	syscall   # prints short name message
	

	la $a0, short_name
    	li $a1, 30
    	li $v0, 8
   	syscall		# gets short name
   	lb $v0, short_name
   	beq $v0, 0xa, shname_loopv
 	la $a1, short_name
	jal write

   	loop1v:
    	li $v0, 4
	la $a0, phone_msg
	syscall   # prints short name message
	la $a0, phone
    	li $a1, 15
    	li $v0, 8
   	syscall		# gets phone number
   	lb $v0, phone
   	beq $v0, 0xa, loop1v
   	la $t0, phone
   	add $t1, $0, $0 
	loop2v:		#count the number of digits
		bgt $t1, 0xE, phone_invalid
		lb $t2, 0($t0)
		beq $t2, 0xA, loop3v
    		beq $t1, $0, L3v 		# first element is (
    		beq $t1, 0x3, L4v		# third element is )
    		beq $t1, 0x8, L5v		# eighth element is -
    		addi $t1, $t1, 1
    		addi $t0, $t0, 1
    		j loop2v   			 
    	L3v:
    		beq $t2, 0x28, L6v
    		j phone_invalid
    		L6v:
    			addi $t1, $t1, 1
    			addi $t0, $t0, 1
    			j loop2v
    	L4v:
    		beq $t2, 0x29, L7v
    		j phone_invalid
    		L7v:
    			addi $t1, $t1, 1
    			addi $t0, $t0, 1
    			j loop2v
    	L5v:
    		beq $t2, 0x2D, L8v
    		j phone_invalid
    		L8v:
    			addi $t1, $t1, 1
    			addi $t0, $t0, 1
    			j loop2v
    	phone_invalidv:	
		li $v0, 4
		la $a0, invalid_phone
		syscall   # prints message
		j loop1v	   	
   		
loop3v:
   		la $a1, phone
		jal write

   	
   	li $v0, 4
	la $a0, email_msg
	syscall   # prints short name message
	
	email_loopv:
	la $a0, email
    	li $a1, 100
    	li $v0, 8
   	syscall		# gets email address
   	lb $v0, email
   	beq $v0, 0xa, email_loopv
	la $a1, email
	jal write

   	
   	la $a1, nl	   # jumps a line at the end of the register
   	li $a2, 1
   	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file
	
	add $t1, $0, $0
	rest:
		lb $t0, ($s3)
		beq $t0, 0x21, end_rest
		bne $t0, $0, rest_cont2
		addi $t1, $t1, 1
		rest_cont2:
		bne $t1, 4, rest_cont
		beq $t0, $0, end_rest
		rest_cont:
		addi $s3, $s3, 1
		j rest
	end_rest:
	addi $s3, $s3, 1
	add $t1, $0, $0
	delimeter_counter:
		lb $t0, ($s3)
		beq $t0, $0, delimeter_out
		bne $t0, 0x3b, delimeter_continue
		addi $t1, $t1, 1
		delimeter_continue:
		beq $t1, 4, delimeter_out
		addi $s3, $s3, 1
		j delimeter_counter
	delimeter_out:
	addi $s3, $s3, 2
	la $a1, ($s3)
	
	
	add $t0, $0, $0
   	move $t1, $a1
   	count3:    # counts how many chars must be written in file so it does not write \0
   		lb $t2, 0($t1)
   		beq $t2, $0, out3
   		addi $t1, $t1, 1
   		addi $t0, $t0, 1
   		j count3
   	out3:
   	move $a2, $t0
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file


	jal close_file
	
	lw $ra, 0($sp)
	
	li $v0, 4
	la $a0, success_msg
	syscall   # prints menu
	
	addi $sp, $sp, 4  # pops return address
	jr $ra


delete:
	addi $sp, $sp, -4
	sw $ra, 0($sp)   # pushes return address
	move $s0, $a3
	 
	jal open_file_r
	
   	addi $a3, $0, 1
   	la $s1, register
   	la $s2, misc
   	add $t9, $0, $0  # flag so t4 does not reset
   	add $s4, $0, $0  
   	loop_delete:

   		jal read
   		move_to_misc2:
   			beq $v0, $0, move_end4
   			bne $s0, $a3, con2
   			addi $s4, $s4, 1
   			bne $s4, 1, con2
   			move $s3, $s2	
   			con2:
   			lb $t3, 0($s1)
   			beq $t3, $0, move_end3
   			sb $t3, 0($s2)
   			addi $s1, $s1, 1
   			addi $s2, $s2, 1
   			
   		j move_to_misc2
   		move_end3:
   		addi $s2, $s2, -1
   		li $t3, 0xA
   		sb $t3, 0($s2)
   		addi $s2, $s2, 1
   		li $t3, 0xA
   		sb $t3, 0($s2)
   		addi $s2, $s2, 1
   		
   		move_end4:
   		la $s1, register
   		li $t3, 0x3B
   		addi $s2, $s2, -2
   		sb $t3, 0($s2)
   		li $t3, 0xA
   		addi $s2, $s2, 1
   		sb $t3, 0($s2)
   		addi $s2, $s2, 1
   		beq $v0, $0, end_delete
		addi $a3, $a3, 1
   		j loop_delete
   	end_delete:


   	jal close_file
   
	move $a3, $s0

	la $t0, misc
	addi $t5, $a3, 0x3B212120
	sw $t5, keep_id
	
	
	
	li $s4, 1
	jal open_file_w
	
	sb $0, 0($s3)
	sb $0, 1($s3)
	sb $0, 2($s3)
	sb $0, 3($s3)
	la $a1, misc


	add $t0, $0, $0
   	move $t1, $a1
   	count5:    # counts how many chars must be written in file so it does not write \0
   		lb $t2, 0($t1)
   		beq $t2, $0, out5
   		addi $t1, $t1, 1
   		addi $t0, $t0, 1
   		j count5
   	out5:
   	move $a2, $t0
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall


	add $t1, $0, $0
	rest2:
		lb $t0, ($s3)
		beq $t0, 0x21, end_rest2
		bne $t0, $0, rest_cont7
		addi $t1, $t1, 1
		rest_cont7:
		bne $t1, 4, rest_cont6
		beq $t0, $0, end_rest2
		rest_cont6:
		addi $s3, $s3, 1
		j rest2
	end_rest2:
	addi $s3, $s3, 1
	add $t1, $0, $0
	delimeter_counter2:
		lb $t0, ($s3)
		beq $t0, $0, delimeter_out2
		bne $t0, 0x3b, delimeter_continue2
		addi $t1, $t1, 1
		delimeter_continue2:
		beq $t1, 4, delimeter_out2
		addi $s3, $s3, 1
		j delimeter_counter2
	delimeter_out2:
	addi $s3, $s3, 2
	la $a1, ($s3)
	
	
	add $t0, $0, $0
   	move $t1, $a1
   	count4:    # counts how many chars must be written in file so it does not write \0
   		lb $t2, 0($t1)
   		beq $t2, $0, out4
   		addi $t1, $t1, 1
   		addi $t0, $t0, 1
   		j count4
   	out4:
   	move $a2, $t0
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor 
	syscall            # write to file


	jal close_file
	
	li $v0, 4
	la $a0, success_msg
	syscall   # prints menu
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4  # pops return address

	jr $ra
	
	
seek:	
	li $v0, 4
	la $a0, seek_msg
	syscall   # prints seek msg
	
	li $v0, 8
	la $a0, buffer
	la $a1, 2       
 	syscall	  # char
	
	lb $s2, buffer
	blt $s2, 0x61, seek_cont
	addi $s2, $s2, -0x20
	seek_cont:
	
   	jal open_file_r
   	
   	li $v0, 4
	la $a0, nl
	syscall   # prints new line
   	
   	addi $a3, $0, 1
   	addi $s3, $0, 1
   	la $t0, register
   	add $t9, $0, $0  # flag so t4 does not reset
	loop_seek:
		
		jal read
		beq $v0, $0, end_seek
   		addi $t0, $t0, 4    # address of name inside register
   		
   		lb $t1, 0($t0)
   		blt $t1, 0x61, seek_cont2
		addi $t1, $t1, -0x20
		seek_cont2:
		bne $t1, $s2, seek_cont3
		
   		li $v0, 4
		la $a0, nl
		syscall
   		
   		li $v0, 1
		la $a0, ($s3)
		syscall   # prints option

		li $v0, 4
		la $a0, option
		syscall   # prints option
		
		li $v0, 4
		la $a0, 0($t0)
		syscall   # prints whole register
		seek_cont3:
		addi $a3, $a3, 1
		addi $s3, $s3, 1
   		j loop_seek
   	end_seek:
	jal close_file
	
	li $v0, 4
	la $a0, nl
	syscall   # prints new line
	li $v0, 4
	la $a0, nl
	syscall   # prints new line
	
	li $v0, 4
	la $a0, view_msg
	syscall   # prints view msg
	
	li $v0, 5       
 	syscall	  # gets option
 	
 	beq $v0, 0, continue
	move $a3, $v0
	jal open_file_r
	addi $t9, $0, 0  # flag so t4 does not reset
	jal read
	jal close_file

	li $v0, 4
	la $a0, nl
	syscall
	li $v0, 4
	la $a0, nl
	syscall
	li $v0, 4
	la $a0, contact_view
	syscall

	li $v0, 4
	la $t9, register
	addi $a0, $t9, 4
	syscall   # prints whole register
	
   	li $v0, 4
	la $a0, nl
	syscall
	li $v0, 4
	la $a0, nl
	syscall
	
	action_menu2:
	li $v0, 4
	la $a0, action_msg
	syscall
	
	li $v0, 5
	syscall
	
	slti $t0, $v0, 1
 	slti $t1, $v0, 4
	xor $t2, $t1, $t0
	
	beq $t2, 1, opt_continue2
	li $v0, 4
	la $a0, invalid_msg
	syscall   # prints message
	j action_menu2
	
	opt_continue2:
	bne $v0, 1, not_edit2
	jal edit
	not_edit2:
	bne $v0, 2, not_delete2
	jal delete
	not_delete2:
	
	lw $ra, 0($sp)
	
	addi $v0, $zero, -1 # sets v0 to 1 so when it returns to continue the branches are not triggered
	j continue

view:
   	jal open_file_r
   	addi $a3, $0, 1
   	la $t0, register
   	add $t9, $0, $0  # flag so t4 does not reset
   	loop_view:
   		li $v0, 4
		la $a0, nl
		syscall   # prints new line
   		jal read
   		beq $v0, $0, end_view
   		li $v0, 1
		la $a0, 0($a3)
		syscall   # prints option
		addi $a3, $a3, 1
		li $v0, 4
		la $a0, option
		syscall   # prints option
   		addi $t0, $t0, 4    # address of name inside register
		li $v0, 4
		la $a0, 0($t0)
		syscall   # prints whole register
   		j loop_view
   	end_view:
   	jal close_file
   	
   	li $v0, 4
	la $a0, nl
	syscall  
   	
   	li $v0, 4
	la $a0, view_msg
	syscall   # prints view msg
	
	li $v0, 5       
 	syscall	  # gets option
 	
 	beq $v0, 0, continue
	move $a3, $v0
	jal open_file_r
	addi $t9, $0, 0  # flag so t4 does not reset
	jal read
	jal close_file

	li $v0, 4
	la $a0, nl
	syscall
	li $v0, 4
	la $a0, nl
	syscall
	li $v0, 4
	la $a0, contact_view
	syscall

	li $v0, 4
	la $t9, register
	addi $a0, $t9, 4
	syscall   # prints whole register
	
   	li $v0, 4
	la $a0, nl
	syscall
	li $v0, 4
	la $a0, nl
	syscall
	
	action_menu:
	li $v0, 4
	la $a0, action_msg
	syscall
	
	li $v0, 5
	syscall
	
	slti $t0, $v0, 1
 	slti $t1, $v0, 4
	xor $t2, $t1, $t0
	
	beq $t2, 1, opt_continue
	li $v0, 4
	la $a0, invalid_msg
	syscall   # prints message
	j action_menu
	
	opt_continue:
	bne $v0, 1, not_edit
	jal edit
	not_edit:
	bne $v0, 2, not_delete
	jal delete
	not_delete:
	
	lw $ra, 0($sp)
	
   	addi $v0, $zero, -1 # sets v0 to 1 so when it returns to continue the branches are not triggered
	j continue

read:	
	addi $t5, $a3, -1
	move $t6, $0
	
	bne $t9, $0, gg
	addi $t4, $0, 0
	addi $t9, $0, 1
	gg:
	la $t0, register 
	char_loop:		# char loop makes sure only one register is read
		
		li   $v0, 14       # system call for reading from file 
		move $a0, $s6      # file descriptor 
		la $a1, buffer
		la $a2, 1
		syscall            # read from file 
		
		beq $v0, -1, almost  # branch if error
		beq $v0, 0, almost   # branch if no char is read
		
		
		lb $t1, buffer
		bne $t1, 0xA, bora
		addi $t4, $t4, 1   # counts new line 
		la $t0, register 
		
		bora:
		beq $t1, $0, gogo     # condition so it doesn't save \0 to the memory     
		
		vamo:
		beq $t4, $a3, char_end   # branch if line wanted is read
		beq $t1, 0xA, gogo       # branch so it does not print \n
		
		bne $t4, $t5, gogo
		sb $t1, 0($t0)
		addi $t6, $t6, 1
		addi $t0, $t0, 1
		gogo:
		j char_loop
		
	char_end:
	la $t0, register
	add $t6, $t6, $t0
	addi $t1, $0, 0xA
	la $t7, id
	sb $t1, 0($t6)
	loop_zero:
		sb $0, 0($t6)
		addi $t6, $t6, 1
		beq $t6, $t7, end_zero
		j loop_zero
	end_zero:
	almost:
	add $t1, $0, $0
	sb $t1, buffer
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
   		beq $t1, $0, end_loop1
   		addi $t8, $t8, 1
   		j loop
   	end_loop:
   	lb $t1, delimeter
   	sb $t1, 0($t8)
   	end_loop1:
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
	add $t9, $0, $0
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
	sw $s0, keep_id
	
	jal close_file
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
