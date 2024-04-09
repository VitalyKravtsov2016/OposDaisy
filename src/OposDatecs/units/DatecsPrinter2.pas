unit DatecsPrinter2;

interface

uses
  // VCL
  SysUtils, DateUtils,
  // This
  PrinterPort, LogFile, DriverError, StringUtils, ByteUtils;

const
  LF = #10;
  TAB = #$09;
  CRLF = #13#10;
  BoolToStr: array [Boolean] of WideString = ('0', '1');

  /////////////////////////////////////////////////////////////////////////////
  // Data type constants

  DataTypeTotal = 0;
  DataTypeNet   = 1;

  /////////////////////////////////////////////////////////////////////////////
  // Paid code constants

  PaidCodeError             = 1;
  PaidCodeTaxNegative       = 2;
  PaidCodeSumLessTotal      = 3;
  PaidCodeSumGreaterTotal   = 4;
  PaidCodeNegativeSubtotal  = 5;

  /////////////////////////////////////////////////////////////////////////////
  // Payment mode constants

  PaymentModeCash = 1;
  PaymentMode1    = 2;
  PaymentMode2    = 3;
  PaymentMode3    = 4;
  PaymentMode4    = 5;

  PaymentModeMin = 1;
  PaymentModeMax = 5;


  MaxTax = 5;

  /////////////////////////////////////////////////////////////////////////////
  // CutMode constants

  CutModeFull     = 1;
  CutModePartial  = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Encoding constants

  EncodingNone      = 0;
  EncodingAuto      = 1;
  EncodingSelected  = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Error constants

  ENoError              = 0;  // Нет ошибок
  EDateTimeNotSet       = 10; // Дата и время не установлены
  EDisplayDisconnected  = 11; // Индикатор клиента не подключен
  EInvalidCommandCode   = 37; // Код полученной команды неверен
  EPrinterError         = 38; // Ошибка принтера
  ESumsOverflow         = 39; // Переполнение операции суммирования
  EInvalidCommandInMode = 40; // Команда не разрешена для текущего режима
  ERecJrnStationEmpty   = 12; // Закончилась чековая или контрольная лента


  DATECS_E_FAILURE      = -2;
  DATECS_E_NOHARDWARE   = -3;
  DATECS_E_CRC          = -4;

  /////////////////////////////////////////////////////////////////////////////
  // Error messages

  SEmptyData: WideString = 'Пустые данные для передачи';
  SNoHardware: WideString = 'Нет связи с ФР';
  SInvalidAnswerCode: WideString = 'Неверный код ответа';
  SInvalidCrc: WideString = 'Неверный CRC';

  SErrorOK: WideString = 'Операция выполнена успешно';
  SInvalidParams: WideString = 'Неверные параметры функции';
  SError1	= 'Невозможно открыть COM порт';
  SError2	= 'Ошибка настройки буферов COM порта';
  SError3	= 'Ошибка настройки маски COM порта';
  SError4	= 'Невозможно получить состояние COM порта';
  SError5	= 'Неверная скорость СОМ порта,  будет установлена 19200 бод';
  SError6	= 'Невозможно установить таймауты COM порта';
  SError7	= 'Ошибка установки связи с фискальным регистратором';
  SError8	= 'Отсутствует лицензия на данный фискальный регистратор';
  SError10: WideString = 'Дата и время не установлены';
  SError11: WideString = 'Индикатор клиента (дисплей покупателя) не подключен';
  SError12: WideString = 'Закончилась чековая или контрольная лента';
  SError13: WideString = 'Ошибка фискализации. Таблица налоговых номеров исчерпана';
  SError14: WideString = 'Ошибка фискализации. Не задан фискальный номер';
  SError15: WideString = 'Ошибка фискализации. Неверен заводской номер или другие данные';
  SError16: WideString = 'Ошибка фискализации. Открыт чек';
  SError17: WideString = 'Ошибка фискализации. Не обнулены суммы за день. Сделайте Z-отчет';
  SError18: WideString = 'Ошибка фискализации. Не заданы налоговые ставки';
  SError19: WideString = 'Ошибка фискализации. Налоговый номер состоит из нулей';
  SError20: WideString = 'Ошибка фискализации. Отсутствует чековая или контрольная лента';
  SError21: WideString = 'Ошибка фискализации. Дата и время не установлены';
  SError22: WideString = 'Ошибка установки заводского номера:' + LF +
    'Неформатирована фискальная память' + LF +
    'Заводской номер уже задан' + LF +
    'Дата/время не установлены';

  SError23	= 'Ошибка установки фискального номера:' + LF +
    'Заводской номер не задан' + LF +
    'Дата/время не установлены' + LF +
    'Открыт чек' + LF +
    'Необходимо сделать Z-отчет';

  SError24: WideString = 'Ошибка установки налогового/идентификационного номера';
  SError25: WideString = 'Ошибка открытия нефискального чека. Фискальная память неформатирована';
  SError26: WideString = 'Ошибка открытия нефискального чека. Открыт фискальный чека';
  SError27: WideString = 'Ошибка открытия нефискального чека. Нефискальный чек уже открыт';
  SError28: WideString = 'Ошибка открытия нефискального чека. Дата и время не установлены';
  SError29: WideString = 'Ошибка выполнения итога чека.';
  SError30: WideString = 'Ошибка выполнения итога чека. ' + LF +
    'Вычисленная сумма отрицательная.' + LF +
    'Оплата не совершается';

  SError31: WideString = 'Сумма оплаты меньше суммы чека (Информационное сообщение)';
  SError32: WideString = 'Сумма оплаты больше суммы чека (Информационное сообщение)';

  SError33: WideString = 'Ошибка выполнения итога чека. ' + LF +
    'Сумма по некоторой налоговой группе отрицательна.';

  SError34: WideString = 'Ошибка программирования/чтения/удаления артикула.';
  SError35: WideString = 'Ошибка выполнения операции служебного ввода/вывода.';
  SError36: WideString = 'Синтаксическая ошибка в команде';
  SError37: WideString = 'Код полученной команды неверен.';
  SError38: WideString = 'Механизм печатающего устройства неисправен.';
  SError39: WideString = 'Переполнение операции суммирования.';
  SError40: WideString = 'Команда не разрешена для текущего фискального режима принтера.';

  SError100: WideString = 'Фискальный регистратор не отвечает.';

  SMaxSynCount: WideString = 'Устройство занято';
  SInvalidParamValue: WideString = 'Неверное значение параметра "%s"';
  SInvalidPasswordLength: WideString = 'Длина пароля должна быть больше или равна 4';
  SInvalidCodeValue: WideString = 'Неверное значение кода';

  /////////////////////////////////////////////////////////////////////////////
  // ReportType constants

  ReportTypeZ               = 0;
  ReportTypeX               = 2;
  ReportTypeEJ              = 5;
  ReportTypeZNotPrint       = 6;
  ReportTypeZByDepartments  = 8;
  ReportTypeXByDepartments  = 9;

