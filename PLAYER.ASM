;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³FMC V1.0 Real Mode Songplayer written by FAUST!                              ³
;³                                                                             ³
;³Refer to the documentation for advice about linking this with your own       ³
;³programs. Those weirdos using protected mode should be talented enough to    ³
;³write an own songplayer.                                                     ³
;³                                                                             ³
;³As you remember, FMC uses 8 channels. Support for the ninth channel is       ³
;³provided, however, and by messing around with the PlayNote and NoteOff-      ³
;³routines you can for example play sound FX. Remember however to shut the     ³
;³interrupts off during these routines because they access ADLIB ports         ³
;³directly.                                                                    ³
;³                                                                             ³
;³As a closing, I'll discuss the instrument system. In the song data, the      ³
;³instruments are stored in an unpacked format with the name and everything,   ³
;³so that they're easy to edit. However, when they're about to be played,      ³
;³the BuildInstrument subroutine is called to convert them into 16-byte packed-³
;³format instruments, which contain directly the values to write into ADLIB    ³
;³registers.                                                                   ³
;³                                                                             ³
;³   P.S There are virtually no comments at all. I'm a lazy person........ :-) ³
;³                                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                Model   Small

                Public  ResetAdlib
                Public  LoadMusic
                Public  PlayMusic
                Public  InitMusic
                Public  StopMusic
                Public  PlayNote
                Public  NoteOff

NumInstruments  equ     32
NumChans        equ     9

ChanInfo        Struc

ChanOp1Ctrl     db      0
ChanOp1Volume   db      0
ChanOp1Attack   db      0
ChanOp1Sustain  db      0
ChanOp1Wave     db      0
ChanOp2Ctrl     db      0
ChanOp2Volume   db      0
ChanOp2Attack   db      0
ChanOp2Sustain  db      0
ChanOp2Wave     db      0
ChanConnect     db      0
ChanLSB         db      0
ChanMSB         db      0
ChanAddvalue    db      0
ChanVolume      db      0
ChanInstr       db      0
ChanEffect1     db      0
ChanEffect2     db      0
ChanEffect3     db      0
ChanNote        db      0
ChanNoteSlot    db      0
ChanSoundOn     db      0
ChanArpeggio    db      0
ChanToneDir     db      0
ChanToneSpeed   db      0
ChanVibDepth    db      0
ChanVibSpeed    db      0
ChanVibDir      db      0
ChanVibCounter  db      0
ChanVibrato     dw      0
ChanTarget      dw      0
ChanFreq        dw      0
ChanBaseFreq    dw      0

ChanInfo        Ends

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Dataseg

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;Frequency values for the chromatic scale

Freqs   dw 344,345,346,348,349,350,351,352,354,355,356,357,358,359,361,362
        dw 363,364,366,367,369,370,371,373,374,375,377,378,380,381,382,384
        dw 385,386,388,389,391,392,394,395,397,398,399,401,402,404,405,407
        dw 408,410,411,413,414,416,417,419,420,422,423,425,426,428,429,431
        dw 432,434,435,437,439,440,442,443,445,447,448,450,452,453,455,456
        dw 458,460,461,463,465,466,468,470,472,473,475,477,478,480,482,483
        dw 485,487,489,490,492,494,496,498,500,501,503,505,507,509,510,512
        dw 514,516,518,520,522,523,525,527,529,531,533,535,537,538,540,542
        dw 544,546,548,550,552,554,556,558,561,563,565,567,569,571,573,575
        dw 577,579,581,583,586,588,590,592,594,596,598,600,603,605,607,609
        dw 611,613,616,618,620,622,625,627,629,631,634,636,638,640,643,645
        dw 647,649,652,654,657,659,662,664,667,669,671,674,676,679,681,684

;Register numbers for the nine standard ADLIB channels

