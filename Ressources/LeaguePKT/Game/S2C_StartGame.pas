unit S2C_StartGame;

interface

uses
  SysUtils,
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter;

type
  TS2C_StartGame = class(TGamePacket)
  private
    FTournamentPauseEnabled: Boolean;
  public
    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property TournamentPauseEnabled: Boolean read FTournamentPauseEnabled write FTournamentPauseEnabled;
  end;

implementation

function TS2C_StartGame.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_StartGame;
end;

procedure TS2C_StartGame.ReadBody(reader: TByteReader);
var
  Bitfield: Byte;
begin
  // FIXME: riot?
  if reader.BytesLeft > 0 then
  begin
    Bitfield := reader.ReadByte;
    FTournamentPauseEnabled := FTournamentPauseEnabled or ((Bitfield and 1) <> 0);
  end;
end;

procedure TS2C_StartGame.WriteBody(writer: TByteWriter);
var
  Bitfield: Byte;
begin
  Bitfield := 0;
  if FTournamentPauseEnabled then
    Bitfield := Bitfield or 1;
  writer.WriteByte(Bitfield);
end;

end.

