unit duDPDataTest;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics, DateUtils,
  // Tnt
  TntGraphics, TntClasses,
  // DUnit
  TestFramework,
  // This
  DaisyPrinter, LogFile, SerialPort, FileUtils, PrinterPort, SocketPort,
  StringUtils, DebugUtils;

type
  { TDaisyPrinterDataTest }

  TDaisyPrinterDataTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FPrinter: TDaisyPrinter;

    property Printer: TDaisyPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;
    // To do
    procedure TestReadFDVATRates;
  published
    procedure TestSearchDevice;
    procedure TestReset;
    procedure TestReadOperator1;
    procedure TestReadConstants;
    procedure TestReadWriteDate;
    procedure TestReadDiagnosticInfo;
    procedure TestReadStatus;
    procedure TestWritePrintOption;
    procedure TestWriteLogoEnabled;
    procedure TestWriteCutMode;
    procedure TestWriteDetailedReceipt;
    procedure TestReadText;
    procedure TestWriteText;
    procedure TestNumberClicheLines;
    procedure TestNumberAdvertizingLines;
    procedure TestPrintOptions;
    procedure TestDetailedPrint;
    procedure TestHeaderType;
    procedure TestTrailerType;
    procedure TestSaveParameters;
    procedure TestPrinterNumber;
    procedure TestSystemFont;
    procedure TestTrailerLogo;
    procedure TestReadOperatorNames;
    procedure TestWriteOperatorName;
    procedure TestReadReceiptStatus;
    procedure TestReadReadDayStatus;
    procedure TestWriteFiscalNumber;
    procedure TestFinalFiscalRecord;
    procedure TestSetBaudRate;
  end;

implementation

{ TDaisyPrinterDataTest }

procedure TDaisyPrinterDataTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  FPort := CreateSerialPort;
  FPrinter := TDaisyPrinter.Create(FPort, FLogger);
end;

procedure TDaisyPrinterDataTest.TearDown;
begin
  FPort := nil;
  FLogger := nil;
  FPrinter.Free;
  FPrinter := nil;
end;

function TDaisyPrinterDataTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM4';
  SerialParams.BaudRate := 9600;
  SerialParams.DataBits := 8;
  SerialParams.StopBits := ONESTOPBIT;
  SerialParams.Parity := 0;
  SerialParams.FlowControl := FLOW_CONTROL_NONE;
  SerialParams.ReconnectPort := False;
  SerialParams.ByteTimeout := 1000;
  Result := TSerialPort.Create(SerialParams, FLogger);
  Result.Open;
  Result.SetDTRState(True);
end;

function TDaisyPrinterDataTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TDaisyPrinterDataTest.TestSearchDevice;
begin

end;

procedure TDaisyPrinterDataTest.TestReset;
begin
  Printer.Check(Printer.Reset);
end;

procedure TDaisyPrinterDataTest.TestReadWriteDate;
var
  Seconds: Integer;
  Date1, Date2: TDateTime;
  Hour, Min, Sec, MSec: Word;
begin
  Date1 := Now;
  Printer.Check(Printer.WriteDateTime(Date1));
  Printer.Check(Printer.ReadDateTime(Date2));
  Seconds := Abs(SecondsBetween(Date1, Date2));
  Check(Seconds <= 60, 'Seconds > 60, ' + IntToStr(Seconds));
  // Seconds are not set
  DecodeTime(Date2, Hour, Min, Sec, MSec);
  Check(Sec <= 1, 'Sec > 1, ' + IntToStr(Sec));
end;

//  FX1300-11.00GE 27-10-2017 09:22,643A,00,8,,
//  FX1300-11.00GE от 27-10-2017 09:22, 643A
procedure TDaisyPrinterDataTest.TestReadDiagnosticInfo;
var
  Data: TDFPDiagnosticInfo;
