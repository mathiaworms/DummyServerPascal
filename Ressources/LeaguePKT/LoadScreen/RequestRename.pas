unit RequestRename;

interface

uses
  LoadScreenPacket,
  LoadScreenPacketID,
  ByteReader,
  ByteWriter,
  SysUtils;

type
  TRequestRename = class(TLoadScreenPacket)
  private
    FPlayerID: UInt64;
    FSkinID: Cardinal;
    FName: string;
  public
    function GetID: TLoadScreenPacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property PlayerID: UInt64 read FPlayerID write FPlayerID;
    property SkinID: Cardinal read FSkinID write FSkinID;
    property Name: string read FName write FName;
  end;

implementation

{ TRequestRename }

function TRequestRename.GetID: TLoadScreenPacketID;
begin
  Result := LoadScreenPacketID.RequestRename;
end;

procedure TRequestRename.ReadBody(reader: TByteReader);
begin
  reader.ReadPad(7);
  FPlayerID := reader.ReadUInt64;
  FSkinID := reader.ReadUInt32;
  FName := reader.ReadSizedStringWithZero;
end;

procedure TRequestRename.WriteBody(writer: TByteWriter);
begin
  writer.WritePad(7);
  writer.WriteUInt64(FPlayerID);
  writer.WriteUInt32(FSkinID);
  writer.WriteSizedStringWithZero(FName);
end;

end.

