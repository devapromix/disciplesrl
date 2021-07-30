﻿unit DisciplesRL.Items;

interface

{$IFDEF FPC}
{$MODESWITCH ADVANCEDRECORDS}
{$ENDIF}

// Предметы в Д1 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=328
// Предметы в Д2 -- http://alldisciples.ru/modules.php?name=Articles&pa=showarticle&artid=223
// Список предм. -- https://www.ign.com/faqs/2005/disciples-ii-rise-of-the-elves-items-listfaq-677342
uses
  DisciplesRL.Resources;

type
  TItemType = (itSpecial, itValuable,
    // Potions and Scrolls
    itPotion, itScroll,
    // Equipable
    itRing, itArmor, itArtifact, itAmulet, itHelm, itWand, itOrb, itTalisman,
    itBoots, itBanner, itTome);

const
  ItemTypeName: array [TItemType] of string = ('', 'ценность', 'эликсир',
    'свиток', 'кольцо', 'доспех', 'артефакт', 'амулет', 'шлем', 'посох',
    'сфера', 'талисман', 'обувь', 'знамя', 'книга');

type
  TItemProp = (ipEquipable, ipConsumable, ipReadable, ipUsable, ipPermanent,
    ipTemporary);

type
  TItemEffect = (ieNone);

type
  TItemEnum = (iNone,
    // Valuables
    iRunicKey, iWotansScroll, iEmberSalts, iEmerald, iRuby, iSapphire, iDiamond,
    iAncientRelic,

    // Potions
    // iLifePotion,
    iPotionOfHealing,
    // iPotionOfRestoration, iHealingOintment,

    // Artifacts
    iDwarvenBracer, iRunestone, iHornOfAwareness, iSoulCrystal, iSkullBracers,
    iLuteOfCharming, iSkullOfThanatos, iBethrezensClaw,

    // iRunicBlade,
    // iWightBlade,
    // iUnholyDagger,
    // iThanatosBlade,
    // iHornOfIncubus,
    // iRoyalScepter

    // Rings
    iStoneRing,
    // iBronzeRing, iSilverRing, iGoldRing,
    // iRingOfStrength, iRingOfTheAges, iHagsRing, iThanatosRing

    // Helms
    iTiaraOfPurity, iMjolnirsCrown, { ... } iImperialCrown);

type
  TItem = record
    Enum: TItemEnum;
    Name: string;
    Level: Integer;
    ItType: TItemType;
  end;

const
  MaxInventoryItems = 12;

type
  TInventory = class(TObject)
  private
    FItem: array [0 .. MaxInventoryItems - 1] of TItem;
  public
    constructor Create;
    procedure Clear; overload;
    procedure Clear(const I: Integer); overload;
    function Count: Integer;
    function Item(const I: Integer): TItem;
    function ItemEnum(const I: Integer): TItemEnum;
    procedure Add(const AItem: TItem); overload;
    procedure Add(const AItemEnum: TItemEnum); overload;
    function ItemName(const I: Integer): string;
  end;

const
  MaxEquipmentItems = 12;
  SlotName: array [0 .. MaxEquipmentItems - 1] of string = ('Шлем', 'Амулет',
    'Знамя', 'Книга', 'Доспех', 'Правая рука', 'Левая рука', 'Кольцо', 'Кольцо',
    'Артефакт', 'Артефакт', 'Обувь');

type
  TEquipment = class(TObject)
  private
    FItem: array [0 .. MaxEquipmentItems - 1] of TItem;
  public
    constructor Create;
    procedure Clear; overload;
    procedure Clear(const I: Integer); overload;
    function Item(const I: Integer): TItem;
    function ItemName(const I: Integer): string; overload;
    function ItemName(const I: Integer; const S: string): string; overload;
    procedure Add(const SlotIndex: Integer;
      const AItemEnum: TItemEnum); overload;
  end;

type
  TItemBase = class(TObject)
    class function Item(const ItemEnum: TItemEnum): TItem; overload;
    class function Item(const ItemIndex: Integer): TItem; overload;
    class function Count: Integer;
  end;

implementation

uses
  SysUtils;

