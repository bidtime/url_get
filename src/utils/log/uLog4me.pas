unit uLog4me;

interface

uses classes, uLogFile;

type
  TLog4me = class
  private
    { Private declarations }
    class var FLogFile: TLogFile;
  public
    { Public declarations }
    class procedure error(msg: AnsiString); //дERROR�������־
    class procedure warn(msg: AnsiString);  //дERROR�������־
    class procedure info(msg: AnsiString);  //дINFO�������־
    class procedure debug(msg: AnsiString); //дDEBUG�������־
    class constructor create();
    class destructor Destroy();
  end;

implementation

{TLog4me}

class constructor TLog4me.create();
begin
  FLogFile := TLogFile.create('');
end;

class destructor TLog4me.Destroy;
begin
  if Assigned(FLogFile) then begin
    FLogFile.Free;
  end;
end;

//-----����4���Ƕ��ⷽ��-------------------------

class procedure TLog4me.error(msg: AnsiString); //дERROR�������־
begin
  FLogFile.error(msg);
end;

class procedure TLog4me.warn(msg: AnsiString); //дERROR�������־
begin
  FLogFile.warn(msg);
end;

class procedure TLog4me.info(msg: AnsiString); //дINFO�������־
begin
  FLogFile.info(msg);
end;

class procedure TLog4me.debug(msg: AnsiString); //дDEBUG�������־
begin
  FLogFile.debug(msg);
end;

end.
