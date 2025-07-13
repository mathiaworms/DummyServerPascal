unit S2C_StartSpawn;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TS2C_StartSpawn = class(TGamePacket)
  private
    FBotCountOrder: Byte;
    FBotCountChaos: Byte;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property BotCountOrder: Byte read FBotCountOrder write FBotCountOrder;
    property BotCountChaos: Byte read FBotCountChaos write FBotCountChaos;
  end;

implementation

{ TS2C_StartSpawn }

function TS2C_StartSpawn.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_StartSpawn;
end;

procedure TS2C_StartSpawn.ReadBody(reader: TByteReader);
begin
  FBotCountOrder := reader.ReadByte;
  FBotCountChaos := reader.ReadByte;
end;

procedure TS2C_StartSpawn.WriteBody(writer: TByteWriter);
begin
  writer.WriteByte(FBotCountOrder);
  writer.WriteByte(FBotCountChaos);
end;

end.

