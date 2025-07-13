unit  C2S_NPC_IssueOrderReq;

interface

uses
   SysUtils,
   GamePacket,
   GamePacketID,
   ByteReader,
   ByteWriter,
   MovementDataUnit,
   VectorTypes; // pour TVector3 (Vector3)

type
  TC2S_NPC_IssueOrderReq = class(TGamePacket)
  private
    FOrderType: Byte;
    FPosition: TVector3;
    FTargetNetID: Cardinal;
    FMovementData: TMovementDataNormal;
  public
    constructor Create; override;
    destructor Destroy; override;

    function GetID: TGamePacketID; override;

    procedure ReadBody(reader: TByteReader); override;
    procedure WriteBody(writer: TByteWriter); override;

    property OrderType: Byte read FOrderType write FOrderType;
    property Position: TVector3 read FPosition write FPosition;
    property TargetNetID: Cardinal read FTargetNetID write FTargetNetID;
    property MovementData: TMovementDataNormal read FMovementData write FMovementData;
  end;

implementation

{ TC2S_NPC_IssueOrderReq }

constructor TC2S_NPC_IssueOrderReq.Create;
begin
  inherited;
  FMovementData := TMovementDataNormal.Create;
end;

destructor TC2S_NPC_IssueOrderReq.Destroy;
begin
  FMovementData.Free;
  inherited;
end;

function TC2S_NPC_IssueOrderReq.GetID: TGamePacketID;
begin
  Result := GamePacketID.C2S_NPC_IssueOrderReq;
end;

procedure TC2S_NPC_IssueOrderReq.ReadBody(reader: TByteReader);
begin
  FOrderType := reader.ReadByte;
  FPosition := reader.ReadVector3;
  FTargetNetID := reader.ReadUInt32;

  if reader.BytesLeft >= 5 then
  begin
    FreeAndNil(FMovementData);
    FMovementData := TMovementDataNormal.Create(reader, 0);
  end;
end;

procedure TC2S_NPC_IssueOrderReq.WriteBody(writer: TByteWriter);
begin
  writer.WriteByte(FOrderType);
  writer.WriteVector3(FPosition);
  writer.WriteUInt32(FTargetNetID);

  if Assigned(FMovementData) then
    FMovementData.Write(writer);
end;

end.

