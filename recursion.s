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
     addi $t5, $zero, 21               # init check to see if more than 21 characters read
     addi $s4, $s4, 0                  # init counter to compare with 5
     lb $s1, 0($s6)                    # load character into $s1 
     
     beq $s4, $t5, invalid             # check counter > 21, invalid input
     beq $s1, $t3, continue            # check NULL character, let's convert to decimal
     beq $s1, $t4, continue            # check ENTER character, let's convert to decimal
     
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
addi $t7, $zero, 1
beq $s4, $t7, check_if_invalid_zero
continue_check_if_invalid_zero:
beq $s4, $zero, invalid # one last check

addi $s7, $zero, 1      # base case checker
addi $s6, $s4, 0        # s6 - base case checker
addi $s5, $s5, -1       # s5 - multiply Controller
addi $t2, $s5, 0        # cMC - copy Multiply Controller     

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

# Exit Program
exit:
li $v0, 10              # Exit Program Code
syscall                 # Do it


invalid:
li $v0, 4               # read string
la $a0, errorMSG        # in memory called error
syscall                 # do it
j exit                  # print error message then exit


# Recursive Converter untouchable: 
# s7 - basecase checcker: 1 ; s6 - num of characters; s5 - multiply controller; s0/a0: character
recursive_converter:
addi $sp, $sp -4            # create space for return address in stack
sw $ra, 0($sp)              # store return address in stack


beq $s6, $s7, basecase      # test if we have reached base case
addi $s0, $s0, 1            # move to next character

addi $s6, $s6, -1           # decrease num of ch i.e. base case checker

jal recursive_converter     # recursively call our function

basecase: 
lb $t0, 0($s0)              # load ch into t0

addi $s0, $s0, -1           # move to prev character

# get string representation of ch (2 digit at most) and put both digits (decimal number in ascii) in currNumber
# position:  0 1
# C would be 2 1.
slti $t6, $t0, 58           # less than or equal to: '9'
bne $t6, $zero, num_char    # if this is a number, we are good ---> go to next character

slti $t6, $t0, 88           # less than or equal to '87(W)': true
bne $t6, $zero, upper_char  # if this is a uppercase letter, we are good ---> go to next character
     
slti $t6, $t0, 120          # less than or equal to '119(w)': true
bne $t6, $zero, lower_char  # if this is a lowercase letter, we are good ---> go to next character

num_char:
addi $t6, $t0, -48          # subtract by 0 to get decimal value
j insertDigits              

upper_char:                 
addi $t6, $t0, -55          # subtract by A to get decimal value
j insertDigits 

lower_char:
addi $t6, $t0, -87          # subtract by a to get decimal value
j insertDigits


insertDigits:
la $s2, currNumber          # get address of currNumber in .data

addi $t9, $zero, 10
div $t6, $t9
mfhi $t9                    # get digit in one's place
# convert $t9 to ascii decimal
addi $t9, $t9, 48           # convert decimal to ascii
sb $t9, 0($s2)              # store one's place in pos 0

addi $t9, $zero, 10
div $t6, $t9
mflo $t9                    # get digit in ten's place
# convert $t9 to ascii decimal
addi $t9, $t9, 48           # convert decimal to ascii
sb $t9, 1($s2)              # store ten's place in pos 1


# tempAnswer = currNumber
la $s2, currNumber
la $t6, tempAnswer

lb $t9, 0($s2)              # load ascii representation of number currentNumber
sb $t9, 0($t6)              # store ascii representation of number in tempAnswer

lb $t9, 1($s2)              # load ascii representation of number curretNumber
sb $t9, 1($t6)              # store ascii representation of number in tempAnswer

###############################
# if cMC !=0
addi $t2, $zero, -1               # decrement t2 by 1.
beq $t2, $s5, addToFinalAnswer    # check if t2 (cMC == # of times to multiply)

# clear tempAnswer
sb $zero, 0($t6)
sb $zero, 1($t6)
sb $zero, 2($t6)
sb $zero, 3($t6)
sb $zero, 4($t6)
sb $zero, 5($t6)
sb $zero, 6($t6)
sb $zero, 7($t6)
sb $zero, 8($t6)
sb $zero, 9($t6)
sb $zero, 10($t6)
sb $zero, 11($t6)
sb $zero, 12($t6)
sb $zero, 13($t6)
sb $zero, 14($t6)
sb $zero, 15($t6)
sb $zero, 16($t6)
sb $zero, 17($t6)
sb $zero, 18($t6)
sb $zero, 19($t6)
sb $zero, 20($t6)
sb $zero, 21($t6)
sb $zero, 22($t6)
sb $zero, 23($t6)
sb $zero, 24($t6)
sb $zero, 25($t6)
sb $zero, 26($t6)
sb $zero, 27($t6)
sb $zero, 28($t6)
sb $zero, 29($t6)
sb $zero, 30($t6)
sb $zero, 31($t6)
sb $zero, 32($t6)
sb $zero, 33($t6)
sb $zero, 34($t6)
sb $zero, 35($t6)


