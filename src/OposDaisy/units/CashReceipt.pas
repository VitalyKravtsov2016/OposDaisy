unit CashReceipt;

interface

uses
  // VCL
  SysUtils,
  // Tnt
  TntClasses,
  // Opos
  Opos, OposException, OposFptr,
  // This
  FiscalReceipt, gnugettext;

type
  { TCashReceipt }

  TCashReceipt = class(TInterfacedObject, IFiscalReceipt)
  private
    FTotal: Currency;
    FIsOpened: Boolean;
    FIsVoided: Boolean;
    FPayment: Currency;
    FLines: TTntStrings;
    FRecType: Integer;

    procedure CheckNotVoided;
    procedure CheckAmount(Amount: Currency);
  public
    property Lines: TTntStrings read FLines;
    property RecType: Integer read FRecType;
  public
    constructor Create(ARecType: Integer);
    destructor Destroy; override;

    procedure BeginFiscalReceipt(PrintHeader: Boolean);

    procedure EndFiscalReceipt(APrintHeader: Boolean);

    procedure PrintRecCash(Amount: Currency);

    procedure PrintRecItem(const Description: WideString; Price: Currency;
      Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString);

    procedure PrintRecItemAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency;
      VatInfo: Integer);

    procedure PrintRecMessage(const Message: WideString);

    procedure PrintRecNotPaid(const Description: WideString;
      Amount: Currency);

    procedure PrintRecRefund(const Description: WideString; Amount: Currency;
      VatInfo: Integer); 

    procedure PrintRecSubtotal(Amount: Currency); 

    procedure PrintRecSubtotalAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency); 

    procedure PrintRecTotal(Total: Currency; Payment: Currency;
      const Description: WideString); 

    procedure PrintRecVoid(const Description: WideString); 

    procedure PrintRecVoidItem(const Description: WideString; Amount: Currency;
      Quantity: Double; AdjustmentType: Integer; Adjustment: Currency;
      VatInfo: Integer); 

    procedure PrintRecItemFuel(const Description: WideString; Price: Currency;
      Quantity: Double; VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString;
      SpecialTax: Currency; const SpecialTaxName: WideString); 

    procedure PrintRecItemFuelVoid(const Description: WideString;
      Price: Currency; VatInfo: Integer; SpecialTax: Currency); 

    procedure PrintRecPackageAdjustment(AdjustmentType: Integer;
      const Description, VatAdjustment: WideString); 

    procedure PrintRecPackageAdjustVoid(AdjustmentType: Integer;
      const VatAdjustment: WideString); 

    procedure PrintRecRefundVoid(const Description: WideString;
      Amount: Currency; VatInfo: Integer); 

    procedure PrintRecSubtotalAdjustVoid(AdjustmentType: Integer;
      Amount: Currency); 

    procedure PrintRecTaxID(const TaxID: WideString); 

    procedure PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency;
      VatInfo: Integer); 

    procedure PrintRecItemVoid(const Description: WideString;
      Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString); 

    procedure PrintRecItemRefund(
      const ADescription: WideString;
      Amount: Currency; Quantity: Double;
      VatInfo: Integer; UnitAmount: Currency;
      const AUnitName: WideString); 

    procedure PrintRecItemRefundVoid(
      const ADescription: WideString;
      Amount: Currency; Quantity: Double;
      VatInfo: Integer; UnitAmount: Currency;
      const AUnitName: WideString); 

    procedure PrintNormal(const Text: WideString; Station: Integer); 

    procedure DirectIO(Command: Integer; var pData: Integer; var pString: WideString); 

    procedure Print(AVisitor: TObject);
    procedure PrintBarcode(const Barcode: string);

    function GetTotal: Currency;
    function GetPayment: Currency;
  end;

implementation

uses
  DaisyFiscalPrinter;

procedure RaiseIllegalError;
begin
  RaiseOposException(OPOS_E_ILLEGAL, _('Receipt method is not supported'));
end;

{ TCashReceipt }

constructor TCashReceipt.Create(ARecType: Integer);
begin
  inherited Create;
  FRecType := ARecType;
  FLines := TTntStringlist.Create;
end;

destructor TCashReceipt.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TCashReceipt.CheckNotVoided;
begin
  if FIsVoided then
    raiseExtendedError(OPOS_EFPTR_WRONG_STATE, 'Receipt is voided');
end;

procedure TCashReceipt.CheckAmount(Amount: Currency);
begin
  if Amount < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Negative amount'));
end;

procedure TCashReceipt.PrintRecCash(Amount: Currency);
begin
  CheckNotVoided;
  FTotal := FTotal + Amount;
end;

procedure TCashReceipt.PrintRecVoid(const Description: WideString);
begin
  CheckNotVoided;
  FIsVoided := True;
end;

procedure TCashReceipt.PrintRecTotal(Total: Currency; Payment: Currency;
  const Description: WideString);
begin
  CheckNotVoided;
  CheckAmount(Total);
  CheckAmount(Payment);
  FPayment := FPayment + Payment;
end;

procedure TCashReceipt.PrintNormal(const Text: WideString;
  Station: Integer);
begin
  FLines.Add(Text);
end;

procedure TCashReceipt.PrintRecMessage(const Message: WideString);
begin
  FLines.Add(Message);
end;

procedure TCashReceipt.EndFiscalReceipt(APrintHeader: Boolean);
begin

end;

procedure TCashReceipt.Print(AVisitor: TObject);
begin
  if FIsVoided then Exit;
  TDaisyFiscalPrinter(AVisitor).Print(Self);
end;

function TCashReceipt.GetPayment: Currency;
begin
  Result := FPayment;
end;

function TCashReceipt.GetTotal: Currency;
begin
  Result := FTotal;
end;

procedure TCashReceipt.BeginFiscalReceipt(PrintHeader: Boolean);
begin
  if FIsOpened then
    raiseExtendedError(OPOS_EFPTR_WRONG_STATE, 'Receipt not opened');

  FIsOpened := True;
end;

procedure TCashReceipt.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString);
begin

end;

procedure TCashReceipt.PrintBarcode(const Barcode: string);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemAdjustmentVoid(
  AdjustmentType: Integer; const Description: WideString; Amount: Currency;
  VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemFuel(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString; SpecialTax: Currency;
  const SpecialTaxName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemFuelVoid(
  const Description: WideString; Price: Currency; VatInfo: Integer;
  SpecialTax: Currency);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemRefund(const ADescription: WideString;
  Amount: Currency; Quantity: Double; VatInfo: Integer;
  UnitAmount: Currency; const AUnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemRefundVoid(
  const ADescription: WideString; Amount: Currency; Quantity: Double;
  VatInfo: Integer; UnitAmount: Currency; const AUnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecItemVoid(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecNotPaid(const Description: WideString;
  Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecPackageAdjustment(AdjustmentType: Integer;
  const Description, VatAdjustment: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
  const VatAdjustment: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecRefund(const Description: WideString;
  Amount: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecRefundVoid(const Description: WideString;
  Amount: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecSubtotal(Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecSubtotalAdjustment(
  AdjustmentType: Integer; const Description: WideString;
  Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecSubtotalAdjustVoid(
  AdjustmentType: Integer; Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecTaxID(const TaxID: WideString);
begin
  RaiseIllegalError;
end;

procedure TCashReceipt.PrintRecVoidItem(const Description: WideString;
  Amount: Currency; Quantity: Double; AdjustmentType: Integer;
  Adjustment: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

end.
