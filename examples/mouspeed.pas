{***********************************************}
{                                               }
{    MOUSPEED                                   }
{    Demoprogramm zur Unit  MOUSE               }
{                                               }
{                                    UJR 1994   }
{***********************************************}

program MouSpeed;

uses     Crt, Graph, Mouse;

const    Path = 'c:\bp\bgi';        { Diese Konstante mÅssen sie evtl. ihren
                                      Verzeichnissen anpassen }
         ch: Char = #0;
         SpeedX: Integer = 0;
         SpeedY: Integer = 0;
         Speed: Byte = 0;
         OldSpeed: Byte = 1;

var      gd,gm: Integer;
         E: tMouseEvent;


begin
  gd := Detect;
  InitGraph( gd, gm, Path );
  DirectVideo := False;
  GotoXY( 1,1 );
  WriteLn('MOUSPEED - Demoprogramm zur Unit Mouse');
  GotoXY( 1,5 );
  Write('Linke und rechte Maustaste: verschiedene Geschwindigkeiten einstellen');
  GotoXY( 1,25 );
  Write('<ESC> Abbruch');
  MouseOn;
  ShowMouse;
  repeat
    if Speed <> OldSpeed then
      begin
        OldSpeed := Speed;
        case Speed of
          0: begin SpeedX :=  8; SpeedY :=  8 end;
             { Achtung: Aufrufe von SetMouseSpeed mit 0 werden ignoriert! }
             { Es bleiben folglich die vorherigen Einstellungen bestehen. }
          1: begin SpeedX := -1; SpeedY := -1 end;
          2: begin SpeedX := 40; SpeedY := 40 end;
          3: begin SpeedX := -4; SpeedY := 20 end;
          4: begin SpeedX :=  0; SpeedY :=  0 end;
          5: begin SpeedX :=  1; SpeedY :=  1 end;
        end;
        SetMouseSpeed( SpeedX, SpeedY );
        GotoXY( 1,20 );
        HideMouse;
        Write('X-Speed = ',SpeedX:3,'      Y-Speed = ',SpeedY:3 );
        ShowMouse;
      end;
    if KeyPressed then ch := ReadKey;
    GetMouseEvent( E );
    case E.Event of
      ev_LButtonDown: if Speed < 5 then Inc( Speed ) else Speed := 0;
      ev_RButtonDown: if Speed > 0 then Dec( Speed ) else Speed := 5;
    end;
  until ( ch = #27 );
  MouseOff;
  CloseGraph;
end.