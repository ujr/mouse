{***********************************************}
{                                               }
{                  Unit TMOUSE                  }
{   Routinen zur einfachen BenÅtzung der Maus   }
{   im Textmodus                                }
{                                               }
{   Version 1.0                UJR, Januar 1995 }
{***********************************************}

unit TMouse;

interface

  const

    { Ereignis-Codes }

         ev_MouseMove         = $0001;           {    1 }
         ev_LButtonDown       = $0002;           {    2 }
         ev_RButtonDown       = $0004;           {    4 }
         ev_MButtonDown       = $0008;           {    8 }
         ev_LButtonUp         = $0010;           {   16 }
         ev_RButtonUp         = $0020;           {   32 }
         ev_MButtonUp         = $0040;           {   64 }
         ev_LButtonDblClk     = $0080;           {  128 }
         ev_RButtonDblClk     = $0100;           {  256 }
         ev_MButtonDblClk     = $0200;           {  512 }
         ev_MouseAuto         = $0400;           { 1024 }

    { Ereignis-Masken }

         ev_NoEvent           = $0000;           {    0 }
         ev_Mouse             = $07FF;           { 2047 }
         ev_AnyButtonDown     = $000E;           {   14 }
         ev_AnyButtonUp       = $0070;           {  112 }
         ev_AnyButtonDblClk   = $0380;           {  896 }
         ev_LButtonEvent      = $0092;           {  146 }
         ev_RButtonEvent      = $0124;           {  292 }
         ev_MButtonEvent      = $0248;           {  584 }
         ev_AnyButtonEvent    = $03FE;           { 1022 }

    { Konstanten fÅr das Aussehen des Maus-Zeigers }

         mc_SameChar          = $00FF;           { gleiches Zeichen         }
         mc_SameCol           = $00FF;           { gleiche Farbe            }
         mc_InvCol            = $7777;           { Farbe invertiert         }
         mc_SameColB          = $807F;           { gleiche Farbe blinkend   }
         mc_InvColB           = $F777;           { invertiert, blinkend     }

    { Maustasten, fÅr tEvent.Buttons und Buttonstate }

         mb_LeftButton        = $0001;           { Linke Maustaste:  Bit 0  }
         mb_RightButton       = $0002;           { Rechte Maustaste: Bit 1  }
         mb_MiddleButton      = $0004;           { Mittlere Taste:   Bit 2  }

    { Variablen, die den aktuellen Mausstatus widerspiegeln }

         MouseX:      Integer = $0000;           { Aktuelle Maus-X-Position }
         MouseY:      Integer = $0000;           { Aktuelle Maus-Y-Position }
         ButtonState: Byte    =   $00;           { Aktueller Tasten-Status  }
         MouseRange:  Byte    =   $00;           { Aktueller Maus-Bereich   }

    { Variablen, die das Verhalten des Eventhandlers bestimmen }

         SwapButton: Boolean = False;            { links-rechts vertauschen }
         DoubleDelay: Word = 8;                  { Max. DblClk-Zwischenzeit }
         RepeatDelay: Word = 8;                  { Min. ev_MouseAuto Zeit   }

    { Konstanten fÅr die Mausbereich-Verwaltung }

         NoRange = 255;                          { Kein bestimmter Bereich  }
         MaxRanges = 100;                        { Max. Anzahl Bereiche     }
         StartCursor: Longint = $850F0000;       { Cursor bis erste Bewegung}


  type

    { Der Ereignisrekord, der von GetMouseEvent Åbergeben wird }

         tMouseEvent = record
           Event: Word;                          { Eine der ev_ -Konstanten }
           Buttons: Byte;                        { Aktueller Tastenstatus   }
           Range: Byte;                          { Aktueller Mausbereich    }
           case Byte of
             0: ( Where: Longint );              { Der Einfachheit wegen    }
             1: ( MouseX: Integer;               { wird 1 Word pro Maus-    }
                  MouseY: Integer );             { koordinate verwendet     }
         end;

    { Dieser Record beschreibt das Aussehen des Mauscursors }

         tCursorView = record
           ScreenMask: Word;
           CursorMask: Word;
         end;

    { Typ fÅr den Bereichspuffer }

         tRangeBuf = array[0..1999] of Byte;



  function  InitMouse: Boolean;
  procedure DoneMouse;
  function  MouseState: Byte;
  function  MouseVisible: Integer;
  procedure ShowMouse;
  procedure HideMouse;
  procedure SetMoveArea( XA,YA,XB,YB: Byte );
  procedure SetMousePos( X,Y: Byte );
  procedure SetMouseSpeed( SpeedX, SpeedY: Integer );
  function  SetMouseRange( XA,YA,XB,YB, Code: Byte; Cursor: Longint ): Boolean;
  function  SwapRangeBuf( var RangeBuf ): Boolean;
  procedure GetMouseEvent( var Event: tMouseEvent );
  procedure ClearQueue;

  function  CursorDifChar( Character: Byte ): Word;
  function  CursorDifCol( Color: Byte ): Word;
  function  DefineCursor( Character, Color: Word ): Longint;
  function  DefineStdCursor( Cursor: Longint ): Longint;
  procedure SetCursor( Cursor: Longint );


