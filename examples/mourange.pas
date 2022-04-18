{***********************************************}
{                                               }
{    MOURANGE                                   }
{    Demoprogramm zur Unit MOUSE                }
{                                               }
{                                    UJR 1994   }
{***********************************************}

program MouRange;

uses     Crt, Graph, Mouse;

const    Path = 'c:\bp\bgi';           { Diese Konstante mÅssen sie evtl.
                                         ihren Verzeichnissen anpassen! }
         ButtonDown: Boolean = False;

var      gd,gm: Integer;
         E: tMouseEvent;
         x1,y1,x2,y2: Integer;


begin
  gd := Detect;
  InitGraph( gd, gm, Path );
  x1 := 0;
  y1 := 0;
  x2 := GetMaxX;
  y2 := GetMaxY;
  SetWriteMode( XORPut );
  DirectVideo := False;
  GotoXY( 1,2 );
  Write('   MOURANGE - Demoprogramm zur Unit Mouse');
  GotoXY( 1,5 );
  WriteLn(' Mit der linken Maustaste kînnen sie den Mausbereich bestimmen.');
  WriteLn(' Die rechte Taste setzt den Bereich wieder auf Bildschirmgrîsse zurÅck.');
  WriteLn(' Tastendruck beendet das Programm');
  MouseOn;
  Rectangle( x1,y1,x2,y2 );
  ShowMouse;
  repeat
    GetMouseEvent( E );
    case E.Event of
      ev_RButtonDown: begin
                        HideMouse;
                        Rectangle( x1,y1,x2,y2 );
                        x1 := 0;
                        y1 := 0;
                        x2 := GetMaxX;
                        y2 := GetMaxY;
                        SetMouseRange( x1,y1,x2,y2 );
                        Rectangle( x1,y1,x2,y2 );
                        ShowMouse;
                      end;
      ev_LButtonDown: begin
                        HideMouse;
                        Rectangle( x1,y1,x2,y2 );
                        x1 := E.MouseX;
                        y1 := E.MouseY;
                        x2 := x1;
                        y2 := y1;
                        Rectangle( x1,y1,x2,y2 );
                        ShowMouse;
                        ButtonDown := True;
                      end;
      ev_MButtonUp,
      ev_RButtonUp,
      ev_LButtonUp:   if ButtonDown then
                      begin
                        HideMouse;
                        Rectangle( x1,y1,x2,y2 );
                        x2 := E.MouseX;
                        y2 := E.MouseY;
                        SetMouseRange( x1,y1,x2,y2 );
                        Rectangle( x1,y1,x2,y2 );
                        ShowMouse;
                        ButtonDown := False;
                        ClearQueue;
                      end;
      ev_MouseMove:   if ButtonDown then
                      begin
                        HideMouse;
                        Rectangle( x1,y1,x2,y2 );
                        x2 := E.MouseX;
                        y2 := E.MouseY;
                        Rectangle( x1,y1,x2,y2 );
                        ShowMouse;
                      end;
    end;
  until KeyPressed;
  ReadKey;
  CloseGraph;
end.