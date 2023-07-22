;ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
;ｳFAUST Input/Output System!!!                                                 ｳ
;ｳ                                                                             ｳ
;ｳSis・tт rutiinit tekstiruudun manipulointiin, tekstin tulostukseen ja in-   ｳ
;ｳputtaukseen ja kaikkeen muuhunkin hassuun. Kиtetтn loistavassa FMC - eli   ｳ
;ｳFaust Music Creator - ohjelmassa.                                            ｳ
;ｳ                                                                             ｳ
;ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
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

                Public  InitDisplay
                Public  ClearScreen
                Public  PrintText
                Public  PrintBox
                Public  CursorOn
                Public  CursorOff
                Public  CursorXY
                Public  FillArea
                Public  PrintByte
                Public  PrintWord
                Public  Input
                Public  Escape
                Public  FileSelector

                Extrn   ReadKey:Near

Entry           Struc

Entry_Name      db      14 dup (32)
Entry_Zero      db      0
Entry_Type      db      0

Entry           Ends

ﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄ

                Dataseg

ﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄ

MaxDirEntry     equ     256

Parent          db      '..',0
ToRoot          db      '\',0

DirBuffer       db      65 dup (0)
TemporaryDir    db      65 dup (0)

                EvenData

OldDTAseg       dw      0
OldDTAoffset    dw      0
SelectorNameOffset dw   0
FilterOffset    dw      0
PathOffset      dw      0
FileNameOffset  dw      0
InputPosition   dw      0
TextRow         db      0
TextColumn      db      0
TextColor       db      0
Escape          db      0
Tab             db      0
SpecialInput    db      0
DirView         dw      0
DirSelect       dw      0
DirEntries      dw      0

FilterText      db      'FILT:',0
NameText        db      'NAME:',0
PathText        db      'PATH:',0

HexWord         db      '0000',0
HexStrip        db      '0123456789ABCDEF'
FilterAll       db      '*.*',0

OurDTA          db      128 dup (0)
InternalBuffer  db      4000 dup (0)
DirTable        Entry   MaxDirEntry dup (<>)

                Evendata

ﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄ

                Codeseg
                .8086
                Jumps

ﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄ

        ;InitDisplay - varmistaa ett・ollaan 80x25-tilassa.
        ;Ei parametrej・

InitDisplay:    mov     AX,3h
                int     10h
                ret

        ;ClearScreen - tyhjentт ruudun mustaksi.
        ;Ei parametrej・

ClearScreen:    push    ES
                push    0b800h
                pop     ES
                pusha86
                xor     DI,DI
                mov     AX,0
                mov     CX,2000
                rep     stosw                   ;Koko nиtt・tyhj・si
                popa86
                pop     ES
                ret

SaveScreen:     push    DS
                push    DS
                pop     ES
                push    0b800h
                pop     DS
                xor     SI,SI
                mov     DI,offset InternalBuffer
                mov     CX,2000
                rep     movsw
                pop     DS
                ret

RestoreScreen:  push    0b800h
                pop     ES
                xor     DI,DI
                mov     SI,offset InternalBuffer
                mov     CX,2000
                rep     movsw
                ret

        ;FileSelector - aktivoi tiedostonvalintalaatikon.
        ;AX - Offset nimelle laatikon ylвeunaan
        ;BX - Offset "suodattimelle"
        ;CX - Offset hakemistopolulle
        ;DX - Offset tiedostonnimelle

FileSelector:   pusha86
                mov     [SelectorNameOffset],AX
                mov     [FilterOffset],BX
                mov     [PathOffset],CX
                mov     [FileNameOffset],DX
                call    SaveScreen
                mov     AL,20
                mov     BL,6
                mov     AH,40
                mov     BH,15
                mov     CL,1
                call    FillArea
                mov     CL,7
                mov     BL,5
                mov     BH,1
                call    FillArea
                mov     AL,21
                mov     CL,15
                mov     DX,[SelectorNameOffset]
                call    PrintText
                call    CursorOff
                call    Changedir_Stage2
                mov     DX,[PathOffset]
                call    GetPath
                call    ReadDirectory
                call    NewName
