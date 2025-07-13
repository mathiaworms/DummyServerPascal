unit S2C_QueryStatusAns;

interface

uses
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TS2C_QueryStatusAns = class(TGamePacket)
  private
    FIsOK: Boolean;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property IsOK: Boolean read FIsOK write FIsOK;
  end;

implementation

{ TS2C_QueryStatusAns }

function TS2C_QueryStatusAns.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_QueryStatusAns;
end;

procedure TS2C_QueryStatusAns.ReadBody(reader: TByteReader);
begin
  FIsOK := reader.ReadBool;
end;

procedure TS2C_QueryStatusAns.WriteBody(writer: TByteWriter);
begin
  writer.WriteBool(FIsOK);
end;

end.