begin
  Printer.Check(Printer.ReadDiagnosticInfo(False, Data));
  CheckEquals('FX1300-11.00GE', Data.FirmwareVersion, 'FirmwareVersion');
  CheckEquals('27-10-2017', Data.FirmwareDate, 'FirmwareDate');
  CheckEquals('09:22', Data.FirmwareTime, 'FirmwareTime');
  CheckEquals('643A', Data.ChekSum, 'ChekSum');
  CheckEquals(0, Data.Switches, 'Switches');
  CheckEquals(8, Data.Country, 'Country');
  CheckEquals('', Data.FDSerial, 'FDSerial');
  CheckEquals('', Data.FDNo, 'FDNo');
end;


procedure TDaisyPrinterDataTest.TestReadStatus;
begin
  Printer.Check(Printer.ReadStatus);
  CheckEquals(False, Printer.Status.GeneralError, 'GeneralError');
  CheckEquals(False, Printer.Status.PrinterError, 'PrinterError');
  CheckEquals(False, Printer.Status.DisplayDisconnected, 'DisplayDisconnected');
  CheckEquals(False, Printer.Status.ClockNotSet, 'ClockNotSet');
  CheckEquals(False, Printer.Status.InvalidCommandCode, 'InvalidCommandCode');
  CheckEquals(False, Printer.Status.InvalidDataSyntax, 'InvalidDataSyntax');
end;

procedure TDaisyPrinterDataTest.TestWritePrintOption;
var
  Options: TDFPPrintOptions;
begin
  Options.BlankLineAfterHeader := True;
  Options.BlankLineAfterRegno := True;
  Options.BlankLineAfterFooter := True;
  Options.DelimiterLineBeforeTotal := True;
  Printer.Check(Printer.WritePrintOptions(Options));
  Printer.Check(Printer.ReadPrintOptions(Options));
  CheckEquals(True, Options.BlankLineAfterHeader, 'BlankLineAfterHeader.1');
  CheckEquals(True, Options.BlankLineAfterRegno, 'BlankLineAfterRegno.1');
  CheckEquals(True, Options.BlankLineAfterFooter, 'BlankLineAfterFooter.1');
  CheckEquals(True, Options.DelimiterLineBeforeTotal, 'DelimiterLineBeforeTotal.1');

  Options.BlankLineAfterHeader := False;
  Options.BlankLineAfterRegno := False;
  Options.BlankLineAfterFooter := False;
  Options.DelimiterLineBeforeTotal := False;
  Printer.Check(Printer.WritePrintOptions(Options));
  Printer.Check(Printer.ReadPrintOptions(Options));
  CheckEquals(False, Options.BlankLineAfterHeader, 'BlankLineAfterHeader.2');
  CheckEquals(False, Options.BlankLineAfterRegno, 'BlankLineAfterRegno.2');
  CheckEquals(False, Options.BlankLineAfterFooter, 'BlankLineAfterFooter.2');
  CheckEquals(False, Options.DelimiterLineBeforeTotal, 'DelimiterLineBeforeTotal.2');
end;

procedure TDaisyPrinterDataTest.TestWriteLogoEnabled;
var
  B: Boolean;
begin
  // Logo is disabled and cannot be enabled !!!
  Printer.Check(Printer.WriteLogoEnabled(True));
  Printer.Check(Printer.ReadLogoEnabled(B));
  CheckEquals(False, B, 'WriteLogoEnabled(True)');

  Printer.Check(Printer.WriteLogoEnabled(False));
  Printer.Check(Printer.ReadLogoEnabled(B));
  CheckEquals(False, B, 'WriteLogoEnabled(False)');
end;

procedure TDaisyPrinterDataTest.TestWriteCutMode;
var
  B: Integer;
