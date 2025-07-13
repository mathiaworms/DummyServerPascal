unit SpeedParams;

interface

uses
  SysUtils,
  ByteReader,
  ByteWriter,
  Types,
  VectorTypes;  // pour TVector2

type

  TSpeedParams = class
  private
    FPathSpeedOverride: Single;
    FParabolicGravity: Single;
    FParabolicStartPoint: TVector2;
    FFacing: Boolean;
    FFollowNetID: Cardinal;
    FFollowDistance: Single;
    FFollowBackDistance: Single;
    FFollowTravelTime: Single;
  public
    property PathSpeedOverride: Single read FPathSpeedOverride write FPathSpeedOverride;
    property ParabolicGravity: Single read FParabolicGravity write FParabolicGravity;
    property ParabolicStartPoint: TVector2 read FParabolicStartPoint write FParabolicStartPoint;
    property Facing: Boolean read FFacing write FFacing;
    property FollowNetID: Cardinal read FFollowNetID write FFollowNetID;
    property FollowDistance: Single read FFollowDistance write FFollowDistance;
    property FollowBackDistance: Single read FFollowBackDistance write FFollowBackDistance;
    property FollowTravelTime: Single read FFollowTravelTime write FFollowTravelTime;
  end;

// Fonctions globales pour lecture / écriture de SpeedParams

function ReadWaypointSpeedParams(reader: TByteReader): TSpeedParams;
procedure WriteSpeedParams(writer: TByteWriter; data: TSpeedParams);

implementation

function ReadWaypointSpeedParams(reader: TByteReader): TSpeedParams;
var
  tmp: TVector2;
begin
  Result := TSpeedParams.Create;
  Result.PathSpeedOverride := reader.ReadFloat;
  Result.ParabolicGravity := reader.ReadFloat;
  tmp := Result.ParabolicStartPoint;
  tmp.X := reader.ReadFloat;
  tmp.Y := reader.ReadFloat;
  Result.ParabolicStartPoint := tmp;
  Result.Facing := reader.ReadBool;
  Result.FollowNetID := reader.ReadUInt32;
  Result.FollowDistance := reader.ReadFloat;
  Result.FollowBackDistance := reader.ReadFloat;
  Result.FollowTravelTime := reader.ReadFloat;
end;

procedure WriteSpeedParams(writer: TByteWriter; data: TSpeedParams);
begin
  if data = nil then
    data := TSpeedParams.Create;  // ou raise Exception ?

  writer.WriteFloat(data.PathSpeedOverride);
  writer.WriteFloat(data.ParabolicGravity);
  writer.WriteFloat(data.ParabolicStartPoint.X);
  writer.WriteFloat(data.ParabolicStartPoint.Y);
  writer.WriteBool(data.Facing);
  writer.WriteUInt32(data.FollowNetID);
  writer.WriteFloat(data.FollowDistance);
  writer.WriteFloat(data.FollowBackDistance);
  writer.WriteFloat(data.FollowTravelTime);
end;

end.

