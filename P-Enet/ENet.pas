unit ENet;

{$IFDEF UNICODE}
  {$DEFINE DELPHI_UNICODE}
{$ENDIF}

interface

uses
  Classes, SysUtils, Windows, WinSock;

const
  // Version ENet
  ENET_VERSION_MAJOR = 1;
  ENET_VERSION_MINOR = 2;
  ENET_VERSION_PATCH = 5;

  // Constantes ENet
  ENET_HOST_ANY = 0;
  ENET_HOST_BROADCASTCONST = $FFFFFFFF;
  ENET_PORT_ANY = 0;

  // Tailles
  ENET_BUFFER_MAXIMUM = 1 + 2 * 4096;
  ENET_HOST_RECEIVE_BUFFER_SIZE = 256 * 1024;
  ENET_HOST_SEND_BUFFER_SIZE = 256 * 1024;
  ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL = 1000;
  ENET_HOST_DEFAULT_MTU = 1400;
  ENET_HOST_DEFAULT_MAXIMUM_PACKET_SIZE = 32 * 1024 * 1024;
  ENET_HOST_DEFAULT_MAXIMUM_WAITING_DATA = 32 * 1024 * 1024;

  // Peer
  ENET_PEER_DEFAULT_ROUND_TRIP_TIME = 500;
  ENET_PEER_DEFAULT_PACKET_THROTTLE = 32;
  ENET_PEER_PACKET_THROTTLE_SCALE = 32;
  ENET_PEER_PACKET_THROTTLE_COUNTER = 7;
  ENET_PEER_PACKET_THROTTLE_ACCELERATION = 2;
  ENET_PEER_PACKET_THROTTLE_DECELERATION = 2;
  ENET_PEER_PACKET_THROTTLE_INTERVAL = 5000;
  ENET_PEER_PACKET_LOSS_SCALE = 1 shl 16;
  ENET_PEER_PACKET_LOSS_INTERVAL = 10000;
  ENET_PEER_WINDOW_SIZE_SCALE = 64 * 1024;
  ENET_PEER_TIMEOUT_LIMIT = 32;
  ENET_PEER_TIMEOUT_MINIMUM = 5000;
  ENET_PEER_TIMEOUT_MAXIMUM = 30000;
  ENET_PEER_PING_INTERVAL = 500;

  // Protocole
  ENET_PROTOCOL_MINIMUM_MTU = 576;
  ENET_PROTOCOL_MAXIMUM_MTU = 4096;
  ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS = 32;
  ENET_PROTOCOL_MINIMUM_WINDOW_SIZE = 4096;
  ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE = 32768;
  ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT = 1;
  ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT = 255;
  ENET_PROTOCOL_MAXIMUM_PEER_ID = $FFF;
  ENET_PROTOCOL_MAXIMUM_PACKET_SIZE = 1024 * 1024 * 1024;
  ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT = 1024 * 1024;

  ENET_PEER_RELIABLE_WINDOWS = 16;
  ENET_PEER_RELIABLE_WINDOW_SIZE = $1000;
  ENET_PEER_FREE_RELIABLE_WINDOWS = 8;
  ENET_PEER_UNSEQUENCED_WINDOW_SIZE = 1024;



