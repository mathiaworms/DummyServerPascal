unit S2C_Ping_Load_Info;

interface

uses
  SysUtils,
  GamePacket,
  GamePacketID,
  ByteReader,
  ByteWriter,
  ConnectionInfo;

type
  TS2C_Ping_Load_Info = class(TGamePacket)
  private
    FConnectionInfo: TConnectionInfo;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetID: TGamePacketID; override;
    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property ConnectionInfo: TConnectionInfo read FConnectionInfo write FConnectionInfo;
  end;

implementation

constructor TS2C_Ping_Load_Info.Create;
begin
  inherited Create;
  FConnectionInfo := TConnectionInfo.Create;
end;

destructor TS2C_Ping_Load_Info.Destroy;
begin
  FConnectionInfo.Free;
  inherited Destroy;
end;

function TS2C_Ping_Load_Info.GetID: TGamePacketID;
begin
  Result := GamePacketID.S2C_Ping_Load_Info;
end;

procedure TS2C_Ping_Load_Info.ReadBody(reader: TByteReader);
begin
  FConnectionInfo := ReadConnectionInfo(reader);
end;

procedure TS2C_Ping_Load_Info.WriteBody(writer: TByteWriter);
begin
  WriteConnectionInfo(writer,FConnectionInfo);
end;

end.