implementation

  const  Copyright: pChar = '  Mouse handling routines (c) 1994 by UJR  ';

         EventQSize = 100;                       { Grîsse der Event-Queue   }

         ButtonCount:   Byte    = 0;             { Tastenanz. 0: keine Maus }
         CursorCount:   Integer = -1;            { Wert>=0: Cursor sichtbar }
         MouseEvents:   Boolean = False;         { True:Eventhandling aktiv }

  var    RangeCursor: array[1..MaxRanges] of Longint; { Cursortypen-Puffer  }
         StandardPtr: Longint;                   { Standard-Cursortyp       }
         RangeBuffer: tRangeBuf;                 { Mausbereichs-Puffer      }
         SaveExit: Pointer;                      { Old ExitProc address     }

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


  function SetMouseRange( XA,YA,XB,YB, Code: Byte; Cursor: Longint ): Boolean;
    var x,y,i: Word;
    begin
      SetMouseRange := False;
      if ( Code > MaxRanges ) or ( Code = 0 ) then Exit;
      RangeCursor[Code] := Cursor;
      for y := YA-1 to YB-1 do
        begin
          i := y*80+XA-1;
          for x := XA-1 to XB-1 do
            begin
              RangeBuffer[i] := Code;
              Inc( i );
            end;
        end;
      SetMouseRange := True;
    end;

  function SwapRangeBuf( var RangeBuf ): Boolean; assembler;
    asm
{ Austauschen des Inhaltes von RangeBuffer mit dem Inhalt des
  Speicherbereiches, auf welchen der Parameter RangeBuf zeigt. }
    end;

  procedure CheckRange; near; assembler;
    asm
        MOV     CX,MouseX
        DEC     CX
        MOV     AX,MouseY
        DEC     AX
        MOV     BL,80
        MUL     BL
        ADD     AX,CX
        MOV     SI,OFFSET DS:RangeBuffer
        ADD     SI,AX
        LODSB
        CMP     MouseRange,AL
        MOV     MouseRange,AL
        JE      @@2
        CMP     AL,NoRange
        JE      @@1
        DEC     AL
        MOV     SI,OFFSET DS:RangeCursor
        MOV     BL,4
        MUL     BL
        MOV     AH,0
        ADD     SI,AX
        LODSW
        MOV     BX,AX
        LODSW
        PUSH    AX
        PUSH    BX
        CALL    SetCursor
        JMP     @@2
  @@1:  MOV     SI,OFFSET DS:StandardPtr
        LODSW
        MOV     BX,AX
        LODSW
        PUSH    AX
        PUSH    BX
        CALL    SetCursor
  @@2:
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
        MOV     SI,CX
        MOV     CL,3
        SHR     SI,CL
        SHR     DX,CL
        INC     SI
        INC     DX
        MOV     MouseX,SI
        MOV     MouseY,DX
        MOV     ButtonState,BL
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
        XCHG    AX,SI
        STOSW
        XCHG    AX,DX
        STOSW
        CMP     DI,OFFSET EventQLast
        JNE     @@1
        MOV     DI,OFFSET EventQueue
  @@1:  MOV     EventQTail,DI
        INC     EventCount
  @@2:  CALL    CheckRange
    end;

  function MouseState: Byte; assembler;
    asm
        MOV     AL,ButtonCount
        CMP     AL,0Fh
        JE      @@1
        CMP     MouseEvents,1
        JE      @@1
        MOV     AL,0FFh
  @@1:
    end;

  function MouseVisible: Integer; assembler;
    asm
        MOV     AX,CursorCount
    end;

  procedure ShowMouse; assembler;
    asm
        CMP     MouseEvents,0
        JE      @@1
        MOV     AX,01h
        INT     33h
        INC     CursorCount
    @@1:
    end;

  procedure HideMouse; assembler;
    asm
        CMP     MouseEvents,0
        JE      @@1
        MOV     AX,02h
        INT     33h
        DEC     CursorCount
    @@1:
    end;

  procedure SetMoveArea( XA, YA, XB, YB: Byte ); assembler;
    asm
        CMP     MouseEvents,0
        JE      @@1
        MOV     CL,3
        MOV     SI,WORD PTR XA
        MOV     DX,WORD PTR XB
        DEC     SI
        DEC     DX
        SHL     SI,CL
        SHL     DX,CL
        MOV     CX,SI
        MOV     AX,07h
        INT     33h
        MOV     CL,3
        MOV     SI,WORD PTR YA
        MOV     DX,WORD PTR YB
        DEC     SI
        DEC     DX
        SHL     SI,CL
        SHL     DX,CL
        MOV     CX,SI
        MOV     AX,08h
        INT     33h
    @@1:
    end;

  procedure SetMousePos( X, Y: Byte ); assembler;
    asm
        CMP     MouseEvents,0
        JE      @@1
        MOV     SI,WORD PTR X
        MOV     DX,WORD PTR Y
        MOV     CL,3
        SHL     SI,CL
        SHL     DX,CL
        MOV     CX,SI
        MOV     AX,04h
        INT     33h
        CALL    CheckRange
  @@1:
    end;

  procedure SetMouseSpeed( SpeedX, SpeedY: Integer ); assembler;
    asm
        CMP     MouseEvents,0
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

  procedure SetCursor( Cursor: Longint ); assembler;
    asm
        CMP     MouseEvents,0
        JE      @@1
        MOV     AX,000Ah
        XOR     BX,BX
        MOV     CX,Cursor.Word[0]
        MOV     DX,Cursor.Word[2]
        INT     33h
  @@1:
    end;

  function DefineCursor( Character, Color: Word ): Longint; assembler;
    asm
        MOV     BX,Character
        AND     BX,00FFh
        MOV     AX,Color
        AND     AX,00FFh
        SHL     AX,08
        ADD     AX,BX
        MOV     BX,Character
        SHR     BX,08
        MOV     DX,Color
        AND     DX,0FF00h
        ADD     DX,BX
    end;

  function CursorDifChar( Character: Byte ): Word; assembler;
    asm
        MOV     AX,WORD PTR Character
        SHL     AX,8
    end;

  function CursorDifCol( Color: Byte ): Word; assembler;
    asm
        MOV     AX,WORD PTR Color
        SHL     AX,8
    end;

  function DefineStdCursor( Cursor: Longint ): Longint; assembler;
    asm
        MOV     BX,Cursor.Word[0]
        MOV     CX,Cursor.Word[2]
        MOV     AX,StandardPtr.Word[0]
        MOV     DX,StandardPtr.Word[2]
        MOV     StandardPtr.Word[0],BX
        MOV     StandardPtr.Word[2],CX
        CMP     MouseRange,NoRange
        JNE     @@1
        PUSH    AX
        PUSH    DX
        PUSH    CX
        PUSH    BX
        CALL    SetCursor
        POP     DX
        POP     AX
  @@1:
    end;

  procedure GetMouseEvent( var Event: tMouseEvent ); assembler;
    asm
        CMP     MouseEvents,0
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
  @@1:  MOV     SI,EventQHead
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
  @@2:  MOV     EventQHead,SI
        DEC     EventCount
  @@3:  STI
        CMP     SwapButton,0
        JE      @@4
        MOV     BH,BL
        AND     BH,3
        JE      @@4
        CMP     BH,3
        JE      @@4
        XOR     BL,3
  @@4:  MOV     BH,LastButtonState
        MOV     LastButtonState,BL
        MOV     AX,BX
        CMP     BH,BL
        JE      @@5
        OR      BH,BH
        JE      @@7
        OR      BL,BL
        JE      @@9
  @@5:  CMP     CX,LastMouseX
        JNE     @@10
        CMP     DX,LastMouseY
        JNE     @@10
        OR      BL,BL
        JE      @@6
        MOV     AX,DI
        SUB     AX,AutoTicks
        CMP     AX,AutoDelay
        JA      @@11
  @@6:  XOR     AX,AX
        MOV     BX,AX
        MOV     CX,LastMouseX
        MOV     DX,LastMouseY
        JMP     @@13
  @@7:  PUSH    CX
        XOR     AL,AH
        XOR     AH,AH
        MOV     AutoTicks,DI
        MOV     BX,RepeatDelay
        MOV     AutoDelay,BX
        MOV     BX,CX
        MOV     CL,1
        CMP     BX,DownMouseX
        JNE     @@8
        MOV     BX,DX
        CMP     BX,DownMouseY
        JNE     @@8
        MOV     BX,DI
        SUB     BX,LastClickTime
        CMP     BX,DoubleDelay
        JAE     @@8
        MOV     BX,LastClick
        SHR     BX,1
        CMP     BX,AX
        JNE     @@8
        MOV     CL,7
  @@8:  SHL     AX,CL
        MOV     LastClickTime,DI
        POP     CX
        MOV     DownMouseX,CX
        MOV     DownMouseY,DX
        MOV     LastClick,AX
        JMP     @@12
  @@9:  PUSH    CX
        MOV     CL,4
        XOR     AL,AH
        XOR     AH,AH
        SHL     AX,CL
        POP     CX
        JMP     @@12
  @@10: MOV     AX,ev_MouseMove
        XOR     BX,BX
        JMP     @@12
  @@11: MOV     AutoTicks,DI
        MOV     AutoDelay,1
        MOV     AX,ev_MouseAuto
  @@12: MOV     LastMouseX,CX
        MOV     LastMouseY,DX
        MOV     BX,WORD PTR LastButtonState
  @@13: CALL    StoreEvent
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

  function DetectMouse: Boolean; near; assembler;
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
  @@1:  MOV     ButtonCount,AL
    end;

  function InitMouse: Boolean; assembler;
    asm
        CALL    DetectMouse
        OR      AL,AL
        JE      @@2
        { Videomodus ÅberprÅfen: nur 80x25 Zeichen zugelassen }
        MOV     ES,Seg0040
        MOV     AL,ES:BYTE PTR 49h
        CMP     AL,02
        JE      @@1
        CMP     AL,03
        JE      @@1
        CMP     AL,07
        JE      @@1
        MOV     ButtonCount,0Fh
        XOR     AX,AX
        JMP     @@2
  @@1:  MOV     DI,OFFSET DS:RangeBuffer
        PUSH    DS
        POP     ES
        MOV     CX,1000                          { !! 2000 Bytes=1000 Words }
        MOV     AX,NoRange*256+NoRange
	CLD
	REP	STOSW
        { Variablen initialisieren }
        MOV     AX,8
        MOV     DoubleDelay,AX
        MOV     RepeatDelay,AX
        XOR     AX,AX
        MOV     SwapButton,AL
        MOV     LastClickTime,AX
        MOV     LastClick,AX
        MOV     LastButtonState,AL
        MOV     EventCount,AX
        MOV     CursorCount,AX
        DEC     CursorCount
        MOV     AX,OFFSET DS:EventQueue
        MOV     EventQHead,AX
        MOV     EventQTail,AX
        { Mausbereich festlegen }
        MOV     AX,0007h
        XOR     CX,CX
        MOV     DX,632 {79*8}
        INT     33h
        MOV     AX,0008h
        XOR     CX,CX
        MOV     DX,192 {24*8}
        INT     33h
        { Maus links oben }
        MOV     AX,0004h
        XOR     CX,CX
        XOR     DX,DX
        INT     33h
        { weitere Variablen initialisieren }
        MOV     AX,0003h
        INT     33h
        MOV     ButtonState,BL
        MOV     SI,CX
        MOV     CL,3
        SHR     SI,CL
        SHR     DX,CL
        MOV     MouseX,SI
        MOV     MouseY,DX
        MOV     LastMouseX,SI
        MOV     LastMouseY,DX
        { Event-Handler installieren }
        MOV     AX,0Ch
        MOV     CX,0FFFFh
        MOV     DX,OFFSET CS:MouseInt
        PUSH    CS
        POP     ES
        INT     33h
        { Standard-Cursor }
        MOV     AX,mc_SameChar
        PUSH    AX
        MOV     AX,mc_InvCol
        PUSH    AX
        CALL    DefineCursor
        MOV     StandardPtr.Word[0],AX
        MOV     StandardPtr.Word[2],DX
        { Start-Cursor setzen }
        MOV     AX,000Ah
        XOR     BX,BX
        MOV     CX,StartCursor.Word[0]
        MOV     DX,StartCursor.Word[2]
        INT     33h
        { Initialisierung erfolgreich }
        MOV     MouseEvents,1
        MOV     AL,1
   @@2:
    end;

  procedure DoneMouse; assembler;
    asm
        CMP     ButtonCount,0
        JE      @@1
        XOR     AX,AX
        MOV     MouseEvents,AL
        MOV     MouseX,AX
        MOV     MouseY,AX
        MOV     ButtonState,AL
        MOV     MouseRange,AL
        INT     33h
    @@1:
    end;

  procedure MouseExit; far;
    begin
      ExitProc := SaveExit;
      DoneMouse;
    end;

