unit SalesReceipt;

interface

uses
  // VCL
  Windows, SysUtils, Forms, Controls, Classes, Messages, Math,
  // Opos
  Opos, OposFptrUtils, OposException, OposFptr, OposUtils,
  // Tnt
  TntClasses,
  // This
  FiscalReceipt, ReceiptItem, gnugettext, WException, MathUtils,
  PrinterTypes;

const
  MaxPayments = 4;

type
  TPayments = array [0..MaxPayments] of Currency;

  { TSalesReceipt }

  TSalesReceipt = class(TInterfacedObject, IFiscalReceipt)
  private
    FIsRefund: Boolean;
    FIsOpened: Boolean;
    FIsVoided: Boolean;
    FChange: Currency;
    FRecItems: TList;
    FPayments: TPayments;
    FItems: TReceiptItems;
    FDecimalPlaces: Integer;
    FAdjustmentPercent: Currency;
    FAdjustmentText: WideString;
    FLines: TTntStrings;
    function IsPayed: Boolean;
  protected
    procedure CheckNotVoided;
    procedure SetRefundReceipt;
    procedure CheckPrice(Value: Currency);
    procedure CheckAmount(Amount: Currency);
    procedure CheckPercents(Value: Currency);
    procedure CheckQuantity(Quantity: Double);
    procedure RecSubtotalAdjustment(const Description: WideString;
      AdjustmentType: Integer; Amount: Currency);

    function GetLastItem: TSalesItem;
    function AddItem(AData: TSalesItemRec): TSalesItem;
  public
    constructor CreateReceipt(ADecimalPlaces: Integer; AIsRefund: Boolean);
    destructor Destroy; override;

    function RoundAmount(Amount: Currency): Currency;

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
      const UnitName: WideString);

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

    property Lines: TTntStrings read FLines;
    property Change: Currency read FChange;
    property Items: TReceiptItems read FItems;
    property IsRefund: Boolean read FIsRefund;
    property Payments: TPayments read FPayments;
    property DecimalPlaces: Integer read FDecimalPlaces;
    property AdjustmentPercent: Currency read FAdjustmentPercent;
    property AdjustmentText: WideString read FAdjustmentText;
 end;

implementation

uses
  DaisyFiscalPrinter;

procedure RaiseIllegalError;
begin
  RaiseOposException(OPOS_E_ILLEGAL, _('Receipt method is not supported'));
end;

procedure CheckPercents(Amount: Currency);
begin
  if not((Amount >= 0)and(Amount <= 100)) then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Invalid percentage'));
end;

function GetVoidAdjustmentType(AdjustmentType: Integer): Integer;
begin
  Result := AdjustmentType;
  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT: Result := FPTR_AT_AMOUNT_SURCHARGE;
    FPTR_AT_AMOUNT_SURCHARGE: Result := FPTR_AT_AMOUNT_DISCOUNT;
    FPTR_AT_PERCENTAGE_DISCOUNT: Result := FPTR_AT_PERCENTAGE_SURCHARGE;
    FPTR_AT_PERCENTAGE_SURCHARGE: Result := FPTR_AT_PERCENTAGE_DISCOUNT;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

{ TSalesReceipt }

constructor TSalesReceipt.CreateReceipt(ADecimalPlaces: Integer; AIsRefund: Boolean);
begin
  inherited Create;
  FRecItems := TList.Create;
  FItems := TReceiptItems.Create;
  FLines := TTntStringList.Create;

  FDecimalPlaces := ADecimalPlaces;
  FIsRefund := AIsRefund;
end;

destructor TSalesReceipt.Destroy;
begin
  FLines.Free;
  FItems.Free;
  FRecItems.Free;
  inherited Destroy;
end;

procedure TSalesReceipt.CheckNotVoided;
begin
  if FIsVoided then
    raiseExtendedError(OPOS_EFPTR_WRONG_STATE, 'Receipt is voided');
end;

procedure TSalesReceipt.Print(AVisitor: TObject);
begin
  if FIsVoided then Exit;
  TDaisyFiscalPrinter(AVisitor).Print(Self);
end;

procedure TSalesReceipt.CheckAmount(Amount: Currency);
begin
  if Amount < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Negative amount'));
end;

function TSalesReceipt.GetLastItem: TSalesItem;
begin
  if FRecItems.Count = 0 then
    raiseException(_('Last receipt item not defined'));
  Result := TSalesItem(FRecItems[FRecItems.Count-1]);
end;

procedure TSalesReceipt.CheckPrice(Value: Currency);
begin
  if Value < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_PRICE, _('Negative price'));
end;

procedure TSalesReceipt.CheckPercents(Value: Currency);
begin
  if (Value < 0)or(Value > 9999) then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Invalid percents value'));
end;

procedure TSalesReceipt.CheckQuantity(Quantity: Double);
begin
  if Quantity < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_QUANTITY, _('Negative quantity'));
end;

procedure TSalesReceipt.PrintRecVoid(const Description: WideString);
begin
  FIsVoided := True;
end;

procedure TSalesReceipt.BeginFiscalReceipt(PrintHeader: Boolean);
begin
  FIsOpened := True;
