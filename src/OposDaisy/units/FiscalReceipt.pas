unit FiscalReceipt;

interface

type
  { IFiscalreceipt }

  IFiscalreceipt = interface
  ['{BA38E27C-DCB2-4EB0-9AC8-AC56FA3ADA9E}']
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

end.
