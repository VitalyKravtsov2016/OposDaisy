unit DatecsFiscalPrinter;

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
  OPOSDatecsLib_TLB, LogFile, WException, VersionInfo, DriverError,
  DatecsPrinter2, FiscalPrinterState, ServiceVersion,
  PrinterParameters, PrinterParametersX,
  CustomReceipt, NonFiscalDoc, CashInReceipt, CashOutReceipt,
  SalesReceipt, TextDocument, ReceiptItem, StringUtils, DebugUtils, VatRate,
  uZintBarcode, uZintInterface, FileUtils, SerialPort, PrinterPort, SocketPort, ReceiptTemplate, RawPrinterPort,
  PrinterTypes, DirectIOAPI, BarcodeUtils, PrinterParametersReg;

const
  FPTR_DEVICE_DESCRIPTION = 'Datecs OPOS driver';

  // VatID values
  MinVatID = 1;
  MaxVatID = 6;

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

  { TDatecsFiscalPrinter }

  TDatecsFiscalPrinter = class(TComponent, IFiscalPrinterService_1_12)
  private
    FPrinter: TDatecsPrinter;
    FParams: TPrinterParameters;
    FOposDevice: TOposServiceDevice19;

    FLines: TTntStrings;
    FCheckNumber: WideString;
    FTestMode: Boolean;
    FLoadParamsEnabled: Boolean;
    FPOSID: WideString;
    FCashierID: WideString;
    FLogger: ILogFile;
    FDocument: TTextDocument;
    FDuplicate: TTextDocument;
    FReceipt: TCustomReceipt;
    FPrinterState: TFiscalPrinterState;
    FVatValues: array [MinVatID..MaxVatID] of Integer;
    FLineChars: Integer;
    FLineHeight: Integer;
    FLineSpacing: Integer;
    FPrefix: WideString;
    FCapRecBold: Boolean;
    FCapRecDwideDhigh: Boolean;
    FExternalCheckNumber: WideString;
    FCodePage: Integer;

    function GetReceiptItemText(ReceiptItem: TSalesReceiptItem;
      Item: TTemplateItem): WideString;
    function ReceiptItemByText(ReceiptItem: TSalesReceiptItem;
      Item: TTemplateItem): WideString;
    function ReceiptFieldByText(Receipt: TSalesReceipt;
      Item: TTemplateItem): WideString;
    procedure AddItems(Items: TList);
    procedure BeginDocument(APrintHeader: boolean);
    procedure UpdateTemplateItem(Item: TTemplateItem);
    procedure DioPrintBarcode(var pData: Integer; var pString: WideString);
    procedure DioPrintBarcodeHex(var pData: Integer;
      var pString: WideString);
    procedure DioSetDriverParameter(var pData: Integer;
      var pString: WideString);
    procedure DioGetDriverParameter(var pData: Integer;
      var pString: WideString);
    function CreatePrinter: TDatecsPrinter;
  public
    procedure PrintDocumentSafe(Document: TTextDocument);
    procedure CheckCanPrint;
    function GetVatRate(Code: Integer): TVatRate;
    function AmountToStr(Value: Currency): AnsiString;
    function AmountToOutStr(Value: Currency): AnsiString;
    function AmountToStrEq(Value: Currency): AnsiString;
    function CreateSerialPort: TSerialPort;
  public
    procedure PrintReceiptTemplate(Receipt: TSalesReceipt; Template: TReceiptTemplate);
    function GetHeaderItemText(Receipt: TSalesReceipt; Item: TTemplateItem): WideString;

    procedure Initialize;
    procedure CheckEnabled;
    function IllegalError: Integer;
    procedure CheckState(AState: Integer);
    procedure SetPrinterState(Value: Integer);
    function DoClose: Integer;
    function GetPrinterStation(Station: Integer): Integer;
    procedure Print(Receipt: TCashInReceipt); overload;
    procedure Print(Receipt: TCashOutReceipt); overload;
    procedure Print(Receipt: TSalesReceipt); overload;
    function GetPrinterState: Integer;
    function DoRelease: Integer;
    procedure CheckCapSetVatTable;
    function CreateReceipt(FiscalReceiptType: Integer): TCustomReceipt;
    procedure PrinterErrorEvent(ASender: TObject; ResultCode,
      ResultCodeExtended, ErrorLocus: Integer;
      var pErrorResponse: Integer);
    procedure PrintDocument(Document: TTextDocument);
    function GetQuantity(Value: Integer): Double;
    procedure PrinterDirectIOEvent(ASender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString);
    procedure PrinterOutputCompleteEvent(ASender: TObject;
      OutputID: Integer);

    property Receipt: TCustomReceipt read FReceipt;
    property Document: TTextDocument read FDocument;
    property Duplicate: TTextDocument read FDuplicate;
    property Printer: TDatecsPrinter read FPrinter;
    property PrinterState: Integer read GetPrinterState write SetPrinterState;
  private
    FPostLine: WideString;
    FPreLine: WideString;

    FDeviceEnabled: Boolean;
    FCheckTotal: Boolean;
    // boolean
    FDayOpened: Boolean;
    FCapRecPresent: Boolean;
    FCapJrnPresent: Boolean;
    FCapSlpPresent: Boolean;
    FCapAdditionalLines: Boolean;
    FCapAmountAdjustment: Boolean;
    FCapAmountNotPaid: Boolean;
    FCapCheckTotal: Boolean;
    FCapDoubleWidth: Boolean;
    FCapDuplicateReceipt: Boolean;
    FCapFixedOutput: Boolean;
    FCapHasVatTable: Boolean;
    FCapIndependentHeader: Boolean;
    FCapItemList: Boolean;
    FCapNonFiscalMode: Boolean;
    FCapOrderAdjustmentFirst: Boolean;
    FCapPercentAdjustment: Boolean;
    FCapPositiveAdjustment: Boolean;
    FCapPowerLossReport: Boolean;
    FCapPredefinedPaymentLines: Boolean;
    FCapReceiptNotPaid: Boolean;
    FCapRemainingFiscalMemory: Boolean;
    FCapReservedWord: Boolean;
    FCapSetPOSID: Boolean;
    FCapSetStoreFiscalID: Boolean;
    FCapSetVatTable: Boolean;
    FCapSlpFiscalDocument: Boolean;
    FCapSlpFullSlip: Boolean;
    FCapSlpValidation: Boolean;
    FCapSubAmountAdjustment: Boolean;
    FCapSubPercentAdjustment: Boolean;
    FCapSubtotal: Boolean;
    FCapTrainingMode: Boolean;
    FCapValidateJournal: Boolean;
    FCapXReport: Boolean;
    FCapAdditionalHeader: Boolean;
    FCapAdditionalTrailer: Boolean;
    FCapChangeDue: Boolean;
    FCapEmptyReceiptIsVoidable: Boolean;
    FCapFiscalReceiptStation: Boolean;
    FCapFiscalReceiptType: Boolean;
    FCapMultiContractor: Boolean;
    FCapOnlyVoidLastItem: Boolean;
    FCapPackageAdjustment: Boolean;
    FCapPostPreLine: Boolean;
    FCapSetCurrency: Boolean;
    FCapTotalizerType: Boolean;
    FCapPositiveSubtotalAdjustment: Boolean;
    FCapSetHeader: Boolean;
    FCapSetTrailer: Boolean;

    FAsyncMode: Boolean;
    FDuplicateReceipt: Boolean;
    FFlagWhenIdle: Boolean;
    // integer
    FCountryCode: Integer;
    FErrorLevel: Integer;
    FErrorOutID: Integer;
    FErrorState: Integer;
    FErrorStation: Integer;
    FQuantityDecimalPlaces: Integer;
    FQuantityLength: Integer;
    FSlipSelection: Integer;
    FActualCurrency: Integer;
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
    FUnitsUpdated: Boolean;
    FCashiersUpdated: Boolean;
    FCashBoxesUpdated: Boolean;
    FReceiptJson: WideString;

    FPtrMapCharacterSet: Boolean;

    function DoCloseDevice: Integer;
    function DoOpen(const DeviceClass, DeviceName: WideString;
      const pDispatch: IDispatch): Integer;
    function GetEventInterface(FDispatch: IDispatch): IOposEvents;
    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    procedure SetDeviceEnabled(Value: Boolean);
    function HandleDriverError(E: EDriverError): TOPOSError;
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function DecodeString(const Text: WideString): WideString;
    function EncodeString(const S: WideString): WideString;
    function RenderQRCode(const BarcodeData: AnsiString): AnsiString;
    procedure PrintBarcode(const Barcode: string);

    property Logger: ILogFile read FLogger;
    property Params: TPrinterParameters read FParams;
    property TestMode: Boolean read FTestMode write FTestMode;
    property OposDevice: TOposServiceDevice19 read FOposDevice;
    property LoadParamsEnabled: Boolean read FLoadParamsEnabled write FLoadParamsEnabled;
  end;

