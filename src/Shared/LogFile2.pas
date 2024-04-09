unit LogFile2;

interface

uses
  // VCL
  Windows, Classes, SysUtils, SyncObjs, SysConst, Variants, DateUtils;

type
  TVariantArray = array of Variant;

  { TLogFile }

  TLogFile = class
  private
    FHandle: THandle;
    FFileName: string;
    FEnabled: Boolean;
    FSeparator: string;
    FLock: TCriticalSection;

    procedure Lock;
    procedure Unlock;
    procedure OpenFile;
    procedure CloseFile;
    procedure SetDefaults;
    function GetOpened: Boolean;
    function GetFileName: string;
    procedure SetEnabled(Value: Boolean);
    procedure Write(const Data: string);
    procedure AddLine(const Data: string);
    procedure SetFileName(const Value: string);

    property Opened: Boolean read GetOpened;
    class function ParamsToStr(const Params: array of const): string;
    class function VariantToStr(V: Variant): string;
    class function VarArrayToStr(const AVarArray: TVariantArray): string;
    procedure AddLines(const Tag, Text: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Info(const Data: string); overload;
    procedure Debug(const Data: string); overload;
    procedure Trace(const Data: string); overload;
    procedure Error(const Data: string); overload;
    procedure Error(const Data: string; E: Exception); overload;
    procedure Info(const Data: string; Params: array of const); overload;
    procedure Trace(const Data: string; Params: array of const); overload;
    procedure Error(const Data: string; Params: array of const); overload;
    procedure Debug(const Data: string; Result: Variant); overload;
    procedure Debug(const Data: string; Params: array of const); overload;
    procedure Debug(const Data: string; Params: array of const; Result: Variant); overload;
    class function StrToText(const Text: string): string;
    function GetFileDate(const FileName: string;
      var FileDate: TDateTime): Boolean;

    property Enabled: Boolean read FEnabled write SetEnabled;
    property FileName: string read FFileName write SetFileName;
    property Separator: string read FSeparator write FSeparator;
  end;

function Logger: TLogFile;
procedure LogDebugData(const Prefix, Data: string);

implementation

const
  SDefaultSeparator   = '------------------------------------------------------------';
  SDefaultSeparator2  = '************************************************************';

function ConstArrayToVarArray(const AValues : array of const): TVariantArray;
var
  i : Integer;
begin
  SetLength(Result, Length(AValues));
  for i := Low(AValues) to High(AValues) do
  begin
    with AValues[i] do
    begin
      case VType of
        vtInteger: Result[i] := VInteger;
        vtInt64: Result[i] := VInt64^;
        vtBoolean: Result[i] := VBoolean;
        vtChar: Result[i] := VChar;
        vtExtended: Result[i] := VExtended^;
        vtString: Result[i] := VString^;
        vtPointer: Result[i] := Integer(VPointer);
        vtPChar: Result[i] := StrPas(VPChar);
        vtObject: Result[i]:= Integer(VObject);
        vtAnsiString: Result[i] := String(VAnsiString);
        vtCurrency: Result[i] := VCurrency^;
        vtVariant: Result[i] := VVariant^;
        vtInterface: Result[i]:= Integer(VPointer);
        vtWideString: Result[i]:= WideString(VWideString);
      else
        Result[i] := NULL;
      end;
    end;
  end;
end;

function StrToHex(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if i <> 1 then Result := Result + ' ';
    Result := Result + IntToHex(Ord(S[i]), 2);
  end;
end;

const
  TagInfo         = '[ INFO] ';
  TagTrace        = '[TRACE] ';
  TagDebug        = '[DEBUG] ';
  TagError        = '[ERROR] ';

var
  FLogger: TLogFile;

function Logger: TLogFile;
begin
  if FLogger = nil then
    FLogger := TLogFile.Create;
  Result := FLogger;
end;

function GetTimeStamp: string;
var
  Year, Month, Day: Word;
  Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(Date, Year, Month, Day);
  DecodeTime(Time, Hour, Min, Sec, MSec);
  Result := Format('%.2d.%.2d.%.4d %.2d:%.2d:%.2d.%.3d ',[
    Day, Month, Year, Hour, Min, Sec, MSec]);
end;

function GetLongFileName(const FileName: string): string;
var
  L: Integer;
  Handle: Integer;
  Buffer: array[0..MAX_PATH] of Char;
  GetLongPathName: function (ShortPathName: PChar; LongPathName: PChar;
    cchBuffer: Integer): Integer stdcall;
const
  kernel = 'kernel32.dll';
begin
  Result := FileName;
  Handle := GetModuleHandle(kernel);
  if Handle <> 0 then
  begin
    @GetLongPathName := GetProcAddress(Handle, 'GetLongPathNameA');
    if Assigned(GetLongPathName) then
    begin
      L := GetLongPathName(PChar(FileName), Buffer, SizeOf(Buffer));
      SetString(Result, Buffer, L);
    end;
  end;
end;

function GetModFileName: string;
var
  Buffer: array[0..261] of Char;
begin
  SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
    Buffer, SizeOf(Buffer)));
