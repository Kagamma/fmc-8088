;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³F.M.C. - nimi puhuu puolestaan!!!                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
                Stack   800h

NumInstr        Equ     32

                Extrn   ResetAdlib:Near
                Extrn   PlayNote:Near
                Extrn   OutValue:Near
                Extrn   NoteOff:Near
                Extrn   BuildInstrument:Near
                Extrn   InstallTimer:Near
                Extrn   RemoveTimer:Near
                Extrn   InitDisplay:Near
                Extrn   ClearScreen:Near
                Extrn   PrintText:Near
                Extrn   PrintBox:Near
                Extrn   CursorOn:Near
                Extrn   CursorOff:Near
                Extrn   CursorXY:Near
                Extrn   FillArea:Near
                Extrn   PrintByte:Near
                Extrn   PrintWord:Near
                Extrn   Input:Near
                Extrn   LoadFile:Near
                Extrn   SaveFile:Near
                Extrn   GetLength:Near
                Extrn   Escape:Byte
                Extrn   InitMusic:Near
                Extrn   StopMusic:Near
                Extrn   FileSelector:Near

                Public  SongIdent
                Public  SongName
                Public  SongChans
                Public  SongOrder
                Public  PiisiDataLoppu
                Public  SongSeg
                Public  SongInstruments
                Public  ReadKey

PattLen         equ     1536/16 ;(8-kanavaiselle patternille)

Instrument      Struc

I_Synthtype     db      0
I_Feedback      db      0
I_ModAttack     db      0
I_ModDecay      db      0
I_ModSustain    db      0
I_ModRelease    db      0
I_ModVolume     db      0
I_ModLevelScale db      0
I_ModMultiplier db      0
I_ModWaveform   db      0
I_ModSustSound  db      0
I_ModScaleEnv   db      0
I_ModPitchVibr  db      0
I_ModVolVibr    db      0
I_CarAttack     db      0
I_CarDecay      db      0
I_CarSustain    db      0
I_CarRelease    db      0
I_CarVolume     db      0
I_CarLevelScale db      0
I_CarMultiplier db      0
I_CarWaveform   db      0
I_CarSustSound  db      0
I_CarScaleEnv   db      0
I_CarPitchVibr  db      0
I_CarVolVibr    db      0
I_PitchShift    db      0
I_Name          db      20 dup (32)
I_EndZero       db      0

Instrument      Ends

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Dataseg

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

WText           db      'STACK CORRUPTION ERROR! This shit ain''t working yet...'
                db      13,10,'$'

SongSeg         dw      seg Song
StartDrive      db      0
ToRoot          db      '\',0
StartDir        db      65 dup (0)
DirBuffer       db      65 dup (0)
Notename        db      'C-0',0
Notenames       db      'C-C#D-D#E-F-F#G-G#A-A#H-'
ExtraNumber     db      '0',0
Yes             db      'Yes',0
No              db      'No ',0
HexEditData     db      '00',0,'11',1,'22',2,'33',3,'44',4,'55',5,'66',6,'77',7,'88',8,'99',9,'aA',10,'bB',11,'cC',12,'dD',13,'eE',14,'fF',15
InstrFileName   db      '                              ',0
SongFileName    db      '                              ',0
InstrPathName   db      '                              ',0
SongPathName    db      '                              ',0
InstrFilter     db      '*.INS       ',0
SongFilter      db      '*.SNG       ',0
Channel9        db      32h,52h,72h,92h,0f2h,35h,55h,75h,95h,0f5h,0c8h,0a8h,0b8h
PianoKeys       db      2ch,1
                db      1fh,2
                db      2dh,3
                db      20h,4
                db      2eh,5
                db      2fh,6
                db      22h,7
                db      30h,8
                db      23h,9
                db      31h,10
                db      24h,11
                db      32h,12
                db      33h,13
                db      26h,14
                db      34h,15
                db      27h,16
                db      10h,13
                db      03h,14
                db      11h,15
                db      04h,16
                db      12h,17
                db      13h,18
                db      06h,19
                db      14h,20
                db      07h,21
                db      15h,22
                db      08h,23
                db      16h,24
                db      17h,25
                db      0ah,26
                db      18h,27
                db      0bh,28
                db      19h,29
                db      1ah,30
                db      '!',255

        ;Seuraa todella kryptinen osuus: Ilmaisee miss„ j„rjestyksess„ ja miten
        ;instrumentin arvot piirret„„n n„yt”lle, ja miten niit„ voi editoida.
        ;Formaatti:
        ;0 Sarake
        ;1 Rivi
        ;2 Nimi (15 merkki„+loppunolla)
        ;18 Byte vai YES/NO (0=Byte 1=Y/N)
        ;19 Maksimiarvo (and-operaatio...)
        ;20 Offsetti instrumenttidatassa
        ;21 Mihin kursori yl”s siirt„„
        ;22 Mihin kursori alas siirt„„
        ;23 Mihin kursori vas. siirt„„
        ;24 Mihin kursori oik. siirt„„
        ;25 seuraava...

EditPoints      Equ     27

InstrEditData   db       7,4,'     Freq. Mod:',0,1,1,offset I_SynthType,0,3,0,1
                db      26,4,'      Feedback:',0,0,7,offset I_FeedBack,1,15,0,2
                db      44,4,'   Pitch Shift:',0,0,255,offset I_PitchShift,2,2,1,2
                db       7,7,'        Attack:',0,0,15,offset I_ModAttack,0,4,3,15
                db       7,8,'         Decay:',0,0,15,offset I_ModDecay,3,5,4,16
                db       7,9,'       Sustain:',0,0,15,offset I_ModSustain,4,6,5,17
                db      7,10,'       Release:',0,0,15,offset I_ModRelease,5,7,6,18
                db      7,11,'        Volume:',0,0,63,offset I_ModVolume,6,8,7,19
                db      7,12,'   Level scale:',0,0,3,offset I_ModLevelScale,7,9,8,20
                db      7,13,'    Multiplier:',0,0,15,offset I_ModMultiplier,8,10,9,21
                db      7,14,'      Waveform:',0,0,3,offset I_ModWaveform,9,11,10,22
                db      7,15,' Sustain Sound:',0,1,1,offset I_ModSustSound,10,12,11,23
                db      7,16,'Scale Envelope:',0,1,1,offset I_ModScaleEnv,11,13,12,24
                db      7,17,' Pitch Vibrato:',0,1,1,offset I_ModPitchVibr,12,14,13,25
                db      7,18,'Volume Vibrato:',0,1,1,offset I_ModVolVibr,13,15,14,26
                db      26,7,'        Attack:',0,0,15,offset I_CarAttack,14,16,3,15
                db      26,8,'         Decay:',0,0,15,offset I_CarDecay,15,17,4,16
                db      26,9,'       Sustain:',0,0,15,offset I_CarSustain,16,18,5,17
                db     26,10,'       Release:',0,0,15,offset I_CarRelease,17,19,6,18
                db     26,11,'        Volume:',0,0,63,offset I_CarVolume,18,20,7,19
                db     26,12,'   Level scale:',0,0,3,offset I_CarLevelScale,19,21,8,20
                db     26,13,'    Multiplier:',0,0,15,offset I_CarMultiplier,20,22,9,21
                db     26,14,'      Waveform:',0,0,3,offset I_CarWaveform,21,23,10,22
                db     26,15,' Sustain Sound:',0,1,1,offset I_CarSustSound,22,24,11,23
                db     26,16,'Scale Envelope:',0,1,1,offset I_CarScaleEnv,23,25,12,24
                db     26,17,' Pitch Vibrato:',0,1,1,offset I_CarPitchVibr,24,26,13,25
                db     26,18,'Volume Vibrato:',0,1,1,offset I_CarVolVibr,25,26,14,26

        ;Songieditorin muuttujia

CurrentPos      db      0
ViewPos         db      0
SubScreen       db      0
SongColumn      db      0
PosAdd          db      0
CurrentPattern  db      0
CurrentChan     db      0
CurrentPattLine db      0
CurrentPattView db      0
CurrentPattCol  db      0
WorkOctave      db      3
PianoTone       db      0
EditMode        db      1
RepeatText      db      'R ',0
EndText         db      'H ',0
BlankChan       db      '        ',0
EditOn          db      'EDIT',0
EditOff         db      '    ',0
PlayOn          db      0
Handle          dw      0
PatternCopyBuf  db      1536 dup (0)

        ;Soundieditorin muuttujia

TestTone        dw      4*192   ;C-4
CurrentInstr    db      0
CurrentEditPoint db     0
CurrentColumn   db      0