type
  { TDiagnosticInfo }

  TDiagnosticInfo = record
    ResultCode: Integer;
    FirmwareVersion: AnsiString;
    FirmwareDate: AnsiString;
    FirmwareTime: AnsiString;
    ChekSum: AnsiString;
    Switches: Integer;
    Country: Byte;
    FDSerial: AnsiString;
    FDNo: AnsiString;
  end;

  { TFDTotals }

  TFDTotals = record
    ResultCode: Integer;
    SalesTotalTaxFree: Int64; // SpaceGr Session Non-Taxable sales Total
    SalesTotalTax: array [1..5] of Int64; // Sales totals by tax
  end;

  { TFDFiscalRecord }

  TFDFiscalRecord = record
    ResultCode: Integer;
    Number: Integer;          // Number of the last fiscal record.
    SalesTotalTaxFree: Int64; // SpaceGr Session Non-Taxable sales Total
    SalesTotalTax: array [1..5] of Int64; // Sales totals by tax
    Date: TDateTime; // Date of the last fiscal record
  end;

  { TFDFiscalRecords }

  TFDFiscalRecords = record
    ResultCode: Integer;
    LogicalNumber: Integer;
    PhysicalNumber: Integer;
  end;

  { TDateTimeResponse }

  TDateTimeResponse = record
    ResultCode: Integer;
    Date: TDateTime;
  end;

  { TFDPLU }

  TFDPLU = record
    Sign: AnsiChar;
    PLU: AnsiString;
    Quantity: Int64;
    Price: Int64;
    DiscountPercent: Double;
    DiscountAmount: Int64;
  end;

  { TFDTotal }

  TFDTotal = record
    Text1: WideString;
    Text2: WideString;
    PaymentMode: Integer;
    Amount: Int64;
  end;

  { TFDTotalResponse }

  TFDTotalResponse = record
    ResultCode: Integer;
    PaidCode: Integer;
    Amount: Int64;
  end;

  { TFDSubtotal }

  TFDSubtotal = record
    PrintSubtotal: Boolean;
    DisplaySubtotal: Boolean;
    SubtotalPercent: Double;
  end;

  { TFDSubtotalResponse }

  TFDSubtotalResponse = record
    ResultCode: Integer;
    SubTotal: Int64;
    SalesTaxFree: Int64;
    TaxTotals: array [1..MaxTax] of Int64;
  end;

  { TFDTaxRates }

  TFDTaxRates = record
    ResultCode: Integer;
    DataFound: Boolean;
    VATRate: array [1..5] of Integer;
    Date: TDateTime;
  end;

  { TFDSale }

  TFDSale = record
    Text1: WideString;
    Text2: WideString;
    Tax: Byte;
    Price: Int64;
    Quantity: Int64;
    DiscountPercent: Integer;
    DiscountAmount: Integer;
  end;

  { TFDStartRec }

  TFDStartRec = record
    Operator: Byte;
    Password: AnsiString;
  end;

  { TFDReceiptNumber }

  TFDReceiptNumber = record
    ResultCode: Integer;
    DocNumber: Integer;
    FDNumber: Integer;
  end;

  { TReceiptNumberRec }

  TReceiptNumberRec = record
    ResultCode: Integer;
    ReceiptNumber: Int64;
  end;

  { TFDReportAnswer }

  TFDReportAnswer = record
    ResultCode: Integer;
    ReportNumber: Integer;
    SalesTotalNoTax: Int64;
    SalesTotalTax: array [1..5] of Int64;
  end;

  { TDatecsCommand }

  TDatecsCommand = record
    Sequence: Byte;
    Code: Byte;
    Data: AnsiString;
  end;

  { TDatecsAnswer }

  TDatecsAnswer = record
    Sequence: Byte;
    Code: Byte;
    Data: WideString;
    Status: AnsiString;
  end;

  { TDatecsFrame }

  TDatecsFrame = class
  public
    class function GetCrc(const Data: AnsiString): AnsiString;
    class function EncodeAnswer(const Data: TDatecsAnswer): AnsiString;
    class function EncodeCommand(const Data: TDatecsCommand): AnsiString;
    class function DecodeAnswer(const Data: AnsiString): TDatecsAnswer;
    class function DecodeCommand(const Data: AnsiString): TDatecsCommand;
    class function DecodeCommand2(const Data: AnsiString;
      var Command: TDatecsCommand): Boolean;
  end;

  { TDatecsStatus }

  TDatecsStatus = record
    Data: string;
    // Byte 0
    GeneralError: Boolean;
    PrinterError: Boolean;
    DisplayDisconnected: Boolean;
    ClockNotSet: Boolean;
    InvalidCommandCode: Boolean;
    InvalidDataSyntax: Boolean;
    // Byte 1
    WrongPassword: Boolean;
    CutterError: Boolean;
    MemoryCleared: Boolean;
    InvalidCommandInMode: Boolean;
    SumsOverflow: Boolean;
    // Byte 2
    NonfiscalRecOpened: Boolean;
    JournalPaperNearEnd: Boolean;
    FiscalRecOpened: Boolean;
    JournalPaperEmpty: Boolean;
    ReceiptPaperNearEnd: Boolean;
    RecJrnPaperNearEnd: Boolean;
    RecJrnStationEmpty: Boolean;


    JrnSmallFont: Boolean; // 3.6, уменьшенный шрифт на контрольной ленте
    DisplayCP866: Boolean; // 3.5, кодовая таблица дисплея (Windows 1251)
    PrinterCP866: Boolean; // 3.4, кодовая страница притера DOS/Windows 1251
    TransparentDisplay: Boolean; // 3.3, режим "прозрачный дисплей"
    AutoCut: Boolean; // 3.2, автоматическая обрезка чека
    BaudRate: Integer; // 3.0-3.1, скорость последовательного порта

    FMError: Boolean; // 4.5
    FMOverflow: Boolean; // 4.4, Фискальная память переполнена
    FM50Zreports: Boolean; // 4.3, В фискальной памяти есть место по крайней мере для 50 Z-отчетов
    FMMissing: Boolean; // 4.2, Нет модуля фискальной памяти
    FMWriteError: Boolean; // 4.0, Возникла ошибка при записи в фискальную память

    SerialNumber: Boolean; // 5.5, Фискальный и заводской номер запрограммированы
    TaxRatesSet: Boolean; // 5.4, Налоговые ставки определены
    Fiscalized: Boolean; // 5.3, Устройство фискализировано
    FMFormatted: Boolean; // 5.1, Фискальная память сформатирована
    FMReadOnly: Boolean; // 5.0, Фискальная память установлена в режим Read Only.
  end;

  { TDatecsPrinter }

  TDatecsPrinter = class
  private
    FTxData: string;
    FRxData: string;
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FAnswer: TDatecsAnswer;
    FCommand: TDatecsCommand;
    FStatus: TDatecsStatus;
    FLastError: Integer;
    FLastErrorText: WideString;
    FPrinterEncoding: Integer;
    FDisplayEncoding: Integer;
    FPrinterCodePage: Integer;
    FDisplayCodePage: Integer;
    FPassword: WideString;

    function CheckStatus: Integer;
    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    function DecodePrinterText(const Text: AnsiString): WideString;
    function GetDisplayCodePage: Integer;
    function GetPrinterCodePage: Integer;

    function GetParam(i: Integer): string;
    function Send(const TxData: WideString): Integer; overload;
    function Send(const TxData: WideString; var RxData: string): Integer; overload;
    procedure SendCommand(const Tx: WideString; var RxData: string);
    function EncodeDisplayText(const Text: WideString): AnsiString;
    function EncodePrinterText(const Text: WideString): AnsiString;
    function SaleCommand(Cmd: Char; const P: TFDSale): Integer;

  public
    TxCount: Integer;

    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;

    procedure Check(Code: Integer);
    function XReport: TFDReportAnswer;
    function ZReport: TFDReportAnswer;
    function ClearExternalDisplay: Integer;
    function FullCut: Integer;
    function PartialCut: Integer;
    function WaitWhilePrintEnd: Integer;
    function Succeeded(ResultCode: Integer): Boolean;
    function DisplayText(const Text: WideString): Integer;
    function StartNonfiscalReceipt: TReceiptNumberRec;
    function EndNonfiscalReceipt: TReceiptNumberRec;
    function PrintNonfiscalText(const Text: WideString): Integer;
    function PaperFeed(LineCount: Integer): Integer;
    function PaperCut(CutMode: Integer): Integer;
    function StartFiscalReceipt(const P: TFDStartRec): TFDReceiptNumber;
    function Sale(const P: TFDSale): Integer;
    function SaleAndDisplay(const P: TFDSale): Integer;
    function ReadTaxRates(const StartDate, EndDate: TDateTime): TFDTaxRates;
    function Subtotal(const P: TFDSubtotal): TFDSubtotalResponse;
    function PrintTotal(const P: TFDTotal): TFDTotalResponse;
    function PrintFiscalText(const Text: WideString): Integer;
    function EndFiscalReceipt: TFDReceiptNumber;
    function SaleByPLU(const P: TFDPLU): Integer;
    function WriteDateTime(Date: TDateTime): Integer;
    function ReadDateTime: TDateTimeResponse;
    function DisplayDateTime: Integer;
    function FinalFiscalRecord(DataType: AnsiChar): TFDFiscalRecord;
    function ReadTotals(DataType: Integer): TFDTotals;
    function ReadFreeFiscalRecords: TFDFiscalrecords;
    function PrintDiagnosticInfo: Integer;
    function PrintReportByNumbers(StartNum, EndNum: Integer): Integer;
    function ReadFDStatus: Integer;
    function GetDiagnosticInfo(CalcCRC: Boolean): TDiagnosticInfo;

    property Port: IPrinterPort read FPort;
    property Logger: ILogFile read FLogger;
    property Status: TDatecsStatus read FStatus;
    property Password: WideString read FPassword write FPassword;
    property PrinterCodePage: Integer read FPrinterCodePage write FPrinterCodePage;
    property DisplayCodePage: Integer read FDisplayCodePage write FDisplayCodePage;
    property PrinterEncoding: Integer read FPrinterEncoding write FPrinterEncoding;
    property DisplayEncoding: Integer read FDisplayEncoding write FDisplayEncoding;
  end;