begin
  Printer.Check(Printer.WriteCutMode(DFP_CM_NONE));
  Printer.Check(Printer.ReadCutMode(B));
  CheckEquals(DFP_CM_NONE, B, 'WriteCutMode(DFP_CM_NONE)');

  Printer.Check(Printer.WriteCutMode(DFP_CM_FULL));
  Printer.Check(Printer.ReadCutMode(B));
  CheckEquals(DFP_CM_FULL, B, 'WriteCutMode(DFP_CM_FULL)');

  Printer.Check(Printer.WriteCutMode(DFP_CM_PARTIAL));
  Printer.Check(Printer.ReadCutMode(B));
  CheckEquals(DFP_CM_PARTIAL, B, 'WriteCutMode(DFP_CM_PARTIAL)');
end;

procedure TDaisyPrinterDataTest.TestWriteDetailedReceipt;
var
  B: Boolean;
begin
  Printer.Check(Printer.WriteDetailedReceipt(True));
  Printer.Check(Printer.ReadDetailedReceipt(B));
  CheckEquals(True, B, 'WriteDetailedReceipt(True)');

  Printer.Check(Printer.WriteDetailedReceipt(False));
  Printer.Check(Printer.ReadDetailedReceipt(B));
  CheckEquals(False, B, 'WriteDetailedReceipt(False)');
end;

procedure TDaisyPrinterDataTest.TestReadFDVATRates;
var
  P: TDFPDateRange;
  Data: TDFPVATRateResponse;
begin
  P.StartDate := Now;
  P.EndDate := Now;
  Printer.Check(Printer.ReadVATRatesOnDate(P, Data));
end;

procedure TDaisyPrinterDataTest.TestReadText;
var
  i: Integer;
  S: WideString;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    // HEADER line/ FOOTER line
    for i := 40 to 53 do
    begin
      Printer.Check(Printer.ReadText(i, S));
      Lines.Add(WideFormat('%.3d: %s', [i, S]))
    end;
    // name of payment
    for i := 60 to 64 do
    begin
      Printer.Check(Printer.ReadText(i, S));
      Lines.Add(WideFormat('%.3d: %s', [i, S]))
    end;
    // commentary lines
    for i := 600 to 609 do
    begin
      Printer.Check(Printer.ReadText(i, S));
      Lines.Add(WideFormat('%.3d: %s', [i, S]))
    end;
    Lines.SaveToFile('DefaultText.txt');
  finally
    Lines.Free;
  end;
end;

procedure TDaisyPrinterDataTest.TestWriteText;
var
  i: Integer;
begin
  // Header line
  for i := 1 to 8 do
  begin
    Printer.Check(Printer.WriteText(39 + i, 'Header line ' + IntToStr(i)));
  end;
  // Trailer line
  for i := 1 to 6 do
  begin
    Printer.Check(Printer.WriteText(47 + i, 'Trailer line ' + IntToStr(i)));
  end;
(*
  // name of payment
  for i := 60 to 64 do
  begin
    Printer.Check(Printer.WriteText(i, 'Payment line ' + IntToStr(i)));
  end;
*)
  // commentary lines
  for i := 600 to 609 do
  begin
    Printer.Check(Printer.WriteText(i, 'Comment line ' + IntToStr(i)));
  end;
end;

procedure TDaisyPrinterDataTest.TestNumberClicheLines;
var
  i: Integer;
  S: AnsiString;
  ResultCode: Integer;
begin
  // Number of cliche lines: 2..8
  ResultCode := Printer.WriteParameter(DFP_SP_NUM_HEADER_LINES, '1');
  // 21, The value is outside the permissible limits
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_NUM_HEADER_LINES=1)');
  for i := 2 to 8 do
  begin
    Printer.Check(Printer.WriteParameter(DFP_SP_NUM_HEADER_LINES, IntToStr(i)));
    Printer.Check(Printer.ReadParameter(DFP_SP_NUM_HEADER_LINES, S));
    CheckEquals(IntToStr(i), S, 'DFP_SP_NUM_HEADER_LINES=' + IntToStr(i));
  end;
  ResultCode := Printer.WriteParameter(DFP_SP_NUM_HEADER_LINES, '9');
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_NUM_HEADER_LINES=1)');
  ResultCode := Printer.WriteParameter(DFP_SP_NUM_HEADER_LINES, 'ASD');
  // 14, Invalid character in data
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_NUM_HEADER_LINES=ASD)');
  // Default value
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_HEADER_LINES, '3'));
end;

