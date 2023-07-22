;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³Yleisi„ DOS-rutiineja kuten tiedoston luku, kirjoitus sek„ DOMINUKSEN hake-  ³
;³mistonetsint„rutiinit (Kutulu olkoon h„nen kanssaan!)                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                Title   Tiedostorutiinit
                Name    FILES

                Model   Small
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
                
                Public  Dir_init
                Public  Dir_deinit
                Public  Loadfile
                Public  Savefile
                Public  Getlength
                Public  Displaymsg
                Public  Intextmode

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Dataseg

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Lastkeno        dw      0
Progdir_exists  db      0
Envseg          dw      ?
Olddir          db      '\'
Olddir_buf      db      64 dup(0)
Progdir         db      '\'
Progdir_buf     db      64 dup(0)
Olddrive        db      ?
Intextmode      db      1                       ;Oletus:k„ynnistysvaiheessa
                                                ;ollaan tekstitilassa

                Evendata

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                Codeseg

                .8086
                Jumps

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

        ;Dir_init ja Dir_deinit, hakevat k„ynnistyshakemiston ja palauttavat
        ;alkuper„isen. On t„rke„ havaita ett„ ES:„„ ei pid„ muuttaa ennen Dir_
        ;initin kutsumista tai seuraa Asmodeuksen ilmaantumiseen verrattavia
        ;hirveyksi„!!!

Dir_init:       mov     AX,ES:[2ch]
                mov     [Envseg],AX
                mov     AX,1900h
                int     21h             ;Nykyinen oletusasema
                mov     [Olddrive],AL
                push    DS
                push    ES
                push    DS
                pop     ES              ; ES=_data
                mov     DS,[Envseg]
                xor     SI,SI
Envloop:        lodsb
                cmp     AL,0
                jne     Envloop
                lodsb
                cmp     AL,0
                jne     Envloop
                add     SI,2                    ;SI pointtaa koko filenamen alkuun
                cmp     byte ptr [SI+1],':'
                jne     Nodrivechange
                mov     DL,byte ptr [SI]
                add     SI,2                    ;SI pointtaa pathin alkuun
                cmp     DL,'a'
                jb      Iso                     ;H„h„ t„ss„ oli bugi ennen
                sub     DL,'a'
                jmp     Envok
Iso:            sub     DL,'A'                  ;AL=drive num
Envok:          cmp     DL,ES:[Olddrive]
                je      Nodrivechange
                mov     AX,0e00h
                int     21h                     ;select disk, dl=drive
Nodrivechange:  push    SI
                push    DS
                push    ES
                pop     DS
                mov     AX,4700h
                mov     SI,offset Olddir_buf
                xor     DL,DL
                int     21h
                pop     DS
                pop     SI

Thisshit_again: lodsb
                cmp     AL,'\'
                je      Thisshit_again
                push    SI
Kenoloop:       cmp     AL,'\'
                jne     Nokeno
                mov     ES:[lastkeno],SI
Nokeno:         cmp     AL,0
                je      Kenoloop_out
                lodsb
                jne     Kenoloop
Kenoloop_out:   cmp     ES:[lastkeno],0
                je      Noprogdir
                mov     DI,offset Progdir_buf
                mov     CX,ES:[Lastkeno]
                dec     CX
                pop     SI
                dec     SI
                sub     CX,SI
                rep     movsb
                mov     ES:[progdir_exists],1
                pop     ES
                pop     DS
                mov     AX,3b00h
                mov     DX,offset Progdir
                int     21h
                mov     DX,offset Progdir
                call    DisplayMsg
                ret

Noprogdir:      pop     SI
                pop     ES
                pop     DS
                ret

Dir_deinit:     cmp     Progdir_exists,0
                je      Nodirchgnow
                mov     AX,3b00h
                mov     DX,offset Olddir
                int     21h
Nodirchgnow:    mov     AX,1900h
                mov     DL,Olddir
                int     21h
                ret

        ;Loadfile-rutiini lataa tiedoston paikkaan BP:DI, tiedostonnimen offset
        ;v„litet„„n DX:ss„. Virhe palautetaan CARRY-lipussa Dosin tyyliin. Pys-
        ;tyy lataamaan vaikka koko perusmuistin t„ydelt„ (ja siin„ sivussa VGA-
        ;muistin p„„lle, hehe)

Loadfile:       pusha86
                push    DS
                mov     AX,3d00h                ;Yritet„„n avausta
                int     21h
                jc      Loadfile_error1         ;Ei suostunut avautumaan
                mov     BX,AX                   ;Handle BX:„„n
                mov     DX,DI                   ;Offsetti
                mov     AX,BP                   ;Destinaatiosegmentti
                cmp     DX,8000h                ;Onko offset segmentin loppu-
                jb      Loadfile_nocorrect      ;puoliskolla
                sub     DX,8000h                ;Suoritetaan korjaus
                add     AX,8000h/16