end;

procedure TSalesReceipt.EndFiscalReceipt(APrintHeader: Boolean);
begin
  FIsOpened := False;
end;

function TSalesReceipt.AddItem(AData: TSalesItemRec): TSalesItem;
begin
  if AData.Quantity = 0 then
    AData.Quantity := 1;

  Result := TSalesItem.CreateItem(FItems, AData);
  FRecItems.Add(Result);
end;

procedure TSalesReceipt.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer;
  UnitPrice: Currency; const UnitName: WideString);
var
  Data: TSalesItemRec;
begin
  CheckNotVoided;
  CheckPrice(Price);
  CheckPrice(UnitPrice);
  CheckQuantity(Quantity);

  Data.Price := Price;
  Data.VatInfo := VatInfo;
  Data.Quantity := Quantity;
  Data.UnitName := UnitName;
  Data.UnitPrice := UnitPrice;
  Data.Description := Description;
  AddItem(Data);
end;

procedure TSalesReceipt.PrintRecItemVoid(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString);
var
  Data: TSalesItemRec;
begin
  CheckNotVoided;
  CheckPrice(Price);
  CheckPrice(UnitPrice);
  CheckQuantity(Quantity);

  Data.Price := Price;
  Data.VatInfo := VatInfo;
  Data.Quantity := Quantity;
  Data.UnitName := UnitName;
  Data.UnitPrice := UnitPrice;
  Data.Description := Description;
  AddItem(Data);
end;

procedure TSalesReceipt.PrintRecItemRefund(const ADescription: WideString;
  Amount: Currency; Quantity: Double; VatInfo: Integer;
  UnitAmount: Currency; const UnitName: WideString);
var
  Data: TSalesItemRec;
begin
  CheckNotVoided;
  CheckPrice(Amount);
  CheckPrice(UnitAmount);
  CheckQuantity(Quantity);
  SetRefundReceipt;

  Data.Price := -Amount;
  Data.VatInfo := VatInfo;
  Data.Quantity := Quantity;
  Data.UnitName := UnitName;
  Data.UnitPrice := UnitAmount;
  Data.Description := ADescription;
  AddItem(Data);
end;

procedure TSalesReceipt.PrintRecVoidItem(const Description: WideString;
  Amount: Currency; Quantity: Double; AdjustmentType: Integer;
  Adjustment: Currency; VatInfo: Integer);
var
  Data: TSalesItemRec;
begin
  CheckNotVoided;
  CheckPrice(Amount);
  CheckQuantity(Quantity);

  Data.Price := Amount;
  Data.Quantity := -Quantity;
  Data.VatInfo := VatInfo;
  Data.Description := Description;
  Data.UnitName := '';
  Data.UnitPrice := 0;
  AddItem(Data);
end;

procedure TSalesReceipt.PrintRecItemRefundVoid(
  const ADescription: WideString; Amount: Currency; Quantity: Double;
  VatInfo: Integer; UnitAmount: Currency; const AUnitName: WideString);
begin
  CheckNotVoided;
  SetRefundReceipt;

  PrintRecItemRefund(ADescription, Amount, Quantity, VatInfo, UnitAmount,
    AUnitName);
end;

procedure TSalesReceipt.PrintRecItemAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency; VatInfo: Integer);
var
  Item: TSalesItem;
  AdjustmentAmount: Currency;
begin
  CheckNotVoided;
  Item := GetLastItem;
  Item.AdjustmentText := '';
  if Item.Adjustment = 0 then
  begin
    Item.AdjustmentText := Description;
  end;

  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT:
    begin
      Item.Adjustment := Item.Adjustment - Amount;
    end;

    FPTR_AT_AMOUNT_SURCHARGE:
    begin
      Item.Adjustment := Item.Adjustment + Amount;
    end;
    FPTR_AT_PERCENTAGE_DISCOUNT:
    begin
      CheckPercents(Amount);
      AdjustmentAmount := RoundAmount(Item.Price * Amount/100);
      Item.Adjustment := Item.Adjustment - AdjustmentAmount;
    end;

    FPTR_AT_PERCENTAGE_SURCHARGE:
    begin
      CheckPercents(Amount);
      AdjustmentAmount := RoundAmount(Item.Price * Amount/100);
      Item.Adjustment := Item.Adjustment + AdjustmentAmount;
    end;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

procedure TSalesReceipt.PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency;
  VatInfo: Integer);
begin
  AdjustmentType := GetVoidAdjustmentType(AdjustmentType);
  PrintRecItemAdjustment(AdjustmentType, Description, Amount, VatInfo);
end;


procedure TSalesReceipt.PrintRecPackageAdjustment(
  AdjustmentType: Integer;
  const Description, VatAdjustment: WideString);
begin
  CheckNotVoided;
end;

procedure TSalesReceipt.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
  const VatAdjustment: WideString);
begin
  CheckNotVoided;
end;

procedure TSalesReceipt.SetRefundReceipt;
begin
  if FRecItems.Count = 0 then
    FIsRefund := True;
end;


procedure TSalesReceipt.PrintRecRefund(const Description: WideString;
  Amount: Currency; VatInfo: Integer);
