unit Main;

interface

uses
  System.SysUtils,
  ENet;

procedure StartServer;

implementation

procedure StartServer;

var
  address: ENetAddress;
  key: array[0..15] of Byte; // 16 bytes, comme en C#
  keyString: AnsiString;
begin

  address.host := ENET_HOST_ANY;
  address.port := 5119;


  keyString := 'GLzvuWtyCfHyGhF2';
  Move(PAnsiChar(keyString)^, key[0], Length(key));
end

end.
