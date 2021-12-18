;/**************************************************************************//**
; * @file     startup_LPC17xx.s
; * @brief    CMSIS Cortex-M3 Core Device Startup File for
; *           NXP LPC17xx Device Series
; * @version  V1.10
; * @date     06. April 2011
; *
; * @note
; * Copyright (C) 2009-2011 ARM Limited. All rights reserved.
; *
; * @par
; * ARM Limited (ARM) is supplying this software for use with Cortex-M
; * processor based microcontrollers.  This file can be freely distributed
; * within development tools that are supporting such ARM based processors.
; *
; * @par
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; ******************************************************************************/

; *------- <<< Use Configuration Wizard in Context Menu >>> ------------------

; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000200

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000000

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     MemManage_Handler         ; MPU Fault Handler
                DCD     BusFault_Handler          ; Bus Fault Handler
                DCD     UsageFault_Handler        ; Usage Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     DebugMon_Handler          ; Debug Monitor Handler
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     WDT_IRQHandler            ; 16: Watchdog Timer
                DCD     TIMER0_IRQHandler         ; 17: Timer0
                DCD     TIMER1_IRQHandler         ; 18: Timer1
                DCD     TIMER2_IRQHandler         ; 19: Timer2
                DCD     TIMER3_IRQHandler         ; 20: Timer3
                DCD     UART0_IRQHandler          ; 21: UART0
                DCD     UART1_IRQHandler          ; 22: UART1
                DCD     UART2_IRQHandler          ; 23: UART2
                DCD     UART3_IRQHandler          ; 24: UART3
                DCD     PWM1_IRQHandler           ; 25: PWM1
                DCD     I2C0_IRQHandler           ; 26: I2C0
                DCD     I2C1_IRQHandler           ; 27: I2C1
                DCD     I2C2_IRQHandler           ; 28: I2C2
                DCD     SPI_IRQHandler            ; 29: SPI
                DCD     SSP0_IRQHandler           ; 30: SSP0
                DCD     SSP1_IRQHandler           ; 31: SSP1
                DCD     PLL0_IRQHandler           ; 32: PLL0 Lock (Main PLL)
                DCD     RTC_IRQHandler            ; 33: Real Time Clock
                DCD     EINT0_IRQHandler          ; 34: External Interrupt 0
                DCD     EINT1_IRQHandler          ; 35: External Interrupt 1
                DCD     EINT2_IRQHandler          ; 36: External Interrupt 2
                DCD     EINT3_IRQHandler          ; 37: External Interrupt 3
                DCD     ADC_IRQHandler            ; 38: A/D Converter
                DCD     BOD_IRQHandler            ; 39: Brown-Out Detect
                DCD     USB_IRQHandler            ; 40: USB
                DCD     CAN_IRQHandler            ; 41: CAN
                DCD     DMA_IRQHandler            ; 42: General Purpose DMA
                DCD     I2S_IRQHandler            ; 43: I2S
                DCD     ENET_IRQHandler           ; 44: Ethernet
                DCD     RIT_IRQHandler            ; 45: Repetitive Interrupt Timer
                DCD     MCPWM_IRQHandler          ; 46: Motor Control PWM
                DCD     QEI_IRQHandler            ; 47: Quadrature Encoder Interface
                DCD     PLL1_IRQHandler           ; 48: PLL1 Lock (USB PLL)
                DCD     USBActivity_IRQHandler    ; 49: USB Activity interrupt to wakeup
                DCD     CANActivity_IRQHandler    ; 50: CAN Activity interrupt to wakeup


                IF      :LNOT::DEF:NO_CRP
                AREA    |.ARM.__at_0x02FC|, CODE, READONLY
CRP_Key         DCD     0xFFFFFFFF
                ENDIF


; Poles
poleSize	EQU 5

				AREA POLES, DATA, READWRITE
pole1			SPACE 4*(poleSize+1)
pole2			SPACE 4*(poleSize+1)
pole3			SPACE 4*(poleSize+1)

; Discs
				AREA DISCS, DATA, READONLY
discs1		DCD 9, 6, 3, 2, 1, 8, 7, 0, 5, 4, 0
discs2		DCD 5, 4, 3, 2, 1, 0, 0, 0


				AREA |.text|, CODE, READONLY


