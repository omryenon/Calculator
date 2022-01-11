section	.data			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string
	octprint     db `%d\0`      ; backquotes for C-escapes
	argcstr     db `%d\n\0`      ; backquotes for C-escapes
	argvstr     db `%s\n\0`      ; backquotes for C-escapes
	error_less     db `Error: Insufficient Number of Arguments on Stack\n\0`
	error_enough     db `Error: Operand Stack Overflow\n\0`  
	calc	db `calc: \0`
	operandStackPointer: dd 0
	operandStackIndex: dd 0
	currLinkPtr: dd 0
	operandStackCounter: dd 0
	numberOfOp: dd 0
	carry: dd 0
	bufferPtr: dd 0
	temp: dd 0
	numOfElements: dd 0
	check: dd 0

section .bss			; we define (global) uninitialized variables in .bss section
	an: resb 80		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
    buffer_length: resb 80
	buffer: resb 80

section .text
	align 16
	global main

	extern printf
	extern fprintf 
	extern fflush
	extern malloc 
	extern calloc 
	extern free 
	; extern gets 
	extern getchar 
	extern fgets 
	extern stdout
	extern stdin
	extern stderr  

%macro printErrorLess 0
	pushad
	push error_less
	call printf
	add esp,4
	popad
%endmacro

%macro printErroEnough 0
	pushad
	push error_enough
	call printf
	add esp,4
	popad
%endmacro

%macro decToOct 1
	mov ebx,%1
	mov edx,0
	mov eax,ebx
	
	.func1loop:
	inc edx
    mov ecx,ebx
    shl ecx,29
    shr ecx,29

    shr ebx,3
    cmp ebx,0
    ja .func1loop
	
    jmp .func2start

	.func2start:
	mov ebx, eax

	inc edx
	mov dword[currLinkPtr], edx
	
	push edx
	call malloc
	test eax, eax         ; check if the malloc failed
	jz   ending 
	add esp, 4

	mov edx, dword[currLinkPtr]
	mov dword[bufferPtr],eax
	

	mov ecx, dword[bufferPtr]
	dec edx
	mov byte[ecx+edx],0
	dec edx
	

	
	.func2loop:
	mov eax,ebx
    shl eax,29
    shr eax,29



	
	add al,'0'





	mov byte[ecx+edx],al
	; mov bl,byte[ecx]
	dec edx
    shr ebx,3
    cmp ebx,0

    ja .func2loop
    jmp .fin

	.fin:
	
	; push dword[bufferPtr]
	; push argvstr
	; call printf
	; add esp,8

	mov ecx, dword[bufferPtr]

%endmacro



%macro printFunc 0
	mov ebx,0		  
	mov bl, byte [buffer]
	cmp ebx, 'p'
	jne end1

	add dword[numberOfOp], 1
	
	mov eax, dword[operandStackIndex]
	cmp eax , dword[operandStackPointer] 
	jne pValid
	

pNoValues:
	printErrorLess
	jmp mainLoop

pValid:
	sub dword[operandStackIndex], 4 ; getting the pointer of the top element of the stack
	mov ecx, dword[operandStackIndex]	
	mov edx, dword[ecx]		;edx contains the pointer to the first element of the linked list
	
loop3:
	inc dword[currLinkPtr]		;list curr ptr is the counter of number of elements
	; printErrorLess
	mov ecx, dword[edx+1]		;ecx have the ptr to the next value
	; printErrorLess
	cmp ecx, 0		;check if the pointer is 0
	; printErrorLess
	je endd			; if so, we are in the end of the list and we continue
	mov edx, ecx	; if not, we are saving on edx the pointer
	; printErrorLess
	jmp loop3	

