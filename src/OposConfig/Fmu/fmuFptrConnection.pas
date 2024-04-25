unit fmuFptrConnection;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ExtCtrls,
  // Tnt
  TntStdCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, FptrTypes, FileUtils, untUtil;

type
  { TfmFptrConnection }

  TfmFptrConnection = class(TFptrPage)
    chbSearchByPort: TTntCheckBox;
    chbSearchByBaudRate: TTntCheckBox;
    cbMaxRetryCount: TTntComboBox;
    lblMaxRetryCount: TTntLabel;
    lblByteTimeout: TTntLabel;
    seByteTimeout: TSpinEdit;
    cbBaudRate: TTntComboBox;
    lblBaudRate: TTntLabel;
    lblComPort: TTntLabel;
    cbComPort: TTntComboBox;
    seRemotePort: TSpinEdit;
    lblRemotePort: TTntLabel;
    lblRemoteHost: TTntLabel;
    edtRemoteHost: TTntEdit;
    cbConnectionType: TTntComboBox;
    lblConnectionType: TTntLabel;
    Bevel1: TBevel;
    lblPollInterval: TTntLabel;
    sePollInterval: TSpinEdit;
    cbCCOType: TTntComboBox;
    lblEventsType: TTntLabel;
    Bevel2: TBevel;
    lblUsrPassword: TTntLabel;
    seOperatorNumber: TSpinEdit;
    seOperatorPassword: TSpinEdit;
    lblSysPassword: TTntLabel;
    Bevel3: TBevel;
    procedure FormCreate(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

var
  fmFptrConnection: TfmFptrConnection;

implementation

{$R *.dfm}

{ TfmFptrConnection }

procedure TfmFptrConnection.UpdatePage;
begin
  cbConnectionType.ItemIndex := Parameters.ConnectionType;
  edtRemoteHost.Text := Parameters.RemoteHost;
  seRemotePort.Value := Parameters.RemotePort;
  cbComPort.Text := Parameters.PortName;
  cbBaudRate.ItemIndex := BaudRateToInt(Parameters.BaudRate);
  seByteTimeout.Value := Parameters.ByteTimeout;
  cbMaxRetryCount.ItemIndex := Parameters.MaxRetryCount;
  chbSearchByBaudRate.Checked := Parameters.SearchByBaudRateEnabled;
  chbSearchByPort.Checked := Parameters.SearchByPortEnabled;
  sePollInterval.Value := Parameters.DevicePollTime;
  cbCCOType.ItemIndex := Parameters.CCOType;
  seOperatorNumber.Value := Parameters.OperatorNumber;
  seOperatorPassword.Value := Parameters.OperatorPassword;
end;

procedure TfmFptrConnection.UpdateObject;
begin
  Parameters.ConnectionType := cbConnectionType.ItemIndex;
  Parameters.RemoteHost := edtRemoteHost.Text;
  Parameters.RemotePort := seRemotePort.Value;
  Parameters.PortName := cbComPort.Text;
  Parameters.BaudRate := IntToBaudRate(cbBaudRate.ItemIndex);
  Parameters.ByteTimeout := seByteTimeout.Value;
  Parameters.MaxRetryCount := cbMaxRetryCount.ItemIndex;
  Parameters.SearchByBaudRateEnabled := chbSearchByBaudRate.Checked;
  Parameters.SearchByPortEnabled := chbSearchByPort.Checked;
  Parameters.DevicePollTime := sePollInterval.Value;
  Parameters.CCOType := cbCCOType.ItemIndex;
  Parameters.OperatorNumber := seOperatorNumber.Value;
  Parameters.OperatorPassword := seOperatorPassword.Value;
end;

procedure TfmFptrConnection.FormCreate(Sender: TObject);
begin
  CreatePorts(cbComPort.Items);
end;

end.
