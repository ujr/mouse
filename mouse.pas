{*********************************************************************}
{                                                                     }
{        Unit   M O U S E                                             }
{                                                                     }
{        Routinen zur einfachen Benützung der Maus                    }
{        in Pascal-Programmen                                         }
{                                                                     }
{        Copyright (c) 1994,1995 Urs-Jakob R�etschi          1994     }
{                                                                     }
{*********************************************************************}

{����������������������������������������������������������������������
  Last update: 1.11.95
  �bersetzung: Compilieren mit Borland Pascal 7.0
����������������������������������������������������������������������}

unit Mouse;

{$C FIXED PRELOAD PERMANENT}

interface

  const

       { Ereignis-Codes }

         ev_MouseMove         = $0001;      {    1 }
         ev_LButtonDown       = $0002;      {    2 }
         ev_RButtonDown       = $0004;      {    4 }
         ev_MButtonDown       = $0008;      {    8 }
         ev_LButtonUp         = $0010;      {   16 }
         ev_RButtonUp         = $0020;      {   32 }
         ev_MButtonUp         = $0040;      {   64 }
         ev_LButtonDblClk     = $0080;      {  128 }
         ev_RButtonDblClk     = $0100;      {  256 }
         ev_MButtonDblClk     = $0200;      {  512 }
         ev_MouseAuto         = $0400;      { 1024 }

       { Ereignis-Masken }

         ev_NoEvent           = $0000;      {    0 }
         ev_Mouse             = $07FF;      { 2047 }
         ev_AnyButtonDown     = $000E;      {   14 }
         ev_AnyButtonUp       = $0070;      {  112 }
         ev_AnyButtonDblClk   = $0380;      {  896 }
         ev_LButtonEvent      = $0092;      {  146 }
         ev_RButtonEvent      = $0124;      {  292 }
         ev_MButtonEvent      = $0248;      {  584 }
         ev_AnyButtonEvent    = $03FE;      { 1022 }

       { Cursorstil-Konstanten }

         mc_User              = $0000;      { Benutzerdefinierter Cursor }
         mc_Default           = $0001;      { Standardpfeil }
         mc_DragNS            = $0002;      { Doppelpfeil oben-unten }
         mc_DragWE            = $0003;      { Doppelpfeil links-rechts }
         mc_DragNWSE          = $0004;      { Doppelpfeil obenlinks-untenrechts }
         mc_DragNESW          = $0005;      { Doppelpfeil obenrechts-untenlinks }
         mc_ArrowDown         = $0006;      { Pfeil nach unten }
         mc_ArrowLeft         = $0007;      { Pfeil nach links }
         mc_ArrowUp           = $0008;      { Pfeil nach oben }
         mc_ArrowRight        = $0009;      { Pfeil nach rechts }
         mc_Drag              = $000A;      { Vierfachpfeil }
         mc_DragDiagonal      = $000B;      { Vierfachpfeil, diagonal }
         mc_Cross             = $000C;      { Kleines Fadenkreuz }
         mc_Wait              = $000D;      { Sanduhr }
         mc_IBeam             = $000E;      { Doppel-T Balken }
         mc_TextStandard      = $0032;      { Standard Text-Cursor }
         mc_TextBlock         = $0033;      { Blockf�rmiger Text-Cursor, grau }
         mc_TextBlink         = $0034;      { Blinkender Block-Cursor, grau }

       { Maustasten, f�r tMouseEvent.Buttons und Buttonstate }

         mb_LeftButton        = $0001;      { Linke Maustaste:    Bit 0 }
         mb_RightButton       = $0002;      { Rechte Maustaste:   Bit 1 }
         mb_MiddleButton      = $0004;      { Mittlere Maustaste: Bit 2 }

       { Variablen, die den aktuellen Mausstatus widerspiegeln }

         MouseX:      Integer = $0000;      { Aktuelle Maus-X-Koordinate }
         MouseY:      Integer = $0000;      { Aktuelle Maus-Y-Koordinate }
         MouseEvent:  Word    = $0000;      { Letztes eingetroffenes Ereignis }
         ButtonState: Byte    =   $00;      { Aktueller Tasten-Status }

       { Variablen, die das Verhalten des Eventhandlers bestimmen }

         SwapButtons: Boolean = False;  { True = links-rechts vertauschen }
         {DoubleDelay: Word = 8;}       { Max Zeit zw. zwei Clicks, da� DblClk }
         DoubleMoveX: Word = 0;         { Maximale x-Bewegung, da� noch DblClk }
         DoubleMoveY: Word = 0;         { Maximale y-Bewegung, da� noch DblClk }
         {RepeatDelay: Word = 8;}       { Ab dieser Anzahl Ticks ev_MouseDrag }
         DblClkTime: Word = 8;
         AutoTime: Word = 8;

       { Weitere Variablen }

         ResetMouse:      Boolean = True;
         TextCursorSMask: Word    = $77FF;
         TextCursorCMask: Word    = $7700;
         TextCursorHardW: Boolean = False;



  type

       { Der Ereignisrekord, der von GetMouseEvent �bergeben wird }

         tMouseEvent = record
           Event: Word;
           Buttons: Word;
           case Byte of
             0: ( Where: Longint );
             1: ( MouseX: Integer;
                  MouseY: Integer );
         end;


         tGraphCursor = array[0..31] of Word;
         ConvertProc  = procedure;


  function  MouseAvail: Boolean;
  function  MouseButtons: Byte;
  function  MouseVisible: Boolean;
  function  MouseHandling: Boolean;
  procedure ShowMouse;
  procedure HideMouse;
  procedure MouseOn;
  procedure MouseOff;
  procedure SetMouseRange( XA,YA,XB,YB: Integer );
  procedure SetMousePos( X,Y: Integer );
  procedure GetMousePos( var X,Y: Integer );
  procedure SetMouseSpeed( SpeedX, SpeedY: Integer );
  procedure SetTextCursor( HardCursor: Boolean; SMask, CMask: Word );
  procedure SetGraphCursor( X,Y: Integer; var Cursor );
  procedure SetCursorStyle( S: Integer );
  function  GetCursorStyle: Integer;
  procedure GetMouseEvent( var Event: tMouseEvent );
  procedure ClearQueue;

  { Konvertierungs-Routinen }
  procedure cnvNoConvert;
  procedure cnv80x25_S;
  procedure cnv80x25_M;
  procedure cnv40x25_S;
  procedure cnv40x25_M;
  procedure cnv320x200_S;
  procedure cnv320x200_M;


  const
         ConvertToScreen: ConvertProc = cnvNoConvert;
         ConvertToMouse:  ConvertProc = cnvNoConvert;


