unit uSMTPInst;

interface

uses
  System.SysUtils, System.Classes;

type
  TSMTPParamRec = record
    FTimerEnabled: boolean;
    FTimerIterv: integer;
    FTimerIterv_try: integer;
    FNeedConnect: boolean;
    FTimeTryNums: integer;
    //
    SMTP_Username: string; //设置登陆帐号
    SMTP_Password: string; //设置登录password
    SMTP_Host: string; //设置SMTP地址
    SMTP_Port: integer; //设置port   必须转化为整型
    SMTP_UseSSL: boolean;
    SMTP_SSL_Port: integer;
    SMTP_AuthCode: string;
    SMTP_ToUser: string;
    SMTP_AuthLogin: boolean;   // 需要登陆验证
    SMTP_UseAuthCode: boolean;
    SMTP_ConnectTimeout: integer;
    //constructor Create(const json: string);
    procedure init();
    function toJson(): string;
    procedure fromJson(const json: string);
  end;
  TSMTPParamHelp = class
    class function fromJson(const json: string): TSMTPParamRec;
    class function toJson(const u: TSMTPParamRec): string;
    class function fromFJson(): TSMTPParamRec;
    class function toFJson(const r: TSMTPParamRec): boolean;
  end;

  TSMTPParamInst = class
  private
    //FIniChanged: boolean;
    FStatusEv: TGetStrProc;
    FLogsEv: TGetStrProc;
    FErrorEv: TGetStrProc;
    function readWriteIni(const bWrite: boolean): boolean;
    { Private declarations }
    procedure showLogs(const S: string);
    procedure showStatus(const S: string);
    procedure showError(const S: string);
    procedure setJson(const S: string);
  public
    { Public declarations }
    FSmtpPar: TSMTPParamRec;
    constructor Create();
    destructor Destroy(); override;
    procedure initial();
    function getParJson(): string;
//    procedure startMessage(const subject, bodyText: string);
//    procedure stopMessage(const subject, bodyText: string);
    procedure setParJson(const S: string);
    function send(const subject, msgBody: string): boolean;
    property StatusEv: TGetStrProc read FStatusEv write FStatusEv;
    property LogsEv: TGetStrProc read FLogsEv write FLogsEv;
    property ErrorEv: TGetStrProc read FErrorEv write FErrorEv;
    property SmtpPar: TSMTPParamRec read FSmtpPar;// write FErrorEv;
  end;

implementation

uses DateUtils, uFileUtils, uJsonFUtils, uJsonSUtils, System.JSON.Types,
  uDESCrypt, uSMTPUtils;

procedure TSMTPParamInst.showLogs(const S: string);
begin
  if Assigned(self.FLogsEv) then begin
    FLogsEv(S);
  end;
end;

procedure TSMTPParamInst.showStatus(const S: string);
begin
  if Assigned(self.FStatusEv) then begin
    FStatusEv(S);
  end;
end;

procedure TSMTPParamInst.showError(const S: string);
begin
  if Assigned(self.FErrorEv) then begin
    FErrorEv(S);
  end;
end;

constructor TSMTPParamInst.create();
begin
  inherited create();
  //FIniChanged := false;
  readWriteIni(false);
end;

destructor TSMTPParamInst.Destroy;
begin
//  if (FIniChanged) then begin
//    readWriteIni(true);
//  end;
  inherited Destroy;
end;

procedure TSMTPParamInst.initial;
var
  S: string;
begin
  ShowLogs('smtpParam: initial begin...');
  S := FSmtpPar.toJson;
  ShowLogs('smtpParam: ' + S);
  //
  ShowLogs('smtpParam: initial end.');
end;

function TSMTPParamInst.readWriteIni(const bWrite: boolean): boolean;
begin
  if not bWrite then begin
    FSmtpPar := TSMTPParamHelp.fromFJson();
    Result := true;
  end else begin
    Result := TSMTPParamHelp.toFJson(FSmtpPar);
  end;
end;

