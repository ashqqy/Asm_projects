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
X	   equ 10
Y 	   equ 5

Main:
	mov AX, VIDEOSEG
	mov ES, AX

	mov AH, COLOR
	mov SI, FRAMESTYLE
	mov DI, SCREENLEN*Y+X*2

	call DrawFrame

	jmp Exit

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

frame 	db '101202303'

end 	Main				