SelectorMain:   call    PrintStuff
                call    CursorOff
                call    ReadKey
                cmp     [DirEntries],0
                je      NoControl
                cmp     AH,48h
                je      SelUp
                cmp     AH,50h
                je      SelDown
                cmp     AX,4900h
                je      SelQuickUp
                cmp     AX,5100h
                je      SelQuickDown
                cmp     AX,4700h
                je      SelStart
                cmp     AX,4f00h
                je      SelEnd
NoControl:      cmp     AH,01
                je      SelectorEsc
                cmp     AL,13
                je      Selected
                cmp     AL,9
                je      TypeInFilter
                jmp     SelectorMain
SelectorQuit:   call    RestoreScreen
                popa86
                ret
SelectorEsc:    mov     [Escape],1
                jmp     SelectorQuit
Selected:       mov     SI,[DirSelect]
                shl     SI,4
                add     SI,offset DirTable
                mov     BP,SI
                inc     BP
                cmp     byte ptr [SI.Entry_Type],1
                jne     FileOK
                call    ChangeDir
                call    ReadDirectory
                call    NewName
                jmp     SelectorMain

FileOK:         mov     [Escape],0
                jmp     SelectorQuit

        ;Muuttaa directory・ Vaatii BP:hen muutosstringin offsetin

ChangeDir:      cmp     byte ptr DS:[BP],'.'
                jne     NoParent
                cmp     byte ptr DS:[BP+1],']'
                je      Impossible
                cmp     byte ptr DS:[BP+1],'.'
                je      ParentDir
NoParent:       mov     DI,0
                mov     SI,[PathOffset]
SeekKeno:       lodsb
                cmp     AL,0
                je      KenoReady
                mov     DI,SI
                cmp     AL,' '
                je      KenoReady
                jmp     SeekKeno
KenoReady:      cmp     DI,0
                je      Impossible
                cmp     byte ptr [DI-1],'\'
                je      NoNeedForKeno
                mov     byte ptr [DI-1],'\'
NoNeedForKeno:  mov     SI,BP
                push    DS
                pop     ES
ChangeDir2:     lodsb
                cmp     AL,']'
                je      Finished
                cmp     AL,0
                je      Finished
                cmp     byte ptr [DI],0
                je      Finished
                stosb
                jmp     ChangeDir2
ChangeDir_Stage2:
Finished:
                mov     SI,[PathOffset]
                cmp     byte ptr [SI+1],':'
                jne     NoDriveSpecified
                mov     DL,[SI]
                cmp     DL,'a'
                jae     PieniKirjain
                sub     DL,'A'
                jmp     KirjainOK
PieniKirjain:   sub     DL,'a'
KirjainOK:      mov     AX,0e00h
                int     21h
                add     SI,2
NoDriveSpecified:
                mov     AX,3b00h
                mov     DX,offset ToRoot
                int     21h
                mov     AX,3b00h
                mov     DX,SI
                mov     BX,DX
                cmp     byte ptr [BX],'\'
                jne     Finished2
                inc     DX
Finished2:      int     21h
                mov     DX,[PathOffset]
                call    GetPath
Impossible:     ret

ParentDir:      mov     DX,offset Parent
                mov     AX,3b00h
                int     21h
                mov     DX,[PathOffset]
                call    GetPath
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

TypeInFilter:   mov     BP,[DirSelect]
                mov     [DirSelect],-1
                call    PrintStuff
                mov     [DirSelect],BP
                mov     AL,26
                mov     BL,17
                mov     CL,15
                mov     DX,[FilterOffset]
                mov     [SpecialInput],1
                call    Input
                cmp     [Tab],1
                je      TypeInPath
                cmp     [Escape],1
                je      SelectorMain
                call    ReadDirectory
                call    NewName
                jmp     SelectorMain
TypeInPath:     mov     BP,[DirSelect]
                mov     [DirSelect],-1
                call    PrintStuff
                mov     [DirSelect],BP
                mov     AL,26
                mov     BL,18
                mov     CL,15
                mov     DX,[PathOffset]
                mov     [SpecialInput],1
                call    Input
                cmp     [Tab],1
                je      TypeInName
                cmp     [Escape],1
                je      SelectorMain
                call    Changedir_Stage2
                call    ReadDirectory
                call    NewName
                jmp     SelectorMain
