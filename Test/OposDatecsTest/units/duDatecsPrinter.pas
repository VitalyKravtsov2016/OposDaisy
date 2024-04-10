unit duDatecsPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics, DateUtils,
  // Tnt
  TntGraphics, TntClasses,
  // DUnit
  TestFramework,
  // This
  DatecsPrinter2, LogFile, SerialPort, FileUtils, PrinterPort, SocketPort,
  StringUtils;

type
  { TDatecsPrinterTest }

  TDatecsPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FPrinter: TDatecsPrinter;
    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;

    property Printer: TDatecsPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadWriteDate;
    procedure TestPrintDiagnosticInfo;
    procedure TestReadDiagnosticInfo;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscalReceipt;
    procedure TestFiscalReceipt;
    procedure TestReadStatus;
    procedure TestResetNonfiscalReceipt;
  end;

implementation

{ TDatecsPrinterTest }

procedure TDatecsPrinterTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  FPort := CreateSerialPort;
  FPrinter := TDatecsPrinter.Create(FPort, FLogger);
end;

procedure TDatecsPrinterTest.TearDown;
begin
  FPort := nil;
  FLogger := nil;
  FPrinter.Free;
  FPrinter := nil;
end;

function TDatecsPrinterTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM4';
  SerialParams.BaudRate := 19200;
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

function TDatecsPrinterTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TDatecsPrinterTest.TestPrintDiagnosticInfo;
begin
  Printer.Check(Printer.PrintDiagnosticInfo);
end;

procedure TDatecsPrinterTest.TestReadWriteDate;
var
  Date: TDateTime;
  Seconds: Integer;
  Response: TDateTimeResponse;
  Hour, Min, Sec, MSec: Word;
begin
  Date := Now;
  Printer.Check(Printer.WriteDateTime(Date));
  Response := Printer.ReadDateTime;
  Printer.Check(Response.ResultCode);
  Seconds := Abs(SecondsBetween(Date, Response.Date));
  Check(Seconds <= 60, 'Seconds > 60, ' + IntToStr(Seconds));
  // Seconds are not set
  DecodeTime(Response.Date, Hour, Min, Sec, MSec);
  Check(Sec <= 1, 'Sec > 1, ' + IntToStr(Sec));
end;

procedure TDatecsPrinterTest.TestReadDiagnosticInfo;
var
  Data: TDiagnosticInfo;
begin
  Data := Printer.GetDiagnosticInfo(False);
  Printer.Check(Data.ResultCode);
  CheckEquals('FX1300-11.00GE', Data.FirmwareVersion, 'FirmwareVersion');
  CheckEquals('27-10-2017', Data.FirmwareDate, 'FirmwareDate');
  CheckEquals('09:22', Data.FirmwareTime, 'FirmwareTime');
  CheckEquals('643A', Data.ChekSum, 'ChekSum');
  CheckEquals(0, Data.Switches, 'Switches');
  CheckEquals(8, Data.Country, 'Country');
  CheckEquals('', Data.FDSerial, 'FDSerial');
  CheckEquals('', Data.FDNo, 'FDNo');
end;

procedure TDatecsPrinterTest.TestXReport;
var
  Data: TFDReportAnswer;
begin
  Printer.Check(Printer.Reset);
  
  Data := Printer.XReport;
  Printer.Check(Data.ResultCode);
  CheckEquals(0, Data.ReportNumber, 'Data.ReportNumber <> 0');
  CheckEquals(0, Data.SalesTotalTaxFree, 'SalesTotalTaxFree');
  CheckEquals(0, Data.SalesTotalTax[1], 'SalesTotalTax[1]');
  CheckEquals(0, Data.SalesTotalTax[2], 'SalesTotalTax[2]');
  CheckEquals(0, Data.SalesTotalTax[3], 'SalesTotalTax[3]');
  CheckEquals(0, Data.SalesTotalTax[4], 'SalesTotalTax[4]');
  CheckEquals(0, Data.SalesTotalTax[5], 'SalesTotalTax[5]');
end;

procedure TDatecsPrinterTest.TestZReport;
var
  Data: TFDReportAnswer;
begin
  Printer.Check(Printer.Reset);

  Data := Printer.ZReport;
  Printer.Check(Data.ResultCode);
  CheckEquals(0, Data.ReportNumber, 'Data.ReportNumber <> 0');
  CheckEquals(0, Data.SalesTotalTaxFree, 'SalesTotalTaxFree');
  CheckEquals(0, Data.SalesTotalTax[1], 'SalesTotalTax[1]');
  CheckEquals(0, Data.SalesTotalTax[2], 'SalesTotalTax[2]');
  CheckEquals(0, Data.SalesTotalTax[3], 'SalesTotalTax[3]');
  CheckEquals(0, Data.SalesTotalTax[4], 'SalesTotalTax[4]');
  CheckEquals(0, Data.SalesTotalTax[5], 'SalesTotalTax[5]');
end;