TitleText       db      '-* Faust Music Creator V1.3 *-',0
LoppuText       db      'Thank you for using FMC.',13,10,13,10,"$"

Below           db      '[F1] Song/Pattern Editor [F2] Instrument Editor [ESC] Exit FMC',0
Quitmessage1    db      'Do You Really Wish To Quit? [Y to confirm]',0
Quitmessage2    db      'Unsaved Song Will Be Lost. Quit Anyway? [Y to confirm]',0
Loadmessage1    db      'Unsaved Song Will Be Lost. Load Anyway? [Y to confirm]',0
LoadInstrPrompt db      'Load Instrument',0
SaveInstrPrompt db      'Save Instrument',0
LoadSongPrompt  db      'Load Song',0
SaveSongPrompt  db      'Save Song',0

KillPrompt      db      'Kill Menu: [1] Kill Song [2] Kill Instruments [3] Kill ''Em All [ESC] Cancel',0

SCR1            db      'SONG EDIT  ',0
SCR2            db      'INSTR. EDIT',0
SCR1P           db      'PATT. EDIT ',0

S1_Text1        db      ' SONG DATA    ',0
S1_Text2        db      ' PATTERN DATA ',0
S1_Text5        db      'Song name:                                                    SPECIAL COMMANDS:',0
S1_Text3        db      ' Position:                                                    [R] For Repeat   ',0
S1_Text4        db      '  Pattern:                                                    [H] For Halt     ',0
S1_Text6        db      'Pattern:',0
S1_Text7        db      'Instr:',0
S1_Text8        db      'Octave:',0

S2_Text1        db      'Instrument number:',0
S2_Text2        db      'Instrument name:',0
S2_Text3        db      'Test tone:',0
S2_Text4        db      '    MODULATOR    ',0
S2_Text5        db      '     CARRIER     ',0

S2_I1           db      '[L] Load [<] Previous [SPC] Test [+] Test Tone Up   [T] Type Name',0
S2_I2           db      '[S] Save [>] Next     [CR] Quiet [-] Test Tone Down [X] Exchg. Car/Mod',0
S1_I1           db      '[TAB] Pattern  [INS] Ins Pos. [L] Load [T] Type Songname [<] Add Chan.',0
S1_I2           db      '[F10] Kill op. [DEL] Del Pos. [S] Save [SPC] Play/Stop   [>] Sub Chan.',0
S1_I3           db      '[TAB] Song     [INS-DEL] I/D Line [<>] Instr.sel [F3-F5] Cut/Copy/Paste [KEYPAD]',0
S1_I4           db      '[F10] Kill op. [CR] Edit Mode     [+-] Patt.sel  [F7-F8] Tr. Down/Up     Octave',0

Screen          db      0               ;L„hdemme songiruudusta
Unsaved         db      0
SpareIdent      db      '    '          ;Latausta varten

        ;T„st„ alkaa itse piisidata

SongIdent       db      'FMC!'
SongName        db      '                    ',0
SongChans       db      8
SongOrder       db      256 dup (0)
PiisiDataLoppu  dw      6606h

SongInstruments     Instrument NumInstr dup (<>)
EndSong         dw      6606h

                Evendata

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Codeseg

                .8086
                Jumps

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Start:          mov     AX,Seg TitleText
                mov     DS,AX
                mov     AX,0305h                ;N„pp„imist” hurjan nopeaksi
                mov     BL,0004h                ;ettei editoidessa kyll„sty
                int     16h
                mov     AX,1900h                ;Aloituslevyasema
                int     21h
                mov     [StartDrive],AL
                mov     AX,4700h
                mov     SI,offset StartDir
                xor     DL,DL
                int     21h                     ;Aloitushakemisto
                mov     DX,offset SongPathName
                call    GetPath
                mov     DX,offset InstrPathName
                call    GetPath
                call    ResetAdlib
                call    InstallTimer
                call    InitDisplay
                call    ClearPatterns
                jmp     SetupScreen1

MainLoop:       call    ReadKey
                cmp     AH,3bh
                je      SetupScreen1
                cmp     AH,3ch
                je      SetupScreen2
                cmp     AH,1                    ;ESC?
                je      CheckQuit
                cmp     [Screen],1
                je      InstrEditor
                cmp     AL,' '
                je      ToggleMusic
                cmp     AL,13
                je      ToggleEdit
                cmp     AH,44h
                je      KillMenu
                cmp     AL,9
                je      SubScreenSwap
                cmp     [SubScreen],1
                je      PatternEditor
                cmp     AX,5600h
                je      PatternCut
                cmp     AX,5700h
                je      PatternCopy
                cmp     AX,5800h
                je      PatternPaste
                cmp     AL,'l'
                je      LoadSong
                cmp     AL,'L'
                je      LoadSong
                cmp     AL,'s'
                je      SaveSong
                cmp     AL,'S'
                je      SaveSong
                cmp     AH,52h
                je      SongInsert
                cmp     AH,53h
                je      SongDelete
                cmp     AL,'-'
                je      PrevPattern
                cmp     AL,'+'
                je      NextPattern
                cmp     AL,'<'
                je      SongSubChan
                cmp     AL,'>'
                je      SongAddChan
                cmp     AL,'R'
                je      SongRepeat
                cmp     AL,'r'
                je      SongRepeat
                cmp     AL,'H'
                je      SongEnd
                cmp     AL,'h'
                je      SongEnd
                cmp     AL,'T'
                je      SongNameEdit
                cmp     AL,'t'
                je      SongNameEdit
                cmp     AX,4b00h
                je      SongMoveLeft
                cmp     AX,4d00h
                je      SongMoveRight
                cmp     AX,4900h
                je      SongMoveLeft2
                cmp     AX,5100h
                je      SongMoveRight2
                cmp     AX,4700h
                je      SongToStart
                cmp     AX,4f00h
                je      SongToEnd
                mov     CX,16
                mov     BX,offset HexEditData
HexSearch2:     cmp     AL,[BX]
                je      SongHexFound2
                inc     BX
                cmp     AL,[BX]
                je      SongHexFound
                add     BX,2
                dec     CX
                jnz     HexSearch2
                jmp     MainLoop
SongHexFound2:  inc     BX
SongHexFound:   inc     BX
                mov     AL,[BX]
                mov     [Unsaved],1
                xor     BH,BH
                mov     DI,offset SongOrder
                mov     BL,[CurrentPos]
                add     DI,BX
                cmp     [SongColumn],1
                jne     TheOther
                and     byte ptr [DI],11110000b
                or      [DI],AL
                and     byte ptr [DI],63
                call    SongCursRight
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop
TheOther:       shl     AL,4
                and     byte ptr [DI],1111b
                or      [DI],AL
                and     byte ptr [DI],63
                call    SongCursRight
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

ToggleMusic:    xor     [PlayOn],1
                cmp     [PlayOn],1
                je      ToggleMusic2
                call    StopMusic
                jmp     MainLoop
ToggleMusic2:   mov     AL,[CurrentPos]
                call    InitMusic
                jmp     EditQuiet

ToggleEdit:     xor     [EditMode],1
                call    UpdatePattern
                jmp     MainLoop

LoadSong:       cmp     [Unsaved],1
                jne     OKtoLoad
                mov     DX,offset LoadMessage1
                call    PrintMessage
                call    ReadKey
                push    AX
                call    ClearMessage
                pop     AX
                cmp     AL,'y'
                je      OKtoLoad
                cmp     AL,'Y'
                je      OKtoLoad
                jmp     MainLoop
OKtoLoad:
                mov     AX,offset LoadSongPrompt
                mov     BX,offset SongFilter
                mov     CX,offset SongPathName
                mov     DX,offset SongFileName
                call    FileSelector

                cmp     [Escape],1
                je      SongLoadQuit
                cmp     [SongFileName],32
                je      SongLoadQuit

                mov     AX,3d00h                ;Yritet„„n avausta
                int     21h
                jc      SongLoadQuit            ;Ei suostunut avautumaan
                mov     [Handle],AX
                mov     BX,AX
                mov     DX,offset SpareIdent
                mov     CX,4
                mov     AX,3f00h                ;Luetaan 4 tavua =
                int     21h                     ;tunnistuskoodi
                jc      SongLoadQuit2
                cmp     [SpareIdent],'F'
                jne     SongLoadQuit2
                cmp     [SpareIdent+1],'M'
                jne     SongLoadQuit2
                cmp     [SpareIdent+2],'C'
                jne     SongLoadQuit2
                cmp     [SpareIdent+3],'!'
                jne     SongLoadQuit2
                pusha86
                call    StopMusic
                mov     [PlayOn],0
                call    ClearPatterns
                popa86
                mov     DX,offset SongName
                mov     CX,offset EndSong-offset SongName
                mov     AX,3f00h
                int     21h
                jc      SongLoadQuit2
                xor     DH,DH
                mov     DL,[SongChans]
                xor     CH,CH
                mov     CL,[SongChans]
                shl     DX,7                    ;x128
                shl     CX,6                    ;x64
                add     CX,DX                   ;CX sis„lt„„ patternin pituuden
                mov     BP,seg Song
                mov     DS,BP                   ;Aloitetaan patternien lataus