TypeInName:     mov     BP,[DirSelect]
                mov     [DirSelect],-1
                call    PrintStuff
                mov     [DirSelect],BP
                mov     AL,26
                mov     BL,19
                mov     CL,15
                mov     DX,[FileNameOffset]
                mov     [SpecialInput],1
                call    Input
                cmp     [Tab],1
                je      SelectorMain
                cmp     [Escape],1
                je      SelectorMain
                mov     DI,[DirSelect]
                shl     DI,4
                add     DI,offset DirTable
                mov     [DI.Entry_Type],0
                jmp     Selected                ;Returnin painaminen nimen
                                                ;kohdalla tarkoittaa sen
                                                ;hyv・symist・
SelDown:        call    Down
                call    NewName
                jmp     SelectorMain

SelUp:          call    Up
                call    NewName
                jmp     SelectorMain

SelQuickDown:   call    Down
                call    Down
                call    Down
                call    Down
                call    NewName
                jmp     SelectorMain

SelQuickUp:     call    Up
                call    Up
                call    Up
                call    Up
                call    NewName
                jmp     SelectorMain

SelStart:       call    Up
                cmp     [DirSelect],0
                jne     SelStart
                call    NewName
                jmp     SelectorMain

SelEnd:         call    Down
                mov     AX,[DirEntries]
                dec     AX
                cmp     [DirSelect],AX
                jne     SelEnd
                call    NewName
                jmp     SelectorMain

NewName:        mov     SI,[DirSelect]
                shl     SI,4
                add     SI,offset DirTable
                push    DS
                pop     ES
                mov     DI,[FileNameOffset]
                mov     AL,32
ClearName:      cmp     byte ptr [DI],0
                je      ClearNameDone
                stosb
                jmp     ClearName
ClearNameDone:  mov     DI,[FileNameOffset]
MoveName:       lodsb
                cmp     AL,0
                je      NewNameDone
                stosb
                jmp     MoveName
NewNameDone:    ret

Down:           inc     [DirSelect]
                mov     AX,[DirEntries]
                cmp     [DirSelect],AX
                jb      DownOK
                dec     AX
                mov     [DirSelect],AX
DownOK:         mov     AX,[DirSelect]
                sub     AX,[DirView]
                cmp     AX,9
                jb      DownOK2
                inc     [DirView]
DownOK2:        ret

Up:             dec     [DirSelect]
                cmp     [DirSelect],-1
                jne     UpOK
                mov     [DirSelect],0
UpOK:           mov     AX,[DirSelect]
                cmp     AX,[DirView]
                jae     UpOK2
                dec     [DirView]
UpOK2:          ret

ReadDirectory:  mov     [DirView],0
                mov     [DirEntries],0
                mov     [DirSelect],0
                mov     CX,MaxDirEntry
                mov     DI,offset DirTable
                push    DS
                pop     ES
                mov     AX,2020h
ClearNames:     push    DI
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw
                stosw          ;Seitsem・ STOSWia per・k・n - se on oikein!
                pop     DI
                add     DI,type Entry
                loop    ClearNames
                mov     AH,2fh
                int     21h
                mov     [OldDTAseg],ES
                mov     [OldDTAoffset],BX
                mov     DX,offset OurDTA
                mov     AH,1ah
                int     21h
                mov     DI,offset DirTable
                mov     CX,00110000b            ;Ensiksi kaikki hakemistot
                mov     DX,offset FilterAll
                mov     AH,4eh
                int     21h             ;Find First
                jc      ThenWeCheckFiles
                call    StoreDir
RDLoop:         mov     AH,4fh
                int     21h             ;Find Next
                jc      ThenWeCheckFiles
                call    StoreDir
                jmp     RDLoop
ThenWeCheckFiles:
                mov     DX,[FilterOffset]
                mov     CX,00110000b            ;Ensiksi kaikki hakemistot
                mov     AH,4eh
                int     21h             ;Find First
                jc      TerribleShit
                call    StoreName
RDLoop2:        mov     AH,4fh
                int     21h             ;Find Next
                jc      TerribleShit
                call    StoreName
                jmp     RDLoop2

TerribleShit:   push    DS
                mov     AX,[OldDTASeg]
                mov     DX,[OldDTAOffset]
                mov     DS,AX
                mov     AH,1ah
                int     21h
                pop     DS
                ret

StoreName:      mov     AL,[OurDTA+15h]
                and     AL,16
                jnz     StoreStop
                inc     [DirEntries]
                cmp     [DirEntries],MaxDirEntry
                jae     StoreStop
                pusha86
                mov     [DI.Entry_Type],0
                mov     [DI.Entry_Zero],0
                mov     SI,offset OurDTA+1eh
                push    DS
                pop     ES
