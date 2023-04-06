;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : os.asm                                 ;
;  author      : 
;  description : LC4 Assembly program to serve as an OS ;
;                TRAPS will be implemented in this file ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Using unlocked OS.asm code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; OS Code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.OS
	.CODE
	.ADDR x8000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; TRAP VECTOR TABLE ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	JMP TRAP_GETC		; x00
	JMP TRAP_PUTC		; x01
	JMP TRAP_GETS		; x02
	JMP TRAP_PUTS		; x03
	JMP TRAP_GETC_TIMER ; x04
	JMP TRAP_DRAW_RECT 	; x05

	; CIT 593 TODO: Add vectors for your additional traps

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;; OS MEMORY ADDRESS CONSTANTS ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

USER_CODE_ADDR 	.UCONST x0000
OS_CODE_ADDR 	.UCONST x8000
OS_VIDEO_ADDR 	.UCONST xC000
OS_VIDEO_NUM_COLS .UCONST #128 ; from lecture
OS_VIDEO_NUM_ROWS .UCONST #124 ; from lecture

OS_KBSR_ADDR	.UCONST xFE00	; keyboard status register
OS_KBDR_ADDR	.UCONST xFE02	; keyboard data register
OS_ADSR_ADDR	.UCONST xFE04	; display status register
OS_ADDR_ADDR	.UCONST xFE06	; display data register
OS_TSR_ADDR	.UCONST xFE08	; timer register
OS_TIR_ADDR	.UCONST xFE0A	; timer interval register
OS_VDCR_ADDR	.UCONST xFE0C	; video display control register


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; OS START  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; operating system entry point (always starts at x8200) ;;;;

	.CODE
	.ADDR x8200
OS_START
	;; R7 <- User code address (x0000)
	LC R7, USER_CODE_ADDR
	RTI			; RTI removes the privilege bit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; OS VIDEO MEMORY ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.DATA
	.ADDR xC000
OS_VIDEO_MEM .BLKW x3E00
	; this merely reserves 3E00 rows of memory for video

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; OS GLOBALS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.ADDR xA000
OS_GLOBALS_MEM	.BLKW x1000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_GETC ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_GETC - Check for a character from the keyboard
;;; Inputs    - none
;;; Outputs   - R0 = value of character read from the keyboard

	.CODE
TRAP_GETC
	LC R0, OS_KBSR_ADDR
	LDR R0, R0, #0
	BRzp TRAP_GETC		; loop while the MSB is zero

	LC R0, OS_KBDR_ADDR
	LDR R0, R0, #0		; read in the character

	RTI



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_PUTC ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_PUTC - Put a character on the console
;;; Inputs    - R0 = ASCII caharacter value to output to display
;;; Outputs   - none

	.CODE
TRAP_PUTC
	LC R1, OS_ADSR_ADDR
	LDR R1, R1, #0
	BRzp TRAP_PUTC		; loop while the MSB is zero

	LC R1, OS_ADDR_ADDR
	STR R0, R1, #0		; write out the character

	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_GETS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_GETS - Check for a string from the keyboard
;;; Inputs    - R0 = address of where string should be written to
;;; Outputs   - R1 = length of string that has been read in
;;; R0 = The start address of where to write keyboard input
;;; R1 = counter for how many letters were stored in memory (except the null)
;;; R2 = store status register
;;; R3 = pointer to OS_KBDR_ADDR
;;; R4 = Used to check if dmem address in R0 is out of bounds
;;; R5 = Actual value we just read from keyboard
;;; R6 = Used to store null hex, then used to store value for ENTER, and also used to store value we write to

	.CODE
TRAP_GETS

	CONST R1, #0	 		; Initialize counter to 0

	CONST R4 x00
	HICONST R4 x20 			;; Store x2000 into R4

	CMP R0 R4	 		; CHECK if the contents of R0 are < starting point (in dmem)
	BRn DONE_GETS_NO_WRITE	 	; RTI if before starting point in dmem

	CONST R4 xFF
	HICONST R4 x7F 			;; Store x7FFF into R4

	CMP R0 R4	 		; CHECK if the contents of R0 are > ending point (in dmem)
	BRP DONE_GETS_NO_WRITE	 	; RTI if after ending point in dmem

	CONST R4 x00
	CONST R4 x00            	; Re-initiate R4 to 0 so it can be used elsewhere

