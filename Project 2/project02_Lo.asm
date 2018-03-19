TITLE Project02     (project02.asm)

;Author: Brandon Lo
;Date:1/29/17
;CS271_400/Program #02
;Description: Displays the Fibonnaci Sequence
;EC1: Display numbers in aligned columns


INCLUDE Irvine32.inc

;constants
UPPERBOUND EQU <46>
LOWERBOUND EQU <1>
MAXCOLUMNS EQU <5>


.data
promptProj        BYTE  "Fibonacci Numbers",0
promptIntro       BYTE  "Programmed by Brandon Lo", 0
promptName	      BYTE	"What's your inputName?", 0
promptString      BYTE  "Hello, ", 0
promptInstruct    BYTE  "Enter the number of Fibonacci terms to be displayed", 0
promptInstruct2   BYTE  "Give the number as an integer in the ranges [1 .. 46].", 0
promptTerms       BYTE  "How many Fibonacci terms do you want? ", 0
promptErrRange    BYTE  "Out of ranges. Enter a number in [1 .. 46]", 0
promptEnd         BYTE  "Results certified by Brandon Lo.", 0
promptBye         BYTE  "Goodbye, ",0
promptEC1	      BYTE "**EC1: Aligned columns using tabs.", 0

;(insert variable definition here)

ranges            DWORD ?
inputName         BYTE  33 DUP (0)
fibonacciterm1    DWORD 1
fibonacciterm2    DWORD 0
currentFib        DWORD 0
currentColumns    DWORD 0
currentRow	      DWORD 1

.code
main PROC
;(insert executable instructions here)
;Display title and inputName (Introduction)
   call Clrscr
   mov   edx,OFFSET promptProj
   call WriteString
   call Crlf
   mov   edx,OFFSET promptIntro
   call WriteString
   call Crlf
   mov   edx,OFFSET promptEC1
   call WriteString
   call Crlf
   call Crlf

;Instructions prompt
   mov   edx, OFFSET promptName
   call WriteString
   mov   edx, OFFSET inputName
   mov   ecx, 32
   call ReadString
   mov   edx, OFFSET promptString
   call WriteString
   mov   edx, OFFSET inputName
   call WriteString
   call Crlf


;Fibonacci prompt for user ranges. (userInstruction)
   mov   edx, OFFSET promptInstruct
   call WriteString
   call Crlf
   mov   edx, OFFSET promptInstruct2
   call WriteString
   call Crlf

;Asks for user input and is checked (getUserData), ecx is also set here to use with the looping
boundsInput:
   mov   edx, OFFSET promptTerms
   call WriteString
   call ReadInt
   mov   ranges,eax
   mov	 ecx, ranges
   call Crlf

;Bounds are checked here after input
checkBounds:
   cmp   ranges, LOWERBOUND
   jb  boundsError
   cmp   ranges, UPPERBOUND
   ja  boundsError
   jmp calcLoop

;String output if out of bounds
boundsError:
   mov   edx, OFFSET promptErrRange
   call WriteString
   call Crlf
   jmp boundsInput

;Calculation of the Fibonnaci numbers(displayFibs)

;After the 1st term is entered, the fibonnaci sequence is calculated here
calcLoop:
	mov		eax, fibonacciterm1
	mov		edx, fibonacciterm2
	mov		fibonacciterm1, edx
	add		fibonacciterm1, eax
	mov		currentFib, eax
	call WriteDec
	cmp		currentRow, 7
	ja	alignLarge

;EC1: Aligns the colmns with tabs based on size of the number called
alignColumn:
	mov		currentFib, eax
	mov     al, 9
    call WriteChar
	call WriteChar 
	jmp checkLoop

alignLarge:
	mov		currentFib, eax
	mov     al, 9
    call WriteChar
	jmp checkLoop

;Post test loop element where it stops if condition is reached
checkLoop:
	cmp		ecx, 1
	je		goodbye
	loop swap

;Used for EC1
newLine:
	call Crlf
	mov		currentColumns, 0
	inc		currentRow
	jmp calcLoop

;used for the fibonnaci calculation, so the new sum is set as fibonnacci2
swap:
	mov		eax, currentFib
	mov		fibonacciterm2, eax
	inc		currentColumns
	cmp		currentColumns, MAXCOLUMNS
	jne	calcLoop
	je  newLine

;Farewell/Goodbye prompt
goodbye:
   call Crlf
   call Crlf
   mov   edx, OFFSET promptEnd
   call WriteString
   call Crlf
   mov   edx, OFFSET promptBye
   call WriteString
   mov   edx, OFFSET inputName
   call WriteString
   call Crlf
   call Crlf

   exit  ;exit to operating system
main ENDP
;(insert additional procedures here)

END main
