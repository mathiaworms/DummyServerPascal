unit UnknownPacket;

interface

uses
  BasePacket, ByteReader, ByteWriter, System.Classes,  System.SysUtils;

type
  TUnknownPacket = class(TBasePacket)
  private
    FBytesLeft: TBytes;
  public
    constructor Create; overload;
    constructor Create(const Data: TBytes); overload;

    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;

    property BytesLeft: TBytes read FBytesLeft write FBytesLeft;
  end;

implementation

{ TUnknownPacket }

constructor TUnknownPacket.Create;
begin
  inherited Create;
  // Pas d'implémentation spécifique ici
end;

constructor TUnknownPacket.Create(const Data: TBytes);
begin
  inherited Create;
  FBytesLeft := Data;
end;

procedure TUnknownPacket.ReadPacket(Reader: TByteReader);
begin
  // Ne fait rien
end;

procedure TUnknownPacket.WritePacket(Writer: TByteWriter);
begin
  // Ne fait rien
end;

end.

