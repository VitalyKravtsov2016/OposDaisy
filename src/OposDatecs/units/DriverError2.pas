unit DriverError2;

interface

uses
  // VCL
  SysUtils;

type
  { EDriverError }

  EDriverError = class(Exception)
  private
    FCode: Integer;
    FText: WideString;
  public
    property Code: Integer read FCode;
    property Text: WideString read FText;
    constructor Create2(ACode: Integer; const AText: WideString);
  end;

procedure RaiseError(Code: Integer; const Text: WideString);

implementation

{ EDriverError }

constructor EDriverError.Create2(ACode: Integer; const AText: WideString);
begin
  inherited Create(AText);
  FCode := ACode;
  FText := AText;
end;

procedure RaiseError(Code: Integer; const Text: WideString);
begin
  raise EDriverError.Create2(Code, Text);
end;

end.
