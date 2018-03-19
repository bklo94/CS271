TITLE Project05     (project05.asm)

;Author: Brandon Lo
;Date:3/7/17
;CS271_400/Program #05
;Write and test a MASM program to perform the following tasks:
;1. Introduce the program.
;2. Get a user request in the range [min = 10 .. max = 200].
;3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements
;of an array.
;4. Display the list of integers before sorting, 10 numbers per line.
;5. Sort the list in descending order (i.e., largest first).
;6. Calculate and display the median value, rounded to the nearest integer.
;7. Display the sorted list, 10 numbers per line.

INCLUDE Irvine32.inc
;(insert constant definitions here)
   MIN            EQU  <10>
   MAX            EQU  <200>
   LO             EQU  <100>
   HI             EQU  <999>
   MAXCOL         EQU  <10>
.data
;(insert variable definition here)
   promptIntro    BYTE  "Sorting Random Integers            Programmed by Brandon Lo", 0
   promptIntro2   BYTE  "This program generates random numbers in the range [100...99],", 0
   promptIntro3   BYTE  "displays the original list, sorts the list, and calculates the", 0
   promptIntro4   BYTE  "median value. Finally, it displays the list sorted in descending order.", 0

   promptRange    BYTE  "How many numbers should be generated? [10 .. 200]: ",0
   promptStart    BYTE  "The unsorted random numbers:",0
   promptSort     BYTE  "The sorted list:",0
   promptMedian   BYTE  "The median is ",0
   period         BYTE  ".",0
   promptError    BYTE  "Invalid Input", 0

   array          DWORD MAX DUP(?)            ;array variable set at 200 because it is the max number of variables that we can input
   inputRange     DWORD ?
   currentCounter DWORD ?
   startBubble    DWORD 0

.code

main PROC
;(insert executable instructions here)
   call           Randomize
   ;pushes all the intro prompts into the stack to be used
   push			  OFFSET promptIntro4
   push			  OFFSET promptIntro3
   push			  OFFSET promptIntro2
   push			  OFFSET promptIntro
   call           introduction

   ;push the variable inputRange to be later returned
   push           OFFSET inputRange
   call           getData

   ;push the user inputRange onto the stack along with the variable array
   push			  inputRange
   push           OFFSET array
   call           fillArray

   ;displays the list
   push			  inputRange 
   push           OFFSET array 
   push			  OFFSET promptStart
   call           displayList

   ;sorts the list here since it is used to calculate the median next
   push			  inputRange
   push			  OFFSET array
   call			  sortList

   ;median is calculated based on the inputRange and chooses the location halfway
   push			  inputRange
   push			  OFFSET array
   call			  displayMedian

   ;prints the list that is already sorted
   push			  inputRange 
   push           OFFSET array 
   push			  OFFSET promptSort
   call           displayList
   exit  ;exit to operating system
main ENDP

;pushes the titles/prompts into the stack and then calls them in the introduction
introduction PROC
	  push		  ebp 
	  mov         ebp, esp
      mov         edx,[ebp+8]
      call        WriteString
      call        crlf
      mov         edx,[ebp+12]
      call        WriteString
      call        crlf
      mov         edx,[ebp+16]
      call        WriteString
      call        crlf
      mov         edx,[ebp+20]
      call        WriteString
      call        crlf
	  pop         ebp
	  ret         16
introduction ENDP

;gets the title/prompt from the stack and then gets user input, which is compared to the constants
getData PROC
      push        ebp
      mov         ebp,esp
      mov         ebx, [ebp+8]
   loopStart:
      mov         edx,OFFSET promptRange
      call        WriteString
      call        ReadInt
      cmp         eax,MIN
      jl          invalidInput
      cmp         eax,MAX
      jg          invalidInput
      mov         [ebx], eax
      call        crlf
      pop         ebp
      ret         4
   invalidInput:
      mov         edx,OFFSET promptError
      call        WriteString
      call        crlf
      jmp         loopStart
      call        crlf
      ret         4
getData ENDP

;array is filled up with random numbers(100-999) using RandomRange
fillArray PROC
      push        ebp
      mov         ebp, esp
      mov         esi, [ebp+8]
      mov         ecx, [ebp+12]
   ;code taken from lecture 
   loopRandom:
      mov         eax, HI
      sub         eax, LO
      inc         eax
	  call		  RandomRange
      add		  eax, LO
	  mov		  [esi],eax
      add         esi, 4
      loop        loopRandom
      pop         ebp
      ret         8
fillArray ENDP

