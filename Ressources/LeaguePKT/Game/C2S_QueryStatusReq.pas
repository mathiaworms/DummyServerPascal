unit C2S_QueryStatusReq;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TC2S_QueryStatusReq = class(TGamePacket)
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;
  end;

implementation

{ TC2S_QueryStatusReq }

function TC2S_QueryStatusReq.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_QueryStatusReq;
end;

procedure TC2S_QueryStatusReq.ReadBody(reader: TByteReader);
begin
  // Rien à lire
end;

procedure TC2S_QueryStatusReq.WriteBody(writer: TByteWriter);
begin
  // Rien à écrire
end;

end.

