unit BatchGamePacket;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  ByteReader,
  ByteWriter,
  GamePacket,
  BasePacket,
  GamePacketID;

type
  TBatchGamePacket = class(TBasePacket)
  public
    Packets: TList<TGamePacket>;
    constructor Create;
    destructor Destroy; override;

    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;
  end;

implementation

{ TBatchGamePacket }

constructor TBatchGamePacket.Create;
begin
  inherited Create;
  Packets := TList<TGamePacket>.Create;
end;

destructor TBatchGamePacket.Destroy;
begin
  Packets.Free;
  inherited;
end;

procedure TBatchGamePacket.ReadPacket(Reader: TByteReader);
begin
  Reader.ReadByte;
  raise Exception.Create('Not implemented');
end;

procedure TBatchGamePacket.WritePacket(Writer: TByteWriter);
begin
  Writer.WriteByte(Byte(TGamePacketID.Batch));
  raise Exception.Create('Not implemented');
end;

end.

