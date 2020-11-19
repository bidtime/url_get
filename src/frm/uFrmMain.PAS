unit uFrmMain;

interface

uses Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.Menus, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdActns, Vcl.ActnList, Vcl.ToolWin, System.ImageList,
  System.Actions, Messages, uAppConst, uHttpParamTimer, uSMTPParamTimer;

type
  TfrmMain = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    ToolButton9: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ActionList1: TActionList;
    FileNew1: TAction;
    FileOpen1: TAction;
    FileSave1: TAction;
    FileSaveAs1: TAction;
    FileExit1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    HelpAbout1: TAction;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    memoLogs: TMemo;
    ToolButton7: TToolButton;
    edtHttpUrl: TEdit;
    Button1: TButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    actnFileProps: TAction;
    TrayIcon1: TTrayIcon;
    PopupMenu: TPopupMenu;
    miProperties: TMenuItem;
    MenuItem1: TMenuItem;
    miClose: TMenuItem;
    Button2: TButton;
    ToolButton11: TToolButton;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure actnFilePropsExecute(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miPropertiesClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
  private
    FClosing: Boolean;
    //FProgmanOpen: Boolean;
    FFromService: Boolean;
    NT351: Boolean;
    FHttpParamTimer: THttpParamTimer;
    FSMTPParamTimer: TSMTPParamTimer;
    procedure addLog(const S: string; const clear: boolean); overload;
    procedure addLog(const S: string); overload;
    function readWriteIni(const bWrite: boolean): boolean;
    procedure ShowStatus(const S: string);
    procedure OnStartSendMail(const S: string);
    procedure OnStopSendMail(const S: string);
    //
    procedure UIInitialize(var Message: TMessage); message UI_INITIALIZE;
    //定义系统消息
    procedure SysCommand(var SysMsg: TMessage); message WM_SYSCOMMAND;
    procedure errorHintS(const S: string; const sec: integer); overload;
    procedure infoHintS(const S: string; const sec: integer); overload;
    procedure errorHintS(const S: string); overload;
    procedure infoHintS(const S: string); overload;
    procedure addError(const S: string);
    { Private declarations }
  public
    { Public declarations }
    procedure Initialize(const FromService: Boolean);
    procedure popHint(const S: string; const bf: TBalloonFlags;
      const tmSecs: integer);  //系统消息
  end;

var
  frmMain: TfrmMain;

implementation

uses uFrmAboutbox, uFormIniFiles, SysUtils, uFileUtils, uFrmHttpParam, uLog4me,
  uSMTPUtils;

{$R *.dfm}

procedure TfrmMain.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;

procedure TfrmMain.FileOpen1Execute(Sender: TObject);
begin
  OpenDialog.Execute;
end;

procedure TfrmMain.FileSave1Execute(Sender: TObject);
begin
  SaveDialog.Execute;
end;

procedure TfrmMain.addLog(const S: string; const clear: boolean);
begin
  if clear then begin
    memoLogs.clear;
  end;
  if memoLogs.Lines.Count>5000 then begin
    memoLogs.Lines.Delete(memoLogs.Lines.Count-1);
  end;
  memoLogs.Lines.Insert(0, FormatDateTime('yyyy-mm-dd hh:nn:ss ', now())  + S );
end;

procedure TfrmMain.actnFilePropsExecute(Sender: TObject);
var sHttpParam, sSMTPParam: string;
begin
  sHttpParam := FHttpParamTimer.getParJson();
  sSMTPParam := FSMTPParamTimer.getParJson();
  if TFrmHttpParam.showNewModel(sHttpParam, sSMTPParam) then begin
    FHttpParamTimer.setParJsonStart(sHttpParam);
    FSMTPParamTimer.setParJsonStart(sSMTPParam);
  end;
end;

procedure TfrmMain.addLog(const S: string);
begin
  TLog4me.debug(S);
  addLog(S, false);
end;

procedure TfrmMain.addError(const S: string);
begin
  TLog4me.error(S);
  addLog(S, false);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  FHttpParamTimer.get(self.edtHttpUrl.Text);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
var str: string;
begin
  str := FormatDateTime('yyyy-mm-dd hh:nn:ss ', now());
  //TMailUtils.SendMail('373226941@qq.com;814364756@qq.com', 'test mail', 'test send it');
  FSMTPParamTimer.send('subject ' + str, 'body test ' + str);
  //self.OnSendMail('no connect');
end;

procedure TfrmMain.ShowStatus(const S: string);
var str: string;
begin
  str := FormatDateTime('yyyy-mm-dd hh:nn:ss ', now()) + S ;
  //ShowPanel(str, 1);
  self.StatusBar.SimpleText := str;
  //addLog(S);
end;

procedure TfrmMain.SysCommand(var SysMsg: TMessage);
begin
  case SysMsg.WParam of
   SC_MINIMIZE: begin  //如果单击最小化的时候
     //self.TrayIcon1.Visible := true;
     self.Visible := not self.Visible;//互斥，就是你有我没有你没有我就有
     end;
   SC_CLOSE: begin
     //self.TrayIcon1.Visible := true;
     self.Visible := not self.Visible;//互斥，就是你有我没有你没有我就有
   end else begin
     inherited;
   end;
  end;
end;

procedure TfrmMain.TrayIcon1DblClick(Sender: TObject);
begin
  miPropertiesClick(miProperties);
end;

procedure TfrmMain.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var pt: TPoint;
begin
  if Button = mbRight then begin
    //if not Visible then begin
      //SetForegroundWindow(Handle);
      GetCursorPos(pt);
      PopupMenu.Popup(pt.x, pt.y);
    //end else begin
    //  SetForegroundWindow(Handle);
    //end;
  end;
end;

procedure TfrmMain.UIInitialize(var Message: TMessage);
var b: boolean;
begin
  b := (Message.WParam <> 0);
  //TLog4Me.info('p:' + IntToStr(Message.WParam));
  //TLog4Me.info('b:' + BoolToStr(b, true));
  Initialize(b);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  TFormIniFiles.rwIni(self, false);
  FClosing := False;
  addLog('', true);
  FHttpParamTimer := THttpParamTimer.Create;
  FSMTPParamTimer := TSMTPParamTimer.Create;
  //
  readWriteIni(false);
  //self.TrayIcon1.Hint := self.Caption;
  //self.TrayIcon1.Icon.Handle := Forms.Application.Icon.Handle;
  FHttpParamTimer.StatusEv := showStatus;
  FHttpParamTimer.LogsEv := addLog;
  FHttpParamTimer.ErrorEv := addError;
  FHttpParamTimer.PopError := self.errorHintS;
  FHttpParamTimer.PopInfo := self.infoHints;
  FHttpParamTimer.SendMailEv := self.OnStartSendMail;
  FHttpParamTimer.SuccessEv := self.OnStopSendMail;
  FHttpParamTimer.initial;
  FHttpParamTimer.get();
  //
  FSMTPParamTimer.StatusEv := showStatus;
  FSMTPParamTimer.LogsEv := addLog;
  FSMTPParamTimer.ErrorEv := addError;
  FSMTPParamTimer.PopError := self.errorHintS;
  FSMTPParamTimer.PopInfo := self.infoHints;
  FSMTPParamTimer.initial;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  TFormIniFiles.rwIni(self, true);
  readWriteIni(true);
  FHttpParamTimer.Free;
  FSMTPParamTimer.Free;
end;

procedure TfrmMain.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.HelpAbout1Execute(Sender: TObject);
begin
  TFrmAboutBox.showNewForm;
end;

procedure TfrmMain.Initialize(const FromService: Boolean);
begin
  FFromService := FromService;
  NT351 := (Win32MajorVersion <= 3) and (Win32Platform = VER_PLATFORM_WIN32_NT);
  if NT351 then begin
    if not FromService then begin
      raise Exception.CreateRes(@SServiceOnly);
    end;
    BorderIcons := BorderIcons + [biMinimize];
    BorderStyle := bsSingle;
  end;
  //ReadSettings;
  if FromService then begin
    miClose.Visible := False;
    N1.Visible := False;
  end;
end;

procedure TfrmMain.miCloseClick(Sender: TObject);
begin
  FClosing := True;
  Close;
end;

procedure TfrmMain.miPropertiesClick(Sender: TObject);
begin
  //Show;
  self.Visible := not self.Visible;
  if Visible then begin
    SetForegroundWindow(Handle);
  end;
end;

procedure TfrmMain.OnStartSendMail(const S: string);
var dtTime: string;
begin
  dtTime := formatDateTime('YYYY-MM-DD hh:nn:ss', now());
  //
  FSMTPParamTimer.startMessage(
    format('[X]告警: vpn连接错误, %s', [dtTime]),      // subject text
    format(                                        // body text
      '%s' +
      '%s' +
      '%s',
      [
        S + '. ' + #13#10,
        '请用windows远程连接登陆 47.92.90.248, 检查IE中的vpn连接. ' + #13#10,
        '用户名：erp_sync/mina_kipo@126.com '
      ]
    )
  );
end;

procedure TfrmMain.OnStopSendMail(const S: string);
var dtTime: string;
begin
  dtTime := formatDateTime('YYYY-MM-DD hh:nn:ss', now());
  FSMTPParamTimer.stopMessage(
    format('[√]提示: vpn连接成功, %s', [dtTime]),   // subject text
    format('%s, %s', [S, dtTime])                   // body text
  );
end;

function TfrmMain.readWriteIni(const bWrite: boolean): boolean;
begin
  if not bWrite then begin
    edtHttpUrl.Text := FHttpParamTimer.HttpPar.FServerUrl;
    Result := true;
  end else begin
    //dmHttpUtils.HttpPar.FServerUrl := edtHttpUrl.Text;
    Result := true;
  end;
end;

procedure TfrmMain.popHint(const S: string; const bf: TBalloonFlags; const tmSecs: integer);
begin
  TrayIcon1.Animate:=true;
  TrayIcon1.BalloonFlags := bf;
  //TrayIcon1.Hint := self.Caption;
  //bfNone = NIIF_NONE, bfInfo = NIIF_INFO, bfWarning = NIIF_WARNING, bfError = NIIF_ERROR
  if bf = bfError then begin
    TrayIcon1.BalloonTitle := '错误';
  end else if bf = bfWarning then begin
    TrayIcon1.BalloonTitle := '警告';
  end else begin
    TrayIcon1.BalloonTitle := '提示';
  end;
  TrayIcon1.BalloonHint := S;
  TrayIcon1.BalloonTimeout := tmSecs;
  TrayIcon1.ShowBalloonHint;
end;

procedure TfrmMain.infoHintS(const S: string; const sec: integer);
begin
  popHint(S, bfInfo, sec * 1000);
end;

procedure TfrmMain.errorHintS(const S: string; const sec: integer);
begin
  popHint(S, bfError, sec * 1000);
end;

procedure TfrmMain.errorHintS(const S: string);
begin
  errorHintS(S, 30);
end;

procedure TfrmMain.infoHintS(const S: string);
begin
  infoHintS(S, 30);
end;

end.
