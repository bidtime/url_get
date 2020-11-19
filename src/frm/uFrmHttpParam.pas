unit uFrmHttpParam;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFrmHttpParam = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    memoHttpParams: TMemo;
    memoSMTPParams: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
    class function showNewModel(var sHttpParam, sSMTPParam: string): boolean;
  end;

implementation

{$R *.dfm}

{ TFrmHttpParam }

class function TFrmHttpParam.showNewModel(var sHttpParam, sSMTPParam: string): boolean;
var
  Frm: TFrmHttpParam;
begin
  Result := false;
  Frm := TFrmHttpParam.Create(nil);
  try
    frm.memoHttpParams.Text := sHttpParam;
    frm.memoSMTPParams.Text := sSMTPParam;
    if Frm.ShowModal = mrOk then begin
      sHttpParam := frm.memoHttpParams.Text;
      sSMTPParam := frm.memoSMTPParams.Text;
      Result := true;
    end;
  finally
    frm.Free;
  end;
end;

end.
