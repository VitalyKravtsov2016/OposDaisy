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
  WException, LogFile, FileUtils, SerialPort, SerialPorts, ReceiptItem;

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

  FiscalPrinterProgID = 'OposDatecs.FiscalPrinter';

  /////////////////////////////////////////////////////////////////////////////
  // ConnectionType constants

  ConnectionTypeSerial   = 0;
  ConnectionTypeSocket   = 1;
  ConnectionTypeJson     = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Default values

  DefLogMaxCount = 10;
  DefLogFileEnabled = True;
  DefPrinterType = 0;
  DefRemoteHost = '192.168.1.87';
  DefRemotePort = 9100;
  DefByteTimeout = 500;
  DefPortNumber = 1;
  DefBaudRate = CBR_9600;
  DefDataBits = DATABITS_8;
  DefStopBits = ONESTOPBIT;
  DefParity = NOPARITY;
  DefFlowControl = FLOW_CONTROL_NONE;
  DefReconnectPort = false;
  DefSerialTimeout = 500;
  DefDevicePollTime = 3000;
  DefConnectionType = ConnectionTypeSerial;

type
  { TPrinterParameters }

  TPrinterParameters = class(TPersistent)
  private
    FLogger: ILogFile;
    FLogMaxCount: Integer;
    FLogFileEnabled: Boolean;
    FLogFilePath: WideString;
    FRemoteHost: string;
    FRemotePort: Integer;
    FByteTimeout: Integer;
    FBaudRate: Integer;
    FDevicePollTime: Integer;
    FConnectionType: Integer;

    procedure SetBaudRate(const Value: Integer);
  public
    PortNumber: Integer;
    DataBits: Integer;
    StopBits: Integer;
    Parity: Integer;
    FlowControl: Integer;
    SerialTimeout: Integer;
    ReconnectPort: Boolean;
    Password: WideString;
    OperatorNumber: Integer;
    OperatorPassword: Integer;

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
    property LogMaxCount: Integer read FLogMaxCount write FLogMaxCount;
    property LogFilePath: WideString read FLogFilePath write FLogFilePath;
    property LogFileEnabled: Boolean read FLogFileEnabled write FLogFileEnabled;
    property ConnectionType: Integer read FConnectionType write FConnectionType;
    property RemoteHost: string read FRemoteHost write FRemoteHost;
    property RemotePort: Integer read FRemotePort write FRemotePort;
    property ByteTimeout: Integer read FByteTimeout write FByteTimeout;
    property BaudRate: Integer read FBaudRate write SetBaudRate;
    property DevicePollTime: Integer read FDevicePollTime write FDevicePollTime;
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

  FLogMaxCount := DefLogMaxCount;
  FLogFilePath := GetModulePath + 'Logs';
  FLogFileEnabled := DefLogFileEnabled;
  ConnectionType := DefConnectionType;
  FRemoteHost := DefRemoteHost;
  FRemotePort := DefRemotePort;
  FByteTimeout := DefByteTimeout;
  PortNumber := DefPortNumber;
  BaudRate := DefBaudRate;
  DataBits := DefDataBits;
  StopBits := DefStopBits;
  Parity := DefParity;
  FlowControl := DefFlowControl;
  ReconnectPort := DefReconnectPort;
  SerialTimeout := DefSerialTimeout;
  DevicePollTime := DefDevicePollTime;
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
  Logger.Debug('LogMaxCount: ' + IntToStr(LogMaxCount));
  Logger.Debug('LogFilePath: ' + LogFilePath);
  Logger.Debug('LogFileEnabled: ' + BoolToStr(LogFileEnabled));
  Logger.Debug('ConnectionType: ' + IntToStr(ConnectionType));
  Logger.Debug('RemoteHost: ' + RemoteHost);
  Logger.Debug('RemotePort: ' + IntToStr(RemotePort));
  Logger.Debug('ByteTimeout: ' + IntToStr(ByteTimeout));
  Logger.Debug('DevicePollTime: ' + IntToStr(DevicePollTime));
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
    LogMaxCount := Src.LogMaxCount;
    LogFileEnabled := Src.LogFileEnabled;
    LogFilePath := Src.LogFilePath;
    ConnectionType := Src.ConnectionType;
    RemoteHost := Src.RemoteHost;
    RemotePort := Src.RemotePort;
    ByteTimeout := Src.ByteTimeout;
    BaudRate := Src.BaudRate;
    PortNumber := Src.PortNumber;
    DataBits := Src.DataBits;
    StopBits := Src.StopBits;
    Parity := Src.Parity;
    FlowControl := Src.FlowControl;
    SerialTimeout := Src.SerialTimeout;
    ReconnectPort := Src.ReconnectPort;
    DevicePollTime := Src.DevicePollTime;
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
