unit fmuFptrExtra;

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

  TfmFptrExtra = class(TFptrPage)
    lblPollInterval: TTntLabel;
    sePollInterval: TSpinEdit;
    Bevel2: TBevel;
    lblUsrPassword: TTntLabel;
    seOperatorNumber: TSpinEdit;
    seOperatorPassword: TSpinEdit;
    lblSysPassword: TTntLabel;
    Bevel3: TBevel;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

var
  fmFptrExtra: TfmFptrExtra;

implementation

{$R *.dfm}

{ TfmFptrExtra }

procedure TfmFptrExtra.UpdatePage;
begin
  sePollInterval.Value := Parameters.PollInterval;
  seOperatorNumber.Value := Parameters.OperatorNumber;
  seOperatorPassword.Value := Parameters.OperatorPassword;
end;

procedure TfmFptrExtra.UpdateObject;
begin
  Parameters.PollInterval := sePollInterval.Value;
  Parameters.OperatorNumber := seOperatorNumber.Value;
  Parameters.OperatorPassword := seOperatorPassword.Value;
end;

end.
