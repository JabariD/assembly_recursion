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
