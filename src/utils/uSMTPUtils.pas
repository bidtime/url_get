unit uSMTPUtils;

{
2020.11.17 ������������ 465 ssl �ʼ���֮ǰ�����㣬��Ҫע�⣺
  1. idSMTP1.UseTLS := utUseImplicitTLS;
  2. idSMTP1.password := authCode;
}

interface

uses classes;

type
  TSMTPParms = record
    Username: string; //���õ�½�ʺ�
    Password: string; //���õ�¼password
    Host: string; //����SMTP��ַ
    Port: integer; //����port   ����ת��Ϊ����
    UseSSL: boolean;
    SSL_Port: integer;
    AuthCode: string;
    AuthLogin: boolean;   // ��Ҫ��½��֤
    UseAuthCode: boolean;
    ConnectTimeout: integer;
  end;
  TSMTPUtils = class
  private
    class var FLogsEv: TGetStrProc;
    class var FErrorEv: TGetStrProc;
    class procedure showLogs(const S: string);
    class procedure showError(const S: string);
  protected
  public
    class function SendMail(const p: TSMTPParms; const toUser, subject, bodyText: string): boolean; static;
    class property LogsEv: TGetStrProc read FLogsEv write FLogsEv;
    class property ErrorEv: TGetStrProc read FErrorEv write FErrorEv;
  end;

implementation

uses SysUtils, IdBaseComponent, IdMessage, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdSMTP, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdSASL, IdSASLUserPass, IdSASLLogin, IdSASL_CRAM_SHA1, IdText,
    IdSASL_CRAMBase, IdSASL_CRAM_MD5, IdSASLSKey, IdSASLPlain,
    IdSASLOTP, IdSASLExternal, IdSASLDigest, IdSASLAnonymous, IdUserPassProvider;