end;

function GetModuleFileName: string;
begin
  Result := GetLongFileName(GetModFileName);
end;

function GetLastErrorText: string;
begin
  Result := Format(SOSError, [GetLastError,  SysErrorMessage(GetLastError)]);
end;

procedure LogDebugData(const Prefix, Data: string);
var
  Line: string;
const
  DataLen = 20; // Max data string length
begin
  Line := Data;
  repeat
    Logger.Debug(Prefix + StrToHex(Copy(Line, 1, DataLen)));
    Line := Copy(Line, DataLen + 1, Length(Line));
  until Line = '';
end;

procedure ODS(const S: string);
begin
{$IFDEF DEBUG}
  OutputDebugString(PChar(S));
{$ENDIF}
end;


{ TLogFile }

constructor TLogFile.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FHandle := INVALID_HANDLE_VALUE;
  FSeparator := SDefaultSeparator;
  SetDefaults;
end;

destructor TLogFile.Destroy;
begin
  CloseFile;
  FLock.Free;
  inherited Destroy;
end;

procedure TLogFile.Lock;
begin
  FLock.Enter;
end;

procedure TLogFile.Unlock;
begin
  FLock.Leave;
end;

function TLogFile.GetFileName: string;
begin
  Result := ChangeFileExt(ExpandFileName(GetModuleFileName), '') + '_' +
    FormatDateTime('yyyy.mm.dd', Date) + '.log';
end;

procedure TLogFile.SetDefaults;
begin
  Enabled := False;
  FileName := GetFileName;
end;

procedure TLogFile.OpenFile;
begin
  Lock;
  try
    if not Opened then
    begin
      FHandle := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

      if Opened then
      begin
        FileSeek(FHandle, 0, 2); // 0 from end
        Debug(Separator);
        Debug('  ��� ���� ������');
      end else
      begin
        ODS(Format('Failed to create log file ''%s''', [FileName]));
        ODS(GetLastErrorText);
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TLogFile.CloseFile;
begin
  Lock;
  try
    if Opened then
    begin
      Debug('  ��� ���� ������');
      Debug(Separator);
      CloseHandle(FHandle);
    end;
    FHandle := INVALID_HANDLE_VALUE;
  finally
    Unlock;
  end;
end;

function TLogFile.GetOpened: Boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

procedure TLogFile.SetEnabled(Value: Boolean);
begin
  if Value <> Enabled then
  begin
    CloseFile;
    FEnabled := Value;
  end;
end;

procedure TLogFile.SetFileName(const Value: string);
begin
  if Value <> FileName then
  begin
    CloseFile;
    FFileName := Value;
  end;
end;

function TLogFile.GetFileDate(const FileName: string;
  var FileDate: TDateTime): Boolean;
var
  Line: string;
  Year, Month, Day: Word;
begin
  try
    Line := ChangeFileExt(ExtractFileName(FileName), '');
    Line := Copy(Line, Length(Line)-9, 10);
    Day := StrToInt(Copy(Line, 1, 2));
    Month := StrToInt(Copy(Line, 4, 2));
    Year := StrToInt(Copy(Line, 7, 4));
    FileDate := EncodeDate(Year, Month, Day);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TLogFile.Write(const Data: string);
