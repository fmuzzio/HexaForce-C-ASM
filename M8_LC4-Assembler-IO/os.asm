;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : os.asm                                 ;
;  author      : Francisco Muzzio
;  description : LC4 Assembly program to serve as an OS ;
;                TRAPS will be implemented in this file ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;   OS - TRAP VECTOR TABLE   ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.OS
.CODE
.ADDR x8000
  ; TRAP vector table
  JMP TRAP_GETC           ; x00
  JMP TRAP_PUTC           ; x01
  JMP TRAP_GETS           ; x02
  JMP TRAP_PUTS           ; x03
  JMP TRAP_TIMER          ; x04
  JMP TRAP_GETC_TIMER     ; x05
  JMP TRAP_RESET_VMEM	  ; x06
  JMP TRAP_BLT_VMEM	      ; x07
  JMP TRAP_DRAW_PIXEL     ; x08
  JMP TRAP_DRAW_RECT      ; x09
  JMP TRAP_DRAW_SPRITE    ; x0A

  ;
  ; TO DO - add additional vectors as described in homework 
  ;
  
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;   OS - MEMORY ADDRESSES & CONSTANTS   ;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; these handy alias' will be used in the TRAPs that follow
  USER_CODE_ADDR .UCONST x0000	; start of USER code
  OS_CODE_ADDR 	 .UCONST x8000	; start of OS code

  OS_GLOBALS_ADDR .UCONST xA000	; start of OS global mem
  OS_STACK_ADDR   .UCONST xBFFF	; start of OS stack mem

  OS_KBSR_ADDR .UCONST xFE00  	; alias for keyboard status reg
  OS_KBDR_ADDR .UCONST xFE02  	; alias for keyboard data reg

  OS_ADSR_ADDR .UCONST xFE04  	; alias for display status register
  OS_ADDR_ADDR .UCONST xFE06  	; alias for display data register

  OS_TSR_ADDR .UCONST xFE08 	; alias for timer status register
  OS_TIR_ADDR .UCONST xFE0A 	; alias for timer interval register

  OS_VDCR_ADDR	.UCONST xFE0C	; video display control register
  OS_MCR_ADDR	.UCONST xFFEE	; machine control register
  OS_VIDEO_NUM_COLS .UCONST #128
  OS_VIDEO_NUM_ROWS .UCONST #124


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; OS DATA MEMORY RESERVATIONS ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xA000
OS_GLOBALS_MEM	.BLKW x1000
;;;  LFSR value used by lfsr code


LFSR .FILL 0x0001




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; OS VIDEO MEMORY RESERVATION ;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.DATA
.ADDR xC000
OS_VIDEO_MEM .BLKW x3E00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;   OS & TRAP IMPLEMENTATIONS BEGIN HERE   ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CODE
.ADDR x8200
.FALIGN
  ;; first job of OS is to return PennSim to x0000 & downgrade privledge
  CONST R7, #0   ; R7 = 0
  RTI            ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - none
;;; Outputs          - R0 = ASCII character from ASCII keyboard

.CODE
TRAP_GETC
    LC R0, OS_KBSR_ADDR  ; R0 = address of keyboard status reg
    LDR R0, R0, #0       ; R0 = value of keyboard status reg
    BRzp TRAP_GETC       ; if R0[15]=1, data is waiting!
                             ; else, loop and check again...

    ; reaching here, means data is waiting in keyboard data reg

    LC R0, OS_KBDR_ADDR  ; R0 = address of keyboard data reg
    LDR R0, R0, #0       ; R0 = value of keyboard data reg
    RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTC   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a single character out to ASCII display
;;; Inputs           - R0 = ASCII character to write to ASCII display
;;; Outputs          - none

.CODE
TRAP_PUTC
  LC R1, OS_ADSR_ADDR 	; R1 = address of display status reg
  LDR R1, R1, #0    	; R1 = value of display status reg
  BRzp TRAP_PUTC    	; if R1[15]=1, display is ready to write!
		    	    ; else, loop and check again...

  ; reaching here, means console is ready to display next char

  LC R1, OS_ADDR_ADDR 	; R1 = address of display data reg
  STR R0, R1, #0    	; R1 = value of keyboard data reg (R0)
  RTI			; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a string of characters from the ASCII keyboard
;;; Inputs           - R0 = Address to place characters from keyboard
;;; Outputs          - R1 = Length of the string 

