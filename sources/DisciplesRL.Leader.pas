﻿unit DisciplesRL.Leader;

interface

uses
  System.Types,
  DisciplesRL.Creatures,
  DisciplesRL.MapObject;

type
  TDirectionEnum = (drEast, drWest, drSouth, drNorth, drSouthEast, drSouthWest, drNorthEast, drNorthWest, drOrigin);

const
  Direction: array [TDirectionEnum] of TPoint = ((X: 1; Y: 0), (X: - 1; Y: 0), (X: 0; Y: 1), (X: 0; Y: - 1), (X: 1; Y: 1), (X: - 1; Y: 1), (X: 1;
    Y: - 1), (X: - 1; Y: - 1), (X: 0; Y: 0));

type
  TLeader = class(TMapObject)
  private
    FRadius: Integer;
    FMaxLeadership: Integer;
  public
    Speed: Integer;
    MaxSpeed: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ChCityOwner;
    procedure UpdateRadius;
    procedure PutAt(const AX, AY: ShortInt; const IsInfo: Boolean = False);
    procedure Turn(const Count: Integer = 1);
    procedure Move(const AX, AY: ShortInt); overload;
    procedure Move(Dir: TDirectionEnum); overload;
    property Radius: Integer read FRadius;
    property MaxLeadership: Integer read FMaxLeadership;
  end;

var
  Leader: TLeader;

implementation

uses
  System.Math,
  Vcl.Dialogs,
  System.SysUtils,
  DisciplesRL.Map,
  DisciplesRL.Resources,
  DisciplesRL.City,
  DisciplesRL.Party,
  DisciplesRL.Scenes,
  DisciplesRL.Game,
  DisciplesRL.Scene.Settlement,
  DisciplesRL.PascalScript.Battle,
  DisciplesRL.PascalScript.Vars,
  DisciplesRL.Scene.Battle,
  DisciplesRL.Scene.Battle2,
  DisciplesRL.Scene.Party,
  DisciplesRL.Scene.Info;

{ TLeader }

procedure TLeader.PutAt(const AX, AY: ShortInt; const IsInfo: Boolean = False);
var
  I: Integer;
  F: Boolean;
begin
  if not InMap(AX, AY) then
    Exit;
  if (Map[lrObj][AX, AY] in StopTiles) then
    Exit;
  if not IsInfo then
    for I := 0 to High(City) do
    begin
      if (City[I].Owner in Races) then
        if (City[I].CurLevel < City[I].MaxLevel) then
        begin
          Inc(City[I].CurLevel);
          DisciplesRL.City.UpdateRadius(I);
        end;
    end;
  if IsInfo then
  begin
    if Map[lrTile][AX, AY] in Capitals then
    begin
        DisciplesRL.Scene.Party.Show(Party[CapitalPartyIndex], scMap);
      Exit;
    end;
    if Map[lrTile][AX, AY] in Cities then
    begin
      I := GetPartyIndex(AX, AY);
      if not Party[I].IsClear then
        DisciplesRL.Scene.Party.Show(Party[I], scMap);
      Exit;
    end;
    case Map[lrObj][AX, AY] of
      reEnemy:
        begin
          I := GetPartyIndex(AX, AY);
          DisciplesRL.Scene.Party.Show(Party[I], scMap);
        end;
    end;
    Exit;
  end
  else
  begin
    SetLocation(AX, AY);
    UpdateRadius;
    Turn(1);
    F := True;
    case Map[lrObj][X, Y] of
      reGold:
        begin
          Map[lrObj][X, Y] := reNone;
          AddLoot();
          F := False;
        end;
      reBag:
        begin
          Map[lrObj][X, Y] := reNone;
          AddLoot();
          F := False;
        end;
      reEnemy:
        begin
          DisciplesRL.Scene.Battle2.Start;
          DisciplesRL.Scenes.CurrentScene := scBattle2;
          Map[lrObj][X, Y] := reNone;
          F := False;
          Exit;
        end;
    end;
  end;
  case LeaderTile of
    reNeutralCity:
      begin
        ChCityOwner;
        DisciplesRL.City.UpdateRadius(DisciplesRL.City.GetCityIndex(X, Y));
        F := False;
      end;
  end;
  if LeaderTile in Capitals then
  begin
    DisciplesRL.Scene.Settlement.Show(stCapital);
    F := False;
  end;
  if LeaderTile in Cities then
  begin
    DisciplesRL.Scene.Settlement.Show(stCity);
    F := False;
  end;
  if F then
    NewDay;
end;

procedure TLeader.UpdateRadius;
begin
  DisciplesRL.Map.UpdateRadius(X, Y, Radius, Map[lrDark], reNone);
end;

procedure TLeader.Turn(const Count: Integer = 1);
var
  C: Integer;
begin
  if (Count < 1) then
    Exit;
  C := 0;
  repeat
    Dec(Speed);
    if (Speed = 0) then
    begin
      Inc(Days);
      IsDay := True;
      Speed := MaxSpeed;
    end;
    Inc(C);
  until (C >= Count);
end;

procedure TLeader.Move(const AX, AY: ShortInt);
begin
  PutAt(X + AX, Y + AY);
end;

procedure TLeader.Move(Dir: TDirectionEnum);
begin
  PutAt(X + Direction[Dir].X, Y + Direction[Dir].Y);
end;

procedure TLeader.ChCityOwner;
begin
  case Party[LeaderPartyIndex].Owner of
    reTheEmpire:
      Map[lrTile][X, Y] := reTheEmpireCity;
    reUndeadHordes:
      Map[lrTile][X, Y] := reUndeadHordesCity;
    reLegionsOfTheDamned:
      Map[lrTile][X, Y] := reLegionsOfTheDamnedCity;
  end;
end;

procedure TLeader.Clear;
begin
  MaxSpeed := 7;
  Speed := MaxSpeed;
  FRadius := IfThen(Wizard, 9, 1);
  UpdateRadius;
end;

constructor TLeader.Create;
begin
  inherited;
  FRadius := 1;
  FMaxLeadership := 1;
end;

destructor TLeader.Destroy;
begin

  inherited;
end;

initialization

Leader := TLeader.Create;

finalization

FreeAndNil(Leader);

end.
