;********************************************** 
;HW3
;Malin Andersson 
;3/13/2019
;Blink LED 
;********************************************** 
.include "ATxmega128A1Udef.inc"
.equ BIT0 = 0x01
.org 0x0			
	rjmp MAIN		
MAIN:
	ldi R16, BIT0
	sts PORTC_DIRSET, R16
	sts PORTA_DIRCLR, R16
	sts PORTC_OUT, R16
POLLING:
	lds R16, PORTA_IN
	andi r16, BIT0
	cpi r16, BIT0
	brne POLLING
	ldi r19, 0x01
	rcall DELAY_X_10MS
	sts PORTC_OUTTGL, R16
	rjmp POLLING
;****************************************** 
;This subroutine delays by x10 ms 
;******************************************
DELAY_X_10MS: 
	cpi r19, 0 ;5 passed in from LOOP 
	brne LOOP3 ;if not 0, go again 
	ret 
LOOP3: 
	rcall DELAY_10MS 
	dec r19 
	brne LOOP3 
	ret 
;****************************************** 
;This subroutine delays by 10 ms 
;****************************************** 
DELAY_10MS: 
	ldi r17, 0x16 ;outer loop @ 1B
LOOP1: 
	dec r17 
	brne START_COUNT 
	ret
START_COUNT: 
	;ldi r18, 0xFF ;inner loop @ FF 
	ldi r18, 0x02
LOOP2: 
	dec r18 
	brne LOOP2 
	rjmp LOOP1