type

  // Types de base
  ENetVersion = Cardinal;
  ENetSocketType = (ENET_SOCKET_TYPE_STREAM, ENET_SOCKET_TYPE_DATAGRAM);
  ENetSocketWait = (ENET_SOCKET_WAIT_NONE, ENET_SOCKET_WAIT_SEND, ENET_SOCKET_WAIT_RECEIVE);
  ENetSocketOption = (ENET_SOCKOPT_NONBLOCK, ENET_SOCKOPT_BROADCAST, ENET_SOCKOPT_RCVBUF, ENET_SOCKOPT_SNDBUF, ENET_SOCKOPT_REUSEADDR);

  // États des peers
  ENetPeerState = (
    ENET_PEER_STATE_DISCONNECTED,
    ENET_PEER_STATE_CONNECTING,
    ENET_PEER_STATE_ACKNOWLEDGING_CONNECT,
    ENET_PEER_STATE_CONNECTION_PENDING,
    ENET_PEER_STATE_CONNECTION_SUCCEEDED,
    ENET_PEER_STATE_CONNECTED,
    ENET_PEER_STATE_DISCONNECT_LATER,
    ENET_PEER_STATE_DISCONNECTING,
    ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT,
    ENET_PEER_STATE_ZOMBIE
  );

  // Types d'événements
  ENetEventType = (
    ENET_EVENT_TYPE_NONE,
    ENET_EVENT_TYPE_CONNECT,
    ENET_EVENT_TYPE_DISCONNECT,
    ENET_EVENT_TYPE_RECEIVE
  );

  // Flags des packets
  ENetPacketFlag = (
    ENET_PACKET_FLAG_NONE = 0,
    ENET_PACKET_FLAG_RELIABLE = 1,
    ENET_PACKET_FLAG_UNSEQUENCED = 2,
    ENET_PACKET_FLAG_NO_ALLOCATE = 4
  );

  // Commandes du protocole
  ENetProtocolCommand = (
    ENET_PROTOCOL_COMMAND_NONE,
    ENET_PROTOCOL_COMMAND_ACKNOWLEDGE,
    ENET_PROTOCOL_COMMAND_CONNECT,
    ENET_PROTOCOL_COMMAND_VERIFY_CONNECT,
    ENET_PROTOCOL_COMMAND_DISCONNECT,
    ENET_PROTOCOL_COMMAND_PING,
    ENET_PROTOCOL_COMMAND_SEND_RELIABLE,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE,
    ENET_PROTOCOL_COMMAND_SEND_FRAGMENT,
    ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED,
    ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT,
    ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT,
    ENET_PROTOCOL_COMMAND_COUNT,
    ENET_PROTOCOL_COMMAND_MASK = $0F
  );

  // Structures de base
  PENetAddress = ^ENetAddress;
  ENetAddress = record
    host: Cardinal;
    port: Word;
  end;

  PENetBuffer = ^ENetBuffer;
  ENetBuffer = record
    data: Pointer;
    dataLength: NativeUInt;
  end;

  PENetPacket = ^ENetPacket;
  ENetPacket = record
    referenceCount: NativeUInt;
    flags: Cardinal;
    data: PByte;
    dataLength: NativeUInt;
    freeCallback: Pointer;
  end;

  PENetChannel = ^ENetChannel;
  ENetChannel = record
    outgoingReliableSequenceNumber: Word;
    outgoingUnreliableSequenceNumber: Word;
    usedReliableWindows: Cardinal;
    reliableWindows: array[0..ENET_PEER_RELIABLE_WINDOWS-1] of Word;
    incomingReliableSequenceNumber: Word;
    incomingUnreliableSequenceNumber: Word;
    incomingReliableCommands: Pointer; // Liste des commandes
    incomingUnreliableCommands: Pointer; // Liste des commandes
  end;

  PENetPeer = ^ENetPeer;
  ENetPeer = record
    dispatchList: record
      next, previous: PENetPeer;
    end;
    host: Pointer; // PENetHost
    outgoingPeerID: Word;
    incomingPeerID: Word;
    connectID: Cardinal;
    outgoingSessionID: Byte;
    incomingSessionID: Byte;
    address: ENetAddress;
    data: Pointer;
    state: ENetPeerState;
    channels: PENetChannel;
    channelCount: NativeUInt;
    incomingBandwidth: Cardinal;
    outgoingBandwidth: Cardinal;
    incomingBandwidthThrottleEpoch: Cardinal;
    outgoingBandwidthThrottleEpoch: Cardinal;
    incomingDataTotal: Cardinal;
    outgoingDataTotal: Cardinal;
    lastSendTime: Cardinal;
    lastReceiveTime: Cardinal;
    nextTimeout: Cardinal;
    earliestTimeout: Cardinal;
    packetLossEpoch: Cardinal;
    packetsSent: Cardinal;
    packetsLost: Cardinal;
    packetLoss: Cardinal;
    packetLossVariance: Cardinal;
    packetThrottle: Cardinal;
    packetThrottleLimit: Cardinal;
    packetThrottleCounter: Cardinal;
    packetThrottleEpoch: Cardinal;
    packetThrottleAcceleration: Cardinal;
    packetThrottleDeceleration: Cardinal;
    packetThrottleInterval: Cardinal;
    lastRoundTripTime: Cardinal;
    lowestRoundTripTime: Cardinal;
    lastRoundTripTimeVariance: Cardinal;
    highestRoundTripTimeVariance: Cardinal;
    roundTripTime: Cardinal;
    roundTripTimeVariance: Cardinal;
    mtu: Cardinal;
    windowSize: Cardinal;
    reliableDataInTransit: Cardinal;
    outgoingReliableSequenceNumber: Word;
    acknowledgements: Pointer; // Liste des acknowledgements
    sentReliableCommands: Pointer; // Liste des commandes
    sentUnreliableCommands: Pointer; // Liste des commandes
    outgoingReliableCommands: Pointer; // Liste des commandes
    outgoingUnreliableCommands: Pointer; // Liste des commandes
    dispatchedCommands: Pointer; // Liste des commandes
    needsDispatch: Integer;
    incomingUnsequencedGroup: Word;
    outgoingUnsequencedGroup: Word;
    unsequencedWindow: array[0..ENET_PEER_UNSEQUENCED_WINDOW_SIZE div 32 - 1] of Cardinal;
    eventData: Cardinal;
    timeoutLimit : Integer ;
    timeoutMinimum : Integer ;
    timeoutMaximum : Integer ;
  end;

  PENetCompressor = ^ENetCompressor;
  ENetCompressor = record
    context: Pointer;
    compress: function(context: Pointer; const buffers: PENetBuffer; bufferCount: NativeUInt; limit: NativeUInt; outData: PByte; outLimit: NativeUInt): NativeUInt; cdecl;
    decompress: function(context: Pointer; const data: PByte; limit: NativeUInt; outData: PByte; outLimit: NativeUInt): NativeUInt; cdecl;
    destroy: procedure(context: Pointer); cdecl;
  end;

  PENetHost = ^ENetHost;
  ENetHost = record
    socket: TSocket;
    address: ENetAddress;
    incomingBandwidth: Cardinal;
    outgoingBandwidth: Cardinal;
    bandwidthThrottleEpoch: Cardinal;
    mtu: Cardinal;
    randomSeed: Cardinal;
    recalculateBandwidthLimits: Integer;
    peers: PENetPeer;
    peerCount: NativeUInt;
    channelLimit: NativeUInt;
    serviceTime: Cardinal;
    dispatchQueue: record
      first, last: PENetPeer;
    end;
    continueSending: Integer;
    packetSize: NativeUInt;
    headerFlags: Word;
    commands: array[0..ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS-1] of Pointer;
    commandCount: NativeUInt;
    buffers: array[0..ENET_BUFFER_MAXIMUM-1] of ENetBuffer;
    bufferCount: NativeUInt;
    checksum: function(const buffers: PENetBuffer; bufferCount: NativeUInt): Cardinal; cdecl;
    compressor: ENetCompressor;
    packetData: array[0..2, 0..ENET_PROTOCOL_MAXIMUM_MTU-1] of Byte;
    receivedAddress: ENetAddress;
    receivedData: PByte;
    receivedDataLength: NativeUInt;
    totalSentData: Cardinal;
    totalSentPackets: Cardinal;
    totalReceivedData: Cardinal;
    totalReceivedPackets: Cardinal;
  end;

  PENetEvent = ^ENetEvent;
  ENetEvent = record
    eventType: ENetEventType;
    peer: PENetPeer;
    channelID: Byte;
    data: Cardinal;
    packet: PENetPacket;
  end;

  // Callbacks
  ENetPacketFreeCallback = procedure(packet: PENetPacket); cdecl;
  ENetChecksumCallback = function(const buffers: PENetBuffer; bufferCount: NativeUInt): Cardinal; cdecl;

  PENetBufferArray = ^TENetBufferArray;
  TENetBufferArray = array[0..MaxInt div SizeOf(ENetBuffer) - 1] of ENetBuffer;

  PENetPeerArray = ^TENetPeerArray;
  TENetPeerArray = array[0..MaxInt div SizeOf(ENetPeer) - 1] of ENetPeer;

