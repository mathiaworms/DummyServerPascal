unit BasePacket;

interface

uses
  SysUtils, ByteReader, ByteWriter, ChannelID, GamePacketID ;

type
  TBasePacket = class abstract
  private
    FBytesLeft: TBytes;
  protected
    constructor Create; virtual;
    procedure ReadPacket(Reader: TByteReader); virtual; abstract;
    procedure WritePacket(Writer: TByteWriter); virtual; abstract;
  public
    property BytesLeft: TBytes read FBytesLeft write FBytesLeft;
    procedure Read(const Data: TBytes);
    function GetBytes: TBytes; virtual;

    class function CreatePacket(const Data: TBytes; Channel: TChannelID): TBasePacket;
  end;

implementation

uses
  KeyCheckPacket, GamePacket, BatchGamePacket, UnknownPacket, ChatPacket, LoadScreenPacket, LoadScreenPacketID;



{ TBasePacket }

constructor TBasePacket.Create;
begin
  inherited Create;
  FBytesLeft := nil;
end;

procedure TBasePacket.Read(const Data: TBytes);
var
  Reader: TByteReader;
begin
  Reader := TByteReader.Create(Data);
  try
    Self.ReadPacket(Reader);
    FBytesLeft := Reader.ReadBytesLeft;
  finally
    Reader.Free;
  end;
end;

function TBasePacket.GetBytes: TBytes;
var
  Writer: TByteWriter;
begin
  Writer := TByteWriter.Create;
  try
    Self.WritePacket(Writer);
    Writer.WriteBytes(FBytesLeft);
    Result := Writer.GetBytes;
  finally
    Writer.Free;
  end;
end;

class function TBasePacket.CreatePacket(const Data: TBytes; Channel: TChannelID): TBasePacket;

  function Construct: TBasePacket;
  var
    GameID: TGamePacketID;
    LoadScreenID: TLoadScreenPacketID;
  begin
    if Length(Data) = 0 then
      raise Exception.Create('Empty packet cannot be parsed!');

    case Channel of
      ChannelID_Default:
        Exit(TKeyCheckPacket.Create);

      ChannelID_ClientToServer,
      ChannelID_SynchClock,
      ChannelID_Broadcast,
      ChannelID_BroadcastUnreliable:
        begin
          GameID := TGamePacketID(Data[0]);

          if GameID = GamePacketID.Batch then
            Exit(TBatchGamePacket.Create);

          if GameID = GamePacketID.ExtendedPacket then
          begin
            if Length(Data) < 7 then
              raise Exception.Create('Packet too small to be extended packet!');
            GameID := TGamePacketID(Word(Data[5]) or (Word(Data[6]) shl 8));
          end;

          if TGamePacket.Lookup.ContainsKey(GameID) then
            Exit(TGamePacket.Lookup[GameID]());

          Exit(TUnknownPacket.Create);
        end;

      ChannelID_Chat:
        Exit(TChatPacket.Create);

      ChannelID_LoadingScreen:
        begin
          LoadScreenID := TLoadScreenPacketID(Data[0]);
          if TLoadScreenPacket.Lookup.ContainsKey(LoadScreenID) then
            Exit(TLoadScreenPacket.Lookup[LoadScreenID]());
          Exit(TUnknownPacket.Create);
        end;

    else
      Exit(TUnknownPacket.Create);
    end;
  end;

begin
  Result := Construct;
  Result.Read(Data);
end;

end.