function GetCommandName(Code: Integer): WideString;
function GetErrorText(Code: Integer): WideString;

implementation

function GetErrorText(Code: Integer): WideString;
begin
  case Code of
    0: Result := SErrorOK;
    -1: Result := SInvalidParams;
    1: Result := SError1;
    2: Result := SError2;
    3: Result := SError3;
    4: Result := SError4;
    5: Result := SError5;
    6: Result := SError6;
    7: Result := SError7;
    8: Result := SError8;
    10: Result := SError10;
    11: Result := SError11;
    12: Result := SError12;
    13: Result := SError13;
    14: Result := SError14;
    15: Result := SError15;
    16: Result := SError16;
    17: Result := SError17;
    18: Result := SError18;
    19: Result := SError19;
    20: Result := SError20;
    21: Result := SError21;
    22: Result := SError22;
    23: Result := SError23;
    24: Result := SError24;
    25: Result := SError25;
    26: Result := SError26;
    27: Result := SError27;
    28: Result := SError28;
    29: Result := SError29;
    30: Result := SError30;
    31: Result := SError31;
    32: Result := SError32;
    33: Result := SError33;
    34: Result := SError34;
    35: Result := SError35;
    36: Result := SError36;
    37: Result := SError37;
    38: Result := SError38;
    39: Result := SError39;
    40: Result := SError40;
    100: Result := SError100;
  else
    Result := '';
  end;
end;

