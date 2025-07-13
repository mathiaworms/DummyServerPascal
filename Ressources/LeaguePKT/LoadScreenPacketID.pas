unit LoadScreenPacketID;

interface

type
  TLoadScreenPacketID = (
    RequestJoinTeam = $64,
    RequestReskin = $65,
    RequestRename = $66,
    TeamRosterUpdate = $67
  );

implementation

end.