implementation

  const  MaxGraphCursors = 14;
         HotSpots: array[1..MaxGraphCursors] of Word =
           ( $0000,$0707,$0707,$0707,$0707,$0F07,$0700,$0007,
             $070F,$0707,$0707,$0707,$0707,$0707 );
         CursorStyles: array[1..MaxGraphCursors] of tGraphCursor =
           ( { mc_Arrow }                                   (
             $3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF,$007F,
             $003F,$001F,$000F,$00FF,$10FF,$787F,$F87F,$FC7F,
             $0000,$4000,$6000,$7000,$7800,$7C00,$7E00,$7F00,
             $7F80,$7FC0,$7E00,$4600,$0600,$0300,$0300,$0000),
             { mc_SizeNS }                                  (
             $FEFF,$FC7F,$F83F,$F01F,$E00F,$C007,$8003,$F83F,
             $F83F,$8003,$C007,$E00F,$F01F,$F83F,$FC7F,$FEFF,
             $0000,$0100,$0380,$07C0,$0FE0,$1FF0,$0380,$0380,
             $0380,$0380,$1FF0,$0FE0,$07C0,$0380,$0100,$0000),
             { mc_SizeWE }                                  (
             $FFFF,$FDBF,$F99F,$F18F,$E187,$C003,$8001,$0000,
             $8001,$C003,$E187,$F18F,$F99F,$FDBF,$FFFF,$FFFF,
             $0000,$0000,$0000,$0420,$0C30,$1C38,$3FFC,$7FFE,
             $3FFC,$1C38,$0C30,$0420,$0000,$0000,$0000,$0000),
             { mc_SizeNWSE }                                (
             $007F,$007F,$00FF,$01FF,$01FF,$00FF,$007F,$183C,
             $3C18,$FE00,$FF00,$FF80,$FF80,$FF00,$FE00,$FE00,
             $0000,$7F00,$7E00,$7C00,$7C00,$7E00,$6700,$4380,
             $01C2,$00E6,$007E,$003E,$003E,$007E,$00FE,$0000),
             { mc_SizeNESW }                                (
             $FE00,$FE00,$FF00,$FF80,$FF80,$FF00,$FE00,$3C18,
             $183C,$007F,$00FF,$01FF,$01FF,$00FF,$007F,$007F,
             $0000,$00FE,$007E,$003E,$003E,$007E,$00E6,$01C2,
             $4380,$6700,$7E00,$7C00,$7C00,$7E00,$7F00,$0000),
             { mc_ArrowDown }                               (
             $F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,
             $0001,$8003,$C007,$E00F,$F01F,$F83F,$FC7F,$FEFF,
             $0000,$0380,$0380,$0380,$0380,$0380,$0380,$0380,
             $0380,$3FF8,$1FF0,$0FE0,$07C0,$0380,$0100,$0000),
             { mc_ArrowLeft }                               (
             $FEFF,$FCFF,$F8FF,$F0FF,$E0FF,$C000,$8000,$0000,
             $8000,$C000,$E0FF,$F0FF,$F8FF,$FCFF,$FEFF,$FFFF,
             $0000,$0000,$0200,$0600,$0E00,$1E00,$3FFE,$7FFE,
             $3FFE,$1E00,$0E00,$0600,$0200,$0000,$0000,$0000),
             { mc_ArrowUp }                                 (
             $FEFF,$FC7F,$F83F,$F01F,$E00F,$C007,$8003,$0001,
             $F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,$F83F,
             $0000,$0100,$0380,$07C0,$0FE0,$1FF0,$3FF8,$0380,
             $0380,$0380,$0380,$0380,$0380,$0380,$0380,$0000),
             { mc_ArrowRight }                              (
             $FF7F,$FF3F,$FF1F,$FF0F,$FF07,$0003,$0001,$0000,
             $0001,$0003,$FF07,$FF0F,$FF1F,$FF3F,$FF7F,$FFFF,
             $0000,$0000,$0040,$0060,$0070,$0078,$7FFC,$7FFE,
             $7FFC,$0078,$0070,$0060,$0040,$0000,$0000,$0000),
             { mc_Size }                                    (
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $0000,$0100,$0380,$07C0,$0100,$1110,$3118,$7FFC,
             $3118,$1110,$0100,$07C0,$0380,$0100,$0000,$0000),
             { mc_SizeDiagonal }                            (
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $0000,$7C7C,$783C,$783C,$7C7C,$4EE4,$07C0,$0380,
             $07C0,$4EE4,$7C7C,$783C,$783C,$7C7C,$0000,$0000),
             { mc_Cross }                                   (
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $0100,$0100,$0100,$0100,$0100,$0100,$0100,$FFFE,
             $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0000),
             { mc_Wait }                                    (
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $3FFC,$300C,$1008,$0810,$0810,$0420,$0240,$0180,
             $0180,$0240,$0420,$0810,$0990,$13C8,$37EC,$3FFC),
             { mc_IBeam }                                   (
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
             $0EE0,$0100,$0100,$0100,$0100,$0100,$0100,$0100,
             $0100,$0100,$0100,$0100,$0100,$0100,$0100,$0EE0)
             { ev... }                                        );

         ButtonCount:   Byte    = 0;        { Tastenanzahl, 0=keine Maus }
         CursorStyle:   Integer = 1;        { Gegenw�rtige Cursornummer }
         CursorVisible: Boolean = False;    { True = Cursor sichtbar }
         EventsActive:  Boolean = False;    { True = Eventhandling aktiv }

         EventQSize = 200;

  var    SaveExit:   Pointer;
         ScreenMode: Byte absolute $0000:$0449;
         TimerTicks: Word absolute $0040:$006C;

         LastClickTime:   Word;
         LastClick:       Word;
         LastButtonState: Byte;
         LastMouseX:      Integer;
         LastMouseY:      Integer;
         DownMouseX:      Integer;
         DownMouseY:      Integer;
         AutoDelay:       Word;
         AutoTicks:       Word;

         EventCount: Word;
         EventQHead: Word;
         EventQTail: Word;
         EventQueue: array[0..EventQSize-1] of tMouseEvent;
         EventQLast: record end;