# free variables   $s3, $a0
addi $k1, $zero, 0 # refresh to 0
addi $s3, $zero, 0 # refresh to 0

# $s2 - baseNumber, $s1 - currNumber, $t3 - bN_index, $t6 - cN_index , $t8 = carry, $t9 = total, $a2 = to_add,
# $s7 - p_index, $a3 - tempAnswer, $k0 - characters in base. $k1 - starts at 0

# multiply currNumber * baseNumber = tempAnswer; CMC-- ; # 2 FOR LOOPS!

la $s2, baseNumber      # s2 = baseNumber
la $s1, currNumber      # s1 = currNumber
la $a3, tempAnswer      # a3 = tempAnswer


addi $t3, $zero, 0      # baseNumber_index = 0
CurrentBaseMultiplication:
addi $t8, $zero, 0      # carry = 0
addi $t6, $zero, 0      # currNumber_index = 0
addi $s3, $zero, 0      # -- reset cN_index = 0

CurrentBaseMultiplication2:
add $s1, $s1, $t6       # add cN_index + currNumber address to get ch
lb $t1, 0($s1)          # load number in currNumber to $t0 -- currNumber[x]
sub $s1, $s1, $t6       # subtract cN_index - currNumber address to get starting position


add $s2, $s2, $t3       # add bN_index + baseNumber address to get ch
lb $t0, 0($s2)          # load first ch in baseNumber to $t0 -- baseNumber[x]
sub $s2, $s2, $t3       # subtract bN_index - baseNumber address to get starting position

addi $t1, $t1, -48      # convert ascii to decimal
addi $t0, $t0, -48      # convert ascii to decimal

mult $t0, $t1           # multiply currNumber[x] * baseNumber[x]
mflo $t9                # total value
add $a2, $t8, $t9       # to_add = carry + total
# recover p[p_index] value
add $s7, $t6, $t3       # p_index = bN_index + cN_index
add $a3, $a3, $s7       # $ p_index + p_index start addreess
lb $t9, 0($a3)          # load that value in #t9
bne $t9, $zero, check_if_not_zero

continue_check_if_not_zero:
add $t9, $t9, $a2       # p[p_index] + to_add 

# ---- carry
addi $v0, $zero, 10     # v0 = 10
div $t9, $v0
mflo $t8                # Carry = product[product_index] / 10
mfhi $t9                # Product[product_index] = product[product_index] % 10
# ---- carry

addi $t9, $t9, 48       # convert decimal back to ascii
sb $t9, 0($a3)          # store into p[p_index]

sub $a3, $a3, $s7       # restore index
 
addi $t6, $t6, 1        # cN_index++
addi $s3, $s3, 1        # currNumber characters reached
slti $a0, $s3, 2        # currNumber can only be as big as 2 characters!
bne $a0, $zero, CurrentBaseMultiplication2  


addi $t3, $t3, 1        # bN_index++
addi $k1, $k1, 1        # baseNumber characters reached
slti $k0, $k1, 2        # baseNumber can only be as big as 2 characters!
beq $k0, $zero, doneCurrentBaseMultiplication 

j CurrentBaseMultiplication  


doneCurrentBaseMultiplication:
# -------- near end of multiplcaion process 
addi $s7, $t3, 1        # new_p_index =  bN_index + 1
add $a3, $a3, $s7       # add to index
addi $t8, $t8, 48       # convert to ascii
sb $t8, 0($a3)          # store last carry in this value

addi $t2, $t2 1         #  cMC-- END  #

addi $k1, $zero, 0      # reset reg k1
addi $s3, $zero, 0      # reset reg s3


### ONE MULTIPLICATION DONE!!!!!!
### Now we to multiply a LOOP to multiply tempAnswer * baseNumber based on the multiply controller
loopMultiplication:
# if copyMultiplercontroller != 0; go into loop CMC--;
beq $t2, $s5, addToFinalAnswer


# Loop: Multiply tempAnswer * baseNumber = tempProduct; 

# multiply tempAnswer * baseNumber = tempAnswer; CMC-- ; # 2 FOR LOOPS!
la $s2, baseNumber      # s2 = baseNumber
la $s1, tempAnswer      # s1 = tempAnswer
la $a3, tempProduct     # a3 = tempProduct


