program Project1;

uses
    crt;

{
grundlegende Logik:
alt - neu | Fall
 0  -  0  |  0
 1  -  1  |  1
 0  -  1  |  2
 1  -  1  |  3
}

const
  minzeile=0;
  minspalte=0;
  maxzeile=10;
  maxspalte=40;

type
    TSpielfeld = array[minzeile..maxzeile,minspalte..maxspalte] of integer;

var
  Feld:TSpielfeld;
  die,born:set of byte;

function nachbarn(z,s:integer):integer;
var
  zaehler, i, k: integer;
begin
  zaehler:=0;
  for i:=z-1 to z+1 do // oben links
      begin
        for k:=s-1 to s+1 do // unten rechts
              if (i>=0) and (k>=0) and (Feld[i,k] in [1,3]) then // erst >=0 Abfrage sonst Fehler
                 zaehler:=zaehler+1;
      end;
  result:=zaehler-Feld[z,s];
end;

function torusnachbarn(z,s:integer):integer;
var
  zaehler, i, k: integer;
begin
  zaehler:=0; // anderes Vorgehen als bei nachbarn():
  for i:=-1 to 1 do // Zaehlvariable mit Indices verrechnen
      begin
        for k:=-1 to 1 do
              if (Feld[((z+i+maxzeile) mod maxzeile),((s+k+maxspalte) mod maxspalte)] in [1,3]) then
                 //      -1 in [minzeile..maxzeile] bzw. spalte zurueckgeworfen
                 zaehler:=zaehler+1;
      end;
  result:=zaehler-Feld[z,s];
end;

procedure regeln; // am Anfang eingestellte Regeln einlesen
begin
  born:=[3];
  die:=[0,1,4..9]; // nach alive:=[] bzw. Gegenteil suchen
end;

procedure init; // random Feld
var
  a,b:integer;
begin
  randomize;
  for a:=minzeile to maxzeile do
      begin
        for b:=minspalte to maxspalte do
            begin
              Feld[a,b]:=random(2);
            end;
      end;
end;

procedure ausgabe; // Ausgabe mit o
var
  a,b:integer;
begin
  for a:=minzeile to maxzeile-1 do // -1 sonst 1 zeile doppelt
      begin
        for b:=minspalte to maxspalte-1 do
            begin
              if Feld[a,b]=1 then
                 write('o')
              else
                write(' ');
            end;
        writeLn();
      end;
end;

procedure nextgeneration;
var
  x,y:integer;
begin
  // durchgang 1
  for x:=minzeile to maxzeile do
      begin
        for y:=minspalte to maxspalte do
            begin
              if Feld[x,y]=1 then
                 begin // aktuell mit Torusfeld
                   if (torusnachbarn(x,y) in die) then
                      Feld[x,y]:=3; // Fall 3 s. Logik
                 end;
              if Feld[x,y]=0 then
                 begin
                   if (torusnachbarn(x,y) in born) then
                      Feld[x,y]:=2; // Fall 2 s. Logik -> Rest bleibt
                 end;
            end;
      end;

  // durchgang 2
  for x:=minzeile to maxzeile do
      begin
        for y:=minspalte to maxspalte do
            begin                    // 2 und 3 binaer umwandeln s. Logik
              if Feld[x,y]=2 then
                 Feld[x,y]:=1;
              if Feld[x,y]=3 then
                 Feld[x,y]:=0;
            end;
      end;
end;

begin
  init;
  ausgabe;
  regeln;

  repeat
    ClrScr;
    nextgeneration;
    writeLn();
    ausgabe;
  until readkey=#27;
end.
