
unit duOposUtils;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Math,
  // DUnit
  TestFramework,
  // Opos
  OposUtils, StringUtils;

type
  { TOposUtilsTest }

  TOposUtilsTest = class(TTestCase)
  published
    procedure TestCeil;
    procedure TestStrToNibble;
  end;

implementation

{ TOposUtilsTest }

procedure TOposUtilsTest.TestCeil;
begin
  CheckEquals(2, Ceil(1.01));
  CheckEquals(2, Ceil(1.99));
  CheckEquals(2, Ceil(2.0));
  CheckEquals(3, Ceil(2.01));
end;

procedure TOposUtilsTest.TestStrToNibble;
const
  Data = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014'#13#10;
  DataNibble = '687474703:2?2?6465762>6;6?66642>6;7:2?636?6>73756=65723?693=39323538373134323538373626663=32313130333032303032303726733=31353434332>373226743=3230323230383236543231303031340=0:';
var
  S: AnsiString;
begin
  S := OposStrToNibble(Data);
  CheckEquals(DataNibble, S, 'OposStrToNibble');

  S := OposNibbleToStr(OposStrToNibble(Data));
  CheckEquals(S, Data, 'Data');;
end;


initialization
  RegisterTest('', TOposUtilsTest.Suite);

end.
