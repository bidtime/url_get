unit uSMTPParamTimer;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, uSMTPInst;

type
  TSMTPParamTimer = class
  private
    FStatusEv: TGetStrProc;
    FPopError: TGetStrProc;
    FPopInfo: TGetStrProc;
    FLogsEv: TGetStrProc;
    FErrorEv: TGetStrProc;
    FMsgSubject: string;
    FMsgBody: string;
    FErrors: boolean;
    FTrySendNums: integer;
    procedure Timer1OnTimer(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    FSmtpInst: TSMTPParamInst;
    FTimer1: TTimer;
    constructor Create();
    destructor Destroy(); override;
    procedure initial();
    function getParJson(): string;
    procedure startMessage(const subject, bodyText: string);
    procedure stopMessage(const subject, bodyText: string);
    procedure setParJsonStart(const S: string);
    function send(const subject, msgBody: string): boolean;
    property SmtpInst: TSMTPParamInst read FSmtpInst;// write FErrorEv;
  end;

implementation

uses DateUtils;

constructor TSMTPParamTimer.create();
begin
  inherited create();
  FSmtpInst := TSMTPParamInst.Create;
  FErrors := false;
  FTrySendNums := 0;
  FTimer1 := TTimer.Create(nil);
  FTimer1.OnTimer := Timer1OnTimer;
end;

destructor TSMTPParamTimer.Destroy;
begin
  FTimer1.Free;
  FSmtpInst.free;
  inherited Destroy;
end;

procedure TSMTPParamTimer.initial;
var
  S: string;
begin
//  ShowLogs('smtpParamTimer: initial begin...');
//  S := TJsonSUtils.Serialize<TSMTPParamRec>(FSmtpPar, TJsonFormatting.Indented);
//  ShowLogs('smtpParam: ' + S);
  //
  self.FTimer1.Interval := FSmtpInst.SmtpPar.FTimerIterv;
  self.FTimer1.Enabled := FSmtpInst.SmtpPar.FTimerEnabled;
  //
  //ShowLogs('smtpParamTimer: initial end.');
end;

procedure TSMTPParamTimer.Timer1OnTimer(Sender: TObject);
var b: boolean;
begin
  self.FTimer1.Enabled := false;
  try
    b := send(FMsgSubject, FMsgBody);
    if (FTrySendNums = -1) then begin
      if (b) then begin
        FMsgBody := '';
      end;
    end else begin
      if (b) or (FTrySendNums >= FSmtpInst.SmtpPar.FTimeTryNums) then begin
        FMsgBody := '';
        FTrySendNums := 0;
      end else begin
        Inc(FTrySendNums);
      end;
    end;
  finally
    self.FTimer1.Enabled := true;
  end;
end;

function TSMTPParamTimer.send(const subject, msgBody: string): boolean;
begin
  Result := FSmtpInst.send(subject, msgBody);
end;

function TSMTPParamTimer.getParJson: string;
begin
  Result := self.FSmtpInst.getParJson;
end;

procedure TSMTPParamTimer.startMessage(const subject, bodyText: string);
begin
  if not FErrors then begin
    FErrors := true;
    self.FMsgSubject := subject;
    self.FMsgBody := bodyText;
  end;
end;

procedure TSMTPParamTimer.stopMessage(const subject, bodyText: string);
begin
  if FErrors then begin
    FErrors := false;
    self.FMsgSubject := subject;
    self.FMsgBody := bodyText;
  end;
end;

procedure TSMTPParamTimer.setParJsonStart(const S: string);
begin
  self.FSmtpInst.setParJson(S);
  self.initial;
end;

{initialization
finalization}

end.