endd:
	inc dword[currLinkPtr]	; adding a space to null ptr.

	mov eax, dword[currLinkPtr]              ; creating a buffer with size of number of elements for printing
	push eax
	call malloc
	test eax, eax         ; check if the malloc failed
	jz   ending 
	add esp, 4

	mov [bufferPtr],eax

	

	mov ecx, dword[operandStackIndex]
	mov edx, dword[ecx]
	sub dword[currLinkPtr], 1

	

	mov eax, dword[currLinkPtr]
	mov ecx, dword[bufferPtr]
	mov byte[ecx+eax],0


	; pushad
	; push dword[bufferPtr]
	; push argcstr
	; call printf
	; add esp,8
	; popad

	

	

loop4:
	sub dword[currLinkPtr], 1
	mov ebx,0
	mov bl,byte[edx]
	add bl,'0'
	; pushad
	; push ebx
	; push argcstr
	; call printf
	; add esp,8
	; popad


	mov eax, dword[currLinkPtr]
	mov ecx, dword[bufferPtr]


	mov byte[ecx+eax],bl	;bl containes the digit that we enter
	mov edx, dword[edx+1]
	

	cmp eax,0
	je enddd
	jmp loop4

enddd:
	push dword[bufferPtr]
	push argvstr
	call printf
	add esp,8
	mov ebx, dword[operandStackIndex]
	mov ecx, dword[ebx]
	mov ecx, 0
	; add dword[numberOfOp], 1
	sub dword[operandStackCounter],1

	mov ecx, dword[bufferPtr]
	push ecx
	call free
	add esp,4

	mov ecx, dword[operandStackIndex]
	freelink ecx

	mov ecx,0
	
	jmp mainLoop
end1:
%endmacro

%macro plusFunc 0
	mov ebx,0		  
	mov bl, byte [buffer]
	cmp ebx, '+'
	jne end2

	add dword[numberOfOp], 1

	mov eax, dword[operandStackIndex]
	cmp eax , dword[operandStackPointer] 
	jne plcheck2
	

plNoValues:
	printErrorLess
	jmp mainLoop

plcheck2:
	sub eax, 4
	cmp eax , dword[operandStackPointer]
	je plNoValues
	
plValid:

	mov dword[currLinkPtr],0

	mov eax, dword[operandStackIndex]	; saving the OPcurrIndex value
	mov ecx, dword[eax-4]	; ecx have link-2
	mov edx, dword[eax-8]	; edx have link-1

plusLoop:
	mov eax, dword[carry]
	mov dword[carry], 0
	mov ebx,0
	mov bl,byte[edx]
	mov bh, byte[ecx]
	add bl,bh
	movzx ebx,bl
	add ebx, eax

	cmp ebx, 8
	jl lessThen8
	sub ebx, 8
	mov dword[carry], 1

lessThen8:
	mov byte[edx], bl

	mov ebx, dword[edx+1]	;taking the pointer to the next link in link-1
	
	mov eax, dword[ecx+1]	;taking the pointer to the next link in link-2
	cmp ebx, 0
	je link1Finish
	cmp eax, 0
	je onlylink2Finish
	mov edx, ebx
	mov ecx, eax 
	jmp plusLoop

link1Finish:
	cmp eax, 0	; if link-2 also finish
	jne onlylink1Finish
	cmp dword[carry],0	;and if carry finish
	je Done

carryForNewLink:

	
	push edx
	push 5
	call malloc
	add esp, 4
	pop edx
	
	mov [edx+1], eax	;putting in the last link the pointer to the new link
	
	mov edx, dword[edx+1]	; edx now contaning the the adress to the new link
	
	mov ebx,1				; adding the carry to the new link
	mov byte[edx], bl

	mov ebx, edx
	mov dword[edx+1],0
	jmp Done


onlylink1Finish:
	mov dword[edx+1], eax
	mov dword[ecx+1], 0	

link2OnlyLoop:
	mov ecx, eax

	mov eax, dword[carry]
	mov dword[carry], 0
	mov ebx,0
	mov bl,byte[ecx]
	movzx ebx,bl

	add ebx, eax

	
	cmp ebx, 8
	jl ADone

