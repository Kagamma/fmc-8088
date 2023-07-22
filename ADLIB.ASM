ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
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

                Extrn   SongChans:Byte
                Extrn   SongSeg:Word
                Extrn   SongIdent:Byte
                Extrn   SongName:Byte
                Extrn   SongOrder:Byte
                Extrn   PiisiDataLoppu:Byte
                Extrn   SongInstruments:Byte
                Extrn   PrintByte:Near

                Public  ResetAdlib
                Public  OutValue
                Public  PlayNote
                Public  NoteOff
                Public  BuildInstrument
                Public  PlayMusic
                Public  InitMusic
                Public  StopMusic

NumInstruments  equ     32
NumChans        equ     9
PattLen         equ     1536/16 ;(8-kanavaiselle patternille)

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

;12:n s„velen f-taajuusarvot siten ett„ itse s„vel on ensimm„isen„ rivill„ ja
;sen j„lkeen tulee 15 v„livaihetta seuraavaan.

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

;Rekisteriarvot yhdeks„„ eri kanavaa varten. Ensin tulee operaattori 1,
;sitten operaattori 2 ja lopuksi yhteiset rekisterit. (13 yht„ kanavaa kohti)

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
PattSeg         dw      0
NoteVolume      db      0
TimeCounter     db      0
Playing         db      0
SongPosition    db      0
PattPosition    db      0
Tempo           db      0
Counter         db      0

ChanInfos       ChanInfo NumChans dup (<>)
GhostRegs       db      256 dup (0)             ;Haamurekisterit arvojen luke-
                                                ;mista varten

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Codeseg
                .8086
                Jumps

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        ;T„m„ rutiini kirjoittaa AL:n m„„r„„m„„n rekisteriin BL:n sis„ll”n.
        ;Tottakai hidas mutta eih„n sille mit„„n voi.

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
                mov     AL,BL       ;Arvo joka laitetaan rekisteriin
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

        ;Žlykk„„mpi versio joka kirjoittaa arvon vain jos se on muuttunut

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
                mov     AL,BL       ;Arvo joka laitetaan rekisteriin
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

        ;T„m„ rutiini resetoi Adlibin sammuttamalla ensin kaikki „„net, odotta-
        ;malla v„h„n ja sitten nollaamalla rekisterit 00-F5.
        ;Lopuksi eri aaltomuodot aktivoidaan kirjoittamalla rekisteri ykk”seen
        ;20h ja rekisteriin BDh laitetaan C0h vibratoiden syvent„miseksi.

ResetAdlib:     cli
                mov     AL,0b0h                 ;Kaikki „„net pois nollaamalla
                mov     BL,0                    ;Frequency MSB
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
                mov     CX,0ffffh               ;Odotetaan ett„ Adlib ehtii
ResetAdlibDelay:dec     CX                      ;reagoida moiseen
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

        ;Rakentaa 16-tavuisen instrumentin 27-tavuisesta. Ideana on ett„
        ;pitempi on helpompi editoida mutta lyhempi sis„lt„„ suoraan arvot jotka
        ;rekistereihin pit„„ laittaa. AL=instrumentin numero ja SI=Pitk„n inst-
        ;rumentin offset.

BuildInstrument:
                pusha86
                cmp     AL,NumInstruments
                jae     BuildQuit               ;Ei aleta korruptoimaan muistia
                mov     DI,offset Instruments
                xor     AH,AH
                shl     AX,4                    ;Kerrotaan 16:lla
                add     DI,AX                   ;Nyt saatu kohdeosoite
                lodsb                           ;Additive Synthesis
                xor     AL,1                    ;K„„nnet„„n bitti
                and     AL,1
                mov     [DI+10],AL              ;Laitetaan kohteeseensa
                lodsb                           ;Feedback
                and     AL,7                    ;Pidet„„n rajoissa
                shl     AL,1                    ;Ylitet„„n nollabitti
                or      [DI+10],AL              ;Yhdistet„„n kohteeseen
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
                mov     AH,63                   ;V„hennet„„n t„ydest„ hiljaisuudesta
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
                mov     AH,63                   ;V„hennet„„n t„ydest„ hiljaisuudesta
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
                lodsb                           ;Taajuuden muutos
                mov     [DI+13],AL
BuildQuit:      popa86
                ret

        ;Soittaa nuotin. AL=kanava,BL=soitin,CX=taajuus ja DL volume. DL:n arvo
        ;nolla t„ytt„ hiljaisuutta. 16 taajuusyksikk”„=1 puolis„velaskel.
        ;Eik”h„n tullut selv„ksi.

PlayNote:       cli
                call    CoolPlayNote
                sti
                ret

