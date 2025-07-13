unit Main;

interface

uses
  SysUtils, Classes, Generics.Collections, RegularExpressions, DummyServerPascal, ChannelID,
  PlayerLoadInfo, ChatPacket, BasePacket, C2S_QueryStatusReq, S2C_QueryStatusAns , RequestJoinTeam ,
  TeamRosterUpdate, RequestReskin, RequestRename , ENet , WinSock;

type

  TAddress = record
    Host: string;
    Port: Word;
  end;



procedure RunExampleServer;

implementation



procedure RunExampleServer;
var
  address: ENetAddress;
  key: TBytes;
  cids: TList<UInt32>;
  server: TLeagueServer;
  mapNum: Integer;
  playerLiteInfo: TPlayerLoadInfo;
  skinID: UInt32;
  championName, playerName: string;
  //commandsList: TList<TCommandEntry>;

  procedure CommandExample(Server: TLeagueServer; ClientID: UInt32; const Param: string);
  begin
    Writeln('Executing command with param: "', Param, '" for client: ', ClientID);
    // Exemple de commande
    Server.SendEncrypted(ClientID, ChannelIDToByte(ChannelID.ChannelID_Chat), TChatPacket.Create); // à compléter
  end;

  procedure HandlePacket(Server: TLeagueServer; Packet: TBasePacket; ClientID: UInt32; Channel: TChannelID);
  var
    i: Integer;
    ChatPkt: TChatPacket;
    match: TMatch;
    //entry: TCommandEntry;
    response: TChatPacket;
  begin
    Writeln('Received packet from client ', ClientID, ' on channel ');
    Writeln('Packet type: ', Packet.ClassName);

    if Packet is TC2S_QueryStatusReq then
    begin
      Writeln('Processing QueryStatusReq...');
      var ans := TS2C_QueryStatusAns.Create;
      try
        ans.IsOK := True;
        Writeln('Sending QueryStatusAns: IsOK=True');
        Server.SendEncrypted(ClientID, ChannelIDToByte(ChannelID.ChannelID_Broadcast), ans);
      finally
        ans.Free;
      end;
    end
    else if Packet is TRequestJoinTeam then
    begin
      Writeln('Processing RequestJoinTeam...');

      // Envoi TeamRosterUpdate
      var ans2 := TTeamRosterUpdate.Create;
      try
        ans2.TeamSizeOrder := 1;
        ans2.FOrderPlayerIDs[0] := ClientID;
        ans2.CurrentTeamSizeOrder := 1;
        Writeln('Sending TeamRosterUpdate: TeamSizeOrder=1, PlayerID=', ClientID);
        Server.SendEncrypted(ClientID, ChannelIDToByte(ChannelID.ChannelID_LoadingScreen), ans2);
      finally
        ans2.Free;
      end;

      // Envoi RequestReskin
      var ans1 := TRequestReskin.Create;
      try
        ans1.PlayerID := ClientID;
        ans1.SkinID := skinID;
        ans1.Name := championName;
        Writeln('Sending RequestReskin: PlayerID=', ClientID,
                ', SkinID=', skinID,
                ', Name=', championName);
        Server.SendEncrypted(ClientID, ChannelIDToByte(ChannelID.ChannelID_LoadingScreen), ans1);
      finally
        ans1.Free;
      end;

      // Envoi RequestRename
      var ans3 := TRequestRename.Create;
      try
        ans3.PlayerID := ClientID;
        ans3.SkinID := 0;
        ans3.Name := playerName;
        Writeln('Sending RequestRename: PlayerID=', ClientID,
                ', SkinID=0',
                ', Name=', playerName);
        Server.SendEncrypted(ClientID, ChannelIDToByte(ChannelID.ChannelID_LoadingScreen), ans3);
      finally
        ans3.Free;
      end;
    end
    else if Packet is TChatPacket then
    begin
      ChatPkt := TChatPacket(Packet);
      Writeln('Received chat message: "', ChatPkt.Message, '"');

      //for i := 0 to commandsList.Count - 1 do
      //begin
      //  entry := commandsList[i];
      //  match := entry.Regex.Match(ChatPkt.Message);
      //  if match.Success and (match.Groups.Count >= 2) then
      //  begin
      //    Writeln('Command matched: ', entry.Regex.ToString);
      //    entry.Proc(Server, ClientID, match.Groups[1].Value);
      //    Break;
      //  end;
      //end;
    end
    else
    begin
      Writeln('Unhandled packet type: ', Packet.ClassName);
    end;
  end;




begin
  Writeln('Initializing ENet...');
  if enet_initialize <> 0 then
  begin
    Writeln('Failed to initialize ENet!');
    Exit;
  end;
  Writeln('ENet initialized successfully');

  address.Host := INADDR_ANY; // Écoute sur toutes les interfaces
  address.Port := 5119;
  key := TEncoding.ASCII.GetBytes('GLzvuWtyCfHyGhF2');
  Writeln('Server address: ', address.Host, ':', address.Port);
  Writeln('Blowfish key: ', TEncoding.ASCII.GetString(key));

  cids := TList<UInt32>.Create;
  try
    cids.Add(1);
    Writeln('Allowed Client IDs: ', cids[0]);

    Writeln('Creating server instance...');
    server := TLeagueServer.Create(address, key, cids);
    playerLiteInfo := TPlayerLoadInfo.Create;
    try
      mapNum := 1;
      Writeln('Map number: ', mapNum);

      // Configuration du joueur
      playerLiteInfo.PlayerID := 1;
      playerLiteInfo.SummonorLevel := 30;
      playerLiteInfo.TeamId := $64;
      playerLiteInfo.SummonorSpell1 := 0;
      playerLiteInfo.SummonorSpell2 := 0;

      skinID := 0;
      championName := 'Karma';
      playerName := 'Test';
      Writeln('Player settings:');
      Writeln('  Champion: ', championName);
      Writeln('  Player Name: ', playerName);
      Writeln('  Skin ID: ', skinID);

      //commandsList := TList<TCommandEntry>.Create;
      try
        Writeln('Server started. Waiting for connections...');

        while True do
        begin
          //Writeln('...');
          server.RunOnce;
          Sleep(10); // Réduire l'utilisation CPU
        end;
      finally
        //commandsList.Free;
        Writeln('Command list freed');
      end;
    finally
      Writeln('Destroying server instance...');
      server.Free;
      Writeln('Server instance destroyed');
    end;
  finally
    Writeln('Freeing client IDs list...');
    cids.Free;
    Writeln('Client IDs list freed');
  end;

  Writeln('Deinitializing ENet...');
  enet_deinitialize;
  Writeln('ENet deinitialized');
  Writeln('Server shutdown complete');
end;

end.
