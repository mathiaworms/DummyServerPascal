unit RequestJoinTeam;

interface

uses
  LoadScreenPacket, LoadScreenPacketID, // unité où est définie TLoadScreenPacket
  ByteReader, ByteWriter, System.SysUtils;

type
  TRequestJoinTeam = class(TLoadScreenPacket)
  private
    FClientID: Cardinal;
    FTeamID: Cardinal;
  public
    function GetID: TLoadScreenPacketID; override;

    procedure ReadBody(Reader: TByteReader); override;
    procedure WriteBody(Writer: TByteWriter); override;

    property ClientID: Cardinal read FClientID write FClientID;
    property TeamID: Cardinal read FTeamID write FTeamID;
  end;

implementation

{ TRequestJoinTeam }

function TRequestJoinTeam.GetID: TLoadScreenPacketID;
begin
  Result := TLoadScreenPacketID.RequestJoinTeam;
end;

procedure TRequestJoinTeam.ReadBody(Reader: TByteReader);
begin
  Reader.ReadPad(3);
  FClientID := Reader.ReadUInt32;
  FTeamID := Reader.ReadUInt32;
end;

procedure TRequestJoinTeam.WriteBody(Writer: TByteWriter);
begin
  Writer.WritePad(3);
  Writer.WriteUInt32(FClientID);
  Writer.WriteUInt32(FTeamID);
end;

end.

