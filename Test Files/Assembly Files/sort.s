nop             # Sort
nop             # Author: Jack Proudfoot
nop             
nop
init:
addi $sp, $zero, 256        # $sp = 256
addi $27, $zero, 3840       # $27 = 3840 address for bottom of heap
addi $t0, $zero, 50
addi $t1, $zero, 3
sw $t1, 0($t0)
addi $t1, $zero, 1
sw $t1, 1($t0)
addi $t1, $zero, 4
sw $t1, 2($t0)
addi $t1, $zero, 2
sw $t1, 3($t0)
add $a0, $zero, $t0
j main
nop
malloc:                     # $a0 = number of words to allocate
nop
sub $27, $27, $a0           # allocate $a0 words of memory
nop
blt $sp, $27, mallocep      # check for heap overflow
nop
mallocep:
nop
add $v0, $27, $zero
nop
jr $ra
nop
buildlist:                  # $a0 = memory address of input data
nop
sw $ra, 0($sp)
nop
addi $sp, $sp, 1
nop
add $t0, $a0, $zero         # index of input data
nop
add $t1, $zero, $zero       # current list pointer
nop
addi $a0, $zero, 0
nop
jal malloc
nop
addi $t3, $v0, -3           # list head pointer
nop
lw $t2, 0($t0)              # load first data value
nop
j blguard
nop
blstart:
nop
addi $a0, $zero, 3
nop
jal malloc
nop
sw $t2, 0($v0)              # set new[0] = data
nop
sw $t1, 1($v0)              # set new[1] = prev
nop
sw $zero, 2($v0)            # set new[2] = next
nop
sw $v0, 2($t1)              # set curr.next = new
nop
addi $t0, $t0, 1            # increment input data index
nop
lw $t2, 0($t0)              # load next input data value
nop
add $t1, $zero, $v0         # set curr = new
nop
blguard:
nop
bne $t2, $zero, blstart
nop
add $v0, $t3, $zero         # set $v0 = list head
nop
addi $sp, $sp, -1
nop
lw $ra, 0($sp)
nop
jr $ra
nop
sort:                       # $a0 = head of list
nop
sw $ra, 0($sp)
nop
addi $sp, $sp, 1
nop
sortrecur:
nop
addi $t7, $zero, 0          # $t7 = 0
nop
add $t0, $a0, $zero         # $t0 = head
nop
add $t1, $t0, $zero         # $t1 = current
nop
j siguard
nop
sortiter:
nop
lw $t2, 0($t1)              # $t2 = current.data
nop
lw $t3, 0($t6)              # $t3 = current.next.data
nop
blt $t2, $t3, sinext
nop
addi $t7, $zero, 1          # $t7 = 1
nop
lw $t4, 1($t1)              # $t4 = current.prev
nop
bne $t4, $zero, supprev
nop
j supprevd
nop
supprev:
nop
sw $t6, 2($t4)              # current.prev.next = current.next
nop
supprevd:
nop
sw $t4, 1($t6)              # current.next.prev = current.prev
nop
lw $t5, 2($t6)              # $t5 = current.next.next
nop
bne $t5, $zero, supnnprev
nop
j supnnprevd
nop
supnnprev:
nop
sw $t1, 1($t5)              # current.next.next.prev = current
nop
supnnprevd:
nop
sw $t5, 2($t1)              # current.next = current.next.next
nop
sw $t1, 2($t6)              # current.next.next = current
nop
sw $t6, 1($t1)              # current.prev = current.next
nop
bne $t0, $t1, sinext
nop
add $t0, $t6, $zero         # head = current.next
nop
sinext:
nop
add $t1, $t6, $zero         # $t1 = current.next
nop
siguard:
nop
lw $t6, 2($t1)              # $t6 = current.next
nop
bne $t6, $zero, sortiter
nop
add $a0, $t0, $zero
nop
bne $t7, $zero, sortrecur
nop
add $v0, $t0, $zero         # $v0 = head
nop
addi $sp, $sp, -1
nop
lw $ra, 0($sp)
nop
jr $ra
nop
main:
nop
jal buildlist
nop
add $t0, $v0, $zero         # $t0 = head of list
nop
add $a0, $t0, $zero         # $a0 = head of list
nop
jal sort
nop
add $t0, $v0, $zero         # $t0 = head of sorted list
nop
add $t5, $zero, $zero
nop
add $t6, $zero, $zero
nop
add $t1, $t0, $zero
nop
j procguard
nop
proclist:
nop
lw $t2, 0($t1)
nop
add $t5, $t5, $t2
nop
sll $t6, $t6, 3
nop
add $t6, $t6, $t5
nop
lw $t1, 2($t1)
nop
procguard:
nop
bne $t1, $zero, proclist
nop
stop:
nop
j stop
nop