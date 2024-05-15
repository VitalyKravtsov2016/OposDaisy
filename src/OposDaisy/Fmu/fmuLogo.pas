unit fmuLogo;

interface

uses
  // VCL
  Windows, Messages, StdCtrls, Controls, Classes, SysUtils, Registry, Dialogs,
  Forms, ComCtrls, Buttons, ExtDlgs, ExtCtrls, Graphics,
  // 3'd
  TntStdCtrls, TntSysUtils, TntButtons, TntComCtrls, TntExtCtrls,
  // Opos
  Opos, Oposhi, OposUtils,
  // This
  BaseForm, DaisyPrinterInterface;

const
  WM_NOTIFY = WM_USER + 1;

type
  { TfmLogo }

  TfmLogo = class(TBaseForm)
    btnClose: TTntButton;
    OpenPictureDialog: TOpenPictureDialog;
    btnOpen: TTntBitBtn;
    btnLoad: TTntBitBtn;
    Panel1: TTntPanel;
    lblMaxImageSize: TTntLabel;
    lblInfo1: TTntLabel;
    lblImageSize: TTntLabel;
    edtImageSize: TTntEdit;
    edtMaxImageSize: TTntEdit;
    lblWarn: TTntLabel;
    imgWarn: TImage;
    Panel2: TTntPanel;
    Image: TImage;
    lblProgress: TTntLabel;
    procedure btnLoadClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FPrinter: IDaisyPrinter;
    FApplicationTitle: WideString;
    FApplicationHandle: THandle;

    procedure UpdatePage;
    property Printer: IDaisyPrinter read FPrinter;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure ShowLogoDialog(APrinter: IDaisyPrinter);

implementation

{$R *.DFM}

procedure ShowLogoDialog(APrinter: IDaisyPrinter);
var
  fm: TfmLogo;
begin
  fm := TfmLogo.Create(nil);
  try
    SetWindowLong(fm.Handle, GWL_HWNDPARENT, GetActiveWindow);
    fm.FPrinter := APrinter;
    fm.UpdatePage;
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;

{ TfmLogo }

constructor TfmLogo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FApplicationHandle := Application.Handle;
  FApplicationTitle := Application.Title;

  Application.Handle := Handle;
  Application.Title := 'Logo loading';
end;

destructor TfmLogo.Destroy;
begin
  Application.Title := FApplicationTitle;
  Application.Handle := FApplicationHandle;
  inherited Destroy;
end;

procedure TfmLogo.UpdatePage;
begin
  edtMaxImageSize.Text := Tnt_WideFormat('%d x %d', [
    Printer.Constants.MaxLogoWidth,
    Printer.Constants.MaxLogoHeight]);

  lblProgress.Caption := '';
  OpenPictureDialog.InitialDir := ExtractFilePath(ParamStr(0));
end;

procedure TfmLogo.btnLoadClick(Sender: TObject);
begin
  btnLoad.Enabled := False;
  try
    Printer.LoadLogoFile(OpenPictureDialog.FileName);
  except
    on E: Exception do
    begin
      Application.HandleException(E);
    end;
  end;
  btnLoad.Enabled := True;
  btnLoad.setFocus;
end;

procedure TfmLogo.btnOpenClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
    Image.Picture.LoadFromFile(OpenPictureDialog.FileName);
    edtImageSize.Text := Tnt_WideFormat('%d x %d', [Image.Picture.Width,
      Image.Picture.Height]);
    lblWarn.Caption := 'Image size more than maximum';
  end;
end;

procedure TfmLogo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