const
  ItemBase: array [TItemEnum] of TItem = (
    // None
    (Enum: iNone; Name: ''; Level: 0; ItType: itSpecial;),

    // Valuables
    // Runic Key
    (Enum: iRunicKey; Name: 'Рунический Ключ'; Level: 1; ItType: itValuable;),
    // Wotan's Scroll
    (Enum: iWotansScroll; Name: 'Свиток Вотана'; Level: 2; ItType: itValuable;),
    // Ember Salts
    (Enum: iEmberSalts; Name: 'Тлеющая Соль'; Level: 3; ItType: itValuable;),
    // Emerald
    (Enum: iEmerald; Name: 'Изумруд'; Level: 4; ItType: itValuable;),
    // Ruby
    (Enum: iRuby; Name: 'Рубин'; Level: 5; ItType: itValuable;),
    // Sapphire
    (Enum: iSapphire; Name: 'Сапфир'; Level: 6; ItType: itValuable;),
    // Diamond
    (Enum: iDiamond; Name: 'Бриллиант'; Level: 7; ItType: itValuable;),
    // Ancient Relic
    (Enum: iAncientRelic; Name: 'Древняя Реликвия'; Level: 8;
    ItType: itValuable;),

    // Potions
    // Potion of Healing
    (Enum: iPotionOfHealing; Name: 'Эликсир Исцеления'; Level: 1;
    ItType: itPotion;),

    // Artifacts
    // Dwarven Bracer
    (Enum: iDwarvenBracer; Name: 'Гномьи Наручи'; Level: 1;
    ItType: itArtifact;),
    // Runestone
    (Enum: iRunestone; Name: 'Рунный Камень'; Level: 2; ItType: itArtifact;),
    // Horn Of Awareness
    (Enum: iHornOfAwareness; Name: 'Рог Чистого Сознания'; Level: 3;
    ItType: itArtifact;),
    // Soul Crystal
    (Enum: iSoulCrystal; Name: 'Кристалл Души'; Level: 4; ItType: itArtifact;),
    // Skull Bracers
    (Enum: iSkullBracers; Name: 'Браслет из Черепов'; Level: 5;
    ItType: itArtifact;),
    // Lute Of Charming
    (Enum: iLuteOfCharming; Name: 'Лютня Обаяния'; Level: 6;
    ItType: itArtifact;),
    // Skull Of Thanatos
    (Enum: iSkullOfThanatos; Name: 'Череп Танатоса'; Level: 7;
    ItType: itArtifact;),
    // Bethrezen's Claw
    (Enum: iBethrezensClaw; Name: 'Коготь Бетрезена'; Level: 8;
    ItType: itArtifact;),

    // Rings
    // Stone Ring
    (Enum: iStoneRing; Name: 'Каменное Кольцо'; Level: 1; ItType: itRing;),

    // Helms
    // Tiara Of Purity
    (Enum: iTiaraOfPurity; Name: 'Тиара Чистоты'; Level: 5; ItType: itHelm;),
    // Mjolnir's Crown
    (Enum: iMjolnirsCrown; Name: 'Корона Мьельнира'; Level: 6; ItType: itHelm;),

    // Imperial Crown
    (Enum: iImperialCrown; Name: 'Корона Империи'; Level: 8; ItType: itHelm;));

  { TInventory }

procedure TInventory.Add(const AItem: TItem);
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum = iNone then
    begin
      FItem[I] := AItem;
      Exit;
    end;
end;

procedure TInventory.Add(const AItemEnum: TItemEnum);
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum = iNone then
    begin
      FItem[I] := ItemBase[AItemEnum];
      Exit;
    end;
end;

procedure TInventory.Clear;
var
  I: Integer;
begin
  for I := 0 to MaxInventoryItems - 1 do
    Clear(I);
end;

procedure TInventory.Clear(const I: Integer);
begin
  FItem[I] := ItemBase[iNone];
end;

function TInventory.Count: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to MaxInventoryItems - 1 do
    if FItem[I].Enum <> iNone then
      Inc(Result);
end;

constructor TInventory.Create;
begin
  Self.Clear;
end;

function TInventory.Item(const I: Integer): TItem;
begin
  Result := FItem[I];
end;

function TInventory.ItemEnum(const I: Integer): TItemEnum;
begin
  Result := FItem[I].Enum;
end;

function TInventory.ItemName(const I: Integer): string;
begin
  if (FItem[I].Name <> '') then
    Result := Format('[%s] %s (%s)', [Chr(I + Ord('M')), FItem[I].Name,
      ItemTypeName[FItem[I].ItType]])
  else
    Result := Format('[%s]', [Chr(I + Ord('M'))]);
end;

{ TItemBase }

class function TItemBase.Count: Integer;
begin
  Result := Length(ItemBase);
end;

class function TItemBase.Item(const ItemEnum: TItemEnum): TItem;
begin
  Result := ItemBase[ItemEnum];
end;

class function TItemBase.Item(const ItemIndex: Integer): TItem;
begin
  Result := ItemBase[TItemEnum(ItemIndex)];
end;

{ TEquipment }

procedure TEquipment.Add(const SlotIndex: Integer; const AItemEnum: TItemEnum);
begin
  FItem[SlotIndex] := ItemBase[AItemEnum];
end;

procedure TEquipment.Clear;
var
  I: Integer;
begin
  for I := 0 to MaxEquipmentItems - 1 do
    Clear(I);
end;

procedure TEquipment.Clear(const I: Integer);
begin
  FItem[I] := ItemBase[iNone];
end;

constructor TEquipment.Create;
begin
  Self.Clear;
end;

function TEquipment.Item(const I: Integer): TItem;
begin
  Result := FItem[I];
end;

function TEquipment.ItemName(const I: Integer; const S: string): string;
begin
  Result := Format('[%s] %s: %s', [Chr(I + Ord('A')), SlotName[I], S]);
end;

function TEquipment.ItemName(const I: Integer): string;
begin
  Result := Format('[%s] %s: %s', [Chr(I + Ord('A')), SlotName[I],
    FItem[I].Name]);
end;

end.