ADone:
	mov byte[ecx], bl
	jmp Done
	
	sub ebx, 8
	mov dword[carry], 1
	mov byte[ecx], bl
	mov eax, dword[ecx+1]


	cmp eax, 0
	jne link2OnlyLoop
	mov edx, ecx
	jmp	carryForNewLink

onlylink2Finish:

	mov edx, ebx
	mov eax, dword[carry]
	mov dword[carry], 0
	mov ebx,0
	mov bl,byte[edx]
	movzx ebx,bl
	add ebx, eax

	cmp ebx, 8
	jl BDone

BDone:
	mov byte[edx], bl
	jmp Done
	
	sub ebx, 8
	mov dword[carry], 1
	mov byte[edx], bl
	mov ebx, dword[edx+1]
	cmp ebx, 0
	jne onlylink2Finish
	jmp	carryForNewLink

Done:
	sub dword[operandStackIndex], 4
	mov dword[carry], 0
	sub dword[operandStackCounter],1
	; add dword[numberOfOp], 1

	mov ecx, dword[operandStackIndex]
	freelink ecx

	mov ecx,0

	jmp mainLoop
end2:
%endmacro

%macro andFunc 0
	mov ebx,0		  
	mov bl, byte [buffer]
	cmp ebx, '&'
	jne end3


	add dword[numberOfOp], 1

	mov eax, dword[operandStackIndex]
	cmp eax , dword[operandStackPointer] 
	jne acheck2
	

aNoValues:
	printErrorLess
	jmp mainLoop

acheck2:
	sub eax, 4
	cmp eax , dword[operandStackPointer]
	je aNoValues

aValid:
	
	mov eax, dword[operandStackIndex]	; saving the OPcurrIndex value
	mov ecx, dword[eax-4]	; ecx have link-2
	mov edx, dword[eax-8]	; edx have link-1

nplusLoop:

	mov ebx,0
	mov bl,byte[edx]
	mov bh, byte[ecx]
	and bl,bh
	movzx ebx,bl

	mov byte[edx], bl

	mov ebx, dword[edx+1]	;taking the pointer to the next link in link-1
	
	mov eax, dword[ecx+1]	;taking the pointer to the next link in link-2

	cmp eax, 0
	je newfinish1loop
	cmp ebx, 0
	je newfinish2
	mov edx, ebx
	mov ecx, eax 
	jmp nplusLoop
	
newfinish1loop:
	cmp ebx, 0
	je newfinish2


	mov ebx, dword[edx+1]	;taking the pointer to the next link in link-1

	
	mov ecx, edx
	inc ecx
	pushad
	freelink ecx
	popad


	mov dword[edx+1], 0

newfinish2:
	sub dword[operandStackIndex], 4
	dec dword[operandStackCounter]
	; add dword[numberOfOp], 1

	mov ecx, dword[operandStackIndex]
	freelink ecx

	jmp mainLoop

end3:
%endmacro

%macro numFunc 0
	mov ebx,0		  
	mov bl, byte [buffer]
	cmp ebx, 'n'
	jne nend

	add dword[numberOfOp], 1

	mov eax, dword[operandStackIndex]
	cmp eax , dword[operandStackPointer] 
	jne npValid
	

nNoValues:
	printErrorLess
	jmp mainLoop

npValid:
	mov dword[currLinkPtr],0
	mov ebx, 0
	mov eax, dword[operandStackIndex]	; saving the OPcurrIndex value
	mov edx, dword[eax-4]	; edx have the first link

nLoop:
	mov ecx, dword[edx+1]	;taking the pointer to the next link

	cmp ecx, 0
	je MSBNumber
	mov edx, ecx
	add ebx, 3
	jmp nLoop

MSBNumber:
	mov ecx, 0
	mov eax,0
	mov al,byte[edx]

	cmp eax, 3
	jle check1Bit
	add ebx, 3
	jmp nFinalLoop
check1Bit:
	cmp eax, 1
	jne is2Bits
	add ebx, 1
	jmp	nFinalLoop
