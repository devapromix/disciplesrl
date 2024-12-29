﻿unit Elinor.Scene.Base.Party;

interface

uses
  System.Classes,
  Vcl.Controls,
  Elinor.Resources,
  Elinor.Button,
  Elinor.Scene.Frames;

type
  TSceneBaseParty = class(TSceneFrames)
  private type
    TTwoButtonEnum = (btCancel, btContinue);
  private const
    TwoButtonText: array [TTwoButtonEnum] of TResEnum = (reTextCancel,
      reTextContinue);
  private
    Button: array [TTwoButtonEnum] of TButton;
    FCurrentIndex: Integer;
  public
  var
  public
    constructor Create(const AResEnum: TResEnum);
    destructor Destroy; override;
    procedure Render; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Cancel; virtual;
    procedure Continue; virtual;
    property CurrentIndex: Integer read FCurrentIndex write FCurrentIndex;
    procedure Update(var Key: Word); override;
    procedure Basic(AKey: Word);
    procedure RenderButtons;
  end;

implementation

uses
  Math, Dialogs,
  SysUtils,
  Elinor.Frame,
  Elinor.Common,
  Elinor.Scenes;

{ TSceneSimpleMenu }

procedure TSceneBaseParty.Basic(AKey: Word);
begin
  case AKey of
    K_ESCAPE:
      Cancel;
    K_ENTER:
      Continue;
  end;
end;

procedure TSceneBaseParty.Cancel;
begin

end;

procedure TSceneBaseParty.Continue;
begin

end;

constructor TSceneBaseParty.Create(const AResEnum: TResEnum);
var
  LTwoButtonEnum: TTwoButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(AResEnum, fgLS6, fgRM2);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TTwoButtonEnum)) + 1)) div 2);
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
  begin
    Button[LTwoButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      TwoButtonText[LTwoButtonEnum]);
    Inc(LLeft, LWidth);
    if (LTwoButtonEnum = btContinue) then
      Button[LTwoButtonEnum].Sellected := True;
  end;
end;

destructor TSceneBaseParty.Destroy;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    FreeAndNil(Button[LTwoButtonEnum]);
  inherited;
end;

procedure TSceneBaseParty.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  case AButton of
    mbLeft:
      begin
        CurrentIndex := GetFramePosition(X, Y);
        if CurrentIndex >= 0 then
        begin
          Game.MediaPlayer.PlaySound(mmClick);
          // ShowMessage(IntToStr(CurrentIndex));
          Exit;
        end;
        if Button[btCancel].MouseDown then
          Cancel;
        if Button[btContinue].MouseDown then
          Continue;
      end;
  end;
end;

procedure TSceneBaseParty.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  inherited;
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    Button[LTwoButtonEnum].MouseMove(X, Y);
end;

procedure TSceneBaseParty.Render;
var
  LX, LY: Integer;
begin
  inherited;

  case CurrentIndex of
    0 .. 2:
      begin
        LX := TFrame.Col(0);
        LY := TFrame.Row(CurrentIndex);
      end;
    3 .. 5:
      begin
        LX := TFrame.Col(1);
        LY := TFrame.Row(CurrentIndex - 3);
      end;
  end;
  DrawImage(LX, LY, reActFrame);

  RenderButtons;
end;

procedure TSceneBaseParty.RenderButtons;
var
  LTwoButtonEnum: TTwoButtonEnum;
begin
  for LTwoButtonEnum := Low(TTwoButtonEnum) to High(TTwoButtonEnum) do
    Button[LTwoButtonEnum].Render;
end;

procedure TSceneBaseParty.Update(var Key: Word);
var
  FF: Boolean;
begin
  inherited;
  FF := CurrentIndex in [0 .. 4];
  case Key of
    K_ESCAPE:
      Cancel;
    K_ENTER:
      if FF then
        Continue;
    K_UP:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          1, 2, 4, 5:
            CurrentIndex := CurrentIndex - 1;
        end;
      end;
    K_Down:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          0, 1, 3, 4:
            CurrentIndex := CurrentIndex + 1;
        end;
      end;
    K_LEFT:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          3 .. 5:
            CurrentIndex := CurrentIndex - 3;
        end;
      end;
    K_RIGHT:
      begin
        Game.MediaPlayer.PlaySound(mmClick);
        case CurrentIndex of
          0 .. 2:
            CurrentIndex := CurrentIndex + 3;
        end;
      end;
  end;
end;

end.
