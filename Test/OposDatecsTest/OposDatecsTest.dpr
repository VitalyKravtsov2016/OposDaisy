program OposDatecsTest;

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
  duLogFile in 'units\duLogFile.pas',
  OPOSException in '..\..\src\Opos\OposException.pas',
  OposServiceDevice19 in '..\..\src\Opos\OposServiceDevice19.pas',
  OposFptr in '..\..\src\Opos\OposFptr.pas',
  OposEvents in '..\..\src\Opos\OposEvents.pas',
  OposFptrUtils in '..\..\src\Opos\OposFptrUtils.pas',
  OposFptrhi in '..\..\src\Opos\OposFptrhi.pas',
  NotifyThread in '..\..\src\Shared\NotifyThread.pas',
  StringUtils in '..\..\src\Shared\StringUtils.pas',
  RegExpr in '..\..\src\Shared\RegExpr.pas',
  FileUtils in '..\..\src\Shared\FileUtils.pas';

{$R *.RES}

begin
  TGUITestRunner.RunTest(RegisteredTests);
end.
