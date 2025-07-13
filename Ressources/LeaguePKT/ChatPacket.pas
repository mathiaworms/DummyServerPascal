unit ChatPacket;

interface

uses
  System.SysUtils,
  ByteReader,
  ByteWriter,
  BasePacket;

type
  TChatPacket = class(TBasePacket)
  public
    ClientID: Cardinal;
    ChatType: Cardinal;
    Message: string;

    constructor Create; overload;
    constructor Create(const Data: TBytes); overload;

    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;
  end;

implementation

{ TChatPacket }

constructor TChatPacket.Create;
begin
  inherited Create;
end;

constructor TChatPacket.Create(const Data: TBytes);
begin
  inherited Create;
  Read(Data);
end;

procedure TChatPacket.ReadPacket(Reader: TByteReader);
begin
  ClientID := Reader.ReadUInt32;
  ChatType := Reader.ReadUInt32;
  Message := Reader.ReadSizedStringWithZero;
end;

procedure TChatPacket.WritePacket(Writer: TByteWriter);
begin
  Writer.WriteUInt32(ClientID);
  Writer.WriteUInt32(ChatType);
  Writer.WriteSizedStringWithZero(Message);
end;

end.

