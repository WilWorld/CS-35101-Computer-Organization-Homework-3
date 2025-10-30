# CS 35101 Computer Organization
# Wil Nahra/Cayden Jones
# Homework 3
# 11/02/2025
.globl main

.data
prompt_enter_list:    .asciiz "This is the list sorting program.\nPlease enter a list to process\n"
input_buf:            .space 256            # buffer for user input line
input_buf_len:        .word 256

# Prompts the user for an operation
menu_prompt: .asciiz "Please select an option: \n1. Sort\n2. Calculate average of all values.\n3. Find the lowest element.\n4. Find the greatest element.\n5. Find the sum of all elements.\n6. Print a specific element.\n7. Print the list contents.\n8. Exit.\n> " 
list_sorted: .asciiz "List sorted!\n" 			# lets the user know the list has been sorted
goodbye: .asciiz "Goodbye!\n" 					# Exits program
lowest: .asciiz "The lowest value is " 			# for displaying the lowest value in the list
greatest: .asciiz "The greatest value is " 		# for displaying the highest value in the list
sum: .asciiz "The sum of the list is " 			# for displaying the sum of the list
average: .asciiz "The average of the list is "	# for displaying the average of the list
index_prompt: .asciiz "Enter index (0-based):"  # prompts user to enter a value to look for the value in that index
invalid: .asciiz "Invalid index.\n" 			# if invalid, will print
complete:.asciiz "Completed!\n" 				# displays when complete
invalid_menu: .asciiz  "Invalid menu selection, try again\n"
nextOperation: .asciiz "\nPlease select an option: \n"

# Storage parameters
MAX_ELEMS:            .word 100    # change if you want support for more elements
float_array:          .space 400   # 100 * 4 bytes = 400 bytes (use MAX_ELEMS*4)
elem_count:           .word 0

.text
main:
# PART 4: Each function will be executed as requested by the user, using a prompt system to display the different 
#    	  options available and process what the user wants.

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
	la $a0, list_sorted
	li $v0, 4
	syscall
	j menuLoop
	
# 2. Find the average value of the elements of the list.
FIND_AVERAGE:
	la $a0, average
	li $v0, 4
	syscall
	j menuLoop

# 3. Find the lowest element of the list.
FIND_LOWEST:
	la $a0, lowest
	li $v0, 4
	syscall
	j menuLoop
	
# 4. Find the greatest element of the list.
FIND_GREATEST:
	la $a0, greatest
	li $v0, 4
	syscall
	j menuLoop
	
# 5. Find the sum of all elements of the list.
FIND_SUM:
	la $a0, sum
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
