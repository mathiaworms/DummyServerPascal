unit DummyServerPascal;

interface
uses
  System.SysUtils, System.Generics.Collections, ENet, Blowfish, ChannelID;

procedure PrintHex(const Data: TBytes; PerLine: Integer = 8);

function SendPKT(const Peer: PENetPeer; ChannelID: Byte ; Data: TBytes ; Reliable : Boolean = true ; Unsequenced : Boolean = false): Boolean;

type

  TBasePacket = class
  end;

  TLeagueDisconnectedEventArgs = class
  private
    FClientID: Cardinal;
    function GetEventName: string;
  public
    constructor Create(AClientID: Cardinal);
    property ClientID: Cardinal read FClientID;
    property EventName: string read GetEventName;
  end;

  TLeagueConnectedEventArgs = class
  private
    FClientID: Cardinal;
    function GetEventName: string;
  public
    constructor Create(AClientID: Cardinal);
    property ClientID: Cardinal read FClientID;
    property EventName: string read GetEventName;
  end;

  TLeaguePacketEventArgs = class
  private
    FClientID: Cardinal;
    FChannelID: TChannelID;
    FPacket: TBasePacket;
    function GetEventName: string;
  public
    constructor Create(AClientID: Cardinal; AChannelID: TChannelID; APacket: TBasePacket);
    property EventName: string read GetEventName;
    property ClientID: Cardinal read FClientID write FClientID;
    property ChannelID: TChannelID read FChannelID;
    property Packet: TBasePacket read FPacket;
  end;

  TLeagueBadPacketEventArgs = class
  private
    FClientID: Cardinal;
    FChannelID: TChannelID;
    FRawData: TBytes;         // tableau de bytes
    FException: Exception;    // Exception
    procedure SetRawData(const Value: TBytes);
    procedure SetException(const Value: Exception);
    function GetEventName: string;
  public
    constructor Create(AClientID: Cardinal; AChannelID: TChannelID; APacket: TBasePacket);
    property EventName: string read GetEventName;
    property ClientID: Cardinal read FClientID write FClientID;
    property ChannelID: TChannelID read FChannelID;
    property RawData: TBytes read FRawData write SetRawData;           // set
    property Exception: Exception read FException write SetException;       //  set
  end;

  TLeagueServer = class
  private
    FHost: pENetHost;
    FBlowfish: TBlowfishData;
    FPeers: TDictionary<Cardinal, PENetPeer>; // Cardinal = uint
    //event
   // FOnDisconnected: TOnDisconnected;
   // FOnConnected: TOnConnected;
   // FOnPacket: TOnPacket;
   // FOnBadPacket: TOnBadPacket;
  public
    constructor Create(const Address: pENetAddress; const Key: TBytes; const ClientIDs: TList<Cardinal>);
    procedure LogPackets(const PeerID: Cardinal; const Data: TBytes; const ChannelID: Byte);
    function SendEncrypted(const Peer: PENetPeer;const ChannelID: Byte; const BasePKT: BasePacket; Reliable: Boolean = true ; Unsequenced: Boolean = false) : Boolean ;
    function SendEncrypted(const ClientID: Cardinal;const ChannelID: Byte; const BasePKT: BasePacket; Reliable: Boolean = true ; Unsequenced: Boolean = false) : Boolean ;
    procedure RunOnce();
    procedure HandlePacketParse(const ChannelID: Byte; const peer: PENetPeer; const rawpackets: pENetPacket);
    procedure HandleAuth(const peer: PENetPeer; const rawpackets: pENetPacket);
    //event
   // property OnDisconnected: TOnDisconnected read FOnDisconnected write FOnDisconnected;
   // property OnConnected: TOnConnected read FOnConnected write FOnConnected;
   // property OnPacket: TOnPacket read FOnPacket write FOnPacket;
   // property OnBadPacket: TOnBadPacket read FOnBadPacket write FOnBadPacket;
  end;

implementation

{ TLeagueDisconnectedEventArgs }

constructor TLeagueDisconnectedEventArgs.Create(AClientID: Cardinal);
begin
  inherited Create;
  FClientID := AClientID;
end;

function TLeagueDisconnectedEventArgs.GetEventName: string;
begin
  Result := 'disconnected';
end;

{ TLeagueConnectedEventArgs }

constructor TLeagueConnectedEventArgs.Create(AClientID: Cardinal);
begin
  inherited Create;
  FClientID := AClientID;
end;

function TLeagueConnectedEventArgs.GetEventName: string;
begin
  Result := 'connected';
end;

{ TLeaguePacketEventArgs }

constructor TLeaguePacketEventArgs.Create(AClientID: Cardinal; AChannelID: TChannelID; APacket: TBasePacket);
begin
  inherited Create;
  FClientID := AClientID;
  FChannelID := AChannelID;
  FPacket := APacket;
end;

function TLeaguePacketEventArgs.GetEventName: string;
begin
  Result := 'packet';
end;

{ TLeagueBadPacketEventArgs }

constructor TLeagueBadPacketEventArgs.Create(AClientID: Cardinal; AChannelID: TChannelID; APacket: TBasePacket);
begin
  inherited Create;
  FClientID := AClientID;
  FChannelID := AChannelID;
end;

procedure TLeagueBadPacketEventArgs.SetRawData(const Value: TBytes);
begin
  FRawData := Value;
end;

procedure TLeagueBadPacketEventArgs.SetException(const Value: Exception);
begin
  FException := Value;
end;

function TLeagueBadPacketEventArgs.GetEventName: string;
begin
  Result := 'packet';
end;

  { TLeagueServer }
