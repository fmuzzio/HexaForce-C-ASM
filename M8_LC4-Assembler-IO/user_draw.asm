;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  file name   : user_draw.asm                            ;
;  author      : Francisco Muzzio
;  description : places x-coordinate, y-coordinate, length,;
;	           width, and color of rectangle on screen;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The following CODE will go into USER's Program Memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.DATA
.ADDR x4000
LOC_TO_DRAW

.CODE 

;;;initialize R5 for use 
LEA R5, LOC_TO_DRAW


;;red rectangle;;
.ADDR x0032   		;#50 for x-coordinate in hex of red rectangle
RED_RECT_X_COORDINATE
.ADDR x0005  	 	;#5 for y-coordinate in hex of red rectangle 
RED_RECT_Y_COORDINATE
.ADDR x000A   		;#10 for length in hex of red rectangle 
RED_RECT_LENGTH
.ADDR x0005   		;#5 for width in hex of red rectangle 
RED_RECT_WIDTH



;;green rectangle;; 
.ADDR x000A  		;#10 for x-coordinate in hex of green rectangle 
GREEN_RECT_X_COORDINATE
.ADDR x000A  		;#10 for y-coordinate in hex of green rectangle 
GREEN_RECT_Y_COORDINATE
.ADDR x0032  		;#50 for length in hex of green rectangle 
GREEN_RECT_LENGTH
.ADDR x0028  		;#40 for width in hex of green rectangle 
GREEN_RECT_WIDTH



;;yellow rectangle;;
.ADDR x0078  		;#120 for x-coordinate in hex of yellow rectangle
YELLOW_RECT_X_COORDINATE
.ADDR x0064  		;#100 for y-coordinate in hex of yellow rectangle
YELLOW_RECT_Y_COORDINATE
.ADDR x0018  		;#24 for length in hex of yellow rectangle
YELLOW_RECT_LENGTH
.ADDR x000A 		;#10 for width in hex of yellow rectangle
YELLOW_RECT_WIDTH


;pointing to red rectangle addresses in order to place on screen 
LEA R0, RED_RECT_X_COORDINATE
LEA R1, RED_RECT_Y_COORDINATE
LEA R2, RED_RECT_LENGTH
LEA R3, RED_RECT_WIDTH

CONST R4, x00
HICONST R4, x7C   	;x7C00 is hex value for red color 
TRAP x09  			; this calls "TRAP_DRAW_RECT" in os.asm

;pointing to green rectangle addresses in order to place on screen
LEA R0, GREEN_RECT_X_COORDINATE
LEA R1, GREEN_RECT_Y_COORDINATE
LEA R2, GREEN_RECT_LENGTH
LEA R3, GREEN_RECT_WIDTH

CONST R4, xE0
HICONST R4, x03  		;x03E0 is hex value for green color
TRAP x09

;pointing to yellow rectangle addresses in order to place on screen
LEA R0, YELLOW_RECT_X_COORDINATE
LEA R1, YELLOW_RECT_Y_COORDINATE
LEA R2, YELLOW_RECT_LENGTH
LEA R3, YELLOW_RECT_WIDTH

CONST R4, xE0
HICONST R4, xFF  		;xFFEO is hex value for yellow color
TRAP x09


END