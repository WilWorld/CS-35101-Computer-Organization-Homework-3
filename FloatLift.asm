# CS 35101 Computer Organization
# Wil Nahra/Cayden Jones
# Homework 3
# 11/02/2025
.globl main

.data
prompt_enter_list:    .asciiz "This is the list sorting program.\nPlease enter a list to process\n"
.align 2
input_buf:            .space 256            # buffer for user input line
input_buf_len:        .word 256

# Prompts the user for an operation
menu_prompt: .asciiz "Please select an option: \n1. Sort\n2. Calculate average of all values.\n3. Find the lowest element.\n4. Find the greatest element.\n5. Find the sum of all elements.\n6. Print a specific element.\n7. Print the list contents.\n8. Exit.\n> " 
list_sorted: .asciiz "List sorted!\n" 			# lets the user know the list has been sorted
goodbye: .asciiz "Goodbye!\n" 				# Exits program
lowest: .asciiz "The lowest value is " 			# for displaying the lowest value in the list
greatest: .asciiz "The greatest value is " 		# for displaying the highest value in the list
sum: .asciiz "The sum of the list is " 			# for displaying the sum of the list
average: .asciiz "The average of the list is "		# for displaying the average of the list
index_prompt: .asciiz "Enter index (0-based):"  	# prompts user to enter a value to look for the value in that index
invalid: .asciiz "Invalid index.\n" 			# if invalid, will print
complete:.asciiz "Completed!\n" 			# displays when complete
invalid_menu: .asciiz  "Invalid menu selection, try again\n"
nextOperation: .asciiz "Please select an option: \n"
comma: .asciiz ", "
newline: .asciiz "\n"
openBracket: .asciiz "["
closedBracket: .asciiz "]"

# Storage parameters
MAX_ELEMS:            .word 100    # change if you want support for more elements
float_array:          .space 400   # 100 * 4 bytes = 400 bytes (use MAX_ELEMS*4)
elem_count:           .word 0 #gonna store this value in $s5

.text
initialInput:
	la $a0, prompt_enter_list
	li $v0, 4
	syscall
	
	la $t0, input_buf        # pointer to input string
    	la $t4, float_array         # pointer to array base
    	move $s5, $zero
	
	li $v0, 8          # syscall code 8 = read string
    	la $a0, input_buf      # load address of buffer
    	li $a1, 400          # maximum number of bytes to read
    	syscall
  	
parseIntput:
 	# Build constants 10.0 and 0.1
    	li   $t1, 10
    	mtc1 $t1, $f8
    	cvt.s.w $f8, $f8       # $f8 = 10.0

	li   $t1, 1
    	mtc1 $t1, $f2
    	cvt.s.w $f2, $f2
    	div.s $f2, $f2, $f8    # $f2 = 0.1
    	parseLoop:
    		lb $t1, 0($t0)
    		beqz $t1, done         # end of string
    		beq  $t1, '[', skipChar
    		beq  $t1, ',', storeValue
    		beq  $t1, ']', storeValue
    		beq  $t1, '.', setFraction

    		# skip anything that's not a digit
    		blt  $t1, '0', nextChar
    		bgt  $t1, '9', nextChar

    		#Converts the char into and int, then to a float
    		addi $t1, $t1, -48
    		mtc1 $t1, $f6
    		cvt.s.w $f6, $f6

    		beq  $t3, 0, integerPart
    	fractionPart:
    		li $t7, 2              # only 2 fractional digits
    		bge $t6, $t7, nextChar

    		mul.s $f6, $f6, $f2
    		add.s $f0, $f0, $f6
   		 div.s $f2, $f2, $f8    # scale down: 0.1 → 0.01
    		addi $t6, $t6, 1
    		j nextChar

	integerPart:
    		mul.s $f0, $f0, $f8
    		add.s $f0, $f0, $f6
    		j nextChar

	setFraction:
    		li $t3, 1              # switch to fractional part
    		addi $t0, $t0, 1
    		j parseLoop
		
	skipChar:
    		addi $t0, $t0, 1
    		j parseLoop

	storeValue:
    		# store current float if any digits were read
    		s.s $f0, 0($t4) 
    		addi $t4, $t4, 4
    		addi $s5, $s5, 1

    		# reset for next number
    		li $t3, 0
    		li $t6, 0
    		li $t1, 0
    		mtc1 $t1, $f0
    		cvt.s.w $f0, $f0
    		li   $t1, 1
    		mtc1 $t1, $f2
    		cvt.s.w $f2, $f2
    		div.s $f2, $f2, $f8    # reset $f2 = 0.1

    		addi $t0, $t0, 1
    		j parseLoop

	nextChar:
    		addi $t0, $t0, 1
    		j parseLoop

	done:
		sw $s5, elem_count
    		
