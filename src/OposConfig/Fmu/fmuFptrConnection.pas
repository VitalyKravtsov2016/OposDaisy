unit fmuFptrConnection;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin,
  // Tnt
  TntStdCtrls,
  // This
  untUtil, PrinterParameters, FiscalPrinterDevice, FptrTypes, FileUtils;

type
  { TfmFptrConnection }

  TfmFptrConnection = class(TFptrPage)
    gbConenctionParams: TTntGroupBox;
    lblComPort: TTntLabel;
    lblBaudRate: TTntLabel;
    lblByteTimeout: TTntLabel;
    lblMaxRetryCount: TTntLabel;
    lblConnectionType: TTntLabel;
    lblRemoteHost: TTntLabel;
    lblRemotePort: TTntLabel;
    cbComPort: TTntComboBox;
    cbBaudRate: TTntComboBox;
    chbSearchByPort: TTntCheckBox;
    chbSearchByBaudRate: TTntCheckBox;
    cbConnectionType: TTntComboBox;
    edtRemoteHost: TTntEdit;
    gbPassword: TTntGroupBox;
    lblUsrPassword: TTntLabel;
    lblSysPassword: TTntLabel;
    seRemotePort: TSpinEdit;
    seByteTimeout: TSpinEdit;
    seOperatorNumber: TSpinEdit;
    seOperatorPassword: TSpinEdit;
    cbMaxRetryCount: TTntComboBox;
    GroupBox1: TTntGroupBox;
    sePollInterval: TSpinEdit;
    lblPollInterval: TTntLabel;
    lblStatusInterval: TTntLabel;
    seStatusInterval: TSpinEdit;
    seStatusTimeout: TSpinEdit;
    lblStatusTimeout: TTntLabel;
    lblEventsType: TTntLabel;
    cbCCOType: TTntComboBox;
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
var
  Index: Integer;
begin
  cbConnectionType.ItemIndex := Parameters.ConnectionType;
  edtRemoteHost.Text := Parameters.RemoteHost;
  seRemotePort.Value := Parameters.RemotePort;
  cbComPort.ItemIndex := Parameters.PortNumber-1;
  cbBaudRate.ItemIndex := BaudRateToInt(Parameters.BaudRate);
  seByteTimeout.Value := Parameters.ByteTimeout;
  cbMaxRetryCount.ItemIndex := Parameters.MaxRetryCount;
  chbSearchByBaudRate.Checked := Parameters.SearchByBaudRateEnabled;
  chbSearchByPort.Checked := Parameters.SearchByPortEnabled;
  cbPropertyUpdateMode.ItemIndex := Parameters.PropertyUpdateMode;
  sePollInterval.Value := Parameters.PollIntervalInSeconds;
  seStatusInterval.Value := Parameters.StatusInterval;
  cbCCOType.ItemIndex := Parameters.CCOType;
  seUsrPassword.Value := Parameters.UsrPassword;
  seSysPassword.Value := Parameters.SysPassword;
  cbStorage.ItemIndex := Parameters.Storage;
  seStatusTimeout.Value := Parameters.StatusTimeout;
  Index := FModels.IndexById(Parameters.ModelId);
  if Index = -1 then Index := 0;
  cbModel.ItemIndex := Index;
end;

procedure TfmFptrConnection.UpdateObject;
begin
  Parameters.ConnectionType := cbConnectionType.ItemIndex;
  Parameters.PrinterProtocol := cbPrinterProtocol.ItemIndex;
  Parameters.RemoteHost := edtRemoteHost.Text;
  Parameters.RemotePort := seRemotePort.Value;
  Parameters.PortNumber := cbComPort.ItemIndex + 1;
  Parameters.BaudRate := IntToBaudRate(cbBaudRate.ItemIndex);
  Parameters.ByteTimeout := seByteTimeout.Value;
  Parameters.MaxRetryCount := cbMaxRetryCount.ItemIndex;
  Parameters.SearchByBaudRateEnabled := chbSearchByBaudRate.Checked;
  Parameters.SearchByPortEnabled := chbSearchByPort.Checked;
  Parameters.PropertyUpdateMode := cbPropertyUpdateMode.ItemIndex;
  Parameters.PollIntervalInSeconds := sePollInterval.Value;
  Parameters.StatusInterval := seStatusInterval.Value;
  Parameters.CCOType := cbCCOType.ItemIndex;
  Parameters.UsrPassword := seUsrPassword.Value;
  Parameters.SysPassword := seSysPassword.Value;
  Parameters.Storage := cbStorage.ItemIndex;
  Parameters.StatusTimeout := seStatusTimeout.Value;

  Parameters.ModelId := FModels[cbModel.ItemIndex].Data.ID;
end;

procedure TfmFptrConnection.FormCreate(Sender: TObject);
begin
  CreatePorts(cbComPort.Items);
end;

end.