LoadPatterns:   xor     DX,DX
                mov     AX,3f00h
                int     21h
                cmp     AX,0
                je      PatternsReady
                add     BP,96
                mov     DS,BP
                jmp     LoadPatterns
PatternsReady:  mov     AX,seg Songname
                mov     DS,AX                   ;Segmentti takaisin
                mov     [UnSaved],0
SongLoadQuit2:  mov     BX,[Handle]
                mov     AX,3e00h
                int     21h
                call    UpdateSong
                call    UpdatePattern
                call    InitMusic               ;T„ll„ nopealla kutsusarjalla
                call    StopMusic               ;uudelleenrakennetaan muuttu-
SongLoadQuit:   call    ClearMessage            ;neet instrumentit
                call    UpdateCursor
                jmp     MainLoop

SaveSong:
                mov     AX,offset SaveSongPrompt
                mov     BX,offset SongFilter
                mov     CX,offset SongPathName
                mov     DX,offset SongFileName
                call    FileSelector

                cmp     [Escape],1
                je      SongSaveQuit
                cmp     [SongFileName],32
                je      SongSaveQuit

                xor     CX,CX                   ;Attribuutit nollaksi
                mov     AX,3c00h                ;Yritet„„n luontia
                int     21h
                jc      SongSaveQuit            ;Ei suostunut avautumaan
                mov     [Handle],AX
                mov     BX,AX
                mov     DX,offset SongIdent
                mov     CX,offset EndSong-offset SongIdent
                mov     AX,4000h                ;Kirjoitetaan patternij„rjestys,
                int     21h                     ;instrumentit ja 666
                jc      SongSaveQuit2
                xor     AX,AX                   ;AX:n lasketaan suurin patt.
                mov     DI,offset SongOrder
                mov     CX,256
SeekHighestPatt:cmp     byte ptr [DI],255
                je      SHPskip
                cmp     byte ptr [DI],254
                je      SHPskip
                cmp     [DI],AL
                jbe     SHPskip
                mov     AL,[DI]                 ;Uusi suurin l”ydetty
SHPskip:        inc     DI
                loop    SeekHighestPatt
                inc     AX                      ;Lis„t„„n yksi
                mov     SI,AX                   ;Siirret„„n laskuri SI-
                xor     DH,DH                   ;rekisteriin
                mov     DL,[SongChans]
                xor     CH,CH
                mov     CL,[SongChans]
                shl     DX,7                    ;x128
                shl     CX,6                    ;x64
                add     CX,DX                   ;CX sis„lt„„ patternin pituuden
                mov     BP,seg Song
                mov     DS,BP                   ;Aloitetaan patternien talletus
SavePatterns:   xor     DX,DX
                mov     AX,4000h
                int     21h
                add     BP,96
                mov     DS,BP
                dec     SI
                jnz     SavePatterns
PatternsReady1: mov     AX,seg Songname
                mov     DS,AX                   ;Segmentti takaisin
                mov     [UnSaved],0
SongSaveQuit2:  mov     BX,[Handle]
                mov     AX,3e00h
                int     21h
SongSaveQuit:   call    ClearMessage
                call    UpdateCursor
                jmp     MainLoop

SongAddChan:    inc     [SongChans]
                cmp     [SongChans],9
                jne     SongChanOK
                mov     [SongChans],8
SongChanOK:     call    UpdatePattern
                jmp     MainLoop

SongSubChan:    dec     [SongChans]
                mov     [CurrentChan],0
                cmp     [SongChans],0
                jne     SongChanOK
                mov     [SongChans],1
                jmp     SongChanOK

SongRepeat:     mov     [Unsaved],1
                xor     BH,BH
                mov     DI,offset SongOrder
                mov     BL,[CurrentPos]
                add     DI,BX
                mov     byte ptr [DI],255
                call    SongCursRight
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop
SongEnd:        mov     [Unsaved],1
                xor     BH,BH
                mov     DI,offset SongOrder
                mov     BL,[CurrentPos]
                add     DI,BX
                mov     byte ptr [DI],254
                call    SongCursRight
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

SongInsert:     mov     DI,offset SongOrder+254
                mov     CX,255
                sub     CL,[CurrentPos]
                jz      SongInsert2
SongInsertLoop: mov     AL,[DI]
                mov     [DI+1],AL
                dec     DI
                loop    SongInsertLoop
SongInsert2:    mov     DI,offset SongOrder
                xor     AH,AH
                mov     AL,[CurrentPos]
                add     DI,AX
                mov     byte ptr [DI],0
                call    UpdateSong
                call    PattUnderCursor
                mov     [Unsaved],1
                jmp     MainLoop

SongDelete:     mov     DI,offset SongOrder
                xor     AH,AH
                mov     AL,[CurrentPos]
                add     DI,AX
                mov     CX,255
                sub     CL,AL
                jz      SongDelete2
SongDeleteLoop: mov     AL,[DI+1]
                mov     [DI],AL
                inc     DI
                loop    SongDeleteLoop
SongDelete2:    mov     byte ptr [SongOrder+255],0
                call    UpdateSong
                call    PattUnderCursor
                mov     [Unsaved],1
                jmp     MainLoop

SongNameEdit:   mov     DX,offset SongName
                mov     CL,15
                mov     AL,10
                mov     BL,5
                call    Input
                call    UpdateCursor
                mov     [Unsaved],1
                jmp     MainLoop

SongMoveLeft2:  call    SongCursLeft
                call    SongCursLeft
                call    SongCursLeft
                call    SongCursLeft
                call    SongCursLeft
                call    SongCursLeft
                call    SongCursLeft
                call    SongCursLeft
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

SongMoveRight2: call    SongCursRight
                call    SongCursRight
                call    SongCursRight
                call    SongCursRight
                call    SongCursRight
                call    SongCursRight
                call    SongCursRight
                call    SongCursRight
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

SongToStart:    mov     [ViewPos],0
                mov     [SongColumn],0
                mov     [CurrentPos],0
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

SongToEnd:      mov     [ViewPos],240
                mov     [SongColumn],1
                mov     [CurrentPos],255
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

SongMoveLeft:   call    SongCursLeft
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

SongMoveRight:  call    SongCursRight
                call    UpdateSong
                call    UpdateCursor
                call    PattUnderCursor
                jmp     MainLoop

PattUnderCursor:xor     AH,AH
                mov     AL,[CurrentPos]
                mov     SI,offset SongOrder
                add     SI,AX
                mov     AL,[SI]
                cmp     AL,63
                jbe     PattUC2
                mov     AL,0
PattUC2:        mov     [CurrentPattern],AL
                call    UpdatePattern
                ret

SongCursLeft:   dec     [SongColumn]
                cmp     [SongColumn],-1
                jne     SongCursLeft2
                mov     [SongColumn],1
                dec     [CurrentPos]
                cmp     [CurrentPos],-1
                jne     SongCursLeft2
                mov     [CurrentPos],0
                mov     [SongColumn],0
SongCursLeft2:  mov     AL,[CurrentPos]
                cmp     [ViewPos],AL
                jbe     SongCursLeft3
                mov     [ViewPos],AL
SongCursLeft3:  ret
SongCursRight:  inc     [SongColumn]
                cmp     [SongColumn],2
                jne     SongCursRight2
                mov     [SongColumn],0
                inc     [CurrentPos]
                cmp     [CurrentPos],0
                jne     SongCursRight2
                mov     [CurrentPos],255
                mov     [SongColumn],1
SongCursRight2: mov     AL,[CurrentPos]
                sub     AL,[ViewPos]
                cmp     AL,16
                jb      SongCursRight3
                inc     [ViewPos]
SongCursRight3: ret

KillMenu:       mov     DX,offset KillPrompt
                call    PrintMessage
KillMenuLoop:   call    ReadKey
                cmp     AL,'1'
                je      Kill1
                cmp     AL,'2'
                je      Kill2
                cmp     AL,'3'
                je      Kill3
                cmp     AH,1
                je      KillEnd
                jmp     KillMenuLoop
