unit GamePacket;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Rtti, System.TypInfo,// System.RttiUtils,
  ByteReader, ByteWriter,
  BasePacket,
  GamePacketID;
type
  TGamePacket = class;

  TGamePacketFactory = reference to function: TGamePacket;

  TGamePacketDict = TDictionary<TGamePacketID, TGamePacketFactory>;

  TGamePacket = class abstract(TBasePacket)
  private
    class var FLookup: TGamePacketDict;
    class function GenerateLookup: TGamePacketDict; static;
  public
    SenderNetID: Cardinal;

    constructor Create; override;

    function GetID: TGamePacketID; virtual; abstract;

    procedure ReadBody(Reader: TByteReader); virtual; abstract;
    procedure WriteBody(Writer: TByteWriter); virtual; abstract;

    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;

    class property Lookup: TGamePacketDict read FLookup;
  end;

implementation


{ TGamePacket }

constructor TGamePacket.Create;
begin
  inherited;
end;

procedure TGamePacket.ReadPacket(Reader: TByteReader);
var
  PacketID: TGamePacketID;
begin
  PacketID := TGamePacketID(Reader.ReadByte);
  SenderNetID := Reader.ReadUInt32;

  if PacketID = TGamePacketID.ExtendedPacket then
  begin
    Reader.ReadUInt16;
  end;

  ReadBody(Reader);
end;

procedure TGamePacket.WritePacket(Writer: TByteWriter);
var
  PacketID: Word;
begin
  PacketID := Ord(Self.GetID);

  if PacketID > $FF then
    Writer.WriteByte($FE)
  else
    Writer.WriteByte(Byte(PacketID));

  Writer.WriteUInt32(SenderNetID);

  if PacketID > $FF then
    Writer.WriteUInt16(PacketID);

  WriteBody(Writer);
end;

class function TGamePacket.GenerateLookup: TGamePacketDict;
var
  ctx: TRttiContext;
  typ: TRttiType;
  instType: TClass;
  packet: TGamePacket;
begin
  Result := TGamePacketDict.Create;

  ctx := TRttiContext.Create;
  try
    for typ in ctx.GetTypes do
    begin
      if (typ is TRttiInstanceType) then
      begin
        instType := TRttiInstanceType(typ).MetaclassType;

        if instType.InheritsFrom(TGamePacket) and
           (instType <> TGamePacket) and
           not instType.ClassNameIs('TGamePacket') then
        begin
          packet := TGamePacket(instType.Create);
          try
            if Result.ContainsKey(packet.GetID) then
              raise Exception.Create('ID already in lookup map');

            Result.Add(packet.GetID, function: TGamePacket
              begin
                Result := instType.Create as TGamePacket;
              end);
          finally
            packet.Free;
          end;
        end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;


initialization
  TGamePacket.FLookup := TGamePacket.GenerateLookup;

finalization
  TGamePacket.FLookup.Free;

end.

