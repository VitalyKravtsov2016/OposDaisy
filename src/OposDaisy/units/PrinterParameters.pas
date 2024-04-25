unit PrinterParameters;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry,
  // Opos
  Opos, Oposhi, OposException,
  // This
  WException, LogFile, FileUtils, SerialPort, SerialPorts;

const
  /////////////////////////////////////////////////////////////////////////////
  // Valid baudrates

  ValidBaudRates: array [0..9] of Integer = (
    2400,
    4800,
    9600,
    19200,
    38400,
    57600,
    115200,
    230400,
    460800,
    921600
  );

  FiscalPrinterProgID = 'OposDaisy.FiscalPrinter';

  /////////////////////////////////////////////////////////////////////////////
  // ConnectionType constants

  ConnectionTypeSerial   = 0;
  ConnectionTypeSocket   = 1;
  ConnectionTypeJson     = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Default values

  DefBaudRate = CBR_19200;
  DefByteTimeout = 500;
  DefCCOType = 0;
  DefConnectionType = ConnectionTypeSerial;
  DefDevicePollTime = 3000;
  DefLogFileEnabled = True;
  DefLogMaxCount = 10;
  DefMaxRetryCount = 3;
  DefOperatorNumber = 1;
  DefOperatorPassword = 1;
  DefPortName = 'COM1';
  DefReconnectPort = false;
  DefRemoteHost = '192.168.1.87';
  DefRemotePort = 9100;
  DefSearchByBaudRateEnabled = False;
  DefSearchByPortEnabled = False;

type
  { TPrinterParameters }

  TPrinterParameters = class(TPersistent)
  private
    FLogger: ILogFile;
    FBaudRate: Integer;
    procedure SetBaudRate(const Value: Integer);
  public
    ByteTimeout: Integer;
    CCOType: Integer;
    ConnectionType: Integer;
    DevicePollTime: Integer;
    LogFileEnabled: Boolean;
    LogFilePath: WideString;
    LogMaxCount: Integer;
    MaxRetryCount: Integer;
    OperatorNumber: Integer;
    OperatorPassword: Integer;
    PortName: WideString;
    ReconnectPort: Boolean;
    RemoteHost: string;
    RemotePort: Integer;
    SearchByBaudRateEnabled: Boolean;
    SearchByPortEnabled: Boolean;

    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    procedure SetDefaults;
    procedure WriteLogParameters;
    function SerialPortNames: string;
    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);
    procedure Assign(Source: TPersistent); override;
    function BaudRateIndex(const Value: Integer): Integer;
    function ItemByText(const ParamName: WideString): WideString;
    procedure LogText(const Caption, Text: WideString);

    property Logger: ILogFile read FLogger;
    property BaudRate: Integer read FBaudRate write SetBaudRate;
  end;

implementation

{ TPrinterParameters }

constructor TPrinterParameters.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  SetDefaults;
end;

destructor TPrinterParameters.Destroy;
begin
  inherited Destroy;
end;

procedure TPrinterParameters.SetDefaults;
begin
  Logger.Debug('TPrinterParameters.SetDefaults');

  BaudRate := DefBaudRate;
  ByteTimeout := DefByteTimeout;
  CCOType := DefCCOType;
  ConnectionType := DefConnectionType;
  DevicePollTime := DefDevicePollTime;
  LogFileEnabled := DefLogFileEnabled;
  LogFilePath := GetModulePath + 'Logs';
  LogMaxCount := DefLogMaxCount;
  MaxRetryCount := DefMaxRetryCount;
  OperatorNumber := DefOperatorNumber;
  OperatorPassword := DefOperatorPassword;
  PortName := DefPortName;
  ReconnectPort := DefReconnectPort;
  ReconnectPort := DefReconnectPort;
  RemoteHost := DefRemoteHost;
  RemotePort := DefRemotePort;
  SearchByBaudRateEnabled := DefSearchByBaudRateEnabled;
  SearchByPortEnabled := DefSearchByPortEnabled;
end;