constructor TLeagueServer.Create(const Address: pENetAddress; const Key: TBytes; const ClientIDs: TList<Cardinal>);
var
  ClientID: Cardinal;
begin
  FHost := enet_host_create(Address,32,8,0,0);
  Blowfish.BlowfishInit(FBlowfish, @Key[0], Length(Key), nil);
  FPeers := TDictionary<Cardinal, PENetPeer>.Create;

  for ClientID in ClientIDs do
    FPeers.Add(ClientID, nil);
end;

procedure TLeagueServer.LogPackets(const PeerID: Cardinal; const Data: TBytes; const ChannelID: Byte);
var
  Channel: byte;
  PacketID: byte;
  DataLength: Integer;
  PeerIDtoprint: Cardinal;
  i, c: Integer;
begin
    if Length(Data) = 0 then
      begin
        Writeln('LogPackets: data is empty');
        Exit;
      end;
    Channel := ChannelID;
    PacketID := Data[0];
    DataLength := Length(Data);
    PeerIDtoprint := PeerID;
   WriteLn(Format('Log packet(%d) on(%d) from(%d) size(%d)',
  [PacketID, Channel, PeerIDtoPrint, DataLength]));
  begin
    i := 0;
    while i < dataLength do
    begin
      for c := i to dataLength - 1 do
      begin
        if c >= i + 16 then
          Break;
        Write(Format('%2.2X ', [Byte(data[c])]));  // print hex
      end;
    WriteLn;
    end;
  end;
  Writeln;
end;

function TLeagueServer.SendEncrypted(const Peer: PENetPeer;const ChannelID: Byte; const BasePKT: BasePacket; Reliable: Boolean = true ; Unsequenced: Boolean = false): Boolean;
var
  Data: TBytes;
begin
  Data := BasePKT.GetByte();      //todo
  Data := EncryptECB(FBlowfish, Data);
  Result := SendPKT(Peer, ChannelID, Data ,Reliable , Unsequenced ) <> false;
end;

function TLeagueServer.SendEncrypted(const ClientID: Cardinal;const ChannelID: Byte; const BasePKT: BasePacket; Reliable: Boolean = true ; Unsequenced: Boolean = false): Boolean;
var
  Peer: PENetPeer;
begin
  if not FPeers.ContainsKey(ClientID) then
  begin
    Result := False;
    Exit;
  end;
  Peer:= FPeers[ClientID];
    //todo : LogPacket(client, packet.GetBytes(), channel);

  Result := SendEncrypted(Peer, ChannelID, BasePKT ,Reliable , Unsequenced ) <> false;
end;

procedure TLeagueServer.RunOnce();
var
  eevent: PENetEvent;
  cid: Cardinal;
begin
  while enet_host_service(FHost, @eevent, 0) > 0 do
  begin
    case eevent.kind of
       ENET_EVENT_TYPE_NONE:
        ;
       ENET_EVENT_TYPE_CONNECT:
       begin
         eevent.peer.data := Pointer(0);
         eevent.peer.mtu := 996;
       end;
       ENET_EVENT_TYPE_DISCONNECT:
       begin
          if (eevent.peer.data <> nil) or (Cardinal(eevent.peer.data) <> 0) then
          begin
           if not eevent.channelID <> (Cardinal(channelID.ChannelID_Default)) then
            begin
             enet_peer_disconnect(eevent.peer, 0);
            end

           else
            begin
             //HandleAuth(eevent.Peer, eevent.Packet);
            end
          end

          else
          begin
            //HandlePacketParse((ChannelID)eevent.ChannelID, eevent.Peer, eevent.Packet);
          end;
       end;
    end;
  end;
end;


procedure TLeagueServer.HandlePacketParse(const ChannelID: Byte; const peer: PENetPeer; const rawpackets: pENetPacket);
var
  ClientID: Cardinal;
  rawData: TBytes;
begin
  ClientID := (Cardinal(peer.data));        //todo check if is correct
  rawData := rawpackets.data;          //todo check if is correct
  rawData := DecryptECB(FBlowfish, rawData);
  try
    { TODO var packet = BasePacket.Create(rawData, channel);
      OnPacket(this, new LeaguePacketEventArgs(cid, channel, packet));
    }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;


procedure TLeagueServer.HandleAuth(const peer: PENetPeer; const rawpackets: pENetPacket);
var
  ClientID: Cardinal;
  rawData: TBytes;
begin
  rawData := rawpackets.data;          //todo check if is correct
  try
    { TODO var clientAuthPacket = new KeyCheckPacket(rawData);

    }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;



{ Custom Function for Print Hex  }

procedure PrintHex(const Data: TBytes; PerLine: Integer = 8);
var
  i, c: Integer;
begin
  for i := 0 to Length(Data) - 1 do
  begin
    if (i mod PerLine) = 0 then
      Writeln;
    Write(Format('%.2x ', [Data[i]]));
  end;
  Writeln;
end;

{ Send PKT  }

function SendPKT(const Peer: PENetPeer; ChannelID: Byte; Data: TBytes; Reliable: Boolean = true ; Unsequenced: Boolean = false): Boolean;
var
  flags : ENetPacketFlag;
  FlagsCardinal: Cardinal;
  packet: PENetPacket;
begin
  flags := ENET_PACKET_FLAG_NONE;
  if (Reliable) = true then
     flags := ENET_PACKET_FLAG_RELIABLE;
  if (Unsequenced) = true then
     flags := ENET_PACKET_FLAG_UNSEQUENCED;
  FlagsCardinal := Cardinal(flags);
  Packet := enet_packet_create(@Data[0], Length(Data), FlagsCardinal);
  Result := enet_peer_send(Peer, ChannelID, Packet) <> 0;
end;



end.
