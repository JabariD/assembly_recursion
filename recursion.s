.data

errorMSG: .asciiz "Invalid input"
userInput: .space 101
new_userInput: .space 101

baseNumber: .space 3
currNumber: .space 3

# Store baseNumber * currNumber into tempAnswer. # do it counter number of times
tempAnswer: .space 100       
# Temporary Storage
tempProduct: .space 100

# Add tempFinalAnswer to FinalAnswer
finalAnswer: .space 100

.text

# NOTE: characters are reversed!

main:
addi $gp, $zero, 0      # init -- carry for Final Addition  
la $t0, baseNumber      # load address of baseNumber
li $t1, 51              # get 3 in ascii
sb $t1, 0($t0)          # store 3 in ascii
addi $t0, $t0, 1        # go to next ch spot
sb $t1, 0($t0)          # store 3 in ascii

# Read 100ch from user
li $v0, 8               # Read string code is 8
la $a0, userInput       # Desired location in userInput
li $a1, 101             # 101 characters to be read
syscall                 # Do it

# Tabs/Spaces Management

# remove leading spaces/tabs

removeloop:
     addi $t0, $zero, 32               # ASCII code for space = 32
     addi $t1, $zero, 9                # ASCII code for tab = 9
     lb $s1, 0($a0)                    # $s1 = curr character
     beq $s1, $t0, next                # leading space, we can continue 
     beq $s1, $t1, next                # leading tab, we can continue
     j characterloopinit               # character is NOT a leading space or tab --> begin to store into string
     
next:
     addi $a0, $a0, 1                  # move to next character
     j removeloop                      # go back to new character
     
## process 2: after we see OUR last character and if we see a space/tab --> ONLY tabs/spaces allowed else INVALID! if reach NULL, we're good!

characterloopinit:
     la $s3, new_userInput             # load string into $s3
     la $s6, new_userInput             # PROPERFORMAT - we are manipulating the address of $s3, we need a copy of where the beginning of the address starts!
     addi $s2, $s2, 0                  # init INDEX for new string
     
characterloop:
     beq $s1, $t0 checkerloopnext      # check that character not space if it is stop
     beq $s1, $t1 checkerloopnext      # check that character not tab if it is stop
     beq $s1, $t3, checkerloopnext     # check that character not NULL character if it is stop 
     
     sb $s1, 0($s3)                    # otherwise store it in string
     
     addi $s3, $s3, 1                  # next space for character
     j characterloopnext               # we can continue, go to next character
     
characterloopnext:
     addi $a0, $a0, 1                  # move to next character
     lb $s1, 0($a0)                    # store next character in $s1
     j characterloop                   # jump back to character loop 
     
checker:
     addi $t3, $zero, 0                # check for NULL end
     addi $t4, $zero, 10               # check for (ENTER) character     
     beq $s1, $t0, checkerloopnext     # perfectly fine
     beq $s1, $t1, checkerloopnext     # perfectly fine 
     beq $s1, $t4, properformat        # we are good to go! (enter key)
     beq $s1, $t3, properformat        # we are good to go! (null character key)
     j invalid                         # if all else fails --> invalid!
     
checkerloopnext:
     addi $a0, $a0, 1                  # increment character to check
     lb $s1, 0($a0)                    # store it in $s1
     j checker                         # jump back to checker
     
properformat:
     # for each character until null key reached, increment counter, check if counter greater than 21 if true -> invalid, check that character in range, it passes
     addi $t5, $zero, 21                # init check to see if more than 21 characters read
     addi $s4, $s4, 0                  # init counter to compare with 5
     lb $s1, 0($s6)                    # load character into $s1 
     
     beq $s4, $t5, invalid             # check counter > 21, invalid input
     beq $s1, $t3, continue             # check NULL character, let's convert to decimal
     beq $s1, $t4, continue             # check ENTER character, let's convert to decimal
     
     slti $t7, $s1, 48                 # if char less than '0': true
     bne $t7, $zero, invalid           # for it to pass it should be 0(FALSE), so we know it's invalid 
     slti $t7, $s1, 58                 # less than or equal to: '9'
     bne $t7, $zero, properformatloop  # if this is a number, we are good ---> go to next character
     
     slti $t7, $s1, 65                 # if char less than '65(A)': true
     bne $t7, $zero invalid            # for it to pass it should be 0(FALSE), so we know it's invalid
     slti $t7, $s1, 88                 # less than or equal to '87(W)': true
     bne $t7, $zero, properformatloop  # if this is a uppercase letter, we are good ---> go to next character
     
     slti $t7, $s1, 97                 # if char less than '97(a)': true
     bne $t7, $zero invalid            # for it to pass it should be 0(FALSE), so we know it's invalid 
     slti $t7, $s1, 120                # less than or equal to '119(w)': true
     bne $t7, $zero, properformatloop  # if this is a lowercase letter, we are good ---> go to next character
     
     j invalid                         # if character is greater than a lowercase letter (catch-all)
     
properformatloop:
     addi $s4, $s4, 1                  # increment counter to check if # of characters > 5
     addi $s6, $s6, 1                  # go to the next character
     j properformat                    # jump back to properformat
     
     
# JAL into Base-33 Converter Function
continue:
beq $s4, $zero, invalid # one last check

addi $s7, $zero, 1   # base case checker
addi $s6, $s4, 0     # s6 - base case checker
addi $s5, $s5, -1    # s5 - multiply Controller
addi $t2, $s5, 0     # cMC - copy Multiply Controller     

la $a0, new_userInput   # pass input address to function
la $s0, new_userInput   # get character by character
jal recursive_converter # <-----------------------------------------------

# Print result
la $s0, finalAnswer
addi $t0, $zero, 50     # how we know we're done looping
addi $s3, $zero, 0      # counter to hit 50 characters
printresult:
lb $k0, 0($s0)          # load character into finalAnswer
addi $k0, $k0, -48      # convert char from ascii into decimal
bne $k0, $zero, open_spot_next_ch # check if char equals zero

print_continue_loop:
addi $s3, $s3, 1        # counter to hit
addi $s0, $s0, 1        # next ch
beq $s3, $t0, start_printing
j printresult 

laststoreAddyinRegprint:
add $t3, $zero, $s0     # store address
addi $s0, $s0, -1       # we added one to our index to just check, we can decrement it now
j print_continue_loop   # jump back to loop proto

open_spot_next_ch:
addi $s0, $s0, 1        # go to next character
lb $k0, 0($s0)          # store in k0
addi $k0, $k0, -48      # convert ascii to decimal
beq $k0, $zero, laststoreAddyinRegprint
addi $s0, $s0, -1       # go back to last character
j print_continue_loop   

start_printing:
la $a2, finalAnswer     # load address of a2
addi $t3, $t3, -1       # decremnt t3
lb $a0, 0($t3)          # load byte
li $v0, 11 
syscall                 # print ch
beq $t3, $a2, exit      # if t3 == a2 we are done!
j start_printing        # otherwise jump back to start_printing
