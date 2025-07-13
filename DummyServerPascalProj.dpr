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
  BasePacket in 'Ressources\LeaguePKT\BasePacket.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insérer du code ici }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
