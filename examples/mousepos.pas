{***********************************************}
{                                               }
{    MOUSEPOS                                   }
{    Demoprogramm zur Unit  MOUSE               }
{                                               }
{                                    UJR 1994   }
{***********************************************}

uses     Crt, Graph, Mouse;

const    Path = 'c:\bp\bgi';        { Diese Konstante mÅssen sie evtl. ihren
                                      Verzeichnissen anpassen }
var      gd,gm: Integer;
         E: tMouseEvent;
         x,y: Integer;

begin
  gd := Detect;
  InitGraph( gd, gm, Path );
  DirectVideo := False;
  GotoXY( 1,1 );
  Write('MOUSEPOS - Demoprogramm zur Unit Mouse');
  GotoXY( 1,5 );
  WriteLn('Immer wenn sie die linke Maustaste drÅcken, wird der Mauszeiger');
  WriteLn('an einen zufÑlligen Ort versetzt. Mit der rechten Maustaste beenden');
  WriteLn('sie das Programm. Im unteren Bildschirmteil wird die Mausposition an-');
  WriteLn('gegeben. Bewegen sie die Maus mal eine Weile wild umher, lassen sie');
  WriteLn('sie dann ruhig und beobachten sie die beiden Koordinatenangaben!');
  GotoXY( 20,20 ); WriteLn('Mausposition von GetMouseEvent (E.MouseX, E.MouseY)');
  GotoXY( 20,24 ); WriteLn('Mausposition von GetMousePos');
  MouseOn;
  ShowMouse;
  Randomize;
  repeat
    Delay( 5 ); { Symbolisch: Zeit verschwenden um Ereignispuffer zu fÅllen }
    GetMouseEvent( E );
    case E.Event of
      ev_LButtonDown:
        SetMousePos( Random( GetMaxX ), Random( GetMaxY ));
      ev_MouseMove:   begin
                        HideMouse;
                        GotoXY( 1,20 );
                        Write( E.MouseX:3,' / ',E.MouseY:3 );
                        ShowMouse;
                      end;
    end;
    GetMousePos( x,y );
    GotoXY( 1,24 );
    Write( x:3,' / ',y:3 );
  until E.Event = ev_RButtonDown;
  CloseGraph;
end.