.CODE
TRAP_GETS

			     ; reusing code from TRAP_GETC
  LC R2, OS_KBSR_ADDR  				            ; R2 = address of keyboard status reg
  LDR R2, R2, #0       				            ; R2 = value of keyboard status reg
  BRzp TRAP_GETS       				            ; if R2[15]=1, data is waiting!
                          			          ; else, loop and check again... 

			     ; reusing code from TRAP_GETC
  LC R2, OS_KBDR_ADDR  				            ; R2 = address of keyboard data reg
  LDR R2, R2, #0       				            ; R2 = value of keyboard data reg


  CMP R0, R5           			              ; sets  NZP (R0 - R5) R0 - x2000
  BRnz RETURN_FROM_TRAP_GETS              ; if R0 - x2000 is negative or zero then we're outside of or at lower bound for data memory 

  
  CMP R0, R6                              ; sets  NZP (R0 - R6) R0 - x7FFF
  BRzp RETURN_FROM_TRAP_GETS              ;  if R0 - x7FFF is positive or zero then we're outside of or at upper bound for data memory
                       				
    
  CMPI R2, #10         			              ; sets  NZP (R4 - #10)
  BRz END_OF_USER_INPUT                   ; check if user has hit [ENTER]
                        
  
  STR R2, R0, #0                          ; put the value in R2 into the data memory addr stored in R0 
  ADD R0, R0, #1                          ; Go to next address, R0 = R0 + 1
  ADD R1, R1, #1                          ; increase count for string length
  BRnzp TRAP_GETS
  
  END_OF_USER_INPUT

  CONST R3, x0                            ; setting R3 to [NULL] = 0 in ASCII 
  STR R3, R0, #0       			              ; stores NULL in R0 to break out of loop 
                           
 
  RETURN_FROM_TRAP_GETS
  RTI

;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_PUTS   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Put a string of characters out to ASCII display
;;; Inputs           - R0 = Address for first character
;;; Outputs          - none



.CODE
TRAP_PUTS
   
  
  CMP R0, R5                     ; sets  NZP (R0 - R6) R0 - x2000
  BRn RETURN_FROM_TRAP_PUTS      ; if R0 - x2000 is negative then we're outside of lower bound for data memory 
 
  	
  CMP R0, R6                    ; Set NZP (R0 - x7FFF) 
  BRp RETURN_FROM_TRAP_PUTS     ;  if R0 - x7FFF is positive then we're outside of upper bound for data memory
	
  
  LDR R2, R0, #0                ; load the ASCII character from the address held in R0 into R2 for while-loop check 
  
  LOOP 
      CMPI R2, #0                ; we know at offset #0 we have the NULL character so we Set NZP (R0 - x0000)        
      BRz RETURN_FROM_TRAP_PUTS  ; If we dont have [NULL] in the current value of R0 loaded into R2, then we keep going 
                             
            
 			   ; resusing code from TRAP_PUTSC TRAP 

      LC R1, OS_ADSR_ADDR 	    ; R1 = address of display status reg
  	  LDR R1, R1, #0    	        ; R1 = value of display status reg
  	  BRzp TRAP_PUTS    	        ; if R1[15]=1, display is ready to write!
		    	                      ; else, loop and check again 	

			  ; resusing code from TRAP_PUTSC TRAP 

      LC R1, OS_ADDR_ADDR 	     ; R1 = address of display data reg
      STR R2, R1, #0       
      
      ADD R0, R0, #1             ; load the next ASCII character from data memory 
      LDR R2, R0, #0             ; Load it into R2 for loop checking 
      BRnzp LOOP


  RETURN_FROM_TRAP_PUTS
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function:
;;; Inputs           - R0 = time to wait in milliseconds
;;; Outputs          - none

.CODE
TRAP_TIMER
  LC R1, OS_TIR_ADDR 	; R1 = address of timer interval reg
  STR R0, R1, #0    	; Store R0 in timer interval register

COUNT
  LC R1, OS_TSR_ADDR  	; Save timer status register in R1
  LDR R1, R1, #0    	; Load the contents of TSR in R1
  BRzp COUNT    	; If R1[15]=1, timer has gone off!

  ; reaching this line means we've finished counting R0

  RTI       		; PC = R7 ; PSR[15]=0



;;;;;;;;;;;;;;;;;;;;;;;   TRAP_GETC_TIMER   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Get a single character from keyboard
;;; Inputs           - R0 = time to wait
;;; Outputs          - R0 = ASCII character from keyboard (or NULL)

.CODE
TRAP_GETC_TIMER

  ;;
  ;; TO DO: complete this trap
  ;;

  RTI                  ; PC = R7 ; PSR[15]=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_RESET_VMEM ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; In double-buffered video mode, resets the video display
