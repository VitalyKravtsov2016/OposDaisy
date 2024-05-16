unit duDaisyFiscalPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, DaisyFiscalPrinter, DaisyPrinter, SerialPort, FileUtils,
  oleFiscalPrinter, StringUtils, PrinterParameters, DirectIOAPI,
  PrinterPort, TestDaisyPrinter, TestPrinterPort, DaisyPrinterInterface;

const
  CRLF = #13#10;

type
  { TDaisyFiscalPrinterTest }

  TDaisyFiscalPrinterTest = class(TTestCase)
  private
    FPrintHeader: Boolean;
    FPort: IPrinterPort;
    FPrinter: TTestDaisyPrinter;
    Driver: ToleFiscalPrinter;

    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure FptrCheck(Code: Integer); overload;
    procedure FptrCheck(Code: Integer; const AText: WideString); overload;
    procedure CheckTotal(Amount: Currency);
    function GetParams: TPrinterParameters;
    function DirectIO2(Command: Integer; const pData: Integer;
      const pString: WideString): Integer;

    property Params: TPrinterParameters read GetParams;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TestEvents;
  published
    procedure OpenClaimEnable;
    procedure TestCashIn;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscal;
    procedure TestFiscalReceipt;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestFiscalReceipt4;
    procedure TestFiscalReceipt5;
    procedure TestFiscalReceipt6;
    procedure TestFiscalReceipt7;
    procedure TestFiscalReceipt8;
    procedure TestFiscalReceiptWithVAT;
    procedure TestFiscalReceiptWithAdjustments;
    procedure TestFiscalReceiptWithAdjustments2;
    procedure TestFiscalReceiptWithAdjustments3;
    procedure TestSetHeaderLine;
    procedure TestSetHeaderLine2;
    procedure TestCheckHealth;

    procedure TestRefundReceipt;
    procedure TestRefundReceipt2;
  end;

implementation

{ TDaisyFiscalPrinterTest }

function TDaisyFiscalPrinterTest.GetParams: TPrinterParameters;
begin
  Result := Driver.Driver.Params;
end;

procedure TDaisyFiscalPrinterTest.FptrCheck(Code: Integer);
begin
  FptrCheck(Code, '');
end;

procedure TDaisyFiscalPrinterTest.FptrCheck(Code: Integer; const AText: WideString);
var
  Text: WideString;
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  if Code <> OPOS_SUCCESS then
  begin
    ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
    ResultCodeExtended := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
    ErrorString := Driver.GetPropertyString(PIDXFptr_ErrorString);

    if ResultCode = OPOS_E_EXTENDED then
      Text := Tnt_WideFormat('%s: %d, %d, %s [%s]', [AText, ResultCode,
        ResultCodeExtended, GetResultCodeExtendedText(ResultCodeExtended),
        ErrorString])
    else
      Text := Tnt_WideFormat('%s: %d, %s [%s]', [AText, ResultCode,
        GetResultCodeText(ResultCode), ErrorString]);

    raise Exception.Create(Text);
  end;
end;

procedure TDaisyFiscalPrinterTest.SetUp;
begin
  inherited SetUp;
  Driver := ToleFiscalPrinter.Create;
  FPort := TTestPrinterPort.Create;
  Driver.Driver.Port := FPort;
  FPrinter := TTestDaisyPrinter.Create(FPort, Driver.Driver.Logger);
  Driver.Driver.Printer := FPrinter;
  Driver.Driver.LoadParamsEnabled := False;
  Params.LogFileEnabled := True;
  Params.LogMaxCount := 10;
  Params.LogFilePath := GetModulePath + 'Logs';
  // Serial
  Params.ConnectionType := ConnectionTypeSerial;
  Params.ByteTimeout := 500;
  Params.PortName := 'COM3';
  Params.BaudRate := 19200;
(*
  // Network
  Params.PrinterType := ConnectionTypeSocket;
  Params.RemoteHost := '10.11.7.176';
  Params.RemotePort := 9100;
  Params.ByteTimeout := 1000;
*)
end;

