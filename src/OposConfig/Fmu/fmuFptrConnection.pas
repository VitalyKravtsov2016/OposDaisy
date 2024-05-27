unit fmuFptrConnection;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ExtCtrls,
  // Tnt
  TntStdCtrls,
  // Opos
  Opos,
  // This
  PrinterParameters, FiscalPrinterDevice, FptrTypes, FileUtils, untUtil,
  OposFiscalPrinter;

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
    btnConnect: TButton;
    memResult: TMemo;
    lblCommandTimeout: TTntLabel;
    seCommandTimeout: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure PageModified(Sender: TObject);
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
  cbComPort.ItemIndex := cbComPort.Items.IndexOf(Parameters.PortName);
  if cbComPort.ItemIndex = -1 then
    cbComPort.ItemIndex := 0;
  cbBaudRate.ItemIndex := BaudRateToInt(Parameters.BaudRate);
  seByteTimeout.Value := Parameters.ByteTimeout;
  seCommandTimeout.Value := Parameters.CommandTimeout;
  cbMaxRetryCount.ItemIndex := Parameters.MaxRetryCount;
  chbSearchByBaudRate.Checked := Parameters.SearchByBaudRateEnabled;
  chbSearchByPort.Checked := Parameters.SearchByPortEnabled;
end;

procedure TfmFptrConnection.UpdateObject;
begin
  Parameters.ConnectionType := cbConnectionType.ItemIndex;
  Parameters.RemoteHost := edtRemoteHost.Text;
  Parameters.RemotePort := seRemotePort.Value;
  Parameters.PortName := cbComPort.Text;
  Parameters.BaudRate := IntToBaudRate(cbBaudRate.ItemIndex);
  Parameters.ByteTimeout := seByteTimeout.Value;
  Parameters.CommandTimeout := seCommandTimeout.Value;
  Parameters.MaxRetryCount := cbMaxRetryCount.ItemIndex;
  Parameters.SearchByBaudRateEnabled := chbSearchByBaudRate.Checked;
  Parameters.SearchByPortEnabled := chbSearchByPort.Checked;
end;

procedure TfmFptrConnection.FormCreate(Sender: TObject);
begin
  CreatePorts(cbComPort.Items);
end;

procedure TfmFptrConnection.btnConnectClick(Sender: TObject);
begin
  DisableButtons;
  FiscalPrinter;
  try
    UpdateObject;
    Device.SaveParams;

    memResult.Clear;
    Check(FiscalPrinter.Open(Device.DeviceName));
    Check(FiscalPrinter.ClaimDevice(0));
    FiscalPrinter.DeviceEnabled := True;
    Check(FiscalPrinter.ResultCode);
    Check(FiscalPrinter.CheckHealth(OPOS_CH_INTERNAL));

    memResult.Lines.Add('OK');
    memResult.Lines.Add('Service object: ' + FiscalPrinter.ServiceObjectDescription);
    memResult.Lines.Add('Device description: ' + FiscalPrinter.DeviceDescription);
  except
    on E: Exception do
    begin
      memResult.Lines.Add('ERROR: ' + E.Message);
    end;
  end;
  EnableButtons;
  FiscalPrinter.Close;
  FreeFiscalPrinter;
end;

procedure TfmFptrConnection.PageModified(Sender: TObject);
begin
  Modified;
end;

end.