// Déclarations forward pour les fonctions de protocole
function enet_protocol_receive_incoming_commands(host: PENetHost; event: PENetEvent): Integer; forward;
function enet_protocol_send_outgoing_commands(host: PENetHost; event: PENetEvent; checkForTimeouts: Integer): Integer; forward;

// Fonctions principales de l'API ENet
function enet_initialize: Integer;
procedure enet_deinitialize;
function enet_time_get: Cardinal;
procedure enet_time_set(newTimeBase: Cardinal);

function enet_address_set_host(address: PENetAddress; const hostName: PAnsiChar): Integer;
function enet_address_get_host_ip(const address: PENetAddress; hostName: PAnsiChar; nameLength: NativeUInt): Integer;
function enet_address_get_host(const address: PENetAddress; hostName: PAnsiChar; nameLength: NativeUInt): Integer;

function enet_packet_create(const data: Pointer; dataLength: NativeUInt; flags: Cardinal): PENetPacket;
procedure enet_packet_destroy(packet: PENetPacket);
function enet_packet_resize(packet: PENetPacket; dataLength: NativeUInt): Integer;
function enet_crc32(const buffers: PENetBuffer; bufferCount: NativeUInt): Cardinal;

function enet_host_create(const address: PENetAddress; peerCount: NativeUInt; channelLimit: NativeUInt; incomingBandwidth: Cardinal; outgoingBandwidth: Cardinal): PENetHost;
procedure enet_host_destroy(host: PENetHost);
function enet_host_connect(host: PENetHost; const address: PENetAddress; channelCount: NativeUInt; data: Cardinal): PENetPeer;
function enet_host_check_events(host: PENetHost; event: PENetEvent): Integer;
function enet_host_service(host: PENetHost; event: PENetEvent; timeout: Cardinal): Integer;
procedure enet_host_flush(host: PENetHost);
procedure enet_host_broadcast(host: PENetHost; channelID: Byte; packet: PENetPacket);
procedure enet_host_compress(host: PENetHost; const compressor: PENetCompressor);
function enet_host_compress_with_range_coder(host: PENetHost): Integer;
procedure enet_host_channel_limit(host: PENetHost; channelLimit: NativeUInt);
procedure enet_host_bandwidth_limit(host: PENetHost; incomingBandwidth: Cardinal; outgoingBandwidth: Cardinal);

function enet_peer_send(peer: PENetPeer; channelID: Byte; packet: PENetPacket): Integer;
function enet_peer_receive(peer: PENetPeer; channelID: PByte): PENetPacket;
procedure enet_peer_ping(peer: PENetPeer);
procedure enet_peer_timeout(peer: PENetPeer; timeoutLimit: Cardinal; timeoutMinimum: Cardinal; timeoutMaximum: Cardinal);
procedure enet_peer_reset(peer: PENetPeer);
procedure enet_peer_disconnect(peer: PENetPeer; data: Cardinal);
procedure enet_peer_disconnect_now(peer: PENetPeer; data: Cardinal);
procedure enet_peer_disconnect_later(peer: PENetPeer; data: Cardinal);
procedure enet_peer_throttle_configure(peer: PENetPeer; interval: Cardinal; acceleration: Cardinal; deceleration: Cardinal);

function enet_range_coder_create: Pointer;
procedure enet_range_coder_destroy(context: Pointer);
function enet_range_coder_compress(context: Pointer; const buffers: PENetBuffer; bufferCount: NativeUInt; limit: NativeUInt; outData: PByte; outLimit: NativeUInt): NativeUInt;
function enet_range_coder_decompress(context: Pointer; const data: PByte; limit: NativeUInt; outData: PByte; outLimit: NativeUInt): NativeUInt;

function enet_protocol_command_size(commandNumber: Byte): NativeUInt;

implementation