procedure StandardCnvHandler; near;
begin
  case ScreenMode of
    $02,$03,$07:
      begin
        ConvertToScreen := cnv80x25_S;
        ConvertToMouse := cnv80x25_M;
      end;
    $00,$01:
      begin
        ConvertToScreen := cnv40x25_S;
        ConvertToMouse := cnv40x25_M;
      end;
    $04,$05,$0D,$13:
      begin
        ConvertToScreen := cnv320x200_S;
        ConvertToMouse := cnv320x200_M;
        DoubleMoveX := 3;
        DoubleMoveY := 2;
      end;
    $11,$12:
      begin
        ConvertToScreen := cnvNoConvert;
        ConvertToMouse := cnvNoConvert;
        DoubleMoveX := 5;
        DoubleMoveY := 5;
      end;
    $0F,$10:
      begin
        ConvertToScreen := cnvNoConvert;
        ConvertToMouse := cnvNoConvert;
        DoubleMoveX := 5;
        DoubleMoveY := 4;
      end;
    $06,$0E:
      begin
        ConvertToScreen := cnvNoConvert;
        ConvertToMouse := cnvNoConvert;
        DoubleMoveX := 5;
        DoubleMoveY := 3;
      end;
  end;
end;

procedure StoreEvent; near; assembler;
asm
        MOV     DI,SP
        LES     DI,SS:[DI+8]
        CLD
        STOSW
        XCHG    AX,BX
        STOSW
        XCHG    AX,CX
        STOSW
        XCHG    AX,DX
        STOSW
