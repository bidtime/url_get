unit uVerInfo;

interface

const
  CompanyName = 'bidtime';
  TelInfo1 = '�ֻ�: 13121385119';
  TelInfo2 = 'QQ: 373226941';
  WebAddress = 'email: riverbo@126.com';
  Version = 0.1;
  Build = '2020.09.17';
  AppExt = '����';
  AppName = 'url monitor';

  function getAppInfo: string;
  function getVerInfo: string;

implementation

uses ShellApi, SysUtils, Forms, Windows, uFileUtils, IOUtils;

function getAppInfo: string;
begin
  Result := AppName + ' ' +
    AppExt + ' ' +
    '�汾��' + FloatToStr(Version) +
    '(build ' + Build + ')'
    ;
end;

function getVerInfo: string;
begin
  Result := 'ver:' + FloatToStr(Version) + '(' + Build + ')';
end;

end.