Regs    db 20h,40h,60h,80h,0e0h,23h,43h,63h,83h,0e3h,0c0h,0a0h,0b0h
        db 21h,41h,61h,81h,0e1h,24h,44h,64h,84h,0e4h,0c1h,0a1h,0b1h
        db 22h,42h,62h,82h,0e2h,25h,45h,65h,85h,0e5h,0c2h,0a2h,0b2h
        db 28h,48h,68h,88h,0e8h,2bh,4bh,6bh,8bh,0ebh,0c3h,0a3h,0b3h
        db 29h,49h,69h,89h,0e9h,2ch,4ch,6ch,8ch,0ech,0c4h,0a4h,0b4h
        db 2ah,4ah,6ah,8ah,0eah,2dh,4dh,6dh,8dh,0edh,0c5h,0a5h,0b5h
        db 30h,50h,70h,90h,0f0h,33h,53h,73h,93h,0f3h,0c6h,0a6h,0b6h
        db 31h,51h,71h,91h,0f1h,34h,54h,74h,94h,0f4h,0c7h,0a7h,0b7h
        db 32h,52h,72h,92h,0f2h,35h,55h,75h,95h,0f5h,0c8h,0a8h,0b8h

Instruments     db      16*NumInstruments dup (0)
SongSeg         dw      Seg Song
PattSeg         dw      0
ParagraphOffset dw      0               ;How many paragraphs between patterns
Handle          dw      0
NoteVolume      db      0
TimeCounter     db      0
Playing         db      0
Loaded          db      0
SongPosition    db      0
PattPosition    db      0
Tempo           db      0
Counter         db      0

ChanInfos       ChanInfo NumChans dup (<>)
GhostRegs       db      256 dup (0)             ;Ghost registers to eliminate
                                                ;writing the same value again

        ;Here the beginning of the song data will be loaded

SongIdent       db      'FMC!'
SongName        db      '                    ',0
SongChans       db      ?
SongOrder       db      256 dup (0)
SongOrderEnd    dw      6606h           ;Will read 666 when viewed
SongInstruments db      48*NumInstruments dup (0)
EndSong         dw      6606h           ;Will read 666 when viewed

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Codeseg
                .8086
                Jumps

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        ;This routine loads the song file for playing. DX must contain the
        ;offset of the file name.

LoadMusic:      mov     [Playing],0
                cli
                mov     AX,3d00h                ;Try to open
                int     21h
                jc      SongLoadQuit            ;Error
                mov     [Handle],AX
                mov     BX,AX
                mov     DX,offset SongIdent
                mov     CX,4
                mov     AX,3f00h                ;Read 4 bytes for the
                int     21h                     ;identification code "FMC!"
                jc      SongLoadQuit2
                cmp     [SongIdent],'F'
                jne     SongLoadQuit2
                cmp     [SongIdent+1],'M'
                jne     SongLoadQuit2
                cmp     [SongIdent+2],'C'
                jne     SongLoadQuit2
                cmp     [SongIdent+3],'!'
                jne     SongLoadQuit2
                mov     DX,offset SongName
                mov     CX,offset EndSong-offset SongName
                mov     AX,3f00h
                int     21h                     ;Now let's load the pattern
                jc      SongLoadQuit2           ;order and instruments
                xor     DH,DH
                mov     DL,[SongChans]
                xor     CH,CH
                mov     CL,[SongChans]
                shl     DX,7                    ;x128
                shl     CX,6                    ;x64
                add     CX,DX                   ;CX holds pattern length in
                mov     SI,CX                   ;bytes
                shr     SI,4                    ;SI contains the length
                mov     [ParagraphOffset],SI
                mov     BP,[SongSeg]            ;in paragraphs
                mov     DS,BP                   ;Begin the loading of the
LoadPatterns:   xor     DX,DX                   ;patterns
                mov     AX,3f00h
                int     21h
                cmp     AX,0
                je      PatternsReady
                add     BP,SI
                mov     DS,BP
                jmp     LoadPatterns
PatternsReady:  mov     AX,seg Songname
                mov     DS,AX                   ;Restore DS segment
                mov     [Loaded],1
SongLoadQuit2:  mov     BX,[Handle]             ;Close the file
                mov     AX,3e00h
                int     21h
SongLoadQuit:   sti
                ret

        ;Begins the playing, at song position 0.

InitMusic:      mov     [Playing],0
                cli
                cmp     [Loaded],1
                jne     CannotInit
                mov     CX,8
                xor     AL,AL
InitMusic2:     call    NoteOff                 ;Kaikki kanavat pois
                inc     AL
                loop    InitMusic2
                mov     [TimeCounter],240       ;Ei tehd„ v„h„„n aikaan mit„„n
                mov     CX,32
                mov     SI,offset SongInstruments
                xor     AL,AL