begin
  if Copyright = nil then;
  SaveExit := ExitProc;
  ExitProc := @MouseExit;
end.

{
  ErklÑuterungen zur Unit   T M O U S E


    Das Koordinatensystem der Unit TMouse:

       Ursprung: 0/0 (links oben)
       Ausmass:  80x25 Zeichen
       Ecke rechts unten: 79/24


    Die RÅckgabewerte der Funktion   M o u s e S t a t e

         0: Maus nicht ansprechbar oder noch nie initialisiert (InitMouse)
         1: Maus mit 1 Taste angeschlossen und ansprechbar
         2: Maus mit 2 Tasten angeschlossen und ansprechbar
         3: Maus mit 3 Tasten angeschlossen und ansprechbar
        15: Maus zwar ansprechbar, jedoch kein 80x25 Zeichen Video-Modus aktiv
       255: Maus war Ok, ist zur Zeit jedoch unberÅcksichtigt (nach DoneMouse)


    Das Eventhandling System   ( G e t M o u s e E v e n t )

       tEvent.Event
           ⁄ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒ¬ƒø
         15¿¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬¡¬Ÿ0
            ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ¿ƒ ev_MouseMove     = $0001
            ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ¿ƒƒƒ ev_LButtonDown   = $0002
             ohne be- ≥ ≥ ≥ ≥ ≥ ≥ ≥ ≥ ¿ƒƒƒƒƒ ev_RButtonDown   = $0004
             deutung  ≥ ≥ ≥ ≥ ≥ ≥ ≥ ¿ƒƒƒƒƒƒƒ ev_MButtonDown   = $0008
                      ≥ ≥ ≥ ≥ ≥ ≥ ¿ƒƒƒƒƒƒƒƒƒ ev_LButtonUp     = $0010
                      ≥ ≥ ≥ ≥ ≥ ¿ƒƒƒƒƒƒƒƒƒƒƒ ev_RButtonUp     = $0020
                      ≥ ≥ ≥ ≥ ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒ ev_MButtonUp     = $0040
                      ≥ ≥ ≥ ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ev_LButtonDblClk = $0080
                      ≥ ≥ ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ev_RButtonDblClk = $0100
                      ≥ ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ev_MButtonDblClk = $0200
                      ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ ev_MouseAuto     = $0400


       tEvent.Event     tEvent.Buttons  tEvent.Range  tEvent.Where
       ------------------------------------------------------------
       ev_MouseMove     Tasten-Status   Mausbereich   Maus-Position
       ev_LButtonDown   Tasten-Status   Mausbereich   Maus-Position
       :                :               :             :
       ev_MButtonDblClk Tasten-Status   Mausbereich   Maus-Position
       ev_MouseAuto     Tasten-Status   Mausbereich   Maus-Position
       ev_NoEvent       0               0             Maus-Position

}