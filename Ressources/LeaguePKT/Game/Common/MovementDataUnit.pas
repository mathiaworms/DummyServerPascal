unit MovementDataUnit;

interface

uses
  SysUtils, Classes, Types,   System.Generics.Collections,  // Types pour TVector2
  ByteReader, ByteWriter,
  SpeedParams, CompressedWaypoint, VectorTypes; // à adapter selon tes unités

type
  // Enum similaire à C# MovementDataType
  TMovementDataType = (
    mdtNone = 0,
    mdtWithSpeed = 1,
    mdtNormal = 2,
    mdtStop = 3
  );

  // Classe abstraite
  TMovementData = class
  private
    FSyncID: Integer;
  public
    function GetType: TMovementDataType; virtual; abstract;
    property SyncID: Integer read FSyncID write FSyncID;

    procedure Write(writer: TByteWriter); virtual; abstract;
  end;

  // MovementDataNone
  TMovementDataNone = class(TMovementData)
  public
    function GetType: TMovementDataType; override;
    procedure Write(writer: TByteWriter); override;
    constructor Create; overload;
    constructor Create(reader: TByteReader; syncID: Integer); overload;
  end;

  // MovementDataStop
  TMovementDataStop = class(TMovementData)
  private
    FPosition, FForward: TVector2;
  public
    function GetType: TMovementDataType; override;
    procedure Write(writer: TByteWriter); override;
    constructor Create; overload;
    constructor Create(reader: TByteReader; syncID: Integer); overload;

    property Position: TVector2 read FPosition write FPosition;
    property Forward: TVector2 read FForward write FForward;
  end;

  // MovementDataNormal
  TMovementDataNormal = class(TMovementData)
  private
    FTeleportNetID: Cardinal;
    FHasTeleportID: Boolean;
    FTeleportID: Byte;
    FWaypoints: TList<TCompressedWaypoint>;
  public
    function GetType: TMovementDataType; override;
    procedure Write(writer: TByteWriter); override;
    constructor Create; overload;
    constructor Create(reader: TByteReader; syncID: Integer); overload;
    destructor Destroy; override;

    property TeleportNetID: Cardinal read FTeleportNetID write FTeleportNetID;
    property HasTeleportID: Boolean read FHasTeleportID write FHasTeleportID;
    property TeleportID: Byte read FTeleportID write FTeleportID;
    property Waypoints: TList<TCompressedWaypoint> read FWaypoints write FWaypoints;
  end;

  // MovementDataWithSpeed
  TMovementDataWithSpeed = class(TMovementDataNormal)
  private
    FSpeedParams: TSpeedParams;
  public
    function GetType: TMovementDataType; override;
    procedure Write(writer: TByteWriter); override;
    constructor Create; overload;
    constructor Create(reader: TByteReader; syncID: Integer); overload;
    destructor Destroy; override;

    property SpeedParams: TSpeedParams read FSpeedParams write FSpeedParams;
  end;

// Fonctions globales pour lecture/écriture avec header

function ReadMovementDataWithHeader(reader: TByteReader): TMovementData;
procedure WriteMovementDataWithHeader(writer: TByteWriter; data: TMovementData);

implementation




{ TMovementDataNone }

constructor TMovementDataNone.Create;
begin
  inherited Create;
end;

constructor TMovementDataNone.Create(reader: TByteReader; syncID: Integer);
begin
  inherited Create;
  SyncID := syncID;
  // rien à lire
end;

function TMovementDataNone.GetType: TMovementDataType;
begin
  Result := mdtNone;
end;

procedure TMovementDataNone.Write(writer: TByteWriter);
begin
  // Rien à écrire
end;

{ TMovementDataStop }

constructor TMovementDataStop.Create;
begin
  inherited Create;
end;

constructor TMovementDataStop.Create(reader: TByteReader; syncID: Integer);
begin
  inherited Create;
  SyncID := syncID;
  FPosition := reader.ReadVector2;
  FForward := reader.ReadVector2;
end;

function TMovementDataStop.GetType: TMovementDataType;
begin
  Result := mdtStop;
end;

procedure TMovementDataStop.Write(writer: TByteWriter);
begin
  writer.WriteVector2(FPosition);
  writer.WriteVector2(FForward);
end;

{ TMovementDataNormal }

constructor TMovementDataNormal.Create;
begin
  inherited Create;
  FWaypoints := TList<TCompressedWaypoint>.Create;
end;

constructor TMovementDataNormal.Create(reader: TByteReader; syncID: Integer);
var
  bitfield, bitfield2: Word;
  size: Byte;