class function TSMTPUtils.SendMail(const p: TSMTPParms; const toUser: string;
  const subject: string; const bodyText: string): boolean;

  function sendMessage(IdSMTP1: TIdSMTP): boolean;
  var IdMessage1: TIdMessage;
  begin
    IdMessage1 := TIdMessage.Create(nil);
    try
      IdMessage1.Body.Clear;   //������ϴη��͵�����
      IdMessage1.CharSet := 'UTF-8';
      IdMessage1.Subject := subject;               //�����ʼ����͵ı���
      IdMessage1.Body.Text := bodyText;            //�����ʼ����͵�����
      //filename := 'C:\�ļ�.txt';   //��Ҫ��ӵĸ����ļ�
      //TIdAttachment.Create(IdMessage1.MessageParts, filename);  //��Ӹ���
      IdMessage1.From.Address := p.Username;       //�����ʼ��ķ�����
      IdMessage1.Recipients.EMailAddresses := toUser;    //�ռ��˵ĵ�ַ
      //IdMessage1.CCList.EMailAddresses:='7894@126.com';//����
      //IdMessage1.BccList.EmailAddresses:='aaaabbb@gmail.com'; //����
      IdMessage1.Priority:= TIdMessagePriority.mpNormal; //�ʼ���Ҫ��
      try
        idSMTP1.Send(IdMessage1);
        Result := true;
        showLogs(format('send: [%s]-%s, %s', [subject, bodyText, boolToStr(Result, true)]));
      except
        on E: Exception do begin
          showError(format('send error, %s', [E.Message]));
          raise Exception.create(e.message);
        end;
      end;
    finally
      IdMessage1.Free;
    end;
  end;

  function doConnect(IdSMTP1: TIdSMTP): boolean;
  begin
    Result := false;
    try
      IdSMTP1.ConnectTimeout := p.ConnectTimeout;
      IdSMTP1.UseEhlo := True;
      IdSMTP1.Connect;
      if IdSMTP1.Authenticate then begin   // autenticate
        Result := sendMessage(IdSMTP1);
      end;
    except
      on E:Exception do begin
        showError(format('SMTP connect error, %s', [E.Message]));
        raise Exception.create(e.message);
      end;
    end;
  end;

  function InitSASL(SMTP: TIdSMTP): boolean;
  var
    IdUserPassProvider: TIdUserPassProvider;
    IdSASLCRAMMD5: TIdSASLCRAMMD5;
    IdSASLCRAMSHA1: TIdSASLCRAMSHA1;
    IdSASLPlain: TIdSASLPlain;
    IdSASLLogin: TIdSASLLogin;
    IdSASLSKey: TIdSASLSKey;
    IdSASLOTP: TIdSASLOTP;
    IdSASLAnonymous: TIdSASLAnonymous;
    IdSASLExternal: TIdSASLExternal;
  begin
    IdUserPassProvider := TIdUserPassProvider.Create(SMTP);
    IdSASLCRAMSHA1 := TIdSASLCRAMSHA1.Create(SMTP);
    IdSASLCRAMSHA1.UserPassProvider := IdUserPassProvider;
    IdSASLCRAMMD5 := TIdSASLCRAMMD5.Create(SMTP);
    IdSASLCRAMMD5.UserPassProvider := IdUserPassProvider;
    IdSASLSKey := TIdSASLSKey.Create(SMTP);
    IdSASLSKey.UserPassProvider := IdUserPassProvider;
    IdSASLOTP := TIdSASLOTP.Create(SMTP);
    IdSASLOTP.UserPassProvider := IdUserPassProvider;
    IdSASLAnonymous := TIdSASLAnonymous.Create(SMTP);
    IdSASLExternal := TIdSASLExternal.Create(SMTP);
    //
    IdSASLLogin := TIdSASLLogin.Create(SMTP);
    IdSASLLogin.UserPassProvider := IdUserPassProvider;
    //
    IdSASLPlain := TIdSASLPlain.Create(SMTP);
    IdSASLPlain.UserPassProvider := IdUserPassProvider;
    try
      IdUserPassProvider.Username := SMTP.Username;
      IdUserPassProvider.Password := SMTP.Password;
      SMTP.SASLMechanisms.Add.SASL := IdSASLCRAMSHA1;
      SMTP.SASLMechanisms.Add.SASL := IdSASLCRAMMD5;
      SMTP.SASLMechanisms.Add.SASL := IdSASLSKey;
      SMTP.SASLMechanisms.Add.SASL := IdSASLOTP;
      SMTP.SASLMechanisms.Add.SASL := IdSASLAnonymous;
      SMTP.SASLMechanisms.Add.SASL := IdSASLExternal;
      SMTP.SASLMechanisms.Add.SASL := IdSASLLogin;
      SMTP.SASLMechanisms.Add.SASL := IdSASLPlain;
      //
      Result := doConnect(SMTP);
    finally
      IdUserPassProvider.Free;
      IdSASLCRAMMD5.Free;
      IdSASLCRAMSHA1.Free;
      IdSASLPlain.Free;
      IdSASLLogin.Free;
      IdSASLSKey.Free;
      IdSASLOTP.Free;
      IdSASLAnonymous.Free;
      IdSASLExternal.Free;
    end;
  end;

  procedure InitAccount(IdSMTP1: TIdSMTP);
  begin
    IdSMTP1.Username:=p.Username; //���õ�½�ʺ�
    IdSMTP1.Host:=p.host;//p.Host; //����SMTP��ַ
    IdSMTP1.ValidateAuthLoginCapability := p.AuthLogin;//true;
    if p.UseSSL then begin
      IdSMTP1.Port := p.SSL_Port;      //465; //����port   ����ת��Ϊ����
      if p.UseAuthCode then begin
        IdSMTP1.Password := p.AuthCode;
      end else begin
        IdSMTP1.Password := p.Password;
      end;
    end else begin
      IdSMTP1.Port := p.Port;          //25; //����port   ����ת��Ϊ����
      IdSMTP1.Password := p.Password;
    end;
  end;

  function InitSSL(IdSMTP1: TIdSMTP): boolean;
  const SMTP_PORT_EXPLICIT_TLS = 587;
  var SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  begin
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    try
      // SSL/TLS handshake determines the highest available SSL/TLS version dynamically SSLHandler.SSLOptions.Method := sslvSSLv23;
      SSLHandler.SSLOptions.Method:=sslvSSLv23;  //sslvSSLv23  sslvSSLv3
      SSLHandler.SSLOptions.Mode := sslmClient;  //(sslmUnassigned, sslmClient, sslmServer, sslmBoth);
      SSLHandler.SSLOptions.VerifyMode := [];
      SSLHandler.SSLOptions.VerifyDepth := 0;
      IdSMTP1.IOHandler:= SSLHandler;  //���������Ӵ
      //UseTLS: utUseExplicitTLS,  utUseImplicitTLS
      if IdSMTP1.Port = SMTP_PORT_EXPLICIT_TLS then begin
        IdSMTP1.UseTLS := utUseExplicitTLS;
      end else begin
        IdSMTP1.UseTLS := utUseImplicitTLS;
      end;
      if (idSMTP1.Username <> '') or (idSMTP1.Password <> '') then begin
        IdSMTP1.AuthType := satSASL;  //���õ�½����  (satNone, satDefault, satSASL);
        Result := InitSASL(IdSMTP1);
      end else begin
        IdSMTP1.AuthType := satNone;
        Result := doConnect(IdSMTP1);
      end;
    finally
      FreeAndNil(SSLHandler);
    end;
  end;

var IdSMTP1: TIdSMTP;
begin
  IdSMTP1 := TIdSMTP.Create(nil);
  try
    InitAccount(IdSMTP1);
    Result := InitSSL(IdSMTP1);
  finally
    IdSmtp1.Disconnect;
    IdSmtp1.Free;
  end;
end;

class procedure TSMTPUtils.showError(const S: string);
begin
  if Assigned(self.FErrorEv) then begin
    FErrorEv(S);
  end;
end;

class procedure TSMTPUtils.showLogs(const S: string);
begin
  if Assigned(self.FLogsEv) then begin
    FLogsEv(S);
  end;
end;

end.