var
  timeBase: Cardinal = 0;
  wsaData: TWSAData;

// Initialisation/Déinitialisation
function enet_initialize: Integer;
begin
  Result := WSAStartup(MAKEWORD(2, 2), wsaData);
  if Result = 0 then
    timeBase := 0;
end;

procedure enet_deinitialize;
begin
  WSACleanup;
end;

// Gestion du temps
function enet_time_get: Cardinal;
begin
  Result := GetTickCount - timeBase;
end;

procedure enet_time_set(newTimeBase: Cardinal);
begin
  timeBase := newTimeBase;
end;

// Gestion des adresses
function enet_address_set_host(address: PENetAddress; const hostName: PAnsiChar): Integer;
var
  hostEntry: PHostEnt;
  addr: u_long;
begin
  addr := inet_addr(hostName);
  if addr <> INADDR_NONE then
  begin
    address^.host := addr;
    Result := 0;
  end
  else
  begin
    hostEntry := gethostbyname(hostName);
    if hostEntry = nil then
    begin
      Result := -1;
      Exit;
    end;

    address^.host := PCardinal(hostEntry^.h_addr_list^)^;
    Result := 0;
  end;
end;

function enet_address_get_host_ip(const address: PENetAddress; hostName: PAnsiChar; nameLength: NativeUInt): Integer;
var
  addr: in_addr;
  name: PAnsiChar;
begin
  addr.s_addr := address^.host;
  name := inet_ntoa(addr);
  if name = nil then
  begin
    Result := -1;
    Exit;
  end;

  StrLCopy(hostName, name, nameLength - 1);
  Result := 0;
end;

function enet_address_get_host(const address: PENetAddress; hostName: PAnsiChar; nameLength: NativeUInt): Integer;
var
  hostEntry: PHostEnt;
  addr: in_addr;
begin
  addr.s_addr := address^.host;
  hostEntry := gethostbyaddr(@addr, sizeof(addr), AF_INET);
  if hostEntry = nil then
  begin
    Result := enet_address_get_host_ip(address, hostName, nameLength);
    Exit;
  end;

  StrLCopy(hostName, hostEntry^.h_name, nameLength - 1);
  Result := 0;
end;

// Gestion des packets
function enet_packet_create(const data: Pointer; dataLength: NativeUInt; flags: Cardinal): PENetPacket;
begin
  New(Result);

  Result^.referenceCount := 1;
  Result^.flags := flags;
  Result^.dataLength := dataLength;
  Result^.freeCallback := nil;

  if (flags and Cardinal(ENET_PACKET_FLAG_NO_ALLOCATE)) <> 0 then
    Result^.data := PByte(data)
  else
  begin
    GetMem(Result^.data, dataLength);
    if data <> nil then
      Move(data^, Result^.data^, dataLength);
  end;
end;

procedure enet_packet_destroy(packet: PENetPacket);
begin
  if packet = nil then Exit;

  if packet^.freeCallback <> nil then
    ENetPacketFreeCallback(packet^.freeCallback)(packet);

  if (packet^.flags and Cardinal(ENET_PACKET_FLAG_NO_ALLOCATE)) = 0 then
    FreeMem(packet^.data);

  Dispose(packet);
end;

function enet_packet_resize(packet: PENetPacket; dataLength: NativeUInt): Integer;
begin
  if (packet^.flags and Cardinal(ENET_PACKET_FLAG_NO_ALLOCATE)) <> 0 then
  begin
    Result := -1;
    Exit;
  end;

  ReallocMem(packet^.data, dataLength);
  packet^.dataLength := dataLength;
  Result := 0;
end;

// Table CRC32
const
  crcTable: array[0..255] of Cardinal = (
    $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
    $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
    $1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
    $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
    $3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
    $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
    $26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
    $2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
    $76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
    $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
    $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
    $65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
    $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
    $4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
    $5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
    $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
    $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
    $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
    $f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
    $fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
    $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
    $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
    $cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
    $c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
    $9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
    $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
    $86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
    $88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
    $a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
    $aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
    $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
    $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
  );

function enet_crc32(const buffers: PENetBuffer; bufferCount: NativeUInt): Cardinal;
var
  crc: Cardinal;
  i, j: NativeUInt;
  data: PByte;
  buffer: PENetBuffer;
begin
  crc := $FFFFFFFF;
  for i := 0 to bufferCount - 1 do
  begin
    // Correction : accéder à l'élément i du tableau pointé par buffers
    buffer := @PENetBufferArray(buffers)^[i];

    data := PByte(buffer^.data);
    for j := 0 to buffer^.dataLength - 1 do
    begin
      crc := crcTable[(crc xor data[j]) and $FF] xor (crc shr 8);
    end;
  end;
  Result := crc xor $FFFFFFFF;
end;

// Gestion des hôtes
function enet_host_create(const address: PENetAddress; peerCount: NativeUInt; channelLimit: NativeUInt; incomingBandwidth: Cardinal; outgoingBandwidth: Cardinal): PENetHost;
var
  host: PENetHost;
  sock: TSocket;
  sockAddr: TSockAddrIn;
  i: NativeUInt;
  flag: Cardinal;
  peer: PENetPeer;
  nonBlocking: u_long;
