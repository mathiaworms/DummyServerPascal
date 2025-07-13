unit VectorTypes;

interface

type
   TVector2 = record
    X, Y: Single;
    constructor Create(aX, aY: Single);
  end;

  TVector3 = record
    X, Y, Z: Single;
    constructor Create(aX, aY, aZ: Single);
  end;

  TVector4 = record
    X, Y, Z, W: Single;
    constructor Create(aX, aY, aZ, aW: Single);
  end;

implementation


constructor TVector2.Create(aX, aY: Single);
begin
  X := aX;
  Y := aY;
end;

constructor TVector3.Create(aX, aY, aZ: Single);
begin
  X := aX;
  Y := aY;
  Z := aZ;
end;

constructor TVector4.Create(aX, aY, aZ, aW: Single);
begin
  X := aX;
  Y := aY;
  Z := aZ;
  W := aW;
end;

end.

