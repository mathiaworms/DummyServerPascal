unit C2S_ClientReady;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TC2S_ClientReady = class(TGamePacket)
  public
    function GetID: TGamePacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;
  end;

implementation

{ TC2S_ClientReady }

function TC2S_ClientReady.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_ClientReady;
end;

procedure TC2S_ClientReady.ReadBody(reader: TByteReader);
begin
  // Rien à lire ici
end;

procedure TC2S_ClientReady.WriteBody(writer: TByteWriter);
begin
  // Rien à écrire ici
end;

end.

