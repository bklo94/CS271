TITLE Project06A     (project06A.asm)

;Author: Brandon Lo
;Date:3/19/17
;CS271_400/Program #06
;Write and test a MASM program to perform the following tasks:
;1. User�s numeric input must be validated the hard way: Read the user's input as a string, and convert the
;string to numeric form. If the user enters non-digits or the number is too large for 32-bit registers, an
;error message should be displayed and the number should be discarded.
;2. Conversion routines must appropriately use the lodsb and/or stosb operators.
;3. All procedure parameters must be passed on the system stack.
;4. Addresses of prompts, identifying strings, and other memory locations should be passed by address to
;the macros.
;5. Used registers must be saved and restored by the called procedures and macros
;6. The stack must be �cleaned up� by the called procedure.

INCLUDE Irvine32.inc
;Constants
;CHE used in order to take out the last comma from the loop
;Used ascii code minimum, ascii 0 is 30h http://www.asciicharstable.com/_site_media/ascii/ascii-chars-table-landscape.jpg
;max size of an unsigned int
CHE EQU  <1>
MIN	EQU  <0>
MAX	EQU <10>
LO	EQU <30h>
HI	EQU <39h>

;Macro to get the string using input as the input Buffer to load the keystroke into memory
getString MACRO	intro, input, count
	push			 edx
	push			 ecx
	push			 eax
	push			 ebx
	mov				 edx, OFFSET intro
	call			 WriteString
	mov				 edx, OFFSET input
	mov				 ecx, SIZEOF input
	call			 ReadString
	mov				 count, 00000000h
	mov				 count, eax
	pop				 ebx
	pop				 eax
	pop				 ecx
	pop				 edx
ENDM

;Simple macro to display a string depending on input
displayString MACRO stringInput
	push			 edx
	mov				 edx, OFFSET stringInput
	call			 WriteString
	pop				 edx
ENDM

.data
	;variables
	promptStart_1    BYTE  "PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",0
	promptStart_2    BYTE  "Written by: Brandon Lo",0
	promptStart_3    BYTE  "Please provide 10 unsigned decimal integers.",0
	promptStart_4    BYTE  "Each number needs to be small enough to fit inside a 32 bit register.",0
	promptStart_5    BYTE  "After you have finished inputting the raw numbers I will display a list",0
	promptStart_6    BYTE  "of the integers, their sum, and their average value.",0
	promptNumber     BYTE  ". Please enter an unsigned number: ",0
	promptNumber2    BYTE  ". Please try again: ",0
	promptError      BYTE  "ERROR: You did not enter an unsigned number or your number was too big.",0
	promptList       BYTE  "You entered the following numbers:",0
	promptSum        BYTE  "The sum of these numbers is: ",0
	promptEC1		 BYTE  "EC:Make a counter for user input", 0
	promptEC2		 BYTE  "EC:Prompts user to restart program", 0
	promptRestart	 BYTE  "Enter 0 if you want to restart testing the program: ", 0
	promptAvg        BYTE  "The average is: ",0
	promptBye        BYTE  "Thanks for playing!",0
	commas           BYTE  ", ",0

	array            DWORD MAX DUP(?)
	stringInput      DB 16 DUP(0)
	input            DWORD 10 DUP(0)
	count            DWORD ?
	counter			 DWORD 1

.code
;introduction which uses the macro to call the variables
introduction PROC
	call             crlf
	displayString	 promptStart_1
	call			 crlf
	displayString	 promptStart_2
	call			 crlf
	call			 crlf
	displayString	 promptStart_3
	call			 crlf
	displayString	 promptStart_4
	call			 crlf
	displayString	 promptStart_5
	call			 crlf
	displayString	 promptStart_6
	call			 crlf
	displayString	 promptEC1
	call			 crlf
	displayString	 promptEC2
	call			 crlf
	call			 CrLf
	ret
introduction ENDP

readVal PROC
	;here is where the list is loaded, with max number loaded into ecx
	;counter is reset here if the loop is restarted
	mov				  counter,0
    push              ebp
    mov               ebp,esp
    mov               ecx,MAX
    mov               edi,[ebp+16]
	jmp				  startLoop
	;Macro for the error
	;input is put into esi, then count, which is the numbers inputted put into ecx
	;eax is then cleared and ebx is set as the accumulator
startError:
	mov				  eax, counter
	call			  WriteDec
    getString promptNumber2, input, count
    push              ecx
    mov               esi,[ebp+12]
    mov               ecx,[ebp+8]
    mov               ecx,[ecx]
    cld
    mov               eax,00000000h
    mov               ebx,00000000h
	jmp               stringConvert
	;the non error loop is the same, except the paramter is different for the macro
