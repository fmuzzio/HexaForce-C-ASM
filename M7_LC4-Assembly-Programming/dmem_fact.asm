;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : dmem_fact.asm                          ;
;  author      : Francisco Muzzio
;  description : LC4 Assembly program to compute the    ;
;                factorial of a number with data memory ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  .DATA                       ; Lines below are DATA memory
  .ADDR x4020                 ; Where to start in DATA memory 

global_array                  ; Label address x4020: global_array
  .FILL #6                    ; Address x4020
  .FILL #5                    ; Address x4021
  .FILL #8                    ; Address x4022
  .FILL #10                   ; Address x4023
  .FILL #-5                   ; Address x4024


  .CODE                       ; Lines below are program memory
  .ADDR x0000                 ; Where to start in program memory



  LEA R0, global_array        ; Assign R0 to data address 
  LDR R0, R0, #0              ; Load value @ offset 0
  ADD R1, R1, R0              ; B  = A            
  JSR SUB_FACTORIAL           ; Jump to subroutine 

  LEA R0, global_array        ; Reassign R0 to data address
  STR R1, R0, #0              ; Overwrite value @ x4020 
                              
  CONST R1, #0                ; Reassign 0 to R1 for factorial count 
  LEA R0, global_array        ; Reassign R0 to data address
  LDR R0, R0, #1              ; Load value @ offset 1
  ADD R1, R1, R0              ; B  = A            
  JSR SUB_FACTORIAL           ; Jump to subroutine 

  LEA R0, global_array        ; Reassign R0 to data address
  STR R1, R0, #1              ; Overwrite value @ x4021 

  CONST R1, #0                ; Reassign 0 to R1 for factorial count 
  LEA R0, global_array        ; Reassign R0 to data address
  LDR R0, R0, #2              ; Load value @ offset 2
  ADD R1, R1, R0              ; B  = A            
  JSR SUB_FACTORIAL           ; Jump to subroutine

  LEA R0, global_array        ; Reassign R0 to data address
  STR R1, R0, #2              ; Overwrite value @ x4022 

  CONST R1, #0                ; Reassign 0 to R1 for factorial count 
  LEA R0, global_array        ; Reassign R0 to data address
  LDR R0, R0, #3              ; Load value @ offset 3
  ADD R1, R1, R0              ; B  = A            
  JSR SUB_FACTORIAL           ; Jump to subroutine

  LEA R0, global_array        ; Reassign R0 to data address
  STR R1, R0, #3              ; Overwrite value @ x4023
                               
  CONST R1, #0                ; Reassign 0 to R1 for factorial count 
  LEA R0, global_array        ; Reassign R0 to data address
  LDR R0, R0, #4              ; Load value @ offset 4
  ADD R1, R1, R0              ; B  = A            
  JSR SUB_FACTORIAL           ; Jump to subroutine

  LEA R0, global_array        ; Reassign R0 to data address
  STR R1, R0, #4              ; Overwrite value @ x4024                             


  JMP END

END_PROG
  CONST R1, #-1             ; If either condition is met with R0 (A<0 || A>8), after writing -1 to the values of B (xFFFF)
  JMP END_FACTORIAL         ; its going to jump to the END_FACTORIAL  subroutine to finish off 
     


.FALIGN
SUB_FACTORIAL               ; ARGS: R0(A), R1(B)

  CMPI R0, #8                 
  BRp END_PROG              ; Largest number algorithm can work with is one that when used in factorial,
                            ; it doesnt go over xFFFF = 65,535  and cause overflow therefore 8! = 40320 is max value we can work with 
                            ; and we do the check with Thus, if differernce (R0-8) is positive then our number is too big and we jump to
                            ; END_PROG subroutine
  
  CMPI R0, #0
  BRn END_PROG              ; If number is negative condition check 
  CMPI R0, #1               ; Start of while loop in case above checks were passed 
  BRnz END_FACTORIAL        ; Tests NZP (was A-0 neg or zero?, if yes, goto END)
  ADD R0, R0, #-1           ; A=A-1
  MUL R1, R1, R0            ; B=B*A


  JMP SUB_FACTORIAL         ; End loop 
  END_FACTORIAL 
  RET                       ; End subroutine 
  END                       ; End program