const
  SCommand_29H: WideString = 'Запись текущих настроек в энергонезависимую флеш-память';
  SCommand_2BH: WideString = 'Установка HEADER и FOOTER и параметров печати';
  SCommand_3DH: WideString = 'Установка даты и времени';
  SCommand_48H: WideString = 'Фискализация';
  SCommand_53H: WideString = 'Установка десятичной точки и налоговых ставок';
  SCommand_54H: WideString = 'Установка режима продаж (начислен ДДС)';
  SCommand_57H: WideString = 'Программирование дополнительных типов оплаты';
  SCommand_5BH: WideString = 'Программирование серийного номера и номера страны';
  SCommand_5CH: WideString = 'Программирование номера фискалной памяти.';
  SCommand_62H: WideString = 'Установка ИНН';
  SCommand_65H: WideString = 'Запись пароля оператора';
  SCommand_66H: WideString = 'Запись имени оператора';
  SCommand_68H: WideString = 'Сброс данных оператора';
  SCommand_6BH: WideString = 'Определение и отчет по товарам';
  SCommand_73H: WideString = 'Загрузка графического логотипа';
  SCommand_76H: WideString = 'Запись пароля администратора';
  SCommand_77H: WideString = 'Сброс пароля оператора';
  SCommand_26H: WideString = 'Открыть нефискальный чек';
  SCommand_27H: WideString = 'Закрыть нефискальный чек';
  SCommand_2AH: WideString = 'Печать нефискального свободного текста';
  SCommand_30H: WideString = 'Открыть фискальный чек';
  SCommand_33H: WideString = 'Итоги (скидок и надбавок)';
  SCommand_34H: WideString = 'Регистрация купли-продажи и дисплей';
  SCommand_35H: WideString = 'Расчет суммы (оплаты)';
  SCommand_36H: WideString = 'Печать фискального свободного текста';
  SCommand_37H: WideString = 'и закрытие чека';
  SCommand_38H: WideString = 'Закрытие кассового чека.';
  SCommand_39H: WideString = 'Отмена или изменение фискального чека';
  SCommand_3AH: WideString = 'Регистрация продажа товара';
  SCommand_3BH: WideString = 'Скидки / надбавки или налог на товарную группу';
  SCommand_55H: WideString = 'Открытие чека возврата';
  SCommand_58H: WideString = 'Печать штрихкода';
  SCommand_5DH: WideString = 'Печать разделителной линии';
  SCommand_6DH: WideString = 'Печат копии чека';
  SCommand_45H: WideString = 'Ежедневный фискальный отчет (с гашением или без)';
  SCommand_32H: WideString = 'Отчет об изменениях в налоговых ставках и десятичной точке в соответствующем периоде';
  SCommand_49H: WideString = 'Подробный отчет из фискальной памяти (по номерам смен)';
  SCommand_5EH: WideString = 'Подробный отчет из фискальной памяти (по датам)';
  SCommand_4FH: WideString = 'Сокращенный отчет из фискальной памяти (по датам)';
  SCommand_5FH: WideString = 'Сокращенный отчет из фискальной памяти (по номерам смен)';
  SCommand_69H: WideString = 'Отчет по операторам';
  SCommand_6FH: WideString = 'Отчет по товарам';
  SCommand_2EH: WideString = 'Получить продолжительность текущей смены';
  SCommand_3EH: WideString = 'Чтение даты и времени';
  SCommand_40H: WideString = 'Информация последней фискальной записи';
  SCommand_41H: WideString = 'Информация начисленных сумм за день';
  SCommand_43H: WideString = 'Информация о накопленной суммы корректировок';
  SCommand_44H: WideString = 'Количество свободных записей в фискальной памяти';
  SCommand_4AH: WideString = 'Получить байт состояния';
  SCommand_4CH: WideString = 'Состояние фискалной операции';
  SCommand_56H: WideString = 'Получить дату последней фискальной записи';
  SCommand_5AH: WideString = 'Получение диагностической информации';
  SCommand_61H: WideString = 'Получение налоговых ставок';
  SCommand_63H: WideString = 'Получение налогового номера';
  SCommand_67H: WideString = 'Информация о текущем чеке';
  SCommand_6EH: WideString = 'Получение информации о суммах оплаты по типам';
  SCommand_70H: WideString = 'Получение информации о операторе';
  SCommand_71H: WideString = 'Получение номера последнего отпечатаннного документа';
  SCommand_72H: WideString = 'Получение информации о фискальных записях за период';
  SCommand_2CH: WideString = 'Промотка бумаги';
  SCommand_2DH: WideString = 'Отрезка бумаги';
  SCommand_21H: WideString = 'Очистить дисплей';
  SCommand_23H: WideString = 'Вывести текст (нижний ряд)';
  SCommand_2FH: WideString = 'Вывести текст (верхний ряд)';
  SCommand_3FH: WideString = 'Показать дату и время';
  SCommand_64H: WideString = 'Дисплей - управление';
  SCommand_46H: WideString = 'Внесение и выплата денежных средств.';
  SCommand_47H: WideString = 'Печать диагностической информации';
  SCommand_50H: WideString = 'Звуковой сигнал';
  SCommand_59H: WideString = 'Программирование производственные площади теста';
  SCommand_6AH: WideString = 'Открыть ящик';
  SCommand_7AH: WideString = 'Запрос состояния модема';
  SCommand_80H: WideString = 'Сервисное обнуление RAM';
  SCommand_81H: WideString = 'Сервисное стирание фискалной памяти';
  SCommand_83H: WideString = 'Сервисное форматирование фискалной памяти';
  SCommand_84H: WideString = 'Читать блок прошивки (память программ)';
  SCommand_85H: WideString = 'Временный запрет печати';
  SCommand_86H: WideString = 'Блокировка записи с неправильной контрольной суммой.';
  SCommand_87H: WideString = 'Сервисная запись в фискальную память';
  SCommand_Unknown: WideString = 'Неизвестная команда';

function GetCommandName(Code: Integer): WideString;
begin
  case Code of
    $29: Result := SCommand_29H;
    $2B: Result := SCommand_2BH;
    $3D: Result := SCommand_3DH;
    $48: Result := SCommand_48H;
    $53: Result := SCommand_53H;
    $54: Result := SCommand_54H;
    $57: Result := SCommand_57H;
    $5B: Result := SCommand_5BH;
    $5C: Result := SCommand_5CH;
    $62: Result := SCommand_62H;
    $65: Result := SCommand_65H;
    $66: Result := SCommand_66H;
    $68: Result := SCommand_68H;
    $6B: Result := SCommand_6BH;
    $73: Result := SCommand_73H;
    $76: Result := SCommand_76H;
    $77: Result := SCommand_77H;
    $26: Result := SCommand_26H;
    $27: Result := SCommand_27H;
    $2A: Result := SCommand_2AH;
    $30: Result := SCommand_30H;
    $33: Result := SCommand_33H;
    $34: Result := SCommand_34H;
    $35: Result := SCommand_35H;
    $36: Result := SCommand_36H;
    $37: Result := SCommand_37H;
    $38: Result := SCommand_38H;
    $39: Result := SCommand_39H;
    $3A: Result := SCommand_3AH;
    $3B: Result := SCommand_3BH;
    $55: Result := SCommand_55H;
    $58: Result := SCommand_58H;
    $5D: Result := SCommand_5DH;
    $6D: Result := SCommand_6DH;
    $45: Result := SCommand_45H;
    $32: Result := SCommand_32H;
    $49: Result := SCommand_49H;
    $5E: Result := SCommand_5EH;
    $4F: Result := SCommand_4FH;
    $5F: Result := SCommand_5FH;
    $69: Result := SCommand_69H;
    $6F: Result := SCommand_6FH;
    $2E: Result := SCommand_2EH;
    $3E: Result := SCommand_3EH;
    $40: Result := SCommand_40H;
    $41: Result := SCommand_41H;
    $43: Result := SCommand_43H;
    $44: Result := SCommand_44H;
    $4A: Result := SCommand_4AH;
    $4C: Result := SCommand_4CH;
    $56: Result := SCommand_56H;
    $5A: Result := SCommand_5AH;
    $61: Result := SCommand_61H;
    $63: Result := SCommand_63H;
    $67: Result := SCommand_67H;
    $6E: Result := SCommand_6EH;
    $70: Result := SCommand_70H;
    $71: Result := SCommand_71H;
    $72: Result := SCommand_72H;
    $2C: Result := SCommand_2CH;
    $2D: Result := SCommand_2DH;
    $21: Result := SCommand_21H;
    $23: Result := SCommand_23H;
    $2F: Result := SCommand_2FH;
    $3F: Result := SCommand_3FH;
    $64: Result := SCommand_64H;
    $46: Result := SCommand_46H;
    $47: Result := SCommand_47H;
    $50: Result := SCommand_50H;
    $59: Result := SCommand_59H;
    $6A: Result := SCommand_6AH;
    $7A: Result := SCommand_7AH;
    $80: Result := SCommand_80H;
    $81: Result := SCommand_81H;
    $83: Result := SCommand_83H;
    $84: Result := SCommand_84H;
    $85: Result := SCommand_85H;
    $86: Result := SCommand_86H;
    $87: Result := SCommand_87H;
  else
    Result := SCommand_Unknown;
  end;
