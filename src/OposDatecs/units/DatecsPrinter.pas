unit DatecsPrinter;

interface

uses
  // VCL
  Windows, SysUtils, ActiveX, Variants,
  // Tnt
  TntSysUtils,
  // This
  ExellioFrame, ExellioTypes, SerialPort2, StrUtil,
  DriverError2, LogFile2, VersionInfo, StringUtils, VariantUtils, MathUtils;

type
  { TDatecsPrinter }

  TDatecsPrinter = class
  private
    FTxData: string;
    FRxData: string;
    FPort: TSerialPort;
    FLastError: Integer;
    FShowError: Boolean;
    FStatus: TDatecsStatus;
    FAnswer: TExellioAnswer;
    FCommand: TExellioCommand;
    FLastErrorText: WideString;
    FS: array [1..11] of WideString;
    FPrinterEncoding: Integer;
    FDisplayEncoding: Integer;
    FPrinterCodePage: Integer;
    FDisplayCodePage: Integer;

    procedure DecodeAnswer;
    function ClearResult: Integer;
    procedure DecodeParams(Count: Integer);
    function HandleException(E: Exception): Integer;
    procedure SendCommand(const TxData: WideString; var RxData: string);
    function Pack(Params: array of const): string;
    procedure ClearParameters;
    function InvalidParams: Integer;
    function GetPassword(const Value: WideString): WideString;
    function GetParam(i: Integer): string;
    function SetLastError(ErrorCode: Integer): Integer;
    function TestIntParam(Value, Min, Max: Integer;
      const ParamName: string): Integer;
    function TestOperator(iOperNum: Integer): Integer;
    function TestDate(const Value: string): Integer;
    function TestPassword(const Password: string): Integer;
    function GetTaxLetter(iTax: Integer): Char;
    procedure CheckCode(Code: Integer);
    function TestPlace(Value: Integer): Integer;
    function GetDate(const Value: string): string;
    function TestGroup(Value: Integer): Integer;
    function CheckStatus: Integer;
    function GetPrinterCodePage: Integer;
    function GetDisplayCodePage: Integer;
    function EncodeDisplayText(const Text: WideString): AnsiString;
    function EncodePrinterText(const Text: WideString): AnsiString;
    function DecodePrinterText(const Text: AnsiString): WideString;
  public
    TxCount: Integer;
    function Send(const TxData: WideString): Integer; overload;
    function Send(const TxData: WideString; var RxData: string): Integer; overload;
    property Port: TSerialPort read FPort;
  public
    function AbsDiscGrp(Grp: SYSINT; Dis: Double): Integer; safecall;
    function AbsDiscTax(Grp: SYSINT; Dis: Double): Integer; safecall;
    function AdvancePaper(iLines: SYSINT): Integer; safecall;
    function AdvancePaperEx(iLines, iType: SYSINT): Integer; safecall;
    function CancelReceipt: Integer; safecall;
    function ChangeArticlePrice(const Pass: WideString; iCode: SYSINT;
      dPrice: Double): Integer; safecall;
    function ClearDisplay: Integer; safecall;
    function ClearOperator(iOperNum: SYSINT; const Pass: WideString): Integer;
      safecall;
    function ClearOperatorPassword(iOperNum: SYSINT;
      const AdmPass: WideString): Integer; safecall;
    function CloseFiscalReceipt: Integer; safecall;
    function CloseNonfiscalReceipt: Integer; safecall;
    function CutReceipt: Integer; safecall;
    function DelArticle(const Pass: WideString; iCode: SYSINT): Integer;
      safecall;
    function DelAllArticles(const Pass: WideString): Integer; safecall;
    function DisplayDateTime: Integer; safecall;
    function DisplayFreeText(const Text: WideString): Integer; safecall;
    function DisplayTextLL(const Text: WideString): Integer; safecall;
    function DisplayTextUL(const Text: WideString): Integer; safecall;
    function EnableAutoOpenDrawer(bEnabled: WordBool): Integer; safecall;
    function EnableCRReport(Mode: WordBool): Integer; safecall;
    function EnableCutCheck(bEnabled: WordBool): Integer; safecall;
    function EnableLogo(bEnabled: WordBool): Integer; safecall;
    function EnableSmallFont(bEnabled: WordBool): Integer; safecall;
    function Fiscalise(const Pass, SerNum, TaxNum: WideString;
      iTaxNumType: SYSINT): Integer; safecall;
    function Get_DbgText: WideString; safecall;
    function Get_IsFiscalised: SYSINT; safecall;
    function Get_IsFiscalOpen: WordBool; safecall;
    function Get_LastError: SYSINT; safecall;
    function Get_LastErrorText: WideString; safecall;
    function Get_LastFPErrorText: WideString; safecall;
    function Get_LSS: WideString; safecall;
    function Get_StatusBytes(Index: Byte): WideString; safecall;
    function GetArticle(iCode: SYSINT): Integer; safecall;
    function GetArticlesInfo: Integer; safecall;
    function GetCorectSums: Integer; safecall;
    function GetCurrentSums(iParam: SYSINT): Integer; safecall;
    function GetCurrentTaxRates: Integer; safecall;
    function GetDateTime: Integer; safecall;
    function GetDayInfo: Integer; safecall;
    function GetDiagnosticInfo(bCalcCRC: WordBool): Integer; safecall;
    function GetErrorMessage(ErrCode: Integer): WideString; safecall;
    function GetFirstArticle: Integer; safecall;
    function GetFirstFreeArticle: Integer; safecall;
    function GetFiscalClosureStatus(bCurrent: WordBool): Integer; safecall;
    function GetFreeClosures: Integer; safecall;
    function GetHeader(iLine: SYSINT): Integer; safecall;
    function GetLastArticle: Integer; safecall;
    function GetLastClosureDate: Integer; safecall;
    function GetLastFreeArticle: Integer; safecall;
    function GetLastReceiptNum: Integer; safecall;
    function GetNextArticle: Integer; safecall;
    function GetOperatorInfo(iOperNum: SYSINT): Integer; safecall;
    function GetReceiptEjCopy(Mode: Integer): Integer; safecall;
    function GetReceiptInfo: Integer; safecall;
    function GetSettingValue(Param: Integer): Integer; safecall;
    function GetSmenLen: Integer; safecall;
    function GetStatus(bWait: WordBool): Integer; safecall;
    function GetTaxNumber: Integer; safecall;
    function InOut(dSum: Double): Integer; safecall;
    function LastFiscalClosure(iParam: SYSINT): Integer; safecall;
    function LogoLoad(const Pass: WideString; iLine: SYSINT;
      const Data: WideString): Integer; safecall;
    function MakeReceiptCopy(iCount: SYSINT): Integer; safecall;
    function OpenDrawer: Integer; safecall;
    function OpenDrawerEx(iMsc: SYSINT): Integer; safecall;
    function OpenFiscalReceipt(iOperator: SYSINT; const Password: WideString;
      iPlaceNumber: SYSINT): Integer; safecall;
    function OpenNonfiscalReceipt: Integer; safecall;
    function OpenPort(const PortName: WideString; iSpeed: SYSINT): Integer;
      safecall;
    function OpenReturnReceipt(iOperator: SYSINT; const Pass: WideString;
      iPlaceNum: SYSINT): Integer; safecall;
    function PerDiscGrp(Grp: SYSINT; Dis: Double): Integer; safecall;
    function PerDiscTax(Grp: SYSINT; Dis: Double): Integer; safecall;
    function PrintBarCode(iType: SYSINT; const Text: WideString): Integer;
      safecall;
    function PrintDiagnosticInfo: Integer; safecall;
    function PrintFiscalText(const Text: WideString): Integer; safecall;
    function PrintLine(iType: SYSINT): Integer; safecall;
    function PrintNonfiscalText(const Text: WideString): Integer; safecall;
    function PrintNullCheck: Integer; safecall;
    function PrintRepByArt(const Pass: WideString; iType: SYSINT): Integer;
      safecall;
    function PrintRepByDate(const Pass, BegDate, EndDate: WideString): Integer;
      safecall;
    function PrintRepByDateFull(const Pass, BegDate,
      EndDate: WideString): Integer; safecall;
    function PrintRepByNum(const Pass: WideString; iBegNum,
      iEndNum: SYSINT): Integer; safecall;
    function PrintRepByNumFull(const Pass: WideString; iBegNum,
      iEndNum: SYSINT): Integer; safecall;
    function PrintRepByOperator(const Pass: WideString): Integer; safecall;
    function PrintTaxReport(const Pass, BegDate, EndDate: WideString): Integer;
      safecall;
    function RegistrAndDisplayItem(iArtNum: SYSINT; dQnty, dPercentDisc,
      dSumDisc: Double): Integer; safecall;
    function RegistrAndDisplayItemEx(iArtNum: SYSINT; dQnty, dPrice,
      dPercentDisc, dSumDisc: Double): Integer; safecall;
    function RegistrItem(iArtNum: SYSINT; dQnty, dPercentDisc,
      dSumDisc: Double): Integer; safecall;
    function RegistrItemEx(iArtNum: SYSINT; dQnty, dPrice, dPercentDisc,
      dSumDisc: Double): Integer; safecall;
    function SaveSettings: Integer; safecall;
    function SetAdminPassword(const OldPass, NewPass: WideString): Integer;
      safecall;
    function SetArticle(iCode, iTax, iGrp: SYSINT; dPrice: Double; const Pass,
      Name: WideString): Integer; safecall;
    function SetBarcodeHeight(Height: SYSINT): Integer; safecall;
    function SetDateTime(const Date, Time: WideString): Integer; safecall;
    function SetFiscalNumber(const FN: WideString): Integer; safecall;
    function SetHeaderFooter(iLine: SYSINT; const Text: WideString): Integer;
      safecall;
    function SetMulDecCurRF(const Pass: WideString; iDec: SYSINT;
      const TaxEnable: WideString; dTaxA, dTaxB, dTaxC,
      dTaxD: Double): Integer; safecall;
    function SetOperatorName(iOperatorNum: SYSINT; const Password,
      Name: WideString): Integer; safecall;
    function SetOperatorPassword(iOperNum: SYSINT; const OldPass,
      NewPass: WideString): Integer; safecall;
    function SetPrintDensity(Density: SYSINT): Integer; safecall;
    function SetSerialNum(const SerialNumber: WideString): Integer; safecall;
    function SetTaxName(Tax: SYSINT; const Name: WideString): Integer;
      safecall;
    function SetTaxNumber(const TaxNumber: WideString; iType: SYSINT): Integer;
      safecall;
    function SetTaxType(iType: SYSINT): Integer; safecall;
    function Sound: Integer; safecall;
    function SoundEx(Hz, Ms: SYSINT): Integer; safecall;
    function SubTotal(dPercentDisc, dSumDisc: Double): Integer; safecall;
    function Total(const Text: WideString; iPayMode: SYSINT;
      dSum: Double): Integer; safecall;
    function TotalEx(const Text: WideString; iPayMode: SYSINT;
      dSum: Double): Integer; safecall;
    function WaitWhilePrintEnd: Integer; safecall;
    function XReport(const Pass: WideString): Integer; safecall;
    function ZReport(const Pass: WideString): Integer; safecall;
    procedure ClosePort; safecall;
    procedure Debugger(bDebug: WordBool); safecall;
    procedure Set_StatusBytes(Index: Byte; const Value: WideString); safecall;
    procedure SetDebugFileName(const Name: WideString); safecall;
    procedure SetReadTimeout(lMSec: Integer); safecall;
    procedure SetTimeout(lMSec: Integer); safecall;
    procedure ShowError(bShow: WordBool); safecall;
    function Get_s1: WideString; safecall;
    function Get_s2: WideString; safecall;
    function Get_s3: WideString; safecall;
    function Get_s4: WideString; safecall;
    function Get_s5: WideString; safecall;
    function Get_s6: WideString; safecall;
    function Get_s7: WideString; safecall;
    function Get_s8: WideString; safecall;
    function Get_s9: WideString; safecall;
    function Get_s10: WideString; safecall;
    function Get_s11: WideString; safecall;

    property DbgText: WideString read Get_DbgText;
    property LastError: SYSINT read Get_LastError;
    property IsFiscalised: SYSINT read Get_IsFiscalised;
    property IsFiscalOpen: WordBool read Get_IsFiscalOpen;
    property LastErrorText: WideString read Get_LastErrorText;
    property LSS: WideString read Get_LSS;
    property LastFPErrorText: WideString read Get_LastFPErrorText;
    property StatusBytes[Index: Byte]: WideString read Get_StatusBytes write Set_StatusBytes;
    property s1: WideString read Get_s1;
    property s2: WideString read Get_s2;
    property s3: WideString read Get_s3;
    property s4: WideString read Get_s4;
    property s5: WideString read Get_s5;
    property s6: WideString read Get_s6;
    property s7: WideString read Get_s7;
    property s8: WideString read Get_s8;
    property s9: WideString read Get_s9;
    property s10: WideString read Get_s10;
    property s11: WideString read Get_s11;
  public
    function GetBarcodeHeight: Integer; safecall;
    function GetCutCheckEnabled: Integer; safecall;
    function GetPrintDensity: Integer; safecall;
    function GetLogoEnabled: Integer; safecall;
    function GetDrawerEnabled: Integer; safecall;
    function GetSmallFontEnabled: Integer; safecall;
    function SendData(const Data: WideString): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    property Status: TDatecsStatus read FStatus;
    property PrinterCodePage: Integer read FPrinterCodePage write FPrinterCodePage;
    property DisplayCodePage: Integer read FDisplayCodePage write FDisplayCodePage;
    property PrinterEncoding: Integer read FPrinterEncoding write FPrinterEncoding;
    property DisplayEncoding: Integer read FDisplayEncoding write FDisplayEncoding;
  end;