begin
  Writeln('[ENet] Creating host...');
  Writeln(Format('  PeerCount: %d, ChannelLimit: %d, InBW: %d, OutBW: %d',
          [peerCount, channelLimit, incomingBandwidth, outgoingBandwidth]));

  if address <> nil then
    Writeln(Format('  Binding to: %s:%d', [IntToStr(address^.host), address^.port]))
  else
    Writeln('  Binding to: any address');

  New(host);
  nonBlocking := 1;
  FillChar(host^, SizeOf(ENetHost), 0);
  Writeln('[ENet] Host structure allocated');

  if channelLimit = 0 then
    channelLimit := ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT
  else if channelLimit > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT then
    channelLimit := ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT;

  host^.randomSeed := Cardinal(enet_time_get);
  host^.randomSeed := (host^.randomSeed shl 16) or (host^.randomSeed shr 16);
  host^.channelLimit := channelLimit;
  host^.incomingBandwidth := incomingBandwidth;
  host^.outgoingBandwidth := outgoingBandwidth;
  host^.bandwidthThrottleEpoch := 0;
  host^.recalculateBandwidthLimits := 0;
  host^.mtu := ENET_HOST_DEFAULT_MTU;
  host^.peerCount := peerCount;
  host^.commandCount := 0;
  host^.bufferCount := 0;
  host^.checksum := @enet_crc32;
  host^.receivedAddress.host := ENET_HOST_ANY;
  host^.receivedAddress.port := 0;

  Writeln('[ENet] Host parameters configured:');
  Writeln(Format('  ChannelLimit: %d, MTU: %d, PeerCount: %d',
          [host^.channelLimit, host^.mtu, host^.peerCount]));

  GetMem(host^.peers, peerCount * SizeOf(ENetPeer));
  FillChar(host^.peers^, peerCount * SizeOf(ENetPeer), 0);
  Writeln(Format('[ENet] Allocated memory for %d peers (%d bytes)',
          [peerCount, peerCount * SizeOf(ENetPeer)]));

  for i := 0 to peerCount - 1 do
  begin
    peer := @PENetPeerArray(host^.peers)^[i];
    peer^.host := host;
    peer^.incomingPeerID := i;
    peer^.outgoingSessionID := $FF;
    peer^.incomingSessionID := $FF;
    peer^.data := nil;
    peer^.state := ENET_PEER_STATE_DISCONNECTED;
    peer^.channelCount := 0;
    peer^.channels := nil;
  end;
  Writeln('[ENet] Peer structures initialized');

  sock := socket(AF_INET, SOCK_DGRAM, 0);
  if sock = -1 then
  begin
    Writeln('[ENet] ERROR: Failed to create socket (Error: ', WSAGetLastError, ')');
    enet_host_destroy(host);
    Result := nil;
    Exit;
  end;
  Writeln('[ENet] Socket created successfully (Handle: ', sock, ')');

  // Configuration du socket
  if address <> nil then
  begin
    FillChar(sockAddr, SizeOf(sockAddr), 0);
    sockAddr.sin_family := AF_INET;
    sockAddr.sin_port := htons(address^.port);
    sockAddr.sin_addr.s_addr := address^.host;

    Writeln('[ENet] Attempting to bind socket...');
    if bind(sock, TSockAddr(sockAddr), SizeOf(sockAddr)) = SOCKET_ERROR then
    begin
      Writeln('[ENet] ERROR: Bind failed (Error: ', WSAGetLastError, ')');
      closesocket(sock);
      enet_host_destroy(host);
      Result := nil;
      Exit;
    end;
    host^.address := address^;
    Writeln('[ENet] Socket bound successfully');
  end
  else
  begin
    Writeln('[ENet] No specific address provided, using wildcard bind');
  end;

  // Rendre le socket non-bloquant
  Writeln('[ENet] Setting socket to non-blocking mode...');
  if ioctlsocket(sock, FIONBIO, nonBlocking) = -1 then
  begin
    Writeln('[ENet] ERROR: Failed to set non-blocking mode (Error: ', WSAGetLastError, ')');
    closesocket(sock);
    enet_host_destroy(host);
    Result := nil;
    Exit;
  end;
  Writeln('[ENet] Socket set to non-blocking mode');

  host^.socket := sock;
  host^.serviceTime := enet_time_get;

  Writeln('[ENet] Host created successfully');
  Writeln(Format('  ServiceTime: %d, Socket: %d', [host^.serviceTime, host^.socket]));

  Result := host;
end;

procedure enet_host_destroy(host: PENetHost);
var
  i: NativeUInt;
begin
  if host = nil then Exit;

  if host^.socket <> -1 then
    closesocket(host^.socket);

  for i := 0 to host^.peerCount - 1 do
  begin
    enet_peer_reset(@PENetPeerArray(host^.peers)^[i]);
  end;

  if host^.peers <> nil then
    FreeMem(host^.peers);

  if host^.compressor.context <> nil then
    host^.compressor.destroy(host^.compressor.context);

  Dispose(host);
end;

function enet_host_connect(host: PENetHost; const address: PENetAddress; channelCount: NativeUInt; data: Cardinal): PENetPeer;
var
  peer: PENetPeer;
  i: NativeUInt;
  channel: PENetChannel;