addi $t3, $zero, 0      # bN_index = 0
addi $k1, $zero, 0
loopCurrentBaseMultiplication:
addi $t8, $zero, 0      # carry = 0
addi $t6, $zero, 0      # cN_index = 0
addi $s3, $zero, 0      # reset cN_index = 0

loopCurrentBaseMultiplication2:
add $s1, $s1, $t6
lb $t1, 0($s1)          # load first ch in currNumber to $t0 -- tempAnswer[x]
beq $t1, $zero, error_check_value_is_null
continue_error_check_value_is_null:
sub $s1, $s1, $t6


add $s2, $s2, $t3
lb $t0, 0($s2)          # load first ch in baseNumber to $t0 -- baseNumber[x]
sub $s2, $s2, $t3

addi $t1, $t1, -48      # convert ascii to decimal
addi $t0, $t0, -48      # convert ascii to decimal

mult $t0, $t1           # multiply currNumber[x] * baseNumber[x]
mflo $t9                # total value
add $a2, $t8, $t9       # to_add = carry + total
# recover p[p_index] value
add $s7, $t6, $t3       # p_index = bN_index + cN_index
add $a3, $a3, $s7       # $ p_index + p_index start addreess
lb $t9, 0($a3)          # load that value in #t9
bne $t9, $zero, loop_check_if_zero

loop_continue_check_if_not_zero:
add $t9, $t9, $a2       # p[p_index] + to_add 

# ---- carry
addi $v0, $zero, 10
div $t9, $v0
mflo $t8                # Carry = product[product_index] / 10
mfhi $t9                # Product[product_index] = product[product_index] % 10
# ---- carry

addi $t9, $t9, 48       # convert decimal back to ascii
sb $t9, 0($a3)          # store into p[p_index]

sub $a3, $a3, $s7       # restore index
 
addi $t6, $t6, 1        # -- tempAnswer_index++
addi $s3, $s3, 1        # -- currNumber characters reached
slti $a0, $s3, 50       # -- estimate 50 chs just to be sure
bne $a0, $zero, loopCurrentBaseMultiplication2 # --


addi $t3, $t3, 1        # -- bN_index++
addi $k1, $k1, 1        # -- baseNumber characters reached
slti $k0, $k1, 2        # --
beq $k0, $zero, loopdoneCurrentBaseMultiplication # --

j loopCurrentBaseMultiplication # --


loopdoneCurrentBaseMultiplication:
# -------- near end of multiplcaion process 
# we need to get the character RIGHT AFTER THE LAST VALUE! THIS IS THE ALGORITHM TO DO IT:
# HOLD COUNTER. WE LOOK FOR THE FIRST NON-ZERO (COUNTER++), WHEN THAT IS FOUND THE NEXT 0 WE FIND IS THE INDEX! (+ 2)
# PUT CARRY RIGHT THERE!
la $a3, tempProduct      # a3 = tempProduct
la $t3, tempProduct      # t3 = potentialAddress
addi $s3, $zero, 0       # counter
addi $t6, $zero, 50
findRemainderSpace:
lb $k0, 0($a3)
addi $k0, $k0, -48       # check if 0
bne $k0, $zero, saveRegasRemainder

Remaindercontinueloop:
addi $s3, $s3, 1         # increment counter
addi $a3, $a3, 1         # move to next character
beq $s3, $t6, storeRemainder
j findRemainderSpace

storeRemainder:
addi $t8, $t8, 48        # convert to ascii
sb $t8, 0($t3)           # store remainder in found index
# --- end of multiplication

# Copy tempProduct into tempAnswer # ------------------------------------
# clear tempAnswer
la $a3, tempAnswer
addi $k0, $zero, 50      
addi $a0, $zero, 0       # counter
clearTempAnswer:
sb $zero, 0($a3)         # set number to 0
addi $a0, $a0, 1
addi $a3, $a3, 1
beq $a0, $k0, continueclearTempAnswer
j clearTempAnswer

continueclearTempAnswer:

# tempAnswer = tempProduct
la $a3, tempAnswer
la $a0, tempProduct
addi $v0, $zero, 50 
addi $k0, $zero, 1
settempAnswerequaltotempProduct:
lb $t8, 0($a0)           # load byte from tempProduct
sb $t8, 0($a3)           # store that byte into tempAnswer
addi $k0, $k0, 1         # increment k0
beq $k0, $v0, continuesettempAnswerequaltotempProduct

addi $a0, $a0, 1         # next number in tempProduct by 1
addi $a3, $a3, 1         # next number in tempAnswer by 1
j settempAnswerequaltotempProduct

continuesettempAnswerequaltotempProduct:

