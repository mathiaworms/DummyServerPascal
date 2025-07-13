unit DummyServerPascal;

interface
uses
  System.SysUtils, System.Generics.Collections, ENet, Blowfish, ChannelID, BasePacket, KeyCheckPacket;

procedure PrintHex(const Data: TBytes; PerLine: Integer = 8);

function SendPKT(const Peer: PENetPeer; ChannelID: Byte; Data: TBytes; Reliable: Boolean = true; Unsequenced: Boolean = false): Boolean;

type
  TLeagueServer = class;

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
    property ClientID: Cardinal read FClientID;
    property ChannelID: TChannelID read FChannelID;
    property Packet: TBasePacket read FPacket;
  end;

  TLeagueBadPacketEventArgs = class
  private
    FClientID: Cardinal;
    FChannelID: TChannelID;
    FRawData: TBytes;
    FException: Exception;
    function GetEventName: string;
  public
    constructor Create(AClientID: Cardinal; AChannelID: TChannelID; const ARawData: TBytes; AException: Exception);
    property EventName: string read GetEventName;
    property ClientID: Cardinal read FClientID;
    property ChannelID: TChannelID read FChannelID;
    property RawData: TBytes read FRawData;
    property Exception: Exception read FException;
  end;

  TOnDisconnected = procedure(Sender: TObject; Args: TLeagueDisconnectedEventArgs) of object;
  TOnConnected = procedure(Sender: TObject; Args: TLeagueConnectedEventArgs) of object;
  TOnPacket = procedure(Sender: TObject; Args: TLeaguePacketEventArgs) of object;
  TOnBadPacket = procedure(Sender: TObject; Args: TLeagueBadPacketEventArgs) of object;

  TLeagueServer = class
  private
    FHost: pENetHost;
    FBlowfish: TBlowfishData;
    FPeers: TDictionary<Cardinal, PENetPeer>;

    FOnDisconnected: TOnDisconnected;
    FOnConnected: TOnConnected;
    FOnPacket: TOnPacket;
    FOnBadPacket: TOnBadPacket;

    procedure HandlePacketParse(ChannelID: Byte; peer: PENetPeer; rawpacket: pENetPacket);
    procedure HandleAuth(peer: PENetPeer; rawpacket: pENetPacket);
    function SendEncrypted(peer: PENetPeer; ChannelID: Byte; BasePKT: TBasePacket; Reliable: Boolean = true; Unsequenced: Boolean = false): Boolean; overload;
  public
    constructor Create(const Address: ENetAddress; const Key: TBytes; const ClientIDs: TList<Cardinal>);
    //destructor Destroy; override;

    procedure LogPackets(PeerID: Cardinal; const Data: TBytes; ChannelID: Byte);
    function SendEncrypted(ClientID: Cardinal; ChannelID: Byte; BasePKT: TBasePacket; Reliable: Boolean = true; Unsequenced: Boolean = false): Boolean; overload;
    procedure RunOnce();

    property OnDisconnected: TOnDisconnected read FOnDisconnected write FOnDisconnected;
    property OnConnected: TOnConnected read FOnConnected write FOnConnected;
    property OnPacket: TOnPacket read FOnPacket write FOnPacket;
    property OnBadPacket: TOnBadPacket read FOnBadPacket write FOnBadPacket;
  end;

implementation

{ TLeagueDisconnectedEventArgs }
constructor TLeagueDisconnectedEventArgs.Create(AClientID: Cardinal);
begin
  FClientID := AClientID;
end;

function TLeagueDisconnectedEventArgs.GetEventName: string;
begin
  Result := 'disconnected';
end;

{ TLeagueConnectedEventArgs }
constructor TLeagueConnectedEventArgs.Create(AClientID: Cardinal);
begin
  FClientID := AClientID;
end;

function TLeagueConnectedEventArgs.GetEventName: string;
begin
  Result := 'connected';
end;

{ TLeaguePacketEventArgs }
constructor TLeaguePacketEventArgs.Create(AClientID: Cardinal; AChannelID: TChannelID; APacket: TBasePacket);
begin
  FClientID := AClientID;
  FChannelID := AChannelID;
  FPacket := APacket;
