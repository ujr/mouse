{*********************************************************************}
{                                                                     }
{        S T Y L E S                                                  }
{                                                                     }
{        Dieses Programm dient der Erzeugung von Mauszeigern          }
{        f걊 den Grafik-Modus. Eventuell als Demoprogramm zur         }
{        Unit MOUSE mitgeben.                                         }
{                                                                     }
{        Copyright (c) 1994,1995 by Urs-Jakob R갻tschi       1994     }
{                                                                     }
{*********************************************************************}

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
  Last update: 3.12.95
  쉇ersetzung: Compilieren mit Borland Pascal 7.0
  Information: Dieses Programm wurde irgendwann im 1994 entwickelt als
               Zusatz und Demo zur Unit MOUSE. Bei Weitergabe als EXE-
               Datei, folgende Anleitung mitgegeben:

  "Das Programm Styles l꼜st sie auf einfache Weise Grafikcursors er-
  stellen, die sie dann in ihren Programmen verwenden k봭nen. Die
  Benutzeroberfl꼊he verf갾t 갶er zwei 16x16 - Gitter, eines f걊 die
  Screenmask (gesetzte Punkte sichern den Hintergrund, nicht gesetzte
  machen ihn schwart) und eines f걊 die Cursormask (gesetzte Punkte
  werden als Cursor gezeichnet). Der rote Punkt bezeichnet der Hotspot
  (also den Bezugspunkt des Cursors) und kann durch Doppelklicks mit
  der linken Taste beliebig versetzt werden. Mit der rechten Maustaste
  k봭nen sie zwischen dem Standard-Pfeil-Cursor und ihrem eigenen
  Cursor wechseln. Das Programm beenden sie mit einem Tastendruck. Sie
  werden daraufhin gefragt, ob sie den Cursor speichern wollen. Wenn
  sie 'j' oder 'J' eingeben, wird eine Datei namens 'CURSOR.CUR' im
  aktuellen Verzeichnis erzeugt, die von folgender Form ist:

    HotSpotX = ...  (X-Koordinate des Hotspots)
    HotSpotY = ...  (Y-Koordinate des Hotspots)
    NewCursor: tGraphCursor = (
      ... ( hier folgen 32 Word-Zahlen, die ihren Cursor beschreiben )
    );

  Diese Datei k봭nen sie dann in Ihr Programm aufnehmen und wenn sie
  den Cursorstil anwenden wollen, 갶ergeben sie einfach HotSpotX,
  HotSpotY und NewCursor in dieser Reihenfolge als Parameter an die
  Prozedur SetGraphCursor.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}

program STYLES;

uses     Crt, Graph, Mouse;

const    Path: String = 'c:\bp\bgi';    { Default-Path }
         SwapCursor: Boolean = False;
         ESC = #27;

var      gd,gm: Integer;
         ScreenMask: array[0..15,0..15] of Boolean;
         CursorMask: array[0..15,0..15] of Boolean;
         NewCursor: tGraphCursor;
         HotSpotX: Integer;
         HotSpotY: Integer;
         E: tMouseEvent;
         Style: Integer;
         Sx,Sy: String;
         i,j,x,y: Integer;
         OldX,OldY: Integer;
         Mask: Byte;
         Ch: Char;
         F: Text;
         DrawMode: Byte;
         Error: Integer;


function PointInRange( X,Y, x1,y1,x2,y2: Integer ): Boolean;
begin
  PointInRange := False;
  if ( X < x1 ) or ( X > x2 ) then Exit;
  if ( Y < y1 ) or ( Y > y2 ) then Exit;
  PointInRange := True;
end;

procedure Init;
begin
  OldX := 0;
  OldY := 0;
  HotSpotX := 0;
  HotSpotY := 0;
  SetFillStyle( SolidFill,15 );
  Bar( 450, 340, 600, 430 );
  for i := 0 to 15 do
    for j := 0 to 15 do
      begin
        ScreenMask[i,j] := False;
        CursorMask[i,j] := False;
      end;
  for i := 0 to 31 do NewCursor[i] := $0000;
  OutTextXY( 20, 20, 'STYLES 1.2 - Mauszeiger erstellen');
  OutTextXY( 340, 20, 'Copyright (c) 1994, 1995 by UJR');
  OutTextXY( 40, 45, 'Screen-Mask' );
  OutTextXY( 360, 45, 'Cursor-Mask' );
  OutTextXY( 20, 340, 'Linke Maustaste:   Pixel setzen/l봲chen');
  OutTextXY( 20, 360, 'Doppelklick links: Hot-Spot setzen');
  OutTextXY( 20, 380, 'Rechte Maustaste:  Neuen Cursor verwenden');
  OutTextXY( 20, 400, 'Taste ESC:         Beenden (Cursor speichern)');
  for i := 0 to 16 do
    begin
      Line( 20, 60+i*16, 276, 60+i*16 );
      Line( 340, 60+i*16, 596, 60+i*16 );
    end;
  for i := 0 to 16 do
    begin
      Line( 20+i*16, 60, 20+i*16, 316 );
      Line( 340+i*16, 60, 340+i*16, 316 );
    end;