# PART 4: Each function will be executed as requested by the user, using a prompt system to display the different 
#    	  options available and process what the user wants.
main:
    # Display menu prompt once
    la $a0, menu_prompt
    li $v0, 4
    syscall
menuLoop:
    # Display initial prompt once
    la $a0, nextOperation
    li $v0, 4
    syscall
    
    # Read user choice
    li $v0, 5
    syscall
    move $t1, $v0
    
    # MENU SWITCHES
    beq $t1, 1, SORT_LIST		# If 1, jump to SORT_LIST
    beq $t1, 2, FIND_AVERAGE 	# if 2, jump to FIND_AVERAGE
    beq $t1, 3, FIND_LOWEST 	# if 3, jump to FIND_LOWEST
    beq $t1, 4, FIND_GREATEST 	# if 4, jump to FIND_GREATEST
    beq $t1, 5, FIND_SUM 		# if 5, jump to FIND_SUM
    beq $t1, 6, FIND_INDEX 		# if 6, jump to FIND_INDEX
    beq $t1, 7, PRINT_LIST		# if 7, jump to PRINT_LIST
    beq $t1, 8, EXIT_PROGRAM	# if 8, exits the program

    # Handles invalid input
    j INVALID_OPTION

# PART 3: Execute the following functions on the list.
# 1. Sort the list from lowest to highest, consider using the bubble sort algorithm explained in class.
SORT_LIST:
	# Load element count
    	lw $t0, elem_count        	  # t0 = number of elements
	# Outer loop counter (i)
	li $t1, 0                	  # t1 = i = 0

	outer_loop:
 		bge $t1, $s5, sort_done   # if i >= elem_count, done
   	 	# Inner loop counter (j)
  	  	li $t2, 0                 # t2 = j = 0
    
	inner_loop:
    		add $t3, $t2, 1           # t3 = j + 1
    		bge $t3, $s5, inner_done  # if j+1 >= elem_count, end inner loop
    
   	 	# Load array[j] and array[j+1]
    		sll $t4, $t2, 2           # offset = j * 4
    		la $t5, float_array
    		add $t6, $t5, $t4         # addr of array[j]
  		lw $t7, 0($t6)            # t7 = array[j]
    		lw $t8, 4($t6)            # t8 = array[j+1]
    
    		# Compare array[j] > array[j+1]
    		ble $t7, $t8, no_swap
    
    		# Swap array[j] and array[j+1]
    		sw $t8, 0($t6)
    		sw $t7, 4($t6)

	no_swap:
    		addi $t2, $t2, 1	  # j++
    		j inner_loop

	inner_done:
    		addi $t1, $t1, 1          # i++
    		j outer_loop

	sort_done:
    		# Print "List sorted!"
    		la $a0, list_sorted
    		li $v0, 4
    		syscall

    		j menuLoop
	
# 2. Find the average value of the elements of the list.
FIND_AVERAGE:
	lw $t1, elem_count	# t1 = # of elements
	la $t2, float_array	# Pointer
	mtc1 $zero, $f0		# Sum
	
	avg_sum_loop:
		beqz $t1, avg_compute	# if no elements, end loop
		l.s $f2, 0($t2)		# loads the current array element in $f2
		add.s $f0, $f0, $f2	# sum + element
		addi $t2, $t2, 4	# move to the next element
		addi $t1, $t1, -1	# counter--
		j avg_sum_loop		# repeat
		
	avg_compute:
		lw $t3, elem_count	# Reloads element count
		mtc1 $t3, $f4
		cvt.s.w $f4, $f4	# $f4 = float(elem_count)
	
		div.s $f6, $f0, $f4	# $f6 = average
	
		la $a0, average
		li $v0, 4
		syscall
	 
		mov.s $f12, $f6
		li $v0, 2
		syscall
	
		la $a0, newline
		li $v0, 4
		syscall 
	
		j menuLoop
	
