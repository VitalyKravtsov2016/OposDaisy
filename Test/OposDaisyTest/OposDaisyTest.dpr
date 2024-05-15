program OposDaisyTest;

uses
  SysUtils,
  TestFramework,
  GUITestRunner,
  LogFile in '..\..\src\Shared\LogFile.pas',
  Opos in '..\..\src\Opos\Opos.pas',
  OposUtils in '..\..\src\Opos\OposUtils.pas',
  Oposhi in '..\..\src\Opos\Oposhi.pas',
  OposStat in '..\..\src\Opos\OposStat.pas',
  OposSemaphore in '..\..\src\Opos\OposSemaphore.pas',
  WException in '..\..\src\Shared\WException.pas',
  duOposDevice in 'units\duOposDevice.pas',
  duOposUtils in 'units\duOposUtils.pas',
  OPOSException in '..\..\src\Opos\OposException.pas',
  OposServiceDevice19 in '..\..\src\Opos\OposServiceDevice19.pas',
  OposFptr in '..\..\src\Opos\OposFptr.pas',
  OposEvents in '..\..\src\Opos\OposEvents.pas',
  OposFptrUtils in '..\..\src\Opos\OposFptrUtils.pas',
  OposFptrhi in '..\..\src\Opos\OposFptrhi.pas',
  NotifyThread in '..\..\src\Shared\NotifyThread.pas',
  StringUtils in '..\..\src\Shared\StringUtils.pas',
  FileUtils in '..\..\src\Shared\FileUtils.pas',
  PrinterPort in '..\..\src\Shared\PrinterPort.pas',
  ByteUtils in '..\..\src\Shared\ByteUtils.pas',
  SerialPort in '..\..\src\Shared\SerialPort.pas',
  DeviceNotification in '..\..\src\Shared\DeviceNotification.pas',
  PortUtil in '..\..\src\Shared\PortUtil.pas',
  TextReport in '..\..\src\Shared\TextReport.pas',
  SocketPort in '..\..\src\Shared\SocketPort.pas',
  DriverError in '..\..\src\Shared\DriverError.pas',
  DebugUtils in '..\..\src\Shared\DebugUtils.pas',
  DaisyPrinter in '..\..\src\OposDaisy\units\DaisyPrinter.pas',
  DaisyPrinterInterface in '..\..\src\OposDaisy\units\DaisyPrinterInterface.pas',
  duDaisyFiscalPrinter in 'units\duDaisyFiscalPrinter.pas',
  DaisyFiscalPrinter in '..\..\src\OposDaisy\units\DaisyFiscalPrinter.pas',
  OPOSDaisyLib_TLB in '..\..\src\OposDaisy\OPOSDaisyLib_TLB.pas',
  OposEventsRCS in '..\..\src\Opos\OposEventsRCS.pas',
  VersionInfo in '..\..\src\Shared\VersionInfo.pas',
  FiscalPrinterState in '..\..\src\OposDaisy\units\FiscalPrinterState.pas',
  ServiceVersion in '..\..\src\Shared\ServiceVersion.pas',
  DeviceService in '..\..\src\Shared\DeviceService.pas',
  PrinterParameters in '..\..\src\OposDaisy\units\PrinterParameters.pas',
  PrinterParametersX in '..\..\src\OposDaisy\units\PrinterParametersX.pas',
  PrinterParametersReg in '..\..\src\OposDaisy\units\PrinterParametersReg.pas',
  CashReceipt in '..\..\src\OposDaisy\units\CashReceipt.pas',
  FiscalReceipt in '..\..\src\OposDaisy\units\FiscalReceipt.pas',
  SalesReceipt in '..\..\src\OposDaisy\units\SalesReceipt.pas',
  ReceiptItem in '..\..\src\OposDaisy\units\ReceiptItem.pas',
  MathUtils in '..\..\src\OposDaisy\units\MathUtils.pas',
  PrinterTypes in '..\..\src\Shared\PrinterTypes.pas',
  DirectIOAPI in '..\..\src\OposDaisy\units\DirectIOAPI.pas',
  fmuLogo in '..\..\src\OposDaisy\Fmu\fmuLogo.pas' {fmLogo},
  BaseForm in '..\..\src\Shared\BaseForm.pas',
  oleFiscalPrinter in '..\..\src\OposDaisy\units\oleFiscalPrinter.pas',
  MockDaisyPrinter in 'units\MockDaisyPrinter.pas';

{$R *.RES}

begin
  TGUITestRunner.RunTest(RegisteredTests);
end.
