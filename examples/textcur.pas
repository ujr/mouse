{***********************************************}
{                                               }
{    TextCur                                    }
{    Demoprogramm zur Unit MOUSE                }
{                                               }
{                                    UJR 1994   }
{***********************************************}

program TextCur;

uses     Crt,Mouse;

var      i: Integer;
         E: tMouseEvent;
         Ch: Char;
         Co: Byte;
         Style: Integer;

begin
  TextBackground( black );
  TextColor( lightgray );
  ClrScr;
  WriteLn('   TEXTCUR - Demoprogramm zur Unit Mouse');
  WriteLn;
  WriteLn('Durch klicken mit der linken Maustaste werden die drei vordefinierten');
  WriteLn('Textcursorstile eingestellt. Bewegen sie den Mauszeiger Åber den');
  WriteLn('Bildschirm und beobachten sie, wie sich die VerknÅpfung von Cursor');
  WriteLn('und Hintergrund auswirkt.');
  WriteLn('Hinweis: Mit der Routine SetTextCursor kînnen sie alle mîglichen Text-');
  WriteLn('cursorarten einstellen, indem sie direkt die Screen- und Cursormask');
  WriteLn('Åbergeben. ');
  GotoXY( 1,11 );
  for i := 0 to 255 do
    Write( Chr( i ));
  GotoXY( 1,16 );
  for i := 0 to 255 do
    begin
      TextColor( i mod 15 );
      Write('€');
    end;
  TextColor( 7 );
  GotoXY( 1,25 );
  Write('Mit beliebiger Taste beenden');
  GotoXY( 1,23 );
  Write('Cursor-Stil: mc_TextStandard');
  MouseOn;
  ShowMouse;
  Style := mc_TextStandard;
  repeat
    GetMouseEvent( E );
    case E.Event of
      ev_MouseMove:
        begin
          GotoXY( 60,25 );
          Write( E.MouseX,'/',E.MouseY,'   ');
        end;
      ev_LButtonDown:
        begin
          if ( Style < mc_TextBlink ) then Inc( Style ) else Style := mc_TextStandard;
          SetCursorStyle( Style );
          GotoXY( 1,23 );
          case Style of
            mc_TextStandard: Write('Cursor-Stil: mc_TextStandard');
            mc_TextBlock:    Write('Cursor-Stil: mc_TextBlock   ');
            mc_TextBlink:    Write('Cursor-Stil: mc_TextBlink   ');
          end;
        end;
    end;
  until KeyPressed;
  while KeyPressed do ReadKey;
end.