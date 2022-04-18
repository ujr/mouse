program MausTest;
{$M $4000,0,65536}
uses  Crt, Dos, Graph, Mouse;

const Path: String = '.';



function PointInRange( X, Y, x1,y1,x2,y2: Integer ): Boolean;
  begin
    PointInRange := False;
    if ( X < x1 ) or ( X > x2 ) then Exit;
    if ( Y < y1 ) or ( Y > y2 ) then Exit;
    PointInRange := True;
  end;

function Beenden: Boolean;
  begin
    Beenden := False;
    Window( 20,16,46,19 );
    TextBackground( red );
    GotoXY( 20,16 ); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    GotoXY( 20,17 ); Write('³ Programm beenden? (j/n) ³');
    GotoXY( 20,18 ); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    TextBackground( blue );
    if UpCase( ReadKey ) = 'J' then Beenden := True
    else ClrScr;
    Window( 1,1,80,25 );
  end;

procedure MenuScreen;
  var i: Byte;
  begin
    TextBackground( blue );
    TextColor( cyan );
    ClrScr;
    Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Write('³                                                                              ³');
    Write('³    MAUSTEST                                                                  ³');
    Write('³    Ein Demonstrations- und Testprogramm zur Unit Mouse                       ³');
    Write('³    ---------------------------------------------------                       ³');
    Write('³                                                                              ³');
    Write('³                                                                              ³');
    Write('³      Demo zu den Cursorstilen des Graphikmodus (SetCursorStyle,...)          ³');
    Write('³      Demo zur Mauszeigerempfindlichkeit (SetMouseSpeed)                      ³');
    Write('³      Demo zur Cursorpositionseinstellung und -abfrage (SetMousePos, Get...)  ³');
    Write('³      Demo zur Einschr„nkung des Mausbereichs (SetMouseRange)                 ³');
    Write('³      Demo zu den vordefinierten Cursorstilen des Textmodus (SetTextCursor)   ³');
    Write('³      Demo zum Event-Manager                                                  ³');
    Write('³                                                                              ³');
    Write('³                                                                              ³');
    Write('³                                                                              ³');
    Write('³                                                                              ³');
    Write('³                                     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    Write('³                                     ³  Maustasten vertauschen:               ³');
    Write('³                                     ³  Doppelclickzeit:                      ³');
    Write('³                                     ³  Tasten-Haltezeit:                     ³');
    Write('³                                     ³  ÉÍÍÍÍÍÍÍÍ»                            ³');
    Write('³    Maustasten:                      ³  º ndern º                            ³');
    Write('³                                     ³  ÈÍÍÍÍÍÍÍÍ¼                            ³');
    Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ UJR 1994 ÄÄÄÄ');
    TextColor( 11 );
    GotoXY( 44,23 ); Write('ndern');
    GotoXY( 6,14 ); Write( 'X' );
    for i := 1 to 6 do
      begin
        GotoXY( 6,7+i ); Write( Chr( i+64 ));
      end;
    GotoXY( 21,23 ); Write( MouseButtons );
  end;

procedure UpdateMenuScreen;
  begin
    TextColor( 11 );
    GotoXY( 68,19 ); if ( SwapButtons ) then Write('Ja  ') else Write('Nein');
    GotoXY( 68,20 ); Write( DblClkTime:5,'    ' );
    GotoXY( 68,21 ); Write( AutoTime:5,'    ' );
  end;

procedure ExecProgram( PName: String );
  begin
    MouseOff;
    TextColor( 7 );
    TextBackground( 0 );
    ClrScr;
    SwapVectors;
    Exec(PName, '');
    SwapVectors;
    WriteLn;
    while KeyPressed do ReadKey;
    if DosError <> 0 then
      begin
        WriteLn('Dos error #', DosError,' !! Taste drcken');
        ReadKey;
      end;
    MouseOn;
    MenuScreen;
    UpdateMenuScreen;
    ShowMouse;
  end;

procedure NewEvMData;
  const x1 = 15;
        y1 = 05;
        x2 = 65;
        y2 = 20;
  var
        Background: Pointer;
        E: tMouseEvent;
        Zurueck: Boolean;
  begin
    Zurueck := False;
    HideMouse;
    GetMem( Background, 4000 );
    Move( Ptr( $B800, $0000 )^, Background^, 4000 );
    Window( x1,y1,x2,y2 );
    TextBackground( cyan );
    ClrScr;
    ShowMouse;
    WriteLn('   Eventmanager-Parameter einstellen');
    WriteLn(^J, '  Tasten vertauschen: ');
    WriteLn(^J, '  Doppelclickzeit:           (1/18.2 sec)');
    WriteLn(^J, '  Tasten-Haltezeit:          (1/18.2 sec)');
    WriteLn(^J,^J,^J,^J,'     ZURšCK');
    GotoXY( 1,9 ); Write('     (Eingaben mit Enter beenden)');
    GotoXY( 23,3 );
    if SwapButtons then Write('Ja  ') else Write('Nein');
    GotoXY( 21,5 );
    Write( DblClkTime );
    GotoXY( 21,7 );
    Write( AutoTime );
    repeat
      GetMouseEvent( E );
      if E.Event = ev_LButtonDown then
        if PointInRange( E.MouseX, E.MouseY, x1+2, y1+2, x1+40, y1+2 ) then
          begin
            SwapButtons := True xor SwapButtons;
            GotoXY( 23, 3 );
            HideMouse;
            if SwapButtons then Write('Ja  ') else Write('Nein');
            ShowMouse;
          end
        else if PointInRange( E.MouseX, E.MouseY, x1+2, y1+4, x1+40, y1+4 ) then
          begin
            GotoXY( 21,5 ); Write('       ');
            GotoXY( 21,5 ); Read( DblClkTime );
          end
        else if PointInRange( E.MouseX, E.MouseY, x1+2, y1+6, x1+40, y1+6 ) then
          begin
            GotoXY( 21,7 ); Write('       ');
            GotoXY( 21,7 ); Read( AutoTime );
          end
        else if PointInRange( E.MouseX, E.MouseY, x1+5, y1+11, x1+10, y1+11 ) then
          Zurueck := True;
    until (( E.Event and ev_AnyButtonDown <> 0 ) and not( PointInRange( E.MouseX, E.MouseY, x1,y1,x2,y2 ))) or Zurueck;
    HideMouse;
    Move( Background^, Ptr( $B800,$0000 )^, 4000 );
    FreeMem( Background, 4000 );
    Window( 1,1,80,25 );
    ShowMouse;
  end;

procedure EventDemo;
  var E: tMouseEvent;
      i: Byte;
      ExitDemo: Boolean;
      OldX, OldY: Byte;
  begin
    { Bildschirm aufbauen }
    HideMouse;
    Window( 2,2,79,24 );
    TextBackground( blue );
    TextColor( yellow );
    ClrScr;
    GotoXY( 33,2 ); Write(' Event-Manager Demonstration');
    GotoXY( 33,3 ); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    for i := 1 to 15 do
      begin
        GotoXY( 33,3+i ); Write('³                                           ³');
      end;
    GotoXY( 33,23 ); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    GotoXY( 2,1 ); Write('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
    for i := 1 to 21 do
      begin
        GotoXY( 2,1+i); Write('º                           º');
      end;
    GotoXY( 2,23); Write('ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
    GotoXY( 33,19 ); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    GotoXY( 33,20 ); Write('³ Einstellungen des Eventmanagers „ndern    ³');
    GotoXY( 33,21 ); Write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    GotoXY( 33,22 ); Write('³ Weiter mit Tastendruck oder Click hier    ³');
    Window( 4,3,30,23 );
    { Bewegungsbereich fr die Maus setzen }
    SetMouseRange( 35,5,77,23 );
    ShowMouse;
    ExitDemo := False;
    repeat
      GetMouseEvent( E );
      case E.Event of
        ev_MouseMove:     WriteLn(' ev_MouseMOVE     (',E.MouseX:2,'/',E.MouseY:2,')');
        ev_LButtonDown:   begin
                            WriteLn(' ev_LButtonDown');
                            if ( E.MouseY = 23 ) then
                              ExitDemo := True
                            else
                              if ( E.MouseY = 21 ) then
                                begin
                                  OldX := WhereX;
                                  OldY := WhereY;
                                  SetMouseRange( 1,1,80,25 );
                                  NewEvMData;
                                  SetMouseRange( 35,5,77,23 );
                                  Window( 4,3,30,23 );
                                  TextBackGround( blue );
                                  GotoXY( OldX, OldY );
                                end;
                          end;
        ev_RButtonDown:   WriteLn(' ev_RButtonDown');
        ev_MButtonDown:   WriteLn(' ev_MButtonDown');
        ev_LButtonUp:     WriteLn(' ev_LButtonUp');
        ev_RButtonUp:     WriteLn(' ev_RButtonUp');
        ev_MButtonUp:     WriteLn(' ev_MButtonUp');
        ev_LButtonDblClk: WriteLn(' ev_LButtonDblClk');
        ev_RButtonDblClk: WriteLn(' ev_RButtonDblClk');
        ev_MButtonDblClk: WriteLn(' ev_MButtonDblClk');
        ev_MouseAuto:     WriteLn(' ev_MouseAUTO     (',E.Buttons and 7,')');
      end;
    until KeyPressed or ExitDemo;
    HideMouse;
    Window( 1,1,80,25 );
    SetMouseRange( 0, 0, 79, 24 );
    MenuScreen;
    UpdateMenuScreen;
    ClearQueue;
    ShowMouse;
  end;

procedure RunDemo;
  var Ch: Char;
      Ende: Boolean;
      E: tMouseEvent;
  begin
    Ende := False;
    repeat
      GetMouseEvent( E );
      if ( E.Event = ev_LButtonDown ) or ( E.Event = ev_RButtonDown ) then
        begin
          if PointInRange( E.MouseX, E.MouseY, 43,23,50,23 ) then
            begin
              NewEvMData;
              TextBackground( blue );
              UpDateMenuScreen;
            end
          else if PointInRange( E.MouseX, E.MouseY, 6,8,6,8 ) then
            ExecProgram( Path+'CURSTYLE.EXE')
          else if PointInRange( E.MouseX, E.MouseY, 6,9,6,9 ) then
            ExecProgram( Path+'MOUSPEED.EXE')
          else if PointInRange( E.MouseX, E.MouseY, 6,10,6,10 ) then
            ExecProgram( Path+'MOUSEPOS.EXE')
          else if PointInRange( E.MouseX, E.MouseY, 6,11,6,11 ) then
            ExecProgram( Path+'MOURANGE.EXE')
          else if PointInRange( E.MouseX, E.MouseY, 6,12,6,12 ) then
            ExecProgram( Path+'TEXTCUR.EXE')
          else if PointInRange( E.MouseX, E.MouseY, 6,13,6,13 ) then
            EventDemo
          else if PointInRange( E.MouseX, E.MouseY, 6,14,6,14 ) then
            Ende := Beenden;
        end
      else
        begin
          if KeyPressed then
            begin
              Ch := UpCase( ReadKey );
              case Ch of
                #27: Ende := True;
                'A': ExecProgram( Path+'CURSTYLE.EXE');
                'B': ExecProgram( Path+'MOUSPEED.EXE');
                'C': ExecProgram( Path+'MOUSEPOS.EXE');
                'D': ExecProgram( Path+'MOURANGE.EXE');
                'E': ExecProgram( Path+'TEXTCUR.EXE');
                'F': EventDemo;
                'X': Ende := Beenden;
              end;
              HideMouse;
              MenuScreen;
              UpDateMenuScreen;
              ShowMouse;
            end;
        end;
    until Ende;
  end;


begin
  TextMode( CO80 );
  ClrScr;
  WriteLn('Geben sie den Pfad zu den .EXE-Dateien');
  Write('der Demoprogramme zur Unit Mouse an (z.B. c:\bp\units): ');
  ReadLn( Path );
  if Path = '' then Path := '.';
  if Copy( Path, Length( Path ), 1 ) <> '\' then Path := Path + '\';
  MouseOn;
  MenuScreen;
  UpDateMenuScreen;
  ShowMouse;
  RunDemo;
  MouseOff;
  TextColor( 7 );
  TextBackground( 0 );
  ClrScr;
end.