program DummyServerPascalProj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ENet in 'P-Enet\ENet.pas',
  ENet_Callbacks in 'P-Enet\ENet_Callbacks.pas',
  ENet_List in 'P-Enet\ENet_List.pas',
  ENet_Protocol in 'P-Enet\ENet_Protocol.pas',
  ENet_Time in 'P-Enet\ENet_Time.pas',
  ENet_Types in 'P-Enet\ENet_Types.pas',
  ENet_Win32 in 'P-Enet\ENet_Win32.pas',
  Blowfish in 'Ressources\Blowfish.pas',
  Commands in 'Ressources\Commands.pas',
  Main in 'Main.pas',
  DummyServerPascal in 'Ressources\DummyServerPascal.pas',
  ChannelID in 'Ressources\LeaguePKT\ChannelID.pas',
  BasePacket in 'Ressources\LeaguePKT\BasePacket.pas',
  ByteReader in 'Ressources\LeaguePKT\ByteReader.pas',
  ByteWriter in 'Ressources\LeaguePKT\ByteWriter.pas',
  GamePacket in 'Ressources\LeaguePKT\GamePacket.pas',
  GamePacketID in 'Ressources\LeaguePKT\GamePacketID.pas',
  IUnusedPacket in 'Ressources\LeaguePKT\IUnusedPacket.pas',
  BatchGamePacket in 'Ressources\LeaguePKT\BatchGamePacket.pas',
  KeyCheckPacket in 'Ressources\LeaguePKT\KeyCheckPacket.pas',
  LoadScreenPacket in 'Ressources\LeaguePKT\LoadScreenPacket.pas',
  LoadScreenPacketID in 'Ressources\LeaguePKT\LoadScreenPacketID.pas',
  UnknownPacket in 'Ressources\LeaguePKT\UnknownPacket.pas',
  RequestJoinTeam in 'Ressources\LeaguePKT\LoadScreen\RequestJoinTeam.pas',
  RequestReskin in 'Ressources\LeaguePKT\LoadScreen\RequestReskin.pas',
  RequestRename in 'Ressources\LeaguePKT\LoadScreen\RequestRename.pas',
  TeamRosterUpdate in 'Ressources\LeaguePKT\LoadScreen\TeamRosterUpdate.pas',
  C2S_ClientReady in 'Ressources\LeaguePKT\Game\C2S_ClientReady.pas',
  C2S_CharSelected in 'Ressources\LeaguePKT\Game\C2S_CharSelected.pas',
  C2S_NPC_IssueOrderReq in 'Ressources\LeaguePKT\Game\C2S_NPC_IssueOrderReq.pas',
  C2S_Ping_Load_Info in 'Ressources\LeaguePKT\Game\C2S_Ping_Load_Info.pas',
  C2S_SynchVersion in 'Ressources\LeaguePKT\Game\C2S_SynchVersion.pas',
  S2C_QueryStatusAns in 'Ressources\LeaguePKT\Game\S2C_QueryStatusAns.pas',
  C2S_World_LockCamera_Server in 'Ressources\LeaguePKT\Game\C2S_World_LockCamera_Server.pas',
  C2S_World_SendCamera_Server in 'Ressources\LeaguePKT\Game\C2S_World_SendCamera_Server.pas',
  C2S_QueryStatusReq in 'Ressources\LeaguePKT\Game\C2S_QueryStatusReq.pas',
  S2C_CreateHero in 'Ressources\LeaguePKT\Game\S2C_CreateHero.pas',
  S2C_EndSpawn in 'Ressources\LeaguePKT\Game\S2C_EndSpawn.pas',
  S2C_StartSpawn in 'Ressources\LeaguePKT\Game\S2C_StartSpawn.pas',
  S2C_SynchVersion in 'Ressources\LeaguePKT\Game\S2C_SynchVersion.pas',
  S2C_StartGame in 'Ressources\LeaguePKT\Game\S2C_StartGame.pas',
  S2C_Ping_Load_Info in 'Ressources\LeaguePKT\Game\S2C_Ping_Load_Info.pas',
  S2C_OnEnterVisiblityClient in 'Ressources\LeaguePKT\Game\S2C_OnEnterVisiblityClient.pas',
  S2C_WaypointGroup in 'Ressources\LeaguePKT\Game\S2C_WaypointGroup.pas',
  MovementDataUnit in 'Ressources\LeaguePKT\Game\Common\MovementDataUnit.pas',
  CompressedWaypoint in 'Ressources\LeaguePKT\Game\Common\CompressedWaypoint.pas',
  ConnectionInfo in 'Ressources\LeaguePKT\Game\Common\ConnectionInfo.pas',
  PlayerLoadInfo in 'Ressources\LeaguePKT\Game\Common\PlayerLoadInfo.pas',
  ChatPacket in 'Ressources\LeaguePKT\ChatPacket.pas',
  SpeedParams in 'Ressources\LeaguePKT\Game\Common\SpeedParams.pas',
  VectorTypes in 'Ressources\LeaguePKT\Game\Common\VectorTypes.pas';

begin
  try
    RunExampleServer;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
