# CS 35101 Computer Organization
# Wil Nahra/Cayden Jones
# Homework 3
# 11/02/2025

.data
prompt_enter_list:    .asciiz "This is the list sorting program.\nPlease enter a list to process\n"
input_buf:            .space 256            # buffer for user input line
input_buf_len:        .word 256

# Prompts the user for an operation
menu_prompt: .asciiz "\nPlease select an option:\n1. Sort\n2. Calculate average of all values.\n3. Find the lowest element.\n4. Find the greatest element.\n5. Find the sum of all elements.\n6. Print a specific element.\n7. Print the list contents.\n8. Exit.\n> " 
list_sorted: .asciiz "List sorted!\n" 			# lets the user know the list has been sorted
goodbye: .asciiz "Goodbye!\n" 					# Exits program
lowest: .asciiz "The lowest value is " 			# for displaying the lowest value in the list
greatest: .asciiz "The greatest value is " 		# for displaying the highest value in the list
sum: .asciiz "The sum of the list is " 			# for displaying the sum of the list
average: .asciiz "The average of the list is "	# for displaying the average of the list
index_prompt: .asciiz "Enter index (0-based):"  # prompts user to enter a value to look for the value in that index
invalid: .asciiz "Invalid index.\n" 			# if invalid, will print
complete:.asciiz "Completed!\n" 				# displays when complete
invalid_menu: .asciiz  "Invalid, menu selection, try again\n"

# Storage parameters
MAX_ELEMS:            .word 100    # change if you want support for more elements
float_array:          .space 400   # 100 * 4 bytes = 400 bytes (use MAX_ELEMS*4)
elem_count:           .word 0

.text
main:
	la $a0, menu_prompt
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
 	move $t0, $v0
	
	beq $t0, 1, SORT_LIST
	beq $t0, 2, FIND_LOWEST
	beq $t0, 3, FIND_GREATEST
	beq $t0, 4, FIND_AVERAGE
	beq $t0, 5, FIND_SUM
	beq $t0, 6, FIND_INDEX
	beq $t0, 7, PRINT_LIST
	beq $t0, 8, EXIT_PROGRAM
	
	la $a0, invalid_menu
	li $v0, 4
	syscall
	j main
	
SORT_LIST:
	la $a0, list_sorted
	li $v0, 4
	syscall
	j main
FIND_LOWEST:
	la $a0, lowest
	li $v0, 4
	syscall
	j main
FIND_GREATEST:
	la $a0, greatest
	li $v0, 4
	syscall
	j main
FIND_AVERAGE:
	la $a0, average
	li $v0, 4
	syscall
	j main
FIND_SUM:
	la $a0, sum
	li $v0, 4
	syscall
	j main
FIND_INDEX:
	la $a0, index_prompt
	li $v0, 4
	syscall
	j main
PRINT_LIST:
	la $a0, ($t0)
	li $v0, 1
	syscall
	j main
EXIT_PROGRAM:
	la $a0, goodbye
	li $v0, 4
	syscall

	li $v0, 10
	syscall