Kill1:          call    ClearSong
                call    ClearPatterns
KillEnd:        call    ClearMessage
                call    UpdateSong
                call    UpdatePattern
                call    UpdateCursor
                jmp     MainLoop
Kill2:          call    ClearInstruments
                jmp     KillEnd
Kill3:          call    ClearSong
                call    ClearPatterns
                call    ClearInstruments
                mov     [UnSaved],0
                jmp     KillEnd

SubScreenSwap:  xor     [SubScreen],1
                jmp     SetUpScreen1

PatternEditor:  cmp     AL,'>'
                je      NextIns
                cmp     AL,'<'
                je      PrevIns
                cmp     AL,'-'
                je      PrevPattern
                cmp     AL,'+'
                je      NextPattern
                cmp     AX,5230h
                je      Octave0
                cmp     AX,4f31h
                je      Octave1
                cmp     AX,5032h
                je      Octave2
                cmp     AX,5133h
                je      Octave3
                cmp     AX,4b34h
                je      Octave4
                cmp     AX,4c35h
                je      Octave5
                cmp     AX,4d36h
                je      Octave6
                cmp     AH,52h
                je      PattInsert
                cmp     AH,53h
                je      PattDelete
                cmp     AX,4200h
                je      TransUp
                cmp     AX,4100h
                je      TransDown
                cmp     AX,5600h
                je      PatternCut
                cmp     AX,5700h
                je      PatternCopy
                cmp     AX,5800h
                je      PatternPaste
                cmp     AX,3d00h
                je      ChanCut
                cmp     AX,3e00h
                je      ChanCopy
                cmp     AX,3f00h
                je      ChanPaste
                cmp     AH,48h
                je      PattMoveUp
                cmp     AH,50h
                je      PattMoveDown
                cmp     AH,4bh
                je      PattMoveLeft
                cmp     AH,4dh
                je      PattMoveRight
                cmp     AH,49h
                je      PattPageUp
                cmp     AH,51h
                je      PattPageDown
                cmp     AH,47h
                je      PattStart
                cmp     AH,4fh
                je      PattEnd
                cmp     [CurrentPattCol],1
                je      InstrMSB
                ja      HexEdit
                cmp     [CurrentPattCol],0
                jne     MainLoop
                cmp     AH,0eh
                je      PianoClear
                mov     SI,offset Pianokeys
PianoSearch:    cmp     byte ptr [SI],'!'
                je      MainLoop
                cmp     byte ptr [SI],AH
                je      PianoFound
                add     SI,2
                jmp     PianoSearch
PianoFound:     mov     AL,[SI+1]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                add     AL,[WorkOctave]
                cmp     AL,96
                ja      MainLoop
                mov     [PianoTone],AL
                cmp     [EditMode],0
                je      JustPlay
                mov     [UnSaved],1
                push    AX
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,PattLen
                mul     BX
                add     AX,seg Song
                mov     ES,AX                   ;Oikea patterni haettu
                xor     AH,AH
                mov     AL,[CurrentChan]
                mov     BX,192
                mul     BX
                mov     DI,AX
                xor     DH,DH
                mov     DL,[CurrentPattLine]
                add     DI,DX
                add     DI,DX
                add     DI,DX
                pop     AX
                mov     ES:[DI],AL
                mov     AL,[CurrentInstr]
                shr     AL,4
                shl     AL,7
                or      ES:[DI],AL
                and     byte ptr ES:[DI+1],00001111b
                mov     AL,[CurrentInstr]
                shl     AL,4
                or      ES:[DI+1],AL
                call    PattCursDown
                call    UpdatePattern
                call    UpdateCursor
JustPlay:       call    EditPlay
                jmp     MainLoop
PianoClear:     xor     AH,AH
                cmp     [EditMode],0
                je      JustPlay2
                mov     AL,[CurrentPattern]
                mov     BX,PattLen
                mul     BX
                add     AX,seg Song
                mov     ES,AX                   ;Oikea patterni haettu
                xor     AH,AH
                mov     AL,[CurrentChan]
                mov     BX,192
                mul     BX
                mov     DI,AX
                xor     DH,DH
                mov     DL,[CurrentPattLine]
                add     DI,DX
                add     DI,DX
                add     DI,DX
                mov     byte ptr ES:[DI],0
                and     byte ptr ES:[DI+1],00001111b
                call    PattCursDown
                call    UpdatePattern
                call    UpdateCursor
JustPlay2:      jmp     EditQuiet

HexEdit:        mov     CX,16
                mov     BX,offset HexEditData
HexSearch3:     cmp     AL,[BX]
                je      PattHexFound2
                inc     BX
                cmp     AL,[BX]
                je      PattHexFound
                add     BX,2
                dec     CX
                jnz     HexSearch3
                jmp     MainLoop
PattHexFound2:  inc     BX
PattHexFound:   inc     BX
                mov     AL,[BX]
                push    AX
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,PattLen
                mul     BX
                add     AX,seg Song
                mov     ES,AX                   ;Oikea patterni haettu
                xor     AH,AH
                mov     AL,[CurrentChan]
                mov     BX,192
                mul     BX
                mov     DI,AX
                xor     DH,DH
                mov     DL,[CurrentPattLine]
                add     DI,DX
                add     DI,DX
                add     DI,DX
                pop     AX
                cmp     [CurrentPattCol],2
                je      Digit0
                cmp     [CurrentPattCol],3
                je      Digit1
                cmp     [CurrentPattCol],4
                je      Digit2
                cmp     [CurrentPattCol],5
                je      Digit3
                jmp     MainLoop
Digit0:         and     byte ptr ES:[DI+1],00001111b
                shl     AL,4
                or      ES:[DI+1],AL
DigitOK:        call    PattCursDown
                call    UpdatePattern
                call    UpdateCursor
                jmp     MainLoop
Digit1:         and     byte ptr ES:[DI+1],11110000b
                or      ES:[DI+1],AL
                jmp     DigitOK
Digit2:         and     byte ptr ES:[DI+2],00001111b
                shl     AL,4
                or      ES:[DI+2],AL
                jmp     DigitOK
Digit3:         and     byte ptr ES:[DI+2],11110000b
                or      ES:[DI+2],AL
                jmp     DigitOK

InstrMSB:       mov     BL,0
                cmp     AL,'0'
                je      InstrMSBFound
                cmp     AL,'1'
                jne     MainLoop
                mov     BL,1
InstrMSBFound:  push    BX
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,PattLen
                mul     BX
                add     AX,seg Song
                mov     ES,AX                   ;Oikea patterni haettu
                xor     AH,AH
                mov     AL,[CurrentChan]
                mov     BX,192
                mul     BX
                mov     DI,AX
                xor     DH,DH
                mov     DL,[CurrentPattLine]
                add     DI,DX
                add     DI,DX
                add     DI,DX
                pop     BX
                shl     BL,7
                and     byte ptr ES:[DI],127
                or      ES:[DI],BL
                call    PattCursDown
                call    UpdatePattern
                call    UpdateCursor
                jmp     MainLoop

Octave0:        mov     [WorkOctave],0
                call    UpdatePattern
                jmp     MainLoop
Octave1:        mov     [WorkOctave],1
                call    UpdatePattern
                jmp     MainLoop
Octave2:        mov     [WorkOctave],2
                call    UpdatePattern
                jmp     MainLoop
Octave3:        mov     [WorkOctave],3
                call    UpdatePattern
                jmp     MainLoop
Octave4:        mov     [WorkOctave],4
                call    UpdatePattern
                jmp     MainLoop
Octave5:        mov     [WorkOctave],5
                call    UpdatePattern
                jmp     MainLoop
Octave6:        mov     [WorkOctave],6
                call    UpdatePattern
                jmp     MainLoop

PattInsert:     xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattLine]
                add     SI,AX
                add     SI,AX
                add     SI,AX
                mov     BP,SI
                xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                add     SI,186
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     BL,[CurrentPattLine]
                mov     DS,AX
                mov     CX,63
                sub     CL,BL
                jz      PattInsertQuit
PattInsert2:    mov     AL,[SI]
                mov     AH,[SI+1]
                mov     BL,[SI+2]
                mov     [SI+3],AL
                mov     [SI+4],AH
                mov     [SI+5],BL
                sub     SI,3
                loop    PattInsert2
PattInsertQuit: mov     SI,BP
                mov     byte ptr [SI],0
                mov     byte ptr [SI+1],0
                mov     byte ptr [SI+2],0
                mov     AX,seg Songname
                mov     DS,AX
                call    UpdatePattern
                jmp     MainLoop

