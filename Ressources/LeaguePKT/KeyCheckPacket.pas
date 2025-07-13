unit KeyCheckPacket;

interface

uses
  System.SysUtils,
  ByteReader,
  ByteWriter,
  BasePacket;

type
  TKeyCheckPacket = class(TBasePacket)
  public
    Action: Byte;
    ClientID: Cardinal;
    PlayerID: UInt64;
    EncryptedPlayerID: UInt64;

    constructor Create; overload;
    constructor Create(const Data: TBytes); overload;

    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;
  end;

implementation

{ TKeyCheckPacket }

constructor TKeyCheckPacket.Create;
begin
  inherited Create;
end;

constructor TKeyCheckPacket.Create(const Data: TBytes);
begin
  inherited Create;
  Read(Data);
end;

procedure TKeyCheckPacket.ReadPacket(Reader: TByteReader);
begin
  Action := Reader.ReadByte;
  Reader.ReadPad(3); // lire 3 octets inutilisés
  ClientID := Reader.ReadUInt32;
  PlayerID := Reader.ReadUInt64;
  EncryptedPlayerID := Reader.ReadUInt64;
end;

procedure TKeyCheckPacket.WritePacket(Writer: TByteWriter);
begin
  Writer.WriteByte(Action);
  Writer.WritePad(3); // écrire 3 octets vides
  Writer.WriteUInt32(ClientID);
  Writer.WriteUInt64(PlayerID);
  Writer.WriteUInt64(EncryptedPlayerID);
end;

end.