procedure TPrinterParameters.LogText(const Caption, Text: WideString);
var
  i: Integer;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    if Lines.Count = 1 then
    begin
      Logger.Debug(Format('%s: ''%s''', [Caption, Lines[0]]));
    end else
    begin
      for i := 0 to Lines.Count-1 do
      begin
        Logger.Debug(Format('%s.%d: ''%s''', [Caption, i, Lines[i]]));
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TPrinterParameters.WriteLogParameters;
begin
  Logger.Debug('TPrinterParameters.WriteLogParameters');
  Logger.Debug(Logger.Separator);
  Logger.Debug('BaudRate: ' + IntToStr(BaudRate));
  Logger.Debug('ByteTimeout: ' + IntToStr(ByteTimeout));
  Logger.Debug('CCOType: ' + IntToStr(CCOType));
  Logger.Debug('ConnectionType: ' + IntToStr(ConnectionType));
  Logger.Debug('DevicePollTime: ' + IntToStr(DevicePollTime));
  Logger.Debug('LogFileEnabled: ' + BoolToStr(LogFileEnabled));
  Logger.Debug('LogFilePath: ' + LogFilePath);
  Logger.Debug('LogMaxCount: ' + IntToStr(LogMaxCount));
  Logger.Debug('MaxRetryCount: ' + IntToStr(MaxRetryCount));
  Logger.Debug('OperatorNumber: ' + IntToStr(OperatorNumber));
  Logger.Debug('OperatorPassword: ' + IntToStr(OperatorPassword));
  Logger.Debug('PortName: ' + PortName);
  Logger.Debug('ReconnectPort: ' + BoolToStr(ReconnectPort));
  Logger.Debug('RemoteHost: ' + RemoteHost);
  Logger.Debug('RemotePort: ' + IntToStr(RemotePort));
  Logger.Debug('SearchByBaudRateEnabled: ' + BoolToStr(SearchByBaudRateEnabled));
  Logger.Debug('SearchByPortEnabled: ' + BoolToStr(SearchByPortEnabled));
  Logger.Debug(Logger.Separator);
end;

function TPrinterParameters.BaudRateIndex(const Value: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := Low(ValidBaudRates) to High(ValidBaudRates) do
  begin
    if ValidBaudRates[i] = Value then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TPrinterParameters.SetBaudRate(const Value: Integer);
begin
  if BaudRateIndex(Value) = -1 then
    raise Exception.CreateFmt('Invalid baudrate value, %d', [Value]);

  FBaudRate := Value;
end;

function TPrinterParameters.SerialPortNames: string;
begin
  Result := TSerialPorts.GetPortNames;
end;

procedure TPrinterParameters.Assign(Source: TPersistent);
var
  Src: TPrinterParameters;
begin
  if Source is TPrinterParameters then
  begin
    Src := Source as TPrinterParameters;

    BaudRate := Src.BaudRate;
    ByteTimeout := Src.ByteTimeout;
    CCOType := Src.CCOType;
    ConnectionType := Src.ConnectionType;
    DevicePollTime := Src.DevicePollTime;
    LogFileEnabled := Src.LogFileEnabled;
    LogFilePath := Src.LogFilePath;
    LogMaxCount := Src.LogMaxCount;
    MaxRetryCount := Src.MaxRetryCount;
    OperatorNumber := Src.OperatorNumber;
    OperatorPassword := Src.OperatorPassword;
    PortName := Src.PortName;
    ReconnectPort := Src.ReconnectPort;
    RemoteHost := Src.RemoteHost;
    RemotePort := Src.RemotePort;
    SearchByBaudRateEnabled := Src.SearchByBaudRateEnabled;
    SearchByPortEnabled := Src.SearchByPortEnabled;
  end else
    inherited Assign(Source);
end;

procedure TPrinterParameters.Load(const DeviceName: WideString);
begin
end;

procedure TPrinterParameters.Save(const DeviceName: WideString);
begin
end;

function TPrinterParameters.ItemByText(
  const ParamName: WideString): WideString;
begin

end;

end.
