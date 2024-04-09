unit duDatecsPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics, DateUtils,
  // Tnt
  TntGraphics, TntClasses,
  // DUnit
  TestFramework,
  // This
  DatecsPrinter2, LogFile, SerialPort, FileUtils, PrinterPort, SocketPort;

type
  { TDatecsPrinterTest }

  TDatecsPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FPrinter: TDatecsPrinter;
    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;

    property Printer: TDatecsPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadWriteDate;
    procedure TestPrintDiagnosticInfo;
    procedure TestReadDiagnosticInfo;
  end;

implementation

{ TDatecsPrinterTest }

procedure TDatecsPrinterTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  FPort := CreateSerialPort;
  FPrinter := TDatecsPrinter.Create(FPort, FLogger);
end;

procedure TDatecsPrinterTest.TearDown;
begin
  FPrinter.Free;
  FPrinter := nil;
end;

function TDatecsPrinterTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM3';
  SerialParams.BaudRate := 19200;
  SerialParams.DataBits := 8;
  SerialParams.StopBits := ONESTOPBIT;
  SerialParams.Parity := 0;
  SerialParams.FlowControl := FLOW_CONTROL_NONE;
  SerialParams.ReconnectPort := False;
  SerialParams.ByteTimeout := 1000;
  Result := TSerialPort.Create(SerialParams, FLogger);
  Result.Open;
  Result.SetDTRState(True);
end;

function TDatecsPrinterTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TDatecsPrinterTest.TestPrintDiagnosticInfo;
begin
  Printer.Check(Printer.PrintDiagnosticInfo);
end;

procedure TDatecsPrinterTest.TestReadWriteDate;
var
  Date: TDateTime;
  Seconds: Integer;
  Response: TDateTimeResponse;
  Hour, Min, Sec, MSec: Word;
begin
  Date := Now;
  Printer.Check(Printer.WriteDateTime(Date));
  Response := Printer.ReadDateTime;
  Printer.Check(Response.ResultCode);
  Seconds := Abs(SecondsBetween(Date, Response.Date));
  Check(Seconds <= 60, 'Seconds > 60, ' + IntToStr(Seconds));
  // Seconds are not set
  DecodeTime(Response.Date, Hour, Min, Sec, MSec);
  Check(Sec <= 1, 'Sec > 1, ' + IntToStr(Sec));
end;

procedure TDatecsPrinterTest.TestReadDiagnosticInfo;
var
  Data: TDiagnosticInfo;
begin
  Data := Printer.GetDiagnosticInfo(False);
  Printer.Check(Data.ResultCode);
  CheckEquals('FX1300-11.00GE', Data.FirmwareVersion, 'FirmwareVersion');
  CheckEquals('27-10-2017', Data.FirmwareDate, 'FirmwareDate');
  CheckEquals('09:22', Data.FirmwareTime, 'FirmwareTime');
  CheckEquals('643A', Data.ChekSum, 'ChekSum');
  CheckEquals(0, Data.Switches, 'Switches');
  CheckEquals(8, Data.Country, 'Country');
  CheckEquals('', Data.FDSerial, 'FDSerial');
  CheckEquals('', Data.FDNo, 'FDNo');
end;

initialization
  RegisterTest('', TDatecsPrinterTest.Suite);

end.