InitMusic3:     call    BuildInstrument         ;"Rakennetaan" soittimet
                inc     AL                      ;uudestaan
                add     SI,48
                loop    InitMusic3
                mov     [SongPosition],-1
                mov     [PattPosition],63
                mov     [Tempo],6
                mov     [Counter],5
                mov     [Playing],1
CannotInit:     sti
                ret

        ;Stops the playing.

StopMusic:      mov     [Playing],0
                cli
                mov     CX,8
                xor     AL,AL
StopMusic2:     call    NoteOff                 ;Every channel off
                inc     AL
                loop    StopMusic2
                mov     CX,11h
                mov     AL,40h
                mov     BL,3fh                  ;Volume levels to zero
StopMusic3:     call    OutValue
                inc     AL
                loop    StopMusic3
                mov     AL,53h
                call    OutValue
                inc     AL
                call    OutValue
                sti
                ret

        ;This is the main routine to be called preferably in a timer interrupt
        ;five times between the vertical retraces. If you have a different
        ;timer frequency then you must adjust the TimeCounter limits below.
        ;Notice that ADLIB requires time to react between a note-off and a
        ;note-on.

PlayMusic:      inc     [TimeCounter]
                cmp     [TimeCounter],1
                je      PlayMusic_NotesOff
                cmp     [TimeCounter],6
                je      PlayMusic_NotesOn
                cmp     [TimeCounter],7
                je      PlayMusic_Update
                ret
PlayMusic_NotesOff:
                mov     SI,offset Chaninfos
                mov     CX,NumChans
                xor     AL,AL
PlayMusic_NotesOff2:
                cmp     [SI.ChanSoundOn],3
                jne     PlayMusic_NotesOff3
                mov     [SI.ChanSoundOn],2
                add     AL,0b0h
                mov     BL,[SI.ChanMSB]
                and     BL,11011111b
                call    SmartOutValue
                sub     AL,0b0h
PlayMusic_NotesOff3:
                inc     AL
                add     SI,type ChanInfo
                loop    PlayMusic_NotesOff2
                ret

PlayMusic_NotesOn:
                mov     SI,offset Chaninfos
                mov     CX,NumChans
                xor     AL,AL
PlayMusic_NotesOn2:
                cmp     [SI.ChanSoundOn],2
                jne     PlayMusic_NotesOn3
                mov     [SI.ChanSoundOn],1
                push    CX
                mov     BL,[SI.ChanInstr]
                mov     CX,[SI.ChanFreq]
                mov     DL,[SI.ChanVolume]
                call    PlayNote
                pop     CX
PlayMusic_NotesOn3:
                inc     AL
                add     SI,type ChanInfo
                loop    PlayMusic_NotesOn2
                ret

PlayMusic_Update:
                mov     [TimeCounter],0
                mov     SI,offset Chaninfos
                mov     BP,offset Regs
                mov     CX,NumChans
PlayMusic2:     cmp     [SI.ChanSoundOn],1
                jne     PlayMusicNext
PlayMusic4:     mov     AL,[SI.ChanAddValue]
                cbw
                add     [SI.ChanFreq],AX
                cmp     [SI.ChanFreq],0
                jge     PlayMusic5
                mov     [SI.ChanFreq],0
PlayMusic5:     mov     DI,SI
                pusha
                mov     AX,[SI.ChanFreq]
                cwd
                mov     BX,192
                idiv    BX              ;DX=note, AX=octave
                and     AL,7
                shl     AL,2
                mov     SI,DX
                shl     SI,1
                add     SI,offset Freqs
                mov     BX,[SI]
                shr     BX,8
                or      AL,BL
                mov     CL,AL
                mov     AL,DS:[BP+11]
                mov     BL,[SI]         ;LSB
                mov     [DI.ChanLSB],BL
                call    SmartOutValue
                add     AL,010h
                mov     BL,CL           ;MSB
                or      BL,20h          ;Channel On-bit
                mov     [DI.ChanMSB],BL
                call    SmartOutValue
                popa
PlayMusicNext:  add     SI,type ChanInfo
                add     BP,13
                dec     CX
                jne     PlayMusic2