;implementing a selection sort based off the pseudocode from the instructor
sortList PROC 
	  push		  ebp
	  mov		  ebp, esp
	  mov		  esi, [ebp+8]
	  mov		  ecx, [ebp+12]
	  dec		  ecx   
   ;for the for loop (len(stack) -1)  
   ;push out to save the ecx and then use it for the outer loop counter since we are doing selection sort
   ; i = k is being set here      
   selectionStart:
	  push		  ecx
	  mov         edx,esi 
   ;this loop is used to find the largest number
   ;if(array[j] > array[i], then skip since we are descending order
   ;then push all the items needed to be switched
   ;add esi, 4 advances, sub esi, 4 goes back 1
   L1: 
	  mov		  ebx, [esi+4]
	  mov		  eax, [edx]
	  cmp		  eax, ebx
	  jg	      L2
	  add		  esi, 4
	  push		  esi
	  push		  edx
	  push		  ecx
	  call		  exchange
	  sub		  esi, 4
   ;if there is no need to swap this function beings, where the inner loop continues to find the largest number,
   ;then the outer loop is done after
   ;sub needed to make room for the function
   L2: 
	  add		  esi, 4
	  loop		  L1
   ;outer loop 
	  pop		  ecx 
	  mov		  esi,edx
	  add		  esi, 4
	  loop	      selectionStart
   endSort:
      pop		  ebp
	  ret		  8
sortList ENDP

;swap function implemented which swaps the array[k] and array[i]
;the numbers are swapped and then reinserted into the array
;parts of this and the above function were based off of http://www.cs.virginia.edu/~evans/cs216/guides/x86.html
exchange PROC
	 push		  ebp
	 mov		  ebp, esp
	 pushad
	 ;the two values are gathered here
	 mov		  ebx, [ebp + 12]
	 mov		  eax, [ebp + 16]   
	 mov		  edx, eax
	 ;the amount of space that the variables take up
	 sub		  edx, ebx
	 ;variables are being saved
	 mov		  esi, ebx
	 mov		  ecx, [ebx]
	 mov		  eax, [eax]
	 mov		  [esi], eax
	 ;advance the pointer after inserting
	 add		  esi, edx
	 mov		  [esi], ecx
	 popad
	 pop		  ebp
	 ret		  12
exchange ENDP

;finds the median based on the inputRange
displayMedian PROC
	  push		  ebp
	  mov		  ebp,esp
	  mov		  esi,[ebp+8]
	  mov		  eax,[ebp+12]
	  mov		  edx, 0
	  mov		  ebx, 2
	  div		  ebx
	  cmp		  edx, 0
	  jz		  evenList
   ;the inputted range is calculated above to determine if it is even or not. If there is a 0 remainder, then it is even.
   ;odd median is calculated just by multiplying by 4 since the stack is in multiple of 4 (DWORD) and the moving to the halfway point
   oddList:
      mov		  ebx, 4
	  mul		  ebx
	  add		  esi,eax
	  mov		  eax, [esi]
	  jmp		  display
  ;even is being calcualted based on the average of the two numbers at the halfway point
   evenList:
      mov		  ebx, 4
	  mul		  ebx
	  add		  esi,eax
	  mov		  eax, [esi]
	  add		  eax, [esi-4]
	  mov		  edx, 0
	  mov		  ebx, 2
	  div		  ebx 
   ;median is being displayed here along with the number, prompt, and the period
   display:
	  mov		  edx,OFFSET promptMedian
	  call		  WriteString
	  call		  WriteDec
	  mov		  edx,OFFSET period
	  call		  WriteString
	  call		  crlf
	  call        crlf
	  pop         ebp
	  ret		  8
displayMedian ENDP

;displays the list that is in the array variable
displayList PROC
      push        ebp
      mov         ebp, esp
      mov         edx, [ebp+8]
	  call		  WriteString 
	  call		  crlf
	  mov		  esi, [ebp+12]
      mov         ecx, [ebp+16]
      mov         currentCounter, 0
   ;currentCounter is used to keep track of the numbers per row and is used to compare them
   ;tab character is used to create ordered columns
   displayLoop:
      mov         eax, [esi]
      call        WriteDec
      mov		  al, 9
      call		  WriteChar
      inc         currentCounter
      cmp         currentCounter, MAXCOL
      jl          continueLoop
      call        crlf
      mov         currentCounter, 0
   ;if there is no need to create a newline, then the loop continues
   continueLoop:
      add         esi, 4
      loop        displayLoop
      call        crlf
	  pop		  ebp
      ret         12
displayList ENDP

END main
