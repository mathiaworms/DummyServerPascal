unit ChannelID;

interface

uses
  SysUtils; // Pour Exception

type
  TChannelID = (
    ChannelID_Default             = $0, // Only used once for KeyCheck
    ChannelID_ClientToServer      = $1, // Game PKT
    ChannelID_SynchClock          = $2, // Game PKT
    ChannelID_Broadcast           = $3, // Game PKT
    ChannelID_BroadcastUnreliable = $4, // Game PKT
    ChannelID_Chat                = $5, // Chat packet
    ChannelID_LoadingScreen       = $6  // Payload EGP
  );

function ByteToChannelID(Value: Byte): TChannelID;
function ChannelIDToByte(Value: TChannelID): Byte;

implementation

function ByteToChannelID(Value: Byte): TChannelID;
begin
  case Value of
    0: Result := ChannelID_Default;
    1: Result := ChannelID_ClientToServer;
    2: Result := ChannelID_SynchClock;
    3: Result := ChannelID_Broadcast;
    4: Result := ChannelID_BroadcastUnreliable;
    5: Result := ChannelID_Chat;
    6: Result := ChannelID_LoadingScreen;
  else
    raise Exception.CreateFmt('Invalid ChannelID byte value: %d', [Value]);
  end;
end;

function ChannelIDToByte(Value: TChannelID): Byte;
begin
  case Value of
    ChannelID_Default:            Result := 0;
    ChannelID_ClientToServer:     Result := 1;
    ChannelID_SynchClock:         Result := 2;
    ChannelID_Broadcast:          Result := 3;
    ChannelID_BroadcastUnreliable:Result := 4;
    ChannelID_Chat:               Result := 5;
    ChannelID_LoadingScreen:      Result := 6;
  else
    raise Exception.CreateFmt('Invalid TChannelID enum value: %d', [Ord(Value)]);
  end;
end;

end.
