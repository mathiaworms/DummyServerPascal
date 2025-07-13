unit PlayerLoadInfo;

interface

uses
  System.SysUtils, System.Classes, ByteReader,
  ByteWriter;

type
  TPlayerLoadInfo = class
  public
    PlayerID: UInt64;
    SummonorLevel: Word;
    SummonorSpell1: Cardinal;
    SummonorSpell2: Cardinal;
    IsBot: Boolean;
    TeamId: Cardinal;
    BotName: string;
    BotSkinName: string;
    BotDifficulty: Integer;
    ProfileIconId: Integer;
    constructor Create;
  end;



function ReadPlayerInfo(reader: TByteReader): TPlayerLoadInfo;
procedure WritePlayerInfo(writer: TByteWriter; data: TPlayerLoadInfo);

implementation

{ TPlayerLoadInfo }

constructor TPlayerLoadInfo.Create;
begin
  inherited;
  PlayerID := UInt64($FFFFFFFFFFFFFFFF); // -1 in UInt64
  SummonorLevel := 0;
  SummonorSpell1 := 0;
  SummonorSpell2 := 0;
  IsBot := False;
  TeamId := 0;
  BotName := '';
  BotSkinName := '';
  BotDifficulty := 0;
  ProfileIconId := 0;
end;

function ReadPlayerInfo(reader: TByteReader): TPlayerLoadInfo;
begin
  Result := TPlayerLoadInfo.Create;
  Result.PlayerID := reader.ReadUInt64;
  Result.SummonorLevel := reader.ReadUInt16;
  Result.SummonorSpell1 := reader.ReadUInt32;
  Result.SummonorSpell2 := reader.ReadUInt32;
  Result.IsBot := reader.ReadBool;
  Result.TeamId := reader.ReadUInt32;
  reader.ReadPad(28); // Padding instead of reading BotName string
  reader.ReadPad(28); // Padding instead of reading BotSkinName string
  // To implement reading fixed strings, you can replace above lines with:
  // Result.BotName := reader.ReadFixedString(64);
  // Result.BotSkinName := reader.ReadFixedString(64);
  Result.BotDifficulty := reader.ReadInt32;
  Result.ProfileIconId := reader.ReadInt32;
end;

procedure WritePlayerInfo(writer: TByteWriter; data: TPlayerLoadInfo);
begin
  if data = nil then
    data := TPlayerLoadInfo.Create;

  writer.WriteUInt64(data.PlayerID);
  writer.WriteUInt16(data.SummonorLevel);
  writer.WriteUInt32(data.SummonorSpell1);
  writer.WriteUInt32(data.SummonorSpell2);
  writer.WriteBool(data.IsBot);
  writer.WriteUInt32(data.TeamId);
  writer.WritePad(28); // Padding instead of writing BotName string
  writer.WritePad(28); // Padding instead of writing BotSkinName string
  // To write fixed strings, replace above with:
  // writer.WriteFixedString(data.BotName, 64);
  // writer.WriteFixedString(data.BotSkinName, 64);
  writer.WriteInt32(data.BotDifficulty);
  writer.WriteInt32(data.ProfileIconId);
end;

end.