CoolPlayNote:   mov     [NoteVolume],DL
                cmp     AL,NumChans
                jae     PlayNoteQuit
                pusha86
                push    AX
                xor     AH,AH
                mov     DX,type ChanInfo
                mul     DX
                mov     BP,AX
                add     BP,offset ChanInfos
                pop     AX
                xor     AH,AH
                mov     SI,AX
                shl     SI,3            ;Kerrotaan kahdeksalla
                add     SI,AX           ;Ja lis„t„„n viisi kertaa,
                add     SI,AX           ;saadaan 13
                add     SI,AX
                add     SI,AX
                add     SI,AX
                add     SI,offset Regs
                push    AX
                push    CX
                xor     BH,BH
                mov     DI,BX
                shl     DI,4            ;Kerrotaan 16:ll„
                add     DI,offset Instruments ;Saadaan soitinten osoite
                mov     CX,14           ;Kopioidaan 14 arvoa soitindatasta
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
PlayNote4:      lodsb                           ;Otetaan rekisterinumero
                mov     BL,DS:[BP]
                call    SmartOutValue           ;Pelataan varman p„„lle
                inc     BP
                loop    PlayNote4
                pop     BP
                pop     CX
                mov     DS:[BP.ChanFreq],CX ;Taajuus talteen
                mov     DS:[BP.ChanSoundOn],1
                pop     AX                  ;Mutta annetaan seuraavan keskey-
                popa86                        ;tyksen hoitaa saundin p„„lle-
PlayNoteQuit:   ret                         ;laitto.

NoteOff:        cmp     AL,NumChans
                jae     PlayNoteQuit
                pusha86
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
                popa86
                ret

InitMusic:      mov     [Playing],0
                cli
                mov     [SongPosition],AL
                dec     [SongPosition]
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
                mov     [PattPosition],63
                mov     [Tempo],6
                mov     [Counter],5
                mov     [Playing],1
                sti
                ret

StopMusic:      mov     [Playing],0
                cli
                mov     CX,8
                xor     AL,AL
StopMusic2:     call    NoteOff                 ;Kaikki kanavat pois
                inc     AL
                loop    StopMusic2
                mov     CX,11h
                mov     AL,40h
                mov     BL,3fh                  ;Volumet nollaksi
StopMusic3:     call    OutValue
                inc     AL
                loop    StopMusic3
                mov     AL,53h                  ;Ja viel„ pari lis„„
                call    OutValue
                inc     AL
                call    OutValue
                sti
                ret

        ;P„ivitt„„ „„ni„ (kutsutaan 5 krt./vertical retrace)

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
                mov     [SI.ChanSoundOn],2      ;Seuraava vaihe:arvot voi
                add     AL,0b0h                 ;asettaa
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
                call    CoolPlayNote
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
PlayMusic2:     cmp     [SI.ChanSoundOn],0
                je      PlayMusicNext
PlayMusic4:     mov     AL,[SI.ChanAddValue]
                cbw
                add     [SI.ChanFreq],AX
                cmp     [SI.ChanFreq],0
                jge     PlayMusic5
                mov     [SI.ChanFreq],0
PlayMusic5:     mov     DI,SI
                pusha86
                mov     AX,[SI.ChanFreq]
                cwd
                mov     BX,192
                idiv    BX              ;Nyt DX=nuotti ja AX=oktaavi
                and     AL,7
                shl     AL,2
                mov     SI,DX
                shl     SI,1
                add     SI,offset Freqs
                mov     BX,[SI]
                shr     BX,8            ;Alatavu pois
                or      AL,BL           ;MSB ja oktaavi AL:ss„
                mov     CL,AL           ;Siirret„„n CL:„„n
                mov     AL,DS:[BP+11]
                mov     BL,[SI]         ;LSB
                mov     [DI.ChanLSB],BL
                call    SmartOutValue
                add     AL,010h
                mov     BL,CL           ;MSB
                cmp     [DI.ChanSoundOn],1
                jne     NotOn
                or      BL,20h          ;Kanava p„„lle-bitti
NotOn:          mov     [DI.ChanMSB],BL
                call    SmartOutValue
                popa86
PlayMusicNext:  add     SI,type ChanInfo
                add     BP,13
                dec     CX
                jne     PlayMusic2
PlayMusic_NewNotes:
                cmp     [Playing],1
                jne     PlayMusic_AllDone
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
                cmp     byte ptr [SI],255               ;Onko alussakin looppi
                je      PlayMusic_StopPlay              ;Siisp„ lopetetaan
PlayMusic_NoRepeat:                                     ;musiikin r„nkytys
                mov     AL,[SI]
                mov     BX,PattLen
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
                cmp     AL,04h    ;Tango Vibrato...
                je      PlayMusic_Vibrato
                cmp     AL,05h
                je      PlayMusic_Release
                cmp     AL,0eh    ;Nuotintoistoefektit
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
                ret

PlayMusic_Release:
                cmp     [SI.ChanSoundOn],3
                je      PlayMusic_EffectsNext
                mov     [SI.ChanSoundOn],4
                jmp     PlayMusic_EffectsNext

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
                je      PlayMusic_EffectsNext   ;Kohdetaajuus jo saavutettu
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
                mov     [SI.ChanSoundOn],2      ;Jos volume vaihdetaan kesken
                jmp     PlayMusic_EffectsNext   ;nuotin, pakotetaan p„„llelait-
                                                ;torutiini toimimaan uudestaan!
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
                mov     [SI.ChanToneDir],-1      ;Alas
                jmp     PlayMusic_NoNote
PlayMusic_ToneUp:
                mov     [SI.ChanToneDir],1       ;Yl”s
                jmp     PlayMusic_NoNote

PlayMusic_StopPlay:
                mov     [Playing],0
PlayMusic_AllDone:
                ret

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                End
