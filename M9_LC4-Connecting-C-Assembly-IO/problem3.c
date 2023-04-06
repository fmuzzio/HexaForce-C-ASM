/********************************************************
 * file name   : problem3.c                             *
 * author      : Francisco Muzzio
 * description : C program to get user input with LC4_GETC and
                   put out output until ENTER is clicked   *
 ********************************************************
*
*/

int main() {

	int enter_key = 0xA; //hex equivalent for [LINE_FEED] or ENTER

	char input; //initialize user keystroke 

	while(!(input == enter_key)){
		input = LC4_GETC ();  //get a character from the keyboard

		 LC4_PUTC (input);  //put that character out to the asci display
	}


	return (0) ;

}