end;

function DecodeStatus(const Data: string; var Status: TDatecsStatus): Boolean;
var
  i: Integer;
  B: array [0..5] of Byte;
begin
  Result := Length(Data) >= 6;
  if not Result then Exit;

  for i := 1 to 6 do
    B[i-1] := Ord(Data[i]);


  Status.Data := Data;
  Status.GeneralError := TestBit(B[0], 5);
  Status.PrinterError := TestBit(B[0], 4);
  Status.DisplayDisconnected := TestBit(B[0], 3);
  Status.ClockNotSet := TestBit(B[0], 2);
  Status.InvalidCommandCode := TestBit(B[0], 1);
  Status.InvalidDataSyntax := TestBit(B[0], 0);

  // Byte 1
  Status.WrongPassword := TestBit(B[1], 6);
  Status.CutterError := TestBit(B[1], 5);
  Status.MemoryCleared := TestBit(B[1], 2);
  Status.InvalidCommandInMode := TestBit(B[1], 1);
  Status.SumsOverflow := TestBit(B[1], 0);

  // Byte 2
  Status.NonfiscalRecOpened := TestBit(B[2], 5);
  Status.JournalPaperNearEnd := TestBit(B[2], 4);
  Status.FiscalRecOpened := TestBit(B[2], 3);
  Status.JournalPaperEmpty := TestBit(B[2], 2);
  Status.RecJrnPaperNearEnd := TestBit(B[2], 1);
  Status.RecJrnStationEmpty := TestBit(B[2], 0);

  Status.JrnSmallFont := TestBit(B[3], 6);
  Status.DisplayCP866 := TestBit(B[3], 5);
  Status.PrinterCP866 := TestBit(B[3], 4);
  Status.TransparentDisplay := TestBit(B[3], 3);
  Status.AutoCut := TestBit(B[3], 2);
  Status.BaudRate := B[3] and 3;

  Status.FMError := TestBit(B[4], 5);
  Status.FMOverflow := TestBit(B[4], 4);
  Status.FM50ZReports := TestBit(B[4], 3);
  Status.FMMissing := TestBit(B[4], 2);
  Status.FMWriteError := TestBit(B[4], 0);

  Status.SerialNumber := TestBit(B[5], 5);
  Status.TaxRatesSet := TestBit(B[5], 4);
  Status.Fiscalized := TestBit(B[5], 3);
  Status.FMFormatted := TestBit(B[5], 1);
  Status.FMReadOnly := TestBit(B[5], 0);
end;

function GetString2(const Data: string; k: Integer): string;
var
  S: string;
  i: Integer;
  P: Integer;
begin
  S := '';
  P := 0;
  for i := 1 to Length(Data) do
  begin
    if Data[i] = ',' then
    begin
      Inc(P);
      if P = K then
      begin
        Result := S;
        Exit;
      end;
      S := '';
    end else
    begin
      S := S + Data[i];
    end;
  end;
  if P < k then
  begin
    Result := S;
  end;
end;

// DDMMYY
function FDDateToStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('ddmmyy', Date);
end;

// DDMMYY
function StrToFDDate(const S: string): TDateTime;
var
  Year, Month, Day: Word;
begin
  Day := StrToInt(Copy(S, 1, 2));
  Month := StrToInt(Copy(S, 3, 2));
  Year := StrToInt(Copy(S, 5, 2));
  Result := EncodeDate(Year, Month, Day);
end;

function DataTypeToChar(DataType: Integer): AnsiChar;
begin
  case DataType of
    DataTypeTotal: Result := 'T';
    DataTypeNet: Result := 'N';
  else
    raise Exception.CreateFmt('Invalid data type value, %d', [DataType]);
  end;
end;

resourcestring
  SInvalidPreambule = 'Неверноый код преамбулы';

// 	<01><LEN><SEQ><CMD><DATA><05><BCC><03>
//	<01><LEN><SEQ><CMD><DATA><04><STATUS><05><BCC><03>

{ TDatecsFrame }

class function TDatecsFrame.GetCrc(const Data: AnsiString): AnsiString;
var
  i: Integer;
  Crc: Integer;
begin
  Crc := 0;
  for i := 1 to Length(Data) do
    Crc := Crc + Ord(Data[i]);
  Result := IntToHex(Crc, 4);
  for i := 1 to 4 do
    Result[i] := Chr(StrToInt('$' + Result[i]) + $30);
end;


//	<01><LEN><SEQ><CMD><DATA><04><STATUS><05><BCC><03>

class function TDatecsFrame.EncodeAnswer(
  const Data: TDatecsAnswer): AnsiString;
begin
  Result :=
    Chr(Length(Data.Data) + $2B) +
    Chr(Data.Sequence) +
    Chr(Data.Code) +
    Data.Data + #04 +
    Data.Status + #05;

  Result := #01 + Result + GetCrc(Result) + #03;
end;

class function TDatecsFrame.DecodeAnswer(
  const Data: AnsiString): TDatecsAnswer;
var
  Len: Integer;
  FrameCrc: AnsiString;
  FrameData: AnsiString;
begin
  if Data[1] <> #01 then
    raise Exception.Create(SInvalidPreambule);

  FrameData := Copy(Data, 2, Length(Data)-6);
  FrameCrc := Copy(Data, Length(Data)-4, 4);
  if GetCrc(FrameData) <> FrameCrc then
    RaiseError(DATECS_E_CRC, SInvalidCrc);


  Len := Ord(Data[2]) - $2B;
  Result.Sequence := Ord(Data[3]);
  Result.Code := Ord(Data[4]);
  Result.Data := Copy(Data, 5, Len);
  Result.Status := Copy(Data, Len + 6, 6);
