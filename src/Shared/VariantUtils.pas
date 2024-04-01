unit VariantUtils;

interface

uses
  // VCL
  SysUtils, Variants;

type
  TVariantArray = array of Variant;

function PackParams(Params: array of const): string;
function VarArrayToStr(const AVarArray: TVariantArray): string;
function ConstArrayToVarArray(const AValues : array of const): TVariantArray;

implementation

function PackParams(Params: array of const): string;
begin
  Result := VarArrayToStr(ConstArrayToVarArray(Params));
end;

function ConstArrayToVarArray(const AValues : array of const): TVariantArray;
var
  i : Integer;
begin
  SetLength(Result, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    with AValues[i] do
    begin
      case VType of
        vtInteger: Result[i] := VInteger;
        vtInt64: Result[i] := VInt64^;
        vtBoolean: Result[i] := VBoolean;
        vtChar: Result[i] := VChar;
        vtExtended: Result[i] := VExtended^;
        vtString: Result[i] := VString^;
        vtPointer: Result[i] := Integer(VPointer);
        vtPChar: Result[i] := StrPas(VPChar);
        vtObject: Result[i]:= Integer(VObject);
        vtAnsiString: Result[i] := String(VAnsiString);
        vtCurrency: Result[i] := VCurrency^;
        vtVariant: Result[i] := VVariant^;
        vtInterface: Result[i]:= Integer(VPointer);
        vtWideString: Result[i]:= WideString(VWideString);
      else
        Result[i] := NULL;
      end;
    end;
  end;
end;

function VariantToStr(V: Variant): string;
begin
  if VarIsNull(V) then
  begin
    Result := 'NULL';
  end else
  begin
    case VarType(V) of
      varOleStr,
      varStrArg,
      varString:
        Result := VarToStr(V);
    else
      Result := VarToStr(V);
    end;
  end;
end;

function VarArrayToStr(const AVarArray: TVariantArray): string;
var
  I: Integer;
begin
  Result := '';
  for i := Low(AVarArray) to High(AVarArray) do
  begin
    if Length(Result) > 0 then
      Result := Result + ',';
    Result := Result + VariantToStr(AVarArray[I]);
  end;
end;


end.