begin
  if channelCount < ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT then
    channelCount := ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT
  else if channelCount > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT then
    channelCount := ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT;

  // Chercher un peer disponible
  peer := nil;
  for i := 0 to host^.peerCount - 1 do
  begin
    if PENetPeerArray(host^.peers)^[i].state = ENET_PEER_STATE_DISCONNECTED then
    begin
      peer := @PENetPeerArray(host^.peers)^[i];
      Break;
    end;
  end;

  if peer = nil then
  begin
    Result := nil;
    Exit;
  end;

  GetMem(peer^.channels, channelCount * SizeOf(ENetChannel));
  FillChar(peer^.channels^, channelCount * SizeOf(ENetChannel), 0);

  peer^.channelCount := channelCount;
  peer^.state := ENET_PEER_STATE_CONNECTING;
  peer^.address := address^;
  peer^.connectID := Random($FFFFFFFF);
  peer^.mtu := host^.mtu;
  peer^.packetThrottleInterval := ENET_PEER_PACKET_THROTTLE_INTERVAL;
  peer^.packetThrottleAcceleration := ENET_PEER_PACKET_THROTTLE_ACCELERATION;
  peer^.packetThrottleDeceleration := ENET_PEER_PACKET_THROTTLE_DECELERATION;
  peer^.outgoingPeerID := ENET_PROTOCOL_MAXIMUM_PEER_ID;
  peer^.eventData := data;

  if host^.outgoingBandwidth = 0 then
    peer^.windowSize := ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE
  else
    peer^.windowSize := (host^.outgoingBandwidth div ENET_PEER_WINDOW_SIZE_SCALE) * ENET_PROTOCOL_MINIMUM_WINDOW_SIZE;

  if peer^.windowSize < ENET_PROTOCOL_MINIMUM_WINDOW_SIZE then
    peer^.windowSize := ENET_PROTOCOL_MINIMUM_WINDOW_SIZE
  else if peer^.windowSize > ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE then
    peer^.windowSize := ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE;

  for i := 0 to channelCount - 1 do
  begin
    channel := PENetChannel(peer^.channels);
    Inc(channel, i);

    channel^.outgoingReliableSequenceNumber := 0;
    channel^.outgoingUnreliableSequenceNumber := 0;
    channel^.incomingReliableSequenceNumber := 0;
    channel^.incomingUnreliableSequenceNumber := 0;
    channel^.incomingReliableCommands := nil;
    channel^.incomingUnreliableCommands := nil;
    channel^.usedReliableWindows := 0;
    FillChar(channel^.reliableWindows, SizeOf(channel^.reliableWindows), 0);
  end;

  Result := peer;
end;

function enet_host_service(host: PENetHost; event: PENetEvent; timeout: Cardinal): Integer;
var
  waitCondition: Cardinal;
  currentTime: Cardinal;
  timeoutEnd: Cardinal;
  selectResult: Integer;
  readSet: TFDSet;
  timeVal: TTimeVal;
begin
  if event <> nil then
  begin
    event^.eventType := ENET_EVENT_TYPE_NONE;
    event^.peer := nil;
    event^.packet := nil;

    if enet_host_check_events(host, event) > 0 then
    begin
      Result := 1;
      Exit;
    end;
  end;

  currentTime := enet_time_get;
  timeoutEnd := currentTime + timeout;

  repeat
    if currentTime >= timeoutEnd then
      Break;

    FD_ZERO(readSet);
    FD_SET(host^.socket, readSet);

    timeVal.tv_sec := (timeoutEnd - currentTime) div 1000;
    timeVal.tv_usec := ((timeoutEnd - currentTime) mod 1000) * 1000;

    selectResult := select(host^.socket + 1, @readSet, nil, nil, @timeVal);

    if selectResult < 0 then
    begin
      Result := -1;
      Exit;
    end;

    if selectResult > 0 then
    begin
      if FD_ISSET(host^.socket, readSet) then
      begin
        if enet_protocol_receive_incoming_commands(host, event) > 0 then
        begin
          Result := 1;
          Exit;
        end;
      end;
    end;

    currentTime := enet_time_get;

    if enet_protocol_send_outgoing_commands(host, event, 1) > 0 then
    begin
      Result := 1;
      Exit;
    end;

    if enet_host_check_events(host, event) > 0 then
    begin
      Result := 1;
      Exit;
    end;

  until False;

  Result := 0;
end;

function enet_host_check_events(host: PENetHost; event: PENetEvent): Integer;
var
  peer: PENetPeer;
begin
  if event = nil then
  begin
    Result := -1;
    Exit;
  end;

  event^.eventType := ENET_EVENT_TYPE_NONE;
  event^.peer := nil;
  event^.packet := nil;

  peer := host^.dispatchQueue.first;
  if peer = nil then
  begin
    Result := 0;
    Exit;
  end;

  // Retirer le peer de la queue de dispatch
  host^.dispatchQueue.first := peer^.dispatchList.next;
  if host^.dispatchQueue.first <> nil then
    host^.dispatchQueue.first^.dispatchList.previous := nil
  else
    host^.dispatchQueue.last := nil;

  peer^.dispatchList.next := nil;
  peer^.dispatchList.previous := nil;
  peer^.needsDispatch := 0;

  case peer^.state of
    ENET_PEER_STATE_CONNECTION_SUCCEEDED:
    begin
      peer^.state := ENET_PEER_STATE_CONNECTED;
      event^.eventType := ENET_EVENT_TYPE_CONNECT;
      event^.peer := peer;
      event^.data := peer^.eventData;
      Result := 1;
    end;

    ENET_PEER_STATE_ZOMBIE:
    begin
      host^.recalculateBandwidthLimits := 1;
      event^.eventType := ENET_EVENT_TYPE_DISCONNECT;
      event^.peer := peer;
      event^.data := peer^.eventData;
      enet_peer_reset(peer);
      Result := 1;
    end;

    ENET_PEER_STATE_CONNECTED:
    begin
      if peer^.dispatchedCommands <> nil then
      begin
        // Traiter les commandes reçues
        // Implémentation simplifiée
        event^.eventType := ENET_EVENT_TYPE_RECEIVE;
        event^.peer := peer;
        event^.channelID := 0;
        event^.packet := nil; // Devrait être le packet reçu
        Result := 1;
      end
      else
        Result := 0;
    end;

    else
      Result := 0;
  end;
