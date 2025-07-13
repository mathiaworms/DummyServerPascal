unit ByteReader;

interface

uses
  System.SysUtils, System.Classes, System.Math, System.Generics.Collections,
  System.IOUtils, System.Types, System.UITypes, System.AnsiStrings,
  System.Character, System.ZLib, System.StrUtils, VectorTypes;

type

  TByteReader = class
  private
    FStream: TMemoryStream;
    FReader: TBinaryReader;
  public
    constructor Create(const Data: TBytes);
    destructor Destroy; override;

    function Position: Integer;
    function Seek(Offset: Integer; Origin: TSeekOrigin = soCurrent): Integer;
    function LengthByte: Integer;
    function BytesLeft: Integer;

    function ReadBool: Boolean;
    function ReadSByte: ShortInt;
    function ReadByte: Byte;
    function ReadInt16: SmallInt;
    function ReadUInt16: Word;
    function ReadInt32: Integer;
    function ReadUInt32: Cardinal;
    function ReadInt64: Int64;
    function ReadUInt64: UInt64;
    function ReadFloat: Single;
    function ReadDouble: Double;
    function ReadF8: Single;

    function ReadBytes(Count: Integer): TBytes;
    procedure ReadPad(Count: Integer);
    function ReadBytesLeft: TBytes;

    function ReadVector2: TVector2;
    function ReadVector3: TVector3;
    function ReadVector4: TVector4;

    function ReadFixedString(MaxLength: Integer): string;
    function ReadZeroTerminatedString: string;
    function ReadSizedString: string;
    function ReadSizedStringWithZero: string;

    function ReadColor: TColor;
  end;

implementation

uses
  System.NetEncoding;



{ --- TByteReader Implementation --- }

constructor TByteReader.Create(const Data: TBytes);
begin
  FStream := TMemoryStream.Create;
  FStream.WriteBuffer(Data, Length(Data));
  FStream.Position := 0;
  FReader := TBinaryReader.Create(FStream, TEncoding.UTF8, False);
end;

destructor TByteReader.Destroy;
begin
  FReader.Free;
  FStream.Free;
  inherited;
end;

function TByteReader.Position: Integer;
begin
  Result := FStream.Position;
end;

function TByteReader.Seek(Offset: Integer; Origin: TSeekOrigin): Integer;
begin
  Result := FStream.Seek(Offset, Origin);
end;

function TByteReader.LengthByte: Integer;
begin
  Result := FStream.Size;
end;

function TByteReader.BytesLeft: Integer;
begin
  Result := FStream.Size - FStream.Position;
end;

function TByteReader.ReadBool: Boolean;
begin
  Result := FReader.ReadBoolean;
end;

function TByteReader.ReadSByte: ShortInt;
begin
  Result := FReader.ReadSByte;
end;

function TByteReader.ReadByte: Byte;
begin
  Result := FReader.ReadByte;
end;

function TByteReader.ReadInt16: SmallInt;
begin
  Result := FReader.ReadInt16;
end;

function TByteReader.ReadUInt16: Word;
begin
  Result := FReader.ReadUInt16;
end;

function TByteReader.ReadInt32: Integer;
begin
  Result := FReader.ReadInt32;
end;

function TByteReader.ReadUInt32: Cardinal;
begin
  Result := FReader.ReadUInt32;
end;

function TByteReader.ReadInt64: Int64;
begin
  Result := FReader.ReadInt64;
end;

function TByteReader.ReadUInt64: UInt64;
begin
  Result := FReader.ReadUInt64;
end;

function TByteReader.ReadFloat: Single;
begin
  Result := FReader.ReadSingle;
end;

function TByteReader.ReadDouble: Double;
begin
  Result := FReader.ReadDouble;
end;

function TByteReader.ReadF8: Single;
begin
  Result := (ReadByte - 128) / 100.0;
end;

function TByteReader.ReadBytes(Count: Integer): TBytes;
begin
  if Count > BytesLeft then
    raise Exception.CreateFmt('Failed to read bytes: %d', [Count]);
  Result := FReader.ReadBytes(Count);
end;

procedure TByteReader.ReadPad(Count: Integer);
begin
  if Count > BytesLeft then
    raise Exception.CreateFmt('Failed to read pad: %d', [Count]);
  FStream.Seek(Count, soCurrent);
end;

function TByteReader.ReadBytesLeft: TBytes;
begin
  Result := FReader.ReadBytes(BytesLeft);
end;

function TByteReader.ReadVector2: TVector2;
var
  x, y: Single;
begin
  x := ReadFloat;
  y := ReadFloat;
  Result := TVector2.Create(x, y);
end;

function TByteReader.ReadVector3: TVector3;
var
  x, y, z: Single;
begin
  x := ReadFloat;
  y := ReadFloat;
  z := ReadFloat;
  Result := TVector3.Create(x, y, z);
end;

function TByteReader.ReadVector4: TVector4;
var
  x, y, z, w: Single;
begin
  x := ReadFloat;
  y := ReadFloat;
  z := ReadFloat;
  w := ReadFloat;
  Result := TVector4.Create(x, y, z, w);
end;

function TByteReader.ReadFixedString(MaxLength: Integer): string;
var
  Raw: TBytes;
  i: Integer;
begin
  Raw := ReadBytes(MaxLength);
  i := 0;
  while (i < Length(Raw)) and (Raw[i] <> 0) do
    Inc(i);
  SetLength(Raw, i);
  Result := TEncoding.UTF8.GetString(Raw);
end;

function TByteReader.ReadZeroTerminatedString: string;
var
  Bytes: TBytes;
  B: Byte;
begin
  SetLength(Bytes, 0);
  repeat
    B := ReadByte;
    if B <> 0 then
    begin
      SetLength(Bytes, Length(Bytes) + 1);
      Bytes[High(Bytes)] := B;
    end;
  until B = 0;
  Result := TEncoding.UTF8.GetString(Bytes);
end;

function TByteReader.ReadSizedString: string;
var
  Count: Integer;
  Raw: TBytes;
begin
  Count := ReadInt32;
  if Count <= 0 then
    Exit('');
  Raw := ReadBytes(Count);
  Result := TEncoding.UTF8.GetString(Raw);
end;

function TByteReader.ReadSizedStringWithZero: string;
begin
  Result := ReadSizedString;
  ReadPad(1); // skip null terminator
end;

function TByteReader.ReadColor: TColor;
begin
  Result := TColor(ReadUInt32);
end;

end.
