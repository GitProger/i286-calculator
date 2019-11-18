.model tiny
.286
.code
     ORG   100H       ; start at offset of 256
program:              ;
     PUSH  CS         ; we are in DOS, no segments
     POP   DS         ; dataseg = codeseg
     CALL  main       ; start main program
     RET              ; return to OS
; ==== functions =====;
 isdigit:  ; arg - AL ; res - CL
     XOR   CL, CL     ; default result - 0
     CMP   AL, '0'    ; if it is less than '0'
     JB    @lblfalse  ; it is not digit
     CMP   AL, '9'    ; if it is more than '9'
     JA    @lblfalse  ; it is not digit
     MOV   CL, 1      ; we checked it
  @lblfalse:
     RET

 getchar:             ; result - AL
     MOV   AH, 01H    ; function number
     INT   21H        ; DOS interrupt
     RET
 cls:                 ; void
     MOV   AX, 3      ; function number
     INT   10H        ; BIOS interrupt
     RET
 putchar:             ; argument - DL
     MOV   AH, 02H    ; function number
     INT   21H        ; DOS interrupt
     RET
     
 printnumber:         ; argument - AX
     MOV   BX, 10     ; base of decimal system
     XOR   CX, CX     ; count of digits
     XOR   DX, DX     ; for DIV
   @cicle:            ;
     DIV   BX         ; dividion
     PUSH  DX         ; save remainder
     XOR   DX, DX     ; for DIV
     INC   CX         ; digits++
     CMP   AX, 0      ; if we havent 0
     JNZ   @cicle     ; dividide
   @cicle2:           ; so printing:
     POP   DX         ; restore last digit
     ADD   DL, '0'    ; convert to char
     CALL  putchar    ; print it
     LOOP  @cicle2    ; if --digits != 0 print anaway
     RET
     
 readnumber:          ; result - AX
     MOV   BX, 10     ; base of decimal system
     XOR   DX, DX     ; for MUL
     XOR   AX, AX     ; default
     XOR   CH, CH     ; CH = 0, we will add CX to AX
   @read:             ; 
     PUSH  AX         ; save last value (AX uses in calling functions)
     CALL  getchar    ; read char
     CALL  isdigit    ; isdigit ?
     CMP   CL, 0      ; if char isnt digit
     JZ    @stop      ; exit
     MOV   CL, AL     ; load char to buffer
     SUB   CL, '0'    ; convert char to digit  
     POP   AX         ; restore last value
     MUL   BX         ; to multiply
     XOR   DX, DX     ; for MUL
     ADD   AX, CX     ; add digit
     JMP   @read      ; read next char
   @stop:             ;
     POP   AX         ; restore last value
     RET
; ==== entry point ==== ;
 main:
     CALL  cls            ; clear screen
     MOV   AH, 9          ; 9th function
     LEA   DX, msg        ; string address
     INT   21H            ; DOS interrupt
   @mainLoop:             ; 
     CALL  readnumber     ; integer 1 in AX
     PUSH  AX             ; save got number 1
     CALL  getchar        ; now symbol is in AL
     PUSH  AX             ; save symbol
     CALL  getchar        ; ignoring 'Enter'
     CALL  readnumber     ; integer in AX **
     POP   DX             ; restore symbol
     POP   BX             ; get number 1, number 2 is in AX **
     XCHG  AX, BX         ; swap 1st and 2nd numbers 
     CMP   DL, '+'        ; if symbol is '+' 
     JE    @plus          ; then go to plus
     CMP   DL, '-'        ; if symbol is '-'
     JE    @minus         ; go to minus
     CMP   DL, '*'        ; if symbol is '*'
     JE    @multi         ; go to multi
     CMP   DL, '/'        ; if symbol is '/'
     JE    @dividide      ; go to division
     CMP   DL, 27         ; if symbol is 'Esc'
     JE    @exitLoop      ; exit program
     JMP   @mainLoop      ; if unrecognized symbol then start anaway
   @plus:                 ;
     ADD   AX, BX         ; AX = AX +BX
     JMP   @print         ; go to printing result
   @minus:                ;
     SUB   AX, BX         ; AX = AX - BX
     JMP   @print         ; go to printing result
   @multi:                ;
     MUL   BX             ; AX = AX * BX
     JMP   @print         ; go to printing result
   @dividide:             ;
     CMP   BX, 0          ; if BX = 0
     JE    @mainLoop      ; start anaway
     XOR   DX, DX         ; DX = 0
     DIV   BX             ; AX = AX / BX   
     CMP   DX, 0          ; if exists remainder
     JE    @print         ;
     PUSH  DX             ; save remainder
     MOV   flag, 1        ; set flag
   @print:                ;
     CALL  printnumber    ; print result

     CMP   flag, 1        ; if was reminder
     JNE   @printnext     ; (if wasnt print enter)
     MOV   DL, ' '        ; write
     CALL  putchar        ; space
     POP   DX             ; rectore remainder
     MOV   AX, DX         ; write
     CALL  printnumber    ; remainder
     
   @printnext:
     MOV   flag, 0        ; no remainder
   
     MOV   AH, 9               ; \
     MOV   DX, offset msg + 30 ;  print enter
     INT   21H                 ; /
     JMP   @mainLoop      ; start anaway
   @exitLoop:
     RET
; ==================== ;
; ======= data ======= ;
  flag DB 0
  msg  DB "This is simple DOS calculator.",13,10,'$'
  
END program

