;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_string.asm                            ;
;  author      : Francisco Muzzio
;  description : read string from the keyboard,       ;
;	             then echo them back to the ASCII display ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.DATA                 ; DATA memory assembly directive

.ADDR x2000
 USER_DATA_LOWER
  
.ADDR x7FFF
USER_DATA_UPPER


.ADDR x4000           ; where to start in DATA memory

global_array           ; label address x4000
.FILL x49              ; #73 offset from label address for ASCII equivalent of "I" 
.FILL x20              ; #32 offset from label address for ASCII equivalent of "[SPACE]"  
.FILL x6C             ; #108 offset from label address for ASCII equivalent of "l" 
.FILL X6F             ; #111 offset from label address for ASCII equivalent of "o"  
.FILL x76             ; #118 offset from label address for ASCII equivalent of "v"  
.FILL x65             ; #101  offset from label address for ASCII equivalent of "e"
.FILL x20              ; #32 offset from label address for ASCII equivalent of "[SPACE]"  
.FILL x43              ; #67 offset from label address for ASCII equivalent of "C"  
.FILL x49              ; #73 offset from label address for ASCII equivalent of "I"  
.FILL x54              ; #84 offset from label address for ASCII equivalent of "T"  
.FILL x20              ; #32 offset from label address for ASCII equivalent of "[SPACE]"  
.FILL x35              ; #53 offset from label address for ASCII equivalent of "5"  
.FILL x39              ; #57 offset from label address for ASCII equivalent of "9"  
.FILL x33              ; #51 offset from label address for ASCII equivalent of "3"
.FILL x00               ; #0 offset from label address for ASCII equivalent of "[NULL]"  


.CODE
.ADDR x0000

LEA R0, global_array  	   ; load starting address of DATA to R0

LEA R5, USER_DATA_LOWER    ; store lower limit of user data address in R6 to be used in TRAP
LEA R6, USER_DATA_UPPER    ; store lower limit of user data address in R2 to be used in TRAP 

TRAP x03                   ; calling  "TRAP_PUTS" TRAP 
END