PattDelete:     xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattLine]
                mov     BP,SI
                add     SI,AX
                add     SI,AX
                add     SI,AX
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     BL,[CurrentPattLine]
                mov     DS,AX
                mov     CX,63
                sub     CL,BL
                jz      PattDeleteQuit
PattDelete2:    mov     AL,[SI+3]
                mov     AH,[SI+4]
                mov     BL,[SI+5]
                mov     [SI],AL
                mov     [SI+1],AH
                mov     [SI+2],BL
                add     SI,3
                loop    PattDelete2
PattDeleteQuit: mov     SI,BP
                mov     byte ptr [SI+189],0
                mov     byte ptr [SI+190],0
                mov     byte ptr [SI+191],0
                mov     AX,seg Songname
                mov     DS,AX
                call    UpdatePattern
                jmp     MainLoop

TransUp:        xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     DS,AX
                mov     CX,64
TransUp2:       mov     AL,[SI]
                and     AL,127
                cmp     AL,0
                je      TransUp4
                inc     AL
                cmp     AL,96
                jb      TransUp3
                mov     AL,96
TransUp3:       and     byte ptr [SI],10000000b
                or      [SI],AL
TransUp4:       add     SI,3
                loop    TransUp2
                mov     AX,seg SongName
                mov     DS,AX
                call    UpdatePattern
                jmp     MainLoop

TransDown:      xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     DS,AX
                mov     CX,64
TransDown2:     mov     AL,[SI]
                and     AL,127
                cmp     AL,0
                je      TransDown4
                dec     AL
                cmp     AL,0
                ja      TransDown3
                mov     AL,1
TransDown3:     and     byte ptr [SI],10000000b
                or      [SI],AL
TransDown4:     add     SI,3
                loop    TransDown2
                mov     AX,seg SongName
                mov     DS,AX
                call    UpdatePattern
                jmp     MainLoop

PatternCut:     xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     DS,AX
                mov     AX,seg Songname
                mov     ES,AX
                mov     DI,offset PatternCopyBuf
                mov     CX,1536
                mov     SI,0
PatternCut1:    movsb
                mov     byte ptr [SI-1],0
                loop    PatternCut1
                mov     AX,seg Songname
                mov     DS,AX
                call    UpdatePattern
                mov     [UnSaved],1
                jmp     MainLoop

PatternCopy:    xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     DS,AX
                mov     AX,seg Songname
                mov     ES,AX
                mov     DI,offset PatternCopyBuf
                mov     CX,1536
                mov     SI,0
PatternCopy1:   movsb
                loop    PatternCopy1
                mov     AX,seg Songname
                mov     DS,AX
                jmp     MainLoop

PatternPaste:   xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     ES,AX
                mov     SI,offset PatternCopyBuf
                mov     CX,1536
                mov     DI,0
PatternPaste1:  movsb
                loop    PatternPaste1
                call    UpdatePattern
                mov     [UnSaved],1
                jmp     MainLoop

ChanCut:        xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     DS,AX
                mov     AX,seg Songname
                mov     ES,AX
                mov     DI,offset PatternCopyBuf
                mov     CX,192
ChanCut1:       movsb
                mov     byte ptr [SI-1],0
                loop    ChanCut1
                mov     AX,seg Songname
                mov     DS,AX
                call    UpdatePattern
                mov     [UnSaved],1
                jmp     MainLoop

ChanCopy:       xor     AH,AH
                mov     AL,[CurrentChan]
                mov     SI,AX
                shl     AX,7            ;x128
                shl     SI,6            ;x64
                add     SI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     DS,AX
                mov     AX,seg Songname
                mov     ES,AX
                mov     DI,offset PatternCopyBuf
                mov     CX,192
ChanCopy1:      movsb
                loop    ChanCopy1
                mov     AX,seg Songname
                mov     DS,AX
                jmp     MainLoop

ChanPaste:      xor     AH,AH
                mov     AL,[CurrentChan]
                mov     DI,AX
                shl     AX,7            ;x128
                shl     DI,6            ;x64
                add     DI,AX           ;x192
                xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,96
                mul     BX
                add     AX,seg Song
                mov     ES,AX
                mov     SI,offset PatternCopyBuf
                mov     CX,192
ChanPaste1:     movsb
                loop    ChanPaste1
                call    UpdatePattern
                mov     [UnSaved],1
                jmp     MainLoop

PattPageDown:   call    PattCursDown
                call    PattCursDown
                call    PattCursDown
PattMoveDown:   call    PattCursDown
                jmp     PattOK
PattPageUp:     call    PattCursUp
                call    PattCursUp
                call    PattCursUp
PattMoveUp:     call    PattCursUp
                jmp     PattOK
PattMoveRight:  call    PattCursRight
                jmp     PattOK
PattMoveLeft:   call    PattCursLeft
                jmp     PattOK
PattStart:      call    PattOver2
                jmp     PattOK
PattEnd:        call    PattOver1
                jmp     PattOK

PattCursUp:     dec     [CurrentPattLine]
                cmp     [CurrentPattLine],-1
                je      PattOver1
                mov     AL,[CurrentPattLine]
                cmp     [CurrentPattView],AL
                jb      MoveQuit
                mov     [CurrentPattView],AL
                jmp     MoveQuit
PattOver1:      mov     [CurrentPattLine],63
                mov     [CurrentPattView],55
                jmp     MoveQuit
PattCursDown:   inc     [CurrentPattLine]
                cmp     [CurrentPattLine],64
                je      PattOver2
                mov     AL,[CurrentPattLine]
                sub     AL,[CurrentPattView]
                cmp     AL,9
                jb      MoveQuit
                inc     [CurrentPattView]
                jmp     MoveQuit
PattOver2:      mov     [CurrentPattLine],0
                mov     [CurrentPattView],0
                jmp     MoveQuit
PattCursRight:  inc     [CurrentPattCol]
                cmp     [CurrentPattCol],6
                jne     MoveQuit
                mov     [CurrentPattCol],0
                inc     [CurrentChan]
                mov     AL,[SongChans]
                cmp     [CurrentChan],AL
                jb      MoveQuit
                mov     [CurrentChan],0
                jmp     MoveQuit
PattCursLeft:   dec     [CurrentPattCol]
                cmp     [CurrentPattCol],-1
                jne     MoveQuit
                mov     [CurrentPattCol],5
                dec     [CurrentChan]
                cmp     [CurrentChan],-1
                jne     MoveQuit
                mov     AL,[SongChans]
                dec     AL
                mov     [CurrentChan],AL
MoveQuit:       ret

PrevPattern:    dec     [CurrentPattern]
                cmp     [CurrentPattern],-1
                jne     PattOK
                mov     [CurrentPattern],0
PattOK:         call    UpdatePattern
                call    UpdateCursor
                jmp     MainLoop
NextPattern:    inc     [CurrentPattern]
                cmp     [CurrentPattern],64
                jne     PattOK
                mov     [CurrentPattern],63
                jmp     PattOK
NextIns:        inc     [CurrentInstr]
                cmp     [CurrentInstr],32
                jne     PattOK
                mov     [CurrentInstr],31
                jmp     PattOK
PrevIns:        dec     [CurrentInstr]
                cmp     [CurrentInstr],-1
                jne     PattOK
                mov     [CurrentInstr],0
                jmp     PattOK
InstrEditor:    call    InstrUpdateCurs
                cmp     AH,48h
                je      InstrCursUp
                cmp     AH,50h
                je      InstrCursDown
                cmp     AH,4bh
                je      InstrCursLeft
                cmp     AH,4dh
                je      InstrCursRight
                cmp     AL,'T'
                je      EnterInstrName
                cmp     AL,'t'
                je      EnterInstrName
                cmp     AL,'<'
                je      PrevInstr
                cmp     AL,'>'
                je      NextInstr
                cmp     AL,'-'
                je      ToneDown
                cmp     AL,'+'
                je      ToneUp
                cmp     AL,'Y'
                je      EditYes
                cmp     AL,'y'
                je      EditYes
                cmp     AL,'N'
                je      EditNo
                cmp     AL,'n'
                je      EditNo
                cmp     AL,' '
                je      EditTest
                cmp     AL,13
                je      EditQuiet
                cmp     AL,'L'
                je      LoadInstr
                cmp     AL,'l'
                je      LoadInstr
                cmp     AL,'S'
                je      SaveInstr
                cmp     AL,'s'
                je      SaveInstr
                cmp     AL,'X'
                je      SwapCarMod
                cmp     AL,'x'
                je      SwapCarMod

        ;Heksaeditointirutiini

                cmp     byte ptr [SI+18],0
                jne     MainLoop
                mov     CX,16
                mov     BX,offset HexEditData
