unit C2S_Ping_Load_Info;

interface

uses
   SysUtils,
   GamePacket,
   GamePacketID,
   ByteReader,
   ByteWriter,
   ConnectionInfo;

type
  TC2S_Ping_Load_Info = class(TGamePacket)
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

{ TC2S_Ping_Load_Info }

constructor TC2S_Ping_Load_Info.Create;
begin
  inherited;
  FConnectionInfo := TConnectionInfo.Create;
end;

destructor TC2S_Ping_Load_Info.Destroy;
begin
  FConnectionInfo.Free;
  inherited;
end;

function TC2S_Ping_Load_Info.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_Ping_Load_Info;
end;

procedure TC2S_Ping_Load_Info.ReadBody(reader: TByteReader);
begin
  FConnectionInfo.Free;
  FConnectionInfo := ReadConnectionInfo(reader);
end;

procedure TC2S_Ping_Load_Info.WriteBody(writer: TByteWriter);
begin
  WriteConnectionInfo(writer,FConnectionInfo);
end;

end.


