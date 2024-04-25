unit MathUtils;

interface

function Round2(Value: Double): Int64;
function RoundAmount(Value: Double): Double;

implementation

const
  C_DOUBLE_PREC = 0.00001; //    9.5E-4;

function ExRound(const N: double; const APrecisionRound: double): double;
var
  i, f: double;
begin
  if N < 0 then
    Result := Int((N - C_DOUBLE_PREC) / APrecisionRound)
  else
    Result := Int((N + C_DOUBLE_PREC) / APrecisionRound);

  f := abs(N / APrecisionRound - Result); 

  if f > 0.5 - C_DOUBLE_PREC then
    i := 1
  else
    i := 0;

  if N < 0 then
    Result := (Result - i) * APrecisionRound
  else
    Result := (Result + i) * APrecisionRound;
end;

function Round2(Value: Double): Int64;
begin
  Result := Trunc(ExRound(Value, 1))
end;

function RoundAmount(Value: Double): Double;
begin
  Result := Round2(Value * 100)/100;
end;


end.