end;

function GetMaskCoordinates( var Mx,My: Integer; var Mask: Byte ) : Boolean;
var Result: Boolean;
    Found: Boolean;
    x,y: Integer;
begin
  Result := False;
  if PointInRange( Mx, My, 20,60,276,316 ) then
    begin
      Mask := 1;
      Found := False;
      x := 0;
      y := 0;
      while not Found do
        begin
          if PointInRange( Mx, My, 20+x*16, 60+y*16, 36+x*16, 76+y*16 ) then
            Found := True
          else
            if ( x < 15 ) then
              Inc( x )
            else
              begin
                x := 0;
                Inc( y );
              end;
        end;
      Mx := x;
      My := y;
      Result := True;
    end
  else
    if PointInRange( Mx, My, 340,60,596,316 ) then
      begin
        Mask := 2;
        Found := False;
        x := 0;
        y := 0;
        while not Found do
          begin
            if PointInRange( Mx, My, 340+x*16, 60+y*16, 356+x*16, 76+y*16 ) then
              Found := True
            else
              if ( x < 15 ) then
                Inc( x )
              else
                begin
                  x := 0;
                  Inc( y );
                end;
          end;
        Mx := x;
        My := y;
        Result := True;
      end;
  GetMaskCoordinates := Result;
end;

procedure CompileNewCursor;
begin
  for i := 0 to 31 do
    begin
      NewCursor[i] := 0;
      if ( i div 16 = 0 ) then
        begin  { ScreenMask }
          for j := 0 to 15 do
            if ScreenMask[j,i mod 16] then
              Inc( NewCursor[i], 32768 shr j );
        end
      else
        begin  { CursorMask }
          for j := 0 to 15 do
            if CursorMask[j,i mod 16] then
              Inc( NewCursor[i], 32768 shr j );
        end;
    end;
end;

procedure MakeCursorFile;
begin
  CompileNewCursor;
  Assign( F, 'CURSOR.CUR' );
  {$I-} Rewrite( F ); {$I+}
  if IOResult <> 0 then
    begin
      ClrScr;
      WriteLn('Fehler beim speichern des Cursors!!!',^J,'Programm abgebrochen.');
      Halt;
    end;
  WriteLn( F, 'HotSpotX: ',HotSpotX );
  WriteLn( F, 'HotSpotY: ',HotSpotY );
  WriteLn( F, 'NewCursor: tGraphCursor = (');
  for i := 0 to 2 do
    WriteLn( F, NewCursor[i*8+0],', ',NewCursor[i*8+1],', ',NewCursor[i*8+2],', ',NewCursor[i*8+3],', ',
                NewCursor[i*8+4],', ',NewCursor[i*8+5],', ',NewCursor[i*8+6],', ',NewCursor[i*8+7],',' );
  WriteLn( F, NewCursor[24],', ',NewCursor[25],', ',NewCursor[26],', ',NewCursor[27],', ',
              NewCursor[28],', ',NewCursor[29],', ',NewCursor[30],', ', NewCursor[31],');');
  Close( F );
end;

procedure UpDateMasks;
begin
  if ( Mask = 1 ) then
    begin
      case DrawMode of
        1: ScreenMask[x,y] := True;
        2: ScreenMask[x,y] := False;
      else
        ScreenMask[x,y] := True xor ScreenMask[x,y]
      end;
      if ( ScreenMask[x,y] ) then
        SetColor( white )
      else
        SetColor( black );
      Circle( 28+x*16, 68+y*16, 5 );
      SetColor( white );
    end
  else
    begin
      case DrawMode of
        1: CursorMask[x,y] := True;
        2: CursorMask[x,y] := False;
      else
        CursorMask[x,y] := True xor CursorMask[x,y];
      end;
      if ( CursorMask[x,y] ) then
        SetColor( white )
      else
        SetColor( black );
      Circle( 348+x*16, 68+y*16, 5 );
      Circle( 28+x*16, 68+y*16, 2 );
      SetColor( white );
    end;
