;PROGRAM NAME: RAMtest
;DATE: Unknown  BY: Unknown
;COMMENT: Here is a memory test program for the 1802. 
;It is a bit match type test of the 32K RAM. 
;It doesn't check for cross-talk between the memory address lines. 
;This version does check for data line cross-talk. 
;The LED's will display the current memory page being tested. 
;If there is an error detected the "Q" LED will come on and stay on. 
;If an error is detected the address that caused the error is stored at memory location 0002h (high order) and 0003h (low order).  
;If there is no errors detected the data LED's will count from "00" to "7F" (01111111) and stop.
;http://www.astrorat.com/cosmacelf/1802programs.html
;
;Dan WA6PZB - 12/8/2019 - Modified to test all 64K bytes
;

;REGISTERS USED:
;R0 Program counter.
;R2 Points for memory location where RAM being tested pointer is.
;R5 Pointer for value for displayed memory address.
;RC Pointer to RAM being tested.
;RD.0 Current pattern being tested.

	incl "1802reg.asm"

	cpu 1802
	ORG 00H

START:	BR TEST	; Branch to start of RAM test program.
	DB 0	; High order test address pointer.
	DB 0	; Low order test address pointer.
	DB 0	; High order address to display.
TEST:	GHI R0	; Use program counter to set high pointers.
	PHI R2
	PHI R5
	PHI RC
	LDI 02h	; R2 points at memory location where pointer is.
	PLO R2
	LDI 04h	; R5 points at current display memory.
	PLO R5
	LDI 42h	; RC points a RAM test beginning.
	PLO RC
	LDI 01h	; RD.0 is current test bit pattern.
	PLO RD
TESTL:	GHI RC	; Update display current test page.
	STR R5
	SEX R5
	OUT 4	; Display page.
	DEC R5	; Fix pointer after display.
	SEX RC
	GHI RC	; Update current RAM test location
	STR R2	; pointed to by R2.
	INC R2
	GLO RC
	STR R2
	DEC R2
	GLO RD
	STXD
	INC RC
	SD	; Test current RAM pattern.
	BZ NEXT	; Jump if current RAM passes.
	SEQ	; Error found turn on Q.
	BR $	; Stop.
NEXT:	GLO RD	; Change to next text pattern.
	SHL
	PLO RD
	BNZ TESTL	; Loop if still more test patterns.
	STR RC
	LDI 01h	; Reset test bit pattern.
	PLO RD
	INC RC	; Move to next page of RAM.
	GHI RC
	SDI	0FFh	; Last page? was 80h changes to 0FFh for full 64K
	BNZ TESTL	; If not do another page.
	BR START	; Repeat
	
	END
