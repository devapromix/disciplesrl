﻿unit Elinor.Scene.Abilities;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Scene.Base.Party,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSceneAbilities = class(TSceneBaseParty)
  private type
    TButtonEnum = (btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextClose);
  private
    Button: array [TButtonEnum] of TButton;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(const ACloseSceneEnum: TSceneEnum);
    class procedure HideScene;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Elinor.Frame,
  Elinor.Scene.Party,
  Elinor.Creatures;

var
  CloseSceneEnum: TSceneEnum;

  { TSceneAbilities }

constructor TSceneAbilities.Create;
var
  LButtonEnum: TButtonEnum;
  LLeft, LWidth: Integer;
begin
  inherited Create(reWallpaperSettlement);
  LWidth := ResImage[reButtonDef].Width + 4;
  LLeft := ScrWidth - ((LWidth * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(LLeft, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(LLeft, LWidth);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneAbilities.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

class procedure TSceneAbilities.HideScene;
begin
  Game.MediaPlayer.PlaySound(mmClick);
  Game.MediaPlayer.PlaySound(mmSettlement);
  Game.Show(CloseSceneEnum);
end;

procedure TSceneAbilities.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  case AButton of
    mbLeft:
      begin
        if Button[btClose].MouseDown then
          HideScene;
      end;
  end;
end;

procedure TSceneAbilities.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
end;

procedure TSceneAbilities.Render;

  procedure RenderParty;
  var
    LPosition: TPosition;
  begin
    for LPosition := Low(TPosition) to High(TPosition) do
      DrawUnit(LPosition, TLeaderParty.Leader, TFrame.Col(LPosition, psLeft),
        TFrame.Row(LPosition), False, True);
  end;

  procedure RenderAbilities;
  var
    I: Integer;
    LAbilityEnum: TAbilityEnum;
  begin
    DrawTitle(reTitleAbilities);
    TextLeft := 250 + TFrame.Col(0, psRight) + 12;
    TextTop := TFrame.Row(0) + 6 + (TextLineHeight div 2);
    TextLeft := TFrame.Col(0, psRight) + 12;
    TextTop := TFrame.Row(0) + 6;
    AddTextLine('Leader Abilities', True);
    AddTextLine;
    for I := 0 to MaxAbilities - 1 do
    begin
      LAbilityEnum := TLeaderParty.Leader.Abilities.GetEnum(I);
      if LAbilityEnum <> skNone then
      begin
        AddTextLine(TAbilities.Ability(LAbilityEnum).Name);
        AddTextLine(TAbilities.Ability(LAbilityEnum).Description[0]);
        AddTextLine(TAbilities.Ability(LAbilityEnum).Description[1]);
        if I = 3 then
        begin
          TextLeft := TFrame.Col(0, psRight) + 320 + 12;
          TextTop := TFrame.Row(0) + 6;
        end;
      end;
    end;
  end;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;

  DrawTitle(reTitleAbilities);

  RenderParty;
  RenderAbilities;
  RenderButtons;
end;

class procedure TSceneAbilities.ShowScene(const ACloseSceneEnum: TSceneEnum);
begin
  CloseSceneEnum := ACloseSceneEnum;
  Game.Show(scAbilities);
  ActivePartyPosition := TLeaderParty.GetPosition;
end;

procedure TSceneAbilities.Timer;
begin
  inherited;

end;

procedure TSceneAbilities.Update(var Key: Word);
begin
  case Key of
    K_ESCAPE, K_ENTER:
      HideScene;
  end;
end;

end.