end;

// 	<01><LEN><SEQ><CMD><DATA><05><BCC><03>

class function TDatecsFrame.EncodeCommand(
  const Data: TDatecsCommand): AnsiString;
begin
  Result :=
    Chr(Length(Data.Data) + $24) +
    Chr(Data.Sequence) +
    Chr(Data.Code) +
    Data.Data + #05;

  Result := #01 + Result + GetCrc(Result) + #03;
end;

class function TDatecsFrame.DecodeCommand(
  const Data: AnsiString): TDatecsCommand;
var
  Len: Integer;
  FrameCrc: AnsiString;
  FrameData: AnsiString;
begin
  if Data[1] <> #01 then
    raise Exception.Create(SInvalidPreambule);

  FrameData := Copy(Data, 2, Length(Data)-6);
  FrameCrc := Copy(Data, Length(Data)-4, 4);
  if GetCrc(FrameData) <> FrameCrc then
    RaiseError(DATECS_E_CRC, SInvalidCrc);


  Len := Ord(Data[2]) - $24;
  Result.Sequence := Ord(Data[3]);
  Result.Code := Ord(Data[4]);
  Result.Data := Copy(Data, 5, Len);
end;

class function TDatecsFrame.DecodeCommand2(
  const Data: AnsiString;
  var Command: TDatecsCommand): Boolean;
var
  Len: Integer;
  FrameCrc: AnsiString;
  FrameData: AnsiString;
begin
  Result := False;
  if Data[1] <> #01 then Exit;

  FrameData := Copy(Data, 2, Length(Data)-6);
  FrameCrc := Copy(Data, Length(Data)-4, 4);
  if GetCrc(FrameData) <> FrameCrc then Exit;

  Len := Ord(Data[2]) - $24;
  Command.Sequence := Ord(Data[3]);
  Command.Code := Ord(Data[4]);
  Command.Data := Copy(Data, 5, Len);
  Result := True;
end;

{ TDatecsPrinter }

constructor TDatecsPrinter.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FPassword := '';
  TxCount := $24;
  FPrinterEncoding := EncodingAuto;
  FDisplayEncoding := EncodingAuto;
end;

destructor TDatecsPrinter.Destroy;
begin

  inherited Destroy;
end;

function TDatecsPrinter.ClearResult: Integer;
begin
  FLastError := 0;
  FLastErrorText := '';
  Result := FLastError;
end;

function TDatecsPrinter.HandleException(E: Exception): Integer;
var
  DriverError: EDriverError;
begin
  if E is EDriverError then
  begin
    DriverError := E as EDriverError;
    FLastError := DriverError.Code;
    FLastErrorText := DriverError.Message;
  end else
  begin
    FLastError := DATECS_E_FAILURE;
    FLastErrorText := e.Message;
  end;
  Logger.Error('%d, %s', [FLastError, FLastErrorText]);
  Result := FLastError;
end;

function TDatecsPrinter.Succeeded(ResultCode: Integer): Boolean;
begin
  Result := ResultCode = 0;
end;

function TDatecsPrinter.CheckStatus: Integer;
begin
  if Status.InvalidCommandCode then
  begin
    Result := EInvalidCommandCode;
    Exit;
  end;

  if Status.ClockNotSet then
  begin
    Result := EDateTimeNotSet;
    Exit;
  end;

  if Status.DisplayDisconnected then
  begin
    Result := EDisplayDisconnected;
    Exit;
  end;

  if Status.PrinterError then
  begin
    Result := EPrinterError;
    Exit;
  end;

  if Status.SumsOverflow then
  begin
    Result := ESumsOverflow;
    Exit;
  end;

  if Status.InvalidCommandInMode then
  begin
    Result := EInvalidCommandInMode;
    Exit;
  end;

  if Status.RecJrnStationEmpty then
  begin
    Result := ERecJrnStationEmpty;
    Exit;
  end;
  Result := ENoError;
end;

function TDatecsPrinter.Send(const TxData: WideString): Integer;
var
  RxData: string;
begin
  Result := Send(TxData, RxData);
end;

function TDatecsPrinter.Send(const TxData: WideString; var RxData: string): Integer;
begin
  try
    SendCommand(TxData, RxData);
    Result := CheckStatus;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TDatecsPrinter.GetPrinterCodePage: Integer;
begin
  Result := 1251;
  if FStatus.PrinterCP866 then
    Result := 866;
end;

function TDatecsPrinter.GetDisplayCodePage: Integer;
begin
  Result := 1251;
  if FStatus.DisplayCP866 then
    Result := 866;
end;

