unit Unit1;

{$mode objfpc}{$H+}

{
grundlegende Logik für alle Rechen- und Färbevorgänge für nächste Generation:
alt - neu | Fall
 0  -  0  |  0
 1  -  1  |  1
 0  -  1  |  2
 1  -  0  |  3
}

{
Spielfeld[x,y] immer getrennt überschreiben von Feld[x,y]!
bzw. Rechenvorgänge und Färbevorgänge getrennt, nie in *einer* for-Schleife
}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Menus;

const
  minzeile=0;
  maxzeile=100;
  minspalte=0;
  maxspalte=100;
  minzoom=30;
  maxzoom=70;
  quadrat=15; // Höhe Quadrat

type
  TSpielfeld=array[minzeile..maxzeile,minspalte..maxspalte] of byte; // effizienter als integer

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
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
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function nachbarn(z,s:integer):integer;
    procedure aendern(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y:integer);
    procedure nextgeneration;
    procedure faerben;
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

function TForm1.nachbarn(z,s:integer):integer; {Christian}
var
  zaehler,i,k:integer;
begin
 zaehler:=0;

 if RadioButton1.Checked then // Torusspielfeld
    begin
      for i:=-1 to 1 do // Zaehlvariable mit Indices verrechnen
       begin
        for k:=-1 to 1 do
              if (Spielfeld[((z+i+maxzeile) mod maxzeile),((s+k+maxspalte) mod maxspalte)] in [1,3]) then
                 //      -1 in [minzeile..maxzeile] bzw. spalte zurueckgeworfen
                 zaehler:=zaehler+1;
       end;
    end

 else  // Rand aus toten Zellen
     begin
       for i:=z-1 to z+1 do // oben links
       begin
        for k:=s-1 to s+1 do // unten rechts
              if (i>=0) and (k>=0) and (Spielfeld[i,k] in [1,3]) then // erst >=0 Abfrage sonst keine "tote Zelle"
                 zaehler:=zaehler+1;
       end;
     end;
                                                                      // OOO
 result:=zaehler-Spielfeld[z,s]; // Wert des mittleren Feldes raus    // O.O
end;                                                                  // OOO

procedure TForm1.Button1Click(Sender: TObject); {Nils}
begin
  if Timer1.enabled then Timer1.enabled:=false else Timer1.enabled:=true;
end;

procedure TForm1.Button2Click(Sender: TObject); {Nils}
var x,y:integer;
begin
 for x:=minzeile to maxzeile do for y:=minspalte to maxspalte do
    begin
      Spielfeld[x,y]:=0;
    end;

 CheckBox1.Checked:=False;
 faerben;
end;

procedure TForm1.Button3Click(Sender: TObject); {Nils}
begin
  z:=0;
  nextgeneration;
end;

procedure TForm1.Button4Click(Sender: TObject); {Christian}
var
  x,y:integer;
begin
  CheckBox1.Checked:=False;
  randomize;
  for x:=minspalte to maxzeile do for y:=minspalte to maxspalte do
     Spielfeld[x,y]:=random(2);
  faerben;
end;

procedure TForm1.ComboBox1Change(Sender: TObject); {Christian}
var
  x,y:integer;
  S:TStringlist;
begin
 for x:=0 to maxzeile do for y:=0 to maxspalte do
    begin
       Spielfeld[x,y]:=0;
    end;

 CheckBox1.Checked:=False;
 faerben;

  S := TStringList.Create();
  S.LoadFromFile(Application.Location+'\patterns\'+ComboBox1.Items[ComboBox1.ItemIndex]+'.txt'); // Pfad zur Pattern-Datei
  for x := 0 to S.Count-1 do
     begin
       for y:=0 to length(S[x]) do
          begin
            if S[x][y]='O' then
               Spielfeld[y+50-(length(S[x]) div 2),x+50-(length(S[x]) div 2)]:=1; // Pattern zentrieren
          end;
     end;

  faerben;

  S.Free(); // Effizienz (!!)
end;

procedure TForm1.Edit1Change(Sender: TObject); {Nils}
begin
  z:=0;
  TrackBar1.position:=strtoint(Edit1.caption);
end;

procedure TForm1.FormCreate(Sender: TObject); {Nils}
var
  x,y:integer;
begin
  for x:=minspalte to maxspalte do for y:=minspalte to maxspalte do
       Spielfeld[x,y]:=0;

  for x:=minzoom to maxzoom do for y:=minzoom to maxzoom do
     begin

       Feld[x,y]:=TShape.Create(Form1);
       Feld[x,y].parent:=Form1;

       Feld[x,y].height:=quadrat;
       Feld[x,y].width:=quadrat;

       Feld[x,y].top:=30+quadrat*(y-minzoom); // fuer oben links (x,y-10) hinrichten
       Feld[x,y].left:=30+quadrat*(x-minzoom);

       Feld[x,y].OnMouseDown:=@aendern;
     end;
end;

procedure TForm1.aendern(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,Y:integer); {hpts. Nils}
var
  a,b:integer;
  S:TShape;
begin
  S:= Sender as TShape;
  a:=((S.left-30) div quadrat)+minzoom;
  b:=((S.top-30) div quadrat)+minzoom;

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

procedure TForm1.Timer1Timer(Sender: TObject); {Nils}
begin
 z:=z+1;
 Label1.caption:=inttostr(z);
 if z=TrackBar1.Position then
   begin
     z:=0;
     nextgeneration;
   end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject); {Nils}
begin
  z:=0;
  Edit1.caption:=inttostr(TrackBar1.position);
end;

procedure TForm1.nextgeneration; {Christian}
var
  x,y:integer;
begin
 // Durchgang 1: Jeder Zelle einen Fall zuweisen s. Logik
 for x:=minzeile to maxzeile do for y:=minspalte to maxspalte do
    begin
       if Spielfeld[x,y]=1 then // Zelle hat Wert 1 -> stirbt sie?
           begin
             if (nachbarn(x,y)<2) or (nachbarn(x,y)>3) then
                Spielfeld[x,y]:=3; // Fall 3
           end
        else // Zelle hat Wert 0 -> wird sie lebendig?
           begin
             if (nachbarn(x,y)=3) then
                Spielfeld[x,y]:=2; // Fall 2 s. Logik -> Rest bleibt
           end;
    end;

  faerben;  // s. Kommentar 2

  // Durchgang 2: Fälle nach Logik in 1 und 0 konvertieren für nächste Generation
  for x:=minzeile to maxzeile do for y:=minspalte to maxspalte do
      begin
        case Spielfeld[x,y] of
              2: Spielfeld[x,y]:=1;
              3: Spielfeld[x,y]:=0;
        end;
      end;
end;

procedure TForm1.faerben; {Christian}
var
  x,y:integer;
begin
 for x:=minzoom to maxzoom do for y:=minzoom to maxzoom do
     begin
       if CheckBox1.Checked then // Leichen einfärben
           begin
             case Spielfeld[x,y] of
                  2: Feld[x,y].brush.color:=clblack;
                  3: Feld[x,y].brush.color:=clScrollBar;
             end;
           end
      else // "Normaler" Färbevorgang nach Fällen (aber auch Leichen ausfärben!)
          begin
            case Spielfeld[x,y] of
                 0: Feld[x,y].brush.color:=clwhite;
                 1: Feld[x,y].brush.color:=clblack;
                 2: Feld[x,y].brush.color:=clblack;
                 3: Feld[x,y].brush.color:=clwhite;
            end;
          end;
     end;
end;

end.

