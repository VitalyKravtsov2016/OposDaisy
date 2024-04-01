unit DatecsFP;

interface

uses
  // VCL
  Windows, Classes, SysUtils, DateUtils, SyncObjs, ExtCtrls,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  untComm, ExellioTypes, ExellioFrame, LogFile, StringUtils,
  VariantUtils, ThreadTimer;

type
  { TDatecsFP }

  TDatecsFP = class
  private
    FData: string;
    FComm: TComm;
    FIsBusy: Boolean;
    FTimeout: Integer;
    FTickCount: Integer;
    FCommand: TExellioCommand;
    FOnCommand: TNotifyEvent;
    FPrinterEncoding: Integer;
    FDisplayEncoding: Integer;
    FPrinterCodePage: Integer;
    FDisplayCodePage: Integer;
    FStatusData: string;
    FStatus: TDatecsStatus;
    FAnswers: TTntStrings;
    FCommands: TTntStrings;
    FCS: TCriticalsection;
    FSynTimer: TThreadTimer;
    FSynCount: Integer;
    FMaxSynCount: Integer;

    procedure ProcessData;
    procedure SetTimeout(const Value: Integer);
    procedure CommRxchar(Sender: TObject; Count: Integer);
    function ParseCommand: Boolean;
    procedure SetStatusData(const Value: string);
    procedure SynTimerEvent(Sender: TObject);
    procedure DoSendAnswer;
    function GetSynInterval: Integer;
    procedure SetSynInterval(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Reset;
    procedure Lock;
    procedure Unlock;
    procedure ClosePort;
    procedure SendAnswer(Data: string);
    procedure WriteData(const Data: string);
    procedure DeviceCommand(Sender: TObject);
    procedure OpenPort(PortNumber, BaudRate: Integer);

    function GetCommand: WideString;
    function GetPrinterCodePage: Integer;
    function GetDisplayCodePage: Integer;
    function DecodePrinterText(const Text: AnsiString): WideString;
    function DecodeDisplayText(const Text: AnsiString): WideString;
    function EncodeDisplayText(const Text: WideString): AnsiString;
    function EncodePrinterText(const Text: WideString): AnsiString;

    property SynCount: Integer read FSynCount;
    property Answers: TTntStrings read FAnswers;
    property Commands: TTntStrings read FCommands;
    property Status: TDatecsStatus read FStatus;
    property Command: TExellioCommand read FCommand;
    property IsBusy: Boolean read FIsBusy write FIsBusy;
    property Timeout: Integer read FTimeout write SetTimeout;
    property MaxSynCount: Integer read FMaxSynCount write FMaxSynCount;
    property StatusData: string read FStatusData write SetStatusData;
    property OnCommand: TNotifyEvent read FOnCommand write FOnCommand;
    property SynInterval: Integer read GetSynInterval write SetSynInterval;
    property PrinterCodePage: Integer read FPrinterCodePage write FPrinterCodePage;
    property DisplayCodePage: Integer read FDisplayCodePage write FDisplayCodePage;
    property PrinterEncoding: Integer read FPrinterEncoding write FPrinterEncoding;
    property DisplayEncoding: Integer read FDisplayEncoding write FDisplayEncoding;
  end;

const
  NAK = #$15;
  SYN = #$16;

implementation

{ TDatecsFP }

constructor TDatecsFP.Create;
begin
  inherited Create;
  FTimeout := 1000;
  FComm := TComm.Create(nil);
  FComm.OnRxChar := CommRxChar;
  FCS := TCriticalsection.Create;
  FAnswers := TTntStringList.Create;
  FCommands := TTntStringList.Create;
  OnCommand := DeviceCommand;
  FPrinterEncoding := EncodingAuto;
  FDisplayEncoding := EncodingAuto;
  FSynTimer := TThreadTimer.Create;
  FSynTimer.Interval := 60; // 60 ms
  FSynTimer.Enabled := False;
  FSynTimer.OnTimer := SynTimerEvent;
  FMaxSynCount := 10;

  StatusData := #$80#$80#$92#$89#$84#$FA;
end;

destructor TDatecsFP.Destroy;
begin
  FComm.Free;
  FCS.Free;
  Answers.Free;
  Commands.Free;
  FSynTimer.Free;
  inherited Destroy;
end;

procedure TDatecsFP.SynTimerEvent(Sender: TObject);
begin
  WriteData(SYN);
  Inc(FSynCount);
  if FSynCount = MaxSynCount then
  begin
    FSynTimer.Enabled := False;
    DoSendAnswer;
  end;
end;

procedure TDatecsFP.DoSendAnswer;
var
  Answer: WideString;
begin
  if Answers.Count > 0 then
  begin
    Answer := Answers[0];
    Answers.Delete(0);
  end else
  begin
    Answer := Chr(FCommand.Code);
  end;
  SendAnswer(Answer);
end;

procedure TDatecsFP.DeviceCommand(Sender: TObject);
var
  Command: string;
begin
  Lock;
  try
    Command := Chr(FCommand.Code) + FCommand.Data;
    Commands.Add(Command);
    if IsBusy then
    begin
      WriteData(SYN);
      Inc(FSynCount);
      FSynTimer.Enabled := True;
    end else
    begin
      DoSendAnswer;
    end;
  finally
    Unlock;
  end;
end;

function TDatecsFP.GetCommand: WideString;
begin
  Lock;
  try
    Result := '';
    if Commands.Count > 0 then
      Result := Commands[0];
    Commands.Clear;
  finally
    Unlock;
  end;
end;

procedure TDatecsFP.Reset;
begin
  FData := '';
  FTickCount := 0;
  FSynCount := 0;
  Answers.Clear;
  Commands.Clear;
end;

procedure TDatecsFP.Lock;
begin
  FCS.Enter;
end;

procedure TDatecsFP.Unlock;
begin
  FCS.Leave;
end;

procedure TDatecsFP.ClosePort;
begin
  FComm.Close;
end;

procedure TDatecsFP.OpenPort(PortNumber, BaudRate: Integer);
begin
  FComm.PortNumber := PortNumber;
  FComm.BaudRate := BaudRate;
  FComm.Open;
end;

procedure TDatecsFP.WriteData(const Data: string);
var
  S: string;
begin
  LogDebugData('-> ', Data);
  S := Data;
  FComm.Write(S[1], Length(S));
end;

procedure TDatecsFP.SetTimeout(const Value: Integer);
begin
  FTimeout := Value;
end;

procedure TDatecsFP.CommRxchar(Sender: TObject; Count: Integer);
var
  Data: string;
begin
  try
    if Count > 0 then
    begin
      SetLength(Data, Count);
      FComm.Read(Data[1], Count);

      FData := FData + Data;
      ProcessData;
    end;
  except
    on E: Exception do
    begin
      Logger.Error(E.Message);
    end;
  end;
end;

procedure TDatecsFP.ProcessData;
begin
  while ParseCommand do
  begin
    if Assigned(FOnCommand) then
      FOnCommand(Self);
  end;
end;

// <01><LEN><SEQ><CMD><DATA><05><BCC><03>

function TDatecsFP.ParseCommand: Boolean;
var
  P: Integer;
  Len: Integer;
  Frame: string;
begin
  // Start of frame
  P := Pos(#01, FData);
  Result := P <> 0;
  if not Result then Exit;

  FData := Copy(FData, P, Length(FData));
  Result := Length(FData) >= 2;
  if not Result then Exit;

  Len := Ord(FData[2]) - $20 + 6;
  Result := Length(FData) >= Len;
  if not Result then Exit;

  Frame := Copy(FData, 1, Len);
  Result := TExellioFrame.DecodeCommand2(Frame, FCommand);
  if Result then
  begin
    LogDebugData('<- ', Frame);
    Logger.Debug('<- ' + Command.Data);

    FData := Copy(FData, Len + 1, Length(FData));
  end else
  begin
    WriteData(NAK);
  end;
end;

procedure TDatecsFP.SendAnswer(Data: string);
var
  Answer: TExellioAnswer;
begin
  Answer.Code := Ord(Data[1]);
  Data := Copy(Data, 2, Length(Data));
  Answer.Sequence := FCommand.Sequence;
  Answer.Status := StatusData;
  Answer.Data := Data;
  Logger.Debug('-> ' + Data);
  WriteData(TExellioFrame.EncodeAnswer(Answer));
end;

function TDatecsFP.GetPrinterCodePage: Integer;
begin
  Result := 1251;
  if FStatus.PrinterCP866 then
    Result := 866;
end;

function TDatecsFP.GetDisplayCodePage: Integer;
begin
  Result := 1251;
  if FStatus.DisplayCP866 then
    Result := 866;
end;

function TDatecsFP.EncodePrinterText(const Text: WideString): AnsiString;
begin
  case PrinterEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := WideStringToAnsiString(GetPrinterCodePage, Text);
    EncodingSelected: Result := WideStringToAnsiString(PrinterCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsFP.EncodeDisplayText(const Text: WideString): AnsiString;
begin
  case DisplayEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := WideStringToAnsiString(GetDisplayCodePage, Text);
    EncodingSelected: Result := WideStringToAnsiString(DisplayCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsFP.DecodePrinterText(const Text: AnsiString): WideString;
begin
  case PrinterEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := AnsiStringToWideString(GetPrinterCodePage, Text);
    EncodingSelected: Result := AnsiStringToWideString(PrinterCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsFP.DecodeDisplayText(const Text: AnsiString): WideString;
begin
  case DisplayEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := AnsiStringToWideString(GetDisplayCodePage, Text);
    EncodingSelected: Result := AnsiStringToWideString(DisplayCodePage, Text);
  else
    Result := Text;
  end;
end;

procedure TDatecsFP.SetStatusData(const Value: string);
begin
  FStatusData := Value;
  DecodeStatus(FStatusData, FStatus);
end;

function TDatecsFP.GetSynInterval: Integer;
begin
  Result := FSynTimer.Interval;
end;

procedure TDatecsFP.SetSynInterval(const Value: Integer);
begin
  FSynTimer.Interval := Value;
end;

end.
