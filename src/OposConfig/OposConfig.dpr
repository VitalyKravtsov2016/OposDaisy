program OposConfig;

uses
  Forms,
  SysUtils,
  gnugettext,
  untPages in 'Units\untPages.pas',
  BaseForm in '..\Shared\BaseForm.pas',
  fmuMain in 'Fmu\fmuMain.pas' {fmMain},
  fmuPages in 'Fmu\fmuPages.pas' {fmPages},
  fmuDevice in 'Fmu\fmuDevice.pas' {fmDevice},
  fmuFptrLog in 'Fmu\fmuFptrLog.pas' {fmFptrLog},
  fmuLogo in '..\OposDaisy\Fmu\fmuLogo.pas' {fmLogo},
  fmuFptrConnection in 'Fmu\fmuFptrConnection.pas' {fmFptrConnection},
  OposDevice in '..\Opos\OposDevice.pas',
  Oposhi in '..\Opos\Oposhi.pas',
  VersionInfo in '..\Shared\VersionInfo.pas',
  DriverError in '..\Shared\DriverError.pas',
  WException in '..\Shared\WException.pas',
  FiscalPrinterDevice in 'Units\FiscalPrinterDevice.pas',
  FptrTypes in 'Units\FptrTypes.pas',
  Opos in '..\Opos\Opos.pas',
  OposFptrUtils in '..\Opos\OposFptrUtils.pas',
  OposUtils in '..\Opos\OposUtils.pas',
  OPOSException in '..\Opos\OposException.pas',
  OposFptr in '..\Opos\OposFptr.pas',
  OposFptrhi in '..\Opos\OposFptrhi.pas',
  PrinterParameters in '..\OposDaisy\units\PrinterParameters.pas',
  LogFile in '..\Shared\LogFile.pas',
  FileUtils in '..\Shared\FileUtils.pas',
  SerialPort in '..\Shared\SerialPort.pas',
  PrinterPort in '..\Shared\PrinterPort.pas',
  DeviceNotification in '..\Shared\DeviceNotification.pas',
  PortUtil in '..\Shared\PortUtil.pas',
  TextReport in '..\Shared\TextReport.pas',
  SerialPorts in '..\Shared\SerialPorts.pas',
  PrinterParametersX in '..\OposDaisy\units\PrinterParametersX.pas',
  PrinterParametersReg in '..\OposDaisy\units\PrinterParametersReg.pas';

PrinterParameters in '..\Shared\PrinterParameters.pas',
  PrinterParametersX in '..\Shared\PrinterParametersX.pas',
  PrinterParametersReg in '..\Shared\PrinterParametersReg.pas';

{$R *.RES}
{$R WindowsXP.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmFptrConnection, fmFptrConnection);
  Application.Run;
end.



