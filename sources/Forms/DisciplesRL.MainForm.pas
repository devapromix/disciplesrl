﻿unit DisciplesRL.MainForm;

interface

uses
{$IFDEF FPC}
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls;
{$ELSE}
  Winapi.Windows,
  Winapi.Messages,
  SysUtils,
  Variants,
  Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls;
{$ENDIF}

type

  { TMainForm }

  TMainForm = class(TForm)
    Timer1: TTimer;
    AutoTimer: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

uses
  DisciplesRL.Scenes,
  Elinor.Saga;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.ClientWidth := ScreenWidth;
  MainForm.ClientHeight := ScreenHeight;
  Game := TGame.Create;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  Game.Render;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Game.Timer;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Game);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Game.Update(Key);
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Game.MouseDown(Button, Shift, X, Y);
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Game.MouseMove(Shift, X, Y);
end;

end.