is2Bits:
	add ebx, 2
nFinalLoop:
	inc ecx
	sub ebx, 8
	cmp ebx, 0
	jle nFinish
	jmp nFinalLoop
nFinish:

	; pushad
	; push ecx
	; push argcstr
	; call printf
	; add esp, 8
	; popad

	decToOct ecx
	
;///////////////////////////////////////////////
	mov edx, 0
	mov dword[currLinkPtr], 0 ;reset the ptr to the curr link in the list
looptest:
	mov eax, 5
	push edx	;have the number of values
	push eax; push amount of bytes malloc should allocate    
	call malloc
	add esp, 4
	pop edx	;edx is the counter of the linklist
	mov ebx,0
	mov edi, eax ;edi now have the adress of the 5byte block

	; pushad
	; push eax
	; push argcstr
	; call printf
	; add esp,8
	; popad
	
	
	; ///// adding the curr digit to the curr linked
	mov ecx, dword[bufferPtr]
	mov bl, byte [ecx+edx] ; here we go char by char in the fgets buffer
	; printErroEnough
	cmp ebx, 0		;checking if its the char \n
	je insertNew2	; if so, we ending the loop	
	
	sub bl,'0' ; if not, we sub 48 from the value to get the actual number

	mov byte [eax], bl	; eax now containing the balue
	mov ecx, dword[currLinkPtr]	; ecx now containing the ptr to the curr linked of the list - start with 0
	
	
	mov dword [edi+1], ecx	; the curr link now have the adress to the next link
	inc edx
	mov dword [currLinkPtr],eax ; the pointr to the link

; ;print the pointer:
; 	push edx
; 	push ecx
; 	push argcstr
; 	call printf
; 	add esp, 8
; 	pop edx

	jmp looptest
	
insertNew2:

	

	pushad
	push eax
	call free
	add esp,4
	popad

	pushad
	push dword[bufferPtr]
	call free
	add esp,4
	popad


	sub dword[operandStackIndex], 4

	mov ecx, dword[operandStackIndex]
	freelink ecx

	mov edx,dword[currLinkPtr]	;
	; inc dword[operandStackCounter]	; inc the number of elements in the stack
	mov eax, dword[operandStackIndex]
	mov dword[eax], edx 
	add dword[operandStackIndex], 4 ; inc the pointer of the next free index of the stack
	mov dword [currLinkPtr],0 ; the pointr to the link
	; add dword[numberOfOp], 1
; ;////////////////////////////////////
; 	mov edx, eax 				; our string
; atoi2:
; 	xor eax, eax 				; zero a "result so far"
; .top2:
; 	movzx ecx, byte [edx] 		; get a character
; 	inc edx 					; ready for next one
; 	cmp ecx, '0' 				; pValid?
; 	jb .done2
; 	cmp ecx, '9'
; 	ja .done2
; 	sub ecx, '0'				; "convert" character to number
; 	imul eax, 10 				; multiply "result so far" by 8
; 	add eax, ecx 				; add in current digit
; 	jmp .top2 					; until done
; .done2:

; 	pushad
; 	push eax
; 	push argcstr
; 	call printf
; 	add esp,8
; 	popad

; 	sub dword[operandStackIndex], 4
; 	sub dword[operandStackCounter],1
; 	add dword[numberOfOp], 1

; ;///////////////////////////////////////////////

	jmp mainLoop
nend:
%endmacro

%macro dupFunc 0
	mov ebx,0		  
	mov bl, byte [buffer]
	cmp ebx, 'd'
	jne end4

	add dword[numberOfOp], 1

	mov eax, dword[operandStackIndex]
	cmp eax , dword[operandStackPointer] 
	jne checknum2
	

dNoValues:
	printErrorLess
	jmp mainLoop

checknum2:
	mov eax, dword[operandStackCounter]
	cmp eax, dword[numOfElements]
	jne dValid 
	printErroEnough
	jmp mainLoop

