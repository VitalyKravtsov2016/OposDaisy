unit TestPrinterPort;

interface

uses
  // VCL
  Windows,
  // This
  PrinterPort;

type
  { TTestPrinterPort }

  TTestPrinterPort = class(TInterfacedObject, IPrinterPort)
  public
    procedure Flush;
    procedure Purge;
    procedure Close;
    procedure Open;
    procedure Lock;
    procedure Unlock;
    procedure Write(const Data: AnsiString);
    function Read(Count: DWORD): AnsiString;
    function CapRead: Boolean;
    function GetDescription: WideString;
  end;

implementation

{ TTestPrinterPort }

function TTestPrinterPort.CapRead: Boolean;
begin
  Result := False;
end;

procedure TTestPrinterPort.Close;
begin

end;

procedure TTestPrinterPort.Flush;
begin

end;

function TTestPrinterPort.GetDescription: WideString;
begin
  Result := 'Test port';
end;

procedure TTestPrinterPort.Lock;
begin

end;

procedure TTestPrinterPort.Open;
begin

end;

procedure TTestPrinterPort.Purge;
begin

end;

function TTestPrinterPort.Read(Count: DWORD): AnsiString;
begin
  Result := StringOfChar(#0, Count);
end;

procedure TTestPrinterPort.Unlock;
begin

end;

procedure TTestPrinterPort.Write(const Data: AnsiString);
begin

end;

end.
