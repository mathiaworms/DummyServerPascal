unit ConnectionInfo;

interface

uses
  System.SysUtils, System.Classes, ByteReader,
  ByteWriter;

type
  TConnectionInfo = class
  public
    ClientID: Cardinal;
    PlayerID: UInt64;
    Percentage: Single;
    ETA: Single;
    Count: SmallInt;
    Ping: Word;
    Ready: Boolean;
    constructor Create;
  end;


function ReadConnectionInfo(reader: TByteReader): TConnectionInfo;
procedure WriteConnectionInfo(writer: TByteWriter; data: TConnectionInfo);

implementation

{ TConnectionInfo }

constructor TConnectionInfo.Create;
begin
  inherited;
  ClientID := 0;
  PlayerID := 0;
  Percentage := 0.0;
  ETA := 0.0;
  Count := 0;
  Ping := 0;
  Ready := False;
end;

function ReadConnectionInfo(reader: TByteReader): TConnectionInfo;
begin
  Result := TConnectionInfo.Create;
  Result.ClientID := reader.ReadUInt32;
  Result.PlayerID := reader.ReadUInt64;
  Result.Percentage := reader.ReadFloat;
  Result.ETA := reader.ReadFloat;
  Result.Count := reader.ReadInt16;
  Result.Ping := reader.ReadUInt16 and $7FFF;
  Result.Ready := (reader.ReadByte and 1) <> 0;
end;

procedure WriteConnectionInfo(writer: TByteWriter; data: TConnectionInfo);
begin
  if data = nil then
    data := TConnectionInfo.Create;

  writer.WriteUInt32(data.ClientID);
  writer.WriteUInt64(data.PlayerID);
  writer.WriteFloat(data.Percentage);
  writer.WriteFloat(data.ETA);
  writer.WriteInt16(data.Count);
  writer.WriteUInt16(data.Ping and $7FFF);
  writer.WriteByte(Byte(Ord(data.Ready)));
end;

end.

