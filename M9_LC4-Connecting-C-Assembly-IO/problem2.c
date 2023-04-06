/********************************************************
 * file name   : problem2.c                             *
 * author      : Thomas Farmer
 * description : C program to call LC4-Assembly TRAP_PUTC
 *               the TRAP is called through the wrapper 
 *               LC4_PUTC() (located in lc4_stdio.asm)   *
 ********************************************************
*
*/

int main() {

	char c = 'A' ;		/* ASCII A = x41 in hex, #65 in dec. */
	
	// could also use: int c = x41; would work the same way

	LC4_PUTC (c) ;

	return (0) ;

}
