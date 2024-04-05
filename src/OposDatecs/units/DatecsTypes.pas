unit DatecsTypes;

interface

uses
  ByteUtils;

const  
///////////////////////////////////////////////////////////////////////////////
// Encoding constants

  EncodingNone      = 0;
  EncodingAuto      = 1;
  EncodingSelected  = 2;


type
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

const
  LF = #10;
  CRLF = #13#10;
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

  SInvalidCrc: WideString = 'Неверный CRC';
  SNoHardware: WideString = 'Нет связи с ФР';
  SMaxSynCount: WideString = 'Устройство занято';
  SEmptyData: WideString = 'Пустые данные для передачи';
  SInvalidAnswerCode: WideString = 'Неверный код ответа';
  SInvalidParamValue: WideString = 'Неверное значение параметра "%s"';
  SInvalidPasswordLength: WideString = 'Длина пароля должна быть больше или равна 4';
  SInvalidCodeValue: WideString = 'Неверное значение кода';


const
  CP_Ukrainian = 21866;

  /////////////////////////////////////////////////////////////////////////////
  // Error codes

  EInvalidParams        = -1;

  DATECS_E_FAILURE      = -2;
  DATECS_E_NOHARDWARE   = -3;
  DATECS_E_CRC          = -4;

  CmdSaveSettings     = #$29; // Запись текущих настроек в энергонезависимую флеш-память
  CmdSetHeaderFooter  = #$2B; // Установка HEADER и FOOTER и параметров печати
  CmdSetDateTime      = #$3D; // Установка даты и времени
  CmdGetDateTime      = #$3E; // Возвращает дату и время


function GetCommandName(Code: Integer): WideString;
function GetErrorText(Code: Integer): WideString;
function DecodeStatus(const Data: string; var Status: TDatecsStatus): Boolean;
function EncodeStatus(const Status: TDatecsStatus): string;


implementation

///////////////////////////////////////////////////////////////////////////////
// Comand codes
(*
  // ИНИЦИАЛИЗАЦИЯ
  29H	(41)	Запись текущих настроек в энергонезависимую флеш-память.
  2BH	(43)	Установка HEADER и FOOTER и параметров печати
  3DH	(61)	Установка даты и времени
  48H	(72)	Фискализация
  53H	(83)	Установка десятичной точки и налоговых ставок
  54H	(84)	Установка режима продаж (начислен ДДС)
  57H	(87)	Программирование дополнительных типов оплаты
  5BH	(91)	Программирование серийного номера и номера страны
  5CH	(92)	Программирование номера фискалной памяти.
  62H	(98)	Установка ИНН
  65H	(101)	Запись пароля оператора
  66H	(102)	Запись имени оператора
  68H	(104)	Сброс данных оператора
  6BH	(107)	Определение и отчет по товарам
  73H	(115)	Загрузка графического логотипа
  76H	(118)	Запись пароля администратора
  77H	(119)	Сброс пароля оператора

  // ПРОДАЖИ
  26H	(38)	Открыть нефискальный чек
  27H	(39)	Закрыть нефискальный чек
  2AH	(42)	Печать нефискального свободного текста
  30H (48) Открыть фискальный чек
  33H (51) Итоги (скидок и надбавок)
  34H (52) Регистрация купли-продажи и дисплей
  35H (53) Расчет суммы (оплаты)
  36H (54) Печать фискального свободного текста
  37H (55) Расчет суммы (оплаты) и закрытие чека
  38H (56) Закрытие кассового чека.
  39H (57) Отмена или изменение фискального чека
  3AH (58) Регистрация продажа товара
  3BH (59) Скидки / надбавки или налог на товарную группу
  55H	(85)	Открытие чека возврата
  58H	(88)	Печать штрихкода
  5DH	(93)	Печать разделителной линии
  6DH	(109)	Печат копии чека

  Конец дня
  45H	(69) 	Ежедневный фискальный отчет (с гашением или без)

  ОТЧЕТЫ
  32H	(50)	Отчет об изменениях в налоговых ставках и десятичной точке в соответствующем периоде
  49H	(73)	Подробный отчет из фискальной памяти (по номерам смен)
  5EH	(94)	Подробный отчет из фискальной памяти (по датам)
  4FH	(79)	Сокращенный отчет из фискальной памяти (по датам)
  5FH	(95)	Сокращенный отчет из фискальной памяти (по номерам смен)
  69H	(105)	Отчет по операторам
  6FH	(111)	Отчет по товарам

  ИНФОРМАЦИЯ
  2ЕH	(46)	Получить продолжительность текущей смены
  3ЕH	(62)	Возвращает дату и время
  40H	(64)	Информация последней фискальной записи
  41H	(65)	Информация начисленных сумм за день
  43H	(67)	Информация о накопленной суммы корректировок
  44H	(68)	Количество свободных записей в фискальной памяти
  4AH	(74) 	Получить байт состояния
  4CH	(76)	Состояние фискалной операции
  56H	(86)	Получить дату последней фискальной записи
  5AH	(90)	Получение диагностической информации
  61H	(97)	Получение налоговых ставок
  63H	(99)	Получение налогового номера
  67H	(103)	Информация о текущем чеке
  6EH	(110)	Получение информации о суммах оплаты по типам
  70H	(112)	Получение информации о операторе
  71H	(113)	Получение номера последнего отпечатаннного документа
  72H	(114)	Получение информации о фискальных записях за период

  КОМАНДЫ ПЕЧАТИ
  2CH	(44)	Промотка бумаги
  2DH	(45)	Отрезка бумаги

  ДИСПЛЕЙ
  21H	(33)	Очистить дисплей
  23H	(35)	Вывести текст (нижний ряд)
  2FH	(47)	Вывести текст (верхний ряд)
  3FH	(63)	Показать дату и время
  64H	(100)	Дисплей - управление

  ДРУГИЕ КОМАНДЫ
  46H	(70)	Внесение и выплата денежных средств.
  47H	(71)	Печать диагностической информации
  50H	(80)	Звуковой сигнал
  59H	(89)	Программирование производственные площади теста
  6AH	(106)	Открыть ящик

  СЕРВИСНЫЕ (НУЖНО УСТАНОВИТЬ ПЕРЕМЫЧКУ)
  80H	(128)	Сервисное обнуление RAM
  81H	(130)	Сервисное стирание фискалной памяти
  83H	(131)	Сервисное форматирование фискалной памяти
  84H	(132)	Читать блок прошивки (память программ)
  85H	(133)	Временный запрет печати
  86H (134) Блокировка записи с неправильной контрольной суммой.
  87H (135) Сервисная запись в фискальную память
*)

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
  SCommand_3EH: WideString = 'Возвращает дату и время';
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

function EncodeStatus(const Status: TDatecsStatus): string;
begin

end;

end.
