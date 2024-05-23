
unit duSalesReceipt;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Math,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposUtils,
  // This
  SalesReceipt;

type
  { TOposUtilsTest }

  TSalesReceiptTest = class(TTestCase)
  published
    procedure TestReceipt;
  end;

implementation

{ TSalesReceiptTest }

procedure TSalesReceiptTest.TestReceipt;
var
  Receipt: TSalesReceipt;
begin
  Receipt := TSalesReceipt.CreateReceipt(2, False);
  try
    Receipt.BeginFiscalReceipt(False);
    Receipt.PrintRecItem('¿»-92', 50.01, 16.560, 2, 3.02, 'Î');
    Receipt.PrintRecTotal(50.01, 50.01, '1');
    CheckEquals(50.01, Receipt.GetTotal, 'Receipt.GetTotal');
    Receipt.EndFiscalReceipt(False);
  finally
    Receipt.Free;
  end;
end;

initialization
  RegisterTest('', TSalesReceiptTest.Suite);

end.
