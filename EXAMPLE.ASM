;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³And here's a little example on how to use the routines in Player.Asm.        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                Model   Small
                Stack   200h

                Extrn   LoadMusic:near
                Extrn   InitMusic:near
                Extrn   StopMusic:near
                Extrn   PlayMusic:near

Frequency       equ     0427dh/5        ;Five interrupts per screen refresh

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Dataseg

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Addvalue        dw      0
Timecounter     dw      0
Timerinstalled  db      0
SongName        db      'virsi517.sng',0
Text            db      'Here we are playing the song...',13,10,'$'

                Evendata

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Codeseg
                .8086

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Start:          mov     AX,seg Text
                mov     DS,AX
                call    InstallTimer
                mov     DX,offset Text
                mov     AH,09h
                int     21h
                mov     DX,offset SongName
                call    LoadMusic
                call    InitMusic
                mov     AH,00h
                int     16h                     ;Wait for keypress
                call    StopMusic
                call    RemoveTimer
                mov     AX,4c00h
                int     21h

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
                pusha
                mov     AX,seg Timecounter
                mov     DS,AX
                call    PlayMusic               ;Here we call the play routine
                mov     AX,[Addvalue]
                add     [Timecounter],AX
                jc      Timer_callOld
                mov     AL,20h
                out     20h,AL
                popa
                pop     DS
                iret

Timer_CallOld:  popa
                pop     DS
                db      0eah
OldTimervector  dd      0

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                end
