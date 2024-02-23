;JORGE ORTIZ RAMIREZ
.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2

main:
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@bg_loop:
  lda background, x  ; Load the tile index from our data
  sta $2007  ; Write the tile index to the PPU
  inx
  cpx #$0A  ; We have 10 tiles
  bne @bg_loop
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$20
  bne @loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

forever:
  jmp forever

nmi:
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003
  lda #$20  ; Set PPU address to $2000 (start of nametable 0)
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:	lda hello, x 	; Load the hello message into SPR-RAM
  sta $2004
  inx
  cpx #$30  ; 48 bytes (10 sprites * 4 bytes each) + 8 bytes (first 2 lines of the message)
  bne @loop
  rti

hello:
  .byte $00, $00, $00, $00 	; DO NOT MODIFY
  .byte $00, $00, $00, $00  ; DO NOT MODIFY
  .byte $6c, $00, $00, $32  ; Y=$6c(108), Sprite 00(J), Palette=00, X=$32(50)
  .byte $6c, $01, $01, $3c  ; Y=$6c(108), Sprite 01(O), Palette=01, X=$3c(60)
  .byte $6c, $09, $00, $46  ; Y=$6c(108), Sprite 09(R), Palette=00, X=$46(70)
  .byte $6c, $03, $00, $50  ; Y=$6c(108), Sprite 03(G), Palette=00, X=$50(80)
  .byte $6c, $04, $01, $5a  ; Y=$6c(108), Sprite 04(E), Palette=01, X=$5a(90)

  .byte $6c, $08, $00, $6e  ; Y=$6c(108), Sprite 08(O), Palette=00, X=$6e(110)
  .byte $6c, $02, $01, $78  ; Y=$6c(108), Sprite 02(R), Palette=01, X=$78(120)
  .byte $6c, $05, $00, $82  ; Y=$6c(108), Sprite 05(T), Palette=00, X=$82(130)
  .byte $6c, $06, $01, $8c  ; Y=$6c(108), Sprite 06(I), Palette=01, X=$8c(140)
  .byte $6c, $07, $01, $96  ; Y=$6c(108), Sprite 07(Z), Palette=01, X=$96(150)

palettes:
  ; Background Palette
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0f, $01, $08, $1a
  .byte $0f, $28, $3c, $06
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

background: ;10 tiles
  .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09

; Character memory
.segment "CHARS"
  .byte %01111110 ; J (00)
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %11011000
  .byte %01111000
  .byte $7e, $18, $18, $18, $18, $18, $d8, $78

  .byte %01111110	; O (01)
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte $7e, $e7, $c3, $c3, $c3, $c3, $e7, $7e

  .byte %01111110 ; R (02)
  .byte %11000110
  .byte %11000110
  .byte %11000110
  .byte %11111110
  .byte %11011000
  .byte %11001100
  .byte %11000110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110 ; G (03)
  .byte %11000000
  .byte %11000000
  .byte %11000000
  .byte %11001110
  .byte %11000011
  .byte %11000011
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %00000000 ; E (04)
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte $7f, $c0, $c0, $ff, $ff, $c0, $c0, $7f

  .byte %11111111 ; T (05)
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte $ff, $18, $18, $18, $18, $18, $18, $18

  .byte %11111111 ; I (06)
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %00011000
  .byte %11111111
  .byte $ff, $18, $18, $18, $18, $18, $18, $ff

  .byte %11111111 ; Z (07)
  .byte %00000011
  .byte %00000110
  .byte %00001100
  .byte %00011000
  .byte %00110000
  .byte %01100000
  .byte %11111111
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %01111110	; O (08)
  .byte %11100111
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11000011
  .byte %11100111
  .byte %01111110
  .byte $00, $00, $00, $00, $00, $00, $00, $00

  .byte %00000000 ; R (09)
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte %00000000
  .byte $7e, $c6, $c6, $c6, $fe, $d8, $cc, $c6