startLoop:
    inc				  counter
	mov				  eax, counter
	call			  WriteDec
    getString promptNumber, input, count
    push              ecx
    mov               esi,[ebp+12]
    mov               ecx,[ebp+8]
    mov               ecx,[ecx]
    cld
    mov               eax,00000000h
    mov               ebx,00000000h
	;lodsb loads request into eax http://faydoc.tripod.com/cpu/lodsd.htm
	;2 cmp's to check if too low or too high
	;stosd puts eax into the array
stringConvert:
	lodsb
	cmp               eax,HI
    ja                invalidInput
    cmp               eax,LO
    jb                invalidInput
    sub               eax,LO
    push              eax
    mov               eax,ebx
    mov               ebx,MAX
    mul               ebx
    mov               ebx,eax
    pop               eax
    add               ebx,eax
    mov               eax,ebx
    mov               eax,00000000h
    loop              stringConvert
    mov               eax,ebx
	stosd
    add               esi,4
    pop               ecx
	cmp				  counter,10
    jne               startLoop
    jmp               endFunction
invalidInput:
    clc
    pop               ecx
    mov               edx,OFFSET promptError
    call              WriteString
    call              crlf
    jmp               startError
endFunction:
    pop               ebp
    ret               12
readVal ENDP
writeVal PROC
    push              ebp
    mov               ebp,esp
    mov               edi,[ebp+8]
    mov               ecx,MAX
;xor is used to count the number of digits, where bx stores the number of digits
startLoop:
    push              ecx
    mov               eax,[edi]
    mov               ecx,MAX
    xor               bx, bx
	;checks to see if eax is 0 or else there would be a division by 0 error.
	;lea loads the effective address into the string buffer http://faydoc.tripod.com/cpu/lea.htm
divideVal:
    xor               edx,edx
    div               ecx
    push              dx
    inc               bx
    cmp               eax,0
    jnz               divideVal
    mov               cx,bx
    lea               esi,stringInput
	;numbers are converted and written to the input buffer
	;CHE is here to take out the last comma in the function, since there are 9 commas in 10 numbers
nextVal:
    pop               ax
    add               ax, '0'
    mov               [esi], ax
    displayString stringInput
    loop              nextVal
    pop               ecx
	add               edi, 4
	cmp				  ecx, CHE
	je				  endLoop
    mov               edx, OFFSET commas
    call              WriteString
    mov               edx, 0
    mov               ebx, 0
    loop startLoop
endLoop:
	call			  crlf
    pop               ebp
    ret               8
writeVal ENDP

;displays the average using the list
displayAverage PROC
    push              ebp
    mov               ebp,esp
    mov               esi,[ebp+8]
    mov               eax,MAX
    mov               edx,0
    mov               ebx,0
    mov               ecx,eax
;finds the average by advancing throught the list and adding to ebx
findAverage:
    mov               eax,[esi]
    add               ebx,eax
    add               esi,4
    loop              findAverage
;stops the summing and the finds the average from the sum
endLoop:
    mov               edx,0
    mov               eax,ebx
    mov               edx,[ebp+12]
    call              WriteString
    call              WriteDec
    call              crlf
    mov               edx,0
    mov               ebx,MAX
    div               ebx
    mov               edx,[ebp+16]
    call              WriteString
    call              WriteDec
    call              crlf
endDisplayAverage:
    pop               ebp
    ret               12
displayAverage ENDP

;goodbyeFunction since I already used the name promptBye
;EC prompt for user loop input
goodbyeFunction PROC
	displayString	  promptRestart
	call			  ReadInt
	cmp				  eax, 0
	jz				  main
    push              ebp
    mov               ebp,esp
    mov               edx,[ebp+8]
	call              crlf
    call              WriteString
    call              crlf
    pop               ebp
    ret               4
goodbyeFunction ENDP

;Main function 
main PROC
	call			  introduction
	push			  OFFSET array
	push			  OFFSET input
	push			  OFFSET count
	call              readVal
	call              crlf
	push              edx
    mov               edx, OFFSET promptList
    call              WriteString
	call			  crlf
    pop               edx
    push              OFFSET stringInput
    push              OFFSET array
    call              writeVal
	push              OFFSET promptAvg
    push              OFFSET promptSum
    push              OFFSET array
    call              displayAverage
    push              OFFSET promptBye
    call              goodbyeFunction
    exit
main ENDP

exit
END main
