unit S2C_OnEnterVisiblityClient;

interface

uses
  SysUtils, Classes, Generics.Collections, // pour TList<T>
  System.Math, // pour les types math si besoin
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter,
  MovementDataUnit,
  VectorTypes;

type
  TS2C_OnEnterVisiblityClient = class;

  // Classe interne pour ItemData
  TItemData = class
  private
    FSlot: Byte;
    FItemsInSlot: Byte;
    FSpellCharges: Byte;
    FItemID: Cardinal;
  public
    property Slot: Byte read FSlot write FSlot;
    property ItemsInSlot: Byte read FItemsInSlot write FItemsInSlot;
    property SpellCharges: Byte read FSpellCharges write FSpellCharges;
    property ItemID: Cardinal read FItemID write FItemID;
  end;

  TS2C_OnEnterVisiblityClient = class(TGamePacket)
  private
    FItems: TObjectList<TItemData>;
    FLookAtType: Byte;
    FLookAtPosition: TVector3;
    FMovementData: TMovementData;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property Items: TObjectList<TItemData> read FItems;
    property LookAtType: Byte read FLookAtType write FLookAtType;
    property LookAtPosition: TVector3 read FLookAtPosition write FLookAtPosition;
    property MovementData: TMovementData read FMovementData write FMovementData;
  end;

implementation

constructor TS2C_OnEnterVisiblityClient.Create;
begin
  inherited Create;
  FItems := TObjectList<TItemData>.Create(True); // Owned items, auto free
  FMovementData := TMovementDataNone.Create; // Par défaut, MovementDataNone
end;

destructor TS2C_OnEnterVisiblityClient.Destroy;
begin
  FMovementData.Free;
  FItems.Free;
  inherited Destroy;
end;

function TS2C_OnEnterVisiblityClient.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_OnEnterVisiblityClient;
end;

procedure TS2C_OnEnterVisiblityClient.ReadBody(reader: TByteReader);
var
  i, itemCount: Integer;
  item: TItemData;
begin
  if reader.BytesLeft < 2 then
  begin
    reader.ReadPad(1);
    Exit;
  end;

  itemCount := reader.ReadByte;
  for i := 0 to itemCount - 1 do
  begin
    item := TItemData.Create;
    item.Slot := reader.ReadByte;
    item.ItemsInSlot := reader.ReadByte;
    item.SpellCharges := reader.ReadByte;
    item.ItemID := reader.ReadUInt32;
    FItems.Add(item);
  end;

  FLookAtType := reader.ReadByte;
  if FLookAtType <> 0 then
    FLookAtPosition := reader.ReadVector3;

  if reader.BytesLeft < 1 then
    Exit;

  FMovementData.Free;
  FMovementData := ReadMovementDataWithHeader(reader);
end;

procedure TS2C_OnEnterVisiblityClient.WriteBody(writer: TByteWriter);
var
  itemCount, i: Integer;
  item: TItemData;
begin
  itemCount := FItems.Count;
  if itemCount > $FF then
   // raise EIOException.Create('More than 255 items!');

  writer.WriteByte(Byte(itemCount));
  for i := 0 to itemCount - 1 do
  begin
    item := FItems[i];
    writer.WriteByte(item.Slot);
    writer.WriteByte(item.ItemsInSlot);
    writer.WriteByte(item.SpellCharges);
    writer.WriteUInt32(item.ItemID);
  end;

  writer.WriteByte(FLookAtType);
  if FLookAtType <> 0 then
    writer.WriteVector3(FLookAtPosition);

  WriteMovementDataWithHeader(writer,FMovementData);
end;

end.

