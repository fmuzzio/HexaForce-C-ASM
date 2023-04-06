;;;;;;;;;;;;;;;;;;;;;;;;;;;;main;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CODE
		.FALIGN
main
	;; prologue
	STR R7, R6, #-2	;; save caller's return address
	STR R5, R6, #-3	;; save caller's frame pointer
	ADD R6, R6, #-3 ;; update stack pointer 
	ADD R5, R6, #0  ;; creates/updates frame pointer 
	ADD R6, R6, #-3	;; allocate space for local vars
	
	;; function body
	CONST R7, #5
	STR R7, R5, #-1 ;; save a = 5 on stack 
	CONST R7, #0
	STR R7, R5, #-2 ;; save b = 0 on stack 

	LDR R7, R5, #-1 ;; get param (a)
	ADD R6, R6, #-1 ;; allocate space for the param 
	STR R7, R6, #0  ;; copy param (a) on top of stack  
	JSR SUB_FACTORIAL ;; jump to subroutine
	
	
	LDR R7, R6, #-1	;; grab return value
	ADD R6, R6, #1	;; free space for arguments
	STR R7, R5, #-2
	CONST R7, #0
L1_problem1
	;; epilogue
	ADD R6, R5, #0	;; pop locals off stack
	ADD R6, R6, #3	;; free space for return address, base pointer, and return value
	STR R7, R6, #-1	;; store return value
	LDR R5, R6, #-3	;; restore base pointer
	LDR R7, R6, #-2	;; restore return address
	RET