PlayMusic_NewNotes:
                cmp     [Playing],1
                jne     PlayMusic_AllDone
                push    ES
                inc     [Counter]
                mov     AL,[Counter]
                cmp     AL,[Tempo]
                jb      PlayMusic_Effects
                mov     [Counter],0
                inc     [PattPosition]
                cmp     [PattPosition],64
                jb      PlayMusic_NoNewPatt
                mov     [PattPosition],0
                inc     [SongPosition]
                xor     AH,AH
                mov     AL,[SongPosition]
                mov     SI,offset SongOrder
                add     SI,AX
                cmp     byte ptr [SI],254
                je      PlayMusic_StopPlay
                cmp     byte ptr [SI],255
                jne     PlayMusic_NoRepeat
                mov     SI,offset SongOrder
                mov     [SongPosition],0
                cmp     byte ptr [SI],255
                je      PlayMusic_StopPlay
PlayMusic_NoRepeat:
                mov     AL,[SI]
                mov     BX,[ParagraphOffset]
                mul     BX
                mov     [PattSeg],AX
                mov     AX,[SongSeg]
                add     [PattSeg],AX
PlayMusic_NoNewPatt:
                mov     AX,[PattSeg]
                mov     ES,AX
                mov     CL,[SongChans]
                mov     SI,offset ChanInfos
                xor     DI,DI
                xor     AH,AH
                mov     AL,[PattPosition]
                add     DI,AX
                add     DI,AX
                add     DI,AX
PlayMusic_ChannelLoop:
                mov     BL,ES:[DI]
                and     BL,127
                mov     [SI.ChanNoteSlot],BL
                cmp     BL,0
                je      PlayMusic_SkipNote
                mov     [SI.ChanNote],BL
PlayMusic_SkipNote:
                mov     AL,ES:[DI+1]
                shr     AL,4
                mov     [SI.ChanInstr],AL
                mov     AL,ES:[DI]
                shr     AL,7
                shl     AL,4
                or      [SI.ChanInstr],AL
                mov     AL,ES:[DI+1]
                and     AL,15
                mov     [SI.ChanEffect1],AL
                mov     AL,ES:[DI+2]
                shr     AL,4
                mov     [SI.ChanEffect2],AL
                mov     AL,ES:[DI+2]
                and     AL,15
                mov     [SI.ChanEffect3],AL
                cmp     BL,0
                je      PlayMusic_NoNote
                cmp     [SI.ChanEffect1],3      ;Onko TonePortamento
                je      PlayMusic_SetTone
                cmp     [SI.ChanEffect1],0eh
                jne     PlayMusic_NormalNote
                cmp     [SI.ChanEffect2],0dh    ;NoteDelay?
                je      PlayMusic_NoNote        ;Eli ei soiteta viel„...
PlayMusic_NormalNote:
                xor     BH,BH
                dec     BL
                shl     BX,4
                mov     [SI.ChanFreq],BX
                mov     [SI.ChanBaseFreq],BX
                mov     [SI.ChanVolume],63
                mov     [SI.ChanSoundOn],3
                mov     [SI.ChanArpeggio],2
                mov     [SI.ChanVibDir],0
                mov     [SI.ChanVibCounter],0
                mov     [SI.ChanVibrato],0
PlayMusic_NoNote:
                add     SI,type ChanInfo
                add     DI,192
                dec     CL
                jnz     PlayMusic_ChannelLoop
PlayMusic_Effects:
                mov     CL,[SongChans]
                mov     SI,offset ChanInfos
PlayMusic_Effects2:
                mov     AL,[SI.ChanEffect1]
                cmp     AL,0fh    ;Set tempo
                je      PlayMusic_SetTempo
                cmp     AL,0dh    ;Patternbreak
                je      PlayMusic_PatternBreak
                cmp     AL,0bh    ;Positionjump
                je      PlayMusic_PositionJump
                cmp     AL,01h    ;Slideup
                je      PlayMusic_SlideUp
                cmp     AL,02h    ;Slidedown
                je      PlayMusic_SlideDown
                cmp     AL,03h    ;Toneportamento
                je      PlayMusic_UpdateTone
                cmp     AL,04h    ;Vibrato
                je      PlayMusic_Vibrato
                cmp     AL,0eh    ;Note Repeat Commands
                je      PlayMusic_NoteRepeats
                cmp     AL,0ah
                je      PlayMusic_VolSlide
                cmp     AL,0ch
                je      PlayMusic_SetVolume
                cmp     AL,00h
                je      PlayMusic_Arpeggio