; Reset Handler
Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
				;IMPORT  SystemInit
                ;IMPORT  __main
                ;LDR r0, =SystemInit
                ;BLX r0
                ;LDR r0, =__main
                ;BX r0

				; load pole addresses
				LDR r1, =pole1
				LDR r2, =pole2
				LDR r3, =pole3
				
				; delimit poles:
				; * poleX empty if [poleX] = 0xFFFFFFFF
				; * poleX full if [poleX - 4] = 0xFFFFFFFF
				MOV r0, #0xFFFFFFFF
				STR r0, [r1, #-4*(poleSize+1)]
				STR r0, [r1]
				STR r0, [r2]
				STR r0, [r3]
				
				; load address of first set of discs
				LDR r0, =discs1
				
				; fill pole 1
				PUSH {r2,r3}
				PUSH {r0,r1}
				BL fillStack
				POP {r0,r1}
				POP {r2,r3}
				
				; fill pole 2
				PUSH {r1,r3}
				PUSH {r0,r2}
				BL fillStack
				POP {r0,r2}
				POP {r1,r3}
				
				; fill pole 3
				PUSH {r1,r2}
				PUSH {r0,r3}
				BL fillStack
				POP {r0,r3}
				POP {r1,r2}
				
				; move one disc from pole 2 to pole 1 (destination pole full)
				PUSH {r0,r3}
				PUSH {r1}
				PUSH {r2}
				BL move1
				POP {r2}
				POP {r1}
				POP {r0,r3}
				
				; move one disc from pole 2 to pole 3 (source pole disc >= destination pole disc)
				PUSH {r0,r1}
				PUSH {r3}
				PUSH {r2}
				BL move1
				POP {r2}
				POP {r3}
				POP {r0,r1}
				
				; move one disc from pole 1 to pole 2 (ok)
				PUSH {r0,r3}
				PUSH {r2}
				PUSH {r1}
				BL move1
				POP {r1}
				POP {r2}
				POP {r0,r3}
				
				; empty pole 1
				PUSH {r2,r3}
				PUSH {r1}
				BL emptyPole
				POP {r1}
				POP {r2,r3}
				
				; empty pole 2
				PUSH {r1,r3}
				PUSH {r2}
				BL emptyPole
				POP {r2}
				POP {r1,r3}
				
				; empty pole 3
				PUSH {r1,r2}
				PUSH {r3}
				BL emptyPole
				POP {r3}
				POP {r1,r2}
			
				; load address of second set of discs
				LDR r0, =discs2
				
				; fill pole 1
				PUSH {r2,r3}
				PUSH {r0,r1}
				BL fillStack
				POP {r0,r1}
				POP {r2,r3}

				; move one disc from pole 2 to pole 3 (source pole empty)

				; move 5 discs from pole 1 to pole 2
				MOV r0, #poleSize
				PUSH {r0}
				PUSH {r3}
				PUSH {r2}
				PUSH {r1}
				BL moveN
				POP {r1}
				POP {r2}
				POP {r3}
				POP {r0}

stop			B stop
                ENDP
					

; Fill pole
fillStack		PROC
				LDR r0, [sp]
				LDR r1, [sp, #4]
				MOV r2, #0xFFFFFFFF
				
fillNext		LDR r3, [r0]
				CMP r3, #0
				BEQ zeroDisc
				CMP r3, r2
				BHI higherDisc
				STMDB r1!, {r3}
				ADD r0, r0, #4
				MOV r2, r3
				B fillNext

zeroDisc		ADD r0, r0, #4

higherDisc 		STR r0, [sp]
				STR r1, [sp, #4]
				BX lr
				ENDP


; Empty pole
emptyPole 		PROC
				LDR r0, [sp]
				MOV r1, #0
				
emptyNext 		LDR r2, [r0]
				CMP r2, #0xFFFFFFFF
				BEQ poleEmpty
				STR r1, [r0]
				ADD r0, r0, #4
				B emptyNext
				
poleEmpty 		STR r0, [sp]
				BX lr
				ENDP


; Move one disc
move1			PROC
				LDR r1, [sp]
				LDR r2, [sp, #4]
				MOV r0, #0
				
				; check if source pole empty
				LDR r3, [r1]
				CMP r3, #0xFFFFFFFF
				BEQ noMove
				
				; check if destination pole full
				SUB r3, r2, #4
				LDR r3, [r3]
				CMP r3, #0xFFFFFFFF
				BEQ noMove
				
				; check if source pole disc >= destination pole disc
				LDR r3, [r1]
				LDR r12, [r2]
				CMP r3, r12
				BHS noMove
				
				; move source pole disc to destination pole
				STR r0, [r1]
				ADD r1, r1, #4
				STMDB r2!, {r3}
				STR r1, [sp]
				STR r2, [sp, #4]
				MOV r0, #1
				
noMove			STR r0, [sp, #8]
				BX lr
				ENDP
					
	
; Move N discs from pole X to pole Y
moveN			PROC
				PUSH {r4,r5,lr}
				LDR r0, [sp, #12]; pole X
				LDR r1, [sp, #16]; pole Y
				LDR r2, [sp, #20]; pole Z
				LDR r4, [sp, #24]; N
				
				; move one disc from pole X to pole Y
				CMP r4, #1
				BNE NNotOne
			    PUSH {r2}
				PUSH {r0,r1,r5}
				BL move1
				POP {r0,r1,r5}
				POP {r2}
				B return

				; move N-1 discs from pole X to pole Z
NNotOne			SUB r4, r4, #1
				PUSH {r1,r4}
				PUSH {r0,r2}
				BL moveN
				POP {r0,r2}
				POP {r1,r5}
				
				; move one disc from pole X to pole Y
				PUSH {r2}
				PUSH {r0,r1,r3}
				BL move1
				POP {r0,r1,r3}
				POP {r2}
				CMP r3, #0
				BEQ return
				ADD r5, r5, #1
				
				; move N-1 discs from pole Z to pole Y
				PUSH {r0,r4}
				PUSH {r1}
				PUSH {r2}
				BL moveN
				POP {r2}
				POP {r1}
				POP {r0,r3}
				ADD r5, r5, r3
				
				; return
return			STR r0, [sp, #12]
				STR r1, [sp, #16]
				STR r2, [sp, #20]
				STR r5, [sp, #24]
				POP {r4,r5,pc}
				ENDP
					

; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                B       .
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler         [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler          [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler        [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler          [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
                EXPORT  SysTick_Handler           [WEAK]
                B       .
                ENDP

Default_Handler PROC

                EXPORT  WDT_IRQHandler            [WEAK]
                EXPORT  TIMER0_IRQHandler         [WEAK]
                EXPORT  TIMER1_IRQHandler         [WEAK]
                EXPORT  TIMER2_IRQHandler         [WEAK]
                EXPORT  TIMER3_IRQHandler         [WEAK]
                EXPORT  UART0_IRQHandler          [WEAK]
                EXPORT  UART1_IRQHandler          [WEAK]
                EXPORT  UART2_IRQHandler          [WEAK]
                EXPORT  UART3_IRQHandler          [WEAK]
                EXPORT  PWM1_IRQHandler           [WEAK]
                EXPORT  I2C0_IRQHandler           [WEAK]
                EXPORT  I2C1_IRQHandler           [WEAK]
                EXPORT  I2C2_IRQHandler           [WEAK]
                EXPORT  SPI_IRQHandler            [WEAK]
                EXPORT  SSP0_IRQHandler           [WEAK]
                EXPORT  SSP1_IRQHandler           [WEAK]
                EXPORT  PLL0_IRQHandler           [WEAK]
                EXPORT  RTC_IRQHandler            [WEAK]
                EXPORT  EINT0_IRQHandler          [WEAK]
                EXPORT  EINT1_IRQHandler          [WEAK]
                EXPORT  EINT2_IRQHandler          [WEAK]
                EXPORT  EINT3_IRQHandler          [WEAK]
                EXPORT  ADC_IRQHandler            [WEAK]
                EXPORT  BOD_IRQHandler            [WEAK]
                EXPORT  USB_IRQHandler            [WEAK]
                EXPORT  CAN_IRQHandler            [WEAK]
                EXPORT  DMA_IRQHandler            [WEAK]
                EXPORT  I2S_IRQHandler            [WEAK]
                EXPORT  ENET_IRQHandler           [WEAK]
                EXPORT  RIT_IRQHandler            [WEAK]
                EXPORT  MCPWM_IRQHandler          [WEAK]
                EXPORT  QEI_IRQHandler            [WEAK]
                EXPORT  PLL1_IRQHandler           [WEAK]
                EXPORT  USBActivity_IRQHandler    [WEAK]
                EXPORT  CANActivity_IRQHandler    [WEAK]

WDT_IRQHandler
TIMER0_IRQHandler
TIMER1_IRQHandler
TIMER2_IRQHandler
TIMER3_IRQHandler
UART0_IRQHandler
UART1_IRQHandler
UART2_IRQHandler
UART3_IRQHandler
PWM1_IRQHandler
I2C0_IRQHandler
I2C1_IRQHandler
I2C2_IRQHandler
SPI_IRQHandler
SSP0_IRQHandler
SSP1_IRQHandler
PLL0_IRQHandler
RTC_IRQHandler
EINT0_IRQHandler
EINT1_IRQHandler
EINT2_IRQHandler
EINT3_IRQHandler
ADC_IRQHandler
BOD_IRQHandler
USB_IRQHandler
CAN_IRQHandler
DMA_IRQHandler
I2S_IRQHandler
ENET_IRQHandler
RIT_IRQHandler
MCPWM_IRQHandler
QEI_IRQHandler
PLL1_IRQHandler
USBActivity_IRQHandler
CANActivity_IRQHandler

                B       .

                ENDP


                ALIGN


; User Initial Stack & Heap

                IF      :DEF:__MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap
__user_initial_stackheap

                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR

                ALIGN

                ENDIF


                END
