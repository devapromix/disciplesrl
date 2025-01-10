﻿unit Elinor.Spells;

interface

uses
  Elinor.Factions,
  Elinor.Resources,
  Elinor.Spells.Types;

type
  TSpellEnum = (spNone,
    // The Empire Spellbook
    spTrueHealing,
    // Undead Hordes Spellbook
    spPlague,
    // Legions of the Damned Spellbook
    spConcealment
    //
    );

type
  TSpell = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; virtual;
  end;

type
  TActiveSpell = class(TObject)
  private
    FSpellEnum: TSpellEnum;
  public
    constructor Create;
    property SpellEnum: TSpellEnum read FSpellEnum;
    procedure SetActiveSpell(const ASpellEnum: TSpellEnum);
    function IsSpell: Boolean;
    procedure Clear;
  end;

type
  TSpells = class(TSpell)
  private
    FSpell: array [TSpellEnum] of TSpell;
    FActiveSpell: TActiveSpell;
  public
    constructor Create;
    destructor Destroy; override;
    function CastAt(const AX, AY: Integer): Boolean; override;
    property ActiveSpell: TActiveSpell read FActiveSpell write FActiveSpell;
    class function Spell(const ASpellEnum: TSpellEnum): TSpellBase; static;
  end;

  { Spells }

type
  TTrueHealingSpell = class(TSpell)
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

type
  TPlagueSpell = class(TSpell)
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

type
  TConcealmentSpell = class(TSpell)
    function CastAt(const AX, AY: Integer): Boolean; override;
  end;

var
  Spells: TSpells;

implementation

uses
  System.SysUtils, Dialogs,
  Elinor.Saga,
  Elinor.Party,
  Elinor.Creatures,
  Elinor.Scenes;

const
  SpellBase: array [TSpellEnum] of TSpellBase = (
    // None
    (Name: ''; Level: 0; Mana: 0; SoundEnum: mmBlock; ResEnum: reNone;),
    // True Healing
    (Name: 'True Healing'; Level: 1; Mana: 10; SoundEnum: mmBlock;
    ResEnum: reTrueHealing;),
    // Plague
    (Name: 'Plague'; Level: 1; Mana: 15; SoundEnum: mmBlock;
    ResEnum: reAshgan;),
    // Concealment
    (Name: 'Concealment'; Level: 1; Mana: 12; SoundEnum: mmBlock;
    ResEnum: reAshkael;)
    //
    );

  { TSpell }

function TSpell.CastAt(const AX, AY: Integer): Boolean;
begin
  Result := False;
end;

constructor TSpell.Create;
begin

end;

destructor TSpell.Destroy;
begin

  inherited;
end;

{ TCurrentSpell }

procedure TActiveSpell.Clear;
begin
  Game.MediaPlayer.PlaySound(mmDispell);
  FSpellEnum := spNone;
end;

constructor TActiveSpell.Create;
begin
  FSpellEnum := spNone;
end;

function TActiveSpell.IsSpell: Boolean;
begin
  Result := FSpellEnum <> spNone;
end;

procedure TActiveSpell.SetActiveSpell(const ASpellEnum: TSpellEnum);
begin
  FSpellEnum := ASpellEnum;
end;

{ TSpells }

function TSpells.CastAt(const AX, AY: Integer): Boolean;
begin
  inherited;
  if not ActiveSpell.IsSpell then
    Exit;
  Result := FSpell[ActiveSpell.SpellEnum].CastAt(AX, AY);
  if Result then
    ActiveSpell.Clear;
end;

constructor TSpells.Create;
begin
  FActiveSpell := TActiveSpell.Create;
  FSpell[spTrueHealing] := TTrueHealingSpell.Create;
  FSpell[spPlague] := TPlagueSpell.Create;
  FSpell[spConcealment] := TConcealmentSpell.Create;
end;

destructor TSpells.Destroy;
var
  LSpellEnum: TSpellEnum;
begin
  for LSpellEnum := Succ(Low(TSpellEnum)) to High(TSpellEnum) do
    FreeAndNil(FSpell[LSpellEnum]);
  FreeAndNil(FActiveSpell);
  inherited;
end;

class function TSpells.Spell(const ASpellEnum: TSpellEnum): TSpellBase;
begin
  Result := SpellBase[ASpellEnum];
end;

{ TTrueHealingSpell }

function TTrueHealingSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex = TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('True Healing');
    Game.MediaPlayer.PlaySound(mmHeal);
    Party[LPartyIndex].HealAll(25);
  end;
end;

{ TPlagueSpell }

function TPlagueSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex <> TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('Plague');
    Game.MediaPlayer.PlaySound(mmPlague);
    Party[LPartyIndex].TakeDamageAll(35);
  end;
end;

{ TConcealmentSpell }

function TConcealmentSpell.CastAt(const AX, AY: Integer): Boolean;
var
  LPartyIndex: Integer;
begin
  inherited;
  LPartyIndex := TSaga.GetPartyIndex(AX, AY);
  if (LPartyIndex > 0) and (LPartyIndex = TLeaderParty.LeaderPartyIndex) then
  begin
    Result := True;
    ShowMessage('Concealment');
    Game.MediaPlayer.PlaySound(mmInvisibility);
    TLeaderParty.Leader.Invisibility := True;
  end;
end;

initialization

Spells := TSpells.Create;

finalization

FreeAndNil(Spells);

end.