StoreNameLoop:  lodsb
                cmp     AL,0
                je      StoreNameEnd
                stosb
                jmp     StoreNameLoop
StoreNameEnd:   popa86
                add     DI,type Entry
                ret
StoreStop:      ret

StoreDir:       mov     AL,[OurDTA+15h]
                and     AL,16
                jz      StoreStop
                inc     [DirEntries]
                cmp     [DirEntries],MaxDirEntry
                jae     StoreStop
                pusha86
                mov     [DI.Entry_Type],0
                mov     [DI.Entry_Zero],0
                mov     SI,offset OurDTA+1eh
                push    DS
                pop     ES
                mov     AL,'['
                stosb
StoreDirLoop:   lodsb
                cmp     AL,0
                je      StoreDirEnd
                stosb
                jmp     StoreDirLoop
StoreDirEnd:    mov     AL,']'
                stosb
                popa86
                mov     [DI.Entry_Type],1       ;Hakemisto
                add     DI,type Entry
                ret

PrintStuff:     pusha86
                mov     AL,21
                mov     BL,17
                mov     CL,15
                mov     DX,offset [FilterText]
                call    PrintText
                inc     BL
                mov     DX,offset [PathText]
                call    PrintText
                inc     BL
                mov     DX,offset [NameText]
                call    PrintText
                mov     AL,26
                mov     BL,17
                mov     CL,15
                mov     DX,[FilterOffset]
                call    PrintText
                inc     BL
                mov     DX,[PathOffset]
                call    PrintText
                inc     BL
                mov     DX,[FileNameOffset]
                call    PrintText
                mov     AL,21
                mov     BL,7
                mov     CL,14
                mov     DX,[DirView]
                shl     DX,4
                add     DX,offset DirTable
                mov     SI,[DirView]
                mov     BP,9
PrintFileNames: mov     CL,1eh
                cmp     SI,[DirSelect]
                jne     NoDiffColor
                mov     CL,2eh
NoDiffColor:    call    PrintBox
                inc     SI
                inc     BL
                add     DX,type Entry
                dec     BP
                jnz     PrintFileNames
                popa86
                ret

        ;PrintText - tulostaa nollaan pтttyv・ merkkijonon.
        ;AL - Sarake
        ;BL - Rivi
        ;CL - Vвi (foreground)
        ;DX - offset

PrintText:      push    ES
                push    0b800h
                pop     ES
                pusha86
                mov     SI,DX                   ;L・deosoite
                cmp     AL,79                   ;Ollaanko rajojen ulkopuolella
                ja      PrintQuit
                cmp     BL,24
                ja      PrintQuit
                xor     AH,AH
                xor     BH,BH
                and     CL,15                   ;Vвikoodi aisoihin
                shl     AX,1                    ;X kerrotaan kahdella
                mov     DI,BX                   ;v・iaikaisesti
                shl     BX,7                    ;x 128
                shl     DI,5                    ;x 32, yhteens・160 tavua
                add     DI,AX
                add     DI,BX
                shr     AX,1                    ;BL toimii juoksevana sarake-
                mov     BL,AL                   ;laskurina
PrintLoop:      lodsb
                cmp     AL,0
                je      PrintQuit               ;Tultiin loppuun
                cmp     AL,13
                je      PrintQuit               ;Return ajaa saman asian
                cmp     AL,10
                je      PrintQuit               ;Kuten my敗 Line Feed
                stosb                           ;Laitetaan merkki
                mov     AL,ES:[DI]              ;Otetaan entinen vвikoodi
                and     AL,11110000b            ;Jдetтn background
                or      AL,CL
                stosb                           ;Talletetaan vвikoodi
                inc     BL
                cmp     BL,80
                jae     PrintQuit
                jmp     PrintLoop
PrintQuit:      popa86
                pop     ES
                ret

        ;PrintBox - muuten sama kuin edellinen mutta CL mтrт samalla my敗
        ;taustan vвin, eli tekstin ympвille piirtyy "laatikko."

