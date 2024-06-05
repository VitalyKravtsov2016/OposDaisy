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
procedure DeleteUsrParametersReg(const DeviceName: WideString; Logger: ILogFile);

procedure LoadParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveUsrParametersReg(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

implementation

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

procedure DeleteUsrParametersReg(const DeviceName: WideString; Logger: ILogFile);
var
  Reg: TTntRegistry;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.DeleteKey(TPrinterParametersReg.GetUsrKeyName(DeviceName));
  finally
    Reg.Free;
  end;
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
      if Reg.ValueExists('BaudRate') then
        Parameters.BaudRate := Reg.ReadInteger('BaudRate');

      if Reg.ValueExists('ByteTimeout') then
        Parameters.ByteTimeout := Reg.ReadInteger('ByteTimeout');

      if Reg.ValueExists('CommandTimeout') then
        Parameters.CommandTimeout := Reg.ReadInteger('CommandTimeout');

      if Reg.ValueExists('ConnectionType') then
        Parameters.ConnectionType := Reg.ReadInteger('ConnectionType');

      if Reg.ValueExists('LogFileEnabled') then
        Parameters.LogFileEnabled := Reg.ReadBool('LogFileEnabled');

      if Reg.ValueExists('LogFilePath') then
        Parameters.LogFilePath := Reg.ReadString('LogFilePath');

      if Reg.ValueExists('LogMaxCount') then
        Parameters.LogMaxCount := Reg.ReadInteger('LogMaxCount');

      if Reg.ValueExists('MaxRetryCount') then
        Parameters.MaxRetryCount := Reg.ReadInteger('MaxRetryCount');

      if Reg.ValueExists('OperatorNumber') then
        Parameters.OperatorNumber := Reg.ReadInteger('OperatorNumber');

      if Reg.ValueExists('OperatorPassword') then
        Parameters.OperatorPassword := Reg.ReadInteger('OperatorPassword');

      if Reg.ValueExists('PollInterval') then
        Parameters.PollInterval := Reg.ReadInteger('PollInterval');

      if Reg.ValueExists('PortName') then
        Parameters.PortName := Reg.ReadString('PortName');

      if Reg.ValueExists('RemoteHost') then
        Parameters.RemoteHost := Reg.ReadString('RemoteHost');

      if Reg.ValueExists('RemotePort') then
        Parameters.RemotePort := Reg.ReadInteger('RemotePort');

      if Reg.ValueExists('SearchByBaudRateEnabled') then
        Parameters.SearchByBaudRateEnabled := Reg.ReadBool('SearchByBaudRateEnabled');

      if Reg.ValueExists('SearchByPortEnabled') then
        Parameters.SearchByPortEnabled := Reg.ReadBool('SearchByPortEnabled');

      if Reg.ValueExists('RefundCashoutLine1') then
        Parameters.RefundCashoutLine1 := Reg.ReadString('RefundCashoutLine1');

      if Reg.ValueExists('RefundCashoutLine2') then
        Parameters.RefundCashoutLine2 := Reg.ReadString('RefundCashoutLine2');

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
    Reg.WriteInteger('BaudRate', FParameters.BaudRate);
    Reg.WriteInteger('ByteTimeout', FParameters.ByteTimeout);
    Reg.WriteInteger('CommandTimeout', FParameters.CommandTimeout);
    Reg.WriteInteger('ConnectionType', FParameters.ConnectionType);
    Reg.WriteInteger('PollInterval', FParameters.PollInterval);
    Reg.WriteBool('LogFileEnabled', Parameters.LogFileEnabled);
    Reg.WriteString('LogFilePath', FParameters.LogFilePath);
    Reg.WriteInteger('LogMaxCount', FParameters.LogMaxCount);
    Reg.WriteInteger('MaxRetryCount', FParameters.MaxRetryCount);
    Reg.WriteInteger('OperatorNumber', FParameters.OperatorNumber);
    Reg.WriteInteger('OperatorPassword', FParameters.OperatorPassword);
    Reg.WriteString('PortName', FParameters.PortName);
    Reg.WriteString('RemoteHost', FParameters.RemoteHost);
    Reg.WriteInteger('RemotePort', FParameters.RemotePort);
    Reg.WriteBool('SearchByBaudRateEnabled', Parameters.SearchByBaudRateEnabled);
    Reg.WriteBool('SearchByPortEnabled', Parameters.SearchByPortEnabled);
    Reg.WriteString('RefundCashoutLine1', FParameters.RefundCashoutLine1);
    Reg.WriteString('RefundCashoutLine2', FParameters.RefundCashoutLine2);

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
var
  Reg: TTntRegistry;
  KeyName: WideString;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_CURRENT_USER;
    KeyName := GetUsrKeyName(DeviceName);
    if Reg.OpenKey(KeyName, False) then
    begin
      if Reg.ValueExists('DayOpened') then
      begin
        Parameters.DayOpened := Reg.ReadBool('DayOpened');
      end;
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

procedure TPrinterParametersReg.SaveUsrParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
  KeyName: WideString;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_CURRENT_USER;
    KeyName := GetUsrKeyName(DeviceName);
    if Reg.OpenKey(KeyName, True) then
    begin
      Reg.WriteBool('DayOpened', Parameters.DayOpened);
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

end.