PlayMusic_EffectsNext:
                add     SI,type ChanInfo
                dec     CL
                jnz     PlayMusic_Effects2
                pop     ES
                ret

PlayMusic_NoteRepeats:
                cmp     [SI.ChanEffect2],0dh
                je      NoteRepeatOK
                cmp     [SI.ChanEffect2],09h
                je      NoteRepeatOK
                jmp     PlayMusic_EffectsNext
NoteRepeatOK:   mov     AL,[SI.ChanEffect3]
                cmp     [Counter],AL
                jne     PlayMusic_EffectsNext
                mov     BL,[SI.ChanNoteSlot]
                xor     BH,BH
                dec     BL
                shl     BX,4
                mov     [SI.ChanFreq],BX
                mov     [SI.ChanBaseFreq],BX
                mov     [SI.ChanVolume],63
                mov     [SI.ChanSoundOn],3
                mov     [SI.ChanArpeggio],2
                mov     [SI.ChanVibDir],0
                mov     [SI.ChanVibCounter],0
                mov     [SI.ChanVibrato],0
                jmp     PlayMusic_EffectsNext

PlayMusic_Vibrato:
                cmp     [SI.ChanSoundOn],3
                je      Vibrato_OK
                cmp     [Counter],0
                je      Vibrato_OK
                jmp     Vibrato_NoNewDepth
Vibrato_OK:     mov     AL,[SI.ChanEffect2]
                cmp     AL,0
                je      Vibrato_NoNewSpeed
                mov     [SI.ChanVibSpeed],AL
                mov     [SI.ChanVibrato],0
                shr     AL,1
                mov     [SI.ChanVibCounter],AL
Vibrato_NoNewSpeed:
                mov     AL,[SI.ChanEffect3]
                cmp     AL,0
                je      Vibrato_NoNewDepth
                mov     [SI.ChanVibDepth],AL
Vibrato_NoNewDepth:
                dec     [SI.ChanVibCounter]
                jns     Vibrato_NotOver
                mov     AL,[SI.ChanVibSpeed]
                mov     [SI.ChanVibCounter],AL
                xor     [SI.ChanVibDir],1
Vibrato_NotOver:xor     AH,AH
                mov     AL,[SI.ChanVibDepth]
                cmp     [SI.ChanVibDir],0
                je      Vibrato_Up
                sub     [SI.ChanVibrato],AX
                mov     AX,[SI.ChanVibrato]
                add     AX,[SI.ChanBaseFreq]
                mov     [SI.ChanFreq],AX
                jmp     PlayMusic_EffectsNext
Vibrato_Up:     add     [SI.ChanVibrato],AX
                mov     AX,[SI.ChanVibrato]
                add     AX,[SI.ChanBaseFreq]
                mov     [SI.ChanFreq],AX
                jmp     PlayMusic_EffectsNext

PlayMusic_UpdateTone:
                cmp     [SI.ChanToneDir],0
                je      PlayMusic_EffectsNext
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                cmp     AL,0
                je      Tone_NoNewSpeed
                mov     [SI.ChanToneSpeed],AL
Tone_NoNewSpeed:xor     AH,AH
                mov     AL,[SI.ChanToneSpeed]
                cmp     [SI.ChanToneDir],-1
                je      Tone_Down
                add     [SI.ChanFreq],AX
                add     [SI.ChanBaseFreq],AX
                mov     AX,[SI.ChanTarget]
                cmp     [SI.ChanBaseFreq],AX
                jae     Tone_Finished
                jmp     PlayMusic_EffectsNext
Tone_Down:      sub     [SI.ChanFreq],AX
                sub     [SI.ChanBaseFreq],AX
                mov     AX,[SI.ChanTarget]
                cmp     [SI.ChanBaseFreq],AX
                jbe     Tone_Finished
                jmp     PlayMusic_EffectsNext
Tone_Finished:  mov     [SI.ChanToneDir],0
                mov     AX,[SI.ChanTarget]
                mov     [SI.ChanFreq],AX
                mov     [SI.ChanBaseFreq],AX
                jmp     PlayMusic_EffectsNext

PlayMusic_SetTempo:
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                cmp     AL,0
                je      SetTempo_StopPlay
                mov     [Tempo],AL
                jmp     PlayMusic_EffectsNext
SetTempo_StopPlay:
                mov     [Playing],0
                jmp     PlayMusic_EffectsNext