PrintBox:       push    ES
                push    0b800h
                pop     ES
                pusha86
                mov     SI,DX                   ;L・deosoite
                cmp     AL,79                   ;Ollaanko rajojen ulkopuolella
                ja      PrintQuit
                cmp     BL,24
                ja      PrintQuit
                xor     AH,AH
                xor     BH,BH
                shl     AX,1                    ;X kerrotaan kahdella
                mov     DI,BX                   ;v・iaikaisesti
                shl     BX,7                    ;x 128
                shl     DI,5                    ;x 32, yhteens・160 tavua
                add     DI,AX
                add     DI,BX
                shr     AX,1                    ;BL toimii juoksevana sarake-
                mov     BL,AL                   ;laskurina
PrintLoop2:     lodsb
                cmp     AL,0
                je      PrintQuit               ;Tultiin loppuun
                cmp     AL,13
                je      PrintQuit               ;Return ajaa saman asian
                cmp     AL,10
                je      PrintQuit               ;Kuten my敗 Line Feed
                stosb                           ;Laitetaan merkki
                mov     AL,CL
                stosb                           ;Talletetaan vвikoodi
                inc     BL
                cmp     BL,80
                jae     PrintQuit
                jmp     PrintLoop2

        ;CursorOn - Kursori pтlle.
        ;Ei parametrej・

CursorOn:       pusha86
                ;mov     AH,01h
                ;mov     CX,0d0eh
                ;int     10h
                popa86
                ret

        ;CursorOff - Pois pтlt・
        ;Ei parametrej・

CursorOff:      pusha86
                ;mov     AH,01h
                ;mov     CX,0d0eh
                ;int     10h
                ;mov     AH,01h
                ;mov     CX,2000h
                ;int     10h
                popa86
                ret

        ;CursorXY - Sijoittaa kursorin ruudulla.
        ;AL - Sarake
        ;BL - Rivi

CursorXY:       pusha86
                mov     BH,0
                mov     DH,BL                   ;Rivi
                mov     DL,AL                   ;Sarake
                mov     AH,02h
                int     10h
                popa86
                ret

        ;FillArea - piirtт jollain taustavвill・tиtetyn suorakulmion.
        ;AL - Sarake
        ;BL - Rivi
        ;AH - X-koko
        ;BH - Y-koko
        ;CL - Vвi

FillArea:       push    ES
                push    0b800h
                pop     ES
                pusha86
                mov     SI,DX                   ;L・deosoite
                cmp     AL,79                   ;Ollaanko rajojen ulkopuolella
                ja      PrintQuit
                cmp     BL,24
                ja      PrintQuit
                mov     DX,BX                   ;Y turvaan DX:n
                mov     BP,AX                   ;X turvaan BP:n
                xor     AH,AH
                xor     BH,BH
                and     CL,7                    ;Vвikoodi aisoihin
                shl     CL,4
                shl     AX,1                    ;X kerrotaan kahdella
                mov     DI,BX                   ;v・iaikaisesti
                shl     BX,7                    ;x 128
                shl     DI,5                    ;x 32, yhteens・160 tavua
                add     DI,AX
                add     DI,BX
                xor     AX,AX
                mov     AH,CL
                shr     DX,8
                jz      PrintQuit
                shr     BP,8
                jz      PrintQuit
FillAreaLoop:   mov     CX,BP
                push    DI
                rep     stosw
                pop     DI
                add     DI,160
                dec     DX
                jnz     FillAreaLoop
                jmp     PrintQuit

        ;PrintByte - tulostaa tavun heksadesimaaliformaatissa.
        ;AL - Sarake
        ;BL - Rivi
        ;CL - Vвi
        ;DL - Luku

PrintByte:      pusha86
                push    AX
                mov     SI,DX
                and     SI,0f0h
                shr     SI,4
                add     SI,offset HexStrip
                mov     AL,[SI]
                mov     [HexWord+2],AL
                mov     SI,DX
                and     SI,0fh
                add     SI,offset HexStrip
                mov     AL,[SI]
                mov     [HexWord+3],AL
                pop     AX
                mov     DX,offset HexWord+2
                call    PrintText
                popa86
                ret

        ;PrintWord - tekee saman mutta wordille.
        ;DX - Luku, muuten samat parametrit.