end;

procedure MouseInt; far; assembler;
asm
        MOV     SI,SEG @DATA
        MOV     DS,SI
        MOV     ButtonState,BL
        MOV     MouseEvent,AX
        CALL    ConvertToScreen
        MOV     MouseX,CX
        MOV     MouseY,DX
        CMP     EventCount,EventQSize
        JE      @@2
        MOV     ES,Seg0040
        MOV     AX,ES:TimerTicks
        MOV     DI,EventQTail
        PUSH    DS
        POP     ES
        CLD
        STOSW
        XCHG    AX,BX
        STOSW
        XCHG    AX,CX
        STOSW
        XCHG    AX,DX
        STOSW
        CMP     DI,OFFSET EventQLast
        JNE     @@1
        MOV     DI,OFFSET EventQueue
@@1:    MOV     EventQTail,DI
        INC     EventCount
@@2:
end;

function MouseAvail: Boolean; assembler;
asm
        XOR       AL,AL
        CMP       ButtonCount,0
        JE        @@1
        MOV       AX,1
@@1:
end;

function MouseVisible: Boolean; assembler;
asm
        MOV     AL,CursorVisible
end;

function MouseHandling: Boolean; assembler;
asm
        MOV     AL,EventsActive
end;

function MouseButtons: Byte; assembler;
asm
        MOV     AL,ButtonCount
end;

procedure ShowMouse; assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        CMP     CursorVisible,0
        JNE     @@1
        MOV     AX,01h
        INT     33h
        MOV     CursorVisible,1
@@1:
end;

procedure HideMouse; assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        CMP     CursorVisible,0
        JE      @@1
        MOV     AX,02h
        INT     33h
        MOV     CursorVisible,0
@@1:
end;

