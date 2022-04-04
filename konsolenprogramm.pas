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
  zeile=20;
  spalte=50;

type
    TSpielfeld = array[1..zeile,1..spalte] of integer;

var
  Feld:TSpielfeld;
  x,y:integer;

function nachbarn(z,s:integer):integer;
var
  zaehler, i, k: integer;
begin
  zaehler:=0;
  for i:=z-1 to z+1 do // oben links
      begin
        for k:=s-1 to s+1 do // unten rechts
              if (Feld[i,k] in [1,3]) and (i>=0) and (k>=0) then
                 zaehler:=zaehler+1;
      end;
  result:=zaehler-Feld[z,s];
end;

procedure init; // random Feld
var
  a,b:integer;
begin
  randomize;
  for a:=1 to zeile do
      begin
        for b:=1 to spalte do
            begin
              Feld[a,b]:=random(2);
            end;
      end;
end;

procedure ausgabe; // binaere Ausgabe
var
  a,b:integer;
begin
  for a:=1 to zeile do
      begin
        for b:=1 to spalte do
            begin
              write(Feld[a,b]);
            end;
        writeLn();
      end;
end;

procedure ausgabe2; // Ausgabe mit #
var
  a,b:integer;
begin
  for a:=1 to zeile do
      begin
        for b:=1 to spalte do
            begin
              if Feld[a,b]=1 then
                 write('#')
              else
                write(' ');
            end;
        writeLn();
      end;
end;

begin
  init;
  ausgabe2;

  repeat
    ClrScr;
    for x:=1 to zeile do
      begin
        for y:=1 to spalte do
            begin
              if Feld[x,y]=1 then
                 begin
                   if (nachbarn(x,y)<2) or (nachbarn(x,y)>3) then
                      Feld[x,y]:=3; // Fall 3 s. Logik
                 end;
              if Feld[x,y]=0 then
                 begin
                   if (nachbarn(x,y)=3) then
                      Feld[x,y]:=2; // Fall 2 s. Logik -> Rest bleibt
                 end;
            end;
      end;


  for x:=1 to zeile do
      begin
        for y:=1 to spalte do
            begin                    // 2 und 3 binaer umwandeln s. Logik
              if Feld[x,y]=2 then
                 Feld[x,y]:=1;
              if Feld[x,y]=3 then
                 Feld[x,y]:=0;
            end;
      end;

  writeLn();
  ausgabe2;
  until readkey=#27;
end.
