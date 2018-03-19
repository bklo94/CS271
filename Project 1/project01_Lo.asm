TITLE Project01     (project01_Lo.asm)

;Author: Brandon Lo
;Date:1/22/17
;CS271_400/Program #01
;Description Asks for 2 numbers and the sum, difference, quotient, product and remainder is shown.
;EC1: Uses jnz or nz. If its zero, it continues the program. If its not zero it stops.
;EC2: Use ja, if val2(stored as eax) is above val1, it jumps to the function NOTEQUAL
;EC3: Uses fld to make a float from val1, fmul to make something like (146/12 = 12.167 * 1000 = 12167)
;That number is subtracted in order to make the 3 decimal place quotient.

INCLUDE Irvine32.inc

.data
;(insert constant definitions here)
decPoint    BYTE ".", 0
modSign     BYTE " % ", 0
divSign     BYTE " / ", 0
prodSign    BYTE " x ", 0
minusSign   BYTE " - ", 0
plusSign    BYTE " + ", 0
equalSign   BYTE " = ", 0
projectOwn  BYTE "Project 01 by Brandon Lo" ,0
promptHelp  BYTE "Enter 2 numbers, and I'll show you the sum, difference, product, quotient and remainder.", 0
promptFir   BYTE "First number: ", 0
promptSec   BYTE "Second number: ", 0
promptEnd   BYTE "Impressed? Bye!", 0
promptAbv   BYTE "EC2:The Second number must be less than the first!", 0
promptZer   BYTE "The second number cannot be 0!", 0
promptRep   BYTE "EC1:Want to go again? Enter 0 for YES. Any other int for NO!: ", 0
promptFlo   BYTE "EC3:Floating Point EC3", 0
promptEC1	BYTE "**EC1: Repeat until the user chooses to quit.", 0
promptEC2	BYTE "**EC2: Validate the second number to be less than the first.", 0
promptEC3	BYTE "**EC3: Calculate and display the quotient as a floating-point number, rounded to the nearest .001.", 0
THOUSAND    DWORD 1000

;(insert variable definition here)
val1        DWORD ?
val2        DWORD ?
product     DWORD ?
difference  DWORD ?
total       DWORD ?
quotient 	DWORD ?
remainder	DWORD ?
temp        DWORD ?
floatStor   DWORD ?
floatLas    DWORD ?
floatAns	REAL4 ?

.code
main PROC
;beginning instruction prompt
   call Clrscr
   mov		edx,OFFSET projectOwn
   call WriteString
   call Crlf
   mov		edx,OFFSET promptEC1
   call WriteString
   call Crlf
   mov		edx,OFFSET promptEC2
   call WriteString
   call Crlf
   mov		edx,OFFSET promptEC3
   call WriteString
   call Crlf
   call Crlf
   mov		edx,OFFSET promptHelp
   call WriteString
   call Crlf

;promptStart is for the loop comaprison EC1
promptStart:
;displays prompt and reads input for the first int
   call Crlf
   mov		edx,OFFSET promptFir
   call WriteString
   call ReadInt
   mov		val1, eax

;displays prompt and reads input for the second int
   mov		edx,OFFSET promptSec
   call WriteString
   call ReadInt
   mov		val2, eax
   call Crlf

;Checks for division by 0
   cmp		eax, 0
   jz		ISZERO

;EC2 where it validates if second number is less than first
   cmp		eax, val1
   ja		NOTEQUAL

;Calculations
;Addition calculation
   mov		eax, val1
   add		eax, val2
   mov      total, eax

;Subtraction calculation
   mov		eax, val1
   sub		eax, val2
   mov      difference, eax

;Multiplication calculation
   mov		edx, val1
   mov		eax, val2
   mul		edx
   mov      product, eax

;Division/remainder calculation
   mov      edx, 0
   mov		eax, val1
   mov		ebx, val2
   idiv		val2
   mov      quotient, eax
   mov      remainder, edx