PlayMusic_PatternBreak:
                mov     [PattPosition],63
                jmp     PlayMusic_EffectsNext

PlayMusic_PositionJump:
                mov     [PattPosition],63
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                dec     AL
                mov     [SongPosition],AL
                jmp     PlayMusic_EffectsNext

PlayMusic_SlideUp:
                xor     AH,AH
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                add     [SI.ChanFreq],AX
                add     [SI.ChanBaseFreq],AX
                cmp     [SI.ChanBaseFreq],1535
                jle     PlayMusic_EffectsNext
                mov     [SI.ChanFreq],1535
                mov     [SI.ChanBaseFreq],1535
                jmp     PlayMusic_EffectsNext

PlayMusic_SlideDown:
                xor     AH,AH
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                sub     [SI.ChanFreq],AX
                sub     [SI.ChanBaseFreq],AX
                cmp     [SI.ChanBaseFreq],0
                jge     PlayMusic_EffectsNext
                mov     [SI.ChanFreq],0
                mov     [SI.ChanBaseFreq],0
                jmp     PlayMusic_EffectsNext

PlayMusic_SetVolume:
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                cmp     AL,63
                jbe     SetVolume_WithinLimits
                mov     AL,63
SetVolume_WithinLimits:
                mov     [SI.ChanVolume],AL
                cmp     [SI.ChanSoundOn],3
                je      PlayMusic_EffectsNext
                mov     [SI.ChanSoundOn],2      ;We'll force the Note-on
                jmp     PlayMusic_EffectsNext   ;routine to function again
                                                ;(could do this in a more
                                                ;intelligent way...)

PlayMusic_VolSlide:
                mov     AL,[SI.ChanEffect2]
                add     [SI.ChanVolume],AL
                cmp     [SI.ChanVolume],63
                jb      VolSlide_NotOver1
                mov     [SI.ChanVolume],63
VolSlide_NotOver1:
                mov     AL,[SI.ChanEffect3]
                sub     [SI.ChanVolume],AL
                cmp     [SI.ChanVolume],128
                jb      VolSlide_NotOver2
                mov     [SI.ChanVolume],0
VolSlide_NotOver2:
                cmp     [SI.ChanSoundOn],3
                je      PlayMusic_EffectsNext
                mov     [SI.ChanSoundOn],2
                jmp     PlayMusic_EffectsNext

PlayMusic_Arpeggio:
                mov     AL,[SI.ChanEffect2]
                or      AL,[SI.ChanEffect3]
                jz      PlayMusic_EffectsNext
                inc     [SI.ChanArpeggio]
                cmp     [SI.ChanArpeggio],3
                jne     Arpeggio_NotOver
                mov     [SI.ChanArpeggio],0
                mov     AX,[SI.ChanBaseFreq]
                mov     [SI.ChanFreq],AX
                jmp     PlayMusic_EffectsNext
Arpeggio_NotOver:
                cmp     [SI.ChanArpeggio],2
                je      Arpeggio2
                mov     AL,[SI.ChanNote]
                add     AL,[SI.ChanEffect2]
                cmp     AL,96
                jb      Arpeggio_NotOver2
                mov     AL,96
Arpeggio_NotOver2:
                xor     AH,AH
                dec     AL
                shl     AX,4
                mov     [SI.ChanBaseFreq],AX
                mov     [SI.ChanFreq],AX
                jmp     PlayMusic_EffectsNext
Arpeggio2:      mov     AL,[SI.ChanNote]
                add     AL,[SI.ChanEffect3]
                cmp     AL,96
                jb      Arpeggio_NotOver3
                mov     AL,96
Arpeggio_NotOver3:
                xor     AH,AH
                dec     AL
                shl     AX,4
                mov     [SI.ChanBaseFreq],AX
                mov     [SI.ChanFreq],AX
                jmp     PlayMusic_EffectsNext

PlayMusic_SetTone:
                mov     AL,[SI.ChanEffect2]
                shl     AL,4
                or      AL,[SI.ChanEffect3]
                mov     [SI.ChanToneSpeed],AL
                xor     BH,BH
                dec     BL
                shl     BX,4
                mov     [SI.ChanTarget],BX
                cmp     BX,[SI.ChanFreq]
                ja      PlayMusic_ToneUp
                mov     [SI.ChanToneDir],-1      ;Up
                jmp     PlayMusic_NoNote
