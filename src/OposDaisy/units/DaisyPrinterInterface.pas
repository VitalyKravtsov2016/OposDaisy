unit DaisyPrinterInterface;

interface

uses
  // VCL
  Classes, Graphics,
  // This
  LogFile, PrinterPort;

const
  LF = #10;
  TAB = #$09;
  CRLF = #13#10;
  BoolToStr: array [Boolean] of WideString = ('0', '1');

  /////////////////////////////////////////////////////////////////////////////
  // VAT rates constants

  MinVATRate = 1;
  MaxVATRate = 5;


  /////////////////////////////////////////////////////////////////////////////
  // Baudrate constants

  DFP_BR_NONE   = 0;
  DFP_BR_1200   = 1;
  DFP_BR_2400   = 2;
  DFP_BR_4800   = 3;
  DFP_BR_9600   = 4;
  DFP_BR_14400  = 5;
  DFP_BR_19200  = 6;
  DFP_BR_28800  = 7;
  DFP_BR_38400  = 8;
  DFP_BR_57600  = 9;
  DFP_BR_115200 = 10;

  /////////////////////////////////////////////////////////////////////////////
  // Barcode type constants

  DFP_BT_EAN8         = 1;
  DFP_BT_EAN13        = 2;
  DFP_BT_CODE128      = 3;
  DFP_BT_UPCE         = 4;
  DFP_BT_UPCA         = 5;
  DFP_BT_CODE25       = 6;
  DFP_BT_CODE25ITF    = 7;
  DFP_BT_CODE25ITFM10 = 8;
  DFP_BT_CODE39       = 9;
  DFP_BT_CODE39M43    = 10;
  DFP_BT_CODE93       = 11;
  DFP_BT_CODABAR      = 12;
  DFP_BT_POSTNET      = 13;

  DFP_BT_MIN          = 1;
  DFP_BT_MAX          = 13;

  /////////////////////////////////////////////////////////////////////////////
  // Barcode position constants

  DFP_BP_CENTER   = 1;
  DFP_BP_RIGHT    = 2;
  DFP_BP_LEFT     = 3;

  DFP_BP_MIN      = 1;
  DFP_BP_MAX      = 3;

  /////////////////////////////////////////////////////////////////////////////
  // Header and trailer constants

  DFP_SP_HEADER_START_LINE  = 40;
  DFP_SP_TRAILER_START_LINE = 48;
  DFP_SP_PAYMENT_START_LINE = 60;
  DFP_SP_COMMENT_START_LINE = 600;

  /////////////////////////////////////////////////////////////////////////////
  // System parameter constants

  DFP_SP_DECIMAL_POINT          = 1;
  DFP_SP_NUM_HEADER_LINES       = 2;
  DFP_SP_NUM_TRAILER_LINES      = 3;
  DFP_SP_PRINT_OPTIONS          = 4;
  DFP_SP_DETAILED_PRINT         = 5;
  DFP_SP_HEADER_TYPE            = 6;
  DFP_SP_TRAILER_TYPE           = 7;
  DFP_SP_ENABLE_OPERATIONS      = 8;
  DFP_SP_ENABLE_PAYMENTS        = 9;
  DFP_SP_PRINTER_NUMBER         = 10;
  DFP_SP_Z_REPORT_TYPE          = 11;
  DFP_SP_PRINT_ALL              = 12;
  DFP_SP_Z_REPORT_ZERO          = 13;
  DFP_SP_SYSTEM_FONT            = 14;
  DFP_SP_TRAILER_LOGO           = 15;
  DFP_SP_AMOUNT_CURRENCY        = 16;
  DFP_SP_FEED_LINES             = 17;
  DFP_SP_PRN_CONTRAST           = 18;
  DFP_SP_DISPLAY_ROWS           = 19;
  DFP_SP_DISPLAY_CHARS          = 20;
  DFP_SP_RS_BAUDRATE            = 21;
  DFP_SP_DISPLAY_SALES          = 22;
  DFP_SP_AUTOCAT                = 23;
  DFP_SP_PRINT_ERRORS           = 24;

  DFP_SP_MIN                    = 1;
  DFP_SP_MAX                    = 24;

  /////////////////////////////////////////////////////////////////////////////
  // Default operator passwords

  DFP_OPERATOR_PASSWORD_1 = 1;
  DFP_OPERATOR_PASSWORD_2 = 2;
  DFP_OPERATOR_PASSWORD_3 = 3;
  DFP_OPERATOR_PASSWORD_4 = 4;
  DFP_OPERATOR_PASSWORD_5 = 5;
  DFP_OPERATOR_PASSWORD_6 = 6;
  DFP_OPERATOR_PASSWORD_7 = 7;
  DFP_OPERATOR_PASSWORD_8 = 8;
  DFP_OPERATOR_PASSWORD_9 = 9;
  DFP_OPERATOR_PASSWORD_10 = 10;
  DFP_OPERATOR_PASSWORD_11 = 11;
  DFP_OPERATOR_PASSWORD_12 = 12;
  DFP_OPERATOR_PASSWORD_13 = 13;
  DFP_OPERATOR_PASSWORD_14 = 14;
  DFP_OPERATOR_PASSWORD_15 = 15;
  DFP_OPERATOR_PASSWORD_16 = 16;
  DFP_OPERATOR_PASSWORD_17 = 17;
  DFP_OPERATOR_PASSWORD_18 = 18;
  DFP_OPERATOR_PASSWORD_19 = 8888;
  DFP_OPERATOR_PASSWORD_20 = 9999;

  /////////////////////////////////////////////////////////////////////////////
  // Cut mode constants

  DFP_CM_NONE     = 0;
  DFP_CM_FULL     = 1;
  DFP_CM_PARTIAL  = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Data type constants

  DFP_DT_TOTAL  = 0;
  DFP_DT_NET    = 1;

  /////////////////////////////////////////////////////////////////////////////
  // Paid code constants

  DFP_PC_ERROR              = 1;
  DFP_PC_VAT_NEGATIVE       = 2;
  DFP_PC_SUM_LESS_TOTAL     = 3;
  DFP_PC_SUM_GREATER_TOTAL  = 4;
  DFP_PC_NEGATIVE_SUBTOTAL  = 5;

  /////////////////////////////////////////////////////////////////////////////
  // Payment mode constants

  DFP_PM_CASH   = 1;
  DFP_PM_MODE1  = 2;
  DFP_PM_MODE2  = 3;
  DFP_PM_MODE3  = 4;
  DFP_PM_MODE4  = 5;

  DFP_PM_MIN    = 1;
  DFP_PM_MAX    = 5;

  /////////////////////////////////////////////////////////////////////////////
  // Error constants

  DFP_E_NOHARDWARE   = -1;
  DFP_E_FAILURE      = -2;
  DFP_E_CRC          = -3;

  ENoError              = 0;    // No errors
  EDateTimeNotSet       = 200;  // Date and time not set
  EDisplayDisconnected  = 201;  // Customer display not connected
  EInvalidCommandCode   = 202;  // Invalid command code
  EPrinterError         = 203;  // Printer error
  ESumsOverflow         = 204;  // Totalizer overflow
  EInvalidCommandInMode = 205;  // Command is invalid in this mode
  ERecJrnEmpty          = 206;  // Receipt or journal station empty
  EInvalidDataSyntax    = 207;  // Invalid data syntax
  EWrongPassword        = 208;  // Wrong password
  ECutterError          = 209;  // Cutter error
  EMemoryCleared        = 210;  // Memory cleared
  EDocPrintAllowed      = 211;  // Document print not allowed
  EInvalidAnswerLength  = 212;  // Invalid answer length
  ECommandFailed        = 213;  // Command failed

  /////////////////////////////////////////////////////////////////////////////
  // Error messages

  SErrorOK: WideString = 'No errors';
  SInvalidCrc: WideString = 'Invalid CRC';
  SEmptyData: WideString = 'Empty command to send';
  SNoHardware: WideString = 'No connection to device';
  SInvalidAnswerCode: WideString = 'Invalid answer code';
  SInvalidLengthValue: WideString = 'Invalid length value';
  SMaxSynReached: WideString = 'Max SYN count reached';
  SInvalidAnswer = 'Invalid answer';