READ

	LC R2, OS_KBSR_ADDR		; load address of status register
	LDR R2, R2, #0			; load the contents of the register
	BRzp READ			; loop while ADSR[15]==0 (waiting for keyboard typing)


	LC R3, OS_KBDR_ADDR		; get the address of data register used to read from keyboard
	LDR R5, R3, #0			; read in the character at this address


	CONST R6 x00;
	HICONST R6 x0D			; Store "ENTER" hex into R6

	CMP R5 R6	 		; check if we just got the ASCII that represents the ENTER KEY BEING HIT
 	BRz DONE_GETS			; if check says we did then jump to end

	CONST R6 x0A			; Store "RETURN" hex into R6 (for my laptop?)
	CMP R5 R6	 		; check if we just got the ASCII that represents the ENTER KEY BEING HIT
 	BRz DONE_GETS			; if check says we did then jump to end


	CONST R6 x00			; Store "RETURN" hex into R6 (x00 when I run outside of )
	CMP R5 R6	 				; check if we just got the ASCII that represents the ENTER KEY BEING HIT
	BRz DONE_GETS			; if check says we did then jump to end


 	ADD R4 R0 R1			; Store in R4 where in dmem we write to on this iteration
	STR R5, R4, #0			; store ASCII value in R5 into dmem at R0


	ADD R1, R1, #1			; increment counter
	BRnzp READ


DONE_GETS

	CONST R6 x00
	HICONST R6 x00 			; store null hex into R6


	ADD R4 R0 R1			; Get the location of the last previously written thing
	ADD R4 R4 #1			; Increment this location by one
	STR R6,R4, #0			; store null into data register located one after last place we wrote to
DONE_GETS_NO_WRITE
	RTI						; return from TRAP and R1 should have length since it was the counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_PUTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_PUTS - Check for a string from the keyboard
;;; Inputs    - R0 = address of where string is located
;;; Outputs   - no output
;;; R0 used to store argument from caller
;;; R1 used to load initial value
;;; R2 to see data address status register
;;; R3 to store OS_ADDR_ADDR
;;; R4 Used for comparison first and then as counter for incrementing where will store in data registers
;;; R2 = R0 + counter since LDR only takes a register and a number
;;;

	.CODE
TRAP_PUTS

	CONST R4 x00
	HICONST R4 x20 			;; Store x2000 into R4

	CMP R0 R4	 			; CHECK if the contents of R0 are < starting point (in dmem)
	BRn DONE_PUTS	 		; RTI if before starting point in dmem

	CONST R4 xFF
	HICONST R4 x7F 			;; Store x2000 into R4

	CMP R0 R4	 			; CHECK if the contents of R0 are > ending point (in dmem)
	BRp DONE_PUTS	 		; RTI if after ending point in dmem

	CONST R4, #0	 		; Initialize counter to 0

LOAD
	ADD R2, R4, R0
	LDR R1, R2, #0		 	; Load the contents of address R0 + iteration (in dmem) into R1
	CMPI R1 x0000	 		; check if we just got the ASCII that represents the end of a string
 	BRz DONE_PUTS


	LC R2, OS_ADSR_ADDR		; load address of status register
	LDR R2, R2, #0			; load the contents of the register
	BRzp LOAD				; loop while ADSR[15]==0 (not sure what we are waiting for tbh though)

	LC R3, OS_ADDR_ADDR		; get the address of data register used to display
	STR R1, R3, #0			; store ASCII value (at R5 which is OS_ADDR_ADDR + iteration we are at)

	ADD R4, R4, #1			; increment where will put the next value to

	BRnzp LOAD


DONE_PUTS
	RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_GETC_TIMER ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_GETC_TIMER - Check for a character from the keyboard
;;;                   but only allow 2000ms (2 seconds)
;;; Inputs    - none
;;;
;;; Outputs   - R0 = value of character read from the keyboard
;;; R0 = Holds address keyboard status and then holds address
;;; R1 = Point to os timer for setting timer
;;; R2 = Holds 2000 ms in hex format
;;; R3 = Point to os timer for checking timer
;;; R4 = Store value of timer check

TRAP_GETC_TIMER

	LC R1, OS_TIR_ADDR	 ; TIR ADDRESS R1
	LC R3, OS_TSR_ADDR	 ; TSR ADDRESS R3

	CONST R2 xD0
	HICONST R2 x07       ; store 2000ms into R2
	STR R2 R1 #0		 ; set the timer

AWAIT_LOOP
	LDR R4, R3, #0		 ; R4 now has time elapsed
	BRn DONE_WAITING	 ; go to RTI if you're done waiting

	LC R0, OS_KBSR_ADDR
	LDR R0, R0, #0
	BRn READY_TO_READ		; jump when ready to read
	BRz AWAIT_LOOP

READY_TO_READ
	LC R0, OS_KBDR_ADDR
	LDR R0, R0, #0		; read in the character

DONE_WAITING
	RTI


