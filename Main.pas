unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts;

type
  { Lineを表示するための位置への情報 ssStart = 開始, ssNext= 継続　, ssEnd =終端 }
 TLineStatus = (sStart, sNext, sEnd);

  { Line 描画の位置、Statusを構造体として定義}
  TLinePoint = record
          Positon : TPointF;
          Status  : TLineStatus;
  end;
  PLinePoint = ^TLinePoint;
  TMainForm = class(TForm)
    Layout1: TLayout;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  private
    DrawPoints  : TList<TLinePoint>;
    PressStatus : Boolean;
    procedure AddPoint(const x, y: single; const Status: TLineStatus);

    { private 宣言 }

  public
    { public 宣言 }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.FormCreate(Sender: TObject);
begin
    DrawPoints := TList<TLinePoint>.Create;  { 描画用の点リストの構築 }
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DrawPoints.DisposeOf;   { 描画用の点リストの破棄 }
end;

procedure TMainForm.AddPoint(const x, y: single; const Status: TLineStatus);
var
    TLP: TLinePoint;    { 仮Line Point }
begin
        if(DrawPoints.Count < 0 ) then exit;   { マイナスはあり得ない }

        TLP.Positon := PointF(x, y);           { 設定データ仮作成 }
        TLP.Status  := Status;
        DrawPoints.Add(TLP);                   { Listに追加 }
        PaintBox1.Repaint;                     { 再描画 }
end;

procedure TMainForm.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
     if ssLeft in Shift then      { 左ボタン押している？ }
     begin
       PressStatus := True;       { 左ボタン押し状態設定 }
       AddPoint( x, y ,sStart);   { 描画用の点設定:開始}
     end;
end;

procedure TMainForm.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
     if ssLeft in Shift then      { 左ボタン押している？ }
     begin
       if(PressStatus =  True) then  { 押し検出済み?}
       AddPoint( x, y ,sNext);   { 描画用の点設定:継続}
     end;
end;

procedure TMainForm.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if(PressStatus =  True) then
    begin
       AddPoint( x, y ,sEnd);   { 描画用の点設定:終端}
    end;
    PressStatus := false;       {押し状態を解除}
end;

procedure TMainForm.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var
   TLP: TLinePoint;    { 仮Line Point }
   StartPoint : TPointF;
begin
        if(DrawPoints.Count < 0 ) then exit;   { マイナスはあり得ない }

        Canvas.Stroke.Kind := TBrushKind.Solid;     {とりあえずのペン色や種類}
        Canvas.Stroke.Dash := TStrokeDash.Solid;
        Canvas.Stroke.Thickness := 2;
        Canvas.Stroke.Color := TAlphaColorRec.Black;

        {線を引く処理}

        for TLP in DrawPoints do
        begin
                case TLP.Status of
                        sStart : StartPoint := TLP.Positon;
                else
                        begin
                            Canvas.DrawLine(StartPoint, TLP.Positon, 1, Canvas.Stroke);
                            StartPoint := TLP.Positon;
                        end;
                end;
        end;
end;

end.