procedure TDatecsPrinterTest.TestNonFiscalReceipt;
const
  StatusNormal = '80 80 C0 80 80 90';
  StatusNonFiscal = '80 80 A0 80 80 90';
begin
  Printer.Check(Printer.Reset);
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.1');
  CheckEquals(False, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.1');

  Printer.Check(Printer.StartNonfiscalReceipt.ResultCode);
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.2');

  Printer.Check(Printer.PrintNonfiscalText('NONFISCAL RECEIPT 1'));
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.2');

  Printer.Check(Printer.PrintNonfiscalText('NONFISCAL RECEIPT 2'));
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.2');

  Printer.Check(Printer.EndNonfiscalReceipt.ResultCode);
  CheckEquals(False, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.3');
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.1');
end;

procedure TDatecsPrinterTest.TestResetNonfiscalReceipt;
const
  StatusNormal = '80 80 C0 80 80 90';
  StatusNonFiscal = '80 80 A0 80 80 90';
begin
  Printer.Check(Printer.Reset);
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.1');
  CheckEquals(False, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.1');

  Printer.Check(Printer.StartNonfiscalReceipt.ResultCode);
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.2');

  Printer.Check(Printer.Reset);
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.2');
  CheckEquals(False, Printer.Status.NonfiscalRecOpened, 'NonfiscalRecOpened.3');
end;

procedure TDatecsPrinterTest.TestFiscalReceipt;
var
  SaleRequest: TFDSale;
  StartRequest: TFDStartRec;
  StartResponse: TFDReceiptNumber;
  SubtotalRequest: TFDSubtotal;
  TotalRequest: TFDTotal;
  EndResponse: TFDReceiptNumber;
const
  StatusNormal = '80 80 C0 80 80 90';
  StatusFiscal = 'A0 80 C0 C2 80 90';
begin
  Printer.Check(Printer.Reset);

  StartRequest.Operator := 1;
  StartRequest.Password := '0001';
  StartResponse := Printer.StartFiscalReceipt(StartRequest);
  Printer.Check(StartResponse.ResultCode);
  CheckEquals(True, Printer.Status.FiscalRecOpened, 'FiscalRecOpened.1');

  Printer.Check(Printer.PrintFiscalText('FISCAL TEXT 1'));

  SaleRequest.Text1 := 'Sale text 1';
  SaleRequest.Text2 := 'Sale text 2';
  SaleRequest.Tax := 1;
  SaleRequest.Price := 1.23;
  SaleRequest.Quantity := 1;
  SaleRequest.DiscountPercent := 0;
  SaleRequest.DiscountAmount := 0;
  Printer.Check(Printer.Sale(SaleRequest));

  SubtotalRequest.PrintSubtotal := True;
  SubtotalRequest.DisplaySubtotal := True;
  SubtotalRequest.SubtotalPercent := 0;
  Printer.Check(Printer.Subtotal(SubtotalRequest).ResultCode);

  TotalRequest.Text1 := 'TOTAL TEXT 1';
  TotalRequest.Text2 := 'TOTAL TEXT 2';
  TotalRequest.PaymentMode := PaymentModeCash;
  TotalRequest.Amount := 1.23;
  Printer.Check(Printer.PrintTotal(TotalRequest).ResultCode);

  EndResponse := Printer.EndFiscalReceipt;
  Printer.Check(EndResponse.ResultCode);
  CheckEquals(StartResponse.DocNumber + 1, EndResponse.DocNumber, 'DocNumber');
  CheckEquals(StartResponse.FDNumber + 1, EndResponse.FDNumber, 'FDNumber');
end;


procedure TDatecsPrinterTest.TestReadStatus;
begin
  Printer.Check(Printer.ReadStatus);
  CheckEquals(False, Printer.Status.GeneralError, 'GeneralError');
  CheckEquals(False, Printer.Status.PrinterError, 'PrinterError');
  CheckEquals(False, Printer.Status.DisplayDisconnected, 'DisplayDisconnected');
  CheckEquals(False, Printer.Status.ClockNotSet, 'ClockNotSet');
  CheckEquals(False, Printer.Status.InvalidCommandCode, 'InvalidCommandCode');
  CheckEquals(False, Printer.Status.InvalidDataSyntax, 'InvalidDataSyntax');
end;

(*
Оператор 1 - 1;
Оператор 2 - 2;
Оператор 3 - 3’
Оператор 4 - 4’
Оператор 5 - 5;
Оператор 6 - 6;
Оператор 7 - 7;
Оператор 8 - 8;
Оператор 9 - 9;
Оператор 10 - 10;
Оператор 11 - 11;
Оператор 12 - 12;
Оператор 13 - 13;
Оператор 14 - 14;
Оператор 15 - 15;
Оператор 16 - 16;
Оператор 17 - 17;
Оператор 18 - 18;
Оператор 19 - 8888;
Оператор 20 - 9999.
*)

initialization
  RegisterTest('', TDatecsPrinterTest.Suite);

end.
