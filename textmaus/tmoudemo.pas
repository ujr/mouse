uses Crt,TMouse;

var E: tMouseEvent;
    OldCursor,OldStdCursor: Longint;
    Status: Byte;

begin
  TextBackground( black );
  TextColor( lightgray );
  ClrScr;
  Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  Write('³                                                                              ³');
  Write('³         DEMOPROGRAMM ZUR UNIT   T M O U S E   Copyright 1995 by UJR          ³');
  Write('³                                                                              ³');
  Write('³   Bitte bewegen Sie die Maus ber den Bildschirm und beobachten Sie dabei,   ³');
  Write('³   wie sich dabei der Mauszeiger standortabh„ngig ver„ndert.                  ³');
  Write('³   Der Standard Mauszeiger (T) kann durch einen Click mit der rechten Taste,  ³');
  Write('³   w„hrend sich die Maus in einem undefiniertem Bereich (255) befindet, durch ³');
  Write('³   das Kreuz (#) und umgekehrt ausgetauscht werden.                           ³');
  Write('³   Zur Programmbeendigung bewegen Sie die Maus in die linke untere Ecke und   ³');
  Write('³   klicken Sie die linke Taste.                                               ³');
  Write('³   Im unteren Bildschirmteil werden wichtige Angaben ber die Maus angezeigt. ³');
  Write('³                                                                              ³');
  Write('³                                                                              ³');
  Write('³                                                                              ³');
  Write('³                                                                              ³');
  Write('³             ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿             ³');
  Write('³             ³ Mausbereich:      ³ Status der Maustasten:       ³             ³');
  Write('³             ³ X-Koordinate:     ³ Letztes Mausereignis:        ³             ³');
  Write('³             ³ Y-Koordinate:     ³                              ³             ³');
  Write('³             ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ             ³');
  Write('³                                                                              ³');
  Write('³                                                                              ³');
  Write('³                                                                              ³');
  Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  InitMouse;
  Status := MouseState;
  case Status of
      0: begin
           GotoXY( 29,23 );
           TextColor( white+blink );
           Write('Keine Maus ansprechbar!!');
         end;
    1..3:begin
           GotoXY( 29,23 );
           TextColor( 12 );
           Write('Ihre Maus hat ',Status,' Kn”fpe');
         end;
     15: begin
           DirectVideo := False;
           ClrScr;
           TextColor( white+blink );
           Write('Falscher Video-Modus fr Unit TMouse!!');
           repeat until KeyPressed;
           Halt;
         end;
  end;
  DefineStdCursor( DefineCursor( CursorDifChar( Ord('T')), mc_SameColB ));
  OldStdCursor := DefineCursor( CursorDifChar( Ord('#')), CursorDifCol( 5 ));
  SetMouseRange( 1, 1, 80, 1, 1, DefineCursor( CursorDifChar( $18 ), mc_InvCol ));
  SetMouseRange( 1, 2, 1, 24, 2, DefineCursor( CursorDifChar( $1B ), mc_InvCol ));
  SetMouseRange( 1, 25, 79, 25, 3, DefineCursor( CursorDifChar( $19 ), mc_InvCol ));
  SetMouseRange( 80, 2, 80, 24, 4, DefineCursor( CursorDifChar( $1A ), mc_InvCol ));
  SetMouseRange( 80, 25, 80, 25, 5, DefineCursor( CursorDifChar( $58 ), CursorDifCol( $40 )));
  SetMouseRange( 10,5,70,20, 6, DefineCursor( CursorDifChar( Ord('X')), mc_InvColB ));
  SetMouseRange( 15,17,66,21,7, DefineCursor( mc_SameChar, CursorDifCol( 11 )));
  TextColor( 12 );
  ShowMouse;
  repeat
    GetMouseEvent( E );
    case E.Event of
      ev_MouseMove:     begin
                          GotoXY( 31,18 );
                          Write( MouseRange:3 );
                          GotoXY( 32,19 );
                          Write( MouseX:2 );
                          GotoXY( 32,20 );
                          Write( MouseY:2 );
                          GotoXY( 39,20 );
                          Write('ev_MouseMove    ');
                        end;
      ev_LButtonDown:   begin
                          GotoXY( 39,20 );
                          Write('ev_LButtonDown  ');
                          if MouseRange <> 5 then
                            SetMousePos( Random( 79 )+1, Random( 24 )+1 );
                        end;
      ev_LButtonUp:     begin
                          GotoXY( 39,20 );
                          Write('ev_LButtonUp    ');
                        end;
      ev_LButtonDblClk: begin
                          GotoXY( 39,20 );
                          Write('ev_LButtonDblClk');
                        end;
      ev_RButtonDown:   begin
                          if MouseRange = NoRange then
                            begin
                              OldCursor := DefineStdCursor( OldStdCursor );
                              OldStdCursor := OldCursor;
                            end;
                          GotoXY( 39,20 );
                          Write('ev_RButtonDown  ');
                        end;
      ev_RButtonUp:     begin
                          GotoXY( 39,20 );
                          Write('ev_RButtonUp    ');
                        end;
      ev_RButtonDblClk: begin
                          GotoXY( 39,20 );
                          Write('ev_RButtonDblClk');
                        end;
      ev_MButtonDown:   begin
                          GotoXY( 39,20 );
                          Write('ev_MButtonDown  ');
                        end;
      ev_MButtonUp:     begin
                          GotoXY( 39,20 );
                          Write('ev_MButtonUp    ');
                        end;
      ev_MButtonDblClk: begin
                          GotoXY( 39,20 );
                          Write('ev_MButtonDblClk');
                        end;
      ev_MouseAuto:     begin
                          GotoXY( 39,20 );
                          Write('ev_MouseAuto    ');
                        end;
    end;
    if E.Event and ev_AnyButtonEvent <> 0 then
      begin
        GotoXY( 60,18 );
        if E.Buttons and mb_LeftButton = mb_LeftButton then
          Write('Û ')
        else
          Write('l ');
        if E.Buttons and mb_MiddleButton = mb_MiddleButton then
          Write('Û ')
        else
          Write('m ');
        if E.Buttons and mb_RightButton = mb_RightButton then
          Write('Û')
        else
          Write('r');
      end;
  until ( E.Event = ev_LButtonUp ) and ( MouseRange = 5 ) or KeyPressed;
  TextColor( 7 );
  ClrScr;
end.