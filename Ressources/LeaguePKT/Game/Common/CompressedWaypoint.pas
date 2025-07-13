unit CompressedWaypoint;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, ByteReader, ByteWriter;

type
  TCompressedWaypoint = record
    X: SmallInt;
    Y: SmallInt;
    constructor Create(aX, aY: SmallInt);
  end;


function ReadCompressedWaypoints(reader: TByteReader; size: Cardinal): TList<TCompressedWaypoint>;
procedure WriteCompressedWaypoints(writer: TByteWriter; dataList: TList<TCompressedWaypoint>);

implementation

{ TCompressedWaypoint }

constructor TCompressedWaypoint.Create(aX, aY: SmallInt);
begin
  X := aX;
  Y := aY;
end;

function ReadCompressedWaypoints(reader: TByteReader; size: Cardinal): TList<TCompressedWaypoint>;
var
  flagsBuffer: TBytes;
  flags: TBits;
  i, flagIndex: Integer;
  lastX, lastY: SmallInt;
begin
  Result := TList<TCompressedWaypoint>.Create;
  if size > 1 then
  begin
    SetLength(flagsBuffer, ((size - 2) div 4) + 1);
    flagsBuffer := reader.ReadBytes(Length(flagsBuffer));
    flags := TBits.Create;
    try
      flags.Size := Length(flagsBuffer) * 8;
      // Charger les bits depuis flagsBuffer
      for i := 0 to Length(flagsBuffer) - 1 do
      begin
        flags[8*i + 0] := (flagsBuffer[i] and $01) <> 0;
        flags[8*i + 1] := (flagsBuffer[i] and $02) <> 0;
        flags[8*i + 2] := (flagsBuffer[i] and $04) <> 0;
        flags[8*i + 3] := (flagsBuffer[i] and $08) <> 0;
        flags[8*i + 4] := (flagsBuffer[i] and $10) <> 0;
        flags[8*i + 5] := (flagsBuffer[i] and $20) <> 0;
        flags[8*i + 6] := (flagsBuffer[i] and $40) <> 0;
        flags[8*i + 7] := (flagsBuffer[i] and $80) <> 0;
      end;
    except
      flags.Free;
      raise;
    end;
  end
  else
  begin
    flags := TBits.Create;
    flags.Size := 8;
  end;

  try
    lastX := reader.ReadInt16;
    lastY := reader.ReadInt16;
    Result.Add(TCompressedWaypoint.Create(lastX, lastY));

    flagIndex := 0;
    for i := 1 to size - 1 do
    begin
      if flags[flagIndex] then
        Inc(lastX, reader.ReadSByte)
      else
        lastX := reader.ReadInt16;
      Inc(flagIndex);

      if flags[flagIndex] then
        Inc(lastY, reader.ReadSByte)
      else
        lastY := reader.ReadInt16;
      Inc(flagIndex);

      Result.Add(TCompressedWaypoint.Create(lastX, lastY));
    end;
  finally
    flags.Free;
  end;
end;

procedure WriteCompressedWaypoints(writer: TByteWriter; dataList: TList<TCompressedWaypoint>);
var
  size, i, flagIndex: Integer;
  flagsBuffer: TBytes;
  flags: TBits;
  relativeX, relativeY: Integer;
begin
  if dataList = nil then
    dataList := TList<TCompressedWaypoint>.Create;

  size := dataList.Count;
  if size < 1 then
    raise Exception.Create('Need at least 1 waypoint!');

  if size > 1 then
    SetLength(flagsBuffer, ((size - 2) div 4) + 1)
  else
    SetLength(flagsBuffer, 0);

  flags := TBits.Create;
  try
    flags.Size := Length(flagsBuffer) * 8;

    flagIndex := 0;
    for i := 1 to size - 1 do
    begin
      relativeX := dataList[i].X - dataList[i - 1].X;
      flags[flagIndex] := (relativeX <= High(ShortInt)) and (relativeX >= Low(ShortInt));
      Inc(flagIndex);

      relativeY := dataList[i].Y - dataList[i - 1].Y;
      flags[flagIndex] := (relativeY <= High(ShortInt)) and (relativeY >= Low(ShortInt));
      Inc(flagIndex);
    end;

    // Copier les bits dans flagsBuffer
    FillChar(flagsBuffer[0], Length(flagsBuffer), 0);
    for i := 0 to flags.Size - 1 do
    begin
      if flags[i] then
        flagsBuffer[i div 8] := flagsBuffer[i div 8] or (1 shl (i mod 8));
    end;

    writer.WriteBytes(flagsBuffer);
    writer.WriteInt16(dataList[0].X);
    writer.WriteInt16(dataList[0].Y);

    flagIndex := 0;
    for i := 1 to size - 1 do
    begin
      if flags[flagIndex] then
        writer.WriteSByte(ShortInt(dataList[i].X - dataList[i - 1].X))
      else
        writer.WriteInt16(dataList[i].X);
      Inc(flagIndex);

      if flags[flagIndex] then
        writer.WriteSByte(ShortInt(dataList[i].Y - dataList[i - 1].Y))
      else
        writer.WriteInt16(dataList[i].Y);
      Inc(flagIndex);
    end;

  finally
    flags.Free;
  end;
end;

end.

