unit ByteWriter;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, VectorTypes;

type


  TByteWriter = class
  private
    FStream: TMemoryStream;
    FWriter: TBinaryWriter;
  public
    constructor Create;
    destructor Destroy; override;

    function Position: Integer;
    function Seek(Offset: Integer; Origin: TSeekOrigin = soCurrent): Integer;
    function LengthByte: Integer;
    function GetBytes: TBytes;

    procedure WriteBool(Value: Boolean);
    procedure WriteSByte(Value: ShortInt);
    procedure WriteByte(Value: Byte);
    procedure WriteInt16(Value: SmallInt);
    procedure WriteUInt16(Value: Word);
    procedure WriteInt32(Value: Integer);
    procedure WriteUInt32(Value: Cardinal);
    procedure WriteInt64(Value: Int64);
    procedure WriteUInt64(Value: UInt64);
    procedure WriteFloat(Value: Single);
    procedure WriteDouble(Value: Double);
    procedure WriteF8(Value: Single);

    procedure WriteBytes(const Data: TBytes);
    procedure WritePad(Count: Integer);

    procedure WriteFixedString(const Str: string; MaxLength: Integer);
    procedure WriteZeroTerminatedString(const Str: string);
    procedure WriteSizedStringWithZero(const Str: string);
    procedure WriteSizedString(const Str: string);

    procedure WriteVector2(const V: TVector2);
    procedure WriteVector3(const V: TVector3);
    procedure WriteVector4(const V: TVector4);

    procedure WriteColor(const Color: TAlphaColor);
  end;

implementation

constructor TByteWriter.Create;
begin
  inherited Create;
  FStream := TMemoryStream.Create;
  FWriter := TBinaryWriter.Create(FStream);
end;

destructor TByteWriter.Destroy;
begin
  FWriter.Free;
  FStream.Free;
  inherited;
end;

function TByteWriter.Position: Integer;
begin
  Result := FStream.Position;
end;

function TByteWriter.Seek(Offset: Integer; Origin: TSeekOrigin): Integer;
begin
  Result := FStream.Seek(Offset, Origin);
end;

function TByteWriter.LengthByte: Integer;
begin
  Result := FStream.Size;
end;

function TByteWriter.GetBytes: TBytes;
begin
  SetLength(Result, FStream.Size);
  Move(FStream.Memory^, Result[0], FStream.Size);
end;

procedure TByteWriter.WriteBool(Value: Boolean);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteSByte(Value: ShortInt);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteByte(Value: Byte);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteInt16(Value: SmallInt);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteUInt16(Value: Word);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteInt32(Value: Integer);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteUInt32(Value: Cardinal);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteInt64(Value: Int64);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteUInt64(Value: UInt64);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteFloat(Value: Single);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteDouble(Value: Double);
begin
  FWriter.Write(Value);
end;

procedure TByteWriter.WriteF8(Value: Single);
begin
  WriteByte(Trunc(Value * 100 + 128));
end;

procedure TByteWriter.WriteBytes(const Data: TBytes);
begin
  FWriter.Write(Data);
end;

procedure TByteWriter.WritePad(Count: Integer);
var
  Pad: TBytes;
begin
  SetLength(Pad, Count);
  FillChar(Pad[0], Count, 0);
  FWriter.Write(Pad);
end;

procedure TByteWriter.WriteFixedString(const Str: string; MaxLength: Integer);
var
  Data: TBytes;
begin
  Data := TEncoding.UTF8.GetBytes(Str);
  if Length(Data) >= MaxLength then
    raise Exception.Create('Too much data!');
  WriteBytes(Data);
  WritePad(MaxLength - Length(Data));
end;

procedure TByteWriter.WriteZeroTerminatedString(const Str: string);
var
  Data: TBytes;
begin
  Data := TEncoding.UTF8.GetBytes(Str);
  WriteBytes(Data);
  WriteByte(0);
end;

procedure TByteWriter.WriteSizedStringWithZero(const Str: string);
begin
  WriteSizedString(Str);
  WritePad(1);
end;

procedure TByteWriter.WriteSizedString(const Str: string);
var
  Data: TBytes;
begin
  Data := TEncoding.UTF8.GetBytes(Str);
  WriteInt32(Length(Data));
  WriteBytes(Data);
end;

procedure TByteWriter.WriteVector2(const V: TVector2);
begin
  WriteFloat(V.X);
  WriteFloat(V.Y);
end;

procedure TByteWriter.WriteVector3(const V: TVector3);
begin
  WriteFloat(V.X);
  WriteFloat(V.Y);
  WriteFloat(V.Z);
end;

procedure TByteWriter.WriteVector4(const V: TVector4);
begin
  WriteFloat(V.X);
  WriteFloat(V.Y);
  WriteFloat(V.Z);
  WriteFloat(V.W);
end;

procedure TByteWriter.WriteColor(const Color: TAlphaColor);
begin
  WriteUInt32(Color);
end;

end.

