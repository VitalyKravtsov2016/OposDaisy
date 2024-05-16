unit TestDaisyPrinter;

interface

uses
  // VCL
  Classes, Graphics,
  // Tnt
  TntClasses,
  // This
  LogFile, PrinterPort, DaisyPrinterInterface;

type
  { TTestDaisyPrinter }

  TTestDaisyPrinter = class(TInterfacedObject, IDaisyPrinter)
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
    function GetOnStatusUpdate: TNotifyEvent;
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
    property Status: TDaisyStatus read GetStatus;
    property LastError: Integer read GetLastError;
    property VATRates: TDFPVATRates read GetVATRates;
    property Constants: TDFPConstants read GetConstants;
    property Diagnostic: TDFPDiagnosticInfo read GetDiagnostic;
    property RegKeyName: WideString read GetRegKeyName write SetRegKeyName;
    property OnStatusUpdate: TNotifyEvent read GetOnStatusUpdate write SetOnStatusUpdate;
  end;

implementation

{ TTestDaisyPrinter }

constructor TTestDaisyPrinter.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FLines := TTntStringList.Create;
  FPort := APort;
  FLogger := ALogger;

  FConstants.MaxLogoWidth := 576;
  FConstants.MaxLogoHeight := 144;
  FConstants.NumPaymentTypes := 5;
  FConstants.NumVATRate := 5;
  FConstants.TaxFreeLetter := '';
  FConstants.VATRate1Letter := ' ';
  FConstants.Dimension := 8;
  FConstants.DescriptionLength := 48;
  FConstants.MessageLength := 44;
  FConstants.NameLength := 32;
  FConstants.MRCLength := 10;
  FConstants.FMNumberLength := 10;
  FConstants.REGNOLength := 15;
  FConstants.DepartmentsNumber := 50;
  FConstants.PLUNumber := 30000;
  FConstants.NumberOfStockGroups := 0;
  FConstants.OperatorsNumber := 20;
  FConstants.PaymentNameLength := 12;
end;

destructor TTestDaisyPrinter.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

function TTestDaisyPrinter.CancelReceipt: Integer;
begin
  Result := 0;
end;

procedure TTestDaisyPrinter.Check(Code: Integer);
begin

end;

function TTestDaisyPrinter.CheckStatus: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ClearExternalDisplay: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Connect: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.DecodePrinterText(
  const Text: AnsiString): WideString;
begin
  Result := Text;
end;