dValid:

	;////getting the top element
	mov eax, dword[operandStackIndex]    
	mov ecx, dword[eax-4] ; ecx is the pointer to the first number
	mov ebx,0
	mov bl, byte[ecx]

	pushad
	push 5
	call malloc
	add esp, 4
	mov edi , dword[operandStackIndex]
	mov [edi], eax  ;/// insert the new first link to the opStack
	mov edi,0
	mov edi, eax
	mov dword[bufferPtr], eax                 ;/// edi now have the adress of the 5byte block
	mov byte[edi], bl                 ;/// first link has its new "copied" value
	mov dword[temp],edi
	popad

	mov edi,dword[temp]

DUPLICATING:
	cmp dword[ecx+1],0
	je finishDuplicating
	mov ecx, dword[ecx+1]    ;/// advance the copied LL
	mov bl, byte[ecx]
	pushad
	push 5           
	call malloc              ;/// malloc the next link
	add esp, 4
	mov [edi+1], eax    ;/// linking between previous to the new link
	popad
	mov edi, dword [edi+1]   ;/// advance the new "ANDING" LL
	mov byte[edi], bl
	jmp DUPLICATING

finishDuplicating:	
	mov[edi+1],dword 0 ;///adding 0 to the last link
	add dword[operandStackIndex], 4
	inc dword[operandStackCounter]
	; add dword[numberOfOp], 1
	mov dword [currLinkPtr],0 ; the pointr to the link
	jmp mainLoop

end4:
%endmacro
%macro quitFunc 0
	mov ebx,0		  
	mov bl, byte [buffer]
	cmp ebx, 'q'
	jne end5

	mov ecx,dword[numberOfOp] 

	; pushad
	; push ecx
	; push argcstr
	; call printf
	; add esp, 8
	; popad

	decToOct ecx

	push ecx
	push argvstr
	call printf
	add esp,8

	
trysomeloop:
	mov edx,dword[operandStackPointer]

	; pushad
	; push edx
	; push dword[operandStackPointer]
	; call printf
	; add esp, 8
	; popad

	; pushad
	; push edx
	; push dword[operandStackIndex]
	; call printf
	; add esp, 8
	; popad
	
	cmp edx, dword[operandStackIndex]
	je con1
	; printErrorLess

	sub dword[operandStackIndex], 4
	mov ebx, dword[operandStackIndex]
	freelink ebx
	jmp trysomeloop
	

con1:
	pushad
	push dword[operandStackPointer]
	call free
	add esp,4
	popad

	pushad
	push dword[bufferPtr]
	call free
	add esp,4
	popad

	; \\\\\cleaning the buffer of fgets
; 	mov eax,0
; label3:
; 	mov dword[buffer+eax*4],0
; 	cmp eax, 19
; 	je ending
; 	inc eax
; 	jmp label3

	jmp ending

end5:
%endmacro

%macro freelink 1
	mov edx, dword[%1]		;edx contains the pointer to the first element of the linked list
	.loop6:
	; printErrorLess

	; pushad
	; push edx
	; push argcstr
	; call printf
	; add esp, 8
	; popad

	; pushad
	; push dword[toDel2]
	; push argcstr
	; call printf
	; add esp, 8
	; popad

	; printErrorLess
	mov ecx, dword[edx+1]		;ecx have the ptr to the next value
	; printErrorLess
	; pushad
	; push ecx
	; push argcstr
	; call printf
	; add esp, 8
	; popad

	; printErrorLess
	cmp ecx, 0		;check if the pointer is 0
	; printErrorLess
	je .freeit			; if so, we are in the end of the list and we continue
	
	pushad
	push edx
	call free
	add esp,4
	popad

	mov edx, ecx	; if not, we are saving on edx the pointer

	jmp .loop6
	; printErrorLess
	.freeit:

	
	
	pushad
	push edx
	call free
	add esp,4
	popad

	
%endmacro
main:
;making the operandStack:
	push ebp                    ; Prolog
    mov ebp, esp
    push ebx                    ; Callee saved registers
    push esi

