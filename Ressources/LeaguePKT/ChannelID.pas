unit ChannelID;

interface

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

implementation

end.
