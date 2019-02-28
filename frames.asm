;**********************************************
;Project 2
;Part 4
;Malin Andersson
;2/14/2019

;Reads inputs from SPST switches on port A,
;and buttons on port F to output LED animations 
;on port C. 
;**********************************************
.include "ATxmega128A1Udef.inc"
	.equ BIT0 = 0x01
	.equ BIT2 = 0x02
	.equ BIT3 = 0x04
	.equ BIT4 = 0x08
	.equ EDIT = 0x00 
	.equ PLAY = 0xFF

.dseg       
.org  0x2000					;frame storing
START:

.cseg
.org 0x000						;Program strt
rjmp MAIN


MAIN:   
	ldi r19, EDIT				;start in EDIT mode

    ldi YL, low(START)			;animation start
    ldi YH, high(START)

	ldi r16, 0xFF				;low part of counter
	sts TCC0_PER, r16
	ldi r16, 0x00				;high part of counter
	sts TCC0_PER+1, r16

	ldi r16, 0x07			;slowest prescalar
	sts TCC0_CTRLA, r16

    ldi r16, 0XFF
    sts PORTC_DIR, r16			;set port d as outputs
    sts PORTA_DIRCLR, r16		;set port a as inputs SPST switches

    ldi r16, 0X00
    sts PORTF_DIR, r16			;set port f as inputs S1 & S2 buttons

    ldi r16, BIT0				;sense edge
    sts PORTF_PIN2CTRL, r16		
    sts PORTF_PIN3CTRL, r16	

    ldi r16, BIT3				;interrupt masking
    sts PORTF_INT0MASK, r16			
    ldi r16, BIT4
    sts PORTF_INT1MASK, r16



	;******************************************
	;Looping through updating LEDs according 
	;to switches/ buttons
	;******************************************
LOOP: 
   cpi r19, EDIT
   breq READ       

   cp   XL, YL				;if not equal, read memory
   cpc  XH, YH				;else reset x
   brne RD_MEM   
   ldi XL, low(START)		;animation start 
   ldi XH, high(START)     	
RD_MEM:     
	ld r21, X+				;read memory
	rjmp UPDATE_LED
READ:          
    lds r21, PORTA_IN		;read SPST switches
UPDATE_LED:  
   sts PORTC_OUT, r21		;update LEDS
   lds r20, PORTF_INTFLAGS	;read buttons

   cpi r20, BIT0            ;check button 1
   brne CHK_ANIMATE         ;if pressed, store
   rcall STORE				;else check button 2  
CHK_ANIMATE:					
   cpi r20, BIT2            ;check button 2
   brne CONT				;if pressed, continue
   rcall ANIMATE		    ;animation time! 
CONT:						;continue
   ldi r16, 0x05            ;5x10ms
   rcall DELAY_X_10MS
   rjmp LOOP
	;******************************************
	;This subroutine stores inputs from SPST
	;******************************************
STORE:   
	st Y+, r21					;store switch input
    ldi r22, BIT0				;clear flag
    sts PORTF_INTFLAGS, r22
    ret         
	;******************************************
	;This subroutine plays data stored
	;******************************************
ANIMATE:   
	com r19                 
    ldi XL, low(START)			;animaion start
    ldi XH, high(START) ;
	ldi r16, 0x10				;20Hz LED on
    rcall DELAY_X_10MS         
    ldi r22, BIT2             
    sts PORTF_INTFLAGS, r22		;clear button
    ret                    
	;******************************************
	;This subroutine delays by x10 ms
	;******************************************
DELAY_X_10MS:
	cpi r16, 0				;5 passed in from LOOP
	brne LOOP3				;if not 0, go again
	ret
LOOP3:
	rcall DELAY_10MS
	dec r16
	brne LOOP3
	ret
	;******************************************
	;This subroutine delays by 10 ms
	;******************************************
DELAY_10MS: 
	ldi r17, 0x1B			;outer loop @ 1B

LOOP1:  
	dec r17					
    brne START_COUNT		
    ret

START_COUNT: 
	ldi r18, 0xFF			;inner loop @ FF
LOOP2:  
	dec r18  
    brne LOOP2 
    rjmp LOOP1