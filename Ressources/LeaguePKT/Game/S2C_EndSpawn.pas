unit S2C_EndSpawn;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TS2C_EndSpawn = class(TGamePacket)
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;
  end;

implementation

{ TS2C_EndSpawn }

function TS2C_EndSpawn.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_EndSpawn;
end;

procedure TS2C_EndSpawn.ReadBody(reader: TByteReader);
begin
  // Aucun corps à lire
end;

procedure TS2C_EndSpawn.WriteBody(writer: TByteWriter);
begin
  // Aucun corps à écrire
end;

end.