end;

function TLeaguePacketEventArgs.GetEventName: string;
begin
  Result := 'packet';
end;

{ TLeagueBadPacketEventArgs }
constructor TLeagueBadPacketEventArgs.Create(AClientID: Cardinal; AChannelID: TChannelID; const ARawData: TBytes; AException: Exception);
begin
  FClientID := AClientID;
  FChannelID := AChannelID;
  FRawData := ARawData;
  FException := AException;
end;

function TLeagueBadPacketEventArgs.GetEventName: string;
begin
  Result := 'badpacket';
end;

{ TLeagueServer }
constructor TLeagueServer.Create(const Address: ENetAddress; const Key: TBytes; const ClientIDs: TList<Cardinal>);
var
  ClientID: Cardinal;
begin
  Writeln('Creating server...');
  FHost := enet_host_create(@Address, 32, 8, 0, 0);
  if FHost = nil then
  begin
    Writeln('Failed to create ENet host!');
    raise Exception.Create('Failed to create ENet host');
  end
  else
    Writeln('ENet host created successfully');

  Writeln('Initializing Blowfish with key length: ', Length(Key));
  BlowfishInit(FBlowfish, @Key[0], Length(Key),nil);

  FPeers := TDictionary<Cardinal, PENetPeer>.Create;
  Writeln('Allowed client IDs:');

  for ClientID in ClientIDs do
  begin
    FPeers.Add(ClientID, nil);
    Writeln('  - ', ClientID);
  end;

  Writeln('Server initialized. Waiting for connections...');
end;

{ destructor TLeagueServer.Destroy;
begin
  Writeln('Destroying server...');
  if FHost <> nil then
    enet_host_destroy(FHost);

  FPeers.Free;
  inherited;
  Writeln('Server destroyed');
end;  }

procedure TLeagueServer.LogPackets(PeerID: Cardinal; const Data: TBytes; ChannelID: Byte);
var
  PacketID: Byte;
  DataLength: Integer;
  i, c: Integer;
begin
  if Length(Data) = 0 then
  begin
    Writeln('LogPackets: data is empty');
    Exit;
  end;

  PacketID := Data[0];
  DataLength := Length(Data);

  WriteLn(Format('Log packet(%d) on(%d) from(%d) size(%d)',
    [PacketID, ChannelID, PeerID, DataLength]));

  i := 0;
  while i < DataLength do
  begin
    for c := i to i + 15 do
    begin
      if c >= DataLength then Break;
      Write(Format('%.2X ', [Data[c]]));
    end;
    WriteLn;
    Inc(i, 16);
  end;
end;

function TLeagueServer.SendEncrypted(peer: PENetPeer; ChannelID: Byte; BasePKT: TBasePacket; Reliable, Unsequenced: Boolean): Boolean;
var
  Data: TBytes;
begin
  Writeln('Sending encrypted packet to client: ', Cardinal(peer^.data));
  Writeln('Packet type: ', BasePKT.ClassName);

  Data := BasePKT.GetBytes;
  Writeln('Original packet data (', Length(Data), ' bytes):');
  PrintHex(Data);

  Data := EncryptECB(FBlowfish, Data);
  Writeln('Encrypted packet data (', Length(Data), ' bytes):');
  PrintHex(Data);

  Result := SendPKT(peer, ChannelID, Data, Reliable, Unsequenced);

  if Result then
    Writeln('Packet sent successfully')
  else
    Writeln('Failed to send packet');
end;

function TLeagueServer.SendEncrypted(ClientID: Cardinal; ChannelID: Byte; BasePKT: TBasePacket; Reliable, Unsequenced: Boolean): Boolean;
var
  peer: PENetPeer;
begin
  if not FPeers.TryGetValue(ClientID, peer) or (peer = nil) then
    Exit(False);

  Result := SendEncrypted(peer, ChannelID, BasePKT, Reliable, Unsequenced);
end;

procedure TLeagueServer.HandlePacketParse(ChannelID: Byte; peer: PENetPeer; rawpacket: pENetPacket);
var
  ClientID: Cardinal;
  rawData, decryptedData: TBytes;
  packet: TBasePacket;
  channel: TChannelID;