procedure TDaisyFiscalPrinterTest.TearDown;
begin
  Driver.Free;
  FPort := nil;
  FPrinter := nil;
  inherited TearDown;
end;

procedure TDaisyFiscalPrinterTest.OpenService;
begin
  if Driver.GetPropertyNumber(PIDX_State) = OPOS_S_CLOSED then
  begin
    FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', nil));
    if Driver.GetPropertyNumber(PIDX_CapPowerReporting) <> 0 then
    begin
      Driver.SetPropertyNumber(PIDX_PowerNotify, OPOS_PN_ENABLED);
    end;
  end;
end;

procedure TDaisyFiscalPrinterTest.ClaimDevice;
begin
  if Driver.GetPropertyNumber(PIDX_Claimed) = 0 then
  begin
    CheckEquals(0, Driver.GetPropertyNumber(PIDX_Claimed),
      'GetPropertyNumber(PIDX_Claimed)');
    FptrCheck(Driver.ClaimDevice(1000));
    CheckEquals(1, Driver.GetPropertyNumber(PIDX_Claimed),
      'GetPropertyNumber(PIDX_Claimed)');
  end;
end;

procedure TDaisyFiscalPrinterTest.EnableDevice;
var
  ResultCode: Integer;
begin
  if Driver.GetPropertyNumber(PIDX_DeviceEnabled) = 0 then
  begin
    Driver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
    ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
    FptrCheck(ResultCode);

    CheckEquals(OPOS_SUCCESS, ResultCode, 'OPOS_SUCCESS');
    CheckEquals(1, Driver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');
  end;
end;

procedure TDaisyFiscalPrinterTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
end;

procedure TDaisyFiscalPrinterTest.TestCashIn;
begin
  OpenClaimEnable;

  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_IN);
  CheckEquals(FPTR_RT_CASH_IN, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(FPrintHeader));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.PrintRecMessage('TEXT LINE 1'));
  FptrCheck(Driver.PrintRecMessage('TEXT LINE 2'));

  FptrCheck(Driver.PrintRecCash(12.34));
  FptrCheck(Driver.PrintRecCash(23.45));
  FptrCheck(Driver.PrintRecCash(34.56));
  FptrCheck(Driver.PrintRecTotal(70.35, 12.34, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(70.35, 23.45, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(70.35, 34.56, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.EndFiscalReceipt(not FPrintHeader));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TDaisyFiscalPrinterTest.TestCashOut;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_OUT);
  CheckEquals(FPTR_RT_CASH_OUT, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(False));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.PrintRecMessage('TEXT LINE 1'));
  FptrCheck(Driver.PrintRecMessage('TEXT LINE 2'));

  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(60, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(60, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(60, 30, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(True));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TDaisyFiscalPrinterTest.TestZReport;
begin
  OpenClaimEnable;
  FptrCheck(Driver.PrintZReport, 'PrintZReport');
end;

procedure TDaisyFiscalPrinterTest.TestXReport;
begin
  OpenClaimEnable;
  FptrCheck(Driver.PrintXReport, 'PrintXReport');
end;

procedure TDaisyFiscalPrinterTest.TestNonFiscal;
begin
  OpenClaimEnable;
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Nonfiscal line 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Nonfiscal line 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Nonfiscal line 3'));
  FptrCheck(DirectIO2(DIO_PRINT_BARCODE, 14, '1234567;;10;3;1;'));
  FptrCheck(DirectIO2(DIO_PRINT_BARCODE, 14, '1234567;;10;3;0;'));
  FptrCheck(DirectIO2(DIO_PRINT_BARCODE, 14, '1234567;;10;3;2;'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt;
var
  ResultCode: Integer;
  Description: WideString;
const
  AdditionalHeader = 'AdditionalHeader line 1' + CRLF + 'AdditionalHeader line 2';
  AdditionalTrailer = 'AdditionalTrailer line 1' + CRLF + 'AdditionalTrailer line 2';
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  Driver.SetPropertyString(PIDXFptr_AdditionalHeader, AdditionalHeader);
  Driver.SetPropertyString(PIDXFptr_AdditionalTrailer, AdditionalTrailer);

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  Description := 'Receipt item 1';
  FptrCheck(Driver.PrintRecItem(Description, 590, 1000, 4, 590, 'pcs'));
  ResultCode := Driver.PrintRecTotal(12345, 12345, '0');
  CheckEquals(OPOS_E_EXTENDED, ResultCode, 'PrintRecTotal');
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
  CheckEquals(OPOS_EFPTR_BAD_ITEM_AMOUNT, ResultCode, 'PrintRecTotal');

  FptrCheck(Driver.PrintRecTotal(590, 590, '0'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt2;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('TRK 1: AI-98', 577.85, 3302, 4, 175, ''));
  FptrCheck(Driver.PrintRecItem('Receipt item 1', 620, 1000, 4, 620, 'pcs'));
  FptrCheck(Driver.PrintRecItem('Receipt item 2', 1250, 1000, 4, 1250, 'pcs'));
  FptrCheck(Driver.PrintRecItem('Receipt item 3', 650, 1000, 4, 650, 'pcs'));
  FptrCheck(Driver.PrintRecTotal(3097.85, 2521, '1'));
  FptrCheck(Driver.PrintRecTotal(3097.85, 577, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt3;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Receipt item 1', 620, 1000, 4, 620, 'pcs'));
  FptrCheck(Driver.PrintRecItem('Receipt item 2', 400, 1000, 4, 400, 'pcs'));
  FptrCheck(Driver.PrintRecItemAdjustment(1, '98', 40, 4));
  FptrCheck(Driver.PrintRecTotal(980, 980, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt4;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Receipt item 1', 236, 1000, 4, 236, 'pcs'));
  FptrCheck(Driver.PrintRecTotal(236, 236, '2'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt5;
begin
  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Apples', 333, 1000, 4, 333, 'kg'));
  FptrCheck(Driver.PrintRecTotal(333, 333, '0'));
  FptrCheck(Driver.PrintRecMessage('Operator ts1'));
  FptrCheck(Driver.PrintRecMessage('ID:      29211 '));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

function TDaisyFiscalPrinterTest.DirectIO2(Command: Integer;
  const pData: Integer; const pString: WideString): Integer;
var
  pData2: Integer;
  pString2: WideString;
begin
  pData2 := pData;
  pString2 := pString;
  Result := Driver.DirectIO(Command, pData2, pString2);
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt6;
begin
  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));

  FptrCheck(DirectIO2(30, 72, '4'));
  FptrCheck(DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('TRK 1:AI-92-K4/K5', 139.20, 870, 4, 160, 'litres'));
  FptrCheck(Driver.PrintRecTotal(139.20, 139.20, '1'));
  FptrCheck(Driver.PrintRecMessage('Kaspi ¹2832880234      '));
  FptrCheck(Driver.PrintRecMessage('Operator: Cashier1'));
  FptrCheck(Driver.PrintRecMessage('Transaction number: 11822'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt7;
begin
  OpenClaimEnable;
  FptrCheck(Driver.ClearError, 'ClearError');
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(DirectIO2(30, 72, '4'));
  FptrCheck(DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('Receipt item 1', 1180, 1000, 4, 1180, 'pcs'));
  FptrCheck(Driver.PrintRecTotal(1180, 1180, '0'));
  FptrCheck(Driver.PrintRecMessage('Operator: ts'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceipt8;
begin
  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('TRK 1:AI-92-K4/K5', 101, 500, 4, 202, 'litres'));
  FptrCheck(Driver.PrintRecTotal(101, 1000, '0'));
  FptrCheck(Driver.PrintRecMessage('Operator: Cashier1'));
  FptrCheck(Driver.PrintRecMessage('Transaction number: 16770'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;


procedure TDaisyFiscalPrinterTest.TestFiscalReceiptWithVAT;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Qiwi fruites in case', 620, 1000, 4, 620, 'pcs'));
  FptrCheck(Driver.PrintRecItem('Americano 180 ml', 400, 1000, 4, 400, 'pcs'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '98', 40, 4));
  FptrCheck(Driver.PrintRecTotal(980, 980, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.CheckTotal(Amount: Currency);
var
  IData: Integer;
  Data: WideString;
  Total: Currency;
begin
  FptrCheck(Driver.GetData(FPTR_GD_CURRENT_TOTAL, IData, Data));
  Total := StrToCurr(Data)/100;
  CheckEquals(Amount, Total, 'Total');
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceiptWithAdjustments;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Qiwi fruites in case', 620, 1000, 4, 620, 'pcs'));
  FptrCheck(Driver.PrintRecItem('Americano 180 ml', 400, 1000, 4, 400, 'pcs'));
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Discount 40', 40, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Surcharge 12', 12, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Surcharge 5%', 5, 4));
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10));
  FptrCheck(Driver.PrintRecTotal(874.80, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceiptWithAdjustments2;
var
  ResultCode: Integer;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('Qiwi fruites in case', 620, 1000, 4, 620, 'pcs'));
  CheckTotal(620);
  FptrCheck(Driver.PrintRecItem('Americano 180 ml', 400, 1000, 4, 400, 'pcs'));
  CheckTotal(1020);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Discount 40', 40, 4));
  CheckTotal(980);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Surcharge 12', 12, 4));
  CheckTotal(992);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10, 4));
  CheckTotal(952);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Surcharge 5%', 5, 4));
  CheckTotal(972);
  // Total adjustments
  ResultCode := Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Discount 10', 10);
  CheckEquals(OPOS_E_ILLEGAL, ResultCode, 'PrintRecSubtotalAdjustment.0');
  CheckTotal(972);
  ResultCode := Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Surcharge 5', 5);
  CheckEquals(OPOS_E_ILLEGAL, ResultCode, 'PrintRecSubtotalAdjustment.1');
  CheckTotal(972);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10));
  CheckTotal(874.8);
  ResultCode := Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Surcharge 5%', 5);
  CheckEquals(OPOS_E_ILLEGAL, ResultCode, 'PrintRecSubtotalAdjustment.2');
  CheckTotal(874.8);
  FptrCheck(Driver.PrintRecTotal(874.8, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestFiscalReceiptWithAdjustments3;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('Qiwi fruites in case', 555.52, 896, 4, 620, 'pcs'));
  CheckTotal(555.52);
  FptrCheck(Driver.PrintRecItem('Americano 180 ml', 400, 1000, 4, 400, 'pcs'));
  CheckTotal(955.52);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Discount 40', 40, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Surcharge 12', 12, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Surcharge 5%', 5, 4));
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10));
  FptrCheck(Driver.PrintRecTotal(816.77, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TDaisyFiscalPrinterTest.TestEvents;
begin
  OpenClaimEnable;
  Application.MessageBox('Change printer state', 'Attention');
end;

procedure TDaisyFiscalPrinterTest.TestSetHeaderLine;
var
  i: Integer;
  Text: WideString;
  NumHeaderLines: Integer;
begin
  OpenClaimEnable;
  NumHeaderLines := Driver.GetPropertyNumber(PIDXFptr_NumHeaderLines);
  for i := 1 to NumHeaderLines do
  begin
    Text := 'Header line ' + IntToStr(i);
    FptrCheck(Driver.SetHeaderLine(i, Text, True));
  end;
end;

procedure TDaisyFiscalPrinterTest.TestSetHeaderLine2;
var
  i: Integer;
  Text: WideString;
  NumHeaderLines: Integer;
begin
  OpenClaimEnable;
  NumHeaderLines := Driver.GetPropertyNumber(PIDXFptr_NumHeaderLines);
  for i := 1 to NumHeaderLines do
  begin
    Text := 'Header line ' + IntToStr(i);
    FptrCheck(Driver.SetHeaderLine(i, Text, (i mod 2) = 0));
  end;
end;

procedure TDaisyFiscalPrinterTest.TestCheckHealth;
begin
  OpenClaimEnable;
  FptrCheck(Driver.CheckHealth(OPOS_CH_INTERNAL));
  FptrCheck(Driver.CheckHealth(OPOS_CH_EXTERNAL));
end;

procedure TDaisyFiscalPrinterTest.TestRefundReceipt;
var
  i: Integer;
  ResultCode: Integer;
const
  Lines: array [0..12] of string = (
    'REFUND1',
    'REFUND2',
    'PrintRecMessage.1',
    'Receipt item 1',
    '                     590.00 x 1.000 = 590.00',
    'Discount 40                         = -40.00',
    'Receipt item 2',
    '                     123.00 x 1.000 = 123.00',
    'DISCOUNT                            = -20.00',
    'PrintRecMessage.2',
    'Discount 10%                        -10.00 %',
    'TOTAL                               = 587.70',
    'PrintRecMessage.3'
  );


begin
  Params.RefundCashoutLine1 := 'REFUND1';
  Params.RefundCashoutLine2 := 'REFUND2';

  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_REFUND);
  CheckEquals(FPTR_RT_REFUND, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.PrintRecMessage('PrintRecMessage.1'));
  FptrCheck(Driver.PrintRecItem('Receipt item 1', 590, 1000, 4, 590, 'pcs'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Discount 40', 40, 4));
  FptrCheck(Driver.PrintRecItem('Receipt item 2', 123, 1000, 4, 123, 'pcs'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '', 20, 4));
  FptrCheck(Driver.PrintRecMessage('PrintRecMessage.2'));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10));

  ResultCode := Driver.PrintRecTotal(12345, 12345, '0');
  CheckEquals(OPOS_E_EXTENDED, ResultCode, 'PrintRecTotal');
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
  CheckEquals(OPOS_EFPTR_BAD_ITEM_AMOUNT, ResultCode, 'PrintRecTotal');

  FptrCheck(Driver.PrintRecTotal(587.7, 587.7, '0'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecMessage('PrintRecMessage.3'));
  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  CheckEquals(Length(Lines), FPrinter.Lines.Count, 'Lines.Count');
  for i := Low(Lines) to High(Lines) do
  begin
    CheckEquals(Lines[i], FPrinter.Lines[i], Format('Lines[%d]', [i]));
  end;
end;

procedure TDaisyFiscalPrinterTest.TestRefundReceipt2;
var
  i: Integer;
  ResultCode: Integer;
const
  Lines: array [0..12] of string = (
    'REFUND1',
    'REFUND2',
    'PrintRecMessage.1',
    'Receipt item 1',
    '                     590.00 x 1.000 = 590.00',
    'Discount 40                         = -40.00',
    'Receipt item 2',
    '                     123.00 x 1.000 = 123.00',
    'DISCOUNT                            = -20.00',
    'PrintRecMessage.2',
    'Discount 10%                        -10.00 %',
    'TOTAL                               = 587.70',
    'PrintRecMessage.3'
  );


begin
  Params.RefundCashoutLine1 := 'REFUND1';
  Params.RefundCashoutLine2 := 'REFUND2';

  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.PrintRecMessage('PrintRecMessage.1'));
  FptrCheck(Driver.PrintRecItemRefund('Receipt item 1', 590, 1000, 4, 590, 'pcs'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Discount 40', 40, 4));
  FptrCheck(Driver.PrintRecItemRefund('Receipt item 2', 123, 1000, 4, 123, 'pcs'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '', 20, 4));
  FptrCheck(Driver.PrintRecMessage('PrintRecMessage.2'));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Discount 10%', 10));

  ResultCode := Driver.PrintRecTotal(12345, 12345, '0');
  CheckEquals(OPOS_E_EXTENDED, ResultCode, 'PrintRecTotal');
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
  CheckEquals(OPOS_EFPTR_BAD_ITEM_AMOUNT, ResultCode, 'PrintRecTotal');

  FptrCheck(Driver.PrintRecTotal(587.7, 587.7, '0'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecMessage('PrintRecMessage.3'));
  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  CheckEquals(Length(Lines), FPrinter.Lines.Count, 'Lines.Count');
  for i := Low(Lines) to High(Lines) do
  begin
    CheckEquals(Lines[i], FPrinter.Lines[i], Format('Lines[%d]', [i]));
  end;
end;

initialization
  RegisterTest('', TDaisyFiscalPrinterTest.Suite);

end.