;;; TRAP_DRAW_RECT - draw rectangle at caller specific location and with caller specified size
;;; Input from caller
;;;   R0 = x coordinate
;;;   R1 = y coordinate (later used to keep track of rows)
;;;   R2 = length of rect...but then stored in memory and used to toggle
;;;   R3 = width of side of rect
;;;   R4 = the color of the box..but then color is stored and use R4 as columns counter
;;;   R7 = max # of col/rows and then pointer to current memory we are coloring in
;;; Output
;;;   Visual representation of the rect in the black screen


	.CODE
TRAP_DRAW_RECT

								;;; Width and length must be greater than 0

	STR R7, R6, #-2	;; save return address (of user start)
	STR R5, R6, #-3	;; save base pointer (of user start)
	ADD R6, R6, #-3 ;; UPDATE STACK POINTER -- update stack pointer (up by 3)
	ADD R5, R6, #0  ;; SET FRAME POINTER to be stack pointer
	ADD R6, R6, #-5	;; allocate stack space for local variables (move stack pointer up by 5 for 1 local variable)

	STR R0 R5 #-1
	STR R1 R5 #-2
	STR R2 R5 #-3
	STR R3 R5 #-4
	STR R4 R5 #-5


	CMPI R2, #0
	BRnz DONE_DRAWING

	CMPI R3, #0
	BRnz DONE_DRAWING

	CMPI R1, #0
	BRnz DONE_DRAWING

	LC R7 OS_VIDEO_NUM_ROWS
	CMP R3, R7
	BRp DONE_DRAWING			;;; Width should not exceed 124

	LC R7 OS_VIDEO_NUM_COLS
	CMP R2, R7
	BRp DONE_DRAWING			;;; Length should not exceed 128


	CMPI R0, #0					;;; x and y coordinates must be greater than 0
	BRn DONE_DRAWING

	CMPI R1, #0
	BRn DONE_DRAWING

	ADD R3, R3, R1				;; Make sure that length/width combined with x,y offsets
	ADD R2, R2, R0				;; still create a valid rectangle to draw

VALIDATE_SIZE_AND_POSITION_Y	;; check if y coordinate with y length is valid
	LC R7 OS_VIDEO_NUM_ROWS
	CMP R3 R7
	BRp FIX_Y

VALIDATE_SIZE_AND_POSITION_X	;; check if x coordinate with x length is valid
	LC R7 OS_VIDEO_NUM_COLS
	CMP R2, R7
	BRp FIX_X
	BRnz SET_UP_NEW_ROW			;; if we are here then we didnt have to fix X and Y, so jump to loop

FIX_Y
	SUB R7, R3, R7
	SUB R0, R0, R7
	SUB R3, R3, R7				;;; Move y coordinate back by overflow and shorten length by overflow
	BRnzp VALIDATE_SIZE_AND_POSITION_X

FIX_X
	SUB R7, R2, R7
	SUB R0, R0, R7
	SUB R2, R2, R7				;;; Move x coordinate back by overflow and shorten length by overflow


SET_UP_NEW_ROW 					;;; Find our initial spot to write. Pointer to OS_VIDEO_MEM

						;;; We need to offset by y coordinate
	LC R7 OS_VIDEO_NUM_COLS			;;; Get max number of columns
	MUL R7, R1, R7				;;; R7 = R1*128 (because we technically are doing a grid)
	LEA R4, OS_VIDEO_MEM			;;; Find location in memory allocated for video
	ADD R7, R7, R0				;;; ;;; Add the x and y coordinate offset (x,y)
	ADD R7, R7, R4

	ADD R4, R0, #0				;;; R6 will store our current column. We start at x coordinate given
	BRnzp UPDATE_ROW_IF_DONE

DRAW_COLUMN


	STR R2 R5 #-3					;; save R2 up by 3
  LDR R2 R5 #-5         ;; LOAD COLOR INTO R2
	STR R2, R7, #0				;;; store color in the address with our hex color
	LDR R2  R5 #-3         ;; LOAD original R2 into R2	 up by 3
	ADD R4, R4, #1				;;; Increment column counter
	ADD R7, R7, #1				;;; Point to next address in OS_VIDEO_MEM


UPDATE_ROW_IF_DONE
	CMP R4, R2
	BRn DRAW_COLUMN
	ADD R1, R1, #1 				; Update row we are on
	CMP R1, R3					; check if we are done
	BRn SET_UP_NEW_ROW 			; if we are not done, go back up to set up a new row

DONE_DRAWING					; when done, return

	ADD R6, R5, #0	         ;; pop locals off stack -- need to move stack pointer down to frame pointer
	ADD R6, R6, #3	         ;; free space for return address, base pointer, and return value
	LDR R5, R6, #-3	         ;; restore base pointer
	LDR R7, R6, #-2	         ;; restore return address
													 ;; there is no return value to this method so R6 #-1 was never used for anything other than argument

	RTI