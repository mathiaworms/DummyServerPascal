unit TeamRosterUpdate;

interface

uses
  LoadScreenPacket,
  LoadScreenPacketID,
  ByteReader,
  ByteWriter,
  SysUtils;

const
  MAX_TEAM_PLAYERS = 24;

type
  TTeamRosterUpdate = class(TLoadScreenPacket)
  public
    FOrderPlayerIDs: array[0..MAX_TEAM_PLAYERS - 1] of UInt64;
    FChaosPlayerIDs: array[0..MAX_TEAM_PLAYERS - 1] of UInt64;
    FTeamSizeOrder: Cardinal;
    FTeamSizeChaos: Cardinal;
    FCurrentTeamSizeOrder: Cardinal;
    FCurrentTeamSizeChaos: Cardinal;

    function GetOrderPlayerID(Index: Integer): UInt64;
    procedure SetOrderPlayerID(Index: Integer; const Value: UInt64);

    function GetChaosPlayerID(Index: Integer): UInt64;
    procedure SetChaosPlayerID(Index: Integer; const Value: UInt64);

  public
    function GetID: TLoadScreenPacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property TeamSizeOrder: Cardinal read FTeamSizeOrder write FTeamSizeOrder;
    property TeamSizeChaos: Cardinal read FTeamSizeChaos write FTeamSizeChaos;

    property OrderPlayerID[Index: Integer]: UInt64 read GetOrderPlayerID write SetOrderPlayerID;
    property ChaosPlayerID[Index: Integer]: UInt64 read GetChaosPlayerID write SetChaosPlayerID;

    property CurrentTeamSizeOrder: Cardinal read FCurrentTeamSizeOrder write FCurrentTeamSizeOrder;
    property CurrentTeamSizeChaos: Cardinal read FCurrentTeamSizeChaos write FCurrentTeamSizeChaos;
  end;

implementation

{ TTeamRosterUpdate }

function TTeamRosterUpdate.GetID: TLoadScreenPacketID;
begin
  Result := LoadScreenPacketID.TeamRosterUpdate;
end;

procedure TTeamRosterUpdate.ReadBody(reader: TByteReader);
var
  i: Integer;
begin
  reader.ReadPad(3);

  FTeamSizeOrder := reader.ReadUInt32;
  FTeamSizeChaos := reader.ReadUInt32;
  reader.ReadPad(4);

  for i := 0 to MAX_TEAM_PLAYERS - 1 do
    FOrderPlayerIDs[i] := reader.ReadUInt64;

  for i := 0 to MAX_TEAM_PLAYERS - 1 do
    FChaosPlayerIDs[i] := reader.ReadUInt64;

  FCurrentTeamSizeOrder := reader.ReadUInt32;
  FCurrentTeamSizeChaos := reader.ReadUInt32;
end;

procedure TTeamRosterUpdate.WriteBody(writer: TByteWriter);
var
  i: Integer;
begin
  writer.WritePad(3);

  writer.WriteUInt32(FTeamSizeOrder);
  writer.WriteUInt32(FTeamSizeChaos);
  writer.WritePad(4);

  for i := 0 to MAX_TEAM_PLAYERS - 1 do
    writer.WriteUInt64(FOrderPlayerIDs[i]);

  for i := 0 to MAX_TEAM_PLAYERS - 1 do
    writer.WriteUInt64(FChaosPlayerIDs[i]);

  writer.WriteUInt32(FCurrentTeamSizeOrder);
  writer.WriteUInt32(FCurrentTeamSizeChaos);
end;

function TTeamRosterUpdate.GetOrderPlayerID(Index: Integer): UInt64;
begin
  if (Index < 0) or (Index >= MAX_TEAM_PLAYERS) then
    raise Exception.CreateFmt('OrderPlayerID index out of bounds: %d', [Index]);
  Result := FOrderPlayerIDs[Index];
end;

procedure TTeamRosterUpdate.SetOrderPlayerID(Index: Integer; const Value: UInt64);
begin
  if (Index < 0) or (Index >= MAX_TEAM_PLAYERS) then
    raise Exception.CreateFmt('OrderPlayerID index out of bounds: %d', [Index]);
  FOrderPlayerIDs[Index] := Value;
end;

function TTeamRosterUpdate.GetChaosPlayerID(Index: Integer): UInt64;
begin
  if (Index < 0) or (Index >= MAX_TEAM_PLAYERS) then
    raise Exception.CreateFmt('ChaosPlayerID index out of bounds: %d', [Index]);
  Result := FChaosPlayerIDs[Index];
end;

procedure TTeamRosterUpdate.SetChaosPlayerID(Index: Integer; const Value: UInt64);
begin
  if (Index < 0) or (Index >= MAX_TEAM_PLAYERS) then
    raise Exception.CreateFmt('ChaosPlayerID index out of bounds: %d', [Index]);
  FChaosPlayerIDs[Index] := Value;
end;

end.

