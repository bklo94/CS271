TITLE Project04     (project04.asm)

;Author: Brandon Lo
;Date:2/19/17
;CS271_400/Program #04
;Description: First, the user is instructed to enter the number of
;composites to be displayed, and is prompted to enter an integer in the range [1 .. 400]. The user
;enters a number, n, and the program verifies that 1 ≤ n ≤ 400. If n is out of range, the user is re-
;prompted until s/he enters a value in the specified range. The program then calculates and displays
;all of the composite numbers up to and including the n th composite. The results should be displayed
;10 composites per line with at least 3 spaces between the numbers.
;EC1: Column ouput aligned.

INCLUDE Irvine32.inc

;constants
UPPERBOUND EQU <400>
LOWERBOUND EQU <1>
MAXCOLUMNS EQU <10>

.data
promptProj        BYTE  "Composite Numbers Programmed by Brandon Lo",0
promptInstruct2   BYTE  "Enter the number of composite numbers you would like to see.", 0
promptTerms       BYTE  "I'll accept orders for up to 400 composites.", 0
promptNumbers     BYTE  "Enter the number of composites to display [1 .. 400]:", 0
promptError       BYTE  "Out of range. Try again", 0
promptBye         BYTE  "Results certified by Brandon Lo. Goodbye.",0
promptEC1	      BYTE  "**EC1: Align the output columns.", 0

;(insert variable definition here)
inputRange        DWORD ?
counter           DWORD ?
quotient          DWORD ?
remainder		  DWORD ?
currentComp       DWORD ?
temp              DWORD 3

.code
;introduction prompts
introduction PROC
    mov			 edx, OFFSET promptProj
	call		 WriteString
	call		 Crlf
	call		 Crlf
	mov			 edx, OFFSET promptInstruct2
	call		 WriteString
	call		 Crlf
	mov			 edx, OFFSET promptTerms
	call		 WriteString
	call		 Crlf
	mov			 edx, OFFSET promptEC1
	call		 WriteString
	call		 Crlf
	call		 Crlf
	ret
introduction ENDP

;user data input/data
getUserData PROC
   mov			 edx, OFFSET promptNumbers
   call			 WriteString
   call			 ReadInt
   mov			 inputRange, eax
   call			 validate
   ret
getUserData ENDP

;sub procedure called validate which validates if the user input is within the boundsInput else it calls get UserData again
validate PROC
   cmp			 eax, LOWERBOUND
   jl			 boundsError
   cmp			 eax, UPPERBOUND
   jg			 boundsError
   ret

boundsError:
	mov			 edx, OFFSET promptError
	call		 WriteString
	call		 Crlf
	call		 getUserData
	ret
validate ENDP

;showComposites procedure which ouputs the composites. Uses tabs to align the columns.
;counter to check for max columns
showComposites PROC
	mov			 ecx, inputRange
	call		 Crlf

check:
   cmp			 counter, MAXCOLUMNS
   je			 newLine

showComp:
   call			 isComposite
   mov			 eax, temp
   call			 WriteDec
   mov			 al, 9
   call			 WriteChar
   inc			 counter
   loop			 check
   ret ;exit to quit the function when the loop ends

newLine:
	mov			 counter, 0
	call		 Crlf
	jge			 showComp
showComposites ENDP

;check to see if it is a composite number or not. Divides by 2 to see if it is divisible and checks remainder
;the number is incremented and checked here (calculation and validation here)
;https://en.wikipedia.org/wiki/Primality_test, checks to see if remainder whe divided by 3 or 2 is 0
; since temp is a global variable it can keep increasing
isComposite PROC
startCalc:
	mov			 edx, 0
	mov			 eax,temp
	mov			 ebx, 2
	div			 ebx
	mov			 quotient, eax
	inc			 temp

;here is where the remainder is checked, if it is dividible by 1, then it is prime, so it advances one more
checkCalc:
	mov			 edx, 0
	mov			 eax, temp
    mov			 currentComp, eax ;global variable set which is used in showComposites is set here.
	div			 quotient
	mov			 remainder, edx
	dec			 quotient
	cmp			 remainder, 0
	je			 endCalc
	cmp			 quotient, 1 ;check to see composite is dividing by 1
	jg			 checkCalc
    je			 startCalc

;return to end the procedure
endCalc:
	ret
isComposite ENDP

;farewell prompt
farewell PROC
	call		 Crlf
	call		 Crlf
	mov			 edx, OFFSET promptBye
	call		 WriteString
	call		 Crlf
	call		 Crlf
	ret
farewell ENDP

;main code start
main PROC
; (insert executable instructions here)
	call		 introduction
	call		 getUserData
	call		 showComposites
	call		 farewell
	exit
main ENDP
; (insert additional procedures here)
END main
