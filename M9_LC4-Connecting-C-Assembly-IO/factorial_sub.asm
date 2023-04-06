;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : factorial_sub.asm                      ;
;  author      : Francisco Muzzio
;  description : LC4 Assembly program to compute the    ;
;                factorial of a number via a subroutine ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




       

.FALIGN
SUB_FACTORIAL               ; ARGS: R0(A), R1(B)


;; PROLOGUE
	STR R7, R6, #-2	;; save caller's return address
	STR R5, R6, #-3	;; save caller's frame pointer
	ADD R6, R6, #-3 ;; update stack pointer 
	ADD R5, R6, #0  ;; creates/updates frame pointer 
	ADD R6, R6, #-3	;; make space for local variables of function 

;;;;;;;SUB_FACTORIAL FUNCTION BODY ;;;;;;;;;;;;;;;

  LDR R0, R5, #3            ;  Store 5 into R0 so that we can keep track of factorial loop decrement and be used in main function body 
  ADD R1, R0 #0             ;  Store R0 into R1 so that it can be used to calculate value of factorial 


  CMPI R0, #8                 
  BRp END_PROG              ; Largest number algorithm can work with is one that when used in factorial,
                            ; it doesnt go over xFFFF = 65,535  and cause overflow therefore 8! = 40320 is max value we can work with 
                            ; and we do the check with Thus, if differernce (R0-8) is positive then our number is too big and we jump to
                            ; END_PROG subroutine
  
  CMPI R0, #0
  BRn END_PROG              ; If number is negative condition check 



FACTORIAL_LOOP
  CMPI R0, #1               ; Start of while loop in case above checks were passed 
  BRnz END_FACTORIAL        ; Tests NZP (was A-0 neg or zero?, if yes, goto END)
  ADD R0, R0, #-1           ; A=A-1
  MUL R1, R1, R0            ; B=B*A
  JMP FACTORIAL_LOOP        ; End loop 
  END_FACTORIAL
  

 ADD R7, R1, #0             ; store the return value (from R1) to the right place in the stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; EPILOGUE
  ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET


;; Modified factorial_sub script to return -1 if factorial value is greater than register width 
END_PROG
CONST R1, #-1              ; If either condition is met with R0 (A<0 || A>8), after writing -1 to the values of B (xFFFF)
  RET                      ; End subroutine 