# clear tempProduct
la $a3, tempProduct
addi $k0, $zero, 50
addi $a0, $zero, 0
clearTempProduct:
sb $zero, 0($a3)         # store zero in each byte
addi $a0, $a0, 1         # counter++
addi $a3, $a3, 1
beq $a0, $k0, continueclearTempProduct
j clearTempProduct

continueclearTempProduct:

 # ------------------------------------------------------
 
addi $t2, $t2, 1         # cMC -- copyMultiplyController++
j loopMultiplication




addToFinalAnswer:

# Add Final Answer + tempAnswer

addi $t9, $zero, 0       # counter
addi $s7, $zero, 50      # counter stop 50
addi $v0, $zero, 10      # to get actual value and carry
la $a3, tempAnswer       # a3 <- tempAnswer
la $a1, finalAnswer      # a1 <- finalAnswer
addToFinalSub:
lb $t1, 0($a3)           # t1 = tempAnswer[x]
lb $t0, 0($a1)           # t0 = finalAnswer[x]
beq $t1, $zero, another_check_if_zero_loop1
another_check_if_zero_loop_continue1:
beq $t0, $zero, another_check_if_zero_loop2
another_check_if_zero_loop_continue2:
addi $t1, $t1, -48       # convert ascii to decimal
addi $t0, $t0, -48       # convert ascii to decimal
add $t8, $t0, $t1        # to_add
add $a2, $gp, $t8        # total = to_add + carry
div $a2, $v0
mfhi $t0                 # p[i] <- (total) % 10
mflo $gp                 # carry <- (total) / 10


addi $t0, $t0, 48        # convert to ascii
sb $t0, 0($a1)           # store t0 into finalAnswer.

addi $a3, $a3, 1         # move to next character in tempAnswer
addi $a1, $a1, 1         # move to next character in finalAnswer
addi $t9, $t9, 1         # counter++
beq $t9, $s7, finallydone
j addToFinalSub

finallydone:
# last carry bit <- gp
la $a3, finalAnswer      #  t9
la $t3, finalAnswer
addi $s3, $zero, 0       # counter
addi $t6, $zero, 50
lastfindRemainderSpace:
lb $k0, 0($a3)
addi $k0, $k0, -48       # check if 0
bne $k0, $zero, lastsaveRegasRemainder 

lastRemaindercontinueloop:
addi $s3, $s3, 1         # counter++
addi $a3, $a3, 1         # move to next character
beq $s3, $t6, laststoreRemainder
j lastfindRemainderSpace

laststoreAddyinReg:
add $t3, $zero, $a3      # save address in t3
addi $a3, $a3, -1        # move back to last character
j lastRemaindercontinueloop

lastsaveRegasRemainder:
addi $a3, $a3, 1         # move to next character to check
lb $k0, 0($a3)           # load it in k0
addi $k0, $k0, -48       # ascii to decimal
beq $k0, $zero, laststoreAddyinReg
addi $a3, $a3, -1        # move back to last character
j lastRemaindercontinueloop

laststoreRemainder:
addi $gp, $gp, 48        # convert to ascii
sb $gp, 0($t3) 
addi $gp, $gp, -48       # convert back to decimal


addi $s5, $s5, 1         # multiply controller -- MAIN
addi $t2, $s5, 0         # cMC // Probably not needed.

lw $ra, 0($sp)
addi $sp, $sp, 4
jr $ra





check_if_not_zero:
addi $t9, $t9, -48
j continue_check_if_not_zero

loop_check_if_zero:
addi $t9, $t9, -48 # check if 0 or null
j loop_continue_check_if_not_zero

error_check_value_is_null:
addi $t1, $zero, 48
j continue_error_check_value_is_null

storeAddyinReg:
add $t3, $zero, $a3
addi $a3, $a3, -1
j Remaindercontinueloop

saveRegasRemainder:
addi $a3, $a3, 1
lb $k0, 0($a3)
addi $k0, $k0, -48 # ascii to decimal
beq $k0, $zero, storeAddyinReg
addi $a3, $a3, -1
j Remaindercontinueloop

another_check_if_zero_loop1:
addi $t1, $t1, 48
j another_check_if_zero_loop_continue1

another_check_if_zero_loop2:
addi $t0, $t0, 48
j another_check_if_zero_loop_continue2

check_if_invalid_zero:
la $k0, new_userInput
lb $t9, 0($k0)
addi $t9, $t9, -48
beq $t9, $zero, print_check_if_invalid_zero
j continue_check_if_invalid_zero

print_check_if_invalid_zero:
lb $a0, 0($k0)          # load byte
li $v0, 11 
syscall                 # print ch
j exit