unit PrinterParametersReg;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Registry,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry, TntSysUtils,
  // This
  PrinterParameters, LogFile, Oposhi, WException, gnugettext, DriverError;

type
  { TPrinterParametersReg }

  TPrinterParametersReg = class
  private
    FLogger: ILogFile;
    FParameters: TPrinterParameters;

    procedure LoadSysParameters(const DeviceName: WideString);
    procedure LoadUsrParameters(const DeviceName: WideString);
    procedure SaveSysParameters(const DeviceName: WideString);
    procedure SaveUsrParameters(const DeviceName: WideString);

    property Parameters: TPrinterParameters read FParameters;
  public
    constructor Create(AParameters: TPrinterParameters; ALogger: ILogFile);

    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);
    class function GetUsrKeyName(const DeviceName: WideString): WideString;
    class function GetSysKeyName(const DeviceName: WideString): WideString;

    property Logger: ILogFile read FLogger;
  end;

procedure DeleteParametersReg(const DeviceName: WideString; Logger: ILogFile);
procedure LoadParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveUsrParametersReg(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

implementation

const
  REG_KEY_VatRateS  = 'VatRates';
  REG_KEY_PAYTYPES  = 'PaymentTypes';
  REGSTR_KEY_IBT = 'SOFTWARE\POSITIVE\POSITIVE32\Terminal';

procedure DeleteParametersReg(const DeviceName: WideString; Logger: ILogFile);
var
  Reg: TTntRegistry;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.DeleteKey(TPrinterParametersReg.GetUsrKeyName(DeviceName));
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.DeleteKey(TPrinterParametersReg.GetSysKeyName(DeviceName));
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.Save', E);
  end;
  Reg.Free;
end;

procedure LoadParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Reader: TPrinterParametersReg;
begin
  Reader := TPrinterParametersReg.Create(Item, Logger);
  try
    Reader.Load(DeviceName);
    Item.Load(DeviceName);     
  finally
    Reader.Free;
  end;
end;

procedure SaveParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Writer: TPrinterParametersReg;
begin
  Writer := TPrinterParametersReg.Create(Item, Logger);
  try
    Writer.Save(DeviceName);
    Item.Save(DeviceName);
  finally
    Writer.Free;
  end;
end;

procedure SaveUsrParametersReg(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);
var
  Writer: TPrinterParametersReg;
begin
  Writer := TPrinterParametersReg.Create(Item, Logger);
  try
    Writer.SaveUsrParameters(DeviceName);
  finally
    Writer.Free;
  end;
end;

{ TPrinterParametersReg }

constructor TPrinterParametersReg.Create(AParameters: TPrinterParameters;
  ALogger: ILogFile);
begin
  inherited Create;
  FParameters := AParameters;
  FLogger := ALogger;
end;

class function TPrinterParametersReg.GetSysKeyName(const DeviceName: WideString): WideString;
begin
  Result := Tnt_WideFormat('%s\%s\%s', [OPOS_ROOTKEY, OPOS_CLASSKEY_FPTR, DeviceName]);
end;

procedure TPrinterParametersReg.Load(const DeviceName: WideString);
begin
  LoadSysParameters(DeviceName);
  LoadUsrParameters(DeviceName);
end;

procedure TPrinterParametersReg.Save(const DeviceName: WideString);
begin
  SaveUsrParameters(DeviceName);
  SaveSysParameters(DeviceName);
end;

procedure TPrinterParametersReg.LoadSysParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
  KeyName: WideString;
begin
  Logger.Debug('TPrinterParametersReg.Load', [DeviceName]);

  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetSysKeyName(DeviceName);
    if Reg.OpenKey(KeyName, False) then
    begin
      if Reg.ValueExists('LogMaxCount') then
        Parameters.LogMaxCount := Reg.ReadInteger('LogMaxCount');

      if Reg.ValueExists('LogFileEnabled') then
        Parameters.LogFileEnabled := Reg.ReadBool('LogFileEnabled');

      if Reg.ValueExists('LogFilePath') then
        Parameters.LogFilePath := Reg.ReadString('LogFilePath');

      if Reg.ValueExists('ConnectionType') then
        Parameters.ConnectionType := Reg.ReadInteger('ConnectionType');

      if Reg.ValueExists('RemoteHost') then
        Parameters.RemoteHost := Reg.ReadString('RemoteHost');

      if Reg.ValueExists('RemotePort') then
        Parameters.RemotePort := Reg.ReadInteger('RemotePort');

      if Reg.ValueExists('ByteTimeout') then
        Parameters.ByteTimeout := Reg.ReadInteger('ByteTimeout');

      if Reg.ValueExists('PortNumber') then
        Parameters.PortNumber := Reg.ReadInteger('PortNumber');

      if Reg.ValueExists('BaudRate') then
        Parameters.BaudRate := Reg.ReadInteger('BaudRate');

      if Reg.ValueExists('DataBits') then
        Parameters.DataBits := Reg.ReadInteger('DataBits');

      if Reg.ValueExists('StopBits') then
        Parameters.StopBits := Reg.ReadInteger('StopBits');

      if Reg.ValueExists('Parity') then
        Parameters.Parity := Reg.ReadInteger('Parity');

      if Reg.ValueExists('FlowControl') then
        Parameters.FlowControl := Reg.ReadInteger('FlowControl');

      if Reg.ValueExists('ReconnectPort') then
        Parameters.ReconnectPort := Reg.ReadBool('ReconnectPort');

      if Reg.ValueExists('SerialTimeout') then
        Parameters.SerialTimeout := Reg.ReadInteger('SerialTimeout');

      if Reg.ValueExists('DevicePollTime') then
        Parameters.DevicePollTime := Reg.ReadInteger('DevicePollTime');

      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TPrinterParametersReg.SaveSysParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
  KeyName: WideString;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetSysKeyName(DeviceName);
    if not Reg.OpenKey(KeyName, True) then
      raiseOpenKeyError(KeyName);

    Reg.WriteString('', FiscalPrinterProgID);
    Reg.WriteBool('LogFileEnabled', Parameters.LogFileEnabled);
    Reg.WriteString('LogFilePath', FParameters.LogFilePath);
    Reg.WriteInteger('LogMaxCount', FParameters.LogMaxCount);
    Reg.WriteString('RemoteHost', FParameters.RemoteHost);
    Reg.WriteInteger('RemotePort', FParameters.RemotePort);
    Reg.WriteInteger('ByteTimeout', FParameters.ByteTimeout);
    Reg.WriteInteger('PortNumber', FParameters.PortNumber);
    Reg.WriteInteger('BaudRate', FParameters.BaudRate);
    Reg.WriteInteger('DataBits', FParameters.DataBits);
    Reg.WriteInteger('StopBits', FParameters.StopBits);
    Reg.WriteInteger('Parity', FParameters.Parity);
    Reg.WriteInteger('FlowControl', FParameters.FlowControl);
    Reg.WriteBool('ReconnectPort', FParameters.ReconnectPort);
    Reg.WriteInteger('SerialTimeout', FParameters.SerialTimeout);
    Reg.WriteInteger('DevicePollTime', FParameters.DevicePollTime);
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

class function TPrinterParametersReg.GetUsrKeyName(const DeviceName: WideString): WideString;
begin
  Result := Tnt_WideFormat('%s\%s\%s', [OPOS_ROOTKEY, OPOS_CLASSKEY_FPTR, DeviceName]);
end;

procedure TPrinterParametersReg.LoadUsrParameters(const DeviceName: WideString);
begin
end;

procedure TPrinterParametersReg.SaveUsrParameters(const DeviceName: WideString);
begin
end;

end.
