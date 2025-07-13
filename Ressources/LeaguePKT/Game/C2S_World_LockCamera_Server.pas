unit C2S_World_LockCamera_Server;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TC2S_World_LockCamera_Server = class(TGamePacket)
  private
    FLocked: Boolean;
    FClientID: Cardinal;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property Locked: Boolean read FLocked write FLocked;
    property ClientID: Cardinal read FClientID write FClientID;
  end;

implementation

{ TC2S_World_LockCamera_Server }

function TC2S_World_LockCamera_Server.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_World_LockCamera_Server;
end;

procedure TC2S_World_LockCamera_Server.ReadBody(reader: TByteReader);
begin
  FLocked := reader.ReadBool;
  FClientID := reader.ReadUInt32;
end;

procedure TC2S_World_LockCamera_Server.WriteBody(writer: TByteWriter);
begin
  writer.WriteBool(FLocked);
  writer.WriteUInt32(FClientID);
end;

end.