procedure MouseOn; assembler;
asm
        XOR     AX,AX
        CMP     AL,ButtonCount
        JE      @@3
        MOV     LastClickTime,AX
        MOV     LastClick,AX
        MOV     LastButtonState,AL
        MOV     EventCount,AX
        MOV     MouseEvent,AX
        INT     33h
        CMP     ResetMouse,0
        JE      @@1
        XOR     AX,AX
        MOV     SwapButtons,AL
        MOV     CursorVisible,AL
        MOV     DoubleMoveX,AX
        MOV     DoubleMoveY,AX
        MOV     AX,8
        MOV     DblClkTime,AX
        MOV     AutoTime,AX
        CALL    StandardCnvHandler
        JMP     @@2
@@1:    CMP     CursorVisible,0
        JE      @@2
        MOV     CursorVisible,0
        CALL    ShowMouse
        MOV     AX,04h
        MOV     CX,LastMouseX
        MOV     DX,LastMouseY
        CALL    ConvertToMouse
        INT     33h
@@2:    MOV     AX,OFFSET DS:EventQueue
        MOV     EventQHead,AX
        MOV     EventQTail,AX
        MOV     AX,03h
        INT     33h
        MOV     ButtonState,BL
        CALL    ConvertToScreen
        MOV     MouseX,CX
        MOV     MouseY,DX
        MOV     LastMouseX,CX
        MOV     LastMouseY,DX
        MOV     AX,0Ch
        MOV     CX,0FFFFh
        MOV     DX,OFFSET CS:MouseInt
        PUSH    CS
        POP     ES
        INT     33h
        MOV     EventsActive,1
@@3:
end;

procedure MouseOff; assembler;
asm
        CMP     ButtonCount,0
        JE      @@1
        CALL    HideMouse
        MOV     AX,0Ch
        XOR     CX,CX
        MOV     DX,CX
        MOV     ES,CX
        MOV     EventsActive,CL
        MOV     MouseX,CX
        MOV     MouseY,CX
        MOV     MouseEvent,CX
        MOV     ButtonState,CL
        INT     33h
@@1:
end;

procedure SetMouseRange( XA, YA, XB, YB: Integer ); assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        MOV     CX,XA
        MOV     DX,YA
        MOV     DI,XB
        MOV     SI,YB
        CALL    ConvertToMouse
        XCHG    CX,DI
        XCHG    DX,SI
        CALL    ConvertToMouse
        PUSH    DX       { YB }
        PUSH    SI       { YA }
        MOV     DX,DI
        XCHG    CX,DX
        MOV     AX,07h
        INT     33h
        POP     CX
        POP     DX
        MOV     AX,08h
        INT     33h
@@1:
end;

procedure SetMousePos( X, Y: Integer ); assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        MOV     CX,X
        MOV     DX,Y
        CALL    ConvertToMouse
        MOV     AX,04h
        INT     33h
@@1:
end;

procedure GetMousePos( var X,Y: Integer ); assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        MOV     AX,03h
        INT     33h
        CALL    ConvertToScreen
        LES     DI,X
        MOV     ES:[DI],CX
        LES     DI,Y
        MOV     ES:[DI],DX
@@1:
end;

procedure SetMouseSpeed( SpeedX, SpeedY: Integer ); assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        MOV     AX,0Fh
        MOV     CX,SpeedX
        MOV     DX,SpeedY
        CMP     CX,0
        JE      @@1
        CMP     DX,0
        JE      @@1
        INT     33h
@@1:
end;

procedure SetTextCursor( HardCursor: Boolean; SMask, CMask: Word ); assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        MOV     AX,000Ah
        MOV     BX,WORD PTR HardCursor
        MOV     CX,SMask
        MOV     DX,CMask
        MOV     TextCursorHardW,BL
        MOV     TextCursorSMask,CX
        MOV     TextCursorCMask,DX
        INT     33h
        MOV     CursorStyle,mc_User;
@@1:
end;

procedure SetGraphCursor( X,Y: Integer; var Cursor ); assembler;
asm
        CMP     EventsActive,0
        JE      @@1
        MOV     AX,09h
        MOV     BX,X
        MOV     CX,Y
        LES     DX,Cursor
        INT     33h
        MOV     CursorStyle,mc_User;