implementation

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

function BTypeToZBType(BarcodeType: Integer): TZBType;
begin
  case BarcodeType of
    DIO_BARCODE_EAN13_INT: Result := tBARCODE_EANX;
    DIO_BARCODE_CODE128A: Result := tBARCODE_CODE128;
    DIO_BARCODE_CODE128B: Result := tBARCODE_CODE128;
    DIO_BARCODE_CODE128C: Result := tBARCODE_CODE128;
    DIO_BARCODE_CODE39: Result := tBARCODE_CODE39;
    DIO_BARCODE_CODE25INTERLEAVED: Result := tBARCODE_C25INTER;
    DIO_BARCODE_CODE25INDUSTRIAL: Result := tBARCODE_C25IND;
    DIO_BARCODE_CODE25MATRIX: Result := tBARCODE_C25MATRIX;
    DIO_BARCODE_CODE39EXTENDED: Result := tBARCODE_EXCODE39;
    DIO_BARCODE_CODE93: Result := tBARCODE_CODE93;
    DIO_BARCODE_CODE93EXTENDED: Result := tBARCODE_CODE93;
    DIO_BARCODE_MSI: Result := tBARCODE_MSI_PLESSEY;
    DIO_BARCODE_POSTNET: Result := tBARCODE_POSTNET;
    DIO_BARCODE_CODABAR: Result := tBARCODE_CODABAR;
    DIO_BARCODE_EAN8: Result := tBARCODE_EANX;
    DIO_BARCODE_EAN13: Result := tBARCODE_EANX;
    DIO_BARCODE_UPC_A: Result := tBARCODE_UPCA;
    DIO_BARCODE_UPC_E0: Result := tBARCODE_UPCE;
    DIO_BARCODE_UPC_E1: Result := tBARCODE_UPCE;
    DIO_BARCODE_EAN128A: Result := tBARCODE_EAN128;
    DIO_BARCODE_EAN128B: Result := tBARCODE_EAN128;
    DIO_BARCODE_EAN128C: Result := tBARCODE_EAN128;
    DIO_BARCODE_CODE11: Result := tBARCODE_CODE11;
    DIO_BARCODE_C25IATA: Result := tBARCODE_C25IATA;
    DIO_BARCODE_C25LOGIC: Result := tBARCODE_C25LOGIC;
    DIO_BARCODE_DPLEIT: Result := tBARCODE_DPLEIT;
    DIO_BARCODE_DPIDENT: Result := tBARCODE_DPIDENT;
    DIO_BARCODE_CODE16K: Result := tBARCODE_CODE16K;
    DIO_BARCODE_CODE49: Result := tBARCODE_CODE49;
    DIO_BARCODE_FLAT: Result := tBARCODE_FLAT;
    DIO_BARCODE_RSS14: Result := tBARCODE_RSS14;
    DIO_BARCODE_RSS_LTD: Result := tBARCODE_RSS_LTD;
    DIO_BARCODE_RSS_EXP: Result := tBARCODE_RSS_EXP;
    DIO_BARCODE_TELEPEN: Result := tBARCODE_TELEPEN;
    DIO_BARCODE_FIM: Result := tBARCODE_FIM;
    DIO_BARCODE_LOGMARS: Result := tBARCODE_LOGMARS;
    DIO_BARCODE_PHARMA: Result := tBARCODE_PHARMA;
    DIO_BARCODE_PZN: Result := tBARCODE_PZN;
    DIO_BARCODE_PHARMA_TWO: Result := tBARCODE_PHARMA_TWO;
    DIO_BARCODE_PDF417: Result := tBARCODE_PDF417;
    DIO_BARCODE_PDF417TRUNC: Result := tBARCODE_PDF417TRUNC;
    DIO_BARCODE_MAXICODE: Result := tBARCODE_MAXICODE;
    DIO_BARCODE_QRCODE: Result := tBARCODE_QRCODE;
    DIO_BARCODE_DATAMATRIX: Result := tBARCODE_DATAMATRIX;
    DIO_BARCODE_AUSPOST: Result := tBARCODE_AUSPOST;
    DIO_BARCODE_AUSREPLY: Result := tBARCODE_AUSREPLY;
    DIO_BARCODE_AUSROUTE: Result := tBARCODE_AUSROUTE;
    DIO_BARCODE_AUSREDIRECT: Result := tBARCODE_AUSREDIRECT;
    DIO_BARCODE_ISBNX: Result := tBARCODE_ISBNX;
    DIO_BARCODE_RM4SCC: Result := tBARCODE_RM4SCC;
    DIO_BARCODE_EAN14: Result := tBARCODE_EAN14;
    DIO_BARCODE_CODABLOCKF: Result := tBARCODE_CODABLOCKF;
    DIO_BARCODE_NVE18: Result := tBARCODE_NVE18;
    DIO_BARCODE_JAPANPOST: Result := tBARCODE_JAPANPOST;
    DIO_BARCODE_KOREAPOST: Result := tBARCODE_KOREAPOST;
    DIO_BARCODE_RSS14STACK: Result := tBARCODE_RSS14STACK;
    DIO_BARCODE_RSS14STACK_OMNI: Result := tBARCODE_RSS14STACK_OMNI;
    DIO_BARCODE_RSS_EXPSTACK: Result := tBARCODE_RSS_EXPSTACK;
    DIO_BARCODE_PLANET: Result := tBARCODE_PLANET;
    DIO_BARCODE_MICROPDF417: Result := tBARCODE_MICROPDF417;
    DIO_BARCODE_ONECODE: Result := tBARCODE_ONECODE;
    DIO_BARCODE_PLESSEY: Result := tBARCODE_PLESSEY;
    DIO_BARCODE_TELEPEN_NUM: Result := tBARCODE_TELEPEN_NUM;
    DIO_BARCODE_ITF14: Result := tBARCODE_ITF14;
    DIO_BARCODE_KIX: Result := tBARCODE_KIX;
    DIO_BARCODE_AZTEC: Result := tBARCODE_AZTEC;
    DIO_BARCODE_DAFT: Result := tBARCODE_DAFT;
    DIO_BARCODE_MICROQR: Result := tBARCODE_MICROQR;
    DIO_BARCODE_HIBC_128: Result := tBARCODE_HIBC_128;
    DIO_BARCODE_HIBC_39: Result := tBARCODE_HIBC_39;
    DIO_BARCODE_HIBC_DM: Result := tBARCODE_HIBC_DM;
    DIO_BARCODE_HIBC_QR: Result := tBARCODE_HIBC_QR;
    DIO_BARCODE_HIBC_PDF: Result := tBARCODE_HIBC_PDF;
    DIO_BARCODE_HIBC_MICPDF: Result := tBARCODE_HIBC_MICPDF;
    DIO_BARCODE_HIBC_BLOCKF: Result := tBARCODE_HIBC_BLOCKF;
    DIO_BARCODE_HIBC_AZTEC: Result := tBARCODE_HIBC_AZTEC;
    DIO_BARCODE_AZRUNE: Result := tBARCODE_AZRUNE;
    DIO_BARCODE_CODE32: Result := tBARCODE_CODE32;
    DIO_BARCODE_EANX_CC: Result := tBARCODE_EANX_CC;
    DIO_BARCODE_EAN128_CC: Result := tBARCODE_EAN128_CC;
    DIO_BARCODE_RSS14_CC: Result := tBARCODE_RSS14_CC;
    DIO_BARCODE_RSS_LTD_CC: Result := tBARCODE_RSS_LTD_CC;
    DIO_BARCODE_RSS_EXP_CC: Result := tBARCODE_RSS_EXP_CC;
    DIO_BARCODE_UPCA_CC: Result := tBARCODE_UPCA_CC;
    DIO_BARCODE_UPCE_CC: Result := tBARCODE_UPCE_CC;
    DIO_BARCODE_RSS14STACK_CC: Result := tBARCODE_RSS14STACK_CC;
    DIO_BARCODE_RSS14_OMNI_CC: Result := tBARCODE_RSS14_OMNI_CC;
    DIO_BARCODE_RSS_EXPSTACK_CC: Result := tBARCODE_RSS_EXPSTACK_CC;
    DIO_BARCODE_CHANNEL: Result := tBARCODE_CHANNEL;
    DIO_BARCODE_CODEONE: Result := tBARCODE_CODEONE;
    DIO_BARCODE_GRIDMATRIX: Result := tBARCODE_GRIDMATRIX;
  else
    raise Exception.CreateFmt('Barcode type not supported, %d', [BarcodeType]);
  end;
