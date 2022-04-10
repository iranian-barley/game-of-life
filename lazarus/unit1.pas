unit Unit1;

{$mode objfpc}{$H+}

{
grundlegende Logik:
alt - neu | Fall
 0  -  0  |  0
 1  -  1  |  1
 0  -  1  |  2
 1  -  0  |  3
}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls;

const
  minzeile=0;
  maxzeile=40;
  minspalte=0;
  maxspalte=40;

type
  TSpielfeld=array[minzeile..maxzeile,minspalte..maxspalte] of integer;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioGroup1: TRadioGroup;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function nachbarn(z,s:integer):integer;
    function torusnachbarn(z,s:integer):integer;
    function totzellnachbarn(z,s:integer):integer;
    procedure aendern(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y:integer);
    procedure nextgeneration;
    procedure Timer1Timer(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private

  public
    Feld:array[minzeile..maxzeile,minspalte..maxspalte] of TShape;
    z: integer;
  end;

var
  Form1: TForm1;
  Spielfeld:TSpielfeld;

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.nachbarn(z,s:integer):integer;
begin
 if RadioButton1.Checked then result:=torusnachbarn(z,s)
 else result:=totzellnachbarn(z,s);
end;

function TForm1.totzellnachbarn(z,s:integer):integer;
var
  zaehler, i, k: integer;
begin
  zaehler:=0;
  for i:=z-1 to z+1 do // oben links
      begin
        for k:=s-1 to s+1 do // unten rechts
              if (i>=0) and (k>=0) and (Spielfeld[i,k] in [1,3]) then // erst >=0 Abfrage sonst Fehler
                 zaehler:=zaehler+1; // bei Zentrieren von Feld[0,0] fixen!!!
      end;
  result:=zaehler-Spielfeld[z,s];
end;

function TForm1.torusnachbarn(z,s:integer):integer;
var
  zaehler, i, k: integer;
begin
  zaehler:=0; // anderes Vorgehen als bei nachbarn():
  for i:=-1 to 1 do // Zaehlvariable mit Indices verrechnen
      begin
        for k:=-1 to 1 do
              if (Spielfeld[((z+i+maxzeile) mod maxzeile),((s+k+maxspalte) mod maxspalte)] in [1,3]) then
                 //      -1 in [minzeile..maxzeile] bzw. spalte zurueckgeworfen
                 zaehler:=zaehler+1;
      end;
  result:=zaehler-Spielfeld[z,s];
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Timer1.enabled then Timer1.enabled:=false else Timer1.enabled:=true;
end;

procedure TForm1.Button2Click(Sender: TObject);
var x,y:integer;
begin
 for x:=minzeile to maxzeile do for y:=minspalte to maxspalte do
    begin
      Spielfeld[x,y]:=0;
      Feld[x,y].Brush.color:=clwhite;
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  z:=0;
  nextgeneration;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  x,y:integer;
  S:TStringlist;
begin
 for x:=0 to maxzeile do for y:=0 to maxspalte do
    begin
       Spielfeld[x,y]:=0;
       Feld[x,y].Brush.Color:=clwhite;
    end;
  S := TStringList.Create();
  S.LoadFromFile('textfile.txt');
  for x := 0 to S.Count-1 do
     begin
       for y:=0 to length(S[x]) do
          begin
            if S[x][y]='O' then
               begin
                  Spielfeld[y,x]:=1; // warum andersrum?
                  Feld[y,x].Brush.Color:=clblack;
               end;
          end;
     end;
  S.Free();
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  z:=0;
  TrackBar1.position:=strtoint(Edit1.caption);
end;

procedure TForm1.FormActivate(Sender: TObject);
var
  x,y:integer;
begin
  for x:=minzeile to maxzeile do for y:=minspalte to maxspalte do Feld[x,y].OnMouseDown:=@aendern;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  x,y:integer;
begin
  for x:=minspalte to maxspalte do for y:=minspalte to maxspalte do
     begin
       Spielfeld[x,y]:=0;

       Feld[x,y]:=TShape.Create(Form1);
       Feld[x,y].parent:=Form1;

       Feld[x,y].height:=20;
       Feld[x,y].width:=20;

       Feld[x,y].top:=10+20*y;
       Feld[x,y].left:=10+20*x;

       Feld[x,y].OnMouseDown:=@aendern;
     end;
end;

procedure TForm1.aendern(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y:integer);
var
  a,b:integer;
  S:TShape;
begin
  S:= Sender as TShape;
  a:=(S.left-10) div 20;
  b:=(S.top-10) div 20;

  if Spielfeld[a,b]=1 then
    begin
      Spielfeld[a,b]:=0;
      Feld[a,b].brush.color:=clwhite;
    end
  else
     begin
      Spielfeld[a,b]:=1;
      Feld[a,b].brush.color:=clblack;
     end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 z:=z+1;
 Label1.caption:=inttostr(z);
 if z=TrackBar1.Position then
   begin
     z:=0;
     nextgeneration;
   end;
  //nextgeneration;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  z:=0;
  Edit1.caption:=inttostr(TrackBar1.position);
end;

procedure TForm1.nextgeneration;
var
  x,y:integer;
begin
  // durchgang 1
  for x:=minzeile to maxzeile do
      begin
        for y:=minspalte to maxspalte do
            begin
              if Spielfeld[x,y]=1 then
                 begin // aktuell mit Torusfeld
                   if (nachbarn(x,y)<2) or (nachbarn(x,y)>3) then
                      Spielfeld[x,y]:=3; // Fall 3
                 end;
              if Spielfeld[x,y]=0 then
                 begin
                   if (nachbarn(x,y)=3) then
                      Spielfeld[x,y]:=2; // Fall 2 s. Logik -> Rest bleibt
                 end;
            end;
      end;

  // durchgang 2
  for x:=minzeile to maxzeile do
      begin
        for y:=minspalte to maxspalte do
            begin
             case Spielfeld[x,y] of
                  //0: Feld[x,y].brush.color:=clwhite; // eigenitlich ueberfluessig
                  //1: Feld[x,y].brush.color:=clblack;
                  2: begin
                        Spielfeld[x,y]:=1;
                        Feld[x,y].brush.color:=clblack;
                     end;
                  3: begin
                        Spielfeld[x,y]:=0;
                        Feld[x,y].brush.color:=clscrollbar; // hier Leichen faerben
                     end;
             end;
            end;
      end;
end;


end.