begin
  ClientID := Cardinal(peer^.data);
  Writeln('Handling packet for client: ', ClientID);

  SetLength(rawData, rawpacket^.dataLength);
  Move(rawpacket^.data^, rawData[0], rawpacket^.dataLength);
  Writeln('Raw packet data (encrypted):');
  PrintHex(rawData);

  try
    decryptedData := DecryptECB(FBlowfish, rawData);
    Writeln('Decrypted packet data:');
    PrintHex(decryptedData);

    channel := ByteToChannelID(ChannelID);
    Writeln('Creating packet for channel: ', Ord(channel));

    packet := TBasePacket.CreatePacket(decryptedData, channel);
    try
      Writeln('Packet created successfully. Type: ', packet.ClassName);

      if Assigned(FOnPacket) then
      begin
        Writeln('Raising OnPacket event...');
        FOnPacket(Self, TLeaguePacketEventArgs.Create(ClientID, channel, packet));
      end
      else
        Writeln('OnPacket event not assigned');
    finally
      packet.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln('Error parsing packet: ', E.Message);
      Writeln('Raw data causing error:');
      PrintHex(rawData);

      if Assigned(FOnBadPacket) then
      begin
        Writeln('Raising OnBadPacket event...');
        FOnBadPacket(Self, TLeagueBadPacketEventArgs.Create(ClientID, channel, rawData, E));
      end
      else
        Writeln('OnBadPacket event not assigned');
    end;
  end;
end;


procedure TLeagueServer.HandleAuth(peer: PENetPeer; rawpacket: pENetPacket);
var
  rawData: TBytes;
  clientAuthPacket: TKeyCheckPacket;
  cid: Cardinal;
  serverAuthPacket: TKeyCheckPacket;
  playerIDBytes: TBytes;
  encryptedID: TBytes;
begin
  Writeln('Handling authentication...');

  SetLength(rawData, rawpacket^.dataLength);
  Move(rawpacket^.data^, rawData[0], rawpacket^.dataLength);
  Writeln('Auth packet data:');
  PrintHex(rawData);

  try
    clientAuthPacket := TKeyCheckPacket.Create(rawData);
    try
      Writeln(Format('Authing player %d for client %d',
        [clientAuthPacket.PlayerID, clientAuthPacket.ClientID]));

      // Convert player ID to bytes
      SetLength(playerIDBytes, SizeOf(UInt64));
      Move(clientAuthPacket.PlayerID, playerIDBytes[0], SizeOf(UInt64));
      Writeln('Player ID bytes:');
      PrintHex(playerIDBytes);

      // Encrypt player ID
      encryptedID := EncryptECB(FBlowfish, playerIDBytes);
      Writeln('Encrypted player ID:');
      PrintHex(encryptedID);
      Writeln('Expected player ID:');
      PrintHex(TBytes(@clientAuthPacket.EncryptedPlayerID), SizeOf(UInt64));

      // Check if encrypted ID matches
      if not CompareMem(@encryptedID[0], @clientAuthPacket.EncryptedPlayerID, SizeOf(UInt64)) then
      begin
        Writeln('Bad checksum! Disconnecting client...');
        enet_peer_disconnect(peer, 0);
        Exit;
      end;

      cid := clientAuthPacket.PlayerID;
      Writeln('Authentication successful for client: ', cid);

      if not FPeers.ContainsKey(cid) then
      begin
        Writeln('Client ID not allowed: ', cid, '. Disconnecting...');
        enet_peer_disconnect(peer, 0);
        Exit;
      end;

      if FPeers[cid] <> nil then
      begin
        Writeln('Client already connected: ', cid, '. Disconnecting...');
        enet_peer_disconnect(peer, 0);
        Exit;
      end;

      // Authenticate client
      peer^.data := Pointer(cid);
      FPeers[cid] := peer;
      Writeln('Client authenticated: ', cid);

      // Send server auth packet
      serverAuthPacket := TKeyCheckPacket.Create;
      try
        serverAuthPacket.ClientID := cid;
        serverAuthPacket.PlayerID := cid;
        serverAuthPacket.EncryptedPlayerID := clientAuthPacket.EncryptedPlayerID;

        Writeln('Sending server auth packet...');
        if SendEncrypted(peer, Byte(ChannelID_Default), serverAuthPacket) then
          Writeln('Server auth packet sent successfully')
        else
          Writeln('Failed to send server auth packet');
      finally
        serverAuthPacket.Free;
      end;

      if Assigned(FOnConnected) then
      begin
        Writeln('Raising OnConnected event...');
        FOnConnected(Self, TLeagueConnectedEventArgs.Create(cid));
      end
      else
        Writeln('OnConnected event not assigned');
    finally
      clientAuthPacket.Free;
    end;
  except
    on E: Exception do
    begin
      Writeln('Authentication error: ', E.ClassName, ' - ', E.Message);
      Writeln('Raw auth data:');
      PrintHex(rawData);
      enet_peer_disconnect(peer, 0);
    end;
  end;