function TSMTPParamInst.send(const subject, msgBody: string): boolean;

  function getNeed(const subT, bodyT: string): boolean;
  var b: boolean;
    p: TSMTPParms;
  begin
    Result := false;
    try
      p.Username := FSmtpPar.SMTP_Username;
      p.Password := FSmtpPar.SMTP_Password;
      p.Host := FSmtpPar.SMTP_Host;
      p.Port := FSmtpPar.SMTP_Port;
      p.UseSSL := FSmtpPar.SMTP_UseSSL;
      p.SSL_Port := FSmtpPar.SMTP_SSL_Port;
      p.AuthCode := FSmtpPar.SMTP_AuthCode;
      p.AuthLogin := FSmtpPar.SMTP_AuthLogin;
      p.UseAuthCode := FSmtpPar.SMTP_UseAuthCode;
      p.ConnectTimeout := FSmtpPar.SMTP_ConnectTimeout;
      b := TSMTPUtils.SendMail(p, FSmtpPar.SMTP_ToUser, subT, bodyT);
      //self.showLogs(format('send: %d [%s]-%s, %s', [FTrySendNums, subT, bodyT, boolToStr(b, true)]));
      Result := b;
    except
      on E: Exception do begin
        self.showStatus(format('send: [%s], error, %s', [subT, E.Message]));
        self.showError(format('send: [%s]-%s, error, %s', [subT, bodyT, E.Message]));
      end;
    end;
  end;

  function donotNeed(const subT, bodyT: string): boolean;
  begin
    self.showLogs(format('send: [%s]-%s, true, do not need send', [subT, bodyT]));
    Result := true;
  end;
begin
  Result := false;
  if msgBody.IsEmpty then begin
    exit;
  end;
  if FSmtpPar.FNeedConnect then begin
    Result := getNeed(subject, msgBody);
  end else begin
    Result := donotNeed(subject, msgBody);
  end;
end;

function TSMTPParamInst.getParJson: string;
begin
  Result := FSmtpPar.toJson;
end;

procedure TSMTPParamInst.setJson(const S: string);
begin
  FSmtpPar.fromJson(S);
end;

procedure TSMTPParamInst.setParJson(const S: string);
begin
  self.setJson(S);
  self.readWriteIni(true);
  self.initial;
end;

{ TSMTPParamRec }

procedure TSMTPParamRec.fromJson(const json: string);
begin
  self := TSMTPParamHelp.fromJson(json);
end;

procedure TSMTPParamRec.init;
begin
  FTimerIterv := 2 * 1000;
  FTimerIterv_try := 10 * 1000;
  FTimerEnabled := false;
  FNeedConnect := false;
  FTimeTryNums := 5;
  //
  SMTP_AuthLogin := true;
  SMTP_ConnectTimeout := 30000;
  //SMTP_Username:='ecarpo_bms@tom.com'; //设置登陆帐号
  //SMTP_Password:='1qaz@WSX'; //设置登录password
  //SMTP_Host:='smtp.tom.com'; //设置SMTP地址
  SMTP_Port:=25; //设置port   必须转化为整型
end;

{initialization
finalization}

function TSMTPParamRec.toJson: string;
begin
  Result := TSMTPParamHelp.toJson(self);
end;

{ TSMTPParamHelp }

class function TSMTPParamHelp.fromFJson(): TSMTPParamRec;
var fileName: string;
  S: string;
begin
  fileName := TFileUtils.appFile('smtpParamTimer.json');
  Result.init();
  Result := TJsonFUtils.DeserializeNF<TSMTPParamRec>(fileName);
  S := DeCryptStr(Result.SMTP_Password);
  Result.SMTP_Password := S;
  S := DeCrypTStr(Result.SMTP_AuthCode);
  Result.SMTP_AuthCode := S;
end;

class function TSMTPParamHelp.toFJson(const r: TSMTPParamRec): boolean;
var fileName: string;
  S: string;
  u: TSMTPParamRec;
begin
  u := r;
  fileName := TFileUtils.appFile('smtpParamTimer.json');
  S := EnCryptStr(u.SMTP_Password);
  u.SMTP_Password := S;
  S := EnCryptStr(u.SMTP_AuthCode);
  u.SMTP_AuthCode := S;
  TJsonFUtils.SerializeF<TSMTPParamRec>(u, fileName, TJsonFormatting.Indented);
  Result := true;
end;

class function TSMTPParamHelp.fromJson(const json: string): TSMTPParamRec;
begin
  Result.init();
  Result := TJsonSUtils.Deserialize<TSMTPParamRec>(json);
end;

class function TSMTPParamHelp.toJson(const u: TSMTPParamRec): string;
begin
  Result := TJsonSUtils.serialize<TSMTPParamRec>(u);
end;

end.