@@1:
end;

procedure SetCursorStyle( S: Integer );
begin
  if ( S > 0 ) and ( S <= MaxGraphCursors ) then
    SetGraphCursor( Lo( HotSpots[S] ), Hi( HotSpots[S] ), CursorStyles[S] )
  else
    case S of
      mc_TextStandard: SetTextCursor( False, $77FF, $7700 );
      mc_TextBlock:    SetTextCursor( False, $7000, $77DB );
      mc_TextBlink:    SetTextCursor( False, $00FF, $F100 );
    else
      Exit;
    end;
  CursorStyle := S;
end;

function GetCursorStyle: Integer; assembler;
asm
        MOV     AX,CursorStyle;
end;

procedure GetMouseEvent( var Event: tMouseEvent ); assembler;
asm
        CMP     EventsActive,0
        JE      @@6
        CLI
        CMP     EventCount,0
        JNE     @@1
        MOV     BL,ButtonState
        MOV     CX,MouseX
        MOV     DX,MouseY
        MOV     ES,Seg0040
        MOV     DI,ES:TimerTicks
        JMP     @@3
@@1:    MOV     SI,EventQHead
        CLD
        LODSW
        XCHG    AX,DI
        LODSW
        XCHG    AX,BX
        LODSW
        XCHG    AX,CX
        LODSW
        XCHG    AX,DX
        CMP     SI,OFFSET EventQLast
        JNE     @@2
        MOV     SI,OFFSET EventQueue
@@2:    MOV     EventQHead,SI
        DEC     EventCount
@@3:    STI
        CMP     SwapButtons,0
        JE      @@4
        MOV     BH,BL
        AND     BH,3
        JE      @@4
        CMP     BH,3
        JE      @@4
        XOR     BL,3
@@4:    MOV     BH,LastButtonState
        MOV     LastButtonState,BL
        MOV     AX,BX
        CMP     BH,BL
        JE      @@5
        OR      BH,BH
        JE      @@7
        OR      BL,BL
        JE      @@9
@@5:    CMP     CX,LastMouseX
        JNE     @@10
        CMP     DX,LastMouseY
        JNE     @@10
        OR      BL,BL
        JE      @@6
        MOV     AX,DI
        SUB     AX,AutoTicks
        CMP     AX,AutoDelay
        JA      @@11
@@6:    XOR     AX,AX
        MOV     BX,AX
        MOV     CX,LastMouseX
        MOV     DX,LastMouseY
        JMP     @@13
@@7:    PUSH    CX
        XOR     AL,AH
        XOR     AH,AH
        MOV     AutoTicks,DI
        MOV     BX,AutoTime
        MOV     AutoDelay,BX
        MOV     BX,CX
        MOV     CL,1
        SUB     BX,DownMouseX
        JAE     @@14
        NEG     BX
@@14:   CMP     BX,DoubleMoveX
        JA      @@8
        MOV     BX,DX
        SUB     BX,DownMouseY
        JAE     @@15
        NEG     BX
@@15:   CMP     BX,DoubleMoveY
        JA      @@8
        MOV     BX,DI
        SUB     BX,LastClickTime
        CMP     BX,DblClkTime
        JAE     @@8
        MOV     BX,LastClick
        SHR     BX,1
        CMP     BX,AX
        JNE     @@8
        MOV     CL,7
@@8:    SHL     AX,CL
        MOV     LastClickTime,DI
        POP     CX
        MOV     DownMouseX,CX
        MOV     DownMouseY,DX
        MOV     LastClick,AX
        JMP     @@12
@@9:    PUSH    CX
        MOV     CL,4
        XOR     AL,AH
        XOR     AH,AH
        SHL     AX,CL
        POP     CX
        JMP     @@12
@@10:   MOV     AX,ev_MouseMove
        XOR     BX,BX
        JMP     @@12
@@11:   MOV     AutoTicks,DI
        MOV     AutoDelay,1
        MOV     AX,ev_MouseAuto
@@12:   MOV     LastMouseX,CX
        MOV     LastMouseY,DX
        MOV     BX,WORD PTR LastButtonState