type
  { TDFPDayStatus }

  TDFPDayStatus = record
    CashTotal: Currency;
    Pay1Total: Currency;
    Pay2Total: Currency;
    Pay3Total: Currency;
    Pay4Total: Currency;
    ZRepNo: Integer;
    DocNo: Integer;
    InvoiceNo: Integer;
  end;

  { TDFPReceiptStatus }

  TDFPReceiptStatus = record
    CanVoid: Boolean; // Indicating the possibility to make corrections. [0/1].
    TaxFreeTotal: Currency; // Total of Non-Taxable sales
    Tax1Total: Currency; // Total of Taxable Space sales
    Tax2Total: Currency; // Total of Taxable A sales
    Tax3Total: Currency; // Total of Taxable B sales
    Tax4Total: Currency; // Total of Taxable C sales
    Tax5Total: Currency; // Total of Taxable D sales
    InvoiceFlag: Boolean; // Flag whether is open a detailed fiscal receipt(invoice). For Georgia = 0
    InvoiceNo: AnsiString;
  end;

  { TDFPBarcode }

  TDFPBarcode = record
    BType: Integer;
    Data: AnsiString;
    Position: Integer;
    Scale: Integer;
    Heightmm: Integer; // Height in mm
    Text: Boolean;
  end;

  { TDFPOperatorName }

  TDFPOperatorName = record
    Number: Integer;
    Password: Integer;
    Name: WideString;
  end;

  { TDFPOperator }

  TDFPOperator = record
    Number: Integer;            // operator number
    NumReceipts: Integer;       // number of fiscal receipts
    TotalNum: Integer;          // number of sales
    TotalAmount: Currency;      // amount of sales
    DiscountNum: Integer;       // number of discounts
    DiscountAmount: Currency;   // amount of discounts
    SurchargeNum: Integer;      // number of surcharges
    SurchargeAmount: Currency;  // amount of surcharges
    VoidNum: Integer;           // number of corrections
    VoidAmount: Currency;       // amount of corrections
    Name: WideString;           // operator name.
  end;

  { TDFPDateRange }

  TDFPDateRange = record
    StartDate: TDateTime;
    EndDate: TDateTime;
  end;

  { TDFPCashRequest }

  TDFPCashRequest = record
    Amount: Currency;
    Text1: WideString;
    Text2: WideString;
  end;

  { TDFPCashResponse }

  TDFPCashResponse = record
    CashAmount: Currency;
    CashInAmount: Currency;
    CashOutAmount: Currency;
  end;

  TDFPVATRates = array [MinVATRate..MaxVATRate] of Double;

  { TDFPConstants }

  TDFPConstants = record
    MaxLogoWidth: Integer; // Horizontal size of Graphical Logo in pixels.
    MaxLogoHeight: Integer; // Vertical size of Graphical Logo in pixels..
    NumPaymentTypes: Integer; // Number of payment types
    NumVATRate: Integer; // Number of tax group.
    TaxFreeLetter: AnsiString; // Letter for non-taxable items (= 20h)
    VATRate1Letter: AnsiString; // Symbol concerning first tax group
    Dimension: Integer; // Dimension of inner arithmetics
    DescriptionLength: Integer; // Number of symbols per line..
    MessageLength: Integer; // Number of symbols per comment line
    NameLength: Integer; // Length of names (operators,PLUs,departments).
    MRCLength: Integer; // Length (number of symbols)of the MRC of FD
    FMNumberLength: Integer; // Length (number of symbols)of the Fiscal Memory Number
    REGNOLength: Integer; // Length (number of symbols)of REGNO
    DepartmentsNumber: Integer; // Number of departments.
    PLUNumber: Integer; // Number of PLUs.
    NumberOfStockGroups: Integer; // Number of stock groups.
    OperatorsNumber: Integer; // Number of operators..
    PaymentNameLength: Integer; // Length of the payment names
  end;

  { TDFPPrintOptions }

  TDFPPrintOptions = record
    BlankLineAfterHeader: Boolean;
    BlankLineAfterRegno: Boolean;
    BlankLineAfterFooter: Boolean;
    DelimiterLineBeforeTotal: Boolean;
  end;

  { TDFPDiagnosticInfo }

  TDFPDiagnosticInfo = record
    FirmwareVersion: AnsiString;
    FirmwareDate: AnsiString;
    FirmwareTime: AnsiString;
    ChekSum: AnsiString;
    Switches: Integer;
    Country: Byte;
    FDSerial: AnsiString;
    FDNo: AnsiString;
  end;

  { TDFPTotals }

  TDFPTotals = record
    SalesTotalTaxFree: Currency; // SpaceGr Session Non-Taxable sales Total
    SalesTotalTax: array [1..5] of Currency; // Sales totals by tax
  end;

  { TDFPFiscalRecord }

  TDFPFiscalRecord = record
    Number: Integer;          // Number of the last fiscal record.
    SalesTotalTaxFree: Currency; // SpaceGr Session Non-Taxable sales Total
    SalesTotalTax: array [1..5] of Currency; // Sales totals by tax
    Date: TDateTime; // Date of the last fiscal record
  end;

  { TDFPFiscalRecords }

  TDFPFiscalRecords = record
    LogicalNumber: Integer;
    PhysicalNumber: Integer;
  end;

  { TDFPPLU }

  TDFPPLU = record
    Sign: AnsiChar;
    PLU: AnsiString;
    Quantity: Double;
    Price: Currency;
    DiscountPercent: Double;
    DiscountAmount: Currency;
  end;

  { TDFPTotal }

  TDFPTotal = record
    Text1: WideString;
    Text2: WideString;
    PaymentMode: Integer;
    Amount: Currency;
  end;

  { TDFPTotalResponse }

  TDFPTotalResponse = record
    PaidCode: Integer;
    Amount: Currency;
  end;

  { TDFPSubtotal }

  TDFPSubtotal = record
    PrintSubtotal: Boolean;
    DisplaySubtotal: Boolean;
    AdjustmentPercent: Double;
  end;

  { TDFPSubtotalResponse }

  TDFPSubtotalResponse = record
    SubTotal: Currency;
    SalesTaxFree: Currency;
    TaxTotals: array [1..MaxVATRate] of Currency;
  end;

  { TDFPVATRateResponse }

  TDFPVATRateResponse = record
    DataFound: Boolean;
    VATRate: array [1..5] of Double;
    Date: TDateTime;
  end;

  { TDFPSale }

  TDFPSale = record
    Text1: WideString;
    Text2: WideString;
    Tax: Byte;
    Price: Currency;
    Quantity: Double;
    DiscountPercent: Double;
    DiscountAmount: Currency;
  end;

  { TDFPOperatorPassword }

  TDFPOperatorPassword = record
    Number: Byte;
    Password: Integer;
  end;

  { TDFPRecNumber }

  TDFPRecNumber = record
    DocNumber: Integer;
    RecNumber: Integer;
  end;

  { TDFPReportAnswer }

  TDFPReportAnswer = record
    ReportNumber: Integer;
    SalesTotalTaxFree: Currency;
    SalesTotalTax: array [1..5] of Currency;
  end;

  { TDaisyCommand }

  TDaisyCommand = record
    Sequence: Byte;
    Code: Byte;
    Data: AnsiString;
  end;

  { TDaisyAnswer }

  TDaisyAnswer = record
    Sequence: Byte;
    Code: Byte;
    Data: WideString;
    Status: AnsiString;
  end;

  { TDaisyStatus }

  TDaisyStatus = record
    Data: string;
    // Byte 0
    GeneralError: Boolean;
    PrinterError: Boolean;
    DisplayDisconnected: Boolean;
    ClockNotSet: Boolean;
    InvalidCommandCode: Boolean;
    InvalidDataSyntax: Boolean;
    // Byte 1
    WrongPassword: Boolean;
    CutterError: Boolean;
    MemoryCleared: Boolean;
    InvalidCommandInMode: Boolean;
    SumsOverflow: Boolean;
    // Byte 2
    DocPrintAllowed: Boolean;
    NonfiscalOpened: Boolean;
    JrnNearEnd: Boolean;
    FiscalOpened: Boolean;
    JrnEmpty: Boolean;
    RecNearEnd: Boolean;
    RecJrnNearEnd: Boolean;
    RecJrnEmpty: Boolean;

    // Byte 3
    FDError: Byte;  // Error number of Fiscal device
    // Byte 4
    FMError: Boolean; // 4.5
    FMOverflow: Boolean; // 4.4, Fiscal memory full
    FMLess50Zreports: Boolean; // 4.3, Room for less than 50 records in fiscal memory
    FMInvalidRecord: Boolean; // 4.2, Invalid record in fiscal memory
    FMWriteError: Boolean; // 4.0, Fiscal memory write error

    // Byte 5
    SerialNumber: Boolean; // 5.5, MRC is programmed
    VATRatesSet: Boolean; // 5.4, Tax rates is programmed
    Fiscalized: Boolean; // 5.3, Fiscalized device
    FMFormatted: Boolean; // 5.1, Not used
    FMReadOnly: Boolean; // 5.0, FM overflowed
  end;

  { IDaisyPrinter }

  IDaisyPrinter = interface
  ['{62559948-EC5F-4956-BE86-2603FA61449D}']
    function GetConstants: TDFPConstants;
    function GetDiagnostic: TDFPDiagnosticInfo;
    function GetLastError: Integer;
    function GetLogger: ILogFile;
    function GetOnStatusUpdate: TNotifyEvent;
    function GetPort: IPrinterPort;
    function GetRegKeyName: WideString;
    function GetStatus: TDaisyStatus;
    function GetVATRates: TDFPVATRates;
    procedure SetOnStatusUpdate(const Value: TNotifyEvent);
    procedure SetRegKeyName(const Value: WideString);

    procedure Lock;
    procedure Unlock;
    procedure LoadParams;
    procedure SaveParams;
    function CheckStatus: Integer;
    function SaleCommand(Cmd: Char; const P: TDFPSale): Integer;
    function DecodePrinterText(const Text: AnsiString): WideString;
    function EncodePrinterText(const Text: WideString): AnsiString;
    procedure SendCommand(const Tx: AnsiString; var RxData: AnsiString);

    function Send(const TxData: AnsiString): Integer; overload;
    function Send(const TxData: AnsiString; var RxData: AnsiString): Integer; overload;

    procedure Check(Code: Integer);
    function Reset: Integer;
    function Connect: Integer;
    function Disconnect: Integer;
    function SearchDevice: Integer;

    function XReport(var R: TDFPReportAnswer): Integer;
    function ZReport(var R: TDFPReportAnswer): Integer;
    function ClearExternalDisplay: Integer;
    function FullCut: Integer;
    function PartialCut: Integer;
    function Succeeded(ResultCode: Integer): Boolean;
    function StartNonfiscalReceipt(var RecNumber: Integer): Integer;
    function EndNonfiscalReceipt(var RecNumber: Integer): Integer;
    function PrintNonfiscalText(const Text: WideString): Integer;
    function PrintNonfiscalLine(const Text: WideString): Integer;
    function PaperFeed(LineCount: Integer): Integer;
    function PaperCut(CutMode: Integer): Integer;
    function StartFiscalReceipt(const P: TDFPOperatorPassword; var R: TDFPRecNumber): Integer;
    function Sale(const P: TDFPSale): Integer;
    function SaleAndDisplay(const P: TDFPSale): Integer;
    function ReadVATRatesOnDate(const P: TDFPDateRange; var R: TDFPVATRateResponse): Integer;

    function Subtotal(const P: TDFPSubtotal; var R: TDFPSubtotalResponse): Integer;
    function PrintTotal(const P: TDFPTotal; var R: TDFPTotalResponse): Integer;
    function PrintFiscalText(const Text: WideString): Integer;
    function EndFiscalReceipt(var R: TDFPRecNumber): Integer;
    function SaleByPLU(const P: TDFPPLU): Integer;
    function WriteDateTime(Date: TDateTime): Integer;
    function ReadDateTime(var Date: TDateTime): Integer;
    function DisplayDateTime: Integer;
    function FinalFiscalRecord(DataType: AnsiChar; var R: TDFPFiscalRecord): Integer;
    function ReadTotals(DataType: Integer; var R: TDFPTotals): Integer;
    function ReadFreeFiscalRecords(var R: TDFPFiscalrecords): Integer;
    function PrintDiagnosticInfo: Integer;
    function PrintReportByNumbers(StartNum, EndNum: Integer): Integer;
    function ReadStatus: Integer;
    function ReadDiagnosticInfo(CalcCRC: Boolean; var R: TDFPDiagnosticInfo): Integer;
    function CancelReceipt: Integer;
    function WritePrintOptions(const Options: TDFPPrintOptions): Integer;
    function ReadPrintOptions(var Options: TDFPPrintOptions): Integer;
    function WriteLogoEnabled(Value: Boolean): Integer;
    function ReadLogoEnabled(var Value: Boolean): Integer;
    function ReadCutMode(var Value: Integer): Integer;
    function WriteCutMode(Value: Integer): Integer;
    function WriteDetailedReceipt(Value: Boolean): Integer;
    function ReadDetailedReceipt(var Value: Boolean): Integer;
    function WriteText(N: Integer; const S: WideString): Integer;
    function ReadText(N: Integer; var S: WideString): Integer;
    function ReadParameter(N: Integer; var S: AnsiString): Integer;
    function WriteParameter(N: Integer; const S: AnsiString): Integer;
    function ReadIntParameter(N: Integer; var Value: Integer): Integer;
    function WriteIntParameter(N, Value: Integer): Integer;

    function ReadConstants(var R: TDFPConstants): Integer;
    function PrintVATRates: Integer;
    function PrintParameters: Integer;
    function ReadVATRates(var VATRates: TDFPVATRates): Integer;
    function WriteVATRates(const VATRates: TDFPVATRates): Integer;
    function LoadLogo(const Logo: TGraphic): Integer;
    function LoadLogoFile(const FileName: WideString): Integer;
    function PrintBarcode(const Data: AnsiString): Integer;
    function PrintBarcode2(const Barcode: TDFPBarcode): Integer;
    function PrintCash(const P: TDFPCashRequest; var R: TDFPCashResponse): Integer;
    function DuplicatePrint(Count,DocNo: Integer): Integer;
    function ReadOperator(N: Integer; var R: TDFPOperator): Integer;
    function WriteOperatorName(const P: TDFPOperatorName): Integer;
    function WritePrinterNumber(N: Integer): Integer;
    function ReadReceiptStatus(var R: TDFPReceiptStatus): Integer;
    function ReadDayStatus(var R: TDFPDayStatus): Integer;
    function ReadLastDocNo(var DocNo: Integer): Integer;
    function WriteFiscalNumber(const FiscalNumber: AnsiString): Integer;

    property Port: IPrinterPort read GetPort;
    property Logger: ILogFile read GetLogger;
    property Status: TDaisyStatus read GetStatus;
    property LastError: Integer read GetLastError;
    property VATRates: TDFPVATRates read GetVATRates;
    property Constants: TDFPConstants read GetConstants;
    property Diagnostic: TDFPDiagnosticInfo read GetDiagnostic;
    property RegKeyName: WideString read GetRegKeyName write SetRegKeyName;
    property OnStatusUpdate: TNotifyEvent read GetOnStatusUpdate write SetOnStatusUpdate;
  end;

implementation

end.