// Number of advertising lines
// Possible values: 0..6
procedure TDaisyPrinterDataTest.TestNumberAdvertizingLines;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 0
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '0'));
  Printer.Check(Printer.ReadParameter(DFP_SP_NUM_TRAILER_LINES, S));
  CheckEquals('0', S, 'DFP_SP_NUM_TRAILER_LINES=0');
  // 1
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '1'));
  Printer.Check(Printer.ReadParameter(DFP_SP_NUM_TRAILER_LINES, S));
  CheckEquals('1', S, 'DFP_SP_NUM_TRAILER_LINES=1');
  // 2
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '2'));
  Printer.Check(Printer.ReadParameter(DFP_SP_NUM_TRAILER_LINES, S));
  CheckEquals('2', S, 'DFP_SP_NUM_TRAILER_LINES=2');
  // 6
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '6'));
  Printer.Check(Printer.ReadParameter(DFP_SP_NUM_TRAILER_LINES, S));
  CheckEquals('6', S, 'DFP_SP_NUM_TRAILER_LINES=6');

  // 21, The value is outside the permissible limits
  ResultCode := Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '7');
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_NUM_TRAILER_LINES=7)');
  Printer.Check(Printer.ReadParameter(DFP_SP_NUM_TRAILER_LINES, S));
  CheckEquals('6', S, 'DFP_SP_NUM_TRAILER_LINES=6');

  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_NUM_TRAILER_LINES=ASD)');
  Printer.Check(Printer.ReadParameter(DFP_SP_NUM_TRAILER_LINES, S));
  CheckEquals('6', S, 'DFP_SP_NUM_TRAILER_LINES=6');

  // Default value
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '1'));
end;

procedure TDaisyPrinterDataTest.TestPrintOptions;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 1111
  Printer.Check(Printer.WriteParameter(DFP_SP_PRINT_OPTIONS, '1111'));
  Printer.Check(Printer.ReadParameter(DFP_SP_PRINT_OPTIONS, S));
  CheckEquals('1111', S, 'DFP_SP_PRINT_OPTIONS=1111');
  // 0000
  Printer.Check(Printer.WriteParameter(DFP_SP_PRINT_OPTIONS, '0000'));
  Printer.Check(Printer.ReadParameter(DFP_SP_PRINT_OPTIONS, S));
  CheckEquals('0000', S, 'DFP_SP_PRINT_OPTIONS=0000');

  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_PRINT_OPTIONS, '2222');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_PRINT_OPTIONS=2222)');

  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_PRINT_OPTIONS, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_PRINT_OPTIONS=ASD)');
end;

procedure TDaisyPrinterDataTest.TestDetailedPrint;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  Printer.Check(Printer.WriteParameter(DFP_SP_DETAILED_PRINT, '1'));
  Printer.Check(Printer.ReadParameter(DFP_SP_DETAILED_PRINT, S));
  CheckEquals('11', S, 'DFP_SP_DETAILED_PRINT=1'); // ???

  Printer.Check(Printer.WriteParameter(DFP_SP_DETAILED_PRINT, '0'));
  Printer.Check(Printer.ReadParameter(DFP_SP_DETAILED_PRINT, S));
  CheckEquals('00', S, 'DFP_SP_DETAILED_PRINT=0'); // ???

  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_DETAILED_PRINT, '2');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_DETAILED_PRINT=2)');

  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_DETAILED_PRINT, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_DETAILED_PRINT=ASD)');
end;

