unit StrUtil;

interface

uses
  // VCL
  SysUtils;

function Min(V1, V2: Integer): Integer;
function StrToHex(const S: string): string;
function HexToStr(const Data: string): string;
function IntToBin(Value, Count: Int64): string;
function BinToInt(const S: string; Index, Count: Integer): Int64;

implementation

function Min(V1, V2: Integer): Integer;
begin
  if V1 < V2 then Result := V1
  else Result := V2;
end;

function BinToInt(const S: string; Index, Count: Integer): Int64;
var
  N: Integer;
begin
  Result := 0;
  if (Index > 0)and(Index <= Length(S)) then
  begin
    N := Min(Length(S)-Index+1, 8);
    if Count <= N then
      Move(S[Index], Result, Count);
  end;
end;

function IntToBin(Value, Count: Int64): string;
begin
  Result := '';
  if Count in [1..8] then
  begin
    SetLength(Result, Count);
    Move(Value, Result[1], Count);
  end;
end;

function StrToHex(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if i <> 1 then Result := Result + ' ';
    Result := Result + IntToHex(Ord(S[i]), 2);
  end;
end;

function HexToStr(const Data: string): string;
var
  S: string;
  i: Integer;
  V, Code: Integer;
begin
  S := '';
  Result := '';
  for i := 1 to Length(Data) do
  begin
    S := Trim(S + Data[i]);
    if (Length(S) <> 0)and((Length(S) = 2)or(Data[i] = ' ')) then
    begin
      Val('$' + S, V, Code);
      if Code <> 0 then Exit;
      Result := Result + Chr(V);
      S := '';
    end;
  end;
  // последний символ
  if Length(S) <> 0 then
  begin
    Val('$' + S, V, Code);
    if Code <> 0 then Exit;
    Result := Result + Chr(V);
  end;
end;


end.
