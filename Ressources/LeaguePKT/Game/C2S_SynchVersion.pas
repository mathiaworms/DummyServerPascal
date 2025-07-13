unit C2S_SynchVersion;

interface

uses
  System.SysUtils,
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TC2S_SynchVersion = class(TGamePacket)
  private
    FTimeLastClient: Single;
    FClientID: UInt32;
    FVersionString: string;
  public
    constructor Create; override;

    function GetID: TGamePacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property TimeLastClient: Single read FTimeLastClient write FTimeLastClient;
    property ClientID: UInt32 read FClientID write FClientID;
    property VersionString: string read FVersionString write FVersionString;
  end;

implementation

{ TC2S_SynchVersion }

constructor TC2S_SynchVersion.Create;
begin
  inherited;
  FVersionString := '';
end;

function TC2S_SynchVersion.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_SynchVersion;
end;

procedure TC2S_SynchVersion.ReadBody(reader: TByteReader);
begin
  FTimeLastClient := reader.ReadFloat;
  FClientID := reader.ReadUInt32;
  FVersionString := reader.ReadFixedString(256);
end;

procedure TC2S_SynchVersion.WriteBody(writer: TByteWriter);
begin
  writer.WriteFloat(FTimeLastClient);
  writer.WriteUInt32(FClientID);
  writer.WriteFixedString(FVersionString, 256);
end;

end.