PlayMusic_ToneUp:
                mov     [SI.ChanToneDir],1       ;Down
                jmp     PlayMusic_NoNote

PlayMusic_StopPlay:
                mov     [Playing],0
PlayMusic_AllDone:
                ret

OutValue:       push    AX DX DI
                xor     AH,AH
                mov     DI,AX
                add     DI,offset GhostRegs
                mov     [DI],BL
                mov     DX,388h
                out     DX,AL
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                inc     DX
                mov     AL,BL
                out     DX,AL
                dec     DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                pop     DI DX AX
                ret

SmartOutValue:  push    AX DX DI
                xor     AH,AH
                mov     DI,AX
                add     DI,offset GhostRegs
                cmp     byte ptr [DI],0
                je      AnyWay
                cmp     [DI],BL
                je      SmartNoAction
Anyway:         mov     [DI],BL
                mov     DX,388h
                out     DX,AL
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                inc     DX
                mov     AL,BL
                out     DX,AL
                dec     DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
                in      AL,DX
SmartNoAction:  pop     DI DX AX
                ret

ResetAdlib:     cli                             ;This is some really weird
                mov     AL,0b0h                 ;shit...
                mov     BL,0
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                inc     AL
                call    OutValue
                mov     CX,0ffffh               ;Let's wait for ADLIB to react
ResetAdlibDelay:dec     CX                      ;for note-offs
                jnz     ResetAdlibDelay
                xor     AL,AL
                xor     BL,BL
                mov     CX,0f6h
ResetAdlib2:    call    OutValue
                inc     AL
                loop    ResetAdlib2
                mov     AL,01h
                mov     BL,020h
                call    OutValue
                mov     AL,0bdh
                mov     BL,0c0h
                call    OutValue
                sti
                ret

BuildInstrument:pusha
                cmp     AL,NumInstruments
                jae     BuildQuit
                mov     DI,offset Instruments
                xor     AH,AH
                shl     AX,4
                add     DI,AX
                lodsb                           ;Additive Synthesis
                xor     AL,1                    ;Invert the bit
                and     AL,1
                mov     [DI+10],AL
                lodsb                           ;Feedback
                and     AL,7
                shl     AL,1
                or      [DI+10],AL
                lodsb                           ;Mod. Attack
                and     AL,15
                shl     AL,4
                mov     [DI+2],AL
                lodsb                           ;Mod. Decay
                and     AL,15
                or      [DI+2],AL
                lodsb                           ;Mod. Sustain
                and     AL,15
                mov     BL,15
                sub     BL,AL
                shl     BL,4
                mov     [DI+3],BL
                lodsb                           ;Mod. Release
                and     AL,15
                or      [DI+3],AL
                lodsb                           ;Volume
                and     AL,63
                mov     AH,63
                sub     AH,AL
                mov     [DI+1],AH
                lodsb                           ;Level Scale
                and     AL,3
                shl     AL,6
                or      [DI+1],AL
                lodsb                           ;Multiplier
                and     AL,15
                mov     [DI],AL
                lodsb                           ;Waveform
                and     AL,3
                mov     [DI+4],AL
                lodsb                           ;Sustain Sound
                and     AL,1
                shl     AL,5
                or      [DI],AL
                lodsb                           ;Scale Envelope
                and     AL,1
                shl     AL,4
                or      [DI],AL
                lodsb                           ;Pitch Vibr.
                and     AL,1
                shl     AL,6
                or      [DI],AL
                lodsb                           ;Volume Vibr.
                and     AL,1
                shl     AL,7
                or      [DI],AL
                add     DI,5
                lodsb                           ;Car. Attack
                and     AL,15
                shl     AL,4
                mov     [DI+2],AL
                lodsb                           ;Car. Decay
                and     AL,15
                or      [DI+2],AL
                lodsb                           ;Car. Sustain
                and     AL,15
                mov     BL,15
                sub     BL,AL
                shl     BL,4
                mov     [DI+3],BL
                lodsb                           ;Car. Release
                and     AL,15
                or      [DI+3],AL
                lodsb                           ;Volume
                and     AL,63
                mov     AH,63
                sub     AH,AL
                mov     [DI+1],AH
                lodsb                           ;Level Scale
                and     AL,3
                shl     AL,6
                or      [DI+1],AL
                lodsb                           ;Multiplier
                and     AL,15
                mov     [DI],AL
                lodsb                           ;Waveform
                and     AL,3
                mov     [DI+4],AL
                lodsb                           ;Sustain Sound
                and     AL,1
                shl     AL,5
                or      [DI],AL
                lodsb                           ;Scale Envelope
                and     AL,1
                shl     AL,4
                or      [DI],AL
                lodsb                           ;Pitch Vibr.
                and     AL,1
                shl     AL,6
                or      [DI],AL
                lodsb                           ;Volume Vibr.
                and     AL,1
                shl     AL,7
                or      [DI],AL
                sub     DI,5
                lodsb                           ;Pitch shift
                mov     [DI+13],AL
