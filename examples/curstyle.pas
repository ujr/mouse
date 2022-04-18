{***********************************************}
{                                               }
{    CURSTYLE                                   }
{    Demoprogramm zur Unit MOUSE                }
{                                               }
{                                    UJR 1994   }
{***********************************************}

program CurStyle;

uses     Crt, Graph, Mouse;

const    Path = 'c:\bp\bgi';     { Diese Konstante mÅssen sie evtl.
                                   ihren Verzeichnissen anpassen! }
         New: Boolean = True;
         NewCursor: tGraphCursor = (
           63, 31, 15, 32783, 49679, 49679, 49167, 49167,
           49183, 49215, 49215, 49183, 32783, 7, 7, 7,
           0, 32640, 16320, 6368, 6240, 6240, 6368, 8128,
           8064, 7936, 7040, 6528, 6592, 15584, 32368, 0 );


var      gd, gm: Integer;
         E: tMouseEvent;
         Style: Integer;
         S: String;

begin
  Style := 1;
  gd := Detect;
  InitGraph( gd, gm, Path );
  SetFillStyle( 5,5 );
  Bar( 20,20,100,300 );
  SetFillStyle( 9,9 );
  Bar( 120,20,220,300 );
  SetFillStyle( 1,15 );
  Bar( 240,20,340,300 );
  OutTextXY( 20, GetMaxY - 30, 'Doppelklick mit rechter Taste beendet das Programm.');
  OutTextXY( 20, GetMaxY - 140, 'Klick mit rechter oder linker Taste: neuer Cursor.');
  OutTextXY( 20, GetMaxY - 120, 'Doppelklick mit linker Taste: Åber die Routine SetGraphCursor');
  OutTextXY( 20, GetMaxY - 100, 'wird ein benutzerdefinierter Cursor angezeigt.');
  SetFillStyle( SolidFill, 0 );
  MouseOn;
  ShowMouse;
  repeat
    GetMouseEvent( E );
    case E.Event of
      ev_LButtonDown: begin
                        if ( Style < 14 ) then Inc( Style ) else Style := 1;
                        SetCursorStyle( Style );
                        New := True;
                      end;
      ev_RButtonDown: begin
                        if ( Style > 1 ) then Dec( Style ) else Style := 14;
                        SetCursorStyle( Style );
                        New := True;
                      end;
      ev_MouseAuto:   begin
                        if ( E.Buttons and mb_LeftButton = mb_LeftButton ) then
                          begin
                            if ( Style < 14 ) then Inc( Style ) else Style := 1;
                            SetCursorStyle( Style );
                          end;
                        if ( E.Buttons and mb_RightButton = mb_RightButton ) then
                          begin
                            if ( Style > 1 ) then Dec( Style ) else Style := 14;
                            SetCursorStyle( Style );
                          end;
                        New := True;
                      end;
      ev_LButtonDblClk: begin
                        SetGraphCursor( 7,7,NewCursor );
                        New := True;
                      end;
    end;
    if New then
      begin
        Str( GetCursorStyle, S );
        Bar( 20, GetMaxY-50, 300, GetMaxY-33 );
        OutTextXY( 20, GetMaxY-50, 'Cursorstil Nr. '+S );
        New := False;
      end;
  until ( E.Event = ev_RButtonDblClk ) or KeyPressed;
  while KeyPressed do ReadKey;
  MouseOff;
  CloseGraph;
end.