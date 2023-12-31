;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;쿟imer-rutiinit (MATOPAS II:sta ripatut!)                                     �
;쿝utiinilla on kaksi teht꼟꼧: lis꼝� RetracesGone-laskuria aina 70hz tahdissa�
;�(pelin nopeuden tasaamista varten) sek� soittaa musiikkia 50hz tahdissa. Ja  �
;퀃ottakai vanhaa rutiinia kutsutaan eik� ajan pit꼒si v꼧risty� ainakaan kovin�
;쿴irve꼜ti.                                                                   �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

                Title   Ajastinkeskeytys ja musiikkirutiinin kutsuminen
                Name    TIMER
pusha86 MACRO
   push ax
   push cx
   push dx
   push bx
   push bp
   push si
   push di
ENDM

popa86 MACRO
   pop di
   pop si
   pop bp
   pop bx
   pop dx
   pop cx
   pop ax
ENDM
                
                Model   Small

                Extrn   PlayMusic:near

                Public  Timerretrace
                Public  InstallTimer
                Public  RemoveTimer
                Public  Retracesgone


컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

Frequency       equ     0427dh/5

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                Dataseg

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

Addvalue        dw      0
Timecounter     dw      0
Timerinstalled  db      0
Retracesinner   db      0
Retracesgone    db      0

                Evendata

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                Codeseg
                .8086

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

Timerretrace:   mov     AL,00110110b
                out     43h,AL
                jmp     $+2
                mov     AL,low Frequency
                out     40h,AL
                jmp     $+2
                mov     AL,high Frequency
                out     40h,AL
                jmp     $+2
                mov     [Retracesgone],0
                mov     [Retracesinner],0
                ret

InstallTimer:   cmp     [Timerinstalled],1
                je      InstallTimerq
                cli
                push    DS
                xor     AX,AX
                mov     DS,AX
                mov     AX,DS:[32]
                mov     BX,DS:[34]
                mov     word ptr CS:[OldTimervector],AX
                mov     word ptr CS:[OldTimervector+2],BX
                mov     AX,CS
                mov     DS:[34],AX
                mov     AX,offset Timerroutine
                mov     DS:[32],AX
                pop     DS
                mov     AL,00110110b
                out     43h,AL
                jmp     $+2
                mov     AL,low frequency
                out     40h,AL
                jmp     $+2
                mov     AL,high frequency
                out     40h,AL
                jmp     $+2
                sti
                mov     [Timerinstalled],1
                mov     [Addvalue],frequency
InstallTimerq:  ret

RemoveTimer:    cmp     [Timerinstalled],1
                jne     InstallTimerq
                cli
                push    DS
                xor     AX,AX
                mov     DS,AX
                mov     AX,word ptr CS:[OldTimervector]
                mov     BX,word ptr CS:[OldTimervector+2]
                mov     DS:[32],AX
                mov     DS:[34],BX
                pop     DS
                mov     AL,00110110b
                out     43h,AL
                jmp     $+2
                xor     AL,AL
                out     40h,AL
                jmp     $+2
                out     40h,AL
                jmp     $+2
                sti
                mov     [Timerinstalled],0
                ret

Timerroutine:   push    DS
                pusha86
                mov     AX,seg Timecounter
                mov     DS,AX
                push    ES
                call    PlayMusic
                pop     ES
                inc     [Retracesinner]
                cmp     [Retracesinner],5
                jb      Timer_noretrace
                mov     [Retracesinner],0
                inc     [Retracesgone]
Timer_noretrace:mov     AX,[Addvalue]
                add     [Timecounter],AX
                jc      Timer_callOld
                mov     AL,20h
                out     20h,AL
                popa86
                pop     DS
                iret

Timer_callOld:  popa86
                pop     DS
                db      0eah            ;Hehee, itse꼧nmuuttavaa koodia (ja
OldTimervector  dd      0               ;inspiraationa tietenkin MATOPAS II...)

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

                end