const
  MaxParams = 11;
  MaxLineLen = 34;

implementation

function BoolToStr(Value: Boolean): string;
begin
  if Value then Result := '1'
  else Result := '0';
end;

function GetSubStr(const Data: string; Index: Integer): string;
begin
  Result := GetString(Data, Index, [',']);
end;

procedure CheckIntParam(Value, Min, Max: Integer; const ParamName: string);
var
  Text: string;
begin
  if (Value < Min)or(Value > Max) then
  begin
    Text := Format(SInvalidParamValue, [ParamName]);
    //Logger.Debug(Text);
    raiseError(EInvalidParams, SInvalidParams);
  end;
end;

function AmountToStr(Value: Double): string;
var
  DS: Char;
begin
  DS := DecimalSeparator;
  DecimalSeparator := '.';
  Result := Format('%.2f', [Round2(Value*100)/100]);
  DecimalSeparator := DS;
end;

function QuantityToStr(Value: Double): string;
var
  DS: Char;
begin
  DS := DecimalSeparator;
  DecimalSeparator := '.';
  Result := Format('%.3f', [Round2(Value*1000)/1000]);
  DecimalSeparator := DS;
end;

function GetString(const Data: string; k: Integer): string;
var
  S: string;
  i: Integer;
  P: Integer;
