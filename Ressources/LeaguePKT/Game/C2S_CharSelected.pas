unit C2S_CharSelected;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TC2S_CharSelected = class(TGamePacket)
  public
    function GetID: TGamePacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;
  end;

implementation

{ TC2S_CharSelected }

function TC2S_CharSelected.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_CharSelected;
end;

procedure TC2S_CharSelected.ReadBody(reader: TByteReader);
begin
  // Aucun corps à lire ici
end;

procedure TC2S_CharSelected.WriteBody(writer: TByteWriter);
begin
  // Aucun corps à écrire ici
end;

end.

