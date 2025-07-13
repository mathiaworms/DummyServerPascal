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

  // Type de fonction cr�ant une instance de TLoadScreenPacket
  TLoadScreenPacketFactory = TFunc<TLoadScreenPacket>;

  // Dictionnaire ID -> fonction cr�ant paquet
  TLoadScreenPacketDict = TDictionary<TLoadScreenPacketID, TLoadScreenPacketFactory>;

  TLoadScreenPacket = class(TBasePacket)
  public
    // ID abstrait (comme propri�t� abstraite en C#)
    function GetID: TLoadScreenPacketID; virtual; abstract;
    property ID: TLoadScreenPacketID read GetID;

    // Lecture et �criture du corps du paquet (abstrait)
    procedure ReadBody(Reader: TByteReader); virtual; abstract;
    procedure WriteBody(Writer: TByteWriter); virtual; abstract;

    // Override des m�thodes de lecture/�criture compl�tes
    procedure ReadPacket(Reader: TByteReader); override;
    procedure WritePacket(Writer: TByteWriter); override;

    // G�n�re le dictionnaire Lookup (�quivalent GenerateLookup)
    class function GenerateLookup: TLoadScreenPacketDict; static;

    // Lookup statique (initialis� une fois)
    class var Lookup: TLoadScreenPacketDict;
  end;


implementation
{ TLoadScreenPacket }
uses
  System.Rtti;

procedure TLoadScreenPacket.ReadPacket(Reader: TByteReader);
begin
  Reader.ReadByte; // lecture de l'ID (ignor�e ici)
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

