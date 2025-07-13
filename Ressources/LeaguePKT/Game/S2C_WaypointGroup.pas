unit S2C_WaypointGroup;

interface

uses
  SysUtils, Classes, Generics.Collections,
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter,
  MovementDataUnit;

type
  TS2C_WaypointGroup = class(TGamePacket)
  private
    FSyncID: Integer;
    FMovements: TList<TMovementDataNormal>;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetID: TGamePacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property SyncID: Integer read FSyncID write FSyncID;
    property Movements: TList<TMovementDataNormal> read FMovements;
  end;

implementation

constructor TS2C_WaypointGroup.Create;
begin
  inherited Create;
  FMovements := TObjectList<TMovementDataNormal>.Create(True); // Owned
end;

destructor TS2C_WaypointGroup.Destroy;
begin
  FMovements.Free;
  inherited Destroy;
end;

function TS2C_WaypointGroup.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_WaypointGroup;
end;

procedure TS2C_WaypointGroup.ReadBody(reader: TByteReader);
var
  i, count: Integer;
  movement: TMovementDataNormal;
begin
  FSyncID := reader.ReadInt32;
  count := reader.ReadInt16;
  for i := 0 to count - 1 do
  begin
    movement := TMovementDataNormal.Create(reader, FSyncID);
    FMovements.Add(movement);
  end;
end;

procedure TS2C_WaypointGroup.WriteBody(writer: TByteWriter);
var
  i, count: Integer;
begin
  count := FMovements.Count;
  if count > $7FFF then
    //raise EIOException.Create('Too many movementdata!');

  writer.WriteInt32(FSyncID);
  writer.WriteInt16(ShortInt(count));
  for i := 0 to count - 1 do
    FMovements[i].Write(writer);
end;

end.