# 3. Find the lowest element of the list.
FIND_LOWEST:
	lw $t1, elem_count	# load # of elements in $t1
	blez $t1, menuLoop	# If list is empty, end
	la $t2, float_array
	
	l.s $f0, 0($t2)		# $f0 will hold the lowest value
	addi $t2, $t2, 4	# next element
	addi $t1, $t1, -1	# decrement
	
	find_lowest_loop:
		beqz $t1, lowest_done	# If no elements, exit
		l.s $f2, 0($t2)		# load element
		c.lt.s $f2, $f0		# if f2 < f0 = new lowest
		bc1f lowest_skip	# if false, skip
		mov.s $f0, $f2		# lowest is current element
	
	lowest_skip:
		addi $t2, $t2, 4	# next element
		addi $t1, $t1, -1	# decrement
		j find_lowest_loop
	
	lowest_done:
    		# Print "The lowest value is "
    		la $a0, lowest
    		li $v0, 4
    		syscall

    		# Print lowest value (float in $f0)
    		mov.s $f12, $f0
    		li $v0, 2
    		syscall

    		# Print newline for readability
    		la $a0, newline
    		li $v0, 4
    		syscall

    		# Return to menu
    		j menuLoop
	
# 4. Find the greatest element of the list.
FIND_GREATEST:
	lw $t1, elem_count	# load # of elements in $t1
	blez $t1, menuLoop	# If list is empty, end
	la $t2, float_array
	
	l.s $f0, 0($t2)		# $f0 will hold the lowest value
	addi $t2, $t2, 4	# next element
	addi $t1, $t1, -1	# decrement
	
	find_greatest_loop:
		beqz $t1, greatest_done	# If no elements, exit
		l.s $f2, 0($t2)		# load element
		c.lt.s $f0, $f2 	# if f2 < f0 = new lowest
		bc1f greatest_skip	# if false, skip
		mov.s $f0, $f2		# lowest is current element
	
	greatest_skip:
		addi $t2, $t2, 4	# next element
		addi $t1, $t1, -1	# decrement
		j find_greatest_loop
	
	greatest_done:
    		# Print "The lowest value is "
    		la $a0, greatest
    		li $v0, 4
    		syscall

    		# Print lowest value (float in $f0)
    		mov.s $f12, $f0
    		li $v0, 2
    		syscall

    		# Print newline
    		la $a0, newline
    		li $v0, 4
    		syscall

    		# Return to menu
    		j menuLoop
    	
# 5. Find the sum of all elements of the list.
FIND_SUM:
	lw $t1, elem_count	# t1 = # of elements
	la $t2, float_array	# Pointer
	mtc1 $zero, $f0		# Sum
	
	sum_loop:
		beqz $t1, sum_done	# if no elements, end loop
		l.s $f2, 0($t2)		# loads the current array element in $f2
		add.s $f0, $f0, $f2	# sum + element
		addi $t2, $t2, 4	# move to the next element
		addi $t1, $t1, -1	# counter--
		j sum_loop		# repeat
	
	sum_done:
		la $a0, sum		# "The sum of the list it"
		li $v0, 4
		syscall
	
		mov.s $f12, $f0		# moves the sum to $f0
		li $v0, 2
		syscall
	
		la $a0, newline		# new line
		li $v0, 4
		syscall 
		j menuLoop
	
# 6. Print a specific index of the list.
FIND_INDEX:
	la $a0, index_prompt
	li $v0, 4
	syscall
	j menuLoop
	
# 7. Print the list contents.
PRINT_LIST:
#initialize registers for array, counter, and max elements
la $t4, float_array
move $t7, $zero
lw $s5, elem_count


li $v0, 4
la $a0, openBracket
syscall

	print_loop:
    		bge $t7, $s5, exit
    		l.s $f12, 0($t4)
    		li $v0, 2            
    		syscall

    		addi $t7, $t7, 1
    		addi $t4, $t4, 4
    		blt $t7, $s5, print_comma
    		j newline_out

	print_comma:
    		li $v0, 4
    		la $a0, comma
    		syscall
    		j print_loop

	newline_out:
		li $v0, 4
		la $a0, closedBracket
		syscall
		
    		li $v0, 4
    		la $a0, newline
    		syscall
    	exit:
	la $a0, complete
	li $v0, 4
	syscall
	j menuLoop

# Invalid menu option handler
INVALID_OPTION:
	la $a0, invalid_menu
	li $v0, 4
	syscall
	j menuLoop
	
# Exits
EXIT_PROGRAM:
	la $a0, goodbye
	li $v0, 4
	syscall

	li $v0, 10
	syscall