HexSearch:      cmp     AL,[BX]
                je      InstrHexFound2
                inc     BX
                cmp     AL,[BX]
                je      InstrHexFound
                add     BX,2
                dec     CX
                jnz     HexSearch
                jmp     MainLoop
InstrHexFound2: inc     BX
InstrHexFound:  inc     BX
                mov     AL,[BX]
                push    AX
                mov     DI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     DI,AX
                add     DI,BX
                xor     AH,AH
                mov     AL,[SI+20]
                add     DI,AX
                pop     AX
                mov     [Unsaved],1
                cmp     [CurrentColumn],1
                je      InstrLowerDigit
                and     byte ptr [DI],00001111b
                shl     AL,4
                or      [DI],AL
                mov     [CurrentColumn],1
                jmp     EditYesNotOver
InstrLowerDigit:and     byte ptr [DI],11110000b
                or      [DI],AL
                mov     [CurrentColumn],0
                inc     [CurrentEditPoint]
                cmp     [CurrentEditPoint],27
                jne     EditYesNotOver
                mov     [CurrentEditPoint],26
                jmp     EditYesNotOver

LoadInstr:
                mov     AX,offset LoadInstrPrompt
                mov     BX,offset InstrFilter
                mov     CX,offset InstrPathName
                mov     DX,offset InstrFileName
                call    FileSelector

                cmp     [Escape],1
                je      LoadTooBig
                cmp     [InstrFileName],32
                je      LoadTooBig
                call    GetLength
                cmp     DX,0
                jne     LoadTooBig
                cmp     AX,48
                ja      LoadTooBig
                mov     DX,offset InstrFileName
                mov     BP,DS
                mov     DI,offset SongInstruments
                mov     AL,[CurrentInstr]
                xor     AH,AH
                mov     BX,AX
                shl     AX,4
                shl     BX,5
                add     DI,AX
                add     DI,BX
                call    LoadFile
                mov     [UnSaved],1
LoadTooBig:     call    ClearMessage
                call    RedrawInstrument
                call    InstrUpdateCurs
                jmp     MainLoop

SaveInstr:
                mov     AX,offset SaveInstrPrompt
                mov     BX,offset InstrFilter
                mov     CX,offset InstrPathName
                mov     DX,offset InstrFileName
                call    FileSelector

                cmp     [Escape],1
                je      LoadTooBig
                cmp     [InstrFileName],32
                je      LoadTooBig
                mov     BP,DS
                mov     DI,offset SongInstruments
                mov     AL,[CurrentInstr]
                xor     AH,AH
                mov     BX,AX
                shl     AX,4
                shl     BX,5
                add     DI,AX
                add     DI,BX
                mov     CX,48
                call    SaveFile
                call    ClearMessage
                call    InstrUpdateCurs
                jmp     MainLoop

SwapCarMod:     mov     DI,offset SongInstruments
                mov     AL,[CurrentInstr]
                xor     AH,AH
                mov     BX,AX
                shl     AX,4
                shl     BX,5
                add     DI,AX
                add     DI,BX
                mov     SI,DI
                add     SI,offset I_ModAttack
                add     DI,offset I_CarAttack
                mov     CX,12
SwapCarMod2:    mov     AL,[SI]
                mov     BL,[DI]
                mov     [SI],BL
                mov     [DI],AL
                inc     SI
                inc     DI
                loop    SwapCarMod2
                call    RedrawInstrument
                jmp     MainLoop

EditQuiet:      mov     AL,8
                call    NoteOff
                cli
                mov     AL,52h
                mov     BL,3fh                  ;Volume nollaksi
                call    OutValue
                mov     AL,55h
                mov     BL,3fh                  ;Volume nollaksi
                call    OutValue
                sti
                jmp     MainLoop

EditPlay:       mov     SI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     SI,AX
                add     SI,BX
                mov     AL,[CurrentInstr]
                call    BuildInstrument
                mov     AL,8
                call    NoteOff
                mov     CX,0ffffh
DelayLoop2:     dec     CX
                jnz     DelayLoop2
                mov     AL,8
                mov     BL,[CurrentInstr]
                xor     CH,CH
                mov     CL,[PianoTone]
                dec     CL
                shl     CX,4
                mov     DL,63
                call    PlayNote
                ret

EditTest:       mov     SI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     SI,AX
                add     SI,BX
                mov     AL,[CurrentInstr]
                call    BuildInstrument
                mov     AL,8
                call    NoteOff
                mov     CX,0ffffh
DelayLoop:      dec     CX
                jnz     DelayLoop
                mov     AL,8
                mov     BL,[CurrentInstr]
                mov     CX,[TestTone]
                mov     DL,63
                call    PlayNote
                jmp     MainLoop

EditYes:        cmp     byte ptr [SI+18],1
                jne     MainLoop
                mov     [Unsaved],1
                mov     DI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     DI,AX
                add     DI,BX
                xor     AH,AH
                mov     AL,[SI+20]
                add     DI,AX
                mov     byte ptr [DI],1
                inc     [CurrentEditPoint]
                cmp     [CurrentEditPoint],27
                jne     EditYesNotOver
                mov     [CurrentEditPoint],26
EditYesNotOver: mov     AL,[SI+19]
                cmp     [DI],AL                 ;Varmistetaan rajat
                jbe     NotOver
                mov     [DI],AL
NotOver:        call    InstrUpdateCurs
                call    RedrawInstrument
                mov     SI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     SI,AX
                add     SI,BX
                mov     AL,[CurrentInstr]
                call    BuildInstrument
                jmp     MainLoop

EditNo:         cmp     byte ptr [SI+18],1
                jne     MainLoop
                mov     [Unsaved],1
                mov     DI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     DI,AX
                add     DI,BX
                xor     AH,AH
                mov     AL,[SI+20]
                add     DI,AX
                mov     byte ptr [DI],0
                inc     [CurrentEditPoint]
                cmp     [CurrentEditPoint],27
                jne     EditYesNotOver
                mov     [CurrentEditPoint],26
                jmp     EditYesNotOver

InstrCursUp:    mov     AL,[SI+21]
                mov     [CurrentEditPoint],AL
                call    InstrUpdateCurs
                jmp     MainLoop
InstrCursDown:  mov     AL,[SI+22]
                mov     [CurrentEditPoint],AL
                call    InstrUpdateCurs
                jmp     MainLoop
InstrCursLeft:  cmp     byte ptr [SI+18],0
                jne     LeftSimple
                dec     [CurrentColumn]
                cmp     [CurrentColumn],-1
                jne     InstrCursReady
                mov     [CurrentColumn],1
LeftSimple:     mov     BL,[CurrentEditPoint]
                mov     AL,[SI+23]
                cmp     BL,AL
                jne     LeftSimple2
                mov     [CurrentColumn],0
LeftSimple2:    mov     [CurrentEditPoint],AL
InstrCursReady: call    InstrUpdateCurs
                jmp     MainLoop
InstrCursRight: cmp     byte ptr [SI+18],0
                jne     RightSimple
                inc     [CurrentColumn]
                cmp     [CurrentColumn],2
                jne     InstrCursReady
                mov     [CurrentColumn],0
RightSimple:    mov     BL,[CurrentEditPoint]
                mov     AL,[SI+24]
                cmp     BL,AL
                jne     RightSimple2
                mov     [CurrentColumn],1
RightSimple2:   mov     [CurrentEditPoint],AL
                jmp     InstrCursReady

InstrUpdateCurs:push    AX
                mov     SI,Offset InstrEditData
                mov     AL,[CurrentEditPoint]
                mov     BL,25
                mul     BL
                add     SI,AX
                mov     AL,[SI]
                mov     BL,[SI+1]
                add     AL,15
                cmp     byte ptr [SI+18],1
                jne     InstrCurs2
                mov     [CurrentColumn],0
InstrCurs2:     add     AL,[CurrentColumn]
                call    CursorXY
                call    CursorOn
                pop     AX
                ret

ToneDown:       cmp     [TestTone],0
                je      ToneDown2
                sub     [TestTone],16
                call    RedrawInstrument
ToneDown2:      jmp     MainLoop

ToneUp:         cmp     [TestTone],1520
                je      ToneDown2
                add     [TestTone],16
                call    RedrawInstrument
                jmp     MainLoop

PrevInstr:      dec     [CurrentInstr]
                cmp     [CurrentInstr],-1
                jne     PrevInstr2
                mov     [CurrentInstr],0
