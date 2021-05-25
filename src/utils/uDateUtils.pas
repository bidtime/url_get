unit uDateUtils;

interface

uses
  Windows;

type
  TDateUtils = class
  private
    class function RoundFloat(const v: double): string; static;
    { Private declarations }
  public
    { Public declarations }
    class function formatDuring(const mss: LongWord): string; overload;
    class function formatDuring(const dtStart: TDateTime; const dtEnd: TDateTime): string; overload;
    class function duringNow(const dtStart: TDateTime): string; overload;
    class function duringNow(const nStart: LongWord): string; overload;
    class function getTickCt(): LongWord;
    class function DateToTimeStamp(const dt: TDateTime): Int64; static;
    class function DateToTimeStampS(const dt: TDateTime): string; static;
    class function fmtDateTime(const dt: TDateTime): string; static;
    class function UnixDateToDateTime(const USec: Longint): TDateTime; static;
  end;

implementation

uses SysUtils, System.DateUtils;

class function TDateUtils.RoundFloat(const v: double): string;
//var
  //s: string;
  //ef: extended;
begin
  //s := '#.' + StringOfChar('0', n);
  //ef := StrToFloat( FloatToStr(v) );                  //��ֹ������������
  //Result := StrToFloat( FormatFloat(s, ef) );
  Result := IntToStr(integer(trunc(v)));
end;

{
	 *
	 * @param Ҫת���ĺ�����
	 * @return �ú�����ת��Ϊ * days * hours * minutes * seconds ��ĸ�ʽ
	 * @author fy.zhang}
class function TDateUtils.formatDuring(const mss: LongWord): string;
var d, h, m, s, ms: double;
begin
	d := mss / (1000 * 60 * 60 * 24);
	h := (mss mod (1000 * 60 * 60 * 24)) / (1000 * 60 * 60);
	m := (mss mod (1000 * 60 * 60)) / (1000 * 60);
	s := (mss mod (1000 * 60)) / 1000;
	ms := (mss mod (1000));
  Result := format('%s d, %s h, %s m, %s s, %s ms', [
    RoundFloat(d),
    RoundFloat(h),
    RoundFloat(m),
    RoundFloat(s),
    RoundFloat(ms)
  ]);
//	Result := days + ' d, ' + hours + ' h, ' + minutes + ' m, '
//				+ seconds + ' s. ';
end;

{
	 *
	 * @param begin ʱ��εĿ�ʼ
	 * @param end	ʱ��εĽ���
	 * @return	���������Date��������֮���ʱ������* days * hours * minutes * seconds�ĸ�ʽչʾ
	 * @author fy.zhang
	 }
class function TDateUtils.duringNow(const nStart: LongWord): string;
begin
  Result := formatDuring(getTickCount() - nStart);
end;

class function TDateUtils.duringNow(const dtStart: TDateTime): string;
begin
  Result := formatDuring(dtStart, now);
end;

class function TDateUtils.formatDuring(const dtStart: TDateTime;
  const dtEnd: TDateTime): string;
var days, hours, minutes, seconds: Int64;
  diff: TDateTime;
begin
 // System.DateUtils.DaysBetween(dtEnd, FileTime);
  //Days := DaysBetween(dtEnd, FileTime);
  //Hours:= HoursBetween(dtEnd, FileTime)-(Days * 24);
  //Minutes := MinutesBetween(dtEnd, FileTime)-((Days * 24 + Hours) * 60);
  //Seconds := SecondsBetween(dtEnd, FileTime)-(((Days * 24 + Hours)*60+Minutes) * 60);
  //
  {Result := format('%s d, %s h, %s m, %s s', [
    RoundFloat(days, 0),
    RoundFloat(hours, 0),
    RoundFloat(minutes, 0),
    RoundFloat(seconds, 0)
  ]);}
  diff := dtEnd - dtStart;
end;

class function TDateUtils.getTickCt: LongWord;
begin
  Result := getTickCount;
end;

// ����ת����ʱ���

class function TDateUtils.DateToTimeStamp(const dt: TDateTime): Int64;
begin
 Result := DateTimeToUnix(IncHour(dt, -8)); //  ����ʱ���8Сʱ
end;

//function Gettimestamp: long;
//begin
// Result := DateTimeToUnix(IncHour(Now,-8)); //  ����ʱ���8Сʱ
//end;

//ʱ���ת��������

class function TDateUtils.UnixDateToDateTime(const USec: Longint): TDateTime;
const UnixStartDate: TDateTime = 25569.0; // 1970/01/01
begin
  Result:= (Usec / 86400) + UnixStartDate;
  Result:= IncHour(Result,8);
end;

class function TDateUtils.DateToTimeStampS(const dt: TDateTime): string;
begin
 Result := inttostr(DateToTimeStamp(dt)); //  ����ʱ���8Сʱ
end;

class function TDateUtils.fmtDateTime(const dt: TDateTime): string;
begin
  Result := formatdatetime('yyyy-mm-dd hh:nn:ss ZZZ', dt);
end;

end.