;checking if there is a value on argv[1]:	
    mov eax, [ebp + 8]          ; argc
	cmp eax, 1
	mov eax, 5
	je	defult

    mov esi, [ebp + 12]         ; **argv
    mov eax, [esi + 4]    		; *argv[1]
	mov edx, eax 				; our string
atoi:
	xor eax, eax 				; zero a "result so far"
.top:
	movzx ecx, byte [edx] 		; get a character
	inc edx 					; ready for next one
	cmp ecx, '0' 				; pValid?
	jb .done
	cmp ecx, '9'
	ja .done
	sub ecx, '0'				; "convert" character to number
	imul eax, 8 				; multiply "result so far" by 8
	add eax, ecx 				; add in current digit
	jmp .top 					; until done
.done:

defult:
	mov dword[numOfElements], eax

	imul eax, 4
	push eax              ; push amount of bytes malloc should allocate    
	call malloc           ; call malloc
	test eax, eax         ; check if the malloc failed
	jz   ending        	 
	add esp,4             ; undo push

	mov [operandStackPointer],eax	  ; the pointr to the stack
	mov [operandStackIndex],eax		;the index in the stack

mainLoop:


; \\\\\cleaning the buffer of fgets
	mov eax,0
label2:
	mov dword[buffer+eax*4],0
	cmp eax, 19
	je continue
	inc eax
	jmp label2


continue:
	pushad
	push calc
	call printf
	add esp,4
	popad

	pushad
	push dword [stdin]
    push buffer_length
    push buffer           ; 3 pushes gets the stack back to 16B-alignment
    call fgets
    add esp, 12
	popad
	
	; printErrorLess

	mov edx,0

	printFunc 
	plusFunc
	dupFunc
	andFunc
	numFunc
	quitFunc

insertFunc:
	mov edx, dword[operandStackCounter]
	cmp edx, dword[numOfElements]
	jne stackAreFree 
	printErroEnough
	jmp mainLoop


stackAreFree:
	mov edx,0
	mov dword[currLinkPtr], 0 ;reset the ptr to the curr link in the list
putInputLoop:
	
	; /////	 creating a new malloc for the linked list
	mov eax, 5
	push edx	;have the number of values
	push eax; push amount of bytes malloc should allocate    
	call malloc
	add esp, 4
	pop edx	;edx is the counter of the linklist
	mov ebx,0
	mov edi, eax ;edi now have the adress of the 5byte block
	
	
	; ///// adding the curr digit to the curr linked
	
	mov bl, byte [buffer+edx] ; here we go char by char in the fgets buffer
	cmp ebx, 10		;checking if its the char \n

	je insertNew	; if so, we ending the loop	
	
	sub bl,'0' ; if not, we sub 48 from the value to get the actual number

	mov byte [eax], bl	; eax now containing the balue
	mov ecx, dword[currLinkPtr]	; ecx now containing the ptr to the curr linked of the list - start with 0
	
	
	mov dword [edi+1], ecx	; the curr link now have the adress to the next link
	inc edx
	mov dword [currLinkPtr],eax ; the pointr to the link

; ;print the pointer:
; 	push edx
; 	push ecx
; 	push argcstr
; 	call printf
; 	add esp, 8
; 	pop edx

	jmp putInputLoop
	
insertNew:

	pushad
	push eax
	call free
	add esp,4
	popad


	mov edx,dword[currLinkPtr]	;
	inc dword[operandStackCounter]	; inc the number of elements in the stack
	mov eax, dword[operandStackIndex]
	mov dword[eax], edx 
	add dword[operandStackIndex], 4 ; inc the pointer of the next free index of the stack
	mov dword [currLinkPtr],0 ; the pointr to the link
	; add dword[numberOfOp], 1

	; ------------------------------------------

jmp mainLoop

	


ending:

    pop esi                     ; Epilog
    pop ebx
    leave
    ret
