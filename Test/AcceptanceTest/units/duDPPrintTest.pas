unit duDPPrintTest;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics, DateUtils,
  // Tnt
  TntGraphics, TntClasses,
  // DUnit
  TestFramework,
  // This
  DaisyPrinter, DaisyPrinterInterface, LogFile, SerialPort, FileUtils,
  PrinterPort, SocketPort, StringUtils, DebugUtils;

type
  TPayments = array [DFP_PM_MIN..DFP_PM_MAX] of Currency;

  { TDaisyPrinterPrintTest }

  TDaisyPrinterPrintTest = class(TTestCase)
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
    procedure PrintFiscalReceipt(Total: Currency; Payments: TPayments);
  published
    procedure TestLoadLogo;
    procedure TestPrintDiagnosticInfo;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscalReceipt;
    procedure TestFiscalReceipt;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestResetNonfiscalReceipt;
    procedure TestPrintVATRates;
    procedure TestPrintParameters;
    procedure TestPrintBarcode;
    procedure TestPrintBarcode2;
    procedure TestPrintCash;
    procedure TestPrintCash2;
    procedure TestHeaderAndTrailer;
    procedure TestDuplicatePrint;
    procedure TestReadVATRates;
    procedure TestWriteDecimalPoint;
  end;

implementation

{ TDaisyPrinterPrintTest }

procedure TDaisyPrinterPrintTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  FPort := CreateSerialPort;
  FPrinter := TDaisyPrinter.Create(FPort, FLogger);
end;

procedure TDaisyPrinterPrintTest.TearDown;
begin
  FPort := nil;
  FLogger := nil;
  FPrinter.Free;
  FPrinter := nil;
end;

function TDaisyPrinterPrintTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM6';
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

function TDaisyPrinterPrintTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TDaisyPrinterPrintTest.TestPrintDiagnosticInfo;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.PrintDiagnosticInfo);
end;

procedure TDaisyPrinterPrintTest.TestXReport;
var
  Data: TDFPReportAnswer;
begin
  Printer.Check(Printer.Reset);
  
  Printer.Check(Printer.XReport(Data));
  CheckEquals(0, Data.ReportNumber, 'Data.ReportNumber <> 0');
  CheckEquals(0, Data.SalesTotalTaxFree, 'SalesTotalTaxFree');
  CheckEquals(0, Data.SalesTotalTax[1], 'SalesTotalTax[1]');
  CheckEquals(0, Data.SalesTotalTax[2], 'SalesTotalTax[2]');
  CheckEquals(0, Data.SalesTotalTax[3], 'SalesTotalTax[3]');
  CheckEquals(0, Data.SalesTotalTax[4], 'SalesTotalTax[4]');
  CheckEquals(0, Data.SalesTotalTax[5], 'SalesTotalTax[5]');
end;

procedure TDaisyPrinterPrintTest.TestZReport;
var
  Data: TDFPReportAnswer;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.ZReport(Data));
(*
  CheckEquals(0, Data.ReportNumber, 'Data.ReportNumber <> 0');
  CheckEquals(0, Data.SalesTotalTaxFree, 'SalesTotalTaxFree');
  CheckEquals(0, Data.SalesTotalTax[1], 'SalesTotalTax[1]');
  CheckEquals(0, Data.SalesTotalTax[2], 'SalesTotalTax[2]');
  CheckEquals(0, Data.SalesTotalTax[3], 'SalesTotalTax[3]');
  CheckEquals(0, Data.SalesTotalTax[4], 'SalesTotalTax[4]');
  CheckEquals(0, Data.SalesTotalTax[5], 'SalesTotalTax[5]');
*)
end;

procedure TDaisyPrinterPrintTest.TestLoadLogo;
var
  Picture: TPicture;
begin
  Printer.Check(Printer.Connect);
  Picture := TPicture.Create;
  try

    //Picture.LoadFromFile(GetModulePath + 'Logo\ShtrihM.bmp');
    //Picture.LoadFromFile(GetModulePath + 'Logo\Adidas.bmp');
    //Picture.LoadFromFile(GetModulePath + 'Logo\test.png');
    Picture.LoadFromFile(GetModulePath + 'Logo\Globus.bmp');
    Printer.Check(Printer.LoadLogo(Picture.Graphic));
    Printer.Check(Printer.WriteLogoEnabled(True));
  finally
    Picture.Free;
  end;