end;

{ TDatecsFiscalPrinter }

constructor TDatecsFiscalPrinter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLogger := TLogFile.Create;
  FDocument := TTextDocument.Create;
  FDuplicate := TTextDocument.Create;
  FReceipt := TCustomReceipt.Create;
  FParams := TPrinterParameters.Create(FLogger);
  FOposDevice := TOposServiceDevice19.Create(FLogger);
  FOposDevice.ErrorEventEnabled := False;
  FPrinterState := TFiscalPrinterState.Create;
  FLines := TTntStringList.Create;
  FLoadParamsEnabled := True;
end;

destructor TDatecsFiscalPrinter.Destroy;
begin
  if FOposDevice.Opened then
    Close;

  FPrinter.Free;
  FLines.Free;
  FParams.Free;
  FDocument.Free;
  FDuplicate.Free;
  FOposDevice.Free;
  FPrinterState.Free;
  FReceipt.Free;
  inherited Destroy;
end;

procedure TDatecsFiscalPrinter.BeginDocument(APrintHeader: boolean);
begin
(*
  Document.Clear;
  Document.LineChars := Printer.RecLineChars;
  Document.LineHeight := Printer.RecLineHeight;
  Document.LineSpacing := Printer.RecLineSpacing;
  if APrintHeader and not (Params.HeaderPrinted) then
  begin
    Document.AddText(Params.HeaderText);
    Params.HeaderPrinted := False;
    SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);
  end;
*)
end;

function TDatecsFiscalPrinter.AmountToStr(Value: Currency): AnsiString;
begin
  if Params.AmountDecimalPlaces = 0 then
  begin
    Result := IntToStr(Round(Value));
  end else
  begin
    Result := Format('%.*f', [Params.AmountDecimalPlaces, Value]);
  end;
end;

function TDatecsFiscalPrinter.AmountToOutStr(Value: Currency): AnsiString;
var
  L: Int64;
begin
  L := Trunc(Value * Math.Power(10, Params.AmountDecimalPlaces));
  Result := IntToStr(L);
end;

function TDatecsFiscalPrinter.AmountToStrEq(Value: Currency): AnsiString;
begin
  Result := '=' + AmountToStr(Value);
end;

function TDatecsFiscalPrinter.GetQuantity(Value: Integer): Double;
begin
  Result := Value / 1000;
end;

function TDatecsFiscalPrinter.CreateReceipt(FiscalReceiptType: Integer): TCustomReceipt;
begin
  case FiscalReceiptType of
    FPTR_RT_CASH_IN: Result := TCashInReceipt.Create;
    FPTR_RT_CASH_OUT: Result := TCashOutReceipt.Create;

    FPTR_RT_SALES,
    FPTR_RT_GENERIC,
    FPTR_RT_SERVICE,
    FPTR_RT_SIMPLE_INVOICE:
      Result := TSalesReceipt.CreateReceipt(rtSell,
        Params.AmountDecimalPlaces, Params.RoundType);

    FPTR_RT_REFUND:
      Result := TSalesReceipt.CreateReceipt(rtRetSell,
        Params.AmountDecimalPlaces, Params.RoundType);
  else
    Result := nil;
    InvalidPropertyValue('FiscalReceiptType', IntToStr(FiscalReceiptType));
  end;
end;

procedure TDatecsFiscalPrinter.CheckCapSetVatTable;
begin
  if not FCapSetVatTable then
    RaiseIllegalError(_('Not supported'));
end;

function TDatecsFiscalPrinter.DoRelease: Integer;
begin
  try
    SetDeviceEnabled(False);
    OposDevice.ReleaseDevice;
    Printer.Port.Close;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.GetPrinterState: Integer;
begin
  Result := FPrinterState.State;
end;

procedure TDatecsFiscalPrinter.SetPrinterState(Value: Integer);
begin
  FPrinterState.SetState(Value);
end;

function TDatecsFiscalPrinter.DoClose: Integer;
begin
  try
    Result := DoCloseDevice;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TDatecsFiscalPrinter.Initialize;
begin
  FDayOpened := True;
  FCapAmountNotPaid := False;
  FCapFixedOutput := False;
  FCapIndependentHeader := False;
  FCapItemList := False;
  FCapNonFiscalMode := False;
  FCapOrderAdjustmentFirst := False;
  FCapPowerLossReport := False;
  FCapReceiptNotPaid := False;
  FCapReservedWord := False;
  FCapSetStoreFiscalID := False;
  FCapSlpValidation := False;
  FCapSlpFiscalDocument := False;
  FCapSlpFullSlip := False;
  FCapTrainingMode := False;
  FCapValidateJournal := False;
  FCapChangeDue := False;
  FCapMultiContractor := False;

  FCapAdditionalLines := True;
  FCapAmountAdjustment := True;
  FCapCheckTotal := True;
  FCapDoubleWidth := True;
  FCapDuplicateReceipt := True;
  FCapHasVatTable := True;
  FCapPercentAdjustment := True;
  FCapPositiveAdjustment := True;
  FCapPredefinedPaymentLines := True;
  FCapRemainingFiscalMemory := True;
  FCapSetPOSID := True;
  FCapSetVatTable := True;
  FCapSubAmountAdjustment := True;
  FCapSubPercentAdjustment := True;
  FCapSubtotal := True;
  FCapXReport := True;
  FCapAdditionalHeader := True;
  FCapAdditionalTrailer := True;
  FCapEmptyReceiptIsVoidable := True;
  FCapFiscalReceiptStation := True;
  FCapFiscalReceiptType := True;
  FCapOnlyVoidLastItem := False;
  FCapPackageAdjustment := True;
  FCapPostPreLine := True;
  FCapSetCurrency := False;
  FCapTotalizerType := True;
  FCapPositiveSubtotalAdjustment := True;

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
  FActualCurrency := FPTR_AC_RUR;
  FContractorId := FPTR_CID_SINGLE;
  FDateType := FPTR_DT_RTC;
  FFiscalReceiptStation := FPTR_RS_RECEIPT;
  FFiscalReceiptType := FPTR_RT_SALES;
  FMessageType := FPTR_MT_FREE_TEXT;
  FTotalizerType := FPTR_TT_DAY;

  FAdditionalHeader := '';
  FAdditionalTrailer := '';
  FOposDevice.PhysicalDeviceName := FPTR_DEVICE_DESCRIPTION;
  FOposDevice.PhysicalDeviceDescription := FPTR_DEVICE_DESCRIPTION;
  FOposDevice.ServiceObjectDescription := 'WebKassa OPOS fiscal printer service. SHTRIH-M, 2022';
  FPredefinedPaymentLines := '0,1,2,3';
  FReservedWord := '';
  FChangeDue := '';

  FUnitsUpdated := False;
  FCashboxesUpdated := False;
  FCashiersUpdated := False;
end;

function TDatecsFiscalPrinter.IllegalError: Integer;
begin
  Result := FOposDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TDatecsFiscalPrinter.ClearResult: Integer;
begin
  Result := FOposDevice.ClearResult;
end;

procedure TDatecsFiscalPrinter.CheckEnabled;
begin
  FOposDevice.CheckEnabled;
end;

procedure TDatecsFiscalPrinter.CheckState(AState: Integer);
begin
  CheckEnabled;
  FPrinterState.CheckState(AState);
end;

function TDatecsFiscalPrinter.DecodeString(const Text: WideString): WideString;
begin
  Result := Text;
end;

function TDatecsFiscalPrinter.EncodeString(const S: WideString): WideString;
begin
  Result := S;
end;

