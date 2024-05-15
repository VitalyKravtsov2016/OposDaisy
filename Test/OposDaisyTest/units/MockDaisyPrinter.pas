unit MockDaisyPrinter;

interface

uses
  // VCL
  Classes, Graphics,
  // Tnt
  TntClasses,
  // This
  LogFile, PrinterPort, DaisyPrinterInterface;

type
  { TMockDaisyPrinter }

  TMockDaisyPrinter = class(TInterfacedObject, IDaisyPrinter)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FLines: TTntStrings;
    FVATRates: TDFPVATRates;
    FConstants: TDFPConstants;
    FDiagnostic: TDFPDiagnosticInfo;
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;

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

    property Lines: TTntStrings read FLines;
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

{ TMockDaisyPrinter }

constructor TMockDaisyPrinter.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FLines := TTntStringList.Create;
  FPort := APort;
  FLogger := ALogger;
end;

destructor TMockDaisyPrinter.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

function TMockDaisyPrinter.CancelReceipt: Integer;
begin
  Result := 0;
end;

procedure TMockDaisyPrinter.Check(Code: Integer);
begin

end;

function TMockDaisyPrinter.CheckStatus: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ClearExternalDisplay: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Connect: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.DecodePrinterText(
  const Text: AnsiString): WideString;
begin
  Result := Text;
end;

function TMockDaisyPrinter.Disconnect: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.DisplayDateTime: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.DuplicatePrint(Count, DocNo: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.EncodePrinterText(
  const Text: WideString): AnsiString;
begin
  Result := Text;
end;

function TMockDaisyPrinter.EndFiscalReceipt(var R: TDFPRecNumber): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.EndNonfiscalReceipt(
  var RecNumber: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.FinalFiscalRecord(DataType: AnsiChar;
  var R: TDFPFiscalRecord): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.FullCut: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.GetConstants: TDFPConstants;
begin
  Result := FConstants;
end;

function TMockDaisyPrinter.GetDiagnostic: TDFPDiagnosticInfo;
begin
  Result := FDiagnostic;
end;

function TMockDaisyPrinter.GetLastError: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.GetLogger: ILogFile;
begin

end;

function TMockDaisyPrinter.GetOnStatusUpdate: TNotifyEvent;
begin

end;

function TMockDaisyPrinter.GetPort: IPrinterPort;
begin

end;

function TMockDaisyPrinter.GetRegKeyName: WideString;
begin

end;

function TMockDaisyPrinter.GetStatus: TDaisyStatus;
begin

end;

function TMockDaisyPrinter.GetVATRates: TDFPVATRates;
begin
  Result := FVATRates;
end;

function TMockDaisyPrinter.LoadLogo(const Logo: TGraphic): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.LoadLogoFile(
  const FileName: WideString): Integer;
begin
  Result := 0;
end;

procedure TMockDaisyPrinter.LoadParams;
begin

end;

procedure TMockDaisyPrinter.Lock;
begin

end;

function TMockDaisyPrinter.PaperCut(CutMode: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PaperFeed(LineCount: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PartialCut: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintBarcode(const Data: AnsiString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintBarcode2(
  const Barcode: TDFPBarcode): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintCash(const P: TDFPCashRequest;
  var R: TDFPCashResponse): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintDiagnosticInfo: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintFiscalText(
  const Text: WideString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintNonfiscalLine(
  const Text: WideString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintNonfiscalText(
  const Text: WideString): Integer;
begin
  Lines.Add(Text);
  Result := 0;
end;

function TMockDaisyPrinter.PrintParameters: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintReportByNumbers(StartNum,
  EndNum: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintTotal(const P: TDFPTotal;
  var R: TDFPTotalResponse): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.PrintVATRates: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadConstants(var R: TDFPConstants): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadCutMode(var Value: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadDateTime(var Date: TDateTime): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadDayStatus(var R: TDFPDayStatus): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadDetailedReceipt(
  var Value: Boolean): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadDiagnosticInfo(CalcCRC: Boolean;
  var R: TDFPDiagnosticInfo): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadFreeFiscalRecords(
  var R: TDFPFiscalrecords): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadIntParameter(N: Integer;
  var Value: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadLastDocNo(var DocNo: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadLogoEnabled(var Value: Boolean): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadOperator(N: Integer;
  var R: TDFPOperator): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadParameter(N: Integer;
  var S: AnsiString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadPrintOptions(
  var Options: TDFPPrintOptions): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadReceiptStatus(
  var R: TDFPReceiptStatus): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadStatus: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadText(N: Integer;
  var S: WideString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadTotals(DataType: Integer;
  var R: TDFPTotals): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadVATRates(
  var VATRates: TDFPVATRates): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ReadVATRatesOnDate(const P: TDFPDateRange;
  var R: TDFPVATRateResponse): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Reset: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Sale(const P: TDFPSale): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.SaleAndDisplay(const P: TDFPSale): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.SaleByPLU(const P: TDFPPLU): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.SaleCommand(Cmd: Char;
  const P: TDFPSale): Integer;
begin
  Result := 0;
end;

procedure TMockDaisyPrinter.SaveParams;
begin

end;

function TMockDaisyPrinter.SearchDevice: Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Send(const TxData: AnsiString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Send(const TxData: AnsiString;
  var RxData: AnsiString): Integer;
begin
  Result := 0;
end;

procedure TMockDaisyPrinter.SendCommand(const Tx: AnsiString;
  var RxData: AnsiString);
begin

end;

procedure TMockDaisyPrinter.SetOnStatusUpdate(const Value: TNotifyEvent);
begin

end;

procedure TMockDaisyPrinter.SetRegKeyName(const Value: WideString);
begin

end;

function TMockDaisyPrinter.StartFiscalReceipt(
  const P: TDFPOperatorPassword; var R: TDFPRecNumber): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.StartNonfiscalReceipt(
  var RecNumber: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Subtotal(const P: TDFPSubtotal;
  var R: TDFPSubtotalResponse): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.Succeeded(ResultCode: Integer): Boolean;
begin
  Result := ResultCode = 0;
end;

procedure TMockDaisyPrinter.Unlock;
begin

end;

function TMockDaisyPrinter.WriteCutMode(Value: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteDateTime(Date: TDateTime): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteDetailedReceipt(Value: Boolean): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteFiscalNumber(
  const FiscalNumber: AnsiString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteIntParameter(N, Value: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteLogoEnabled(Value: Boolean): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteOperatorName(
  const P: TDFPOperatorName): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteParameter(N: Integer;
  const S: AnsiString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WritePrinterNumber(N: Integer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WritePrintOptions(
  const Options: TDFPPrintOptions): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteText(N: Integer;
  const S: WideString): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.WriteVATRates(
  const VATRates: TDFPVATRates): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.XReport(var R: TDFPReportAnswer): Integer;
begin
  Result := 0;
end;

function TMockDaisyPrinter.ZReport(var R: TDFPReportAnswer): Integer;
begin
  Result := 0;
end;

end.