begin
  inherited Create;
  SyncID := syncID;

  bitfield := reader.ReadUInt16;
  FHasTeleportID := (bitfield and 1) <> 0;

  bitfield2 := reader.ReadUInt16;
  size := Byte(bitfield2 and $7F);
  if size > 0 then
  begin
    FTeleportNetID := reader.ReadUInt32;
    if FHasTeleportID then
      FTeleportID := reader.ReadByte;

    FWaypoints := ReadCompressedWaypoints(reader,size);
  end
  else
    FWaypoints := TList<TCompressedWaypoint>.Create;
end;

destructor TMovementDataNormal.Destroy;
begin
  FWaypoints.Free;
  inherited;
end;

function TMovementDataNormal.GetType: TMovementDataType;
begin
  Result := mdtNormal;
end;

procedure TMovementDataNormal.Write(writer: TByteWriter);
var
  waypointsSize: Integer;
  bitfield, bitfield2: Word;
begin
  if FWaypoints = nil then
    waypointsSize := 0
  else
    waypointsSize := FWaypoints.Count;

  if waypointsSize > $7F then
    raise Exception.Create('Too many paths > 0x7F!');

  bitfield := 0;
  if FHasTeleportID then
    bitfield := bitfield or 1;
  writer.WriteUInt16(bitfield);

  bitfield2 := 0;
  if FWaypoints <> nil then
    bitfield2 := bitfield2 or (waypointsSize and $7F);
  writer.WriteUInt16(bitfield2);

  if FWaypoints <> nil then
  begin
    writer.WriteUInt32(FTeleportNetID);
    if FHasTeleportID then
      writer.WriteByte(FTeleportID);

    WriteCompressedWaypoints(writer,FWaypoints);
  end;
end;

{ TMovementDataWithSpeed }

constructor TMovementDataWithSpeed.Create;
begin
  inherited Create;
  FSpeedParams := TSpeedParams.Create;
end;

constructor TMovementDataWithSpeed.Create(reader: TByteReader; syncID: Integer);
var
  bitfield, bitfield2: Word;
  size: Byte;
begin
  inherited Create;
  SyncID := syncID;

  bitfield := reader.ReadUInt16;
  HasTeleportID := (bitfield and 1) <> 0;

  bitfield2 := reader.ReadUInt16;
  size := Byte(bitfield2 and $7F);
  if size > 0 then
  begin
    TeleportNetID := reader.ReadUInt32;
    if HasTeleportID then
      TeleportID := reader.ReadByte;

    FSpeedParams.Free;
    FSpeedParams := ReadWaypointSpeedParams(reader);
    Waypoints.Free;
    Waypoints := ReadCompressedWaypoints(reader,size);
  end
  else
  begin
    FSpeedParams := TSpeedParams.Create;
    Waypoints := TList<TCompressedWaypoint>.Create;
  end;
end;

destructor TMovementDataWithSpeed.Destroy;
begin
  FSpeedParams.Free;
  inherited;
end;

function TMovementDataWithSpeed.GetType: TMovementDataType;
begin
  Result := mdtWithSpeed;
end;

procedure TMovementDataWithSpeed.Write(writer: TByteWriter);
var
  waypointsSize: Integer;
  bitfield, bitfield2: Word;
begin
  if Waypoints = nil then
    waypointsSize := 0
  else
    waypointsSize := Waypoints.Count;

  if waypointsSize > $7F then
    raise Exception.Create('Too many paths > 0x7F!');

  bitfield := 0;
  if HasTeleportID then
    bitfield := bitfield or 1;
  writer.WriteUInt16(bitfield);

  bitfield2 := 0;
  if Waypoints <> nil then
    bitfield2 := bitfield2 or (waypointsSize and $7F);
  writer.WriteUInt16(bitfield2);

  if Waypoints <> nil then
  begin
    writer.WriteUInt32(TeleportNetID);
    if HasTeleportID then
      writer.WriteByte(TeleportID);

    WriteSpeedParams(writer,FSpeedParams);
    WriteCompressedWaypoints(writer,Waypoints);
  end;
end;

// Fonctions globales

function ReadMovementDataWithHeader(reader: TByteReader): TMovementData;
var
  t: Byte;
  syncID: Integer;
begin
  t := reader.ReadByte;
  syncID := reader.ReadInt32;

  case TMovementDataType(t) of
    mdtStop: Result := TMovementDataStop.Create(reader, syncID);
    mdtNormal: Result := TMovementDataNormal.Create(reader, syncID);
    mdtWithSpeed: Result := TMovementDataWithSpeed.Create(reader, syncID);
  else
    Result := TMovementDataNone.Create(reader, syncID);
  end;
end;

procedure WriteMovementDataWithHeader(writer: TByteWriter; data: TMovementData);
begin
  if data = nil then
    data := TMovementDataNone.Create;

  writer.WriteByte(Ord(data.GetType));
  writer.WriteInt32(data.SyncID);
  data.Write(writer);
end;

end.