;EC3 floating point calculations
   fld		val1	       ;pushes floating point into ST(0)
   fdiv		val2   		 ;float division and pop
   fimul	THOUSAND	       ;convert integer and multiply
   frndint				    ;Rounds ST(0) to integer (1000 * float makes it round to 3rd decimal place)
   fist     floatStor	 ;stores integer in memory operand

   mov		eax, quotient
   mul		thousand
   mov		floatLas, eax
   mov		eax, floatStor
   sub		eax, floatLas   ;float part is actually created here
   mov		floatStor, eax

;Outputs
;Provides the additon string and answer. Answer is saved as total after val1 is put into eax, and the eax is added to from val2.
   mov      eax, val1
   call WriteDec
   mov		edx,OFFSET plusSign
   call WriteString
   mov      eax, val2
   call WriteDec
   mov		edx,OFFSET equalSign
   call WriteString
   mov      eax, total
   call WriteDec
   call Crlf

;Provides the difference string and answer/output. Answer is saved as difference after val1 is put into eax, and the eax is subtracted by val2.
   mov      eax, val1
   call WriteDec
   mov		edx,OFFSET minusSign
   call WriteString
   mov      eax, val2
   call WriteDec
   mov		edx,OFFSET equalSign
   call WriteString
   mov      eax, difference
   call WriteDec
   call Crlf

;Provides the product string and answer. Answer is saved as product after val1 is put into eax, and the eax is multiplied by val2.
   mov      eax, val1
   call WriteDec
   mov		edx,OFFSET prodSign
   call WriteString
   mov      eax, val2
   call WriteDec
   mov		edx,OFFSET equalSign
   call WriteString
   mov      eax, product
   call WriteDec
   call Crlf

;Provides the division string and answer. Saves edx as the remainder and eax as the answer that will display now.
   mov      eax, val1
   call WriteDec
   mov		edx,OFFSET divSign
   call WriteString
   mov      eax, val2
   call WriteDec
   mov		edx,OFFSET equalSign
   call WriteString
   mov      eax, quotient
   call WriteDec
   call Crlf

;Provides the remainder string and answer. Uses the remainder from the calculation of the answer of val1/val2, where eax is the result and remainder is in edx.
   mov      eax, val1
   call WriteDec
   mov		edx,OFFSET modSign
   call WriteString
   mov      eax, val2
   call WriteDec
   mov		edx,OFFSET equalSign
   call WriteString
   mov      eax, remainder
   call WriteDec
   call Crlf

;EC3: Floating Point EC3 string and answer. Output the prompt first then the calculation is stored.
   call Crlf
   mov		edx,OFFSET promptFlo
   call WriteString
   call Crlf
   mov      eax, val1
   call WriteDec
   mov		edx,OFFSET divSign
   call WriteString
   mov      eax, val2
   call WriteDec
   mov		edx,OFFSET equalSign
   call WriteString
   mov		eax, quotient
   call WriteDec
   mov		edx,OFFSET decPoint
   call WriteString
   mov		eax,floatStor
   call	WriteDec
   call Crlf
   call Crlf

;Goodbye Prompts
;EC1: displays prompt for the loopand reads input for the second int. Stops if 0 is not entered as an int.
   mov		edx,OFFSET promptRep
   call WriteString
   call ReadInt
   cmp		eax, 0
   jnz		STOP
   jz		   promptStart

;Exits the program loop if 0 is not entered
STOP:
   mov		edx,OFFSET promptEnd
   call WriteString
   call Crlf
   INVOKE ExitProcess, 0

;Runs the output string if val2 is larger than val1
NOTEQUAL:
   mov		edx,OFFSET promptAbv
   call WriteString
   call Crlf
   call Crlf
   mov		edx,OFFSET promptEnd
   call WriteString
   call Crlf
   call Crlf
   INVOKE ExitProcess, 0

;Edge case testing if 0 is entered.
ISZERO:
   mov		edx,OFFSET promptZer
   call WriteString
   call Crlf
   call Crlf
   mov		edx,OFFSET promptEnd
   call WriteString
   call Crlf
   call Crlf
   INVOKE ExitProcess, 0

   exit  ;exit to operating system
main ENDP

END main
