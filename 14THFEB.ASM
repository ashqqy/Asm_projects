.model tiny
.code
org 100h

;-------------------------------
	
VIDEOSEG   equ 0b800h
CMDPARAMS  equ 0082h
SCREENLEN  equ 80*2
FRAMESTYLE equ offset frame
COLOR 	   equ 10001100b	; Red (blink)
FRAMELEN   equ 20
FRAMEHIGH  equ 5
X	   equ 20
Y 	   equ 10

Main:		call ClearScreen
		
		mov AX, VIDEOSEG
		mov ES, AX
		
		mov BX, CMDPARAMS
		call GetCmdArgs

		mov SI, FRAMESTYLE
		mov DI, SCREENLEN*Y+X*2
		call DrawFrame

		jmp Exit

;-------------------------------
;Entry: None
;Destr: AH, DX
;-------------------------------
ClearScreen	proc

		mov AH, 09h
		mov DX, offset clear_screen_arr	
		int 21h
		ret
		endp

;-------------------------------
;Entry:
;Destr:
;-------------------------------
GetDecCmd	proc
		ret
		endp

;-------------------------------
;Reads hex number before space (1 or 2 digit) from cmd params
; (in the beginning spaces are not skipped)
;Entry: BX - cmdparams (0082h)
;Destr: CL - read (return hex)
;-------------------------------	

AsciiToHex	proc
		
		cmp CL, '9'

		jbe IfDigitBody
		ja  IfLetterBody

IfDigitBody: 	sub CL, '0'
		ret

IfLetterBody:   sub CL, 'a' - 10
		ret
		
		endp

;-------------------------------

GetHexCmd	proc
		
		mov CX, [BX]		; read two character at once

		inc BX			; skip space if no 1 symb

		cmp CL, ' '
		je GetHexEnd
		call AsciiToHex

		inc BX			; skip space after 1 symb
		xchg CL, CH

		cmp CL, ' '
		je GetHexEnd 
		call AsciiToHex

		inc BX			; skip space after 2 symb

		shl CH, 4		; CH = CH * f + CL
		or CH, CL
		
GetHexEnd:	ret
		endp	

;-------------------------------
;Entry:	BX - cmdparams (0082h),
;Destr: CX - for GetDec/Hex,
;	AH - color 
;	DL - frame len,
;	DH - frame high,
;-------------------------------
GetCmdArgs	proc

		xor DX, DX		; DX = 0
		xor AX, AX			

		call GetHexCmd
		mov DL, CH		; DL = frame lenght

		call GetHexCmd
		mov DH, CH		; DH = frame high

		call GetHexCmd
		mov AH, CH		; AH = color

		ret
		endp

;-------------------------------
;Entry: AH - color,
;	DI - coords,
;	ES - videoseg (0b800h),
;	SI - framestyle array ptr,
; 
;Destr: AL - symbol, 
;	CX - counter & line lenght
;-------------------------------
DrawLine 	proc

	lodsb			; al = ds:[si++]
	stosw			; es:[di] = ax, di+=2

	mov CX, FRAMELEN - 2
	lodsb
	rep stosw
	
	lodsb
	stosw

	ret
		endp
;-------------------------------
;Entry:	AH - color,
;	DI - coords (screenlen * y + x * 2),
;	ES - videoseg (0b800h),
;	SI - framestyle array ptr
;
;Destr: CX - counter,
;	AL - symbol
;-------------------------------
DrawFrame	proc
	
	call DrawLine
	sub DI, FRAMELEN * 2
	add DI, SCREENLEN
	
	mov CX, FRAMEHIGH - 2
StartFrameBody:
	cmp CX, 0	
	je EndFrameBody
		
	push CX
	call DrawLine
	pop CX
	dec CX

	sub SI, 3

	sub DI, FRAMELEN * 2
	add DI, SCREENLEN

	jmp StartFrameBody
EndFrameBody:
	
	add SI, 3
	call DrawLine

	ret
		endp

;-------------------------------

Exit:	mov AX, 4c00h
	int 21h

;-------------------------------
clear_screen_arr db 80*26 dup (' '), '$'
frame 	    	 db '101202303'

end 	Main				