program OposConfig;

uses
  Forms,
  SysUtils,
  gnugettext,
  Opos in '..\Opos\Opos.pas',
  Oposhi in '..\Opos\Oposhi.pas',
  OposFptr in '..\Opos\OposFptr.pas',
  OposUtils in '..\Opos\OposUtils.pas',
  OposDevice in '..\Opos\OposDevice.pas',
  OposFptrhi in '..\Opos\OposFptrhi.pas',
  OposFptrUtils in '..\Opos\OposFptrUtils.pas',
  OPOSException in '..\Opos\OposException.pas',
  untPages in 'Units\untPages.pas',
  BaseForm in '..\Shared\BaseForm.pas',
  fmuMain in 'Fmu\fmuMain.pas' {fmMain},
  fmuPages in 'Fmu\fmuPages.pas' {fmPages},
  fmuDevice in 'Fmu\fmuDevice.pas' {fmDevice},
  fmuFptrLog in 'Fmu\fmuFptrLog.pas' {fmFptrLog},
  fmuFptrConnection in 'Fmu\fmuFptrConnection.pas' {fmFptrConnection},
  VersionInfo in '..\Shared\VersionInfo.pas',
  DriverError in '..\Shared\DriverError.pas',
  WException in '..\Shared\WException.pas',
  FptrTypes in 'Units\FptrTypes.pas',
  LogFile in '..\Shared\LogFile.pas',
  FileUtils in '..\Shared\FileUtils.pas',
  untUtil in 'Units\untUtil.pas',
 FiscalPrinterDevice in 'Units\FiscalPrinterDevice.pas',
  DeviceNotification in '..\Shared\DeviceNotification.pas',
  PrinterParameters in '..\OposDaisy\units\PrinterParameters.pas',
  PrinterParametersX in '..\OposDaisy\units\PrinterParametersX.pas',
  PrinterParametersReg in '..\OposDaisy\units\PrinterParametersReg.pas';

{$R *.RES}
{$R WindowsXP.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmFptrConnection, fmFptrConnection);
  Application.Run;
end.