end;

procedure TDaisyPrinterPrintTest.TestNonFiscalReceipt;
const
  StatusNormal = '80 80 C0 80 80 90';
  StatusNonFiscal = '80 80 A0 80 80 90';
var
  RecNumber: Integer;
  Strings: TTntStrings;
  GeorgianText: WideString;
begin
  GeorgianText := '';
  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('GeorgianText.txt');
    GeorgianText := Strings[0];
  finally
    Strings.Free;
  end;

  Printer.Check(Printer.Reset);
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.1');
  CheckEquals(False, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.1');

  Printer.Check(Printer.StartNonfiscalReceipt(RecNumber));
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.2');

  Printer.Check(Printer.PrintNonfiscalText('NONFISCAL RECEIPT 1'));
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.2');

  Printer.Check(Printer.PrintNonfiscalText(GeorgianText));
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.2');

  Printer.Check(Printer.PrintNonfiscalText('EAN8'));
  Printer.Check(Printer.PrintBarcode('1,1123234'));

  Printer.Check(Printer.EndNonfiscalReceipt(RecNumber));
  CheckEquals(False, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.3');
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.1');
end;

procedure TDaisyPrinterPrintTest.TestResetNonfiscalReceipt;
const
  StatusNormal = '80 80 C0 80 80 90';
  StatusNonFiscal = '80 80 A0 80 80 90';
var
  RecNumber: Integer;
begin
  Printer.Check(Printer.Reset);
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.1');
  CheckEquals(False, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.1');

  Printer.Check(Printer.StartNonfiscalReceipt(RecNumber));
  CheckEquals(StatusNonFiscal, StrToHex(Printer.Status.Data), 'StatusNonFiscal.1');
  CheckEquals(True, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.2');

  Printer.Check(Printer.Reset);
  CheckEquals(StatusNormal, StrToHex(Printer.Status.Data), 'StatusNormal.2');
  CheckEquals(False, Printer.Status.NonfiscalOpened, 'NonfiscalOpened.3');
end;

procedure TDaisyPrinterPrintTest.PrintFiscalReceipt(Total: Currency; Payments: TPayments);
var
  i: integer;
  SaleRequest: TDFPSale;
  RecNumber: TDFPRecNumber;
  Operator: TDFPOperatorPassword;
  TotalRequest: TDFPTotal;
  TotalResponse: TDFPTotalResponse;
  EndResponse: TDFPRecNumber;
begin
  Printer.Check(Printer.Reset);

  Operator.Number := 1;
  Operator.Password := 1;
  Printer.Check(Printer.StartFiscalReceipt(Operator, RecNumber));
  CheckEquals(True, Printer.Status.FiscalOpened, 'FiscalOpened.1');
  // Sale
  SaleRequest.Text1 := 'Sale text 1';
  SaleRequest.Text2 := '';
  SaleRequest.Tax := 1;
  SaleRequest.Price := Total;
  SaleRequest.Quantity := 1;
  SaleRequest.DiscountPercent := 0;
  SaleRequest.DiscountAmount := 0;
  Printer.Check(Printer.Sale(SaleRequest));
  // Payments
  for i := Low(Payments) to High(Payments) do
  begin
    TotalRequest.Text1 := '';
    TotalRequest.Text2 := '';
    TotalRequest.PaymentMode := i;
    TotalRequest.Amount := Payments[i];
    Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  end;
  // EndFiscalReceipt
  Printer.Check(Printer.EndFiscalReceipt(EndResponse));
end;

procedure TDaisyPrinterPrintTest.TestFiscalReceipt;
const
  StatusNormal = '80 80 C0 80 80 90';
  StatusFiscal = 'A0 80 C0 C2 80 90';
var
  SaleRequest: TDFPSale;
  RecNumber: TDFPRecNumber;
  Operator: TDFPOperatorPassword;
  TotalRequest: TDFPTotal;
  TotalResponse: TDFPTotalResponse;
  EndResponse: TDFPRecNumber;
  GeorgianText: WideString;
  Strings: TTntStringList;
  RecStatus: TDFPReceiptStatus;
begin
  GeorgianText := '';
  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('GeorgianText.txt');
    GeorgianText := Strings[0];
  finally
    Strings.Free;
  end;

  Printer.Check(Printer.Reset);

  Operator.Number := 1;
  Operator.Password := 1;
  Printer.Check(Printer.StartFiscalReceipt(Operator, RecNumber));
  CheckEquals(True, Printer.Status.FiscalOpened, 'FiscalOpened.1');

  Printer.Check(Printer.PrintFiscalText('FISCAL TEXT 1'));

  SaleRequest.Text1 := 'Sale text 1';
  SaleRequest.Text2 := GeorgianText;
  SaleRequest.Tax := 1;
  SaleRequest.Price := 1.23;
  SaleRequest.Quantity := 1;
  SaleRequest.DiscountPercent := -2.34;
  SaleRequest.DiscountAmount := 0;
  Printer.Check(Printer.Sale(SaleRequest));

  // Receipt status
  Printer.Check(Printer.ReadReceiptStatus(RecStatus));
  CheckEquals(True, RecStatus.CanVoid, 'CanVoid');
  CheckEquals(0, RecStatus.TaxFreeTotal, 'TaxFreeTotal');
  CheckEquals(1.20, RecStatus.Tax1Total, 'Tax1Total');
  CheckEquals(0, RecStatus.Tax2Total, 'Tax2Total');
  CheckEquals(0, RecStatus.Tax3Total, 'Tax3Total');
  CheckEquals(0, RecStatus.Tax4Total, 'Tax4Total');
  CheckEquals(0, RecStatus.Tax5Total, 'Tax5Total');
  CheckEquals(False, RecStatus.InvoiceFlag, 'InvoiceFlag');
  CheckEquals('', RecStatus.InvoiceNo, 'InvoiceNo');
  // Payment1
  TotalRequest.Text1 := 'PAYMENT1';
  TotalRequest.Text2 := GeorgianText;
  TotalRequest.PaymentMode := DFP_PM_MODE1;
  TotalRequest.Amount := 0.01;
  Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  // Payment2
  TotalRequest.Text1 := 'PAYMENT2';
  TotalRequest.Text2 := '';
  TotalRequest.PaymentMode := DFP_PM_MODE2;
  TotalRequest.Amount := 0.01;
  Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  // Payment3
  TotalRequest.Text1 := 'PAYMENT3';
  TotalRequest.Text2 := '';
  TotalRequest.PaymentMode := DFP_PM_MODE3;
  TotalRequest.Amount := 0.01;
  Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  // Payment4
  TotalRequest.Text1 := 'PAYMENT4';
  TotalRequest.Text2 := '';
  TotalRequest.PaymentMode := DFP_PM_MODE4;
  TotalRequest.Amount := 0.01;
  Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  // Cash payment
  TotalRequest.Text1 := 'CASH PAYMENT';
  TotalRequest.Text2 := '';
  TotalRequest.PaymentMode := DFP_PM_CASH;
  TotalRequest.Amount := 1.23;
  Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  // Receipt status
  Printer.Check(Printer.ReadReceiptStatus(RecStatus));
  CheckEquals(False, RecStatus.CanVoid, 'CanVoid');
  CheckEquals(0, RecStatus.TaxFreeTotal, 'TaxFreeTotal');
  CheckEquals(1.20, RecStatus.Tax1Total, 'Tax1Total');
  CheckEquals(0, RecStatus.Tax2Total, 'Tax2Total');
  CheckEquals(0, RecStatus.Tax3Total, 'Tax3Total');
  CheckEquals(0, RecStatus.Tax4Total, 'Tax4Total');
  CheckEquals(0, RecStatus.Tax5Total, 'Tax5Total');
  CheckEquals(False, RecStatus.InvoiceFlag, 'InvoiceFlag');
  CheckEquals('', RecStatus.InvoiceNo, 'InvoiceNo');
  // EndFiscalReceipt
  Printer.Check(Printer.EndFiscalReceipt(EndResponse));
  CheckEquals(RecNumber.DocNumber + 1, EndResponse.DocNumber, 'DocNumber');
  CheckEquals(RecNumber.RecNumber + 1, EndResponse.RecNumber, 'RecNumber');
end;

procedure TDaisyPrinterPrintTest.TestFiscalReceipt2;
var
  SaleRequest: TDFPSale;
  RecNumber: TDFPRecNumber;
  Operator: TDFPOperatorPassword;
  TotalRequest: TDFPTotal;
  TotalResponse: TDFPTotalResponse;
  EndResponse: TDFPRecNumber;
  Subtotal: TDFPSubtotal;
  SubtotalResponse: TDFPSubtotalResponse;
begin
  Printer.Check(Printer.Reset);

  Operator.Number := 1;
  Operator.Password := 1;
  Printer.Check(Printer.StartFiscalReceipt(Operator, RecNumber));
  // Sale
  SaleRequest.Text1 := 'Sale text 1';
  SaleRequest.Text2 := '';
  SaleRequest.Tax := 1;
  SaleRequest.Price := 1.23;
  SaleRequest.Quantity := 1;
  SaleRequest.DiscountPercent := 0;
  SaleRequest.DiscountAmount := -0.03;
  Printer.Check(Printer.Sale(SaleRequest));
  // Sale void
  SaleRequest.Text1 := 'Sale void 1';
  SaleRequest.Text2 := '';
  SaleRequest.Tax := 1;
  SaleRequest.Price := -1.23;
  SaleRequest.Quantity := 1;
  SaleRequest.DiscountPercent := 0;
  SaleRequest.DiscountAmount := -0.03;
  Printer.Check(Printer.Sale(SaleRequest));
  // Subtotal -5%
  Subtotal.PrintSubtotal := True;
  Subtotal.DisplaySubtotal := False;
  Subtotal.AdjustmentPercent := -5.00;
  Printer.Check(Printer.Subtotal(Subtotal, SubtotalResponse));
  // Subtotal -3%
  Subtotal.PrintSubtotal := True;
  Subtotal.DisplaySubtotal := False;
  Subtotal.AdjustmentPercent := -3.00;
  CheckEquals(22, Printer.Subtotal(Subtotal, SubtotalResponse), 'Subtotal');
  // Payment
  TotalRequest.Text1 := '';
  TotalRequest.Text2 := '';
  TotalRequest.PaymentMode := DFP_PM_CASH;
  TotalRequest.Amount := 1.20;
  Printer.Check(Printer.PrintTotal(TotalRequest, TotalResponse));
  // EndFiscalReceipt
  Printer.Check(Printer.EndFiscalReceipt(EndResponse));
end;

procedure TDaisyPrinterPrintTest.TestPrintVATRates;
begin
  Printer.Check(Printer.PrintVATRates);
end;

procedure TDaisyPrinterPrintTest.TestPrintParameters;
begin
  Printer.Check(Printer.PrintParameters);
end;

procedure TDaisyPrinterPrintTest.TestPrintBarcode;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.PrintBarcode('11232345'));
end;

procedure TDaisyPrinterPrintTest.TestPrintBarcode2;
var
  Scale: Integer;
  RecNumber: Integer;
  Barcode: TDFPBarcode;
begin
  Printer.Check(Printer.Reset);
  Printer.Check(Printer.StartNonfiscalReceipt(RecNumber));

  // EAN8, DFP_BP_LEFT
  Printer.Check(Printer.PrintNonfiscalText('EAN8, DFP_BP_LEFT'));
  Barcode.BType := DFP_BT_EAN8;
  Barcode.Data := '1234567';
  Barcode.Position := DFP_BP_LEFT;
  Barcode.Scale := 0;
  Barcode.Heightmm := 10;
  Barcode.Text := True;
  Printer.Check(Printer.PrintBarcode2(Barcode));
  // EAN8, DFP_BP_CENTER
  Printer.Check(Printer.PrintNonfiscalText('EAN8, DFP_BP_CENTER'));
  Barcode.BType := DFP_BT_EAN8;
  Barcode.Data := '1234567';
  Barcode.Position := DFP_BP_CENTER;
  Barcode.Scale := 0;
  Barcode.Heightmm := 10;
  Barcode.Text := True;
  Printer.Check(Printer.PrintBarcode2(Barcode));
  // EAN8, DFP_BP_RIGHT
  Printer.Check(Printer.PrintNonfiscalText('EAN8, DFP_BP_RIGHT'));
  Barcode.BType := DFP_BT_EAN8;
  Barcode.Data := '1234567';
  Barcode.Position := DFP_BP_RIGHT;
  Barcode.Scale := 0;
  Barcode.Heightmm := 10;
  Barcode.Text := True;
  Printer.Check(Printer.PrintBarcode2(Barcode));

  for Scale := 3 to 8 do
  begin
    // EAN8, Scale
    Printer.Check(Printer.PrintNonfiscalText('EAN8, Scale=' + IntToStr(Scale)));
    Barcode.BType := DFP_BT_EAN8;
    Barcode.Data := '1234567';
    Barcode.Position := DFP_BP_CENTER;
    Barcode.Scale := Scale;
    Barcode.Heightmm := 10;
    Barcode.Text := True;
    Printer.Check(Printer.PrintBarcode2(Barcode));
  end;

  Printer.Check(Printer.EndNonfiscalReceipt(RecNumber));
end;

// After Z report
procedure TDaisyPrinterPrintTest.TestPrintCash;
var
  P: TDFPCashRequest;
  R: TDFPCashResponse;
begin
  // CashIn 0
  P.Amount := 0;
  P.Text1 := '';
  P.Text2 := '';
  CheckEquals(21, Printer.PrintCash(P, R), 'PrintCash(0)');
  // CashIn 0.01
  P.Amount := 0.01;
  P.Text1 := 'Text 1';
  P.Text2 := '';
  Printer.Check(Printer.PrintCash(P, R));
  CheckEquals(0.01, R.CashAmount, 'CashAmount');
  CheckEquals(0.01, R.CashInAmount, 'CashInAmount');
  CheckEquals(0, R.CashOutAmount, 'CashOutAmount');
  // CashIn
  P.Amount := 123.45;
  P.Text1 := 'Text 1';
  P.Text2 := 'Text 2';
  Printer.Check(Printer.PrintCash(P, R));
  CheckEquals(123.46, R.CashAmount, 'CashAmount');
  CheckEquals(123.46, R.CashInAmount, 'CashInAmount');
  CheckEquals(0, R.CashOutAmount, 'CashOutAmount');
  // CashOut
  P.Amount := -123.46;
  P.Text1 := 'Text 1';
  P.Text2 := 'Text 2';
  Printer.Check(Printer.PrintCash(P, R));
  CheckEquals(0, R.CashAmount, 'CashAmount');
  CheckEquals(123.46, R.CashInAmount, 'CashInAmount');
  CheckEquals(123.46, R.CashOutAmount, 'CashOutAmount');
end;

procedure TDaisyPrinterPrintTest.TestPrintCash2;
var
  P: TDFPCashRequest;
  R: TDFPCashResponse;
  DayStatus1: TDFPDayStatus;
  DayStatus2: TDFPDayStatus;
begin
  Printer.Check(Printer.Reset);
  // DayStatus1
  Printer.Check(Printer.ReadDayStatus(DayStatus1));
  // CashIn
  P.Text1 := '';
  P.Text2 := '';
  P.Amount := 1.23;
  Printer.Check(Printer.PrintCash(P, R));
  // DayStatus2
  Printer.Check(Printer.ReadDayStatus(DayStatus2));
  CheckEquals(DayStatus1.CashTotal, DayStatus2.CashTotal, 'CashTotal');
  CheckEquals(DayStatus1.Pay1Total, DayStatus2.Pay1Total, 'Pay1Total');
  CheckEquals(DayStatus1.Pay2Total, DayStatus2.Pay2Total, 'Pay2Total');
  CheckEquals(DayStatus1.Pay3Total, DayStatus2.Pay3Total, 'Pay3Total');
  CheckEquals(DayStatus1.Pay4Total, DayStatus2.Pay4Total, 'Pay4Total');
end;

procedure TDaisyPrinterPrintTest.TestHeaderAndTrailer;
var
  i: Integer;
begin
  Printer.Check(Printer.Reset);
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
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_HEADER_LINES, '8'));
  Printer.Check(Printer.WriteParameter(DFP_SP_NUM_TRAILER_LINES, '6'));
  Printer.Check(Printer.WriteParameter(DFP_SP_HEADER_TYPE, '00000000'));
  Printer.Check(Printer.WriteParameter(DFP_SP_TRAILER_TYPE, '000000'));
end;

procedure TDaisyPrinterPrintTest.TestDuplicatePrint;
begin
  Printer.Check(Printer.DuplicatePrint(1,0));
end;

procedure TDaisyPrinterPrintTest.TestReadVATRates;
var
  VATRates: TDFPVATRates;
begin
(*
  // Test values
  VATRates[1] := 12.34;
  VATRates[2] := 23.45;
  VATRates[3] := 34.56;
  VATRates[4] := 45.67;
  VATRates[5] := 56.78;
  Printer.Check(Printer.WriteVATRates(VATRates));
  Printer.Check(Printer.ReadVATRates(VATRates));
  CheckEquals(12.34, VATRates[1], 0.01, 'VATRates[1]');
  CheckEquals(23.45, VATRates[2], 0.01, 'VATRates[2]');
  CheckEquals(34.56, VATRates[3], 0.01, 'VATRates[3]');
  CheckEquals(45.67, VATRates[4], 0.01, 'VATRates[4]');
  CheckEquals(56.78, VATRates[5], 0.01, 'VATRates[5]');
*)
  // Default values
  VATRates[1] := 0;
  VATRates[2] := 18;
  VATRates[3] := 0;
  VATRates[4] := 0;
  VATRates[5] := 0;
  Printer.Check(Printer.WriteVATRates(VATRates));
  Printer.Check(Printer.ReadVATRates(VATRates));
  CheckEquals(0, VATRates[1], 0.01, 'VATRates[1]');
  CheckEquals(18, VATRates[2], 0.01, 'VATRates[2]');
  CheckEquals(0, VATRates[3], 0.01, 'VATRates[3]');
  CheckEquals(0, VATRates[4], 0.01, 'VATRates[4]');
  CheckEquals(0, VATRates[5], 0.01, 'VATRates[5]');
end;

procedure TDaisyPrinterPrintTest.TestWriteDecimalPoint;
var
  S: AnsiString;
  ResultCode: Integer;
begin
  Printer.Check(Printer.Reset);
  // DFP_SP_DECIMAL_POINT
  ResultCode := Printer.WriteParameter(DFP_SP_DECIMAL_POINT, '1');
  CheckEquals(21, ResultCode, 'WriteParameter(DFP_SP_DECIMAL_POINT=1');

  Printer.Check(Printer.WriteParameter(DFP_SP_DECIMAL_POINT, '0'));
  Printer.Check(Printer.ReadParameter(DFP_SP_DECIMAL_POINT, S));
  CheckEquals('0', S, 'DFP_SP_DECIMAL_POINT=0');

  Printer.Check(Printer.WriteParameter(DFP_SP_DECIMAL_POINT, '2'));
  Printer.Check(Printer.ReadParameter(DFP_SP_DECIMAL_POINT, S));
  CheckEquals('2', S, 'DFP_SP_DECIMAL_POINT=2');
end;

procedure TDaisyPrinterPrintTest.TestFiscalReceipt3;
var
  Payments: TPayments;
  DayStatus1: TDFPDayStatus;
  DayStatus2: TDFPDayStatus;
begin
  Printer.Check(Printer.Reset);
  // DayStatus1
  Printer.Check(Printer.ReadDayStatus(DayStatus1));
  // Receipt
  Payments[1] := 1.23;
  Payments[2] := 2.34;
  Payments[3] := 3.45;
  Payments[4] := 4.56;
  Payments[5] := 5.67;
  PrintFiscalReceipt(17.25, Payments);
  // DayStatus2
  Printer.Check(Printer.ReadDayStatus(DayStatus2));
  CheckEquals(DayStatus1.CashTotal + Payments[1], DayStatus2.CashTotal, 'CashTotal');
  CheckEquals(DayStatus1.Pay1Total + Payments[2], DayStatus2.Pay1Total, 'Pay1Total');
  CheckEquals(DayStatus1.Pay2Total + Payments[3], DayStatus2.Pay2Total, 'Pay2Total');
  CheckEquals(DayStatus1.Pay3Total + Payments[4], DayStatus2.Pay3Total, 'Pay3Total');
  CheckEquals(DayStatus1.Pay4Total + Payments[5], DayStatus2.Pay4Total, 'Pay4Total');
end;

initialization
  RegisterTest('', TDaisyPrinterPrintTest.Suite);

end.