var
  Data: TSalesItemRec;
begin
  CheckNotVoided;
  CheckAmount(Amount);
  SetRefundReceipt;

  Data.Quantity := 1;
  Data.Price := -Amount;
  Data.UnitPrice := Amount;
  Data.VatInfo := VatInfo;
  Data.Description := Description;
  Data.UnitName := '';
  AddItem(Data);
end;

procedure TSalesReceipt.PrintRecRefundVoid(
  const Description: WideString;
  Amount: Currency; VatInfo: Integer);
var
  Data: TSalesItemRec;
begin
  CheckNotVoided;
  CheckAmount(Amount);
  SetRefundReceipt;

  Data.Quantity := 1;
  Data.Price := -Amount;
  Data.UnitPrice := Amount;
  Data.VatInfo := VatInfo;
  Data.Description := Description;
  Data.UnitName := '';
  AddItem(Data);
end;

procedure TSalesReceipt.PrintRecSubtotal(Amount: Currency);
begin
  CheckNotVoided;
end;

procedure TSalesReceipt.PrintRecSubtotalAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency);
begin
  CheckNotVoided;
  RecSubtotalAdjustment(Description, AdjustmentType, Amount);
end;

procedure TSalesReceipt.RecSubtotalAdjustment(const Description: WideString;
  AdjustmentType: Integer; Amount: Currency);
begin
  CheckNotVoided;
  if FAdjustmentPercent <> 0 then
    RaiseOposException(OPOS_E_ILLEGAL, 'Subtotal adjustment already defined');

  FAdjustmentText := Description;

  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT,
    FPTR_AT_AMOUNT_SURCHARGE:
    begin
      RaiseOposException(OPOS_E_ILLEGAL, 'Receipt amount adjustments not supported');
    end;

    FPTR_AT_PERCENTAGE_DISCOUNT:
    begin
      CheckPercents(Amount);
      FAdjustmentPercent := -Amount;
    end;

    FPTR_AT_PERCENTAGE_SURCHARGE:
    begin
      CheckPercents(Amount);
      FAdjustmentPercent := Amount;
    end;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

function TSalesReceipt.RoundAmount(Amount: Currency): Currency;
var
  K: Integer;
begin
  K := Round(Power(10, DecimalPlaces));
  Result := Round2(Amount * K) / K;
end;

function TSalesReceipt.GetTotal: Currency;
var
  i: Integer;
  Item: TSalesItem;
begin
  Result := 0;
  for i := 0 to FRecItems.Count-1 do
  begin
    Item := TSalesItem(FRecItems[i]);
    Result := Result + RoundAmount(Item.GetTotal);
  end;
  Result := Result + (Result * FAdjustmentPercent/100);
end;

function TSalesReceipt.GetPayment: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(FPayments) to High(FPayments) do
  begin
    Result := Result + FPayments[i];
  end;
end;

procedure TSalesReceipt.PrintRecSubtotalAdjustVoid(
  AdjustmentType: Integer; Amount: Currency);
begin
  CheckNotVoided;
  AdjustmentType := GetVoidAdjustmentType(AdjustmentType);
  RecSubtotalAdjustment('', AdjustmentType, Amount);
end;

procedure TSalesReceipt.PrintRecTotal(Total: Currency; Payment: Currency;
  const Description: WideString);
var
  Index: Integer;
begin
  CheckNotVoided;
  CheckAmount(Total);
  CheckAmount(Payment);

  Index := StrToIntDef(Description, 0);
  FPayments[Index] := FPayments[Index] + Payment;
  if IsPayed then
  begin
    FChange := GetPayment - GetTotal;
  end;
end;

function TSalesReceipt.IsPayed: Boolean;
begin
  Result := GetPayment >= GetTotal;
end;

procedure TSalesReceipt.PrintRecMessage(const Message: WideString);
var
  Item: TTextItem;
begin
  if (FRecItems.Count > 0) and IsPayed then
  begin
    Lines.Add(Message);
  end else
  begin
    Item := TTextItem.Create(FItems);
    Item.Text := Message;
  end;
end;

procedure TSalesReceipt.PrintBarcode(const Barcode: string);
var
  Item: TBarcodeItem;
begin
  Item := TBarcodeItem.Create(Items);
  Item.Barcode := Barcode;
end;

procedure TSalesReceipt.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString);
begin

end;

procedure TSalesReceipt.PrintNormal(const Text: WideString;
  Station: Integer);
begin

end;

procedure TSalesReceipt.PrintRecCash(Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TSalesReceipt.PrintRecItemFuel(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString; SpecialTax: Currency;
  const SpecialTaxName: WideString);
begin
  RaiseIllegalError;
end;

procedure TSalesReceipt.PrintRecItemFuelVoid(const Description: WideString;
  Price: Currency; VatInfo: Integer; SpecialTax: Currency);
begin
  RaiseIllegalError;
end;

procedure TSalesReceipt.PrintRecNotPaid(const Description: WideString;
  Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TSalesReceipt.PrintRecTaxID(const TaxID: WideString);
begin
  RaiseIllegalError;
end;

end.