// 1..6
procedure TDaisyPrinterDataTest.TestHeaderType;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_HEADER_TYPE, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_HEADER_TYPE=ASD)');

  Printer.Check(Printer.WriteParameter(DFP_SP_HEADER_TYPE, '00000000'));
  Printer.Check(Printer.ReadParameter(DFP_SP_HEADER_TYPE, S));
  CheckEquals('00000000', S, 'DFP_SP_HEADER_TYPE=00000000');

  Printer.Check(Printer.WriteParameter(DFP_SP_HEADER_TYPE, '01010101'));
  Printer.Check(Printer.ReadParameter(DFP_SP_HEADER_TYPE, S));
  CheckEquals('01010101', S, 'DFP_SP_HEADER_TYPE=00000000');

  Printer.Check(Printer.WriteParameter(DFP_SP_HEADER_TYPE, '11111111'));
  Printer.Check(Printer.ReadParameter(DFP_SP_HEADER_TYPE, S));
  CheckEquals('11111111', S, 'DFP_SP_HEADER_TYPE=11111111');
end;

//07,111111, Trailer type
procedure TDaisyPrinterDataTest.TestTrailerType;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_TRAILER_TYPE, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_TRAILER_TYPE=ASD)');

  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_TYPE, '000000'));
  Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_TYPE, S));
  CheckEquals('000000', S, 'DFP_SP_TRAILER_TYPE=000000');

  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_TYPE, '010101'));
  Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_TYPE, S));
  CheckEquals('010101', S, 'DFP_SP_TRAILER_TYPE=010101');

  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_TYPE, '111111'));
  Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_TYPE, S));
  CheckEquals('111111', S, 'DFP_SP_TRAILER_TYPE=111111');
end;

procedure TDaisyPrinterDataTest.TestSaveParameters;
var
  i: Integer;
  S: AnsiString;
  Lines: TStrings;
begin

  Lines := TStringList.Create;
  try
    for i := DFP_SP_MIN to DFP_SP_MAX do
    begin
      Printer.Check(Printer.ReadParameter(i, S));
      Lines.Add(Format('%.2d,%s, %s', [i, S, GetParameterName(i)]));
    end;
    Lines.SaveToFile('Parameters.txt');
  finally
    Lines.Free;
  end;
end;

procedure TDaisyPrinterDataTest.TestPrinterNumber;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_PRINTER_NUMBER, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_PRINTER_NUMBER=ASD)');

  // 21, The value is outside the permissible limits
  ResultCode := Printer.WriteParameter(DFP_SP_PRINTER_NUMBER, '0');
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_PRINTER_NUMBER=0)');

  Printer.Check(Printer.WriteParameter(DFP_SP_PRINTER_NUMBER, '99'));
  Printer.Check(Printer.ReadParameter(DFP_SP_PRINTER_NUMBER, S));
  CheckEquals('99', S, 'DFP_SP_PRINTER_NUMBER=99');

  Printer.Check(Printer.WriteParameter(DFP_SP_PRINTER_NUMBER, '1'));
  Printer.Check(Printer.ReadParameter(DFP_SP_PRINTER_NUMBER, S));
  CheckEquals('01', S, 'DFP_SP_PRINTER_NUMBER=1');
end;

procedure TDaisyPrinterDataTest.TestSystemFont;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_SYSTEM_FONT, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_SYSTEM_FONT=ASD)');

  // 21, The value is outside the permissible limits
  ResultCode := Printer.WriteParameter(DFP_SP_SYSTEM_FONT, '2');
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_SYSTEM_FONT=2)');

  Printer.Check(Printer.WriteParameter(DFP_SP_SYSTEM_FONT, '0'));
  Printer.Check(Printer.ReadParameter(DFP_SP_SYSTEM_FONT, S));
  CheckEquals('0', S, 'DFP_SP_SYSTEM_FONT=0');

  Printer.Check(Printer.WriteParameter(DFP_SP_SYSTEM_FONT, '1'));
  Printer.Check(Printer.ReadParameter(DFP_SP_SYSTEM_FONT, S));
  CheckEquals('1', S, 'DFP_SP_SYSTEM_FONT=1');
