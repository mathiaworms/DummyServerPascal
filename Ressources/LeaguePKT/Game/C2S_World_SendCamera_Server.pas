unit C2S_World_SendCamera_Server;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter,
  System.Types; // Pour TPoint3D ou un équivalent de Vector3 (voir remarque)

type
  TVector3 = record
    X, Y, Z: Single;
  end;

  TC2S_World_SendCamera_Server = class(TGamePacket)
  private
    FCameraPosition: TVector3;
    FCameraDirection: TVector3;
    FClientID: Cardinal;
    FSyncID: ShortInt;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property CameraPosition: TVector3 read FCameraPosition write FCameraPosition;
    property CameraDirection: TVector3 read FCameraDirection write FCameraDirection;
    property ClientID: Cardinal read FClientID write FClientID;
    property SyncID: ShortInt read FSyncID write FSyncID;
  end;

implementation

{ TC2S_World_SendCamera_Server }

function TC2S_World_SendCamera_Server.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_World_SendCamera_Server;
end;

procedure TC2S_World_SendCamera_Server.ReadBody(reader: TByteReader);
begin
  FCameraPosition.X := reader.ReadFloat;
  FCameraPosition.Y := reader.ReadFloat;
  FCameraPosition.Z := reader.ReadFloat;

  FCameraDirection.X := reader.ReadFloat;
  FCameraDirection.Y := reader.ReadFloat;
  FCameraDirection.Z := reader.ReadFloat;

  FClientID := reader.ReadUInt32;
  FSyncID := reader.ReadSByte;
end;

procedure TC2S_World_SendCamera_Server.WriteBody(writer: TByteWriter);
begin
  writer.WriteFloat(FCameraPosition.X);
  writer.WriteFloat(FCameraPosition.Y);
  writer.WriteFloat(FCameraPosition.Z);

  writer.WriteFloat(FCameraDirection.X);
  writer.WriteFloat(FCameraDirection.Y);
  writer.WriteFloat(FCameraDirection.Z);

  writer.WriteUInt32(FClientID);
  writer.WriteSByte(FSyncID);
end;

end.