function TTestDaisyPrinter.Disconnect: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.DisplayDateTime: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.DuplicatePrint(Count, DocNo: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.EncodePrinterText(
  const Text: WideString): AnsiString;
begin
  Result := Text;
end;

function TTestDaisyPrinter.EndFiscalReceipt(var R: TDFPRecNumber): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.EndNonfiscalReceipt(
  var RecNumber: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.FinalFiscalRecord(DataType: AnsiChar;
  var R: TDFPFiscalRecord): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.FullCut: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.GetConstants: TDFPConstants;
begin
  Result := FConstants;
end;

function TTestDaisyPrinter.GetDiagnostic: TDFPDiagnosticInfo;
begin
  Result := FDiagnostic;
end;

function TTestDaisyPrinter.GetLastError: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.GetOnStatusUpdate: TNotifyEvent;
begin

end;

function TTestDaisyPrinter.GetRegKeyName: WideString;
begin

end;

function TTestDaisyPrinter.GetStatus: TDaisyStatus;
begin

end;

function TTestDaisyPrinter.GetVATRates: TDFPVATRates;
begin
  Result := FVATRates;
end;

function TTestDaisyPrinter.LoadLogo(const Logo: TGraphic): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.LoadLogoFile(
  const FileName: WideString): Integer;
begin
  Result := 0;
end;

procedure TTestDaisyPrinter.LoadParams;
begin

end;

procedure TTestDaisyPrinter.Lock;
begin

end;

function TTestDaisyPrinter.PaperCut(CutMode: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PaperFeed(LineCount: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PartialCut: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintBarcode(const Data: AnsiString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintBarcode2(
  const Barcode: TDFPBarcode): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintCash(const P: TDFPCashRequest;
  var R: TDFPCashResponse): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintDiagnosticInfo: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintFiscalText(
  const Text: WideString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintNonfiscalLine(
  const Text: WideString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintNonfiscalText(
  const Text: WideString): Integer;
begin
  Lines.Add(Text);
  Result := 0;
end;

function TTestDaisyPrinter.PrintParameters: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintReportByNumbers(StartNum,
  EndNum: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintTotal(const P: TDFPTotal;
  var R: TDFPTotalResponse): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.PrintVATRates: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadConstants(var R: TDFPConstants): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadCutMode(var Value: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadDateTime(var Date: TDateTime): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadDayStatus(var R: TDFPDayStatus): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadDetailedReceipt(
  var Value: Boolean): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadDiagnosticInfo(CalcCRC: Boolean;
  var R: TDFPDiagnosticInfo): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadFreeFiscalRecords(
  var R: TDFPFiscalrecords): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadIntParameter(N: Integer;
  var Value: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadLastDocNo(var DocNo: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadLogoEnabled(var Value: Boolean): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadOperator(N: Integer;
  var R: TDFPOperator): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadParameter(N: Integer;
  var S: AnsiString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadPrintOptions(
  var Options: TDFPPrintOptions): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadReceiptStatus(
  var R: TDFPReceiptStatus): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadStatus: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadText(N: Integer;
  var S: WideString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadTotals(DataType: Integer;
  var R: TDFPTotals): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadVATRates(
  var VATRates: TDFPVATRates): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ReadVATRatesOnDate(const P: TDFPDateRange;
  var R: TDFPVATRateResponse): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Reset: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Sale(const P: TDFPSale): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.SaleAndDisplay(const P: TDFPSale): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.SaleByPLU(const P: TDFPPLU): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.SaleCommand(Cmd: Char;
  const P: TDFPSale): Integer;
begin
  Result := 0;
end;

procedure TTestDaisyPrinter.SaveParams;
begin

end;

function TTestDaisyPrinter.SearchDevice: Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Send(const TxData: AnsiString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Send(const TxData: AnsiString;
  var RxData: AnsiString): Integer;
begin
  Result := 0;
end;

procedure TTestDaisyPrinter.SendCommand(const Tx: AnsiString;
  var RxData: AnsiString);
begin

end;

procedure TTestDaisyPrinter.SetOnStatusUpdate(const Value: TNotifyEvent);
begin

end;

procedure TTestDaisyPrinter.SetRegKeyName(const Value: WideString);
begin

end;

function TTestDaisyPrinter.StartFiscalReceipt(
  const P: TDFPOperatorPassword; var R: TDFPRecNumber): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.StartNonfiscalReceipt(
  var RecNumber: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Subtotal(const P: TDFPSubtotal;
  var R: TDFPSubtotalResponse): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.Succeeded(ResultCode: Integer): Boolean;
begin
  Result := ResultCode = 0;
end;

procedure TTestDaisyPrinter.Unlock;
begin

end;

function TTestDaisyPrinter.WriteCutMode(Value: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteDateTime(Date: TDateTime): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteDetailedReceipt(Value: Boolean): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteFiscalNumber(
  const FiscalNumber: AnsiString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteIntParameter(N, Value: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteLogoEnabled(Value: Boolean): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteOperatorName(
  const P: TDFPOperatorName): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteParameter(N: Integer;
  const S: AnsiString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WritePrinterNumber(N: Integer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WritePrintOptions(
  const Options: TDFPPrintOptions): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteText(N: Integer;
  const S: WideString): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.WriteVATRates(
  const VATRates: TDFPVATRates): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.XReport(var R: TDFPReportAnswer): Integer;
begin
  Result := 0;
end;

function TTestDaisyPrinter.ZReport(var R: TDFPReportAnswer): Integer;
begin
  Result := 0;
end;

end.