;;; DO NOT MODIFY this trap, it's for future HWs
;;; Inputs - none
;;; Outputs - none
.CODE	
TRAP_RESET_VMEM
  LC R4, OS_VDCR_ADDR
  CONST R5, #1
  STR R5, R4, #0
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TRAP_BLT_VMEM ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRAP_BLT_VMEM - In double-buffered video mode, copies the contents
;;; of video memory to the video display.
;;; DO NOT MODIFY this trap, it's for future HWs
;;; Inputs - none
;;; Outputs - none
.CODE
TRAP_BLT_VMEM
  LC R4, OS_VDCR_ADDR
  CONST R5, #2
  STR R5, R4, #0
  RTI


;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_PIXEL   ;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: Draw point on video display
;;; Inputs           - R0 = row to draw on (y)
;;;                  - R1 = column to draw on (x)
;;;                  - R2 = color to draw with
;;; Outputs          - none

.CODE
TRAP_DRAW_PIXEL
  LEA R3, OS_VIDEO_MEM       ; R3=start address of video memory
  LC  R4, OS_VIDEO_NUM_COLS  ; R4=number of columns

  CMPIU R1, #0    	         ; Checks if x coord from input is > 0
  BRn END_PIXEL
  CMPIU R1, #127    	     ; Checks if x coord from input is < 127
  BRp END_PIXEL
  CMPIU R0, #0    	         ; Checks if y coord from input is > 0
  BRn END_PIXEL
  CMPIU R0, #123    	     ; Checks if y coord from input is < 123
  BRp END_PIXEL

  MUL R4, R0, R4      	     ; R4= (row * NUM_COLS)
  ADD R4, R4, R1      	     ; R4= (row * NUM_COLS) + col
  ADD R4, R4, R3      	     ; Add the offset to the start of video memory
  STR R2, R4, #0      	     ; Fill in the pixel with color from user (R2)

END_PIXEL
  RTI       		         ; PC = R7 ; PSR[15]=0
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_RECT   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: draws rectangle at specified location and size 
;;; Inputs:
;R0 = rectangle X-coordinate
;R1 = rectangle Y-coordinate 
;R2 = rectangle lenth
;R3 = rectangle width
;R4 = rectangle color
;R5 = holds OS_VIDEO_MEM (offset to the start)
;R6 = pointer to location of pixel placement  (already has stuff loaded)

;;; Outputs:
;Rectangle representation in black display screen

.CODE
TRAP_DRAW_RECT
                  ;using code from TRAP_DRAW_PIXEL trap

  CMPIU R0, #0    	      ; Checks if x coord from input is > 0
  BRn END_DRAW
  CMPIU R0, #127    	      ; Checks if x coord from input is < 127
  BRp END_DRAW
  CMPIU R1, #0    	      ; Checks if y coord from input is > 0
  BRn END_DRAW
  CMPIU R1, #123    	      ; Checks if y coord from input is < 123
  BRp END_DRAW
 

LOOP_ROWS
  CMPIU R1, #123              ; Checks if y coord from input is < 123 
  BRzp END_LOOP_ROWS          
  LDR R0, R5, #0              

LOOP_COLUMNS
  CMPU R0, R2                ; compares x-coordinate with length 
  BRzp END_LOOP_COLUMNS

  LEA R5, OS_VIDEO_MEM
  LC  R6, OS_VIDEO_NUM_COLS  ; R6=number of columns
 
  				
			;using code from TRAP_DRAW_PIXEL trap
  MUL R6, R1, R6             ; R6= (row * NUM_COLS)
  ADD R6, R6, R0             ; R6= (row * NUM_COLS) + col
  ADD R6, R6, R5             ; Add the offset to the start of video memory
  STR R4, R6, #0             ; Fill in the pixel with color from user (R4)
  ADD R0, R0, #1             ; increment coordinate 
  JMP LOOP_COLUMNS
  
END_LOOP_COLUMNS  
  ADD R1, R1, #1             ; go to next y-coordinate 
  JMP LOOP_ROWS   
END_LOOP_ROWS 
  
END_DRAW
RTI



;;;;;;;;;;;;;;;;;;;;;;;;;;;   TRAP_DRAW_SPRITE   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Function: EDIT ME!
;;; Inputs    EDIT ME!
;;; Outputs   EDIT ME!

.CODE
TRAP_DRAW_SPRITE

  ;;
  ;; TO DO: complete this trap
  ;;

  RTI


;; TO DO: Add TRAPs in HW

