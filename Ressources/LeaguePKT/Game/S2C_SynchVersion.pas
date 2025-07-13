unit S2C_SynchVersion;

interface

uses
  SysUtils,
  GamePacket,
  GamePacketID,
  PlayerLoadInfo,
  ByteReader,
  ByteWriter;

type
  TS2C_SynchVersion = class(TGamePacket)
  private
    FIsVersionOK: Boolean;
    FMapToLoad: Integer;
    FPlayerInfo: TArray<TPlayerLoadInfo>;
    FVersionString: string;
    FMapMode: string;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property IsVersionOK: Boolean read FIsVersionOK write FIsVersionOK;
    property MapToLoad: Integer read FMapToLoad write FMapToLoad;
    property PlayerInfo: TArray<TPlayerLoadInfo> read FPlayerInfo;
    property VersionString: string read FVersionString write FVersionString;
    property MapMode: string read FMapMode write FMapMode;
  end;

implementation

function TS2C_SynchVersion.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_SynchVersion;
end;

procedure TS2C_SynchVersion.ReadBody(reader: TByteReader);
var
  I: Integer;
begin
  FIsVersionOK := reader.ReadBool;
  FMapToLoad := reader.ReadInt32;
  for I := Low(FPlayerInfo) to High(FPlayerInfo) do
    FPlayerInfo[I] := ReadPlayerInfo(reader);
  FVersionString := reader.ReadFixedString(256);
  FMapMode := reader.ReadFixedString(128);
end;

procedure TS2C_SynchVersion.WriteBody(writer: TByteWriter);
var
  I: Integer;
begin
  writer.WriteBool(FIsVersionOK);
  writer.WriteInt32(FMapToLoad);
  for I := Low(FPlayerInfo) to High(FPlayerInfo) do
    WritePlayerInfo(writer,FPlayerInfo[I]);
  writer.WriteFixedString(FVersionString, 256);
  writer.WriteFixedString(FMapMode, 128);
end;

end.