BuildQuit:      popa
                ret

        ;A routine to play a note.
        ;AL=Channel number (0-8)
        ;BL=Instrument number
        ;CX=Frequency (16 units make one halfstep)
        ;DL=Volume (0-63)

PlayNote:       mov     [NoteVolume],DL
                cmp     AL,NumChans
                jae     PlayNoteQuit
                pusha
                push    AX
                xor     AH,AH
                mov     DX,type ChanInfo
                mul     DX
                mov     BP,AX
                add     BP,offset ChanInfos
                mov     DS:[BP.ChanSoundOn],0
                pop     AX
                xor     AH,AH
                mov     SI,AX
                shl     SI,3
                add     SI,AX
                add     SI,AX
                add     SI,AX
                add     SI,AX
                add     SI,AX
                add     SI,offset Regs
                push    AX
                push    CX
                xor     BH,BH
                mov     DI,BX
                shl     DI,4
                add     DI,offset Instruments
                mov     CX,14
                push    BP
PlayNote2:      mov     AL,[DI]
                mov     DS:[BP],AL
                inc     BP
                inc     DI
                loop    PlayNote2
                pop     BP
                mov     AL,[NoteVolume]
                mov     AH,63
                sub     AH,AL
                mov     AL,DS:[BP.ChanOp1Volume]
                and     AL,00111111b
                add     AL,AH
                shr     AL,1
                cmp     AL,63
                jbe     PlayNote_NotOver1
                mov     AL,63
PlayNote_NotOver1:
                mov     CL,DS:[BP.ChanOp1Volume]
                and     CL,11000000b
                or      CL,AL
                mov     DS:[BP.ChanOp1Volume],CL
                mov     AL,DS:[BP.ChanOp2Volume]
                and     AL,00111111b
                add     AL,AH
                shr     AL,1
                cmp     AL,63
                jbe     PlayNote_NotOver2
                mov     AL,63
PlayNote_NotOver2:
                mov     CL,DS:[BP.ChanOp2Volume]
                and     CL,11000000b
                or      CL,AL
                mov     DS:[BP.ChanOp2Volume],CL
PlayNote3:      mov     CX,11
                push    BP
PlayNote4:      lodsb
                mov     BL,DS:[BP]
                call    SmartOutValue
                inc     BP
                loop    PlayNote4
                pop     BP
                pop     CX
                mov     DS:[BP.ChanFreq],CX   ;At the next interrupt the
                mov     DS:[BP.ChanSoundOn],1 ;sound will start
                pop     AX
                popa
PlayNoteQuit:   ret

        ;A routine to stop the playing of one channel.
        ;AL=Channel number (0-8)

NoteOff:        cmp     AL,NumChans
                jae     PlayNoteQuit
                pusha
                push    AX
                xor     AH,AH
                mov     DX,type ChanInfo
                mul     DX
                mov     BP,AX
                add     BP,offset ChanInfos
                pop     AX
                mov     DS:[BP.ChanSoundOn],0
                add     AL,0b0h
                mov     BL,DS:[BP.ChanMSB]
                and     BL,11011111b
                call    SmartOutValue
                popa
                ret

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        ;And here come the pattern datas in a different segment. We'll have
        ;a 96K segment so that any FMC song will surely load!
        ;
        ;Remember to enable 32-bit processing in the linker, and don't care
        ;about the 386-directive. Because of some stupid reason which I
        ;don't know it is needed when defining this large segments.
        ;
        ;Feel free to set the size smaller, according to your needs.

                .386

Song            SEGMENT PARA UNINIT
                db      98304 dup (?)
Song            Ends

                End