function TDatecsFiscalPrinter.BeginFiscalDocument(
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

function TDatecsFiscalPrinter.BeginFiscalReceipt(PrintHeader: WordBool): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_FISCAL_RECEIPT);

    FReceipt.Free;
    FReceipt := CreateReceipt(FFiscalReceiptType);
    FReceipt.BeginFiscalReceipt(PrintHeader);
    FExternalCheckNumber := CreateGUIDStr;

    BeginDocument(PrintHeader);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.BeginFixedOutput(Station,
  DocumentType: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.BeginItemList(VatID: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.BeginNonFiscal: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_NONFISCAL);
    BeginDocument(False);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.BeginTraining: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    RaiseOposException(OPOS_E_ILLEGAL, _('Ðåæèì òðåíèðîâêè íå ïîääåðæèâàåòñÿ'));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.CheckHealth(Level: Integer): Integer;
begin
  try
    CheckEnabled;
    { !!! }
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.Claim(Timeout: Integer): Integer;
begin
  try
    FOposDevice.ClaimDevice(Timeout);
    FParams.CheckPrameters;
    Printer.Port.Open;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.ClaimDevice(Timeout: Integer): Integer;
begin
  Result := Claim(Timeout);
end;

function TDatecsFiscalPrinter.ClearError: Integer;
begin
  Result := ClearResult;
end;

function TDatecsFiscalPrinter.ClearOutput: Integer;
begin
  try
    FOposDevice.CheckClaimed;
    { !!! }
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.Close: Integer;
begin
  Result := DoClose;
end;

function TDatecsFiscalPrinter.CloseService: Integer;
begin
  Result := DoClose;
end;

function TDatecsFiscalPrinter.COFreezeEvents(Freeze: WordBool): Integer;
begin
  try
    FOposDevice.FreezeEvents := Freeze;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.CompareFirmwareVersion(
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

procedure TDatecsFiscalPrinter.DioPrintBarcode(var pData: Integer; var pString: WideString);
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

procedure TDatecsFiscalPrinter.DioPrintBarcodeHex(var pData: Integer;
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

procedure TDatecsFiscalPrinter.DioSetDriverParameter(var pData: Integer;
  var pString: WideString);
begin
  case pData of
    DriverParameterBarcode: Receipt.Barcode := pString;
    DriverParameterPrintEnabled: Params.PrintEnabled := StrToBool(pString);
  end;
end;

procedure TDatecsFiscalPrinter.DioGetDriverParameter(var pData: Integer;
  var pString: WideString);
begin
  case pData of
    DriverParameterBarcode: pString := Receipt.Barcode;
    DriverParameterPrintEnabled: pString := BoolToStr(Params.PrintEnabled);
  end;
end;

function TDatecsFiscalPrinter.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
begin

  try
    FOposDevice.CheckOpened;
    case Command of
      DIO_PRINT_BARCODE: DioPrintBarcode(pData, pString);
      DIO_PRINT_BARCODE_HEX: DioPrintBarcodeHex(pData, pString);
      DIO_PRINT_HEADER: ;
      DIO_PRINT_TRAILER: ;
      DIO_SET_DRIVER_PARAMETER: DioSetDriverParameter(pData, pString);
      DIO_GET_DRIVER_PARAMETER: DioGetDriverParameter(pData, pString);
    else
      if Receipt.IsOpened then
      begin
        Receipt.DirectIO(Command, pData, pString);
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.DirectIO2(Command: Integer; const pData: Integer; const pString: WideString): Integer;
var
  pData2: Integer;
  pString2: WideString;
begin
  pData2 := pData;
  pString2 := pString;
  Result := DirectIO(Command, pData2, pString2);
end;

function TDatecsFiscalPrinter.EndFiscalDocument: Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.EndFiscalReceipt(PrintHeader: WordBool): Integer;
begin
  try
    FPrinterState.CheckState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    FReceipt.EndFiscalReceipt(PrintHeader);
    FReceipt.Print(Self);
    if FDuplicateReceipt then
    begin
      FDuplicateReceipt := False;
      FDuplicate.Assign(Document);
    end;
    SetPrinterState(FPTR_PS_MONITOR);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.EndFixedOutput: Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.EndInsertion: Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.EndItemList: Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.EndNonFiscal: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_NONFISCAL);
    PrintDocumentSafe(Document);
    SetPrinterState(FPTR_PS_MONITOR);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.EndRemoval: Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.EndTraining: Integer;
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

function TDatecsFiscalPrinter.Get_OpenResult: Integer;
begin
  Result := FOposDevice.OpenResult;
end;

function TDatecsFiscalPrinter.GetData(DataItem: Integer; out OptArgs: Integer;
  out Data: WideString): Integer;
var
  ZReportNumber: Integer;
begin
  try
    case DataItem of
      FPTR_GD_FIRMWARE: ;
      FPTR_GD_PRINTER_ID: Data := ''; // Params.CashboxNumber; { !!! }
      FPTR_GD_CURRENT_TOTAL: Data := AmountToOutStr(Receipt.GetTotal());
      FPTR_GD_DAILY_TOTAL: Data := ''; // AmountToOutStr(ReadDailyTotal); { !!! }
      FPTR_GD_GRAND_TOTAL: Data := ''; // AmountToOutStr(ReadGrandTotal);
      FPTR_GD_MID_VOID: Data := AmountToOutStr(0);
      FPTR_GD_NOT_PAID: Data := AmountToOutStr(0);
      FPTR_GD_RECEIPT_NUMBER: Data := FCheckNumber;
      FPTR_GD_REFUND: Data := ''; // AmountToOutStr(ReadRefundTotal); { !!! }
      FPTR_GD_REFUND_VOID: Data := AmountToOutStr(0);
      FPTR_GD_Z_REPORT:; { !!! }
      FPTR_GD_FISCAL_REC: Data := ''; // AmountToOutStr(ReadSellTotal); { !!! }
      FPTR_GD_FISCAL_DOC,
      FPTR_GD_FISCAL_DOC_VOID,
      FPTR_GD_FISCAL_REC_VOID,
      FPTR_GD_NONFISCAL_DOC,
      FPTR_GD_NONFISCAL_DOC_VOID,
      FPTR_GD_NONFISCAL_REC,
      FPTR_GD_RESTART,
      FPTR_GD_SIMP_INVOICE,
      FPTR_GD_TENDER,
      FPTR_GD_LINECOUNT:
        Data := AmountToStr(0);
      FPTR_GD_DESCRIPTION_LENGTH: Data := IntToStr(0); { !!! }
    else
      InvalidParameterValue('DataItem', IntToStr(DataItem));
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.GetDate(out Date: WideString): Integer;
var
  Year, Month, Day, Hour, Minute, Second, MilliSecond: Word;
begin
  try
    case FDateType of
      FPTR_DT_RTC:
      begin
        DecodeDateTime(Now, Year, Month, Day, Hour, Minute, Second, MilliSecond);
        Date := Format('%.2d%.2d%.4d%.2d%.2d',[Day, Month, Year, Hour, Minute]);
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

function TDatecsFiscalPrinter.GetOpenResult: Integer;
begin
  Result := FOposDevice.OpenResult;
end;

function TDatecsFiscalPrinter.GetPropertyNumber(PropIndex: Integer): Integer;
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
      PIDXFptr_AmountDecimalPlaces    : Result := Params.AmountDecimalPlaces;
      PIDXFptr_AsyncMode              : Result := BoolToInt[FAsyncMode];
      PIDXFptr_CheckTotal             : Result := BoolToInt[FCheckTotal];
      PIDXFptr_CountryCode            : Result := FCountryCode;
      PIDXFptr_CoverOpen              : Result := 0; // BoolToInt[Printer.CoverOpen]; { !!! }
      PIDXFptr_DayOpened              : Result := BoolToInt[FDayOpened];
      PIDXFptr_DescriptionLength      : Result := 0; { !!! }
      PIDXFptr_DuplicateReceipt       : Result := BoolToInt[FDuplicateReceipt];
      PIDXFptr_ErrorLevel             : Result := FErrorLevel;
      PIDXFptr_ErrorOutID             : Result := FErrorOutID;
      PIDXFptr_ErrorState             : Result := FErrorState;
      PIDXFptr_ErrorStation           : Result := FErrorStation;
      PIDXFptr_FlagWhenIdle           : Result := BoolToInt[FFlagWhenIdle];
      PIDXFptr_JrnEmpty               : Result := 0; // BoolToInt[Printer.JrnEmpty];
      PIDXFptr_JrnNearEnd             : Result := 0; // BoolToInt[Printer.JrnNearEnd];
      PIDXFptr_MessageLength          : Result := 0; // Printer.RecLineChars;
      PIDXFptr_NumHeaderLines         : Result := FParams.NumHeaderLines;
      PIDXFptr_NumTrailerLines        : Result := FParams.NumTrailerLines;
      PIDXFptr_NumVatRates            : Result := FParams.VatRates.Count;
      PIDXFptr_PrinterState           : Result := FPrinterState.State;
      PIDXFptr_QuantityDecimalPlaces  : Result := FQuantityDecimalPlaces;
      PIDXFptr_QuantityLength         : Result := FQuantityLength;
      PIDXFptr_RecEmpty               : Result := 0; // BoolToInt[Printer.RecEmpty];
      PIDXFptr_RecNearEnd             : Result := 0; // BoolToInt[Printer.RecNearEnd];
      PIDXFptr_RemainingFiscalMemory  : Result := FRemainingFiscalMemory;
      PIDXFptr_SlpEmpty               : Result := 0; // BoolToInt[Printer.SlpEmpty];
      PIDXFptr_SlpNearEnd             : Result := 0; // BoolToInt[Printer.SlpNearEnd];
      PIDXFptr_SlipSelection          : Result := FSlipSelection;
      PIDXFptr_TrainingModeActive     : Result := BoolToInt[False];
      PIDXFptr_ActualCurrency         : Result := FActualCurrency;
      PIDXFptr_ContractorId           : Result := FContractorId;
      PIDXFptr_DateType               : Result := FDateType;
      PIDXFptr_FiscalReceiptStation   : Result := FFiscalReceiptStation;
      PIDXFptr_FiscalReceiptType      : Result := FFiscalReceiptType;
      PIDXFptr_MessageType                : Result := FMessageType;
      PIDXFptr_TotalizerType              : Result := FTotalizerType;
      PIDXFptr_CapAdditionalLines         : Result := BoolToInt[FCapAdditionalLines];
      PIDXFptr_CapAmountAdjustment        : Result := BoolToInt[FCapAmountAdjustment];
      PIDXFptr_CapAmountNotPaid           : Result := BoolToInt[FCapAmountNotPaid];
      PIDXFptr_CapCheckTotal              : Result := BoolToInt[FCapCheckTotal];
      PIDXFptr_CapCoverSensor             : Result := 0; //BoolToInt[Printer.CapCoverSensor];
      PIDXFptr_CapDoubleWidth             : Result := BoolToInt[FCapDoubleWidth];
      PIDXFptr_CapDuplicateReceipt        : Result := BoolToInt[FCapDuplicateReceipt];
      PIDXFptr_CapFixedOutput             : Result := BoolToInt[FCapFixedOutput];
      PIDXFptr_CapHasVatTable             : Result := BoolToInt[FCapHasVatTable];
      PIDXFptr_CapIndependentHeader       : Result := BoolToInt[FCapIndependentHeader];
      PIDXFptr_CapItemList                : Result := BoolToInt[FCapItemList];
      PIDXFptr_CapJrnEmptySensor          : Result := 0; // BoolToInt[Printer.CapJrnEmptySensor];
      PIDXFptr_CapJrnNearEndSensor        : Result := 0; // BoolToInt[Printer.CapJrnNearEndSensor];
      PIDXFptr_CapJrnPresent              : Result := 0; // BoolToInt[Printer.CapJrnPresent];
      PIDXFptr_CapNonFiscalMode           : Result := BoolToInt[FCapNonFiscalMode];
      PIDXFptr_CapOrderAdjustmentFirst    : Result := BoolToInt[FCapOrderAdjustmentFirst];
      PIDXFptr_CapPercentAdjustment       : Result := BoolToInt[FCapPercentAdjustment];
      PIDXFptr_CapPositiveAdjustment      : Result := BoolToInt[FCapPositiveAdjustment];
      PIDXFptr_CapPowerLossReport         : Result := BoolToInt[FCapPowerLossReport];
      PIDXFptr_CapPredefinedPaymentLines  : Result := BoolToInt[FCapPredefinedPaymentLines];
      PIDXFptr_CapReceiptNotPaid          : Result := BoolToInt[FCapReceiptNotPaid];
      PIDXFptr_CapRecEmptySensor          : Result := 0; // BoolToInt[Printer.CapRecEmptySensor];
      PIDXFptr_CapRecNearEndSensor        : Result := 0; // BoolToInt[Printer.CapRecNearEndSensor];
      PIDXFptr_CapRecPresent              : Result := BoolToInt[FCapRecPresent];
      PIDXFptr_CapRemainingFiscalMemory   : Result := BoolToInt[FCapRemainingFiscalMemory];
      PIDXFptr_CapReservedWord            : Result := BoolToInt[FCapReservedWord];
      PIDXFptr_CapSetHeader               : Result := BoolToInt[FCapSetHeader];
      PIDXFptr_CapSetPOSID                : Result := BoolToInt[FCapSetPOSID];
      PIDXFptr_CapSetStoreFiscalID        : Result := BoolToInt[FCapSetStoreFiscalID];
      PIDXFptr_CapSetTrailer              : Result := BoolToInt[FCapSetTrailer];
      PIDXFptr_CapSetVatTable             : Result := BoolToInt[FCapSetVatTable];
      PIDXFptr_CapSlpEmptySensor          : Result := 0; // BoolToInt[Printer.CapSlpEmptySensor];
      PIDXFptr_CapSlpFiscalDocument       : Result := BoolToInt[FCapSlpFiscalDocument];
      PIDXFptr_CapSlpFullSlip             : Result := BoolToInt[FCapSlpFullSlip];
      PIDXFptr_CapSlpNearEndSensor        : Result := 0; // BoolToInt[Printer.CapSlpNearEndSensor];
      PIDXFptr_CapSlpPresent              : Result := 0; // BoolToInt[Printer.CapSlpPresent];
      PIDXFptr_CapSlpValidation           : Result := BoolToInt[FCapSlpValidation];
      PIDXFptr_CapSubAmountAdjustment     : Result := BoolToInt[FCapSubAmountAdjustment];
      PIDXFptr_CapSubPercentAdjustment    : Result := BoolToInt[FCapSubPercentAdjustment];
      PIDXFptr_CapSubtotal                : Result := BoolToInt[FCapSubtotal];
      PIDXFptr_CapTrainingMode            : Result := BoolToInt[FCapTrainingMode];
      PIDXFptr_CapValidateJournal         : Result := BoolToInt[FCapValidateJournal];
      PIDXFptr_CapXReport                 : Result := BoolToInt[FCapXReport];
      PIDXFptr_CapAdditionalHeader        : Result := BoolToInt[FCapAdditionalHeader];
      PIDXFptr_CapAdditionalTrailer       : Result := BoolToInt[FCapAdditionalTrailer];
      PIDXFptr_CapChangeDue               : Result := BoolToInt[FCapChangeDue];
      PIDXFptr_CapEmptyReceiptIsVoidable  : Result := BoolToInt[FCapEmptyReceiptIsVoidable];
      PIDXFptr_CapFiscalReceiptStation    : Result := BoolToInt[FCapFiscalReceiptStation];
      PIDXFptr_CapFiscalReceiptType       : Result := BoolToInt[FCapFiscalReceiptType];
      PIDXFptr_CapMultiContractor         : Result := BoolToInt[FCapMultiContractor];
      PIDXFptr_CapOnlyVoidLastItem        : Result := BoolToInt[FCapOnlyVoidLastItem];
      PIDXFptr_CapPackageAdjustment       : Result := BoolToInt[FCapPackageAdjustment];
      PIDXFptr_CapPostPreLine             : Result := BoolToInt[FCapPostPreLine];
      PIDXFptr_CapSetCurrency             : Result := BoolToInt[FCapSetCurrency];
      PIDXFptr_CapTotalizerType           : Result := BoolToInt[FCapTotalizerType];
      PIDXFptr_CapPositiveSubtotalAdjustment: Result := BoolToInt[FCapPositiveSubtotalAdjustment];
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

function TDatecsFiscalPrinter.GetPropertyString(PropIndex: Integer): WideString;
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

function TDatecsFiscalPrinter.GetTotalizer(VatID, OptArgs: Integer;
  out Data: WideString): Integer;

  function ReadGrossTotalizer(OptArgs: Integer): Currency;
  begin
    Result := 0;
    case OptArgs of
      FPTR_TT_DOCUMENT: Result := 0;
      FPTR_TT_DAY: Result := 0; // ReadDailyTotal; { !!! }
      FPTR_TT_RECEIPT: Result := Receipt.GetTotal;
      FPTR_TT_GRAND: Result := 0; // ReadGrandTotal; { !!! }
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

function TDatecsFiscalPrinter.GetVatEntry(VatID, OptArgs: Integer;
  out VatRate: Integer): Integer;
begin
  Result := ClearResult;
end;

function TDatecsFiscalPrinter.Open(const DeviceClass, DeviceName: WideString;
  const pDispatch: IDispatch): Integer;
begin
  Result := DoOpen(DeviceClass, DeviceName, pDispatch);
end;

function TDatecsFiscalPrinter.OpenService(const DeviceClass,
  DeviceName: WideString; const pDispatch: IDispatch): Integer;
begin
  Result := DoOpen(DeviceClass, DeviceName, pDispatch);
end;

function TDatecsFiscalPrinter.PrintDuplicateReceipt: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    if FDuplicate.Items.Count > 0 then
    begin
      PrintDocument(FDuplicate);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.PrintFiscalDocumentLine(
  const DocumentLine: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.PrintFixedOutput(DocumentType, LineNumber: Integer;
  const Data: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.PrintNormal(Station: Integer;
  const AData: WideString): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_NONFISCAL);
    Document.AddText(AData);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.PrintPeriodicTotalsReport(const Date1,
  Date2: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.PrintPowerLossReport: Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.PrintRecCash(Amount: Currency): Integer;
begin
  try
    FReceipt.PrintRecCash(Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.PrintRecItem(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecItemAdjustment(AdjustmentType: Integer;
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

function TDatecsFiscalPrinter.PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
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

function TDatecsFiscalPrinter.PrintRecItemFuel(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecItemFuelVoid(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecItemRefund(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecItemRefundVoid(
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

function TDatecsFiscalPrinter.PrintRecItemVoid(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecMessage(const Message: WideString): Integer;
begin
  try
    CheckEnabled;
    FReceipt.PrintRecMessage(Message);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.PrintRecNotPaid(const Description: WideString;
  Amount: Currency): Integer;
begin
  try
    if not FCapReceiptNotPaid then
      RaiseOposException(OPOS_E_ILLEGAL, _('Not paid receipt is nor supported'));

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

function TDatecsFiscalPrinter.PrintRecPackageAdjustment(AdjustmentType: Integer;
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

function TDatecsFiscalPrinter.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
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

function TDatecsFiscalPrinter.PrintRecRefund(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecRefundVoid(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintRecSubtotal(Amount: Currency): Integer;
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

function TDatecsFiscalPrinter.PrintRecSubtotalAdjustment(AdjustmentType: Integer;
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

function TDatecsFiscalPrinter.PrintRecSubtotalAdjustVoid(AdjustmentType: Integer;
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

function TDatecsFiscalPrinter.PrintRecTaxID(const TaxID: WideString): Integer;
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

function TDatecsFiscalPrinter.PrintRecTotal(Total, Payment: Currency;
  const Description: WideString): Integer;
var
  PaymentType: Integer;
begin
  try
    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE, 'OPOS_EFPTR_WRONG_STATE');

    if FCheckTotal and (FReceipt.GetTotal <> Total) then
    begin
      raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT,
        Format('App total %s, but receipt total %s', [
        AmountToStr(Total), AmountToStr(FReceipt.GetTotal)]));
    end;

    PaymentType := StrToIntDef(Description, 0);
    case PaymentType of
      0:;
      1: PaymentType := Params.PaymentType2;
      2: PaymentType := Params.PaymentType3;
      3: PaymentType := Params.PaymentType4;
    end;

    FReceipt.PrintRecTotal(Total, Payment, IntToStr(PaymentType));
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

function TDatecsFiscalPrinter.PrintRecVoid(
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

function TDatecsFiscalPrinter.PrintRecVoidItem(const Description: WideString;
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

function TDatecsFiscalPrinter.PrintReport(ReportType: Integer; const StartNum,
  EndNum: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.PrintXReport: Integer;
begin
  try
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_REPORT);
    try
      Printer.Check(Printer.XReport.ResultCode);
      Printer.WaitWhilePrintEnd;
    finally
      SetPrinterState(FPTR_PS_MONITOR);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.PrintZReport: Integer;
begin
  try
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_REPORT);
    try
      Printer.Check(Printer.ZReport.ResultCode);
      Printer.WaitWhilePrintEnd;
    finally
      SetPrinterState(FPTR_PS_MONITOR);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.Release1: Integer;
begin
  Result := DoRelease;
end;

function TDatecsFiscalPrinter.ReleaseDevice: Integer;
begin
  Result := DoRelease;
end;

function TDatecsFiscalPrinter.ResetPrinter: Integer;
begin
  try
    CheckEnabled;
    SetPrinterState(FPTR_PS_MONITOR);
    FReceipt.Free;
    FReceipt := TCustomReceipt.Create;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := IllegalError;
end;

function TDatecsFiscalPrinter.SetCurrency(NewCurrency: Integer): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetDate(const Date: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetHeaderLine(LineNumber: Integer;
  const Text: WideString; DoubleWidth: WordBool): Integer;
var
  LineText: WideString;
begin
  try
    CheckEnabled;

    if (LineNumber <= 0)or(LineNumber > Params.NumHeaderLines) then
      raiseIllegalError('Invalid line number');

    LineText := Text;
    //if DoubleWidth then
    //  LineText := ESC_DoubleWide + LineText;

    FParams.Header[LineNumber-1] := LineText;
    SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetPOSID(const POSID,
  CashierID: WideString): Integer;
begin
  FPOSID := POSID;
  FCashierID := CashierID;
  Result := ClearResult;
end;

procedure TDatecsFiscalPrinter.SetPropertyNumber(PropIndex, Number: Integer);
begin
  try
    case PropIndex of
      // common
      PIDX_DeviceEnabled:
        SetDeviceEnabled(IntToBool(Number));

      PIDX_DataEventEnabled:
        FOposDevice.DataEventEnabled := IntToBool(Number);

      PIDX_PowerNotify:
      begin
        FOposDevice.PowerNotify := Number;
        //Printer.PowerNotify := Number; { !!! }
      end;

      PIDX_BinaryConversion:
      begin
        FOposDevice.BinaryConversion := Number;
        //Printer.BinaryConversion := Number; { !!! }
      end;

      // Specific
      PIDXFptr_AsyncMode:
      begin
        FAsyncMode := IntToBool(Number);
        //Printer.AsyncMode := IntToBool(Number); { !!! }
      end;

      PIDXFptr_CheckTotal: FCheckTotal := IntToBool(Number);
      PIDXFptr_DateType: FDateType := Number;
      PIDXFptr_DuplicateReceipt: FDuplicateReceipt := IntToBool(Number);
      PIDXFptr_FiscalReceiptStation: FFiscalReceiptStation := Number;

      PIDXFptr_FiscalReceiptType:
      begin
        CheckState(FPTR_PS_MONITOR);
        FFiscalReceiptType := Number;
      end;
      PIDXFptr_FlagWhenIdle:
      begin
        FFlagWhenIdle := IntToBool(Number);
        //Printer.FlagWhenIdle  := IntToBool(Number); { !!! }
      end;
      PIDXFptr_MessageType:
        FMessageType := Number;
      PIDXFptr_SlipSelection:
        FSlipSelection := Number;
      PIDXFptr_TotalizerType:
        FTotalizerType := Number;
      PIDX_FreezeEvents:
      begin
        FOposDevice.FreezeEvents := Number <> 0;
        //Printer.FreezeEvents := Number <> 0; { !!! }
      end;
    end;

    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TDatecsFiscalPrinter.SetPropertyString(PropIndex: Integer;
  const Text: WideString);
begin
  try
    FOposDevice.CheckOpened;
    case PropIndex of
      PIDXFptr_AdditionalHeader   : FAdditionalHeader := Text;
      PIDXFptr_AdditionalTrailer  : FAdditionalTrailer := Text;
      PIDXFptr_PostLine           : FPostLine := Text;
      PIDXFptr_PreLine            : FPreLine := Text;
      PIDXFptr_ChangeDue          : FChangeDue := Text;
    end;
    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetStoreFiscalID(const ID: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetTrailerLine(LineNumber: Integer;
  const Text: WideString; DoubleWidth: WordBool): Integer;
var
  LineText: WideString;
begin
  try
    CheckEnabled;
    if (LineNumber <= 0)or(LineNumber > Params.NumTrailerLines) then
      raiseIllegalError('Invalid line number');

    LineText := Text;
    //if DoubleWidth then
    //  LineText := ESC_DoubleWide + LineText;

    Params.Trailer[LineNumber-1] := LineText;
    SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetVatTable: Integer;
begin
  try
    CheckEnabled;
    CheckCapSetVatTable;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.SetVatValue(VatID: Integer;
  const VatValue: WideString): Integer;
var
  VatValueInt: Integer;
begin
  try
    CheckEnabled;
    CheckCapSetVatTable;

    // There are 6 taxes in Shtrih-M ECRs available
    if (VatID < MinVatID)or(VatID > MaxVatID) then
      InvalidParameterValue('VatID', IntToStr(VatID));

    VatValueInt := StrToInt(VatValue);
    if VatValueInt < MinVatValue then
      InvalidParameterValue('VatValue', VatValue);

    if VatValueInt > MaxVatValue then
      InvalidParameterValue('VatValue', VatValue);

    FVatValues[VatID] := VatValueInt;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.UpdateFirmware(
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

function TDatecsFiscalPrinter.UpdateStatistics(
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

function TDatecsFiscalPrinter.VerifyItem(const ItemName: WideString;
  VatID: Integer): Integer;
begin
  Result := IllegalError;
end;

procedure TDatecsFiscalPrinter.PrinterErrorEvent(ASender: TObject; ResultCode: Integer;
  ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  Logger.Debug(Format('PtrErrorEvent: %d, %d, %d', [
    ResultCode, ResultCodeExtended, ErrorLocus]));
end;

procedure TDatecsFiscalPrinter.PrinterDirectIOEvent(ASender: TObject; EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  Logger.Debug(Format('PtrDirectIOEvent: %d, %d, %s', [
    EventNumber, pData, pString]));
end;

procedure TDatecsFiscalPrinter.PrinterOutputCompleteEvent(ASender: TObject; OutputID: Integer);
begin
  Logger.Debug(Format('PtrOutputCompleteEvent: %d', [OutputID]));
end;

function TDatecsFiscalPrinter.DoOpen(const DeviceClass, DeviceName: WideString;
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
      //FPrinter := TDatecsPrinter.Create(FLogger, FPort); { !!! }
    end;
    // (FParams.PrinterName))
    Printer.Port.Open;

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

function TDatecsFiscalPrinter.CreatePrinter: TDatecsPrinter;
begin
(*
  case Params.PrinterType of
    PrinterTypeSerial:
    begin
      Result := TDatecsPrinter.Create;
    end;
    PrinterTypeNetwork:
    begin
      Result := TDatecsPrinter.Create;
    end;
    PrinterTypeJson:
    begin
      Result := TDatecsPrinter.Create;
    end;
  else
    raise Exception.Create('Invalid PrinterType value');
  end;
*)  
end;

function TDatecsFiscalPrinter.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := Params.PortName;
  SerialParams.BaudRate := Params.BaudRate;
  SerialParams.DataBits := Params.DataBits;
  SerialParams.StopBits := Params.StopBits;
  SerialParams.Parity := Params.Parity;
  SerialParams.FlowControl := Params.FlowControl;
  SerialParams.ReconnectPort := Params.ReconnectPort;
  SerialParams.ByteTimeout := Params.SerialTimeout;
  Result := TSerialPort.Create(SerialParams, Logger);
end;

function TDatecsFiscalPrinter.DoCloseDevice: Integer;
begin
  try
    Result := ClearResult;
    if not FOposDevice.Opened then Exit;

    SetDeviceEnabled(False);
    FOposDevice.Close;
    Printer.Port.Close;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsFiscalPrinter.GetEventInterface(FDispatch: IDispatch): IOposEvents;
begin
  Result := TOposEventsRCS.Create(FDispatch);
end;

function TDatecsFiscalPrinter.HandleException(E: Exception): Integer;
var
  OPOSError: TOPOSError;
  OPOSException: EOPOSException;
begin
  if E is EDriverError then
  begin
    OPOSError := HandleDriverError(E as EDriverError);
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

procedure TDatecsFiscalPrinter.SetDeviceEnabled(Value: Boolean);

  function IsCharacterSetSupported(const CharacterSetList: string;
    CharacterSet: Integer): Boolean;
  begin
    Result := Pos(IntToStr(CharacterSet), CharacterSetList) <> 0;
  end;

var
  CharacterSetList: WideString;
begin
  if Value <> FDeviceEnabled then
  begin
    if Value then
    begin
      { !!! }
    end else
    begin
      //Printer.Disconnect; { !!! }
    end;
    FDeviceEnabled := Value;
    FOposDevice.DeviceEnabled := Value;
  end;
end;

function TDatecsFiscalPrinter.HandleDriverError(E: EDriverError): TOPOSError;
begin
  Result.ResultCode := OPOS_E_EXTENDED;
  Result.ErrorString := GetExceptionMessage(E);
  if E.ErrorCode = 11 then
  begin
    Result.ResultCodeExtended := OPOS_EFPTR_DAY_END_REQUIRED;
  end else
  begin
    Result.ResultCodeExtended := 300 + E.ErrorCode;
  end;
end;

procedure TDatecsFiscalPrinter.Print(Receipt: TCashInReceipt);
begin
  { !!! }
end;

procedure TDatecsFiscalPrinter.Print(Receipt: TCashOutReceipt);
begin
  { !!! }
end;

function TDatecsFiscalPrinter.GetVatRate(Code: Integer): TVatRate;
begin
  Result := nil;
  if Params.VatRateEnabled then
  begin
    Result := Params.VatRates.ItemByCode(Code);
  end;
end;

procedure TDatecsFiscalPrinter.Print(Receipt: TSalesReceipt);
begin
  { !!! }
end;

function TDatecsFiscalPrinter.GetHeaderItemText(Receipt: TSalesReceipt;
  Item: TTemplateItem): WideString;
begin
  case Item.ItemType of
    TEMPLATE_TYPE_TEXT: Result := Item.Text;
    TEMPLATE_TYPE_PARAM: Result := Params.ItemByText(Item.Text);
    TEMPLATE_TYPE_ITEM_FIELD: Result := ReceiptFieldByText(Receipt, Item);
    TEMPLATE_TYPE_SEPARATOR: Result := StringOfChar('-', Item.LineChars);
    TEMPLATE_TYPE_NEWLINE: Result := CRLF;
  else
    Result := '';
  end;
end;

function TDatecsFiscalPrinter.GetReceiptItemText(ReceiptItem: TSalesReceiptItem;
  Item: TTemplateItem): WideString;
begin
  case Item.ItemType of
    TEMPLATE_TYPE_TEXT: Result := Item.Text;
    TEMPLATE_TYPE_ITEM_FIELD: Result := ReceiptItemByText(ReceiptItem, Item);
    TEMPLATE_TYPE_PARAM: Result := Params.ItemByText(Item.Text);
    TEMPLATE_TYPE_SEPARATOR: Result := StringOfChar('-', Document.LineChars);
    TEMPLATE_TYPE_NEWLINE: Result := CRLF;
  else
    Result := '';
  end;
end;

function TDatecsFiscalPrinter.ReceiptItemByText(ReceiptItem: TSalesReceiptItem;
  Item: TTemplateItem): WideString;
var
  Amount: Currency;
begin
  Result := '';
  if WideCompareText(Item.Text, 'Price') = 0 then
  begin
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(ReceiptItem.Price <> 0) then
    begin
      Result := Format('%.2f', [ReceiptItem.Price]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'VatInfo') = 0 then
  begin
    Result := IntToStr(ReceiptItem.VatInfo);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Quantity') = 0 then
  begin
    Result := Format('%.3f', [ReceiptItem.Quantity]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'UnitPrice') = 0 then
  begin
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(ReceiptItem.UnitPrice <> 0) then
    begin
      Result := Format('%.2f', [ReceiptItem.UnitPrice]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'UnitName') = 0 then
  begin
    Result := ReceiptItem.UnitName;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Description') = 0 then
  begin
    Result := ReceiptItem.Description;
    Exit;
  end;
  if WideCompareText(Item.Text, 'MarkCode') = 0 then
  begin
    Result := ReceiptItem.MarkCode;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Discount') = 0 then
  begin
    Amount := Abs(ReceiptItem.Discounts.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    begin
      Result := Format('%.2f', [Amount]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Charge') = 0 then
  begin
    Amount := Abs(ReceiptItem.Charges.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Total') = 0 then
  begin
    Amount := Abs(ReceiptItem.GetTotalAmount(Params.RoundType));
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  raise Exception.CreateFmt('Receipt item %s not found', [Item.Text]);
end;

function TDatecsFiscalPrinter.ReceiptFieldByText(Receipt: TSalesReceipt;
  Item: TTemplateItem): WideString;

  function GetRecTypeText(RecType: TRecType): string;
  begin
    case RecType of
      rtBuy    : Result := 'ÏÎÊÓÏÊÀ';
      rtRetBuy : Result := 'ÂÎÇÂÐÀÒ ÏÎÊÓÏÊÈ';
      rtSell   : Result := 'ÏÐÎÄÀÆÀ';
      rtRetSell: Result := 'ÂÎÇÂÐÀÒ ÏÐÎÄÀÆÈ';
    else
      raise Exception.CreateFmt('Invalid receipt type, %d', [Ord(RecType)]);
    end;
  end;

var
  Amount: Currency;
begin
  Result := '';
  if WideCompareText(Item.Text, 'Discount') = 0 then
  begin
    Amount := Abs(Receipt.Discounts.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    begin
      Result := Format('%.2f', [Amount]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Charge') = 0 then
  begin
    Amount := Abs(Receipt.Charges.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Total') = 0 then
  begin
    Amount := Abs(Receipt.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment0') = 0 then
  begin
    Amount := Abs(Receipt.Payments[0]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment1') = 0 then
  begin
    Amount := Abs(Receipt.Payments[1]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment2') = 0 then
  begin
    Amount := Abs(Receipt.Payments[2]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment3') = 0 then
  begin
    Amount := Abs(Receipt.Payments[3]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Change') = 0 then
  begin
    Amount := Abs(Receipt.Change);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'OperationTypeText') = 0 then
  begin
    Result := GetRecTypeText(Receipt.RecType);
    Exit;
  end;

  raise Exception.CreateFmt('Receipt field %s not found', [Item.Text]);
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

procedure TDatecsFiscalPrinter.PrintReceiptTemplate(Receipt: TSalesReceipt;
  Template: TReceiptTemplate);
var
  i, j: Integer;
  IsValid: Boolean;
  Item: TTemplateItem;
  LineItems: TList;
  ReceiptItem: TReceiptItem;
  RecTexItem: TRecTexItem;
begin
  IsValid := True;
  LineItems := TList.Create;
  try
    // Header
    LineItems.Clear;
    for i := 0 to Template.Header.Count-1 do
    begin
      Item := Template.Header[i];
      UpdateTemplateItem(Item);
      Item.Value := GetHeaderItemText(Receipt, Item);
      LineItems.Add(Item);
    end;
    AddItems(LineItems);
    LineItems.Clear;
    // Items
    for i := 0 to Receipt.Items.Count-1 do
    begin
      ReceiptItem := Receipt.Items[i];
      if ReceiptItem is TRecTexItem then
      begin
        RecTexItem := ReceiptItem as TRecTexItem;
        Document.AddLine(RecTexItem.Text, RecTexItem.Style);
      end;


      if ReceiptItem is TSalesReceiptItem then
      begin
        for j := 0 to Template.RecItem.Count-1 do
        begin
          Item := Template.RecItem[j];
          UpdateTemplateItem(Item);
          if Item.ItemType = TEMPLATE_TYPE_NEWLINE then
          begin
            Item.Value := CRLF;
            if IsValid then
            begin
              LineItems.Add(Item);
              AddItems(LineItems);
            end;
            LineItems.Clear;
            IsValid := True;
          end else
          begin
            LineItems.Add(Item);
            Item.Value := GetReceiptItemText(ReceiptItem as TSalesReceiptItem, Item);
            IsValid := Item.Value <> '';
          end;
        end;
      end;
    end;
    AddItems(LineItems);
    LineItems.Clear;
    for i := 0 to Template.Trailer.Count-1 do
    begin
      Item := Template.Trailer[i];
      UpdateTemplateItem(Item);
      Item.Value := GetHeaderItemText(Receipt, Item);
      LineItems.Add(Item);
    end;
    AddItems(LineItems);
    LineItems.Clear;
    Document.AddText(Receipt.Trailer.Text);
  finally
    LineItems.Free;
  end;
end;

procedure TDatecsFiscalPrinter.UpdateTemplateItem(Item: TTemplateItem);
begin
  if Item.LineChars = 0 then
  begin
    Item.LineChars := Document.LineChars;
  end;
  if Item.LineSpacing = 0 then
  begin
    Item.LineSpacing := Document.LineSpacing;
  end;
end;

procedure TDatecsFiscalPrinter.AddItems(Items: TList);

  procedure AddListItems(Items: TList);
  var
    i: Integer;
    Item: TTemplateItem;
  begin
    for i := 0 to Items.Count-1 do
    begin
      Item := TTemplateItem(Items[i]);
      Document.LineChars := Item.LineChars;
      Document.LineSpacing := Item.LineSpacing;
      case Item.TextStyle of
        STYLE_QR_CODE: Document.AddItem(Item.Value, Item.TextStyle);
      else
        Document.Add(Item.Value, Item.TextStyle);
      end;
    end;
  end;

var
  i: Integer;
  Len: Integer;
  List: TList;
  Valid: Boolean;
  Line: WideString;
  Item: TTemplateItem;
begin
  Line := '';
  Valid := True;
  List := TList.Create;
  try
    for i := 0 to Items.Count-1 do
    begin
      Item := TTemplateItem(Items[i]);

      if (Item.Enabled = TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO) then
      begin
        if Item.Value = '' then
        begin
          List.Clear;
          Line := '';
          Valid := False;
        end;
      end;

      if Item.FormatText <> '' then
        Item.Value := Format(Item.FormatText, [Item.Value]);

      case Item.Alignment of
        ALIGN_RIGHT:
        begin
          Len := Item.GetLineLength - Length(Item.Value) - Length(Line);
          Item.Value := StringOfChar(' ', Len) + Item.Value;
        end;

        ALIGN_CENTER:
        begin
          Len := (Item.GetLineLength-Length(Item.Value)-Length(Line)) div 2;
          Item.Value := StringOfChar(' ', Len) + Item.Value;
        end;
      end;
      Line := Line + Item.Value;
      List.Add(Item);
      if Item.ItemType = TEMPLATE_TYPE_NEWLINE then
      begin
        if Valid then
        begin
          AddListItems(List);
        end;
        Line := '';
        List.Clear;
        Valid := True;
      end;
    end;
    AddListItems(List);
  finally
    List.Free;
  end;
end;


procedure TDatecsFiscalPrinter.CheckCanPrint;
begin
  { !!! }
end;

procedure TDatecsFiscalPrinter.PrintDocumentSafe(Document: TTextDocument);
begin
  if not Params.PrintEnabled then Exit;

  try
    Document.AddText(Params.TrailerText);
    PrintDocument(Document);
  except
    on E: Exception do
    begin
      Document.Save;
      Logger.Error('Failed to print document, ' + E.Message);
    end;
  end;
end;

procedure TDatecsFiscalPrinter.PrintDocument(Document: TTextDocument);
var
  TickCount: DWORD;
begin
  Logger.Debug('PrintDocument');
  TickCount := GetTickCount;
  CheckCanPrint;
  { !!! }
  Logger.Debug(Format('PrintDocument, time=%d ms', [GetTickCount-TickCount]));
end;

function TDatecsFiscalPrinter.GetPrinterStation(Station: Integer): Integer;
begin
  if (Station and FPTR_S_RECEIPT) <> 0 then
  begin
    if not FCapRecPresent then
      RaiseOposException(OPOS_E_ILLEGAL, _('Íåò ÷åêîâîãî ïðèíòåðà'));
  end;

  if (Station and FPTR_S_JOURNAL) <> 0 then
  begin
    if not FCapJrnPresent then
      RaiseOposException(OPOS_E_ILLEGAL, _('Íåò ïðèíòåðà êîíòðîëüíîé ëåíòû'));
  end;

  if (Station and FPTR_S_SLIP) <> 0 then
  begin
    if not FCapSlpPresent then
      RaiseOposException(OPOS_E_ILLEGAL, _('Slip station is not present'));
  end;
  if Station = 0 then
    RaiseOposException(OPOS_E_ILLEGAL, _('No station defined'));

  Result := Station;
end;

function TDatecsFiscalPrinter.RenderQRCode(const BarcodeData: AnsiString): AnsiString;
var
  Bitmap: TBitmap;
  Render: TZintBarcode;
  Stream: TMemoryStream;
begin
  Result := '';
  Bitmap := TBitmap.Create;
  Render := TZintBarcode.Create;
  Stream := TMemoryStream.Create;
  try
    Render.BorderWidth := 0;
    Render.FGColor := clBlack;
    Render.BGColor := clWhite;
    Render.Scale := 1;
    Render.Height := 200;
    Render.BarcodeType := tBARCODE_QRCODE;
    Render.Data := BarcodeData;
    Render.ShowHumanReadableText := False;
    Render.EncodeNow;
    RenderBarcode(Bitmap, Render.Symbol, False);
    ScaleGraphic(Bitmap, 2);
    Bitmap.SaveToStream(Stream);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      SetLength(Result, Stream.Size);
      Stream.ReadBuffer(Result[1], Stream.Size);
    end;
  finally
    Render.Free;
    Bitmap.Free;
    Stream.Free;
  end;
end;

procedure TDatecsFiscalPrinter.PrintBarcode(const Barcode: string);
begin
  if FPrinterState.State = FPTR_PS_NONFISCAL then
  begin
    Document.AddBarcode(Barcode);
  end else
  begin
    Receipt.PrintBarcode(Barcode);
  end;
end;

end.
