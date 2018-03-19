TITLE Project03     (project03.asm)

;Author: Brandon Lo
;Date:2/12/17
;CS271_400/Program #03
;Description: Sums up all the negative integers that are entered
;EC1: Calculate the lines during user input.
;EC2: Calculate and display the average as a floating-pointer number,rounded to the nearest .001.

INCLUDE Irvine32.inc

;constants
UPPERBOUND EQU <-1>
LOWERBOUND EQU <-100>

.data
promptProj        BYTE  "Welcome to the Integer Accumulator by Brandon Lo",0
promptName	      BYTE	"What's your Name?", 0
promptString      BYTE  "Hello, ", 0
promptInstruct2   BYTE  "Please enter numbers in [-100, -1].", 0
promptTerms       BYTE  "Enter a non-negative number when you are finished to see results.", 0
promptNumbers     BYTE  " Enter number:", 0
promptValidAns1   BYTE  "You entered ", 0
promptValidAns2   BYTE  " valid numbers.",0
promptSum         BYTE  "The sum of your valid numbers is ",0
promptAvg         BYTE  "The floating-point average is ",0
promptRAvg        BYTE  "The rounded average is ",0
promptBye         BYTE  "Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ",0
promptEdge        BYTE  "No valid numbers inputted",0
promptOver		  BYTE  "Enter a number than is less than or equal to 100", 0
promptEC1	      BYTE "**EC1: Calculate the lines during user input.", 0
promptEC2         BYTE "**EC2: Calculate and display the average as a floating-pointer number,rounded to the nearest .001.",0
decimal           BYTE ".",0
THOUSAND		  SDWORD 1000
NTHOUSAND		  SDWORD -1000

;(insert variable definition here)
checkNum	      DWORD 2
numLines          DWORD 1
validCheck        DWORD 0
inputName         BYTE  33 DUP (0)
currentNumber     DWORD ?
accumulator       DWORD 0
faccumulator      DWORD	?
quotient          DWORD 0
remainder         DWORD 0
floatStor		  DWORD ?
floatingPoint     REAL4 ?


.code
main PROC
;(insert executable instructions here)

;Display title and inputName (Introduction)
   call Clrscr
   mov   edx,OFFSET promptProj
   call WriteString
   call Crlf
   mov   edx,OFFSET promptEC1
   call WriteString
   call Crlf
   mov   edx,OFFSET promptEC2
   call WriteString
   call Crlf

;Get user inputName
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
   call Crlf

;Instructions for the aggregator
   mov   edx, OFFSET promptInstruct2
   call WriteString
   call Crlf
   mov   edx, OFFSET promptTerms
   call WriteString
   call Crlf

;part of code that asks for user input
input:
   mov   eax, numLines
   call WriteDec
   mov   edx, OFFSET decimal
   call WriteString
   mov   edx, OFFSET promptNumbers
   call WriteString
   call ReadInt
   mov   currentNumber, eax
   inc   numLines

;Checks input
   mov   eax, currentNumber
   mov   ebx, UPPERBOUND
   cmp   ebx,eax
   jl    edge
   mov   eax, currentNumber
   mov	 ebx, LOWERBOUND
   cmp   eax, ebx
   jl	 edgeOver

;sums up the number into accumulator
acc:
   mov   eax, accumulator
   add   eax, currentNumber
   mov   accumulator, eax
   jmp input

;ends the calculations and displays the results
endCalc:
   mov   edx,OFFSET promptValidAns1
   call WriteString
   dec	numLines
   dec  numLines
   mov   eax, numLines
   call WriteDec
   mov   edx, OFFSET promptValidAns2
   call WriteString
   call Crlf

   mov   edx, OFFSET promptSum
   call WriteString
   mov   eax, accumulator
   call WriteInt
   call Crlf

;EC2 floating point calculations (slightly modified from Assignment 1 for signed) (quotient also calculated here)
   mov		edx,0 
   mov      eax, accumulator
   CDQ
   mov		ebx, numLines
   idiv     ebx
   mov		quotient,eax
   mov		remainder,edx

   mov		eax,remainder
   mul		NTHOUSAND
   mov		remainder,eax

   mov		eax, numLines
   mul		THOUSAND
   mov		faccumulator,eax

   fld		remainder
   fdiv		faccumulator
   fimul	THOUSAND
   frndint
   fist		floatStor

;Rounded average is printed out here
   mov   edx, OFFSET promptRAvg
   call WriteString
   cmp	remainder,500
   ja FIVEHUNDRED

   cmp	remainder, 500
   jb  oneAvg

   mov	eax,floatStor
   call WriteInt
   call Crlf

;Floating Point Average is printed out here
float:
   mov   edx, OFFSET promptAvg
   call WriteString
   mov		eax, quotient
   call WriteInt
   mov		edx,OFFSET decimal
   call WriteString
   mov		eax, floatStor
   call WriteDec

;ending/goodbye prompt
goodbye:
   call Crlf
   mov   edx, OFFSET promptBye
   call WriteString
   mov   edx, OFFSET inputName
   call WriteString
   call Crlf
   call Crlf
   INVOKE ExitProcess, 0

;Used to round up if decimal is >= .5
FIVEHUNDRED:
   mov	eax,quotient
   sub	eax,1
   call WriteInt
   call Crlf
   jmp float

edgeOver:
   mov   edx, OFFSET promptOver
   call WriteString
   call Crlf
   dec numLines
   jmp input

;When there is only one number there is a special case of the average.
oneAvg:
   mov	eax,quotient
   call WriteInt
   call Crlf
   jmp float

;No valid numbers edge case output
edge:
	mov eax, 2
	cmp	numLines, eax
	je	noNumInput
	jmp endCalc

;Edge Case Output
noNumInput:
   mov   edx, OFFSET promptEdge
   call WriteString
   call Crlf
   jmp goodbye

;If you output a number lower than -100, one chance to reinput
input2:
   mov   eax, numLines
   call WriteDec
   mov   edx, OFFSET decimal
   call WriteString
   mov   edx, OFFSET promptNumbers
   call WriteString
   call ReadInt
   mov   currentNumber, eax
   inc   numLines
   mov   eax, currentNumber
   mov	 ebx, LOWERBOUND
   cmp   eax, ebx
   jl	 endCalc
   jmp acc

   exit  ;exit to operating system
main ENDP
;(insert additional procedures here)

END main
