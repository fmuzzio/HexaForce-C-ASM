;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_string2.asm                            ;
;  author      : Francisco Muzzio
;  description : read characters from the keyboard,       ;
;	             then echo them back to the ASCII display ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 .DATA 
 .ADDR x2020
 USER_DATA_START
  
 .ADDR x2000
 USER_DATA_LOWER
  
 .ADDR x7FFF
 USER_DATA_UPPER

 
 .CODE
 .ADDR x0000

 LEA R5, USER_DATA_LOWER    ; store lower limit of user data address in R6 to be used in TRAP
 LEA R6, USER_DATA_UPPER    ; store lower limit of user data address in R2 to be used in TRAP 

  
 
 
 LEA R0, USER_DATA_START ; R0 = x2020; data memory addr
 TRAP x02              ; this calls "TRAP_GETS" in os.asm
 
 ADD R2, R1, #0          ; R2 = R1


 CONST R0, x4C	       ; ASCII equivalent for "L"
 TRAP x01	             ; this calls "TRAP_PUTC" in os.asm

 CONST R0, x65	       ; ASCII equivalent for "e"
 TRAP x01	  
          
 CONST R0, x6E	       ; ASCII equivalent for "n"
 TRAP x01	          
 
 CONST R0, x67	       ; ASCII equivalent for "g"
 TRAP x01	           
 
 CONST R0, x74	       ; ASCII equivalent for "t"
 TRAP x01	           
 
 CONST R0, x68	       ; ASCII equivalent for "h"
 TRAP x01	           
 
 CONST R0, x20	       ; ASCII equivalent for "[SPACE]"
 TRAP x01	           

 CONST R0, x3D	       ; ASCII equivalent for "="
 TRAP x01	           

 CONST R0, x20	       ; ASCII equivalent for "[SPACE]"
 TRAP x01	           
 
 

 CONST R3, x30          ; value needed for conversion to decimal according to ASCII Table (x30 = 0 in ASCII)

 ADD R0, R2, #0         ; bring back string length count for upcoming conversion to ASCII
 ADD R0, R0, R3         ; convert to ASCII by adding hex value ASCII representation of decimal 0 
 TRAP x01	          

 CONST R0, x0A	     ; ASCII equivalent for "[LINE FEED]". Purpose to print out 
 TRAP x01	           


 LEA R0, USER_DATA_START ; bring back data memory address x2020 into R0

 TRAP x03              ; this calls "TRAP_PUTS" in os.asm


 END