end;


begin
  if not MouseAvail then
    begin
      WriteLn('Keine Maus kann angesprochen werden!');
      WriteLn('Das Programm STYLES ben봳igt eine Maus!');
      Halt;
    end;
  repeat
    DetectGraph( gd, gm );
    if gd <> VGA then
      begin
        WriteLn('Dieses Programm wurde f걊 die VGA-Karte entwickelt.');
        WriteLn('Vielleicht werden Sie Problemen begegnen!');
        Write('Taste dr갷ken...');
        repeat until KeyPressed;
        while KeyPressed do ReadKey;
      end;
    InitGraph( gd, gm, Path );
    Error := GraphResult;
    if ( Error = grFileNotFound ) or ( Error = grInvalidDriver ) then
      begin
        WriteLn(#13#10'Geben sie den Pfad zu ihren .BGI-Dateien ein oder');
        WriteLn('dr갷ken sie <Ctrl>+<Break> um das Programm zu beenden!');
        Write(#13#10'Pfad: ');
        ReadLn( Path );
      end
    else
      if Error <> grOk then
        begin
          WriteLn('Grafikmodus kann nicht initialisiert werden!');
          Halt;
        end;
  until Error = grOk;
  Init;
  SetColor( lightred );
  Circle( 348+HotSpotX*16, 68+HotSpotY*16, 3 );
  Circle( 348+HotSpotX*16, 68+HotSpotY*16, 2 );
  SetColor( white );
  MouseOn;
  ShowMouse;
  DoubleMoveX := 3;
  DoubleMoveY := 3;
  Style := GetCursorStyle;
  SetFillStyle( SolidFill, 0 );
  repeat
    if KeyPressed then
      begin
        Ch := ReadKey;
        if Ch = #0 then Ch := ReadKey;
      end;
    GetMouseEvent( E );
    case E.Event of
      ev_MouseMove:
        begin
          x := E.MouseX;
          y := E.MouseY;
          Str( E.MouseX, Sx );
          Str( E.MouseY, Sy );
          Bar( 20, 450, 120, 465 );
          OutTextXY( 20, 450, Sx+'/'+Sy );
          if GetMaskCoordinates( x,y,Mask ) then
            if ( E.Buttons = mb_LeftButton ) then
              if ( x <> OldX ) or ( y <> OldY ) then
                begin
                  OldX := x;
                  OldY := y;
                  HideMouse;
                  UpdateMasks;
                  ShowMouse;
                end;
        end;
      ev_LButtonDblClk:
        begin
          x := E.MouseX;
          y := E.MouseY;
          if GetMaskCoordinates( x, y, Mask ) then
            begin
              HideMouse;
              SetColor( black );
              Circle( 348+HotSpotX*16, 68+HotSpotY*16, 3 );
              Circle( 348+HotSpotX*16, 68+HotSpotY*16, 2 );
              HotSpotX := x;
              HotSpotY := y;
              SetColor( lightred );
              Circle( 348+HotSpotX*16, 68+HotSpotY*16, 3 );
              Circle( 348+HotSpotX*16, 68+HotSpotY*16, 2 );
              SetColor( white );
              ShowMouse;
            end
          else
            begin
              Sound( 500 );
              Delay( 20 );
              NoSound;
            end;
        end;
      ev_LButtonDown:
        begin
          x := E.MouseX;
          y := E.MouseY;
          if GetMaskCoordinates( x, y, Mask ) then
            begin
              if Mask = 1 then
                begin
                  if ScreenMask[x,y] then DrawMode := 2 else DrawMode := 1;
                end
              else
                if CursorMask[x,y] then DrawMode := 2 else DrawMode := 1;
              HideMouse;
              UpDateMasks;
              ShowMouse;
            end;
        end;
      ev_LButtonUp: DrawMode := 3;
      ev_RButtonUp:
        begin
          CompileNewCursor;
          if ( SwapCursor ) then
            SetCursorStyle( Style )
          else
            SetGraphCursor( HotSpotX, HotSpotY, NewCursor );
          SwapCursor := True xor SwapCursor;
        end;
    end;
  until Ch = ESC;
  CloseGraph;
  MouseOff;
  Write('Speichern? (j/n) ');
  while KeyPressed do ReadKey;
  repeat
    Ch := UpCase( ReadKey );
  until Ch in ['J','N'];
  WriteLn( Ch );
  if Ch = 'J' then MakeCursorFile;
end.