end;

procedure enet_host_flush(host: PENetHost);
begin
  host^.serviceTime := enet_time_get;
  enet_protocol_send_outgoing_commands(host, nil, 0);
end;

procedure enet_host_broadcast(host: PENetHost; channelID: Byte; packet: PENetPacket);
var
  i: NativeUInt;
begin
  for i := 0 to host^.peerCount - 1 do
  begin
   if (PENetPeerArray(host^.peers)^[i]).state = ENET_PEER_STATE_CONNECTED then
    begin
      enet_peer_send(PENetPeer(NativeInt(host^.peers) + i * SizeOf(ENetPeer)), channelID, packet);
    end;
  end;

  if packet^.referenceCount = 0 then
    enet_packet_destroy(packet);
end;

procedure enet_host_compress(host: PENetHost; const compressor: PENetCompressor);
begin
  if host^.compressor.context <> nil then
    host^.compressor.destroy(host^.compressor.context);

  if compressor <> nil then
    host^.compressor := compressor^
  else
    FillChar(host^.compressor, SizeOf(ENetCompressor), 0);
end;

function enet_host_compress_with_range_coder(host: PENetHost): Integer;
var
  compressor: ENetCompressor;
begin
  compressor.context := enet_range_coder_create;
  if compressor.context = nil then
  begin
    Result := -1;
    Exit;
  end;

  compressor.compress := @enet_range_coder_compress;
  compressor.decompress := @enet_range_coder_decompress;
  compressor.destroy := @enet_range_coder_destroy;

  enet_host_compress(host, @compressor);
  Result := 0;
end;

procedure enet_host_channel_limit(host: PENetHost; channelLimit: NativeUInt);
begin
  if channelLimit = 0 then
    channelLimit := ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT
  else if channelLimit > ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT then
    channelLimit := ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT;

  host^.channelLimit := channelLimit;
end;

procedure enet_host_bandwidth_limit(host: PENetHost; incomingBandwidth: Cardinal; outgoingBandwidth: Cardinal);
begin
  host^.incomingBandwidth := incomingBandwidth;
  host^.outgoingBandwidth := outgoingBandwidth;
  host^.recalculateBandwidthLimits := 1;
end;

// Gestion des peers
function enet_peer_send(peer: PENetPeer; channelID: Byte; packet: PENetPacket): Integer;
var
  channel: PENetChannel;
  command: Pointer; // Devrait être PENetProtocol
begin
  if peer^.state <> ENET_PEER_STATE_CONNECTED then
  begin
    Result := -1;
    Exit;
  end;

  if channelID >= peer^.channelCount then
  begin
    Result := -1;
    Exit;
  end;

  channel := PENetChannel(NativeInt(peer^.channels) + channelID * SizeOf(ENetChannel));

  // Incrémenter le compteur de références
  Inc(packet^.referenceCount);

  // Ajouter le packet à la queue d'envoi
  if (packet^.flags and Cardinal(ENET_PACKET_FLAG_RELIABLE)) <> 0 then
  begin
    // Packet fiable
    // Implémentation simplifiée - devrait ajouter à outgoingReliableCommands
    Result := 0;
  end
  else
  begin
    // Packet non fiable
    // Implémentation simplifiée - devrait ajouter à outgoingUnreliableCommands
    Result := 0;
  end;
end;

function enet_peer_receive(peer: PENetPeer; channelID: PByte): PENetPacket;
begin
  // Implémentation simplifiée
  // Devrait récupérer le prochain packet dans la queue de réception
  Result := nil;
end;

procedure enet_peer_ping(peer: PENetPeer);
begin
  if peer^.state <> ENET_PEER_STATE_CONNECTED then
    Exit;

  // Envoyer une commande ping
  // Implémentation simplifiée
end;



procedure enet_peer_timeout(peer: PENetPeer; timeoutLimit: Cardinal; timeoutMinimum: Cardinal; timeoutMaximum: Cardinal);

begin
  peer^.timeoutLimit := timeoutLimit;
  peer^.timeoutMinimum := timeoutMinimum;
  peer^.timeoutMaximum := timeoutMaximum;
end;

procedure enet_peer_reset(peer: PENetPeer);
var
  i: NativeUInt;
begin
  peer^.outgoingPeerID := ENET_PROTOCOL_MAXIMUM_PEER_ID;
  peer^.connectID := 0;
  peer^.state := ENET_PEER_STATE_DISCONNECTED;
  peer^.incomingBandwidth := 0;
  peer^.outgoingBandwidth := 0;

  // Nettoyer les channels
  if peer^.channels <> nil then
  begin
    for i := 0 to peer^.channelCount - 1 do
    begin
      // Nettoyer les commandes en attente
      // Implémentation simplifiée
    end;

    FreeMem(peer^.channels);
    peer^.channels := nil;
  end;

  peer^.channelCount := 0;
  peer^.data := nil;

  // Nettoyer les listes de commandes
  // Implémentation simplifiée