var
  S: string;
  Count: DWORD;
begin
  Lock;
  try
    ODS(Data);
    if not Enabled then Exit;
    S := Data;

    OpenFile;
    if Opened then
    begin
      WriteFile(FHandle, S[1], Length(S), Count, nil);
    end;
  finally
    Unlock;
  end;
end;

procedure TLogFile.AddLine(const Data: string);
const
  CRLF = #13#10;
var
  Line: string;
begin
  Line := Format('[%s] [%.8d] %s', [GetTimeStamp, GetCurrentThreadID, Data]) + CRLF;
  Write(Line);
end;

procedure TLogFile.AddLines(const Tag, Text: string);
var
  i: Integer;
  Lines: TStrings;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
      AddLine(Tag + Lines[i]);
  finally
    Lines.Free;
  end;
end;

procedure TLogFile.Trace(const Data: string);
begin
  AddLines(TagTrace, Data);
end;

procedure TLogFile.Info(const Data: string);
begin
  AddLines(TagInfo, Data);
end;

procedure TLogFile.Error(const Data: string);
begin
  AddLines(TagError, Data);
end;

procedure TLogFile.Error(const Data: string; E: Exception);
begin
  AddLines(TagError, Data + ' ' + E.Message);
end;

procedure TLogFile.Debug(const Data: string);
begin
  AddLines(TagDebug, Data);
end;

class function TLogFile.ParamsToStr(const Params: array of const): string;
begin
  Result := VarArrayToStr(ConstArrayToVarArray(Params));
end;

procedure TLogFile.Debug(const Data: string; Params: array of const);
begin
  Debug(Data + ParamsToStr(Params));
end;

procedure TLogFile.Debug(const Data: string; Params: array of const;
  Result: Variant);
begin
  Debug(Data + ParamsToStr(Params) + '=' + VariantToStr(Result));
end;

procedure TLogFile.Debug(const Data: string; Result: Variant);
begin
  Debug(Data + '=' + VariantToStr(Result));
end;

procedure TLogFile.Error(const Data: string; Params: array of const);
begin
  Error(Data + ParamsToStr(Params));
end;

procedure TLogFile.Info(const Data: string; Params: array of const);
begin
  Info(Data + ParamsToStr(Params));
end;

procedure TLogFile.Trace(const Data: string; Params: array of const);
begin
  Trace(Data + ParamsToStr(Params));
end;

{ �������������� ������ � �����, ����� ������� ��� ������� }

class function TLogFile.StrToText(const Text: string): string;
var
  Code: Byte;
  i: Integer;
  IsPrevCharNormal: Boolean;
begin
  Result := '';
  IsPrevCharNormal := False;
  if Length(Text) > 0 then
  begin
    for i := 1 to Length(Text) do
    begin
      Code := Ord(Text[i]);
      if Code < $20 then
      begin
        if IsPrevCharNormal then
        begin
          IsPrevCharNormal := False;
          Result := Result + '''';
        end;
        Result := Result + Format('#$%.2x', [Code])
      end else
      begin
        if not IsPrevCharNormal then
        begin
          IsPrevCharNormal := True;
          Result := Result + '''';
        end;
        Result := Result + Text[i];
      end;
    end;
    if IsPrevCharNormal then
      Result := Result + '''';
  end else
  begin
    Result := '''''';
  end;
end;

class function TLogFile.VariantToStr(V: Variant): string;
begin
  if VarIsNull(V) then
  begin
    Result := 'NULL';
  end else
  begin
    case VarType(V) of
      varOleStr,
      varStrArg,
      varString:
        Result := StrToText(VarToStr(V));
    else
      Result := VarToStr(V);
    end;
  end;
end;

class function TLogFile.VarArrayToStr(const AVarArray: TVariantArray): string;
var
  I: Integer;
begin
  Result := '';
  for i := Low(AVarArray) to High(AVarArray) do
  begin
    if Length(Result) > 0 then
      Result := Result + ', ';
    Result := Result + VariantToStr(AVarArray[I]);
  end;
  Result := '(' + Result + ')';
end;

initialization

finalization
  FLogger.Free;
  FLogger := nil;

end.