unit LoadScreenPacket;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  ByteReader,
  ByteWriter,
  BasePacket,
  LoadScreenPacketID;

type

  TLoadScreenPacket = class; // forward declaration

  // Type de fonction créant une instance de TLoadScreenPacket
  TLoadScreenPacketFactory = TFunc<TLoadScreenPacket>;

  // Dictionnaire ID -> fonction créant paquet
  TLoadScreenPacketDict = TDictionary<TLoadScreenPacketID, TLoadScreenPacketFactory>;

  TLoadScreenPacket = class(TBasePacket)
  public
    // ID abstrait (comme propriété abstraite en C#)
    function GetID: TLoadScreenPacketID; virtual; abstract;
    property ID: TLoadScreenPacketID read GetID;

    // Lecture et écriture du corps du paquet (abstrait)
    procedure ReadBody(Reader: TByteReader); virtual; abstract;
    procedure WriteBody(Writer: TByteWriter); virtual; abstract;

    // Override des méthodes de lecture/écriture complètes
    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;

    // Génère le dictionnaire Lookup (équivalent GenerateLookup)
    class function GenerateLookup: TLoadScreenPacketDict; static;

    // Lookup statique (initialisé une fois)
    class var Lookup: TLoadScreenPacketDict;
  end;


implementation
{ TLoadScreenPacket }
uses
  System.Rtti;

procedure TLoadScreenPacket.ReadPacket(Reader: TByteReader);
begin
  Reader.ReadByte; // lecture de l'ID (ignorée ici)
  ReadBody(Reader);
end;

procedure TLoadScreenPacket.WritePacket(Writer: TByteWriter);
begin
  Writer.WriteByte(Byte(ID));
  WriteBody(Writer);
end;

class function TLoadScreenPacket.GenerateLookup: TLoadScreenPacketDict;
var
  ctx: TRttiContext;
  typ: TRttiType;
  instType: TClass;
  packet: TLoadScreenPacket;
  id: TLoadScreenPacketID;
  factory: TLoadScreenPacketFactory;
begin
  Result := TLoadScreenPacketDict.Create;
  ctx := TRttiContext.Create;
  try
    for typ in ctx.GetTypes do
    begin
      if typ is TRttiInstanceType then
      begin
        instType := TRttiInstanceType(typ).MetaclassType;
        if instType.InheritsFrom(TLoadScreenPacket) and
           not instType.ClassNameIs('TLoadScreenPacket') then
        begin
          packet := TLoadScreenPacket(instType.Create);
          try
            id := packet.ID;
            if Result.ContainsKey(id) then
              raise Exception.Create('ID already in lookup map');

            factory := function: TLoadScreenPacket
            begin
              Result := TLoadScreenPacket(instType.Create);
            end;

            Result.Add(id, factory);
          finally
            packet.Free;
          end;
        end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

// Initialisation statique du Lookup
initialization
  TLoadScreenPacket.Lookup := TLoadScreenPacket.GenerateLookup;

finalization
  TLoadScreenPacket.Lookup.Free;

end.