@@13:   CALL    StoreEvent
end;

procedure ClearQueue; assembler;
asm
        MOV     AX,MouseX
        MOV     BX,MouseY
        MOV     LastMouseX,AX
        MOV     LastMouseY,BX
        MOV     BL,ButtonState
        MOV     LastButtonState,BL
        MOV     EventCount,0
        MOV     AX,OFFSET DS:EventQueue
        MOV     EventQHead,AX
        MOV     EventQTail,AX
end;

procedure cnvNoConvert;
begin
end;

procedure cnv80x25_S; assembler;
asm
        SHR     CX,1
        SHR     CX,1
        SHR     CX,1
        INC     CX
        SHR     DX,1
        SHR     DX,1
        SHR     DX,1
        INC     DX
end;

procedure cnv80x25_M; assembler;
asm
        DEC     CX
        SHL     CX,1
        SHL     CX,1
        SHL     CX,1
        DEC     DX
        SHL     DX,1
        SHL     DX,1
        SHL     DX,1
end;

procedure cnv40x25_M; assembler;
asm
        PUSH    BX
        DEC     CX
        DEC     DX
        MOV     BX,CX
        MOV     CL,4
        SHL     BX,CL
        DEC     CL
        SHL     DX,CL
        MOV     CX,BX
        POP     BX
end;

procedure cnv40x25_S; assembler;
asm
        PUSH    BX
        MOV     BX,CX
        MOV     CL,4
        SHR     BX,CL
        DEC     CL
        SHR     DX,CL
        INC     DX
        MOV     CX,BX
        INC     CX
        POP     BX
end;

procedure cnv320x200_S; assembler;
asm
        SHR     CX,1
end;

procedure cnv320x200_M; assembler;
asm
        SHL     CX,1
end;

procedure MouseExit; far;
begin
  MouseOff;
  ExitProc := SaveExit;
end;

procedure InitMouse; assembler;
asm
        MOV     AX,3533h
        INT     21h
        MOV     AX,ES
        OR      AX,BX
        JE      @@1
        XOR     AX,AX
        INT     33h
        OR      AX,AX
        JE      @@1
        MOV     AX,BX
@@1:    MOV     ButtonCount,AL
end;


begin
  SaveExit := ExitProc;
  ExitProc := @MouseExit;
  InitMouse;
end.

    {------------------- DAS EVENTHANDLING SYSTEM -------------------}
    {     !!!!!!!!!�                                                 }
    {  tEvent.What                                                   }
    {    �������������������������������Ŀ                           }
    {  15���������������������������������0                          }
    {     � � � � � � � � � � � � � � � �� ev_MouseMove     = $0001  }
    {     � � � � � � � � � � � � � � ���� ev_LButtonDown   = $0002  }
    {      ohne be- � � � � � � � � ������ ev_RButtonDown   = $0004  }
    {      deutung  � � � � � � � �������� ev_MButtonDown   = $0008  }
    {               � � � � � � ���������� ev_LButtonUp     = $0010  }
    {               � � � � � ������������ ev_RButtonUp     = $0020  }
    {               � � � � �������������� ev_MButtonUp     = $0040  }
    {               � � � ���������������� ev_LButtonDblClk = $0080  }
    {               � � ������������������ ev_RButtonDblClk = $0100  }
    {               � �������������������� ev_MButtonDblClk = $0200  }
    {               ���������������������� ev_MouseAuto     = $0400  }
    {                                                                }
    {                                                                }
    {  tEvent.What        tEvent.Message        tEvent.Where         }
    {  ----------------------------------------------------------    }
    {  ev_MouseMove       Tasten-Status         Maus-Position        }
    {  ev_LButtonDown     Tasten-Status         Maus-Position        }
    {  ...                ...                   ...                  }
    {  ev_MButtonDblClk   Tasten-Status         Maus-Position        }
    {  ev_MouseAuto       Tasten-Status         Maus-Position        }
    {  ev_NoEvent         0                     Maus-Position        }
    {                                                                }
    {----------------------------------------------------------------}
