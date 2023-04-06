;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : factorial_sub.asm                      ;
;  author      : Francisco Muzzio
;  description : LC4 Assembly program to compute the    ;
;                factorial of a number via a subroutine ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; register allocation: R0=A, R1=B

  CONST R0, #5              ; R0 = 5
  ADD R1, R1, R0            ; B  = A 
  
JSR SUB_FACTORIAL           ; Jump to subroutine 

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