PrevInstr2:     call    RedrawInstrument
                jmp     MainLoop

NextInstr:      inc     [CurrentInstr]
                cmp     [CurrentInstr],NumInstr
                jb      Nextinstr2
                mov     [CurrentInstr],NumInstr-1
NextInstr2:     call    RedrawInstrument
                jmp     MainLoop

EnterInstrName: mov     DX,offset SongInstruments
                mov     [Unsaved],1
                xor     AH,AH
                mov     AL,[CurrentInstr]
                mov     BX,AX
                shl     BX,5
                shl     AX,4
                add     DX,BX
                add     DX,AX
                add     DX,offset I_Name
                mov     AL,41
                mov     BL,3
                mov     CL,15
                call    Input
                call    InstrUpdateCurs
                jmp     MainLoop

SetupScreen1:   mov     [Screen],0
                call    RedrawScreen
                call    UpdateCursor
                jmp     MainLoop

SetupScreen2:   mov     [Screen],1
                call    RedrawScreen
                mov     SI,Offset InstrEditData
                mov     AL,[CurrentEditPoint]
                mov     BL,25
                mul     BL
                add     SI,AX
                mov     AL,[SI]
                mov     BL,[SI+1]
                add     AL,15
                call    CursorXY
                call    CursorOn
                jmp     MainLoop

RedrawScreen:   call    TitleBar
                cmp     [Screen],0
                jne     RedrawScreen2
                mov     AL,0
                mov     BL,0
                mov     CL,10
                mov     DX,offset SCR1
                cmp     [SubScreen],1
                jne     RedrawScreen3
                mov     DX,offset SCR1P
RedrawScreen3:  call    PrintText
                mov     AL,0
                mov     BL,3
                mov     CL,4eh
                mov     DX,offset S1_Text1
                call    PrintBox
                add     BL,2
                mov     CL,13
                mov     DX,offset S1_Text5
                call    PrintText
                inc     BL
                mov     DX,offset S1_Text3
                call    PrintText
                inc     BL
                mov     DX,offset S1_Text4
                call    PrintText
                mov     BL,9
                mov     CL,4eh
                mov     DX,offset S1_Text2
                call    PrintBox
                mov     AL,15
                mov     CL,13
                mov     DX,offset S1_Text6
                call    PrintText
                mov     AL,26
                mov     DX,offset S1_Text7
                call    PrintText
                mov     AL,62
                mov     DX,offset S1_Text8
                call    PrintText
                call    UpdateSong
                call    UpdatePattern
                cmp     [SubScreen],0
                jne     SubScreen2
                mov     AL,0
                mov     CL,10
                mov     BL,21
                mov     DX,offset S1_I1
                call    PrintText
                inc     BL
                mov     DX,offset S1_I2
                call    PrintText
                ret
SubScreen2:     mov     AL,0
                mov     CL,10
                mov     BL,21
                mov     DX,offset S1_I3
                call    PrintText
                inc     BL
                mov     DX,offset S1_I4
                call    PrintText
                ret

UpdateCursor:   cmp     [SubScreen],1
                je      PattCursor
                mov     BL,7
                mov     AL,10
                add     AL,[SongColumn]
                xor     DX,DX
                add     DL,[CurrentPos]
                sub     DL,[ViewPos]
                cmp     DL,15
                ja      NoCursor
                xor     DX,DX
                add     DL,[CurrentPos]
                add     DL,[CurrentPos]
                add     DL,[CurrentPos]
                sub     DL,[ViewPos]
                sub     DL,[ViewPos]
                sub     DL,[ViewPos]
                add     AL,DL
                call    CursorXY
                call    CursorOn
                ret
PattCursor:     mov     BL,11
                add     BL,[CurrentPattLine]
                sub     BL,[CurrentPattView]
                mov     AL,[CurrentPattCol]
                cmp     AL,0
                je      PattCursor2
                add     AL,2
PattCursor2:    add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,[CurrentChan]
                add     AL,3
                call    CursorXY
                call    CursorOn
                ret
NoCursor:       call    CursorOff
                ret

RedrawScreen2:  mov     AL,0
                mov     BL,0
                mov     CL,10
                mov     DX,offset SCR2
                call    PrintText
                mov     BL,21
                mov     DX,offset S2_I1
                call    PrintText
                inc     BL
                mov     DX,offset S2_I2
                call    PrintText
                mov     AL,7
                mov     BL,6
                mov     CL,4eh
                mov     DX,offset S2_Text4
                call    PrintBox
                mov     AL,26
                mov     DX,offset S2_Text5
                call    PrintBox
                call    RedrawInstrument
                ret

UpdatePattern:  mov     AL,23
                mov     BL,9
                mov     CL,15
                mov     DL,[CurrentPattern]
                call    PrintByte
                mov     AL,32
                mov     DL,[CurrentInstr]
                call    PrintByte
                mov     AL,35
                xor     DX,DX
                mov     DL,[CurrentInstr]
                mov     CX,DX
                shl     DX,5
                shl     CX,4
                add     DX,CX
                add     DX,offset SongInstruments+offset I_Name
                mov     CL,15
                call    PrintText
                mov     AL,69
                mov     DL,[WorkOctave]
                call    PrintByte
                mov     AL,57
                mov     DX,offset EditOff
                cmp     [EditMode],1
                jne     NoEditMode
                mov     DX,offset EditOn
NoEditMode:     call    PrintText
                cmp     [CurrentPattView],55
                jbe     UpdatePattern2
                mov     [CurrentPattView],55
UpdatePattern2: xor     AH,AH
                mov     AL,[CurrentPattern]
                mov     BX,PattLen
                mul     BX
                add     AX,seg Song
                mov     ES,AX                   ;Oikea patterni haettu
                xor     DI,DI
                xor     AH,AH
                mov     AL,[CurrentPattView]
                add     DI,AX
                add     DI,AX
                add     DI,AX                   ;Aloitusrivi haettu
                mov     BP,1                    ;Kanavalaskuri
                mov     [PosAdd],0
UpdatePLoop1:   push    DI
                mov     CX,9                    ;9 rivi„
                xor     AH,AH
                mov     AL,[CurrentPattView]
                mov     SI,AX                   ;SI sis„lt„„ rivinumeron
                mov     BL,11                   ;Aloitusrivi
UpdatePLoop2:   push    CX                      ;Rivilaskuri talteen
                mov     AL,0
                mov     CL,15
                mov     DX,SI
                call    PrintByte
                mov     byte ptr [NoteName],'-'         ;Oletuksena tyhj„                mov     byte ptr [NoteName+1],'-'
                mov     byte ptr [NoteName+1],'-'       ;nuottipaikka
                mov     byte ptr [NoteName+2],'-'
                xor     AH,AH
                mov     AL,[SongChans]
                cmp     BP,AX
                jbe     OKToPrint
                mov     DX,offset BlankChan
                mov     AL,3
                add     AL,[PosAdd]
                call    PrintText
                jmp     SlotDone
OKToPrint:      mov     AL,ES:[DI]              ;Nuotti
                and     AL,127                  ;Maskataan instrumentin 5-bitti
                xor     AH,AH                   ;pois
                cmp     AL,0
                je      NoNote
                dec     AL
                shl     AX,4                    ;Saadaan taajuusarvo
                call    Note
NoNote:         mov     AL,3
                add     AL,[PosAdd]
                mov     DX,offset NoteName
                mov     CL,13
                call    PrintText
                mov     [ExtraNumber],'0'
                mov     DL,ES:[DI]              ;Nuotti uudestaan
                and     DL,128                  ;Instrumentin 5-bitti
                jz      Not16
                mov     [ExtraNumber],'1'
Not16:          mov     AL,6
                add     AL,[PosAdd]
                mov     CL,15
                mov     DX,offset ExtraNumber
                call    PrintText
                mov     AL,7
                add     AL,[PosAdd]
                mov     DX,ES:[DI+1]
                xchg    DL,DH
                call    PrintWord
SlotDone:       inc     BL
                inc     SI
                add     DI,3
                pop     CX
                dec     CX
                jnz     UpdatePloop2
                add     [PosAdd],9
                pop     DI
                add     DI,192
                inc     BP
                cmp     BP,9
                jne     UpdatePloop1
                ret

UpdateSong:     mov     DX,offset Songname
                mov     CL,15
                mov     BL,5
                mov     AL,10
                call    PrintText
                cmp     [ViewPos],240
                jbe     UpdateSong2
                mov     [ViewPos],240
UpdateSong2:    mov     DL,[ViewPos]
                inc     BL
                mov     BP,16