end;

procedure enet_peer_disconnect(peer: PENetPeer; data: Cardinal);
begin
  if peer^.state = ENET_PEER_STATE_DISCONNECTED then
    Exit;

  enet_peer_reset(peer);

  peer^.eventData := data;
  peer^.state := ENET_PEER_STATE_DISCONNECTING;

  // Envoyer une commande de déconnexion
  // Implémentation simplifiée
end;

procedure enet_peer_disconnect_now(peer: PENetPeer; data: Cardinal);
begin
  if peer^.state = ENET_PEER_STATE_DISCONNECTED then
    Exit;

  peer^.eventData := data;
  enet_peer_reset(peer);
end;

procedure enet_peer_disconnect_later(peer: PENetPeer; data: Cardinal);
begin
  if peer^.state = ENET_PEER_STATE_DISCONNECTED then
    Exit;

  peer^.eventData := data;
  peer^.state := ENET_PEER_STATE_DISCONNECT_LATER;
end;

procedure enet_peer_throttle_configure(peer: PENetPeer; interval: Cardinal; acceleration: Cardinal; deceleration: Cardinal);
begin
  peer^.packetThrottleInterval := interval;
  peer^.packetThrottleAcceleration := acceleration;
  peer^.packetThrottleDeceleration := deceleration;
end;

// Compression Range Coder (implémentation simplifiée)
function enet_range_coder_create: Pointer;
begin
  GetMem(Result, 1024); // Contexte simplifié
  FillChar(Result^, 1024, 0);
end;

procedure enet_range_coder_destroy(context: Pointer);
begin
  FreeMem(context);
end;

function enet_range_coder_compress(context: Pointer; const buffers: PENetBuffer; bufferCount: NativeUInt; limit: NativeUInt; outData: PByte; outLimit: NativeUInt): NativeUInt;
begin
  // Implémentation simplifiée - pas de compression réelle
  Result := 0;
end;

function enet_range_coder_decompress(context: Pointer; const data: PByte; limit: NativeUInt; outData: PByte; outLimit: NativeUInt): NativeUInt;
begin
  // Implémentation simplifiée - pas de décompression réelle
  Result := 0;
end;

// Fonctions de protocole (implémentation simplifiée)
function enet_protocol_receive_incoming_commands(host: PENetHost; event: PENetEvent): Integer;
var
  receivedLength: Integer;
  buffer: array[0..4095] of Byte;
  fromAddr: TSockAddr;
  fromAddrIn: TSockAddrIn absolute fromAddr;
  fromLen: Integer;
  hostStr: string;
begin
  fromLen := SizeOf(fromAddr);
  Writeln('[ENet] Waiting to receive data...');

  receivedLength := recvfrom(
    host^.socket,
    buffer,
    SizeOf(buffer),
    0,
    fromAddr,
    fromLen
  );

  if receivedLength <= 0 then
  begin
    Writeln('[ENet] ERROR: Receive failed or no data (Error: ', WSAGetLastError, ')');
    Result := 0;
    Exit;
  end;

  host^.receivedAddress.host := fromAddrIn.sin_addr.s_addr;
  host^.receivedAddress.port := ntohs(fromAddrIn.sin_port);

  // Convertir l'adresse IP en string
  hostStr := Format('%d.%d.%d.%d', [
    (host^.receivedAddress.host shr 24) and $FF,
    (host^.receivedAddress.host shr 16) and $FF,
    (host^.receivedAddress.host shr 8) and $FF,
    host^.receivedAddress.host and $FF
  ]);

  Writeln(Format('[ENet] Received %d bytes from %s:%d',
          [receivedLength, hostStr, host^.receivedAddress.port]));

  host^.receivedData := @buffer;
  host^.receivedDataLength := receivedLength;

  Writeln('[ENet] Processing incoming commands...');
  // Traiter les commandes reçues
  // Implémentation simplifiée

  Result := 0;
end;

function enet_protocol_send_outgoing_commands(host: PENetHost; event: PENetEvent; checkForTimeouts: Integer): Integer;
begin
  // Implémentation simplifiée
  // Devrait envoyer tous les packets en attente
  Result := 0;
end;

function enet_protocol_command_size(commandNumber: Byte): NativeUInt;
begin
  // Tailles des commandes du protocole
  case commandNumber of
    0: Result := 0; // ENET_PROTOCOL_COMMAND_NONE
    1: Result := 8; // ENET_PROTOCOL_COMMAND_ACKNOWLEDGE
    2: Result := 48; // ENET_PROTOCOL_COMMAND_CONNECT
    3: Result := 44; // ENET_PROTOCOL_COMMAND_VERIFY_CONNECT
    4: Result := 8; // ENET_PROTOCOL_COMMAND_DISCONNECT
    5: Result := 4; // ENET_PROTOCOL_COMMAND_PING
    6: Result := 6; // ENET_PROTOCOL_COMMAND_SEND_RELIABLE
    7: Result := 6; // ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE
    8: Result := 24; // ENET_PROTOCOL_COMMAND_SEND_FRAGMENT
    9: Result := 6; // ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED
    10: Result := 8; // ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT
    11: Result := 12; // ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE
    12: Result := 24; // ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT
    else Result := 0;
  end;
end;

end.
