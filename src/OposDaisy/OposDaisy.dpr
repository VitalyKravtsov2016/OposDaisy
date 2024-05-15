library OposDaisy;

uses
  Opos in '..\Opos\Opos.pas',
  Oposhi in '..\Opos\Oposhi.pas',
  OposFptr in '..\Opos\OposFptr.pas',
  OposUtils in '..\Opos\OposUtils.pas',
  OposFptrhi in '..\Opos\OposFptrhi.pas',
  OposEvents in '..\Opos\OposEvents.pas',
  OposSemaphore in '..\Opos\OposSemaphore.pas',
  OposException in '..\Opos\OposException.pas',
  OposFptrUtils in '..\Opos\OposFptrUtils.pas',
  OposEventsRCS in '..\Opos\OposEventsRCS.pas',
  OposServiceDevice19 in '..\Opos\OposServiceDevice19.pas',
  WException in '..\Shared\WException.pas',
  oleFiscalPrinter in 'Units\oleFiscalPrinter.pas',
  LogFile in '..\Shared\LogFile.pas',
  DaisyFiscalPrinter in 'units\DaisyFiscalPrinter.pas',
  OposDaisyLib_TLB in 'OposDaisyLib_TLB.pas',
  NotifyThread in '..\Shared\NotifyThread.pas',
  VersionInfo in '..\Shared\VersionInfo.pas',
  DebugUtils in '..\Shared\DebugUtils.pas',
  DriverError in '..\Shared\DriverError.pas',
  JsonUtils in '..\Shared\JsonUtils.pas',
  FiscalPrinterState in 'units\FiscalPrinterState.pas',
  MathUtils in 'units\MathUtils.pas',
  ServiceVersion in '..\Shared\ServiceVersion.pas',
  DeviceService in '..\Shared\DeviceService.pas',
  CashReceipt in 'units\CashReceipt.pas',
  FileUtils in '..\Shared\FileUtils.pas',
  StringUtils in '..\Shared\StringUtils.pas',
  SalesReceipt in 'units\SalesReceipt.pas',
  ReceiptItem in 'units\ReceiptItem.pas',
  ComServ in '..\Common\ComServ.pas',
  OposDevice in '..\Opos\OposDevice.pas',
  ByteUtils in '..\Shared\ByteUtils.pas',
  PrinterPort in '..\Shared\PrinterPort.pas',
  SerialPort in '..\Shared\SerialPort.pas',
  DeviceNotification in '..\Shared\DeviceNotification.pas',
  PortUtil in '..\Shared\PortUtil.pas',
  TextReport in '..\Shared\TextReport.pas',
  SocketPort in '..\Shared\SocketPort.pas',
  SerialPorts in '..\Shared\SerialPorts.pas',
  Translation in '..\Shared\Translation.pas',
  DirectIOAPI in 'units\DirectIOAPI.pas',
  PrinterTypes in '..\Shared\PrinterTypes.pas',
  StrUtil in '..\Shared\StrUtil.pas',
  VariantUtils in '..\Shared\VariantUtils.pas',
  DaisyPrinter in 'units\DaisyPrinter.pas',
  FiscalReceipt in 'units\FiscalReceipt.pas',
  PrinterParameters in 'units\PrinterParameters.pas',
  PrinterParametersX in 'units\PrinterParametersX.pas',
  PrinterParametersReg in 'units\PrinterParametersReg.pas',
  fmuLogo in 'Fmu\fmuLogo.pas' {fmLogo},
  BaseForm in '..\Shared\BaseForm.pas',
  DaisyPrinterInterface in 'units\DaisyPrinterInterface.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
