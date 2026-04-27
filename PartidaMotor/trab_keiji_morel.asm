        ORG     0000H
        LJMP    MAIN

        ORG     000BH
        LJMP    TIMER0_ISR

        ORG     0030H

MAIN:
        MOV     SP,   #70H
        MOV     P1,   #0FFH
        MOV     P2,   #0FFH
        MOV     R2,   #00H
        MOV     R5,   #50
        MOV     R6,   #00H
        MOV     TMOD, #01H
        MOV     TH0,  #3CH
        MOV     TL0,  #0B0H
        MOV     IE,   #82H
        SETB    TR0

WAIT_START:
        JB      P2.3, WAIT_START
        MOV     A,    P2
        CPL     A
        ANL     A,    #07H
        ADD     A,    #01H
        MOV     R0,   A
        MOV     P1,   #0FCH
        MOV     R2,   #01H
        MOV     R6,   #00H

MAIN_LOOP:
        MOV     A,    R6
        JZ      CHECK_REV
        MOV     R6,   #00H
        MOV     A,    R2
        CJNE    A,    #01H, CHECK_REV
        DJNZ    R0,   CHECK_REV
        MOV     P1,   #0FAH
        MOV     R2,   #02H

CHECK_REV:
        JB      P2.4, MAIN_LOOP
        MOV     R1,   #03H
        MOV     R6,   #00H

WAIT_REV_TICK:
        MOV     A,    R6
        JZ      WAIT_REV_TICK
        MOV     R6,   #00H
        DJNZ    R1,   WAIT_REV_TICK
        MOV     P1,   #0FFH
        MOV     P1,   #0F6H
        MOV     R0,   #03H
        MOV     R2,   #01H
        MOV     R6,   #00H
        LJMP    MAIN_LOOP

TIMER0_ISR:
        MOV     TH0,  #3CH
        MOV     TL0,  #0B0H
        DJNZ    R5,   END_ISR
        MOV     R5,   #50
        MOV     R6,   #01H
END_ISR:
        RETI

        END
