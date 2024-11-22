program JuegoSO1;

uses
  Forms,
  uFrmMain in 'uFrmMain.pas' {Form1},
  uCola in 'uCola.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