function TDatecsPrinter.EncodePrinterText(const Text: WideString): AnsiString;
begin
  case PrinterEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := WideStringToAnsiString(GetPrinterCodePage, Text);
    EncodingSelected: Result := WideStringToAnsiString(PrinterCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsPrinter.EncodeDisplayText(const Text: WideString): AnsiString;
begin
  case DisplayEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := WideStringToAnsiString(GetDisplayCodePage, Text);
    EncodingSelected: Result := WideStringToAnsiString(DisplayCodePage, Text);
  else
    Result := Text;
  end;
end;

function TDatecsPrinter.DecodePrinterText(const Text: AnsiString): WideString;
begin
  case PrinterEncoding of
    EncodingNone: Result := Text;
    EncodingAuto: Result := AnsiStringToWideString(GetPrinterCodePage, Text);
    EncodingSelected: Result := AnsiStringToWideString(PrinterCodePage, Text);
  else
    Result := Text;
  end;
end;

procedure TDatecsPrinter.SendCommand(const Tx: WideString; var RxData: string);
var
  B: Byte;
  S: string;
  i: Integer;
const
  MaxCommandCount = 3;
begin
  Port.Lock;
  Logger.Debug(Logger.Separator);
  try
    if Length(Tx) = 0 then
      raise Exception.Create(SEmptyData);

    FCommand.Sequence := TxCount;
    FCommand.Code := Ord(Tx[1]);
    FCommand.Data := Copy(Tx, 2, Length(Tx));
    FTxData := TDatecsFrame.EncodeCommand(FCommand);

    S := Format('0x%.2x, %s', [FCommand.Code, GetCommandName(FCommand.Code)]);
    Logger.Debug(S);
    Logger.Debug('=> ' + Tx);

    for i := 1 to MaxCommandCount do
    begin
      Logger.Debug('-> ' + StrToHex(FTxData));
      Port.Write(FTxData);
      // 01
      repeat
        B := Ord(Port.Read(1)[1]);
        Logger.Debug('<- ' + StrToHex(Chr(B)));
        case B of
          $01: Break;
          $15:
          begin
            Break;
          end;
          $16:
          begin
            Sleep(100);
            Continue;
          end;
        else
          RaiseError(DATECS_E_NOHARDWARE, SNoHardware);
        end;
      until false;
      if B = $15 then Continue;

      B := Ord(Port.Read(1)[1]);
      FRxData := Port.Read(B - $20 + 4);
      Logger.Debug('<- ' + StrToHex(FRxData));
      FRxData := #$01 + Chr(B) + FRxData;
      FAnswer := TDatecsFrame.DecodeAnswer(FRxData);
      FAnswer.Data := DecodePrinterText(FAnswer.Data);
      DecodeStatus(FAnswer.Status, FStatus);
      Logger.Debug('<= ' + FAnswer.Data);

      if FCommand.Sequence = FAnswer.Sequence then
      begin
        if FCommand.Code <> FAnswer.Code then
          raise Exception.Create(SInvalidAnswerCode);
        RxData := FAnswer.Data;
        Break;
      end;

      if i = MaxCommandCount then
        RaiseError(DATECS_E_NOHARDWARE, SNoHardware);
    end;

    Inc(TxCount);
    if not(TxCount in [$20..$7F]) then
    begin
      TxCount := $20;
    end;
  finally
    Port.Unlock;
  end;
end;

function TDatecsPrinter.GetParam(i: Integer): string;
begin
  Result := GetString2(FAnswer.Data, i);
end;

function TDatecsPrinter.XReport: TFDReportAnswer;
var
  i: Integer;
begin
  Result.ResultCode := Send(#$45'0');
  if Succeeded(Result.ResultCode) then
  begin
    Result.ReportNumber := StrToInt(GetParam(1));
    Result.SalesTotalNoTax := StrToInt64(GetParam(2));
    for i := 1 to 5 do
      Result.SalesTotalTax[i] := StrToInt64(GetParam(i + 2));
  end;
end;

function TDatecsPrinter.ZReport: TFDReportAnswer;
var
  i: Integer;
begin
  Result.ResultCode := Send(#$45'2');
  if Succeeded(Result.ResultCode) then
  begin
    Result.ReportNumber := StrToInt(GetParam(1));
    Result.SalesTotalNoTax := StrToInt(GetParam(2));
    for i := 1 to 5 do
      Result.SalesTotalTax[i] := StrToInt64(GetParam(i + 2));
  end;
end;

procedure TDatecsPrinter.Check(Code: Integer);
begin
  if Code <> 0 then
    RaiseError(Code, GetErrorText(Code));
end;

function TDatecsPrinter.WaitWhilePrintEnd: Integer;
begin

end;

function TDatecsPrinter.ClearExternalDisplay: Integer;
begin
  Result := Send(#$21);
end;

function TDatecsPrinter.DisplayText(const Text: WideString): Integer;
begin
  Result := Send(#$23 + EncodeDisplayText(Copy(Text, 1, 20)));
end;

function TDatecsPrinter.StartNonfiscalReceipt: TReceiptNumberRec;
begin
  Result.ResultCode := Send(#$26);
  if Succeeded(Result.ResultCode) then
    Result.ReceiptNumber := StrToInt64(GetParam(1));
end;

function TDatecsPrinter.EndNonfiscalReceipt: TReceiptNumberRec;
begin
  Result.ResultCode := Send(#$27);
  if Succeeded(Result.ResultCode) then
    Result.ReceiptNumber := StrToInt64(GetParam(1));
end;

function TDatecsPrinter.PrintNonfiscalText(const Text: WideString): Integer;
begin
  Result := Send(#$2A + EncodePrinterText(Text));
end;

function TDatecsPrinter.PaperFeed(LineCount: Integer): Integer;
begin
  Result := Send(#$2C + IntToStr(LineCount));
end;

function TDatecsPrinter.PartialCut: Integer;
begin
  Result := PaperCut(CutModePartial);
end;

function TDatecsPrinter.FullCut: Integer;
begin
  Result := PaperCut(CutModeFull);
end;

function TDatecsPrinter.PaperCut(CutMode: Integer): Integer;
begin
  Result := Send(#$2D + IntToStr(CutMode));
end;

function TDatecsPrinter.StartFiscalReceipt(const P: TFDStartRec): TFDReceiptNumber;
var
  Command: AnsiString;
begin
  Command := #$30 + Format('%d,%s', [P.Operator, P.Password]);
  Result.ResultCode := Send(Command);
  if Succeeded(Result.ResultCode) then
  begin
    Result.DocNumber := StrToInt64(GetParam(1));
    Result.FDNumber := StrToInt64(GetParam(2));
  end;
end;

function TDatecsPrinter.SaleCommand(Cmd: Char; const P: TFDSale): Integer;
const
  TaxLetters = 'ABCD';
var
  Command: AnsiString;
begin
  Command := P.Text1;
  if P.Text2 <> '' then
    Command := Command + LF + P.Text2;
  if P.Tax in [1..4] then
    Command := Command + TAB + TaxLetters[P.Tax];
  Command := Command + IntToStr(P.Price) + '*' + IntToStr(P.Quantity);
  if P.DiscountPercent <> 0 then
    Command := Command + Format(',%.2f', [P.DiscountPercent]);
  if P.DiscountAmount <> 0 then
    Command := Command + Format('$%d', [P.DiscountAmount]);
  Result := Send(Cmd + Command);
end;

function TDatecsPrinter.Sale(const P: TFDSale): Integer;
begin
  Result := SaleCommand(#$31, P);
end;

function TDatecsPrinter.SaleAndDisplay(const P: TFDSale): Integer;
begin
  Result := SaleCommand(#$34, P);
end;

function TDatecsPrinter.ReadTaxRates(const StartDate,
  EndDate: TDateTime): TFDTaxRates;
var
  i: Integer;
  Command: AnsiString;
begin
  Command := FDDateToStr(StartDate) + ',' +  FDDateToStr(EndDate);
  Result.ResultCode := Send(#$32 + Command);
  if Succeeded(Result.ResultCode) then
  begin
    Result.DataFound := GetParam(1) = 'P';
    for i := 1 to 5 do
      Result.VATRate[i] := StrToInt(GetParam(i+1));
    Result.Date := StrToFDDate(GetParam(7));
  end;
end;

function TDatecsPrinter.Subtotal(const P: TFDSubtotal): TFDSubtotalResponse;
var
  i: Integer;
  Command: AnsiString;
begin
  Command := BoolToStr[P.PrintSubtotal] + BoolToStr[P.DisplaySubtotal];
  if P.SubtotalPercent <> 0 then
    Command := Command + ',' + Format('%.2f', [P.SubtotalPercent]);
  Result.ResultCode := Send(#$33 + Command);
  if Succeeded(Result.ResultCode) then
  begin
    Result.SubTotal := StrToInt64(GetParam(1));
    Result.SalesTaxFree := StrToInt64(GetParam(2));
    for i := 1 to MaxTax do
      Result.TaxTotals[i] := StrToInt(GetParam(i+2));
  end;
end;

function StrToPaidCode(C: AnsiChar): Integer;
begin
  case C of
    'F': Result := PaidCodeError;
    'I': Result := PaidCodeTaxNegative;
    'D': Result := PaidCodeSumLessTotal;
    'R': Result := PaidCodeSumGreaterTotal;
    'E': Result := PaidCodeNegativeSubtotal;
  else
    raise Exception.CreateFmt('Unknown payment code, %s', [C]);
  end;
end;

function TDatecsPrinter.PrintTotal(const P: TFDTotal): TFDTotalResponse;
var
  i: Integer;
  Command: AnsiString;
const
  PaymentModeChar = 'PNCDE';
  PaymentModeChar2 = 'PNCUB';
begin
  if not(P.PaymentMode in [PaymentModeMin..PaymentModeMax]) then
    raise Exception.CreateFmt('Invalid PaymentMode value, %d', [P.PaymentMode]);

  Command := P.Text1 + LF + P.Text2 + TAB + PaymentModeChar[P.PaymentMode] +
    IntToStr(P.Amount);
  Result.ResultCode := Send(#$35 + Command);
  if Succeeded(Result.ResultCode) then
  begin
    Result.PaidCode := StrToPaidCode(GetParam(1)[1]);
    Result.Amount := StrToInt64(GetParam(2));
  end;
end;

function TDatecsPrinter.PrintFiscalText(const Text: WideString): Integer;
begin
  Result := Send(#$36 + Text);
end;

function TDatecsPrinter.EndFiscalReceipt: TFDReceiptNumber;
begin
  Result.ResultCode := Send(#$38);
  if Succeeded(Result.ResultCode) then
  begin
    Result.DocNumber := StrToInt64(GetParam(1));
    Result.FDNumber := StrToInt64(GetParam(2));
  end;
end;

function TDatecsPrinter.SaleByPLU(const P: TFDPLU): Integer;
var
  Command: AnsiString;
begin
  Command := P.Sign + P.PLU + '*' + IntToStr(P.Quantity) + ',' +
    Format('%.2f', [P.DiscountPercent]) + '@' + IntToStr(P.Price) + '$' +
    IntToStr(P.DiscountAmount);
  Result := Send(#$3A + Command);
end;

function TDatecsPrinter.WriteDateTime(Date: TDateTime): Integer;
var
  Command: AnsiString;
begin
  Command := FormatDateTime('dd-mm-yy hh:nn:ss', Date);
  Result := Send(#$3D + Command);
end;

function TDatecsPrinter.ReadDateTime: TDateTimeResponse;
var
  Answer: AnsiString;
  Year, Month, Day: Word;
  Hour, Min, Sec: Word;
begin
  Result.ResultCode := Send(#$3E, Answer);
  if Succeeded(Result.ResultCode) then
  begin
    if Length(Answer) < 17 then
     raise Exception.CreateFmt('Invalid date answer, %s', [Answer]);

    Day := StrToInt(Copy(Answer, 1, 2));
    Month := StrToInt(Copy(Answer, 4, 2));
    Year := 2000 + StrToInt(Copy(Answer, 7, 2));
    Hour := StrToInt(Copy(Answer, 10, 2));
    Min := StrToInt(Copy(Answer, 13, 2));
    Sec := StrToInt(Copy(Answer, 16, 2));
    Result.Date := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Min, Sec, 0);
  end;
end;

function TDatecsPrinter.DisplayDateTime: Integer;
begin
  Result := Send(#$3F);
end;

function TDatecsPrinter.FinalFiscalRecord(DataType: AnsiChar): TFDFiscalRecord;
var
  i: Integer;
  Answer: AnsiString;
begin
  Result.ResultCode := Send(#$40 + DataType, Answer);
  if Succeeded(Result.ResultCode) then
  begin
    Result.Number := GetInteger(Answer, 1, [',']);
    Result.SalesTotalTaxFree := StrToInt64(GetString(Answer, 2, [',']));
    for i := 1 to 5 do
      Result.SalesTotalTax[i] := StrToInt64(GetString(Answer, i+2, [',']));
    Result.Date := StrToFDDate(GetString(Answer, 8, [',']))
  end;
end;

function TDatecsPrinter.ReadTotals(DataType: Integer): TFDTotals;
var
  i: Integer;
  Answer: AnsiString;
begin
  Result.ResultCode := Send(#$41 + DataTypeToChar(DataType));
  if Succeeded(Result.ResultCode) then
  begin
    Result.SalesTotalTaxFree := StrToInt64(GetString(Answer, 1, [',']));
    for i := 1 to 5 do
      Result.SalesTotalTax[i] := StrToInt64(GetString(Answer, i+1, [',']));
  end;
end;

function TDatecsPrinter.ReadFreeFiscalRecords: TFDFiscalrecords;
var
  Answer: AnsiString;
begin
  Result.ResultCode := Send(#$44, Answer);
  if Succeeded(Result.ResultCode) then
  begin
    Result.LogicalNumber := GetInteger(Answer, 1, [',']);
    Result.PhysicalNumber := GetInteger(Answer, 2, [',']);
  end;
end;

function TDatecsPrinter.PrintDiagnosticInfo: Integer;
begin
  Result := Send(#$47);
end;

function TDatecsPrinter.PrintReportByNumbers(StartNum, EndNum: Integer): Integer;
begin
  Result := Send(#$49  + IntToStr(StartNum) + ',' + IntToStr(EndNum));
end;

function TDatecsPrinter.ReadFDStatus: Integer;
begin
  Result := Send(#$4A);
end;

function TDatecsPrinter.GetDiagnosticInfo(CalcCRC: Boolean): TDiagnosticInfo;
var
  Answer: AnsiString;
begin
  Result.ResultCode := Send(#$5A + BoolToStr[CalcCRC], Answer);
  if Succeeded(Result.ResultCode) then
  begin
    Result.FirmwareVersion := GetString(Answer, 1, [' ', ',']);
    Result.FirmwareDate := GetString(Answer, 2, [' ', ',']);
    Result.FirmwareTime := GetString(Answer, 3, [' ', ',']);
    Result.ChekSum := GetString(Answer, 4, [' ', ',']);
    Result.Switches := GetInteger(Answer, 5, [' ', ',']);
    Result.Country := GetInteger(Answer, 6, [' ', ',']);
    Result.FDSerial := GetString(Answer, 7, [' ', ',']);
    Result.FDNo := GetString(Answer, 8, [' ', ',']);
  end;
end;


end.