UpdateSongLoop1:call    PrintByte
                add     AL,3
                inc     DL
                dec     BP
                jnz     UpdateSongLoop1
                mov     AL,10
                inc     BL
                mov     SI,offset SongOrder
                xor     DH,DH
                mov     DL,[ViewPos]
                add     SI,DX
                mov     BP,16
UpdateSongLoop2:mov     DL,[SI]
                cmp     DL,255
                je      UpdateSongRepeat
                cmp     DL,254
                je      UpdateSongEnd
                call    PrintByte
                add     AL,3
                inc     SI
                dec     BP
                jnz     UpdateSongLoop2
                ret
UpdateSongRepeat:
                mov     DX,offset RepeatText
                call    PrintText
                add     AL,3
                inc     SI
                dec     BP
                jnz     UpdateSongLoop2
                ret
UpdateSongEnd:  mov     DX,offset EndText
                call    PrintText
                add     AL,3
                inc     SI
                dec     BP
                jnz     UpdateSongLoop2
                ret

RedrawInstrument:
                mov     SI,offset SongInstruments
                mov     AL,[CurrentInstr]
                mov     BL,[CurrentInstr]
                xor     AH,AH
                xor     BH,BH
                shl     AX,5
                shl     BX,4
                add     SI,AX
                add     SI,BX
                mov     AL,[CurrentInstr]
                call    BuildInstrument
                mov     AL,4
                mov     BL,3
                mov     CL,13
                mov     DX,offset S2_Text1
                call    PrintText
                add     AL,21
                mov     DX,offset S2_Text2
                call    PrintText
                mov     AL,67
                mov     BL,19
                mov     DX,offset S2_Text3
                call    PrintText
                mov     DL,[CurrentInstr]
                mov     AL,22
                mov     BL,3
                mov     CL,15
                call    PrintByte
                mov     DX,offset SongInstruments
                xor     AH,AH
                mov     AL,[CurrentInstr]
                mov     BX,AX
                shl     AX,5            ;x 32
                shl     BX,4            ;x 16, yht. x 48
                add     DX,AX
                add     DX,BX
                add     DX,offset I_Name
                mov     AL,41
                mov     BL,3
                mov     CL,15
                call    PrintText
                mov     AX,[TestTone]
                call    Note
                mov     AL,77
                mov     BL,19
                mov     CL,15
                mov     DX,offset NoteName
                call    PrintText
                mov     BP,EditPoints
                mov     SI,Offset InstrEditData
                mov     DI,Offset SongInstruments
                xor     AH,AH
                mov     AL,[CurrentInstr]
                mov     BX,AX
                shl     BX,5
                shl     AX,4
                add     DI,BX
                add     DI,AX
RInstrLoop:     mov     AL,[SI]                 ;Sarake ja rivi
                mov     BL,[SI+1]
                mov     CL,13
                mov     DX,SI
                add     DX,2
                call    PrintText
                push    DI
                xor     DH,DH
                mov     DL,[SI+20]
                add     DI,DX
                mov     DL,[DI]                 ;Parametri instrumenttidatasta
                pop     DI
                cmp     byte ptr [SI+18],0
                jne     YesNoShit
                add     AL,15
                mov     CL,15
                call    PrintByte
                add     SI,25
                dec     BP
                jnz     RInstrLoop
                ret
YesNoShit:      add     AL,15
                mov     CL,15
                cmp     DL,1
                je      YesShit
                mov     DX,offset No
                call    PrintText
                add     SI,25
                dec     BP
                jnz     RInstrLoop
                ret
YesShit:        mov     DX,offset Yes
                call    PrintText
                add     SI,25
                dec     BP
                jnz     RInstrLoop
                ret

        ;AL = Patternin numero

ClearPattern:   pusha86
                cmp     AL,63
                ja      ClearPattern2
                xor     AH,AH
                mov     BX,seg Song
                mov     CX,96
                mul     CX
                add     BX,AX
                mov     ES,BX
                mov     CX,768
                xor     DI,DI
                xor     AX,AX
                rep     stosw
ClearPattern2:  popa86
                ret

ClearPatterns:  xor     AL,AL
                mov     CX,64
ClearPatterns2: call    ClearPattern
                inc     AL
                loop    ClearPatterns2
                ret

ClearInstruments:mov    DI,offset SongInstruments
                mov     CX,NumInstr
                mov     AX,DS
                mov     ES,AX
ClearInstruments2:mov     AX,0
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosb
                mov     AX,2020h
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                mov     AL,0
                stosb
                loop    ClearInstruments2
                ret

ClearSong:      mov     DI,offset SongName
                push    DS
                pop     ES
                mov     CX,20
                mov     AL,32
                rep     stosb
                mov     DI,offset SongOrder
                mov     AL,0
                mov     CX,256
                rep     stosb
                ret

CheckQuit:      mov     DX,offset QuitMessage1
                cmp     [UnSaved],1
                jne     CheckQuit2
                mov     DX,offset QuitMessage2
CheckQuit2:     call    PrintMessage
                call    ReadKey
                call    ClearMessage
                cmp     AL,'y'
                je      Exit
                cmp     AL,'Y'
                je      Exit
                jmp     MainLoop

TitleBar:       call    ClearScreen
                call    CursorOff
                mov     AL,0
                mov     AH,80
                mov     BL,0
                mov     BH,1
                mov     CL,01h
                call    FillArea
                mov     AL,25
                mov     BL,0
                mov     CL,0fh
                mov     DX,offset TitleText
                call    PrintText
                mov     AL,9
                mov     BL,1
                mov     CL,0eh
                mov     DX,offset Below
                call    PrintText
                ret

ClearMessage:   pusha86
                mov     AL,0
                mov     BL,24
                mov     AH,80
                mov     BH,1
                mov     CL,0
                call    FillArea
                popa86
                ret

PrintMessage:   pusha86
                mov     AL,0
                mov     BL,24
                mov     AH,80
                mov     BH,1
                mov     CL,0
                call    FillArea
                mov     CL,2
                call    PrintText
                popa86
                ret

WaitKey:        push    AX
                xor     AH,AH
                int     16h
                pop     AX
                ret

ReadKey:        xor     AH,AH
                int     16h               ;AL = Ascii-koodi, AH = Scankoodi
                ret

        ;AX=taajuus

Note:           pusha86
                cwd
                mov     BX,192                  ;Jaetaan oktaavilla
                idiv    BX
                add     AL,'0'
                mov     [Notename+2],AL         ;Kirjoitetaan oktaavinumero
                shr     DX,4                    ;Jaetaan taajuus 16:lla nuotin
                shl     DX,1                    ;saamiseksi
                mov     SI,DX
                add     SI,offset Notenames
                mov     AL,[SI]
                mov     [Notename],AL
                mov     AL,[SI+1]
                mov     [Notename+1],AL
                popa86
                ret

GetPath:        push    DX
                mov     AX,4700h
                mov     SI,offset DirBuffer
                xor     DL,DL
                int     21h
                mov     AX,1900h
                int     21h
                add     AL,'A'
                pop     DI
                mov     [DI],AL
                mov     byte ptr [DI+1],':'
                mov     byte ptr [DI+2],'\'
                add     DI,3
                mov     SI,offset DirBuffer
GetPathLoop:    cmp     byte ptr [DI],0
                je      GetPathEnd
                cmp     byte ptr [SI],' '
                je      GetPathSpace
                cmp     byte ptr [SI],0
                je      GetPathSpace
                lodsb
                mov     [DI],AL
                inc     DI
                jmp     GetPathLoop
GetPathEnd:     ret
GetPathSpace:   mov     byte ptr [DI],32
                inc     DI
                cmp     byte ptr [DI],0
                jne     GetPathSpace
                ret

Exit:           call    InitDisplay
                mov     AX,SP
                cmp     AX,0800h
                je      STACKOK
                mov     DX,offset WText
                mov     AX,0900h
                int     21h
                mov     AL,30
                mov     BL,0
                mov     CL,14
                mov     DX,SP
                call    PrintWord
STACKOK:
                call    RemoveTimer
                call    ResetAdlib
                mov     AX,0e00h
                mov     DL,[StartDrive]
                int     21h
                mov     AX,3b00h
                mov     DX,offset ToRoot
                int     21h
                mov     AX,3b00h
                mov     DX,offset StartDir
                int     21h
                mov     AX,0900h
                mov     DX,offset LoppuText
                int     21h
                mov     AX,4c00h
                int     21h

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;                .386

Song            Segment Para Public UnInit
                db      4096 dup (?)
Song            Ends

                End     Start