begin
  S := '';
  P := 0;
  for i := 1 to Length(Data) do
  begin
    if Data[i] = ',' then
    begin
      Inc(P);
      if P = K then
      begin
        Result := S;
        Exit;
      end;
      S := '';
    end else
    begin
      S := S + Data[i];
    end;
  end;
  if P < k then
  begin
    Result := S;
  end;
end;


{ TDatecsPrinter }

constructor TDatecsPrinter.Create;
begin
  inherited Create;
  FPort := TSerialPort.Create;
  Logger.FileName := ChangeFileExt(GetDllFileName, '.log');
  Logger.Enabled := False;
  TxCount := $20;
  FPrinterEncoding := EncodingAuto;
  FDisplayEncoding := EncodingAuto;
end;

destructor TDatecsPrinter.Destroy;
begin
  FPort.Free;
  inherited Destroy;
end;

function TDatecsPrinter.GetPrinterCodePage: Integer;
begin
  Result := 1251;
  if FStatus.PrinterCP866 then
    Result := 866;
end;

function TDatecsPrinter.GetDisplayCodePage: Integer;
begin
  Result := 1251;
  if FStatus.DisplayCP866 then
    Result := 866;
end;

function TDatecsPrinter.EncodePrinterText(const Text: WideString): AnsiString;
begin
  case PrinterEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := WideStringToAnsiString(GetPrinterCodePage, Text);
    EncodingSelected: Result := WideStringToAnsiString(PrinterCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsPrinter.EncodeDisplayText(const Text: WideString): AnsiString;
begin
  case DisplayEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := WideStringToAnsiString(GetDisplayCodePage, Text);
    EncodingSelected: Result := WideStringToAnsiString(DisplayCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsPrinter.DecodePrinterText(const Text: AnsiString): WideString;
begin
  case PrinterEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := AnsiStringToWideString(GetPrinterCodePage, Text);
    EncodingSelected: Result := AnsiStringToWideString(PrinterCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsPrinter.ClearResult: Integer;
begin
  FLastError := 0;
  FLastErrorText := '';
  Result := FLastError;
end;

function TDatecsPrinter.SetLastError(ErrorCode: Integer): Integer;
begin
  Result := ErrorCode;
  FLastError := ErrorCode;
  FLastErrorText := GetErrorText(ErrorCode);
  Logger.Error('%d, %s', [FLastError, FLastErrorText]);
end;

function TDatecsPrinter.HandleException(E: Exception): Integer;
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    FLastError := DriverError.Code;
    FLastErrorText := DriverError.Text;
  end else
  begin
    FLastError := DATECS_E_FAILURE;
    FLastErrorText := e.Message;
  end;
  Logger.Error('%d, %s', [FLastError, FLastErrorText]);
  Result := FLastError;
end;

function TDatecsPrinter.TestIntParam(Value, Min, Max: Integer;
  const ParamName: string): Integer;
var
  Text: string;
begin
  Result := ClearResult;
  if (Value < Min)or(Value > Max) then
  begin
    Text := Format(SInvalidParamValue, [ParamName]);
    Logger.Debug(Text);
    Result := InvalidParams;
  end;
end;

function TDatecsPrinter.TestPlace(Value: Integer): Integer;
begin
  Result := TestIntParam(Value, 1, 65535, 'PlaceNumber');
end;

function TDatecsPrinter.GetDate(const Value: string): string;
begin
  Result := Copy(Value, 1, 6);
end;

function TDatecsPrinter.TestDate(const Value: string): Integer;
begin
  Result := ClearResult;
  if Length(Value) < 6 then
  begin
    Result := InvalidParams;
  end;
end;

function TDatecsPrinter.TestPassword(const Password: string): Integer;
begin
  Result := ClearResult;
  if (Length(Password) < 4) then
  begin
    Logger.Debug(Format('%s, ''%s''', [SInvalidPasswordLength, Password]));
    Result := InvalidParams;
  end;
end;

function TDatecsPrinter.TestOperator(iOperNum: Integer): Integer;
begin
  Result := TestIntParam(iOperNum, 1, 16, 'iOperNum');
end;

function TDatecsPrinter.InvalidParams: Integer;
begin
  Result := EInvalidParams;
  FLastError := EInvalidParams;
  FLastErrorText := SInvalidParams;
end;

function TDatecsPrinter.GetPassword(const Value: WideString): WideString;
begin
  Result := Copy(Value, 1, 8);
end;

function TDatecsPrinter.Pack(Params: array of const): string;
begin
  Result := VarArrayToStr(ConstArrayToVarArray(Params));
end;

procedure TDatecsPrinter.DecodeAnswer;
begin
  DecodeParams(MaxParams);
end;

function TDatecsPrinter.GetParam(i: Integer): string;
begin
  Result := GetString(FAnswer.Data, i);
end;

procedure TDatecsPrinter.DecodeParams(Count: Integer);
var
  i: Integer;
  P: Integer;
begin
  P := Min(MaxParams, Count);
  for i := 1 to P do
  begin
    FS[i] := GetParam(i);
  end;
end;

function TDatecsPrinter.Send(const TxData: WideString): Integer;
var
  RxData: string;
begin
  Result := Send(TxData, RxData);
end;

procedure TDatecsPrinter.ClearParameters;
var
  i: Integer;
begin
  for i := Low(FS) to High(FS) do
    FS[i] := '';
end;

function TDatecsPrinter.CheckStatus: Integer;
begin
  if Status.InvalidCommandCode then
  begin
    Result := SetLastError(37);
    Exit;
  end;

  if Status.ClockNotSet then
  begin
    Result := SetLastError(10);
    Exit;
  end;

  if Status.DisplayDisconnected then
  begin
    Result := SetLastError(11);
    Exit;
  end;

  if Status.PrinterError then
  begin
    Result := SetLastError(38);
    Exit;
  end;

  if Status.AddOverflow then
  begin
    Result := SetLastError(39);
    Exit;
  end;

  if Status.InvalidCommandInMode then
  begin
    Result := SetLastError(40);
    Exit;
  end;

  if Status.RecJrnStationEmpty then
  begin
    Result := SetLastError(12);
    Exit;
  end;

  Result := ClearResult;
end;

function TDatecsPrinter.Send(const TxData: WideString; var RxData: string): Integer;
begin
  try
    ClearParameters;
    SendCommand(TxData, RxData);
    Result := CheckStatus;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TDatecsPrinter.SendCommand(const TxData: WideString; var RxData: string);
var
  B: Byte;
  S: string;
  i: Integer;
const
  MaxCommandCount = 3;
begin
  Port.Lock;
  Logger.Debug(Logger.Separator);
  try
    if Length(TxData) = 0 then
      raise Exception.Create(SEmptyData);

    FCommand.Sequence := TxCount;
    FCommand.Code := Ord(TxData[1]);
    FCommand.Data := Copy(TxData, 2, Length(TxData));
    FTxData := TExellioFrame.EncodeCommand(FCommand);

    S := Format('0x%.2x, %s', [FCommand.Code, GetCommandName(FCommand.Code)]);
    Logger.Debug(S);
    Logger.Debug('-> ' + TxData);

    for i := 1 to MaxCommandCount do
    begin
      Port.Write(FTxData);
      // 01
      repeat
        B := Port.ReadByte;
        case B of
          $01: Break;
          $15:
          begin
            Break;
          end;
          $16:
          begin
            Sleep(100);
            Continue;
          end;
        else
          RaiseError(DATECS_E_NOHARDWARE, SNoHardware);
        end;
      until false;
      if B = $15 then Continue;

      B := Port.ReadByte;
      FRxData := Port.Read(B - $20 + 4);
      FRxData := #$01 + Chr(B) + FRxData;
      FAnswer := TExellioFrame.DecodeAnswer(FRxData);
      FAnswer.Data := DecodePrinterText(FAnswer.Data);
      DecodeStatus(FAnswer.Status, FStatus);
      Logger.Debug('<- ' + FAnswer.Data);

      if FCommand.Sequence = FAnswer.Sequence then
      begin
        if FCommand.Code <> FAnswer.Code then
          raise Exception.Create(SInvalidAnswerCode);
        RxData := FAnswer.Data;
        Break;
      end;

      if i = MaxCommandCount then
        RaiseError(DATECS_E_NOHARDWARE, SNoHardware);
    end;

    Inc(TxCount);
    if not(TxCount in [$20..$7F]) then
    begin
      TxCount := $20;
    end;
  finally
    Logger.Debug(Logger.Separator);
    Port.Unlock;
  end;
end;

function TDatecsPrinter.GetTaxLetter(iTax: Integer): Char;
const
  TaxLetters: array [1..7] of Char = ('À','Á','Â','Ã','Ä','Ì','Í');
begin
  CheckIntParam(iTax, 1, 7, 'Tax');
  Result := TaxLetters[iTax];
end;

procedure TDatecsPrinter.CheckCode(Code: Integer);
begin
  if Code <= 0 then
  begin
    Logger.Debug(Format('%s, %d', [SInvalidCodeValue, Code]));
    raiseError(EInvalidParams, SInvalidParams);
  end;
end;

function TDatecsPrinter.TestGroup(Value: Integer): Integer;
begin
  Result := TestIntParam(Value, 1, 99, 'Group');
end;

// IDatecs

procedure TDatecsPrinter.ClosePort;
begin
  try
    Port.Close;
    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TDatecsPrinter.Debugger(bDebug: WordBool);
begin
  Logger.Enabled := bDebug;
  if bDebug then
  begin
    Logger.Debug('  Äðàéâåð ïðèíòåðà Datecs FPU-550');
    Logger.Debug('  Âåðñèÿ ôàéëà: ' + GetFileVersionInfoStr + ', ØÒÐÈÕ-Ì, 2013');
    Logger.Debug(Logger.Separator);
  end;
end;

function TDatecsPrinter.Get_IsFiscalised: SYSINT;
begin
  Result := 0;
  if FStatus.Fiscalized then
    Result := 1;
end;

function TDatecsPrinter.Get_IsFiscalOpen: WordBool;
begin
  Result := FStatus.FiscalRecOpened;
end;

function TDatecsPrinter.Get_LastError: SYSINT;
begin
  Result := FLastError;
end;

function TDatecsPrinter.Get_LastErrorText: WideString;
begin
  Result := FLastErrorText;
end;

function TDatecsPrinter.Get_LastFPErrorText: WideString;
begin
  Result := '';
end;

function TDatecsPrinter.Get_LSS: WideString;
begin
  Result := '';
end;

function TDatecsPrinter.Get_StatusBytes(Index: Byte): WideString;
begin
  Result := FStatus.Data;
end;

function TDatecsPrinter.GetSettingValue(Param: Integer): Integer;
begin

end;

function TDatecsPrinter.GetErrorMessage(ErrCode: Integer): WideString;
begin
  Result := GetErrorText(ErrCode);
end;

procedure TDatecsPrinter.SetDebugFileName(const Name: WideString);
begin
  Logger.FileName := Name;
end;

procedure TDatecsPrinter.ShowError(bShow: WordBool);
begin
  FShowError := bShow;
end;

procedure TDatecsPrinter.SetReadTimeout(lMSec: Integer);
begin
  Port.SetCmdTimeout(lMSec);
end;


procedure TDatecsPrinter.SetTimeout(lMSec: Integer);
begin
  Port.Timeout := lMSec;
end;

function TDatecsPrinter.GetReceiptEjCopy(Mode: Integer): Integer;
begin

end;

procedure TDatecsPrinter.Set_StatusBytes(Index: Byte;
  const Value: WideString);
begin

end;


function TDatecsPrinter.EnableCRReport(Mode: WordBool): Integer;
begin

end;


function TDatecsPrinter.WaitWhilePrintEnd: Integer;
begin

end;

function TDatecsPrinter.Get_DbgText: WideString;
begin

end;


function TDatecsPrinter.PerDiscGrp(Grp: SYSINT; Dis: Double): Integer;
begin
  Result := TestGroup(Grp);
  if Result <> 0 then Exit;
  Result := Send(Format(#$3B'G%d,00,%s', [Grp, AmountToStr(-Dis)]));
end;


function TDatecsPrinter.PerDiscTax(Grp: SYSINT; Dis: Double): Integer;
begin
  Result := TestIntParam(Grp, 1, 5, 'Grp');
  if Result <> 0 then Exit;
  Result := Send(Format(#$3B'T%s,00,%s', [
    GetTaxLetter(Grp), AmountToStr(-Dis)]));
end;

function TDatecsPrinter.AbsDiscGrp(Grp: SYSINT; Dis: Double): Integer;
begin
  Result := TestGroup(Grp);
  if Result <> 0 then Exit;
  Result := Send(#$3B + Format('G%d,00;%s', [Grp, AmountToStr(-Dis)]));
end;

function TDatecsPrinter.AbsDiscTax(Grp: SYSINT; Dis: Double): Integer;
begin
  Result := TestIntParam(Grp, 1, 5, 'Grp');
  if Result <> 0 then Exit;
  Result := Send(Format(#$3B'T%s,00;%s', [
    GetTaxLetter(Grp), AmountToStr(-Dis)]));
end;

function TDatecsPrinter.AdvancePaper(iLines: SYSINT): Integer;
var
  Command: string;
begin
  Command := #$2C;
  if iLines in [1..99] then
    Command := #$2C + Pack([iLines, 1]);
  Result := Send(Command);
end;

function TDatecsPrinter.AdvancePaperEx(iLines, iType: SYSINT): Integer;
begin
  Result := Send(#$2C + Format('%d,%d', [iLines, iType]));
end;

function TDatecsPrinter.CancelReceipt: Integer;
begin
  Result := Send(#$39);
end;

function TDatecsPrinter.ChangeArticlePrice(
  const Pass: WideString;
  iCode: SYSINT;
  dPrice: Double): Integer;
var
  Command: string;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Command := #$6B + 'C' + Pack([iCode, AmountToStr(dPrice), GetPassword(Pass)]);
  Result := Send(Command);
  DecodeAnswer;
end;

function TDatecsPrinter.ClearDisplay: Integer;
begin
  Result := Send(#$21);
end;

function TDatecsPrinter.ClearOperator(iOperNum: SYSINT;
  const Pass: WideString): Integer;
begin
  Result := TestOperator(iOperNum);
  if Result <> 0  then Exit;
  Result := TestPassword(Pass);
  if Result <> 0  then Exit;
  Result := Send(#$68 + Pack([iOperNum, GetPassword(Pass)]));
end;

function TDatecsPrinter.ClearOperatorPassword(iOperNum: SYSINT;
  const AdmPass: WideString): Integer;
begin
  Result := TestOperator(iOperNum);
  if Result <> 0 then Exit;
  Result := TestPassword(AdmPass);
  if Result <> 0 then Exit;
  Result := Send(#$77 + Pack([iOperNum, GetPassword(AdmPass)]));
end;

function TDatecsPrinter.CloseFiscalReceipt: Integer;
begin
  Result := Send(#$38);
  DecodeParams(3);
end;

function TDatecsPrinter.CloseNonfiscalReceipt: Integer;
begin
  Result := Send(#$27);
  DecodeParams(3);
end;

function TDatecsPrinter.CutReceipt: Integer;
begin
  Result := Send(#$2D);
end;

function TDatecsPrinter.DelArticle(const Pass: WideString;
  iCode: SYSINT): Integer;
var
  Command: string;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  if iCode < 0 then
  begin
    Result := InvalidParams;
    Exit;
  end;

  if iCode = 0 then
  begin
    Command := Format(#$6B'DA,%s', [GetPassword(Pass)])
  end else
  begin
    Command := Format(#$6B'D%.5d,%s', [iCode, GetPassword(Pass)]);
  end;
  Result := Send(Command);
  DecodeAnswer;
end;

function TDatecsPrinter.DelAllArticles(const Pass: WideString): Integer;
var
  Command: string;
begin
  Command := Format(#$6B'DA,%s', [Pass]);
  Result := Send(Command);
end;

function TDatecsPrinter.DisplayDateTime: Integer;
begin
  Result := Send(#$3F);
end;

function TDatecsPrinter.DisplayFreeText(const Text: WideString): Integer;
begin
  Result := DisplayTextUL(Copy(Text, 1, 20));
  if Result <>0 then Exit;
  Result := DisplayTextLL(Copy(Text, 21, 20));
end;

function TDatecsPrinter.DisplayTextLL(const Text: WideString): Integer;
begin
  Result := Send(#$23 + EncodeDisplayText(Copy(Text, 1, 20)));
end;

function TDatecsPrinter.DisplayTextUL(const Text: WideString): Integer;
begin
  Result := Send(#$2F + EncodeDisplayText(Copy(Text, 1, 20)));
end;

function TDatecsPrinter.Fiscalise(const Pass, SerNum, TaxNum: WideString;
  iTaxNumType: SYSINT): Integer;
var
  Code: Integer;
  Command: string;
begin
  Command := #$48 + Format('%s,%s,%s,%d', [Pass, SerNum, TaxNum, iTaxNumType]);
  Result := Send(Command);
  FS[1] := FAnswer.Data;
  Code := StrToIntDef(GetParam(1), 0);
  if Code in [1..10] then
  begin
    Result := SetLastError(12 + Code);
  end;
end;

function TDatecsPrinter.GetArticle(iCode: SYSINT): Integer;
begin
  try
    CheckCode(iCode);
    Result := Send(#$6B'R' + IntToStr(iCode));
    DecodeAnswer;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsPrinter.GetArticlesInfo: Integer;
begin
  Result := Send(#$6B'I');
  DecodeAnswer;
end;

function TDatecsPrinter.GetCorectSums: Integer;
begin
  Result := Send(#$43);
  DecodeParams(6);
end;

function TDatecsPrinter.GetCurrentSums(iParam: SYSINT): Integer;
begin
  Result := TestIntParam(iParam, 0, 3, 'Param');
  if Result <> 0 then Exit;
  Result := Send(#$41 + IntToStr(iParam));
  DecodeParams(6);
end;

function TDatecsPrinter.GetCurrentTaxRates: Integer;
begin
  Result := Send(#$61);
  DecodeParams(4);
end;

function TDatecsPrinter.GetDateTime: Integer;
begin
  Result := Send(#$3E);
  FS[1] := FAnswer.Data;
end;

function TDatecsPrinter.GetDayInfo: Integer;
begin
  Result := Send(#$6E);
  DecodeAnswer;
  FS[1] := GetParam(1);
  FS[2] := GetParam(2);
  FS[3] := GetParam(3);
  FS[4] := GetParam(4);
  FS[5] := GetParam(9);
  FS[6] := GetParam(10);
  FS[7] := GetParam(11);
  FS[8] := GetParam(5);
  FS[9] := GetParam(6);
  FS[10] := GetParam(7);
end;

function TDatecsPrinter.GetDiagnosticInfo(bCalcCRC: WordBool): Integer;
begin
  Result := Send(#$5A + BoolToStr(bCalcCRC));
  DecodeParams(6);
end;

function TDatecsPrinter.GetFirstArticle: Integer;
begin
  Result := Send(#$6B'F');
  DecodeAnswer;
end;

function TDatecsPrinter.GetFirstFreeArticle: Integer;
begin
  Result := Send(#$6B'X');
  DecodeAnswer;
end;

function TDatecsPrinter.GetFiscalClosureStatus(bCurrent: WordBool): Integer;
var
  Command: string;
begin
  Command := #$4C;
  if bCurrent then
    Command := #$4C'T';
  Result := Send(Command);
  DecodeParams(4);
end;

function TDatecsPrinter.GetFreeClosures: Integer;
begin
  Result := Send(#$44);
  DecodeParams(2);
end;

function TDatecsPrinter.GetLastArticle: Integer;
begin
  Result := Send(#$6B'L');
  DecodeAnswer;
end;

function TDatecsPrinter.GetLastClosureDate: Integer;
begin
  Result := Send(#$56);
  DecodeParams(1);
end;

function TDatecsPrinter.GetLastFreeArticle: Integer;
begin
  Result := Send(#$6B'x');
  DecodeAnswer;
end;

function TDatecsPrinter.GetLastReceiptNum: Integer;
begin
  Result := Send(#$71);
  DecodeParams(1);
end;

function TDatecsPrinter.GetNextArticle: Integer;
begin
  Result := Send(#$6B'N');
  DecodeAnswer;
end;

function TDatecsPrinter.GetOperatorInfo(iOperNum: SYSINT): Integer;
begin
  Result := TestOperator(iOperNum);
  if Result <> 0 then Exit;
  Result := Send(#$70 + IntToStr(iOperNum));
  DecodeParams(7);
end;

function TDatecsPrinter.GetReceiptInfo: Integer;
begin
  Result := Send(#$67);
  DecodeParams(7);
end;

function TDatecsPrinter.GetSmenLen: Integer;
begin
  Result := Send(#$2E);
  Decodeparams(2);
end;

function TDatecsPrinter.GetStatus(bWait: WordBool): Integer;
const
  StatusCode: array [Boolean] of Char = ('S', 'W');
begin
  Result := Send(#$4A + StatusCode[bWait]);
end;

function TDatecsPrinter.GetTaxNumber: Integer;
begin
  Result := Send(#$63);
  DecodeParams(2);
end;

function TDatecsPrinter.InOut(dSum: Double): Integer;
begin
  Result := Send(#$46 + AmountToStr(dSum));
  FS[1] := GetParam(2);
  FS[2] := GetParam(3);
  FS[3] := GetParam(4);
end;

function TDatecsPrinter.LastFiscalClosure(iParam: SYSINT): Integer;
begin
  Result := TestIntParam(iParam, 0, 1, 'iParam');
  if Result <> 0 then Exit;
  Result := Send(#$40 + IntToStr(iParam));
  DecodeParams(7);
end;

function TDatecsPrinter.LogoLoad(const Pass: WideString; iLine: SYSINT;
  const Data: WideString): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := TestIntParam(iLine, 1, 96, 'Line');
  if Result <> 0 then Exit;
  Result := Send(#$73 + Pack([GetPassword(Pass), iLine-1, Data]));
end;

function TDatecsPrinter.MakeReceiptCopy(iCount: SYSINT): Integer;
begin
  if iCount <> 1 then iCount := 2;
  Result := Send(#$6D + IntToStr(iCount));
end;

function TDatecsPrinter.OpenDrawer: Integer;
begin
  Result := Send(#$6A'150');
end;

function TDatecsPrinter.OpenDrawerEx(iMsc: SYSINT): Integer;
begin
  if not(iMsc in [6..150]) then
    iMsc := 150;
  Result := Send(#$6A + IntToStr(iMsc));
end;

function TDatecsPrinter.OpenFiscalReceipt(iOperator: SYSINT;
  const Password: WideString; iPlaceNumber: SYSINT): Integer;
begin
  Result := TestOperator(iOperator);
  if Result <> 0 then Exit;
  Result := TestPassword(Password);
  if Result <> 0 then Exit;
  Result := TestPlace(iPlaceNumber);
  if Result <> 0 then Exit;
  Result := Send(#$30 + Format('%.5d,%s,%.5d,I', [
    iOperator, GetPassword(Password), iPlaceNumber]));
  DecodeParams(3);
end;

function TDatecsPrinter.OpenNonfiscalReceipt: Integer;
begin
  Result := Send(#$26);
  DecodeParams(4);
end;

function TDatecsPrinter.OpenPort(const PortName: WideString;
  iSpeed: SYSINT): Integer;
begin
  try
    Port.PortName := PortName;
    Port.BaudRate := iSpeed;
    Port.Open;
    Port.Timeout := 100;
    Port.SetCmdTimeout(1000);
    Port.SetDTRState(True);
    Port.SetRTSState(False);
    Result := GetStatus(True);

    Result := ClearResult;
  except
    on E: Exception do
      Result := ClearResult;
  end;
end;

function TDatecsPrinter.OpenReturnReceipt(iOperator: SYSINT;
  const Pass: WideString; iPlaceNum: SYSINT): Integer;
begin
  Result := TestOperator(iOperator);
  if Result <> 0 then Exit;

  Result := TestPassword(Pass);
  if Result <> 0 then Exit;

  Result := TestPlace(iPlaceNum);
  if Result <> 0 then Exit;

  Result := Send(#$55 + Format('%.5d,%s,%.5d,I', [iOperator, Pass, iPlaceNum]));
  DecodeParams(3);
end;

function TDatecsPrinter.PrintBarCode(iType: SYSINT;
  const Text: WideString): Integer;
var
  Barcode: string;
begin
  Result := TestIntParam(iType, 1, 5, 'Type');
  if Result <> 0 then Exit;

  Barcode := Text;
  case iType of
    1: Barcode := Copy(Barcode, 1, 7);
    2: Barcode := Copy(Barcode, 1, 12);
  end;
  Result := Send(#$58 + Pack([iType, Barcode]));
end;

function TDatecsPrinter.PrintDiagnosticInfo: Integer;
begin
  Result := Send(#$47);
end;

function TDatecsPrinter.PrintFiscalText(const Text: WideString): Integer;
var
  Data: WideString;
  Line: WideString;
begin
  Result := ClearResult;
  if Length(Text) = 0 then Exit;

  Data := Text;
  repeat
    Line := Copy(Data, 1, MaxLineLen);
    Line := EncodePrinterText(Line);
    Result := Send(#$36 + Line);
    if Result <> 0 then Break;
    Data := Copy(Data, MaxLineLen + 1, Length(Data));
  until Data = '';
end;

function TDatecsPrinter.PrintLine(iType: SYSINT): Integer;
begin
  Result := TestIntParam(iType, 1, 3, 'Type');
  if Result <> 0 then Exit;
  Result := Send(#$5D + IntToStr(iType));
end;

function TDatecsPrinter.PrintNonfiscalText(const Text: WideString): Integer;
var
  Data: WideString;
  Line: WideString;
begin
  Result := ClearResult;
  if Length(Text) = 0 then Exit;

  Data := Text;
  repeat
    Line := Copy(Data, 1, MaxLineLen);
    Line := EncodePrinterText(Line);
    Result := Send(#$2A + Line);
    if Result <> 0 then Break;
    Data := Copy(Data, MaxLineLen + 1, Length(Data));
  until Data = '';
end;

function TDatecsPrinter.PrintNullCheck: Integer;
const
  NullReceipt: WideString = 'ÍÓËÜÎÂÈÉ ×ÅÊ';
begin
  Result := OpenFiscalReceipt(1, '0000', 1);
  if Result <> 0 then Exit;
  Result := PrintFiscalText(NullReceipt);
  if Result <> 0 then Exit;
  Result := SubTotal(0, 0);
  if Result <> 0 then Exit;
  Result := GetFiscalClosureStatus(True);
  if Result <> 0 then Exit;
  Result := Total('', 1, 0);
  if Result <> 0 then Exit;
  Result := CloseFiscalReceipt;
end;

function TDatecsPrinter.PrintRepByArt(const Pass: WideString;
  iType: SYSINT): Integer;
const
  RepType = 'SPG';
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := TestIntParam(iType, 1, 3, 'Type');
  if Result <> 0 then Exit;
  Result := Send(#$6F + Pack([GetPassword(Pass), RepType[iType]]));
end;

function TDatecsPrinter.PrintRepByDate(const Pass, BegDate,
  EndDate: WideString): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := TestDate(BegDate);
  if Result <> 0 then Exit;
  Result := TestDate(EndDate);
  if Result <> 0 then Exit;
  Result := Send(#$4F + Pack([
    GetPassword(Pass), GetDate(BegDate), GetDate(EndDate)]));
end;

function TDatecsPrinter.PrintRepByDateFull(const Pass, BegDate,
  EndDate: WideString): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := TestDate(BegDate);
  if Result <> 0 then Exit;
  Result := TestDate(EndDate);
  if Result <> 0 then Exit;
  Result := Send(#$5E + Pack([
    GetPassword(Pass), GetDate(BegDate), GetDate(EndDate)]));
end;

function TDatecsPrinter.PrintRepByNum(const Pass: WideString; iBegNum,
  iEndNum: SYSINT): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := Send(#$5F + Pack([GetPassword(Pass), iBegNum, iEndNum]));
end;

function TDatecsPrinter.PrintRepByNumFull(const Pass: WideString; iBegNum,
  iEndNum: SYSINT): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := Send(#$49  + Pack([GetPassword(Pass), iBegNum, iEndNum]));
end;

function TDatecsPrinter.PrintRepByOperator(const Pass: WideString): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := Send(#$69 + GetPassword(Pass));
end;

function TDatecsPrinter.PrintTaxReport(const Pass, BegDate,
  EndDate: WideString): Integer;
begin
  Result := TestPassword(Pass);
  if Result <> 0 then Exit;
  Result := TestDate(BegDate);
  if Result <> 0 then Exit;
  Result := TestDate(EndDate);
  if Result <> 0 then Exit;

  Result := Send(#$32 + Pack([GetPassword(Pass), GetDate(BegDate), GetDate(EndDate)]));
end;

function TDatecsPrinter.RegistrAndDisplayItem(
  iArtNum: SYSINT; dQnty, dPercentDisc, dSumDisc: Double): Integer;
var
  Command: string;
begin
  if iArtNum <= 0 then
  begin
    Result := InvalidParams;
    Exit;
  end;
  Command := #$34 + Format('%d*%s,%s;%s',[iArtNum, QuantityToStr(dQnty),
    AmountToStr(dPercentDisc), AmountToStr(dSumDisc)]);
  Result := Send(Command);
end;

function TDatecsPrinter.RegistrAndDisplayItemEx(iArtNum: SYSINT; dQnty,
  dPrice, dPercentDisc, dSumDisc: Double): Integer;
var
  Command: string;
begin
  if iArtNum <= 0 then
  begin
    Result := InvalidParams;
    Exit;
  end;
  Command := #$34 + Format('%d*%s#%s,%s;%s',[iArtNum, QuantityToStr(dQnty),
    AmountToStr(dPrice), AmountToStr(dPercentDisc),
    AmountToStr(dSumDisc)]);
  Result := Send(Command);
end;

function TDatecsPrinter.RegistrItem(iArtNum: SYSINT; dQnty, dPercentDisc,
  dSumDisc: Double): Integer;
var
  Command: string;
begin
  if iArtNum <= 0 then
  begin
    Result := InvalidParams;
    Exit;
  end;
  if (dPercentDisc < 0.01)and(dSumDisc < 0.01) then
    Command := #$3A + Format('%d*%s',[iArtNum, QuantityToStr(dQnty)])
  else
    Command := #$3A + Format('%d*%s,%s;%s',[iArtNum, QuantityToStr(dQnty),
    AmountToStr(dPercentDisc), AmountToStr(dSumDisc)]);
  Result := Send(Command);
end;

function TDatecsPrinter.RegistrItemEx(iArtNum: SYSINT; dQnty, dPrice,
  dPercentDisc, dSumDisc: Double): Integer;
var
  Command: string;
begin
  if iArtNum <= 0 then
  begin
    Result := InvalidParams;
    Exit;
  end;
  if (dPercentDisc < 0.01)and(dSumDisc < 0.01) then
    Command := Format(#$3A'%d*%s#%s', [
      iArtNum, QuantityToStr(dQnty), AmountToStr(dPrice)])
  else
    Command := Format(#$3A'%d*%s#%s,%s;%s', [iArtNum, QuantityToStr(dQnty),
      AmountToStr(dPrice), AmountToStr(dPercentDisc), AmountToStr(dSumDisc)]);
  Result := Send(Command);
end;

function TDatecsPrinter.SaveSettings: Integer;
begin
  Result := Send(CmdSaveSettings);
end;

function TDatecsPrinter.SetAdminPassword(const OldPass,
  NewPass: WideString): Integer;
begin
  Result := TestPassword(OldPass);
  if Result <> 0 then Exit;
  Result := TestPassword(NewPass);
  if Result <> 0 then Exit;
  Result := Send(#$76 + Pack([GetPassword(OldPass), GetPassword(OldPass)]));
end;

function TDatecsPrinter.SetArticle(iCode, iTax, iGrp: SYSINT; dPrice: Double;
  const Pass, Name: WideString): Integer;
var
  Command: string;
begin
  try
    CheckCode(iCode);
    CheckIntParam(iTax, 1, 7, 'iTax');
    CheckIntParam(iGrp, 1, 99, 'iGrp');
    Command := #$6B + 'P' + GetTaxLetter(iTax) +
      Pack([iGrp, iCode, AmountToStr(dPrice), GetPassword(Pass),
      EncodePrinterText(Name)]);

    Result := Send(Command);
    DecodeAnswer;
  except
    on E: Exception do
      REsult := HandleException(E);
  end;
end;

function TDatecsPrinter.SetDateTime(const Date, Time: WideString): Integer;
var
  SDate: string;
  Year, Month, Day: Word;
begin
  Result := ClearResult;
  try
    Day := StrToInt(Copy(Date,1,2));
    Month := StrToInt(Copy(Date,3,2));
    Year := StrToInt(Copy(Date,5,2));
    SDate := Format('%.2d-%.2d-%.2d', [Day, Month, Year]);
  except
    on E: Exception do
    begin
      Result := InvalidParams;
    end;
  end;

  if Result = 0 then
    Result := Send(CmdSetDateTime + SDate + ' ' + Time);
end;

function TDatecsPrinter.SetFiscalNumber(const FN: WideString): Integer;
begin
  Result := Send(#$5C + Copy(FN, 1, 10));
  FS[1] := GetParam(1);
  if FS[1] <> 'P' then
    Result := SetLastError(23);
end;

function TDatecsPrinter.GetBarcodeHeight: Integer;
begin
  Result := Send(CmdSetHeaderFooter + 'IB');
end;

function TDatecsPrinter.GetCutCheckEnabled: Integer;
begin
  Result := Send(CmdSetHeaderFooter + 'IC');
end;

function TDatecsPrinter.GetPrintDensity: Integer;
begin
  Result := Send(CmdSetHeaderFooter + 'ID');
end;

function TDatecsPrinter.GetHeader(iLine: SYSINT): Integer;
var
  Answer: string;
  Command: string;
begin
  try
    CheckIntParam(iLine, 1, 8, 'iLine');
    Command := CmdSetHeaderFooter + 'I' + IntToStr(iLine-1);
    Result := Send(Command, Answer);
    FS[1] := Answer;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsPrinter.GetLogoEnabled: Integer;
begin
  Result := Send(CmdSetHeaderFooter + 'IL');
end;

function TDatecsPrinter.GetDrawerEnabled: Integer;
begin
  Result := Send(CmdSetHeaderFooter + 'IX');
end;

function TDatecsPrinter.GetSmallFontEnabled: Integer;
begin
  Result := Send(CmdSetHeaderFooter + 'IR');
end;

function TDatecsPrinter.SetHeaderFooter(iLine: SYSINT;
  const Text: WideString): Integer;
var
  Answer: string;
  Command: string;
begin
  try
    CheckIntParam(iLine, 1, 8, 'iLine');
    Command := CmdSetHeaderFooter + IntToStr(iLine-1) + EncodePrinterText(Text);
    Result := Send(Command, Answer);
    FS[1] := Answer;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsPrinter.SetBarcodeHeight(Height: SYSINT): Integer;
var
  Command: string;
begin
  try
    if not(Height in [24..240]) then
      Height := 240;
    Command := CmdSetHeaderFooter + 'B' + IntToStr(Height);
    Result := Send(Command);
    FS[1] := FAnswer.Data;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsPrinter.EnableSmallFont(bEnabled: WordBool): Integer;
begin
  Result := Send(#$2B + 'J' + BoolToStr(bEnabled));
  FS[1] := FAnswer.Data;
end;

function TDatecsPrinter.EnableCutCheck(bEnabled: WordBool): Integer;
var
  Command: string;
begin
  try
    Command := CmdSetHeaderFooter + 'C' + BoolToStr(bEnabled);
    Result := Send(Command);
    FS[1] := FAnswer.Data;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsPrinter.SetPrintDensity(Density: SYSINT): Integer;
var
  Command: string;
begin
  if Density <= 0 then
  begin
    Result := InvalidParams;
    Exit;
  end;

  if Density > 5 then Density := 3;
  Command := CmdSetHeaderFooter + 'D' + IntToStr(Density);
  Result := Send(Command);
  FS[1] := FAnswer.Data;
end;

function TDatecsPrinter.EnableLogo(bEnabled: WordBool): Integer;
var
  Command: string;
begin
  Command := CmdSetHeaderFooter + 'L' + BoolToStr(bEnabled);
  Result := Send(Command);
  FS[1] := FAnswer.Data;
end;

function TDatecsPrinter.EnableAutoOpenDrawer(bEnabled: WordBool): Integer;
begin
  Result := Send(#$2B + 'X' + BoolToStr(not bEnabled));
  FS[1] := FAnswer.Data;
end;

function TDatecsPrinter.SetMulDecCurRF(
  const Pass: WideString; iDec: SYSINT;
  const TaxEnable: WideString; dTaxA, dTaxB, dTaxC,
  dTaxD: Double): Integer;
var
  Command: string;
begin
  Command := #$53 + Pack([
    Pass, IntToStr(iDec), TaxEnable,
    AmountToStr(dTaxA), AmountToStr(dTaxB),
    AmountToStr(dTaxC), AmountToStr(dTaxD)]);
  Result := Send(Command);
  FS[1] := GetParam(1);
  FS[2] := GetParam(2);
  FS[3] := GetParam(3);
  FS[4] := GetParam(3);
  FS[5] := GetParam(3);
  FS[6] := GetParam(3);
end;

function TDatecsPrinter.SetOperatorName(iOperatorNum: SYSINT; const Password,
  Name: WideString): Integer;
begin
  Result := TestOperator(iOperatorNum);
  if Result <> 0 then Exit;
  Result := Send(#$66 + Pack([iOperatorNum, Password, EncodePrinterText(Name)]));
end;

function TDatecsPrinter.SetOperatorPassword(iOperNum: SYSINT; const OldPass,
  NewPass: WideString): Integer;
begin
  Result := TestOperator(iOperNum);
  if Result <> 0 then Exit;
  Result := Send(#$65 + Pack([iOperNum, OldPass, NewPass]));
end;

function TDatecsPrinter.SetSerialNum(const SerialNumber: WideString): Integer;
begin
  Result := Send(#$5B'2,' + SerialNumber);
  FS[1] := GetParam(1);
  FS[2] := GetParam(2);
  if FS[1] <> 'P' then
    Result := SetLastError(22);
end;

function TDatecsPrinter.SetTaxName(Tax: SYSINT;
  const Name: WideString): Integer;
const
  TaxLetter = 'IJKL';
begin
  Result := TestIntParam(Tax, 1, 4, 'Tax');
  if Result <> 0 then Exit;
  Result := Send(#$57 + Pack([TaxLetter[Tax], EncodePrinterText(Copy(Name, 1, 24))]));
end;

function TDatecsPrinter.SetTaxNumber(const TaxNumber: WideString;
  iType: SYSINT): Integer;
begin
  Result := TestIntParam(iType, 0, 1, 'iType');
  if Result <> 0 then Exit;

  if Length(TaxNumber) < 12 then
  begin
    Result := InvalidParams;
    Exit;
  end;
  Result := Send(#$62 + Pack([Copy(TaxNumber, 1, 12), IntToStr(iType)]));
  FS[1] := GetParam(1);
  if FS[1] <> 'P' then
    Result := SetLastError(24);
end;

function TDatecsPrinter.SetTaxType(iType: SYSINT): Integer;
begin
  Result := TestIntParam(iType, 0, 1, 'iType');
  if Result <> 0 then Exit;
  Result := Send(#$54 + IntToStr(iType));
end;

function TDatecsPrinter.Sound: Integer;
begin
  Result := Send(#$50);
end;

function TDatecsPrinter.SoundEx(Hz, Ms: SYSINT): Integer;
begin
  Result := Send(#$50 + Pack([Hz, Ms]));
end;

function TDatecsPrinter.SubTotal(dPercentDisc, dSumDisc: Double): Integer;
var
  Command: string;
begin
  if dPercentDisc <> 0 then
    Command := #$33'11,' + AmountToStr(dPercentDisc)
  else
    Command := #$33'11;' + AmountToStr(dSumDisc);
  Result := Send(Command);
  DecodeParams(6);
end;

const
  PayModes = 'PNCDIJKL';

function TDatecsPrinter.Total(const Text: WideString; iPayMode: SYSINT;
  dSum: Double): Integer;
var
  Data: string;
begin
  Result := TestIntParam(iPayMode, 1, 8, 'PayMode');
  if Result <> 0 then Exit;
  Result := Send(#$35 + EncodePrinterText(Text) + #$09 +
    PayModes[iPayMode] + AmountToStr(dSum));
  Data := FAnswer.Data;
  if Length(Data) > 0 then
  begin
    FS[1] := Copy(Data, 1, 1);
    FS[2] := Copy(Data, 2, 12);
    if Result = 0 then
    begin
      case Data[1] of
        'F': Result := SetLastError(29);
        'E': Result := SetLastError(30);
        'I': Result := SetLastError(33);
      end;
    end;
  end;
end;

function TDatecsPrinter.TotalEx(const Text: WideString; iPayMode: SYSINT;
  dSum: Double): Integer;
var
  Data: string;
begin
  Result := TestIntParam(iPayMode, 1, 8, 'PayMode');
  if Result <> 0 then Exit;
  Result := Send(#$37 + EncodePrinterText(Text) + #$09 +
    PayModes[iPayMode] + AmountToStr(dSum));
  Data := FAnswer.Data;
  if Length(Data) > 0 then
  begin
    FS[1] := Copy(Data, 1, 1);
    FS[2] := Copy(Data, 2, 12);
    if Result = 0 then
    begin
      case Data[1] of
        'F': Result := SetLastError(29);
        'E': Result := SetLastError(30);
        'I': Result := SetLastError(33);
      end;
    end;
  end;
end;

function TDatecsPrinter.XReport(const Pass: WideString): Integer;
begin
  Result := Send(#$45 + Pass + ',2');
  DecodeParams(7);
end;

function TDatecsPrinter.ZReport(const Pass: WideString): Integer;
begin
  Result := Send(#$45 + Pass + ',0');
  DecodeParams(7);
end;

function TDatecsPrinter.Get_s1: WideString;
begin
  Result := FS[1];
end;

function TDatecsPrinter.Get_s10: WideString;
begin
  Result := FS[10];
end;

function TDatecsPrinter.Get_s11: WideString;
begin
  Result := FS[11];
end;

function TDatecsPrinter.Get_s2: WideString;
begin
  Result := FS[2];
end;

function TDatecsPrinter.Get_s3: WideString;
begin
  Result := FS[3];
end;

function TDatecsPrinter.Get_s4: WideString;
begin
  Result := FS[4];
end;

function TDatecsPrinter.Get_s5: WideString;
begin
  Result := FS[5];
end;

function TDatecsPrinter.Get_s6: WideString;
begin
  Result := FS[6];
end;

function TDatecsPrinter.Get_s7: WideString;
begin
  Result := FS[7];
end;

function TDatecsPrinter.Get_s8: WideString;
begin
  Result := FS[8];
end;

function TDatecsPrinter.Get_s9: WideString;
begin
  Result := FS[9];
end;

function TDatecsPrinter.SendData(const Data: WideString): Integer;
begin
  Result := Send(Data);
end;

end.