end;

procedure TDaisyPrinterDataTest.TestTrailerLogo;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  // 14, Invalid character in data
  ResultCode := Printer.WriteParameter(DFP_SP_TRAILER_LOGO, 'ASD');
  CheckEquals(14, ResultCode, 'WriteParameter(DFP_SP_TRAILER_LOGO=ASD)');

  // 21, The value is outside the permissible limits
  ResultCode := Printer.WriteParameter(DFP_SP_TRAILER_LOGO, '200');
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_TRAILER_LOGO=200)');

  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_LOGO, '1'));
  Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_LOGO, S));
  CheckEquals('001', S, 'DFP_SP_TRAILER_LOGO=1');

  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_LOGO, '144'));
  Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_LOGO, S));
  CheckEquals('144', S, 'DFP_SP_TRAILER_LOGO=144');

  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_LOGO, '0'));
  Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_LOGO, S));
  CheckEquals('000', S, 'DFP_SP_TRAILER_LOGO=0');
end;

// 576,144,5,5,,, ,8,48,44,32,10,10,0,15,50,30000,1,1,0,20,12,0,0,0,0
procedure TDaisyPrinterDataTest.TestReadConstants;
var
  Data: TDFPConstants;
begin
  Printer.Check(Printer.ReadConstants(Data));
  CheckEquals(576, Data.MaxLogoWidth, 'MaxLogoWidth');
  CheckEquals(144, Data.MaxLogoHeight, 'MaxLogoHeight');
  CheckEquals(5, Data.NumPaymentTypes, 'NumPaymentTypes');
  CheckEquals(5, Data.NumVATRate, 'NumVATRate');
  CheckEquals('', Data.TaxFreeLetter, 'TaxFreeLetter');
  CheckEquals(' ', Data.VATRate1Letter, 'VATRate1Letter');
  CheckEquals(8, Data.Dimension, 'Dimension');
  CheckEquals(48, Data.DescriptionLength, 'DescriptionLength');
  CheckEquals(44, Data.MessageLength, 'MessageLength');
  CheckEquals(32, Data.NameLength, 'NameLength');
  CheckEquals(10, Data.MRCLength, 'MRCLength');
  CheckEquals(10, Data.FMNumberLength, 'FMNumberLength');
  CheckEquals(15, Data.REGNOLength, 'REGNOLength');
  CheckEquals(50, Data.DepartmentsNumber, 'DepartmentsNumber');
  CheckEquals(30000, Data.PLUNumber, 'PLUNumber');
  CheckEquals(0, Data.NumberOfStockGroups, 'NumberOfStockGroups');
  CheckEquals(20, Data.OperatorsNumber, 'OperatorsNumber');
  CheckEquals(12, Data.PaymentNameLength, 'PaymentNameLength');
end;

procedure TDaisyPrinterDataTest.TestReadOperator1;
var
  Strings: TTntStrings;
  Operator: TDFPOperator;
  OperatorName: WideString;
begin
  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('Operators.txt');
    OperatorName := Strings[0];
  finally
    Strings.Free;
  end;
  Printer.Check(Printer.ReadOperator(1, Operator));
  CheckEquals(1, Operator.Number, 'Operator.Number');
  CheckEquals(0, Operator.NumReceipts, 'Operator.NumReceipts');
  CheckEquals(0, Operator.TotalNum, 'Operator.TotalNum');
  CheckEquals(0, Operator.TotalAmount, 0.01, 'Operator.TotalAmount');
  CheckEquals(0, Operator.DiscountNum, 'Operator.DiscountNum');
  CheckEquals(0, Operator.DiscountAmount, 'Operator.DiscountAmount');
  CheckEquals(0, Operator.SurchargeNum, 'Operator.SurchargeNum');
  CheckEquals(0, Operator.SurchargeAmount, 'Operator.SurchargeAmount');
  CheckEquals(0, Operator.VoidNum, 'Operator.VoidNum');
  CheckEquals(0, Operator.VoidAmount, 'Operator.VoidAmount');
  CheckEquals(OperatorName, Operator.Name, 'Operator.Name');
