unit S2C_CreateHero;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter,
  System.SysUtils;

type
  TS2C_CreateHero = class(TGamePacket)
  private
    FUnitNetID: Cardinal;
    FClientID: Cardinal;
    FNetNodeID: Byte;
    FSkillLevel: Byte;
    FTeamIsOrder: Boolean;
    FIsBot: Boolean;
    FBotRank: Byte;
    FSpawnPositionIndex: Byte;
    FSkinID: Cardinal;
    FName: string;
    FSkin: string;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property UnitNetID: Cardinal read FUnitNetID write FUnitNetID;
    property ClientID: Cardinal read FClientID write FClientID;
    property NetNodeID: Byte read FNetNodeID write FNetNodeID;
    property SkillLevel: Byte read FSkillLevel write FSkillLevel;
    property TeamIsOrder: Boolean read FTeamIsOrder write FTeamIsOrder;
    property IsBot: Boolean read FIsBot write FIsBot;
    property BotRank: Byte read FBotRank write FBotRank;
    property SpawnPositionIndex: Byte read FSpawnPositionIndex write FSpawnPositionIndex;
    property SkinID: Cardinal read FSkinID write FSkinID;
    property Name: string read FName write FName;
    property Skin: string read FSkin write FSkin;
  end;

implementation

{ TS2C_CreateHero }

function TS2C_CreateHero.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_CreateHero;
end;

procedure TS2C_CreateHero.ReadBody(reader: TByteReader);
begin
  FUnitNetID := reader.ReadUInt32;
  FClientID := reader.ReadUInt32;
  FNetNodeID := reader.ReadByte;
  FSkillLevel := reader.ReadByte;
  FTeamIsOrder := reader.ReadBool;
  FIsBot := reader.ReadBool;
  FBotRank := reader.ReadByte;
  FSpawnPositionIndex := reader.ReadByte;
  FSkinID := reader.ReadUInt32;
  FName := reader.ReadFixedString(40);
  FSkin := reader.ReadFixedString(40);
end;

procedure TS2C_CreateHero.WriteBody(writer: TByteWriter);
begin
  writer.WriteUInt32(FUnitNetID);
  writer.WriteUInt32(FClientID);
  writer.WriteByte(FNetNodeID);
  writer.WriteByte(FSkillLevel);
  writer.WriteBool(FTeamIsOrder);
  writer.WriteBool(FIsBot);
  writer.WriteByte(FBotRank);
  writer.WriteByte(FSpawnPositionIndex);
  writer.WriteUInt32(FSkinID);
  writer.WriteFixedString(FName, 40);
  writer.WriteFixedString(FSkin, 40);
end;

end.

