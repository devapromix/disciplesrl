﻿unit Elinor.Scene.Settlement;

interface

uses
  Vcl.Controls,
  System.Classes,
  Elinor.Scene.Frames,
  Elinor.Button,
  Elinor.Resources,
  Elinor.Party,
  Elinor.Scenes;

type
  TSettlementSubSceneEnum = (stCity, stCapital);

  { TSceneMap }

type
  TSceneSettlement = class(TSceneFrames)
  private type
    TButtonEnum = (btTemple, btBarracks, btParty, btClose);
  private const
    ButtonText: array [TButtonEnum] of TResEnum = (reTextTemple, reTextBarracks,
      reTextParty, reTextClose);
    procedure ShowTempleScene;
  private
  class var
    Button: array [TButtonEnum] of TButton;
    CurrentSettlementType: TSettlementSubSceneEnum;
    CurrentCityIndex: Integer;
  public
    class var SettlementParty: TParty;
  private
    IsUnitSelected: Boolean;
    ConfirmParty: TParty;
    ConfirmPartyPosition: TPosition;
    procedure MoveCursor(Dir: TDirectionEnum);
    procedure MoveUnit;
    procedure ShowPartyScene;
    procedure ShowBarracksScene;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render; override;
    procedure Update(var Key: Word); override;
    procedure Timer; override;
    procedure MouseDown(AButton: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    class procedure ShowScene(SettlementType: TSettlementSubSceneEnum);
      overload;
    class procedure HideScene;
  end;

implementation

uses
  System.SysUtils,
  Elinor.Saga,
  Elinor.Scenario,
  Elinor.Map,
  Elinor.Scene.Party,
  Elinor.Creatures,
  DisciplesRL.Scene.Hire,
  Elinor.Scene.Temple,
  Elinor.Scene.Party2,
  Elinor.Scene.Hire,
  Elinor.Scene.Barracks;

procedure TSceneSettlement.MoveCursor(Dir: TDirectionEnum);
begin
  case Dir of
    drWest:
      case ActivePartyPosition of
        1, 3, 5:
          Inc(ActivePartyPosition, 6);
        0, 2, 4:
          Inc(ActivePartyPosition);
        6, 8, 10:
          Dec(ActivePartyPosition, 6);
        7, 9, 11:
          Dec(ActivePartyPosition);
      end;
    drEast:
      case ActivePartyPosition of
        1, 3, 5:
          Dec(ActivePartyPosition);
        0, 2, 4:
          Inc(ActivePartyPosition, 6);
        6, 8, 10:
          Inc(ActivePartyPosition);
        7, 9, 11:
          Dec(ActivePartyPosition, 6);
      end;
    drNorth:
      case ActivePartyPosition of
        0, 1, 6, 7:
          Inc(ActivePartyPosition, 4);
        2 .. 5, 8 .. 11:
          Dec(ActivePartyPosition, 2);
      end;
    drSouth:
      case ActivePartyPosition of
        0 .. 3, 6 .. 9:
          Inc(ActivePartyPosition, 2);
        4, 5, 10, 11:
          Dec(ActivePartyPosition, 4);
      end;
  end;
  Game.Render;
end;

class procedure TSceneSettlement.HideScene;
begin
  case Game.Map.LeaderTile of
    reNeutralCity:
      begin
        TLeaderParty.Leader.ChCityOwner;
        TMapPlace.UpdateRadius(TMapPlace.GetIndex(TLeaderParty.Leader.X,
          TLeaderParty.Leader.Y));
      end;
  end;
  if (Game.Scenario.CurrentScenario = sgOverlord) then
  begin
    if (TMapPlace.GetCityCount = TScenario.ScenarioCitiesMax) then
    begin
      TSceneHire.Show(stVictory);
      Exit;
    end;
  end;
  Game.MediaPlayer.PlayMusic(mmMap);
  Game.Show(scMap);
  Game.MediaPlayer.PlaySound(mmClick);
  Game.NewDay;
end;

{ TSceneSettlement }

constructor TSceneSettlement.Create;
var
  LButtonEnum: TButtonEnum;
  L, W: Integer;
begin
  inherited Create(reWallpaperSettlement, fgLS6, fgRS6);
  W := ResImage[reButtonDef].Width + 4;
  L := ScrWidth - ((W * (Ord(High(TButtonEnum)) + 1)) div 2);
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
  begin
    Button[LButtonEnum] := TButton.Create(L, DefaultButtonTop,
      ButtonText[LButtonEnum]);
    Inc(L, W);
    if (LButtonEnum = btClose) then
      Button[LButtonEnum].Sellected := True;
  end;
end;

destructor TSceneSettlement.Destroy;
var
  LButtonEnum: TButtonEnum;
begin
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    FreeAndNil(Button[LButtonEnum]);
  inherited;
end;

procedure TSceneSettlement.MouseDown(AButton: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPartyPosition: Integer;
begin
  inherited;
  if (Game.Map.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y) >
    0) and (CurrentSettlementType = stCapital) and (AButton = mbRight) and
    (GetPartyPosition(X, Y) < 6) then
    Exit;
  // Move party
  case AButton of
    mbRight:
      begin
        LPartyPosition := GetPartyPosition(X, Y);
        case LPartyPosition of
          0 .. 11:
            begin
              ActivePartyPosition := LPartyPosition;
              Self.MoveUnit;
            end;
        end;
      end;
    mbLeft:
      begin
        if Button[btBarracks].MouseDown then
          ShowBarracksScene
        else if Button[btTemple].MouseDown then
          ShowTempleScene
        else if Button[btParty].MouseDown then
          ShowPartyScene
        else if Button[btClose].MouseDown then
          HideScene
        else
        begin
          LPartyPosition := GetPartyPosition(X, Y);
          case LPartyPosition of
            0 .. 11:
              begin
                CurrentPartyPosition := LPartyPosition;
                ActivePartyPosition := CurrentPartyPosition;
              end;
          end;
          Game.MediaPlayer.PlaySound(mmClick);
        end;
      end;
  end;
end;

procedure TSceneSettlement.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LButtonEnum: TButtonEnum;
begin
  inherited;
  for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
    Button[LButtonEnum].MouseMove(X, Y);
  Game.Render;
end;

procedure TSceneSettlement.Render;

  procedure RenderButtons;
  var
    LButtonEnum: TButtonEnum;
  begin
    for LButtonEnum := Low(TButtonEnum) to High(TButtonEnum) do
      Button[LButtonEnum].Render;
  end;

begin
  inherited;
  case CurrentSettlementType of
    stCity:
      begin
        DrawTitle(Game.Map.GetCityNameTitleRes(CurrentCityIndex + 1));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage(ScrWidth + 20, 160, reTextCityDef);
      end;
    stCapital:
      begin
        DrawTitle(Game.Map.GetCityNameTitleRes(0));
        DrawImage(20, 160, reTextLeadParty);
        DrawImage(ScrWidth + 20, 160, reTextCapitalDef);
      end;
  end;
  with TSceneParty do
  begin
    if (Game.Map.GetDistToCapital(TLeaderParty.Leader.X, TLeaderParty.Leader.Y)
      = 0) or (CurrentSettlementType = stCity) then
      RenderParty(psLeft, Party[TLeaderParty.LeaderPartyIndex],
        Party[TLeaderParty.LeaderPartyIndex].Count <
        TLeaderParty.Leader.Leadership)
    else
      RenderParty(psLeft, nil);
    RenderParty(psRight, SettlementParty, True);
  end;
  DrawResources;
  RenderButtons;
end;

class procedure TSceneSettlement.ShowScene(SettlementType
  : TSettlementSubSceneEnum);
begin
  CurrentSettlementType := SettlementType;
  case CurrentSettlementType of
    stCity:
      begin
        CurrentCityIndex := TSaga.GetPartyIndex(TLeaderParty.Leader.X,
          TLeaderParty.Leader.Y);
        SettlementParty := Party[CurrentCityIndex];
        SettlementParty.Owner := Party[TLeaderParty.LeaderPartyIndex].Owner;
      end
  else
    SettlementParty := Party[TLeaderParty.CapitalPartyIndex];
  end;
  ActivePartyPosition := TLeaderParty.GetPosition;
  SelectPartyPosition := -1;
  Game.Show(scSettlement);
end;

procedure TSceneSettlement.ShowTempleScene;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        TSceneTemple.ShowScene(TLeaderParty.Leader);
        Game.MediaPlayer.PlaySound(mmClick);
      end
  else
    if not SettlementParty.IsClear then
    begin
      TSceneTemple.ShowScene(SettlementParty);
      Game.MediaPlayer.PlaySound(mmClick);
    end;
  end;
end;

procedure TSceneSettlement.MoveUnit;
begin
  if not((ActivePartyPosition < 0) or ((ActivePartyPosition < 6) and
    (CurrentPartyPosition >= 6) and (Party[TLeaderParty.LeaderPartyIndex].Count
    >= TLeaderParty.Leader.Leadership))) then
  begin
    Party[TLeaderParty.LeaderPartyIndex].ChPosition(SettlementParty,
      ActivePartyPosition, CurrentPartyPosition);
    Game.MediaPlayer.PlaySound(mmClick);
  end;
end;

procedure TSceneSettlement.ShowBarracksScene;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        TSceneBarracks.ShowScene(TLeaderParty.Leader);
        Game.MediaPlayer.PlaySound(mmClick);
      end
  else
    if not SettlementParty.IsClear then
    begin
      TSceneBarracks.ShowScene(SettlementParty);
      Game.MediaPlayer.PlaySound(mmClick);
    end;
  end;

end;

procedure TSceneSettlement.ShowPartyScene;
begin
  case ActivePartyPosition of
    0 .. 5:
      begin
        TSceneParty2.ShowScene(Party[TLeaderParty.LeaderPartyIndex],
          scSettlement);
        Game.MediaPlayer.PlaySound(mmClick);
      end
  else
    if not SettlementParty.IsClear then
    begin
      TSceneParty2.ShowScene(SettlementParty, scSettlement);
      Game.MediaPlayer.PlaySound(mmClick);
    end;
  end;
end;

procedure TSceneSettlement.Timer;
begin
  inherited;

end;

procedure TSceneSettlement.Update(var Key: Word);
begin
  inherited;
  case Key of
    K_SPACE:
      begin
        if IsUnitSelected then
        begin
          IsUnitSelected := False;
          SelectPartyPosition := -1;
          Self.MoveUnit;
        end
        else
        begin
          IsUnitSelected := True;
          SelectPartyPosition := ActivePartyPosition;
          CurrentPartyPosition := ActivePartyPosition;
        end;
      end;
    K_ESCAPE, K_ENTER:
      HideScene;
    K_B:
      ShowBarracksScene;
    K_P:
      ShowPartyScene;
    K_T:
      ShowTempleScene;
    K_LEFT, K_KP_4, K_A:
      MoveCursor(drWest);
    K_RIGHT, K_KP_6, K_D:
      MoveCursor(drEast);
    K_UP, K_KP_8, K_W:
      MoveCursor(drNorth);
    K_DOWN, K_KP_2, K_X:
      MoveCursor(drSouth);
  end;
end;

end.
