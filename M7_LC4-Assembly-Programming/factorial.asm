;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : factorial.asm                          ;
;  author      : Francisco Muzzio
;  description : LC4 Assembly program to compute the    ;
;                factorial of a number                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;; pseudo-code of factorial algorithm
;
; A = 5 ;  // example to do 5!
; B = A ;  // B=A! when while loop completes
;
; while (A > 1) {
; 	A = A - 1 ;
; 	B = B * A ;
; }
;

;;; TO-DO: Implement the factorial algorithm above using LC4 Assembly instructions


; register allocation: R0=A, R1=B
	  
  CONST R0, #5    ; A = 5
  ADD R1, R1, R0  ; B = A 

LOOP 
  CMPI R0, #1      ; Sets  NZP (A-0)
  BRnz END         ; Tests NZP (was A-0 neg or zero?, if yes, goto END)
  ADD R0, R0, #-1  ; A=A-1
  MUL R1, R1, R0   ; B=B*A
  JMP LOOP         ; Always goto LOOP 
END                ; End program