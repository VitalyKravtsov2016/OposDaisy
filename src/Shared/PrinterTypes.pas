unit PrinterTypes;

interface

uses
  // VCL
  SysUtils,
  // This
  StringUtils;

type
  { TBarcodeRec }

  TBarcodeRec = record
    Data: WideString; // barcode data
    Text: WideString; // barcode text
    Width: Integer;
    Height: Integer;
    BarcodeType: Integer;
    ModuleWidth: Integer;
    Alignment: Integer;
    Parameter1: Byte;
    Parameter2: Byte;
    Parameter3: Byte;
    Parameter4: Byte;
    Parameter5: Byte;
  end;

const
  CRLF = #13#10;
  ValueDelimiters = [';'];

function StrToBarcode(const Data: string): TBarcodeRec;
function BarcodeToStr(const Barcode: TBarcodeRec): string;

implementation

function StrToBarcode(const Data: string): TBarcodeRec;
begin
  Result.Data := GetString(Data, 1, ValueDelimiters);
  Result.Text := GetString(Data, 2, ValueDelimiters);
  Result.Height := GetInteger(Data, 3, ValueDelimiters);
  Result.BarcodeType := GetInteger(Data, 4, ValueDelimiters);
  Result.ModuleWidth := GetInteger(Data, 5, ValueDelimiters);
  Result.Alignment := GetInteger(Data, 6, ValueDelimiters);
  Result.Parameter1 := GetInteger(Data, 7, ValueDelimiters);
  Result.Parameter2 := GetInteger(Data, 8, ValueDelimiters);
  Result.Parameter3 := GetInteger(Data, 9, ValueDelimiters);
  Result.Parameter4 := GetInteger(Data, 10, ValueDelimiters);
  Result.Parameter5 := GetInteger(Data, 11, ValueDelimiters);
  Result.Width := GetInteger(Data, 12, ValueDelimiters);
end;

function BarcodeToStr(const Barcode: TBarcodeRec): string;
begin
  Result := Format('%s;%s;%d;%d;%d;%d;%d;%d;%d',[
    Barcode.Data,
    Barcode.Text,
    Barcode.Height,
    Barcode.BarcodeType,
    Barcode.ModuleWidth,
    Barcode.Alignment,
    Barcode.Parameter1,
    Barcode.Parameter2,
    Barcode.Parameter3,
    Barcode.Parameter4,
    Barcode.Parameter5]);
end;


end.