PrintWord:      pusha86
                push    AX
                mov     SI,DX
                and     SI,0f000h
                shr     SI,12
                add     SI,offset HexStrip
                mov     AL,[SI]
                mov     [HexWord],AL
                mov     SI,DX
                and     SI,0f00h
                shr     SI,8
                add     SI,offset HexStrip
                mov     AL,[SI]
                mov     [HexWord+1],AL
                mov     SI,DX
                and     SI,0f0h
                shr     SI,4
                add     SI,offset HexStrip
                mov     AL,[SI]
                mov     [HexWord+2],AL
                mov     SI,DX
                and     SI,0fh
                add     SI,offset HexStrip
                mov     AL,[SI]
                mov     [HexWord+3],AL
                pop     AX
                mov     DX,offset HexWord
                call    PrintText
                popa86
                ret

        ;Input - Ottaa merkkijonon nаpikselt・sisтn.
        ;AL - Sarake
        ;BL - Rivi
        ;CL - Tekstin vвi
        ;DX - Merkkijonon osoite
        ;
        ;HUOMAUTUS: Merkkijonon tиtyy olla nollaan pтttyv・eik・kannata sal-
        ;lia loppunollan pтlle kirjoittamista!!!

Input:          pusha86
                mov     [Escape],0
                mov     [Tab],0
                xor     BP,BP
                mov     SI,DX
InputSeek:      cmp     byte ptr [SI],0         ;Haetaan merkkijonon pituus
                je      InputFound
                inc     BP
                inc     SI
                jmp     InputSeek
InputFound:     mov     [InputPosition],0
                mov     [TextColumn],AL
                mov     [TextRow],BL
                mov     [TextColor],CL
InputLoop:      cmp     [InputPosition],BP
                je      InputNoCursor
                mov     AL,[TextColumn]
                add     AX,[InputPosition]
                call    CursorXY
                call    CursorOn
                jmp     InputOK
InputNoCursor:  call    CursorOff
InputOK:        mov     AL,[TextColumn]
                mov     BL,[TextRow]
                mov     CL,[TextColor]
                call    PrintText
                xor     AH,AH
                int     16h                     ;Merkki nаpikselt・
                cmp     AX,5300h
                je      InputDelete
                cmp     AL,13                   ;Returniko?
                je      InputEnd
                cmp     AH,1
                je      InputEscape
                cmp     [SpecialInput],1        ;Tarvitaanko TABia?
                jne     Input_NoTABCheck
                cmp     AL,9
                je      InputTab
Input_NoTABCheck:
                cmp     AL,9
                je      InputLoop
                cmp     AH,14
                je      InputBS                 ;Backspace
                cmp     AH,4bh
                je      InputLeft               ;Nuoli vas.
                cmp     AH,4dh
                je      InputRight              ;Nuoli oik.
                cmp     AL,0                    ;Ei pтstet・nollaa tekstiin
                je      InputLoop
                cmp     [InputPosition],BP
                je      InputRight
                mov     DI,DX
                add     DI,[InputPosition]
                mov     [DI],AL
InputRight:     inc     [InputPosition]
                cmp     [InputPosition],BP      ;Mentiink・yli?
                jbe     InputLoop
                dec     [InputPosition]
                jmp     InputLoop
InputEnd:       call    CursorOff
                popa86
                ret
InputBS:        mov     DI,DX
                add     DI,[InputPosition]
                cmp     DI,DX                   ;Ei tehd・mitтn jos ollaan
                je      InputLeft               ;jo vasemmassa reunassa!
                mov     byte ptr [DI-1],32      ;Pyyhitтn merkki kursorin
InputLeft:      dec     [InputPosition]         ;vasemmalta puolelta
                cmp     [InputPosition],-1
                jne     InputLoop
                mov     [InputPosition],0
                jmp     InputLoop
InputEscape:    call    CursorOff
                mov     [Escape],1
                popa86
                ret
InputTab:       mov     [SpecialInput],0
                mov     [Tab],1
                popa86
                ret
InputDelete:    mov     DI,DX
                add     DI,[InputPosition]
                mov     AX,BP
                dec     AX
                sub     AX,[InputPosition]
                jz      InputDelete2
                js      ABCDE
                mov     CX,AX
DeleteLoop:     mov     AL,[DI+1]
                mov     [DI],AL
                inc     DI
                loop    DeleteLoop
InputDelete2:   mov     DI,DX
                add     DI,BP
                dec     DI
                mov     byte ptr [DI],32
ABCDE:
                jmp     InputLoop
ﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄ

                End
