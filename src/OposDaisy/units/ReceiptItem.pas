unit ReceiptItem;

interface

Uses
  // VCL
  Classes, SysUtils, Math,
  // This
  MathUtils, PrinterTypes;

type
  TReceiptItem = class;
  TBarcodeItem = class;

  { TReceiptItems }

  TReceiptItems = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TReceiptItem;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TReceiptItem;
    function GetTotal: Currency;

    procedure Clear;
    procedure InsertItem(AItem: TReceiptItem);
    procedure RemoveItem(AItem: TReceiptItem);
    procedure Insert(Index: Integer; AItem: TReceiptItem);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TReceiptItem read GetItem; default;
  end;

  { TReceiptItem }

  TReceiptItem = class
  private
    FOwner: TReceiptItems;
    procedure SetOwner(AOwner: TReceiptItems);
  public
    constructor Create(AOwner: TReceiptItems); virtual;
    destructor Destroy; override;
    function GetTotal: Currency; virtual;
  end;

  { TSalesItemRec }

  TSalesItemRec = record
    Price: Currency;
    VatInfo: Integer;
    Quantity: Double;
    UnitPrice: Currency;
    UnitName: WideString;
    Description: WideString;
  end;

  { TSalesItem }

  TSalesItem = class(TReceiptItem)
  private
    FData: TSalesItemRec;
    FAdjustment: Currency;
  public
    constructor CreateItem(AOwner: TReceiptItems; const AData: TSalesItemRec);
    function GetTotal: Currency; override;
    procedure Assign(Item: TSalesItem);

    property Total: Currency read GetTotal;
    property Data: TSalesItemRec read FData;
    property Price: Currency read FData.Price;
    property VatInfo: Integer read FData.VatInfo;
    property Quantity: Double read FData.Quantity;
    property UnitPrice: Currency read FData.UnitPrice;
    property UnitName: WideString read FData.UnitName;
    property Description: WideString read FData.Description;
    property Adjustment: Currency read FAdjustment write FAdjustment;
  end;

  { TTextItem }

  TTextItem = class(TReceiptItem)
  private
    FText: WideString;
  public
    property Text: WideString read FText write FText;
  end;

  { TBarcodeItem }

  TBarcodeItem = class(TReceiptItem)
  private
    FBarcode: string;
  public
    property Barcode: string read FBarcode write FBarcode;
  end;

implementation

{ TReceiptItems }

constructor TReceiptItems.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TReceiptItems.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TReceiptItems.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TReceiptItems.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TReceiptItems.GetItem(Index: Integer): TReceiptItem;
begin
  Result := FList[Index];
end;

procedure TReceiptItems.Insert(Index: Integer; AItem: TReceiptItem);
begin
  FList.Insert(Index, AItem);
  AItem.FOwner := Self;
end;

procedure TReceiptItems.InsertItem(AItem: TReceiptItem);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TReceiptItems.RemoveItem(AItem: TReceiptItem);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TReceiptItems.GetTotal: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
  begin
    Result := Result + Items[i].GetTotal;
  end;
end;

function TReceiptItems.Add: TReceiptItem;
begin
  Result := TReceiptItem.Create(Self);
end;

{ TReceiptItem }

constructor TReceiptItem.Create(AOwner: TReceiptItems);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TReceiptItem.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TReceiptItem.SetOwner(AOwner: TReceiptItems);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

function TReceiptItem.GetTotal: Currency;
begin
  Result := 0;
end;

{ TSalesItem }

constructor TSalesItem.CreateItem(AOwner: TReceiptItems; const AData: TSalesItemRec);
begin
  inherited Create(AOwner);
  FData := AData;
end;

function TSalesItem.GetTotal: Currency;
begin
  Result := Price + Adjustment;
end;

procedure TSalesItem.Assign(Item: TSalesItem);
var
  Src: TSalesItem;
begin
  if Item is TSalesItem then
  begin
    Src := Item as TSalesItem;

    FData := Src.Data;
    FAdjustment := Src.Adjustment;
  end;
end;

end.