Loadfile_nocorrect:
                mov     DS,AX
                mov     CX,8000h                ;Maksimi lukemisen pituus
                sub     CX,DX                   ;V„hennet„„n offsetti (ettei
                mov     AX,3f00h                ;segmentin raja ylity)
                int     21h                     ;Luetaan ensimm„inen annos
                jc      Loadfile_error2         ;Jotain h„m„r„„ tapahtui
Loadfile_loop:  mov     AX,DS                   ;Seuraava annos aloitetaan
                add     AX,8000h/16             ;offsetista nolla, ja ladataan
                mov     DS,AX                   ;32768 tavun p”tk”iss„
                xor     DX,DX
                mov     CX,8000h
                mov     AX,3f00h
                int     21h
                jc      Loadfile_error2
                cmp     AX,0                    ;Ollaanko lopussa eli luettiin
                jne     Loadfile_loop           ;0 tavua
Loadfile_ready: mov     AX,3e00h                ;Suljetaan tiedosto
                int     21h
                pop     DS                      ;Palautetaan alkuper„inen DS
                popa86
                clc                             ;CARRY=0, ei virhett„
                ret
Loadfile_error1:pop     DS                      ;Palaut. alkuper„inen DS
                popa86
                stc                             ;CARRY=1, virhe
                ret
Loadfile_error2:mov     AX,3e00h                ;Suljetaan tiedosto
                int     21h
                pop     DS                      ;Palautetaan alkuper„inen DS
                popa86
                clc                             ;CARRY=1, virhe ladatessa
                ret

        ;Savefile-rutiini tallentaa osoitteesta BP:DI CX tavua. Segmenttirajoja
        ;ei voi ylitt„„ ja maksimi tiedonsiirron pituudelle on 65535 tavua.
        ;Virhe CARRYssa ja nimen offset DX:ss„.

Savefile:       pusha86
                push    DS
                mov     AX,3c00h                ;Tiedoston luonti
                push    CX
                xor     CX,CX                   ;Attribuutit=0, ei kikkailuja
                int     21h
                jc      Savefile_error1         ;Eip„ auennut
                mov     BX,AX                   ;Handle BX:„„n
                mov     AX,BP                   ;Oikea segmentti
                mov     DS,AX
                mov     DX,DI                   ;Aloitusoffset
                pop     CX                      ;Pituus takaisin
                mov     AX,4000h                ;Ja kirjoitetaan
                int     21h
                mov     AX,3e00h                ;Suljetaan
                int     21h
                pop     DS
                popa86
                clc                             ;Ei virhett„?
                ret
Savefile_error1:pop     CX                      ;Ensin tarpeettomaksi j„„nyt CX
                pop     DS
                popa86
                stc                             ;Virhe, CARRY=1
                ret

        ;Lopuksi viel„ hauska rutiini tiedoston pituuden hakemiseen. DX sis„l-
        ;t„„ nimen offsetin ja pituuden (CARRYN ollessa nolla eli ei virhett„)
        ;saa DX:AX-rekisteriparissa.

Getlength:      mov     AX,3d00h
                int     21h                     ;Yritet„„n avausta
                jc      Getlength_error1        ;Ei auennut
                push    AX                      ;Handle talteen pinoon
                mov     BX,AX                   ;Handle talteen
                xor     CX,CX                   ;Siirtym„ nollaksi
                xor     DX,DX
                mov     AX,4202h                ;Siirryt„„n tiedostossa lopusta
                int     21h                     ;katsoen
                jc      Getlength_error2        ;Ei onnistunut, sairasta?
                pop     BX                      ;Handle pois pinosta
                push    AX
                mov     AX,3e00h                ;Suljetaan tiedosto
                int     21h
                pop     AX
                clc                             ;CARRY=0, ei virhett„
                ret
Getlength_error2:
                pop     BX
                mov     AX,3e00h                ;Suljetaan tiedosto ja ilmoi-
                int     21h                     ;tetaan virheest„
                stc
                ret
Getlength_error1:
                stc                             ;Ei avautunut joten homma on
                ret                             ;varsin yksinkertainen

        ;Ja lopulta GLENVISA:sta ripattu viestinkirjoitusrutiini, jota FSS tulee
        ;k„ytt„m„„n. Stringi tulee olla nollaan p„„ttyv„ ja osoitteessa DS:DX

Displaymsg:     pusha86
                cmp     [Intextmode],1
                jne     Dispdone                ;Jos ollaan graffatilassa niin
                mov     SI,DX                   ;on parempi olla tulostamatta
Displaymsg2:    lodsb
                cmp     AL,255
                je      Disp_nextline
                cmp     AL,0
                je      Dispdone2
                mov     AH,02
                mov     DL,AL
                int     21h
                jmp     Displaymsg2
Dispdone2:      mov     AH,02
                mov     DL,13
                int     21h
                mov     DL,10
                int     21h                     ;Loppuun viel„ CR+LF
Dispdone:       popa86
                ret
Disp_nextline:  mov     AH,02
                mov     DL,13
                int     21h
                mov     DL,10
                int     21h                     ;Rivinvaihto
                jmp     Displaymsg2             ;ja takaisin silmukkaan...

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                end
