unit DaisyFiscalPrinter;

interface

uses
  // VCL
  Classes, SysUtils, Windows, DateUtils, ActiveX, ComObj, Math, Graphics,
  // Tnt
  TntSysUtils, TntClasses,
  // Opos
  Opos, Oposhi, OposFptr, OposFptrHi, OposEvents,
  OposEventsRCS, OposException, OposFptrUtils, OposServiceDevice19,
  OposUtils,
  // gnugettext
  gnugettext,
  // This
  OPOSDaisyLib_TLB, LogFile, WException, VersionInfo, DriverError,
  DaisyPrinter, DaisyPrinterInterface, FiscalPrinterState, ServiceVersion,
  PrinterParameters, PrinterParametersX, CashReceipt, SalesReceipt, ReceiptItem,
  StringUtils, DebugUtils, FileUtils, SerialPort, PrinterPort, SocketPort,
  PrinterTypes, DirectIOAPI, PrinterParametersReg, FiscalReceipt, NotifyThread;

const
  // VatValue
  MinVatValue = 0;
  MaxVatValue = 9999;


type
  { TPaperStatus }

  TPaperStatus = record
    IsEmpty: Boolean;
    IsNearEnd: Boolean;
    Status: Integer;
  end;

  { TDaisyFiscalPrinter }

  TDaisyFiscalPrinter = class(TComponent, IFiscalPrinterService_1_12)
  private
    FTestMode: Boolean;
    FLoadParamsEnabled: Boolean;
    procedure PrintBarcodeText(const BarcodeText: string);
    procedure DioReadPaymentName(var pData: Integer;
      var pString: WideString);
    procedure DioWritePaymentName(var pData: Integer;
      var pString: WideString);
    procedure DioSendCommand(var pData: Integer; var pString: WideString);
    procedure PrintText(const Text: WideString);
    procedure DeviceProc(Sender: TObject);
    procedure PrinterStatusUpdate(Sender: TObject);
    procedure SetRecEmpty(Value: Boolean);
    procedure StartDeviceThread;
    procedure StopDeviceThread;
    procedure PrintRefundReceipt(Receipt: TSalesReceipt);
    procedure PrintSalesReceipt(Receipt: TSalesReceipt);
    function SalesReceiptToText(Receipt: TSalesReceipt): WideString;
    function GetPort: IPrinterPort;
    function CreatePort: IPrinterPort;
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FPrinter: IDaisyPrinter;
    FReceipt: IFiscalReceipt;
    FVatRates: TDFPVATRates;
    FParams: TPrinterParameters;
    FOposDevice: TOposServiceDevice19;
    FPrinterState: TFiscalPrinterState;
    FDeviceThread: TNotifyThread;

    procedure DioPrintBarcode(var pData: Integer; var pString: WideString);
    procedure DioPrintBarcodeHex(var pData: Integer;
      var pString: WideString);
    procedure DioSetDriverParameter(var pData: Integer;
      var pString: WideString);
    procedure DioGetDriverParameter(var pData: Integer;
      var pString: WideString);
    procedure CheckRecStation(Station: Integer);
    procedure CheckVATID(VatID: Integer);
  public
    function AmountToInt(Value: Currency): Integer;
    function AmountToStr(Value: Currency): AnsiString;
    function AmountToOutStr(Value: Currency): AnsiString;
    function AmountToStrEq(Value: Currency): AnsiString;
  public
    procedure Initialize;
    procedure CheckEnabled;
    function IllegalError: Integer;
    procedure CheckState(AState: Integer);
    procedure SetPrinterState(Value: Integer);
    function DoClose: Integer;
    procedure Print(Receipt: TCashReceipt); overload;
    procedure Print(Receipt: TSalesReceipt); overload;
    function GetPrinterState: Integer;
    function DoRelease: Integer;
    function CreateReceipt(FiscalReceiptType: Integer): IFiscalReceipt;
    procedure PrinterErrorEvent(ASender: TObject; ResultCode,
      ResultCodeExtended, ErrorLocus: Integer;
      var pErrorResponse: Integer);
    function GetQuantity(Value: Integer): Double;
    procedure PrinterDirectIOEvent(ASender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString);
    procedure PrinterOutputCompleteEvent(ASender: TObject;
      OutputID: Integer);

    property Receipt: IFiscalReceipt read FReceipt;
    property Printer: IDaisyPrinter read FPrinter write FPrinter;
    property PrinterState: Integer read GetPrinterState write SetPrinterState;
  private
    FNumHeaderLines: Integer;
    FNumTrailerLines: Integer;
    FPostLine: WideString;
    FPreLine: WideString;
    FDeviceEnabled: Boolean;
    FCheckTotal: Boolean;
    FRecEmpty: Boolean;
    FAmountDecimalPlaces: Integer;
    // boolean
    FAsyncMode: Boolean;
    FDuplicateReceipt: Boolean;
    FFlagWhenIdle: Boolean;
    // integer
    FMessageLength: Integer;
    FDescriptionLength: Integer;
    FCountryCode: Integer;
    FErrorLevel: Integer;
    FErrorOutID: Integer;
    FErrorState: Integer;
    FErrorStation: Integer;
    FQuantityDecimalPlaces: Integer;
    FQuantityLength: Integer;
    FSlipSelection: Integer;
    FContractorId: Integer;
    FDateType: Integer;
    FFiscalReceiptStation: Integer;
    FFiscalReceiptType: Integer;
    FMessageType: Integer;
    FTotalizerType: Integer;
    FAdditionalHeader: WideString;
    FAdditionalTrailer: WideString;
    FPredefinedPaymentLines: WideString;
    FReservedWord: WideString;
    FChangeDue: WideString;
    FRemainingFiscalMemory: Integer;

    function DoCloseDevice: Integer;
    function DoOpen(const DeviceClass, DeviceName: WideString;
      const pDispatch: IDispatch): Integer;
    function GetEventInterface(FDispatch: IDispatch): IOposEvents;
    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    procedure SetDeviceEnabled(Value: Boolean);
  public
    function Get_OpenResult: Integer; safecall;
    function COFreezeEvents(Freeze: WordBool): Integer; safecall;
    function GetPropertyNumber(PropIndex: Integer): Integer; safecall;
    procedure SetPropertyNumber(PropIndex: Integer; Number: Integer); safecall;
    function GetPropertyString(PropIndex: Integer): WideString; safecall;
    procedure SetPropertyString(PropIndex: Integer; const Text: WideString); safecall;
    function OpenService(const DeviceClass: WideString; const DeviceName: WideString;
                         const pDispatch: IDispatch): Integer; safecall;
    function CloseService: Integer; safecall;
    function CheckHealth(Level: Integer): Integer; safecall;
    function ClaimDevice(Timeout: Integer): Integer; safecall;
    function ClearOutput: Integer; safecall;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; safecall;
    function DirectIO2(Command: Integer; const pData: Integer; const pString: WideString): Integer;
    function ReleaseDevice: Integer; safecall;
    function BeginFiscalDocument(DocumentAmount: Integer): Integer; safecall;
    function BeginFiscalReceipt(PrintHeader: WordBool): Integer; safecall;
    function BeginFixedOutput(Station: Integer; DocumentType: Integer): Integer; safecall;
    function BeginInsertion(Timeout: Integer): Integer; safecall;
    function BeginItemList(VatID: Integer): Integer; safecall;
    function BeginNonFiscal: Integer; safecall;
    function BeginRemoval(Timeout: Integer): Integer; safecall;
    function BeginTraining: Integer; safecall;
    function ClearError: Integer; safecall;
    function EndFiscalDocument: Integer; safecall;
    function EndFiscalReceipt(PrintHeader: WordBool): Integer; safecall;
    function EndFixedOutput: Integer; safecall;
    function EndInsertion: Integer; safecall;
    function EndItemList: Integer; safecall;
    function EndNonFiscal: Integer; safecall;
    function EndRemoval: Integer; safecall;
    function EndTraining: Integer; safecall;
    function GetData(DataItem: Integer; out OptArgs: Integer; out Data: WideString): Integer; safecall;
    function GetDate(out Date: WideString): Integer; safecall;
    function GetTotalizer(VatID: Integer; OptArgs: Integer; out Data: WideString): Integer; safecall;
    function GetVatEntry(VatID: Integer; OptArgs: Integer; out VatRate: Integer): Integer; safecall;
    function PrintDuplicateReceipt: Integer; safecall;
    function PrintFiscalDocumentLine(const DocumentLine: WideString): Integer; safecall;
    function PrintFixedOutput(DocumentType: Integer; LineNumber: Integer; const Data: WideString): Integer; safecall;
    function PrintNormal(Station: Integer; const AData: WideString): Integer; safecall;
    function PrintPeriodicTotalsReport(const Date1: WideString; const Date2: WideString): Integer; safecall;
    function PrintPowerLossReport: Integer; safecall;
    function PrintRecItem(const Description: WideString; Price: Currency; Quantity: Integer;
                          VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString): Integer; safecall;
    function PrintRecItemAdjustment(AdjustmentType: Integer; const Description: WideString;
                                    Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecMessage(const Message: WideString): Integer; safecall;
    function PrintRecNotPaid(const Description: WideString; Amount: Currency): Integer; safecall;
    function PrintRecRefund(const Description: WideString; Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecSubtotal(Amount: Currency): Integer; safecall;
    function PrintRecSubtotalAdjustment(AdjustmentType: Integer; const Description: WideString;
                                        Amount: Currency): Integer; safecall;
    function PrintRecTotal(Total: Currency; Payment: Currency; const Description: WideString): Integer; safecall;
    function PrintRecVoid(const Description: WideString): Integer; safecall;
    function PrintRecVoidItem(const Description: WideString; Amount: Currency; Quantity: Integer;
                              AdjustmentType: Integer; Adjustment: Currency; VatInfo: Integer): Integer; safecall;
    function PrintReport(ReportType: Integer; const StartNum: WideString; const EndNum: WideString): Integer; safecall;
    function PrintXReport: Integer; safecall;
    function PrintZReport: Integer; safecall;
    function ResetPrinter: Integer; safecall;
    function SetDate(const Date: WideString): Integer; safecall;
    function SetHeaderLine(LineNumber: Integer; const Text: WideString; DoubleWidth: WordBool): Integer; safecall;
    function SetPOSID(const POSID: WideString; const CashierID: WideString): Integer; safecall;
    function SetStoreFiscalID(const ID: WideString): Integer; safecall;
    function SetTrailerLine(LineNumber: Integer; const Text: WideString; DoubleWidth: WordBool): Integer; safecall;
    function SetVatTable: Integer; safecall;
    function SetVatValue(VatID: Integer; const VatValue: WideString): Integer; safecall;
    function VerifyItem(const ItemName: WideString; VatID: Integer): Integer; safecall;
    function PrintRecCash(Amount: Currency): Integer; safecall;
    function PrintRecItemFuel(const Description: WideString; Price: Currency; Quantity: Integer;
                              VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString;
                              SpecialTax: Currency; const SpecialTaxName: WideString): Integer; safecall;
    function PrintRecItemFuelVoid(const Description: WideString; Price: Currency; VatInfo: Integer;
                                  SpecialTax: Currency): Integer; safecall;
    function PrintRecPackageAdjustment(AdjustmentType: Integer; const Description: WideString;
                                       const VatAdjustment: WideString): Integer; safecall;
    function PrintRecPackageAdjustVoid(AdjustmentType: Integer; const VatAdjustment: WideString): Integer; safecall;
    function PrintRecRefundVoid(const Description: WideString; Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecSubtotalAdjustVoid(AdjustmentType: Integer; Amount: Currency): Integer; safecall;
    function PrintRecTaxID(const TaxID: WideString): Integer; safecall;
    function SetCurrency(NewCurrency: Integer): Integer; safecall;
    function GetOpenResult: Integer; safecall;
    function Open(const DeviceClass: WideString; const DeviceName: WideString;
                  const pDispatch: IDispatch): Integer; safecall;
    function Close: Integer; safecall;
    function Claim(Timeout: Integer): Integer; safecall;
    function Release1: Integer; safecall;
    function ResetStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; safecall;
    function UpdateStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; safecall;
    function UpdateFirmware(const FirmwareFileName: WideString): Integer; safecall;
    function PrintRecItemAdjustmentVoid(AdjustmentType: Integer; const Description: WideString;
                                        Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecItemVoid(const Description: WideString; Price: Currency; Quantity: Integer;
                              VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString): Integer; safecall;
    function PrintRecItemRefund(const Description: WideString; Amount: Currency; Quantity: Integer;
                                VatInfo: Integer; UnitAmount: Currency; const UnitName: WideString): Integer; safecall;
    function PrintRecItemRefundVoid(const Description: WideString; Amount: Currency;
                                    Quantity: Integer; VatInfo: Integer; UnitAmount: Currency;
                                    const UnitName: WideString): Integer; safecall;
    property OpenResult: Integer read Get_OpenResult;
  public
    constructor Create2(AOwner: TComponent; APrinter: IDaisyPrinter);
    destructor Destroy; override;

    function DecodeString(const Text: WideString): WideString;
    function EncodeString(const S: WideString): WideString;
    procedure PrintBarcode(const BarcodeText: string);

    property Logger: ILogFile read FLogger;
    property Params: TPrinterParameters read FParams;
    property Port: IPrinterPort read GetPort write FPort;
    property TestMode: Boolean read FTestMode write FTestMode;
    property OposDevice: TOposServiceDevice19 read FOposDevice;
    property LoadParamsEnabled: Boolean read FLoadParamsEnabled write FLoadParamsEnabled;
  end;

implementation

uses
  fmuLogo;

const
  BoolToInt: array [Boolean] of Integer = (0, 1);

function IntToBool(Value: Integer): Boolean;
begin
  Result := Value <> 0;
end;

function GetSystemLocaleStr: WideString;
const
  BoolToStr: array [Boolean] of WideString = ('0', '1');
begin
  Result := Format('LCID: %d, LangID: %d.%d, FarEast: %s, FarEast: %s',
    [SysLocale.DefaultLCID, SysLocale.PriLangID, SysLocale.SubLangID,
    BoolToStr[SysLocale.FarEast], BoolToStr[SysLocale.MiddleEast]]);
end;

function GetSystemVersionStr: WideString;
var
  OSVersionInfo: TOSVersionInfo;
begin
  Result := '';
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
  begin
    Result := Tnt_WideFormat('%d.%d.%d, Platform ID: %d', [
      OSVersionInfo.dwMajorVersion,
      OSVersionInfo.dwMinorVersion,
      OSVersionInfo.dwBuildNumber,
      OSVersionInfo.dwPlatformId]);
  end;
end;

{ TDaisyFiscalPrinter }

constructor TDaisyFiscalPrinter.Create2(AOwner: TComponent; APrinter: IDaisyPrinter);
begin
  inherited Create(AOwner);
  FPrinter := APrinter;
  FLogger := TLogFile.Create;
  FParams := TPrinterParameters.Create(FLogger);
  FOposDevice := TOposServiceDevice19.Create(FLogger);
  FOposDevice.ErrorEventEnabled := False;
  FPrinterState := TFiscalPrinterState.Create;
  FLoadParamsEnabled := True;
end;

destructor TDaisyFiscalPrinter.Destroy;
begin
  if FOposDevice.Opened then
    Close;

  FPort := nil;
  FParams.Free;
  FPrinter := nil;
  FOposDevice.Free;
  FPrinterState.Free;
  FReceipt := nil;
  FDeviceThread.Free;
  FDeviceThread := nil;
  inherited Destroy;
end;

function TDaisyFiscalPrinter.GetPort: IPrinterPort;
begin
  if FPort = nil then
    FPort := CreatePort;
  Result := FPort;
end;

function TDaisyFiscalPrinter.CreatePort: IPrinterPort;
var
  SerialParams: TSerialParams;
  SocketParams: TSocketParams;
begin
  case Params.ConnectionType of
    ConnectionTypeSerial:
    begin
      SerialParams.PortName := Params.PortName;
      SerialParams.BaudRate := Params.BaudRate;
      SerialParams.DataBits := DATABITS_8;
      SerialParams.StopBits := ONESTOPBIT;
      SerialParams.Parity := NOPARITY;
      SerialParams.FlowControl := FLOW_CONTROL_NONE;
      SerialParams.ReconnectPort := False;
      SerialParams.ByteTimeout := Params.ByteTimeout;
      Result := TSerialPort.Create(SerialParams, Logger);
    end;
    ConnectionTypeSocket:
    begin
      SocketParams.RemoteHost := Params.RemoteHost;
      SocketParams.RemotePort := Params.RemotePort;
      SocketParams.ByteTimeout := Params.ByteTimeout;
      SocketParams.MaxRetryCount := 1;
      Result := TSocketPort.Create(SocketParams, Logger);
    end;
  else
    raise Exception.Create('Invalid PrinterType value');
  end;
end;

procedure TDaisyFiscalPrinter.CheckVATID(VatID: Integer);
begin
  if (VatID < 1)or(VatID > DaisyPrinterInterface.MaxVATRate) then
    RaiseIllegalError(Format('Invalid VatID parameter, %d', [VatID]));
end;

procedure TDaisyFiscalPrinter.CheckRecStation(Station: Integer);
begin
  if Station <> FPTR_S_RECEIPT then
    RaiseIllegalError(_('Station not supported'));
end;

function TDaisyFiscalPrinter.AmountToInt(Value: Currency): Integer;
begin
  if FAmountDecimalPlaces = 0 then
  begin
    Result := Round(Value);
  end else
  begin
    Result := Round(Value * Math.Power(10, FAmountDecimalPlaces));
  end;
end;

function TDaisyFiscalPrinter.AmountToStr(Value: Currency): AnsiString;
begin
  if FAmountDecimalPlaces = 0 then
  begin
    Result := IntToStr(Round(Value));
  end else
  begin
    Result := Format('%.*f', [FAmountDecimalPlaces, Value]);
  end;
end;

function TDaisyFiscalPrinter.AmountToOutStr(Value: Currency): AnsiString;
var
  L: Int64;
begin
  L := Trunc(Value * Math.Power(10, FAmountDecimalPlaces));
  Result := IntToStr(L);
end;

function TDaisyFiscalPrinter.AmountToStrEq(Value: Currency): AnsiString;
begin
  Result := '=' + AmountToStr(Value);
end;

function TDaisyFiscalPrinter.GetQuantity(Value: Integer): Double;
begin
  Result := Value / 1000;
end;

function TDaisyFiscalPrinter.CreateReceipt(FiscalReceiptType: Integer): IFiscalReceipt;
begin
  case FiscalReceiptType of
    FPTR_RT_CASH_IN: Result := TCashReceipt.Create(FPTR_RT_CASH_IN);
    FPTR_RT_CASH_OUT: Result := TCashReceipt.Create(FPTR_RT_CASH_OUT);
    FPTR_RT_SALES,
    FPTR_RT_GENERIC,
    FPTR_RT_SERVICE,
    FPTR_RT_SIMPLE_INVOICE:
      Result := TSalesReceipt.CreateReceipt(FAmountDecimalPlaces, False);
    FPTR_RT_REFUND:
      Result := TSalesReceipt.CreateReceipt(FAmountDecimalPlaces, True);
  else
    Result := nil;
    InvalidPropertyValue('FiscalReceiptType', IntToStr(FiscalReceiptType));
  end;
end;

function TDaisyFiscalPrinter.DoRelease: Integer;
begin
  try
    SetDeviceEnabled(False);
    OposDevice.ReleaseDevice;
    Port.Close;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.GetPrinterState: Integer;
begin
  Result := FPrinterState.State;
end;

procedure TDaisyFiscalPrinter.SetPrinterState(Value: Integer);
begin
  FPrinterState.SetState(Value);
end;

function TDaisyFiscalPrinter.DoClose: Integer;
begin
  try
    Result := DoCloseDevice;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TDaisyFiscalPrinter.Initialize;
begin
  FAmountDecimalPlaces := 2;
  FDescriptionLength := 0; { !!! }
  FMessageLength := 0; { !!! }
  FAsyncMode := False;
  FDuplicateReceipt := False;
  FFlagWhenIdle := False;
  // integer
  FOposDevice.ServiceObjectVersion := GenericServiceVersion;
  FCountryCode := FPTR_CC_RUSSIA;
  FErrorLevel := FPTR_EL_NONE;
  FErrorOutID := 0;
  FErrorState := FPTR_PS_MONITOR;
  FErrorStation := FPTR_S_RECEIPT;
  SetPrinterState(FPTR_PS_MONITOR);
  FQuantityDecimalPlaces := 3;
  FQuantityLength := 10;
  FSlipSelection := FPTR_SS_FULL_LENGTH;
  FContractorId := FPTR_CID_SINGLE;
  FDateType := FPTR_DT_RTC;
  FFiscalReceiptStation := FPTR_RS_RECEIPT;
  FFiscalReceiptType := FPTR_RT_SALES;
  FMessageType := FPTR_MT_FREE_TEXT;
  FTotalizerType := FPTR_TT_DAY;

  FAdditionalHeader := '';
  FAdditionalTrailer := '';
  FOposDevice.PhysicalDeviceName := 'DAISY FX 1300, Georgia';
  FOposDevice.PhysicalDeviceDescription := 'DAISY FX 1300, Georgia';
  FOposDevice.ServiceObjectDescription := 'DAISY FX 1300 OPOS fiscal printer service. SHTRIH-M, 2024';
  FPredefinedPaymentLines := '1,2,3,4,5';
  FReservedWord := '';
  FChangeDue := '';
end;

function TDaisyFiscalPrinter.IllegalError: Integer;
begin
  Result := FOposDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TDaisyFiscalPrinter.ClearResult: Integer;
begin
  Result := FOposDevice.ClearResult;
end;

procedure TDaisyFiscalPrinter.CheckEnabled;
begin
  FOposDevice.CheckEnabled;
end;

procedure TDaisyFiscalPrinter.CheckState(AState: Integer);
begin
  CheckEnabled;
  FPrinterState.CheckState(AState);
end;

function TDaisyFiscalPrinter.DecodeString(const Text: WideString): WideString;
begin
  Result := Text;
end;

function TDaisyFiscalPrinter.EncodeString(const S: WideString): WideString;
begin
  Result := S;
end;

function TDaisyFiscalPrinter.BeginFiscalDocument(
  DocumentAmount: Integer): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_FISCAL_DOCUMENT);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.BeginFiscalReceipt(PrintHeader: WordBool): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_FISCAL_RECEIPT);
    StopDeviceThread;
    FReceipt := CreateReceipt(FFiscalReceiptType);
    FReceipt.BeginFiscalReceipt(PrintHeader);
    Params.DayOpened := True;
    SaveUsrParameters(Params, FOposDevice.DeviceName, Logger);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.BeginFixedOutput(Station,
  DocumentType: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.BeginItemList(VatID: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.BeginNonFiscal: Integer;
var
  RecNumber: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_NONFISCAL);
    StopDeviceThread;
    Printer.Check(Printer.StartNonfiscalReceipt(RecNumber));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.BeginTraining: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    RaiseOposException(OPOS_E_ILLEGAL, _('Training mode not supported'));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.CheckHealth(Level: Integer): Integer;
begin
  try
    CheckEnabled;
    case Level of
      OPOS_CH_INTERNAL:
      begin
        Printer.Check(Printer.Reset);
      end;
      OPOS_CH_EXTERNAL:
      begin
        //Printer.Check(Printer.PrintDiagnosticInfo);
        Printer.Check(Printer.PrintParameters);
        //Printer.Check(Printer.PrintVATRates);
      end;
      OPOS_CH_INTERACTIVE:
      begin
        { !!! }
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.Claim(Timeout: Integer): Integer;
begin
  try
    FOposDevice.ClaimDevice(Timeout);
    Port.Open;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.ClaimDevice(Timeout: Integer): Integer;
begin
  Result := Claim(Timeout);
end;

function TDaisyFiscalPrinter.ClearError: Integer;
begin
  Result := ClearResult;
end;

function TDaisyFiscalPrinter.ClearOutput: Integer;
begin
  try
    FOposDevice.CheckClaimed;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.Close: Integer;
begin
  Result := DoClose;
end;

function TDaisyFiscalPrinter.CloseService: Integer;
begin
  Result := DoClose;
end;

function TDaisyFiscalPrinter.COFreezeEvents(Freeze: WordBool): Integer;
begin
  try
    FOposDevice.FreezeEvents := Freeze;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.CompareFirmwareVersion(
  const FirmwareFileName: WideString; out pResult: Integer): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TDaisyFiscalPrinter.DioReadPaymentName(var pData: Integer; var pString: WideString);
var
  N: Integer;
begin
  if (pData < 1) or (pData > Printer.Constants.NumPaymentTypes) then
    RaiseIllegalError('Invalid payment number');

  N := DaisyPrinterInterface.DFP_SP_PAYMENT_START_LINE + pData -1;
  Printer.Check(Printer.ReadText(N, pString));
end;

procedure TDaisyFiscalPrinter.DioWritePaymentName(var pData: Integer; var pString: WideString);
var
  N: Integer;
begin
  if (pData < 1) or (pData > Printer.Constants.NumPaymentTypes) then
    RaiseIllegalError('Invalid payment number');

  N := DaisyPrinterInterface.DFP_SP_PAYMENT_START_LINE + pData -1;
  Printer.Check(Printer.WriteText(N, pString));
end;

procedure TDaisyFiscalPrinter.DioSendCommand(var pData: Integer; var pString: WideString);
var
  Answer: AnsiString;
  Command: AnsiString;
begin
  Command := Chr(pData) + Printer.EncodePrinterText(pString);
  Printer.Check(Printer.Send(Command, Answer));
  pString := Printer.DecodePrinterText(Answer);
end;

procedure TDaisyFiscalPrinter.DioPrintBarcode(var pData: Integer; var pString: WideString);
var
  Barcode: TBarcodeRec;
begin
  if Pos(';', pString) = 0 then
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := pString;
    Barcode.Text := pString;
    Barcode.Height := 0;
    Barcode.Width := 0;
    Barcode.ModuleWidth := 4;
    Barcode.Alignment := 0;
    Barcode.Parameter1 := 0;
    Barcode.Parameter2 := 0;
    Barcode.Parameter3 := 0;
    Barcode.Parameter4 := 0;
    Barcode.Parameter5 := 0;
  end else
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := GetString(pString, 1, ValueDelimiters);
    Barcode.Text := GetString(pString, 2, ValueDelimiters);
    Barcode.Height := GetInteger(pString, 3, ValueDelimiters);
    Barcode.ModuleWidth := GetInteger(pString, 4, ValueDelimiters);
    Barcode.Alignment := GetInteger(pString, 5, ValueDelimiters);
    Barcode.Parameter1 := GetInteger(pString, 6, ValueDelimiters);
    Barcode.Parameter2 := GetInteger(pString, 7, ValueDelimiters);
    Barcode.Parameter3 := GetInteger(pString, 8, ValueDelimiters);
    Barcode.Parameter4 := GetInteger(pString, 9, ValueDelimiters);
    Barcode.Parameter5 := GetInteger(pString, 10, ValueDelimiters);
    Barcode.Width := 0;
  end;
  PrintBarcode(BarcodeToStr(Barcode));
end;

procedure TDaisyFiscalPrinter.DioPrintBarcodeHex(var pData: Integer;
  var pString: WideString);
var
  Barcode: TBarcodeRec;
begin
  if Pos(';', pString) = 0 then
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := HexToStr(pString);
    Barcode.Text := pString;

    (*
    Barcode.Height := Printer.Params.BarcodeHeight;
    Barcode.ModuleWidth := Printer.Params.BarcodeModuleWidth;
    Barcode.Alignment := Printer.Params.BarcodeAlignment;
    Barcode.Parameter1 := Printer.Params.BarcodeParameter1;
    Barcode.Parameter2 := Printer.Params.BarcodeParameter2;
    Barcode.Parameter3 := Printer.Params.BarcodeParameter3;
    *)
  end else
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := HexToStr(GetString(pString, 1, ValueDelimiters));
    Barcode.Text := GetString(pString, 2, ValueDelimiters);
    Barcode.Height := GetInteger(pString, 3, ValueDelimiters);
    Barcode.ModuleWidth := GetInteger(pString, 4, ValueDelimiters);
    Barcode.Alignment := GetInteger(pString, 5, ValueDelimiters);
    Barcode.Parameter1 := GetInteger(pString, 6, ValueDelimiters);
    Barcode.Parameter2 := GetInteger(pString, 7, ValueDelimiters);
    Barcode.Parameter3 := GetInteger(pString, 8, ValueDelimiters);
  end;
  PrintBarcode(BarcodeToStr(Barcode));
end;

procedure TDaisyFiscalPrinter.DioSetDriverParameter(var pData: Integer;
  var pString: WideString);
begin
end;

procedure TDaisyFiscalPrinter.DioGetDriverParameter(var pData: Integer;
  var pString: WideString);
begin
end;

function TDaisyFiscalPrinter.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
begin

  try
    FOposDevice.CheckOpened;
    case Command of
      DIO_LOAD_LOGO: Printer.Check(Printer.LoadLogoFile(pString));
      DIO_LOGO_DLG: ShowLogoDialog(Printer);
      DIO_READ_PAYMENT_NAME: DioReadPaymentName(pData, pString);
      DIO_WRITE_PAYMENT_NAME: DioWritePaymentName(pData, pString);
      DIO_COMMAND_PRINTER_STR: DioSendCommand(pData, pString);

      DIO_PRINT_BARCODE: DioPrintBarcode(pData, pString);
      DIO_PRINT_BARCODE_HEX: DioPrintBarcodeHex(pData, pString);
      DIO_SET_DRIVER_PARAMETER: DioSetDriverParameter(pData, pString);
      DIO_GET_DRIVER_PARAMETER: DioGetDriverParameter(pData, pString);
    else
      (*
      if Receipt.IsOpened then
      begin
        Receipt.DirectIO(Command, pData, pString);
      end;
      *)
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.DirectIO2(Command: Integer; const pData: Integer; const pString: WideString): Integer;
var
  pData2: Integer;
  pString2: WideString;
begin
  pData2 := pData;
  pString2 := pString;
  Result := DirectIO(Command, pData2, pString2);
end;

function TDaisyFiscalPrinter.EndFiscalDocument: Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.EndFiscalReceipt(PrintHeader: WordBool): Integer;
begin
  try
    FPrinterState.CheckState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    FReceipt.EndFiscalReceipt(PrintHeader);
    FReceipt.Print(Self);
    SetPrinterState(FPTR_PS_MONITOR);
    StartDeviceThread;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.EndFixedOutput: Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.EndInsertion: Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.EndItemList: Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.EndNonFiscal: Integer;
var
  RecNumber: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_NONFISCAL);
    Printer.Check(Printer.EndNonfiscalReceipt(RecNumber));
    SetPrinterState(FPTR_PS_MONITOR);
    StartDeviceThread;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.EndRemoval: Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.EndTraining: Integer;
begin
  try
    CheckEnabled;
    RaiseOposException(OPOS_E_ILLEGAL, _('Training mode is not active'));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.Get_OpenResult: Integer;
begin
  Result := FOposDevice.OpenResult;
end;

function TDaisyFiscalPrinter.GetData(DataItem: Integer; out OptArgs: Integer;
  out Data: WideString): Integer;

  function ReadDayTotal: Currency;
  var
    Day: TDFPDayStatus;
  begin
    Printer.Check(Printer.ReadDayStatus(Day));
    Result := Day.CashTotal + Day.Pay1Total +
      Day.Pay2Total + Day.Pay3Total + Day.Pay3Total;
  end;

  function ReadZReportNumber: Integer;
  var
    Day: TDFPDayStatus;
  begin
    Printer.Check(Printer.ReadDayStatus(Day));
    Result := Day.ZRepNo;
  end;

  function ReadReceiptNumber: Integer;
  begin
    Printer.Check(Printer.ReadLastDocNo(Result));
  end;

begin
  try
    case DataItem of
      FPTR_GD_FIRMWARE: Data := FOposDevice.PhysicalDeviceDescription;
      FPTR_GD_PRINTER_ID: Data := Printer.Diagnostic.FDNo;
      FPTR_GD_CURRENT_TOTAL: Data := AmountToOutStr(Receipt.GetTotal());
      FPTR_GD_DAILY_TOTAL: Data := AmountToOutStr(ReadDayTotal);
      FPTR_GD_Z_REPORT: Data := IntToStr(ReadZReportNumber);
      FPTR_GD_RECEIPT_NUMBER: Data := IntToStr(ReadReceiptNumber);
    else
      InvalidParameterValue('DataItem', IntToStr(DataItem));
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.GetDate(out Date: WideString): Integer;
var
  ADate: TDateTime;
begin
  try
    case FDateType of
      FPTR_DT_RTC:
      begin
        Printer.Check(Printer.ReadDateTime(ADate));
        Date := OposEncodeDate(ADate);
      end;
    else
      InvalidPropertyValue('DateType', IntToStr(FDateType));
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.GetOpenResult: Integer;
begin
  Result := FOposDevice.OpenResult;
end;

function TDaisyFiscalPrinter.GetPropertyNumber(PropIndex: Integer): Integer;
begin
  try
    case PropIndex of
      // standard
      PIDX_Claimed                    : Result := BoolToInt[FOposDevice.Claimed];
      PIDX_DataEventEnabled           : Result := BoolToInt[FOposDevice.DataEventEnabled];
      PIDX_DeviceEnabled              : Result := BoolToInt[FDeviceEnabled];
      PIDX_FreezeEvents               : Result := BoolToInt[FOposDevice.FreezeEvents];
      PIDX_OutputID                   : Result := FOposDevice.OutputID;
      PIDX_ResultCode                 : Result := FOposDevice.ResultCode;
      PIDX_ResultCodeExtended         : Result := FOposDevice.ResultCodeExtended;
      PIDX_ServiceObjectVersion       : Result := FOposDevice.ServiceObjectVersion;
      PIDX_State                      : Result := FOposDevice.State;
      PIDX_BinaryConversion           : Result := FOposDevice.BinaryConversion;
      PIDX_DataCount                  : Result := FOposDevice.DataCount;
      PIDX_PowerNotify                : Result := FOposDevice.PowerNotify;
      PIDX_PowerState                 : Result := FOposDevice.PowerState;
      PIDX_CapPowerReporting          : Result := FOposDevice.CapPowerReporting;
      PIDX_CapStatisticsReporting     : Result := BoolToInt[FOposDevice.CapStatisticsReporting];
      PIDX_CapUpdateStatistics        : Result := BoolToInt[FOposDevice.CapUpdateStatistics];
      PIDX_CapCompareFirmwareVersion  : Result := BoolToInt[FOposDevice.CapCompareFirmwareVersion];
      PIDX_CapUpdateFirmware          : Result := BoolToInt[FOposDevice.CapUpdateFirmware];
      // specific
      PIDXFptr_AmountDecimalPlaces    : Result := FAmountDecimalPlaces;
      PIDXFptr_AsyncMode              : Result := BoolToInt[FAsyncMode];
      PIDXFptr_CheckTotal             : Result := BoolToInt[FCheckTotal];
      PIDXFptr_CountryCode            : Result := FCountryCode;
      PIDXFptr_CoverOpen              : Result := BoolToInt[False];
      PIDXFptr_DayOpened              : Result := BoolToInt[Params.DayOpened];
      PIDXFptr_DescriptionLength      : Result := FDescriptionLength;
      PIDXFptr_DuplicateReceipt       : Result := BoolToInt[FDuplicateReceipt];
      PIDXFptr_ErrorLevel             : Result := FErrorLevel;
      PIDXFptr_ErrorOutID             : Result := FErrorOutID;
      PIDXFptr_ErrorState             : Result := FErrorState;
      PIDXFptr_ErrorStation           : Result := FErrorStation;
      PIDXFptr_FlagWhenIdle           : Result := BoolToInt[FFlagWhenIdle];
      PIDXFptr_JrnEmpty               : Result := 0;
      PIDXFptr_JrnNearEnd             : Result := 0;
      PIDXFptr_MessageLength          : Result := FMessageLength;
      PIDXFptr_NumHeaderLines         : Result := FNumHeaderLines;
      PIDXFptr_NumTrailerLines        : Result := FNumTrailerLines;
      PIDXFptr_NumVatRates            : Result := MaxVATRate;
      PIDXFptr_PrinterState           : Result := FPrinterState.State;
      PIDXFptr_QuantityDecimalPlaces  : Result := FQuantityDecimalPlaces;
      PIDXFptr_QuantityLength         : Result := FQuantityLength;
      PIDXFptr_RecEmpty               : Result := BoolToInt[FRecEmpty];
      PIDXFptr_RecNearEnd             : Result := BoolToInt[False];
      PIDXFptr_RemainingFiscalMemory  : Result := FRemainingFiscalMemory;
      PIDXFptr_SlpEmpty               : Result := 0;
      PIDXFptr_SlpNearEnd             : Result := 0;
      PIDXFptr_SlipSelection          : Result := FSlipSelection;
      PIDXFptr_TrainingModeActive     : Result := BoolToInt[False];
      PIDXFptr_ActualCurrency         : Result := FPTR_AC_OTHER;
      PIDXFptr_ContractorId           : Result := FContractorId;
      PIDXFptr_DateType               : Result := FDateType;
      PIDXFptr_FiscalReceiptStation   : Result := FFiscalReceiptStation;
      PIDXFptr_FiscalReceiptType          : Result := FFiscalReceiptType;
      PIDXFptr_MessageType                : Result := FMessageType;
      PIDXFptr_TotalizerType              : Result := FTotalizerType;
      PIDXFptr_CapAdditionalLines         : Result := 1;
      PIDXFptr_CapAmountAdjustment        : Result := 1;
      PIDXFptr_CapAmountNotPaid           : Result := 0;
      PIDXFptr_CapCheckTotal              : Result := 1;
      PIDXFptr_CapCoverSensor             : Result := 0;
      PIDXFptr_CapDoubleWidth             : Result := 0;
      PIDXFptr_CapDuplicateReceipt        : Result := 1;
      PIDXFptr_CapFixedOutput             : Result := 0;
      PIDXFptr_CapHasVatTable             : Result := 1;
      PIDXFptr_CapIndependentHeader       : Result := 1;
      PIDXFptr_CapItemList                : Result := 1;
      PIDXFptr_CapJrnEmptySensor          : Result := 0;
      PIDXFptr_CapJrnNearEndSensor        : Result := 0;
      PIDXFptr_CapJrnPresent              : Result := 0;
      PIDXFptr_CapNonFiscalMode           : Result := 1;
      PIDXFptr_CapOrderAdjustmentFirst    : Result := 0;
      PIDXFptr_CapPercentAdjustment       : Result := 1;
      PIDXFptr_CapPositiveAdjustment      : Result := 1;
      PIDXFptr_CapPowerLossReport         : Result := 0;
      PIDXFptr_CapPredefinedPaymentLines  : Result := 1;
      PIDXFptr_CapReceiptNotPaid          : Result := 0;
      PIDXFptr_CapRecEmptySensor          : Result := 1;
      PIDXFptr_CapRecNearEndSensor        : Result := 0;
      PIDXFptr_CapRecPresent              : Result := 1;
      PIDXFptr_CapRemainingFiscalMemory   : Result := 0;
      PIDXFptr_CapReservedWord            : Result := 0;
      PIDXFptr_CapSetHeader               : Result := 1;
      PIDXFptr_CapSetPOSID                : Result := 1;
      PIDXFptr_CapSetStoreFiscalID        : Result := 0;
      PIDXFptr_CapSetTrailer              : Result := 1;
      PIDXFptr_CapSetVatTable             : Result := 1;
      PIDXFptr_CapSlpEmptySensor          : Result := 0;
      PIDXFptr_CapSlpFiscalDocument       : Result := 0;
      PIDXFptr_CapSlpFullSlip             : Result := 0;
      PIDXFptr_CapSlpNearEndSensor        : Result := 0;
      PIDXFptr_CapSlpPresent              : Result := 0;
      PIDXFptr_CapSlpValidation           : Result := 0;
      PIDXFptr_CapSubAmountAdjustment     : Result := 0;
      PIDXFptr_CapSubPercentAdjustment    : Result := 1;
      PIDXFptr_CapSubtotal                : Result := 0;
      PIDXFptr_CapTrainingMode            : Result := 0;
      PIDXFptr_CapValidateJournal         : Result := 0;
      PIDXFptr_CapXReport                 : Result := 1;
      PIDXFptr_CapAdditionalHeader        : Result := 1;
      PIDXFptr_CapAdditionalTrailer       : Result := 1;
      PIDXFptr_CapChangeDue               : Result := 0;
      PIDXFptr_CapEmptyReceiptIsVoidable  : Result := 1;
      PIDXFptr_CapFiscalReceiptStation    : Result := 1;
      PIDXFptr_CapFiscalReceiptType       : Result := 1;
      PIDXFptr_CapMultiContractor         : Result := 0;
      PIDXFptr_CapOnlyVoidLastItem        : Result := 0;
      PIDXFptr_CapPackageAdjustment       : Result := 1;
      PIDXFptr_CapPostPreLine             : Result := 0;
      PIDXFptr_CapSetCurrency             : Result := 0;
      PIDXFptr_CapTotalizerType           : Result := 1;
      PIDXFptr_CapPositiveSubtotalAdjustment: Result := 1;
    else
      Result := 0;
    end;
  except
    on E: Exception do
    begin
      Result := 0;
      HandleException(E);
    end;
  end;
end;

function TDaisyFiscalPrinter.GetPropertyString(PropIndex: Integer): WideString;
begin
  case PropIndex of
    // commmon
    PIDX_CheckHealthText                : Result := FOposDevice.CheckHealthText;
    PIDX_DeviceDescription              : Result := FOposDevice.PhysicalDeviceDescription;
    PIDX_DeviceName                     : Result := FOposDevice.PhysicalDeviceName;
    PIDX_ServiceObjectDescription       : Result := FOposDevice.ServiceObjectDescription;
    // specific
    PIDXFptr_ErrorString                : Result := FOposDevice.ErrorString;
    PIDXFptr_PredefinedPaymentLines     : Result := FPredefinedPaymentLines;
    PIDXFptr_ReservedWord               : Result := FReservedWord;
    PIDXFptr_AdditionalHeader           : Result := FAdditionalHeader;
    PIDXFptr_AdditionalTrailer          : Result := FAdditionalTrailer;
    PIDXFptr_ChangeDue                  : Result := FChangeDue;
    PIDXFptr_PostLine                   : Result := FPostLine;
    PIDXFptr_PreLine                    : Result := FPreLine;
  else
    Result := '';
  end;
end;

function TDaisyFiscalPrinter.GetTotalizer(VatID, OptArgs: Integer;
  out Data: WideString): Integer;

  function ReadGrossTotalizer(OptArgs: Integer): Currency;
  begin
    Result := 0;
    case OptArgs of
      FPTR_TT_DOCUMENT: Result := 0;
      FPTR_TT_DAY: Result := 0;
      FPTR_TT_RECEIPT: Result := Receipt.GetTotal;
      FPTR_TT_GRAND: Result := 0;
    else
      RaiseIllegalError(Format('OptArgs value not supported, %d', [OptArgs]));
    end;
  end;

begin
  try
    case VatID of
      FPTR_GT_GROSS: Data := AmountToOutStr(ReadGrossTotalizer(OptArgs));
      (*
      FPTR_GT_NET                      =  2;
      FPTR_GT_DISCOUNT                 =  3;
      FPTR_GT_DISCOUNT_VOID            =  4;
      FPTR_GT_ITEM                     =  5;
      FPTR_GT_ITEM_VOID                =  6;
      FPTR_GT_NOT_PAID                 =  7;
      FPTR_GT_REFUND                   =  8;
      FPTR_GT_REFUND_VOID              =  9;
      FPTR_GT_SUBTOTAL_DISCOUNT        =  10;
      FPTR_GT_SUBTOTAL_DISCOUNT_VOID   =  11;
      FPTR_GT_SUBTOTAL_SURCHARGES      =  12;
      FPTR_GT_SUBTOTAL_SURCHARGES_VOID =  13;
      FPTR_GT_SURCHARGE                =  14;
      FPTR_GT_SURCHARGE_VOID           =  15;
      FPTR_GT_VAT                      =  16;
      FPTR_GT_VAT_CATEGORY             =  17;
      *)
    end;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.GetVatEntry(VatID, OptArgs: Integer;
  out VatRate: Integer): Integer;
begin
  try
    CheckVATID(VatID);
    VatRate := AmountToInt(Printer.VATRates[VatID]);
    Result := ClearResult;
  except
    on E: Exception do
    begin
      Result := HandleException(E);
    end;
  end;
end;

function TDaisyFiscalPrinter.Open(const DeviceClass, DeviceName: WideString;
  const pDispatch: IDispatch): Integer;
begin
  Result := DoOpen(DeviceClass, DeviceName, pDispatch);
end;

function TDaisyFiscalPrinter.OpenService(const DeviceClass,
  DeviceName: WideString; const pDispatch: IDispatch): Integer;
begin
  Result := DoOpen(DeviceClass, DeviceName, pDispatch);
end;

function TDaisyFiscalPrinter.PrintDuplicateReceipt: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    Printer.Check(Printer.DuplicatePrint(1,0));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintFiscalDocumentLine(
  const DocumentLine: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.PrintFixedOutput(DocumentType, LineNumber: Integer;
  const Data: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.PrintNormal(Station: Integer;
  const AData: WideString): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_NONFISCAL);
    CheckRecStation(Station);
    Printer.Check(Printer.PrintNonfiscalText(AData));

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintPeriodicTotalsReport(const Date1,
  Date2: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.PrintPowerLossReport: Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.PrintRecCash(Amount: Currency): Integer;
begin
  try
    FReceipt.PrintRecCash(Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity, VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItem(Description, Price, GetQuantity(Quantity), VatInfo,
      UnitPrice, UnitName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency;
  VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemAdjustment(AdjustmentType, Description, Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency;
  VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemAdjustmentVoid(AdjustmentType, Description,
      Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemFuel(const Description: WideString;
  Price: Currency; Quantity, VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString; SpecialTax: Currency;
  const SpecialTaxName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemFuel(Description, Price, GetQuantity(Quantity), VatInfo,
      UnitPrice, UnitName, SpecialTax, SpecialTaxName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemFuelVoid(const Description: WideString;
  Price: Currency; VatInfo: Integer; SpecialTax: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemFuelVoid(Description, Price, VatInfo, SpecialTax);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemRefund(const Description: WideString;
  Amount: Currency; Quantity, VatInfo: Integer; UnitAmount: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemRefund(Description, Amount, GetQuantity(Quantity), VatInfo,
      UnitAmount, UnitName);
   Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemRefundVoid(
  const Description: WideString; Amount: Currency; Quantity,
  VatInfo: Integer; UnitAmount: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemRefundVoid(Description, Amount, GetQuantity(Quantity), VatInfo,
      UnitAmount, UnitName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecItemVoid(const Description: WideString;
  Price: Currency; Quantity, VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemVoid(Description, Price, GetQuantity(Quantity), VatInfo,
      UnitPrice, UnitName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecMessage(const Message: WideString): Integer;
var
  Text: WideString;
begin
  try
    CheckEnabled;

    case FMessageType of
      FPTR_MT_DOT_LINE:
      begin
        Text := StringOfChar('.', Printer.Constants.MessageLength);
        FReceipt.PrintRecMessage(Text);
      end;
      FPTR_MT_EMPTY_LINE: FReceipt.PrintRecMessage(' ');
      FPTR_MT_FREE_TEXT: FReceipt.PrintRecMessage(Message);
    else
      FReceipt.PrintRecMessage(Message);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecNotPaid(const Description: WideString;
  Amount: Currency): Integer;
begin
  try
    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT_ENDING) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE, 'Invalid state');

    FReceipt.PrintRecNotPaid(Description, Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecPackageAdjustment(AdjustmentType: Integer;
  const Description, VatAdjustment: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecPackageAdjustment(AdjustmentType,
      Description, VatAdjustment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
  const VatAdjustment: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecPackageAdjustVoid(AdjustmentType, VatAdjustment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecRefund(const Description: WideString;
  Amount: Currency; VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecRefund(Description, Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecRefundVoid(const Description: WideString;
  Amount: Currency; VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecRefundVoid(Description, Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecSubtotal(Amount: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecSubtotal(Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecSubtotalAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecSubtotalAdjustment(AdjustmentType, Description, Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecSubtotalAdjustVoid(AdjustmentType: Integer;
  Amount: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecSubtotalAdjustVoid(AdjustmentType, Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecTaxID(const TaxID: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecTaxID(TaxID);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecTotal(Total, Payment: Currency;
  const Description: WideString): Integer;
begin
  try
    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE, 'OPOS_EFPTR_WRONG_STATE');

    if FCheckTotal and (AmountToInt(FReceipt.GetTotal) <> AmountToInt(Total)) then
    begin
      raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT,
        Format('App total %s, but receipt total %s', [
        AmountToStr(Total), AmountToStr(FReceipt.GetTotal)]));
    end;

    FReceipt.PrintRecTotal(Total, Payment, Description);
    if FReceipt.GetPayment >= FReceipt.GetTotal then
    begin
      SetPrinterState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    end else
    begin
      SetPrinterState(FPTR_PS_FISCAL_RECEIPT_TOTAL);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecVoid(
  const Description: WideString): Integer;
begin
  try
    CheckEnabled;
    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_ENDING) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE);

    FReceipt.PrintRecVoid(Description);
    SetPrinterState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintRecVoidItem(const Description: WideString;
  Amount: Currency; Quantity, AdjustmentType: Integer;
  Adjustment: Currency; VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecVoidItem(Description, Amount, GetQuantity(Quantity),
      AdjustmentType, Adjustment, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintReport(ReportType: Integer; const StartNum,
  EndNum: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.PrintXReport: Integer;
var
  R: TDFPReportAnswer;
begin
  try
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_REPORT);
    try
      Printer.Check(Printer.XReport(R));
    finally
      SetPrinterState(FPTR_PS_MONITOR);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.PrintZReport: Integer;
var
  R: TDFPReportAnswer;
begin
  try
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_REPORT);
    try
      Printer.Check(Printer.ZReport(R));
      Params.DayOpened := False;
      SaveUsrParameters(Params, FOposDevice.DeviceName, Logger);
    finally
      SetPrinterState(FPTR_PS_MONITOR);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.Release1: Integer;
begin
  Result := DoRelease;
end;

function TDaisyFiscalPrinter.ReleaseDevice: Integer;
begin
  Result := DoRelease;
end;

function TDaisyFiscalPrinter.ResetPrinter: Integer;
begin
  try
    CheckEnabled;
    SetPrinterState(FPTR_PS_MONITOR);
    Printer.Check(Printer.Reset);
    FReceipt := nil;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDaisyFiscalPrinter.SetCurrency(NewCurrency: Integer): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetDate(const Date: WideString): Integer;
var
  ADate: TDateTime;
begin
  try
    CheckEnabled;
    ADate := OposDecodeDate(Date);
    Printer.Check(Printer.WriteDateTime(ADate));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetHeaderLine(LineNumber: Integer;
  const Text: WideString; DoubleWidth: WordBool): Integer;
var
  S: AnsiString;
begin
  try
    CheckEnabled;
    if (LineNumber <= 0)or(LineNumber > FNumHeaderLines) then
      raiseIllegalError('Invalid line number');

    Printer.Check(Printer.WriteText(DFP_SP_HEADER_START_LINE + LineNumber-1, Text));
    Printer.Check(Printer.ReadParameter(DFP_SP_HEADER_TYPE, S));
    if Length(S) >= 8 then
    begin
      if DoubleWidth then
        S[LineNumber] := '1'
      else
        S[LineNumber] := '0';
      Printer.Check(Printer.WriteParameter(DFP_SP_HEADER_TYPE, S));
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetPOSID(const POSID,
  CashierID: WideString): Integer;
var
  Operator: TDFPOperatorName;
begin
  try
    Operator.Number := Params.OperatorNumber;
    Operator.Password := Params.OperatorPassword;
    Operator.Name := CashierID;
    Printer.Check(Printer.WriteOperatorName(Operator));
    Printer.Check(Printer.WritePrinterNumber(StrToInt(POSID)));

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TDaisyFiscalPrinter.SetPropertyNumber(PropIndex, Number: Integer);
begin
  try
    case PropIndex of
      // common
      PIDX_DeviceEnabled: SetDeviceEnabled(IntToBool(Number));
      PIDX_DataEventEnabled: FOposDevice.DataEventEnabled := IntToBool(Number);
      PIDX_PowerNotify: FOposDevice.PowerNotify := Number;
      PIDX_BinaryConversion: FOposDevice.BinaryConversion := Number;
      // Specific
      PIDXFptr_AsyncMode: FAsyncMode := IntToBool(Number);
      PIDXFptr_CheckTotal: FCheckTotal := IntToBool(Number);
      PIDXFptr_DateType: FDateType := Number;
      PIDXFptr_DuplicateReceipt: FDuplicateReceipt := IntToBool(Number);
      PIDXFptr_FiscalReceiptStation: FFiscalReceiptStation := Number;

      PIDXFptr_FiscalReceiptType:
      begin
        CheckState(FPTR_PS_MONITOR);
        FFiscalReceiptType := Number;
      end;
      PIDXFptr_FlagWhenIdle: FFlagWhenIdle := IntToBool(Number);
      PIDXFptr_MessageType: FMessageType := Number;
      PIDXFptr_SlipSelection: FSlipSelection := Number;
      PIDXFptr_TotalizerType: FTotalizerType := Number;
      PIDX_FreezeEvents: FOposDevice.FreezeEvents := Number <> 0;
    end;
    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TDaisyFiscalPrinter.SetPropertyString(PropIndex: Integer;
  const Text: WideString);
begin
  try
    FOposDevice.CheckOpened;
    case PropIndex of
      PIDXFptr_AdditionalHeader   : FAdditionalHeader := Text;
      PIDXFptr_AdditionalTrailer  : FAdditionalTrailer := Text;
      PIDXFptr_PostLine           : FPostLine := Text;
      PIDXFptr_PreLine            : FPreLine := Text;
      PIDXFptr_ChangeDue:
      begin
        RaiseIllegalError('ChangeDue not supported');
        FChangeDue := Text;
      end;
    end;
    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetStoreFiscalID(const ID: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetTrailerLine(LineNumber: Integer;
  const Text: WideString; DoubleWidth: WordBool): Integer;
var
  S: AnsiString;
begin
  try
    CheckEnabled;
    if (LineNumber <= 0)or(LineNumber > FNumTrailerLines) then
      raiseIllegalError('Invalid line number');

    Printer.Check(Printer.WriteText(DFP_SP_TRAILER_START_LINE + LineNumber-1, Text));
    Printer.Check(Printer.ReadParameter(DFP_SP_TRAILER_TYPE, S));
    if Length(S) >= 6 then
    begin
      if DoubleWidth then
        S[LineNumber] := '1'
      else
        S[LineNumber] := '0';
      Printer.Check(Printer.WriteParameter(DFP_SP_HEADER_TYPE, S));
    end;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetVatTable: Integer;
begin
  try
    CheckEnabled;
    Printer.Check(Printer.WriteVATRates(FVatRates));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.SetVatValue(VatID: Integer;
  const VatValue: WideString): Integer;
var
  VatValueInt: Integer;
begin
  try
    CheckEnabled;
    // There are 6 taxes in Shtrih-M ECRs available
    if (VatID < MinVATRate)or(VatID > MaxVATRate) then
      InvalidParameterValue('VatID', IntToStr(VatID));

    VatValueInt := StrToInt(VatValue);
    if VatValueInt < MinVatValue then
      InvalidParameterValue('VatValue', VatValue);

    if VatValueInt > MaxVatValue then
      InvalidParameterValue('VatValue', VatValue);

    FVatRates[VatID] := VatValueInt/100;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.VerifyItem(const ItemName: WideString;
  VatID: Integer): Integer;
begin
  Result := IllegalError;
end;

procedure TDaisyFiscalPrinter.PrinterErrorEvent(ASender: TObject; ResultCode: Integer;
  ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  Logger.Debug(Format('PtrErrorEvent: %d, %d, %d', [
    ResultCode, ResultCodeExtended, ErrorLocus]));
end;

procedure TDaisyFiscalPrinter.PrinterDirectIOEvent(ASender: TObject; EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  Logger.Debug(Format('PtrDirectIOEvent: %d, %d, %s', [
    EventNumber, pData, pString]));
end;

procedure TDaisyFiscalPrinter.PrinterOutputCompleteEvent(ASender: TObject; OutputID: Integer);
begin
  Logger.Debug(Format('PtrOutputCompleteEvent: %d', [OutputID]));
end;

function TDaisyFiscalPrinter.DoOpen(const DeviceClass, DeviceName: WideString;
  const pDispatch: IDispatch): Integer;
begin
  try
    Initialize;
    FOposDevice.Open(DeviceClass, DeviceName, GetEventInterface(pDispatch));
    if FLoadParamsEnabled then
    begin
      LoadParameters(FParams, DeviceName, FLogger);
    end;
    Logger.MaxCount := FParams.LogMaxCount;
    Logger.Enabled := FParams.LogFileEnabled;
    Logger.FilePath := FParams.LogFilePath;
    Logger.DeviceName := DeviceName;

    if FPrinter = nil then
    begin
      FPrinter := TDaisyPrinter.Create(Port, Logger);
    end;
    Printer.CommandTimeout := Params.CommandTimeout;
    Printer.RegKeyName := TPrinterParametersReg.GetUsrKeyName(DeviceName);
    Printer.LoadParams;
    Printer.OnStatusUpdate := PrinterStatusUpdate;

    Logger.Debug(Logger.Separator);
    Logger.Debug('LOG START');
    Logger.Debug(FOposDevice.ServiceObjectDescription);
    Logger.Debug('ServiceObjectVersion : ' + IntToStr(FOposDevice.ServiceObjectVersion));
    Logger.Debug('File version         : ' + GetFileVersionInfoStr);
    Logger.Debug('System               : ' + GetSystemVersionStr);
    Logger.Debug('System locale        : ' + GetSystemLocaleStr);
    Logger.Debug(Logger.Separator);
    FParams.WriteLogParameters;

    FQuantityDecimalPlaces := 3;
    Result := ClearResult;
  except
    on E: Exception do
    begin
      DoCloseDevice;
      Result := HandleException(E);
    end;
  end;
end;

function TDaisyFiscalPrinter.DoCloseDevice: Integer;
begin
  try
    Result := ClearResult;
    if not FOposDevice.Opened then Exit;

    SetDeviceEnabled(False);
    FOposDevice.Close;
    Port.Close;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDaisyFiscalPrinter.GetEventInterface(FDispatch: IDispatch): IOposEvents;
begin
  Result := TOposEventsRCS.Create(FDispatch);
end;

function GetResultCodeExtended(Code: Integer): Integer;
begin
  case Code of
    // Fiscal memory is full
    30: Result := OPOS_EFPTR_FISCAL_MEMORY_FULL;
    // More than 24 hours from first receipt without issuing daily Z report';
    82: Result := OPOS_EFPTR_DAY_END_REQUIRED;
    // Fiscal memory does not exist
    70: Result := OPOS_EFPTR_MISSING_DEVICES;
    // Customer display not connected
    EDisplayDisconnected: Result := OPOS_EFPTR_MISSING_DEVICES;
    ERecJrnEmpty: Result := OPOS_EFPTR_REC_EMPTY;
    EDateTimeNotSet: Result := OPOS_EFPTR_CLOCK_ERROR;
  else
    Result := 300 + Code;
  end;
end;

function TDaisyFiscalPrinter.HandleException(E: Exception): Integer;
var
  OPOSError: TOPOSError;
  DriverError: EDriverError;
  OPOSException: EOPOSException;
begin
  if E is EConnectionError then
  begin
    FOposDevice.PowerState := OPOS_PS_OFF_OFFLINE;
    OPOSError.ResultCode := OPOS_E_NOHARDWARE;
    OPOSError.ErrorString := E.Message;
    OPOSError.ResultCodeExtended := 0;
    FOposDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    OPOSError.ResultCode := OPOS_E_EXTENDED;
    OPOSError.ErrorString := GetExceptionMessage(E);
    OPOSError.ResultCodeExtended := GetResultCodeExtended(DriverError.Code);
    FOposDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  if E is EOPOSException then
  begin
    OPOSException := E as EOPOSException;
    OPOSError.ErrorString := GetExceptionMessage(E);
    OPOSError.ResultCode := OPOSException.ResultCode;
    OPOSError.ResultCodeExtended := OPOSException.ResultCodeExtended;
    FOposDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  OPOSError.ErrorString := GetExceptionMessage(E);
  OPOSError.ResultCode := OPOS_E_FAILURE;
  OPOSError.ResultCodeExtended := OPOS_SUCCESS;
  FOposDevice.HandleException(OPOSError);
  Result := OPOSError.ResultCode;
end;

function GetMaxRecLine(const RecLineCharsList: WideString): Integer;
var
  S: WideString;
  K: Integer;
  N: Integer;
begin
  K := 1;
  Result := 0;
  while true do
  begin
    S := GetString(RecLineCharsList, K, [',']);
    if S = '' then Break;
    N := StrToIntDef(S, 0);
    if N > Result then
      Result := N;
    Inc(K);
  end;
end;

procedure TDaisyFiscalPrinter.SetDeviceEnabled(Value: Boolean);
begin
  if Value <> FDeviceEnabled then
  begin
    if Value then
    begin
      Printer.Check(Printer.Connect);
      FOposDevice.PowerState := OPOS_PS_ONLINE;

      Printer.Check(Printer.ReadIntParameter(DFP_SP_NUM_HEADER_LINES, FNumHeaderLines));
      Printer.Check(Printer.ReadIntParameter(DFP_SP_NUM_TRAILER_LINES, FNumTrailerLines));
      Printer.Check(Printer.ReadIntParameter(DFP_SP_DECIMAL_POINT, FAmountDecimalPlaces));

      FMessageLength := Printer.Constants.MessageLength;
      FDescriptionLength := Printer.Constants.DescriptionLength;

      FOposDevice.PhysicalDeviceDescription := Format('%s, %s %s, %s', [
        Printer.Diagnostic.FirmwareVersion, Printer.Diagnostic.FirmwareDate,
        Printer.Diagnostic.FirmwareTime, Printer.Diagnostic.ChekSum]);

      Logger.Debug('PhysicalDeviceDescription: ' + FOposDevice.PhysicalDeviceDescription);

      StartDeviceThread;
    end else
    begin
      FOposDevice.PowerState := OPOS_PS_UNKNOWN;
      StopDeviceThread;
      Printer.Disconnect;
    end;
    FDeviceEnabled := Value;
    FOposDevice.DeviceEnabled := Value;
  end;
end;

procedure TDaisyFiscalPrinter.StartDeviceThread;
begin
  if Params.PollInterval <> 0 then
  begin
    FDeviceThread.Free;
    FDeviceThread := TNotifyThread.Create(True);
    FDeviceThread.OnExecute := DeviceProc;
    FDeviceThread.Resume;
  end;
end;

procedure TDaisyFiscalPrinter.StopDeviceThread;
begin
  FDeviceThread.Free;
  FDeviceThread := nil;
end;

procedure TDaisyFiscalPrinter.PrinterStatusUpdate(Sender: TObject);
begin
  FOposDevice.PowerState := OPOS_PS_ONLINE;
  SetRecEmpty(Printer.Status.RecJrnEmpty);
end;

procedure TDaisyFiscalPrinter.SetRecEmpty(Value: Boolean);
begin
  if Value <> FRecEmpty then
  begin
    FRecEmpty := Value;
    if Value then
      FOposDevice.StatusUpdateEvent(FPTR_SUE_REC_EMPTY)
    else
      FOposDevice.StatusUpdateEvent(FPTR_SUE_REC_PAPEROK);
  end;
end;

procedure TDaisyFiscalPrinter.DeviceProc(Sender: TObject);
var
  TickCount: Integer;
begin
  Logger.Debug('DeviceProc.Start');
  try
    while not FDeviceThread.Terminated do
    begin
      try
        Printer.ReadStatus;
      except
        on E: Exception do
        begin
          Logger.Error('DeviceProc', E);
          FOposDevice.PowerState := OPOS_PS_OFF_OFFLINE;
        end;
      end;
      TickCount := Integer(GetTickCount);
      repeat
        Sleep(20);
        if FDeviceThread.Terminated then Break;
      until Integer(GetTickCount) > (TickCount + Params.PollInterval * 1000);
    end;
  except
    on E: Exception do
      Logger.Error('DeviceProc: ', E);
  end;
  Logger.Debug('DeviceProc.End');
end;

procedure TDaisyFiscalPrinter.Print(Receipt: TCashReceipt);
var
  P: TDFPCashRequest;
  R: TDFPCashResponse;
begin
  P.Amount := Receipt.GetTotal;
  if Receipt.RecType = FPTR_RT_CASH_OUT then
    P.Amount := -Receipt.GetTotal;

  if Receipt.Lines.Count > 0 then
    P.Text1 := Receipt.Lines[0];
  if Receipt.Lines.Count > 1 then
    P.Text2 := Receipt.Lines[1];

  Printer.Check(Printer.PrintCash(P, R));
end;

procedure TDaisyFiscalPrinter.Print(Receipt: TSalesReceipt);
begin
  if Receipt.IsRefund then
  begin
    PrintRefundReceipt(Receipt);
  end else
  begin
    PrintSalesReceipt(Receipt);
  end;
end;

procedure TDaisyFiscalPrinter.PrintRefundReceipt(Receipt: TSalesReceipt);
var
  i: Integer;
  Lines: TTntStrings;
  RecNumber: Integer;
  CashRequest: TDFPCashRequest;
  CashResponse: TDFPCashResponse;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := SalesReceiptToText(Receipt);
    // Print nonfiscal receipt
    Printer.Check(Printer.StartNonfiscalReceipt(RecNumber));
    for i := 0 to Lines.Count-1 do
    begin
      Printer.Check(Printer.PrintNonfiscalText(Lines[i]));
    end;
    Printer.Check(Printer.EndNonfiscalReceipt(RecNumber));
  finally
    Lines.Free;
  end;
  // CashOut receipt
  CashRequest.Amount := -Abs(Receipt.GetTotal);
  CashRequest.Text1 := Params.RefundCashoutLine1;
  CashRequest.Text2 := Params.RefundCashoutLine2;
  Printer.Check(Printer.PrintCash(CashRequest, CashResponse));
end;

function TDaisyFiscalPrinter.SalesReceiptToText(Receipt: TSalesReceipt): WideString;
const
  AdjustmentName: array [Boolean] of WideString = ('CHARGE', 'DISCOUNT');
var
  i: Integer;
  Text: AnsiString;
  Item: TReceiptItem;
  SaleQuantity: Double;
  SalePrice: Currency;
  SalesItem: TSalesItem;
  Lines: TTntStrings;
  Barcode: TBarcodeRec;
  AdjustmentText: WideString;
begin
  Lines := TTntStringList.Create;
  try
    if Receipt.IsRefund then
    begin
      if Params.RefundCashoutLine1 <> '' then
        Lines.Add(Params.RefundCashoutLine1);
      if Params.RefundCashoutLine2 <> '' then
        Lines.Add(Params.RefundCashoutLine2);
    end;
    for i := 0 to Receipt.Items.Count-1 do
    begin
      Item := Receipt.Items[i];
      if Item is TSalesItem then
      begin
        SalesItem := Item as TSalesItem;

        if SalesItem.Description <> '' then
          Lines.Add(SalesItem.Description);

        if AmountToInt(SalesItem.UnitPrice) = 0 then
        begin
          SaleQuantity := 1;
          SalePrice := SalesItem.Price;
        end else
        begin
          SaleQuantity := SalesItem.Quantity;
          SalePrice := SalesItem.UnitPrice;
        end;
        Text := Format('%.2f x %.3f = %.2f', [SalePrice, SaleQuantity, Receipt.RoundAmount(SalePrice * SaleQuantity)]);
        Text := AlignLines('', Text, Printer.Constants.MessageLength);
        Lines.Add(Text);
        // Adjustment
        if SalesItem.Adjustment <> 0 then
        begin
          AdjustmentText := AdjustmentName[SalesItem.Adjustment < 0];
          if SalesItem.AdjustmentText <> '' then
            AdjustmentText := SalesItem.AdjustmentText;
          Text := Format('= %.2f', [SalesItem.Adjustment]);
          Text := AlignLines(AdjustmentText, Text, Printer.Constants.MessageLength);
          Lines.Add(Text);
        end;
      end;
      if Item is TTextItem then
      begin
        Text := (Item as TTextItem).Text;
        Lines.Add(Text);
      end;
      if Item is TBarcodeItem then
      begin
        Barcode := StrToBarcode((Item as TBarcodeItem).Barcode);
        Lines.Add(Barcode.Data);
      end;
    end;
    // Adjustment
    if Receipt.AdjustmentPercent <> 0 then
    begin
      AdjustmentText := AdjustmentName[Receipt.AdjustmentPercent < 0];
      if Receipt.AdjustmentText <> '' then
        AdjustmentText := Receipt.AdjustmentText;
      Text := Format('%.2f %%', [Receipt.AdjustmentPercent]);
      Text := AlignLines(AdjustmentText, Text, Printer.Constants.MessageLength);
      Lines.Add(Text);
    end;

    Text := Format('= %.2f', [Receipt.GetTotal]);
    Text := AlignLines('TOTAL', Text, Printer.Constants.MessageLength);
    Lines.Add(Text);
    if Receipt.Lines.Count > 0 then
    begin
      Lines.AddStrings(Receipt.Lines);
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TDaisyFiscalPrinter.PrintSalesReceipt(Receipt: TSalesReceipt);
var
  i: Integer;
  Sale: TDFPSale;
  Text: WideString;
  Amount: Currency;
  Barcode: WideString;
  Item: TReceiptItem;
  SalesItem: TSalesItem;
  RecNumber: TDFPRecNumber;
  Operator: TDFPOperatorPassword;
  Subtotal: TDFPSubtotal;
  SubtotalResponse: TDFPSubtotalResponse;
  Total: TDFPTotal;
  TotalResponse: TDFPTotalResponse;
begin
  Operator.Number := Params.OperatorNumber;
  Operator.Password := Params.OperatorPassword;
  Printer.Check(Printer.StartFiscalReceipt(Operator, RecNumber));
  PrintText(FAdditionalHeader);

  for i := 0 to Receipt.Items.Count-1 do
  begin
    Item := Receipt.Items[i];
    if Item is TSalesItem then
    begin
      SalesItem := Item as TSalesItem;

      Sale.Text1 := SalesItem.Description;
      Sale.Text2 := '';
      Sale.Tax := SalesItem.VatInfo;
      if AmountToInt(SalesItem.UnitPrice) = 0 then
      begin
        Sale.Quantity := 1;
        Sale.Price := SalesItem.Price;
      end else
      begin
        Sale.Quantity := SalesItem.Quantity;
        Sale.Price := SalesItem.UnitPrice;
      end;

      Sale.DiscountPercent := 0;
      Sale.DiscountAmount := SalesItem.Adjustment;
      Printer.Check(Printer.Sale(Sale));
    end;
    if Item is TTextItem then
    begin
      Text := (Item as TTextItem).Text;
      Printer.Check(Printer.PrintFiscalText(Text));
    end;
    if Item is TBarcodeItem then
    begin
      Barcode := (Item as TBarcodeItem).Barcode;
      PrintBarcodeText(Barcode);
    end;
  end;
  // Percent subtotal adjustment
  if Receipt.AdjustmentPercent <> 0 then
  begin
    Subtotal.PrintSubtotal := True;
    Subtotal.DisplaySubtotal := False;
    Subtotal.AdjustmentPercent := Receipt.AdjustmentPercent;
    Printer.Check(Printer.Subtotal(Subtotal, SubtotalResponse));
  end;
  // Payments
  for i := Low(Receipt.Payments) to High(Receipt.Payments) do
  begin
    Amount := Receipt.Payments[i];
    if Amount <> 0 then
    begin
      Total.Text1 := '';
      Total.Text2 := '';
      Total.PaymentMode := i + 1;
      Total.Amount := Amount;
      Printer.Check(Printer.PrintTotal(Total, TotalResponse));
    end;
  end;
  PrintText(FAdditionalTrailer);
  // EndFiscalReceipt
  Printer.Check(Printer.EndFiscalReceipt(RecNumber));
end;

procedure TDaisyFiscalPrinter.PrintText(const Text: WideString);
var
  i: Integer;
  Lines: TTntStrings;
begin
  if Text = '' then Exit;
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      Printer.Check(Printer.PrintFiscalText(Lines[i]));
    end;
  finally
    Lines.Free;
  end;
end;

function GetLastLine(const Line: WideString): WideString;
var
  P: Integer;
begin
  Result := Line;
  while True do
  begin
    P := Pos(CRLF, Result);
    if P <= 0 then Break;
    Result := Copy(Result, P+2, Length(Result));
  end;
end;

procedure TDaisyFiscalPrinter.PrintBarcode(const BarcodeText: string);
begin
  if FPrinterState.State = FPTR_PS_NONFISCAL then
  begin
    PrintBarcodeText(BarcodeText);
  end else
  begin
    Receipt.PrintBarcode(BarcodeText);
  end;
end;

procedure TDaisyFiscalPrinter.PrintBarcodeText(const BarcodeText: string);

  function BTypeToDFPBType(BType: Integer): Integer;
  begin
    case BType of
      DIO_BARCODE_CODE128A: Result := DFP_BT_CODE128;
      DIO_BARCODE_CODE128B: Result := DFP_BT_CODE128;
      DIO_BARCODE_CODE128C: Result := DFP_BT_CODE128;
      DIO_BARCODE_CODE39: Result := DFP_BT_CODE39;
      DIO_BARCODE_CODE25INTERLEAVED: Result := DFP_BT_CODE25ITF;
      DIO_BARCODE_CODE25INDUSTRIAL: Result := DFP_BT_CODE25ITFM10;
      DIO_BARCODE_CODE93: Result := DFP_BT_CODE93;
      DIO_BARCODE_POSTNET: Result := DFP_BT_POSTNET;
      DIO_BARCODE_CODABAR: Result := DFP_BT_CODABAR;
      DIO_BARCODE_EAN8: Result := DFP_BT_EAN8;
      DIO_BARCODE_EAN13: Result := DFP_BT_EAN13;
      DIO_BARCODE_UPC_A: Result := DFP_BT_UPCA;
      DIO_BARCODE_UPC_E0: Result := DFP_BT_UPCE;
      DIO_BARCODE_UPC_E1: Result := DFP_BT_UPCE;
    else
      raise Exception.CreateFmt('Invalid barcode type, %d', [BType]);
    end;
  end;

  function AlignmentToPosition(Alignment: Integer): Integer;
  begin
    case Alignment of
      BARCODE_ALIGNMENT_CENTER: Result := DFP_BP_CENTER;
      BARCODE_ALIGNMENT_LEFT: Result := DFP_BP_LEFT;
      BARCODE_ALIGNMENT_RIGHT: Result := DFP_BP_RIGHT;
    else
      raise Exception.CreateFmt('Invalid alignment value, %d', [Alignment]);
    end;
  end;

var
  Barcode: TBarcodeRec;
  ABarcode: TDFPBarcode;
begin
  Barcode := StrToBarcode(BarcodeText);
  ABarcode.BType := BTypeToDFPBType(Barcode.BarcodeType);
  ABarcode.Data := Barcode.Data;
  ABarcode.Position := AlignmentToPosition(Barcode.Alignment);
  ABarcode.Scale := Barcode.ModuleWidth;
  ABarcode.Heightmm := Barcode.Height;
  ABarcode.Text := True;
  Printer.Check(Printer.PrintBarcode2(ABarcode));
end;

end.