end;

procedure TLeagueServer.RunOnce();
var
  eevent: ENetEvent;
begin
  while enet_host_service(FHost, @eevent, 0) > 0 do
  begin
    Writeln('Default event received: kind = ', Ord(eevent.eventType ));

    case eevent.eventType of
      ENET_EVENT_TYPE_CONNECT:
        begin
          Writeln('New connection from: ',
            eevent.peer^.address.host, ':', eevent.peer^.address.port);
          eevent.peer^.data := nil;
          eevent.peer^.mtu := 996;
        end;

      ENET_EVENT_TYPE_DISCONNECT:
        begin
          if (eevent.peer^.data <> nil) then
          begin
            var cid := Cardinal(eevent.peer^.data);
            Writeln('Client disconnected: ', cid);
            FPeers[cid] := nil;
            if Assigned(FOnDisconnected) then
              FOnDisconnected(Self, TLeagueDisconnectedEventArgs.Create(cid));
          end
          else
          begin
            Writeln('Unauthenticated client disconnected');
          end;
        end;

      ENET_EVENT_TYPE_RECEIVE:
        begin
          try
            Writeln('Received packet on channel ', eevent.channelID,
                    ' (', eevent.packet^.dataLength, ' bytes)');

            if eevent.peer^.data = nil then // Non authentifié
            begin
              Writeln('Processing auth packet...');
              if eevent.channelID <> Byte(ChannelID_Default) then
              begin
                Writeln('Unauthenticated client sent packet on non-default channel. Disconnecting...');
                enet_peer_disconnect(eevent.peer, 0)
              end
              else
              begin
                HandleAuth(eevent.peer, eevent.packet);
              end;
            end
            else // Déjà authentifié
            begin
              var cid := Cardinal(eevent.peer^.data);
              Writeln('Processing packet from client: ', cid);
              HandlePacketParse(eevent.channelID, eevent.peer, eevent.packet);
            end;
          finally
            enet_packet_destroy(eevent.packet);
          end;
        end;
    else
      Writeln('Unknown ENet event kind: ', Ord(eevent.eventType));
    end;
  end;
end;

{ Helpers }
procedure PrintHex(const Data: TBytes; PerLine: Integer = 8);
var
  i: Integer;
begin
  for i := 0 to High(Data) do
  begin
    if (i > 0) and (i mod PerLine = 0) then
      WriteLn;
    Write(Format('%.2X ', [Data[i]]));
  end;
  WriteLn;
end;

function SendPKT(const Peer: PENetPeer; ChannelID: Byte; Data: TBytes; Reliable: Boolean; Unsequenced: Boolean): Boolean;
var
  flags: ENetPacketFlag;
  packet: pENetPacket;
begin
  flags := ENET_PACKET_FLAG_NONE;
  if Reliable then
    flags := ENET_PACKET_FLAG_RELIABLE;
  if Unsequenced then
    flags := ENET_PACKET_FLAG_UNSEQUENCED;

  packet := enet_packet_create(@Data[0], Length(Data), (Cardinal(flags)) );
  Result := (enet_peer_send(peer, ChannelID, packet) = 0);
end;

end.