end;


procedure TDaisyPrinterDataTest.TestReadOperatorNames;
var
  i: Integer;
  Lines: TTntStrings;
  Data: TDFPConstants;
  Operator: TDFPOperator;
begin
  Lines := TTntStringList.Create;
  try
    Printer.Check(Printer.ReadConstants(Data));
    for i := 1 to Data.OperatorsNumber do
    begin
      Printer.Check(Printer.ReadOperator(i, Operator));
      Lines.Add(Operator.Name);
    end;
    Lines.SaveToFile('Operators.txt');
  finally
    Lines.Free;
  end;
end;

procedure TDaisyPrinterDataTest.TestWriteOperatorName;
var
  P: TDFPOperatorName;
  Operator: TDFPOperator;
  Operator2: TDFPOperator;
begin
  Printer.Check(Printer.ReadOperator(1, Operator));

  P.Number := 1;
  P.Password := DFP_OPERATOR_PASSWORD_1;
  P.Name := Operator.Name;
  Printer.Check(Printer.WriteOperatorName(P));

  Printer.Check(Printer.ReadOperator(1, Operator2));
  CheckEquals(Operator.Name, Operator2.Name, 'Operator.Name');
end;

procedure TDaisyPrinterDataTest.TestReadReceiptStatus;
var
  R: TDFPReceiptStatus;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.ReadReceiptStatus(R));
  CheckEquals(False, R.CanVoid, 'CanVoid');
  CheckEquals(0, R.TaxFreeTotal, 'TaxFreeTotal');
  CheckEquals(0, R.Tax1Total, 'Tax1Total');
  CheckEquals(0, R.Tax2Total, 'Tax2Total');
  CheckEquals(0, R.Tax3Total, 'Tax3Total');
  CheckEquals(0, R.Tax4Total, 'Tax4Total');
  CheckEquals(False, R.InvoiceFlag, 'InvoiceFlag');
  CheckEquals('', R.InvoiceNo, 'InvoiceNo');
end;

procedure TDaisyPrinterDataTest.TestReadReadDayStatus;
var
  DocNo: Integer;
  R: TDFPDayStatus;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.ReadLastDocNo(DocNo));
  Printer.Check(Printer.ReadDayStatus(R));
  CheckEquals(0, R.CashTotal, 'CashTotal');
  CheckEquals(0, R.Pay1Total, 'Pay1Total');
  CheckEquals(0, R.Pay2Total, 'Pay2Total');
  CheckEquals(0, R.Pay3Total, 'Pay3Total');
  CheckEquals(0, R.Pay4Total, 'Pay4Total');
  CheckEquals(0, R.ZRepNo, 'ZRepNo');
  CheckEquals(DocNo+1, R.DocNo, 'DocNo'); // !!!
  CheckEquals(0, R.InvoiceNo, 'InvoiceNo');
end;

// 202, Invalid command code
procedure TDaisyPrinterDataTest.TestWriteFiscalNumber;
begin
  Printer.Check(Printer.Reset);
  CheckEquals(202, Printer.WriteFiscalNumber('1887612837'), 'WriteFiscalNumber');
end;

// 205, Command is invalid in this mode
procedure TDaisyPrinterDataTest.TestFinalFiscalRecord;
var
  R: TDFPFiscalRecord;
begin
  Printer.Check(Printer.Reset);
  CheckEquals(205, Printer.FinalFiscalRecord('N', R), 'FinalFiscalRecord');
end;

procedure TDaisyPrinterDataTest.TestSetBaudRate;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.WriteIntParameter(DFP_SP_RS_BAUDRATE, DFP_BR_9600));
  Printer.Check(Printer.Reset);
end;

initialization
  RegisterTest('', TDaisyPrinterDataTest.Suite);

end.
