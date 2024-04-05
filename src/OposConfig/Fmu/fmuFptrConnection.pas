unit fmuFptrConnection;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin,
  // Tnt
  TntStdCtrls,
  // This
  untUtil, PrinterParameters, FptrTypes, FiscalPrinterDevice, FileUtils,
  LogFile;

type
  { TfmFptrConnection }

  TfmFptrConnection = class(TFptrPage)
    gbConenctionParams: TTntGroupBox;
    lblServerConnectTimeout: TTntLabel;
    lblServerAddress: TTntLabel;
    seServerConnectTimeout: TSpinEdit;
    edtServerAddress: TEdit;
    lblServerLogin: TTntLabel;
    edtServerLogin: TEdit;
    edtServerPassword: TEdit;
    lblServerPassword: TTntLabel;
    btnTestConnection: TButton;
    edtResultCode: TEdit;
    lblResultCode: TTntLabel;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.dfm}

{ TfmFptrConnection }

procedure TfmFptrConnection.UpdatePage;
begin
  edtServerAddress.Text := Parameters.ServerAddress;
  seServerConnectTimeout.Value := Parameters.ServerConnectTimeout;
  edtServerLogin.Text := Parameters.ServerLogin;
  edtServerPassword.Text := Parameters.ServerPassword;
end;

procedure TfmFptrConnection.UpdateObject;
begin
  Parameters.ServerAddress := edtServerAddress.Text;
  Parameters.ServerConnectTimeout := seServerConnectTimeout.Value;
  Parameters.ServerLogin := edtServerLogin.Text;
  Parameters.ServerPassword := edtServerPassword.Text;
end;

procedure TfmFptrConnection.btnTestConnectionClick(Sender: TObject);
begin
  EnableButtons(False);
  edtResultCode.Clear;
  UpdateObject;
  try
    //Driver.Connect; { !!! }
    edtResultCode.Text := 'OK';
  except
    on E: Exception do
    begin
      Logger.Error(E.Message);
      edtResultCode.Text := E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmFptrConnection.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

end.
