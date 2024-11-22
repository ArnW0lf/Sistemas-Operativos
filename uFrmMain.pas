unit uFrmMain;

interface

uses
  uCola,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus;

type
  TForm1 = class(TForm)
    MainMenu: TMainMenu;
    Juego1: TMenuItem;
    Jugar: TMenuItem;
    N1: TMenuItem;
    Salir: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure JugarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SalirClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    User   : PCB;       //Para almacenar al personaje del usuario.  Este PCB no se encolará, y por tanto no lo manipulará el PlanificadorRR.
    Q      : Cola;      //Cola del Planificador RR.
    Estado : Integer;   //0=No pasa nada, 1=Murió el User, 2=Murió la Nave
    canon  : PCB;

    procedure InitJuego();
    procedure CicloJuego;
    procedure Planificador();

    procedure MoverNave(PRUN : PCB);
    procedure MoverBalaN(PRUN : PCB);
    procedure MoverBalaU(PRUN : PCB);


    procedure cls;
    procedure Dibujar(P:PCB);
    procedure Borrar(P:PCB);
    //procedure Rectangulo(x,y, Ancho, Alto, Color : Integer);
    procedure Circulo(x, y, Ancho, Alto, Color: Integer);

    function ColisionBalaCanon(Bala, canon: PCB): Boolean;
    function ColisionBalaNave(Bala, Nave: PCB): Boolean;
    function MaxX : Integer;
    function MaxY : Integer;
  public

  end;



var
  Form1: TForm1;

implementation
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);

begin
  Q := Cola.Create;    //Construir (new) la cola del PlanificadorRR.
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Estado := -1;       //Salir del while (Estado=0) del proc. CicloJuego()
  CanClose := true;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
 var
   X2Canon : Integer;
   P : PCB;

begin  //Evento: Se presionó una tecla.
   if not canon.Activo then
    Exit;

  case Key of
    VK_LEFT : begin
                Borrar(canon);
                canon.x := canon.x - 5;
                if canon.x < 0
                   then
                     canon.x := 0;    //Clamp X a 0

                Dibujar(canon);
              end;

    VK_RIGHT : begin
                Borrar(canon);
                canon.x := canon.x + 5;
                X2Canon := canon.x + canon.Ancho - 1;

                if X2Canon > MaxX
                   then
                     canon.x := MaxX-canon.ancho+1;

                Dibujar(canon);
               end;

    VK_SPACE : begin
                 P.Tipo := BALAU;
                 P.Alto  := 15;
                 P.Ancho := 5;
                 P.Color := clGreen;
                 P.Retardo := 25;
                 P.y := canon.y - P.Alto;
                 P.x := (canon.ancho - P.Ancho) div 2 + canon.x;

                 P.Hora := GetTickCount();
                 Dibujar(P);
                 Q.Meter(P);
               end;
  end;
end;

procedure TForm1.JugarClick(Sender: TObject);
begin
  InitJuego();
end;


procedure TForm1.SalirClick(Sender: TObject);
begin
  close();  //Generar el evento FormCloseQuery
end;

procedure TForm1.InitJuego;
  var
    P : PCB;
    i : Integer;
    TercioAncho: Integer;

begin
    //showMessage('La Hora es '+IntToStr( getTickCount() ));
    cls();

    TercioAncho := MaxX div 3;

    //Pone el cañon en el centro de la parte inf de la pantalla.
    canon.ancho :=30; canon.Alto := 30;
    canon.y := MaxY - canon.Alto;
    canon.x := (MaxX-canon.Ancho) div 2; //(MaxX div 2)- (canon.Ancho div 2);
    canon.Color := clGreen;
    canon.Activo := true;
    Dibujar(canon);

    //Iniciar (vaciar) la cola Q
    Q.Init();

    for i := 0 to 2 do
    begin

      //Crear la Nave y su PCB y depositarla en la cola
     P.Tipo := NAVE;
     P.ancho :=30; P.Alto := 30;
     P.y := 0;
     P.x := i * TercioAncho + (TercioAncho - P.Ancho) div 2;
     P.Color := clRed;
     P.Retardo := 100;
     P.Hora := GetTickCount();
     P.Dir := 1;



     Dibujar(P);

     Q.Meter(P);
    end;

   CicloJuego();
end;




procedure TForm1.CicloJuego;
begin
  Estado := 0;

  while Estado=0 do
  begin
    Planificador();
    Application.ProcessMessages();  //Para procesar los eventos del user.
  end;

end;


procedure TForm1.Planificador;
 var
   PRUN : PCB;
begin
  PRUN := Q.Sacar();

  if (PRUN.Hora + PRUN.Retardo > GetTickCount() ) then
  begin
    if PRUN.Activo then  // Solo reencola si el PCB está activo
      Q.Meter(PRUN);
  end
     else //Dispatch PRUN
        case PRUN.Tipo of
          NAVE  : MoverNave(PRUN);
          BALAN : MoverBalaN(PRUN);
          BALAU : MoverBalaU(PRUN);
        end;
end;


procedure TForm1.MoverNave(PRUN: PCB);
var
  TercioAncho, Inicio, Fin: Integer;
  P: PCB;
begin
  Borrar(PRUN);

  TercioAncho := MaxX div 3;
  Inicio := (PRUN.x div TercioAncho) * TercioAncho;
  Fin := Inicio + TercioAncho - PRUN.Ancho;

  PRUN.x := PRUN.x + (5 * PRUN.Dir);


  if (PRUN.x < Inicio) or (PRUN.x > Fin) then
  begin
    PRUN.Dir := -PRUN.Dir;
    PRUN.x := PRUN.x + (5 * PRUN.Dir);
  end;

  PRUN.Hora := GetTickCount();
  Dibujar(PRUN);
  Q.Meter(PRUN);


  if Random(10) = 0 then
  begin

    P.Tipo := BALAN;
    P.Retardo := 25;
    P.Ancho := 5;
    P.Alto := 15;
    P.Color := clRed;
    P.x := PRUN.x + (PRUN.Ancho div 2) - (P.Ancho div 2);
    P.y := PRUN.y + PRUN.Alto;
    P.Hora := GetTickCount();
    P.Activo := True;

    Dibujar(P);
    Q.Meter(P);
  end;
end;



{
procedure TForm1.MoverNave(PRUN: PCB);
 var
   P : PCB;

begin
  Borrar(PRUN);
  PRUN.x := PRUN.x + (5 * PRUN.Dir);

  if (PRUN.x <= 0) then
    PRUN.Dir := 1
  else if (PRUN.x + PRUN.Ancho >= MaxX()) then
    PRUN.Dir :=-1;

  PRUN.Hora := GetTickCount();
  Dibujar(PRUN);
  Q.Meter(PRUN);

  if (Random(10)=0) then
      begin
        P.Tipo := BALAN;
        P.Retardo := 25;
        P.Ancho := 5; P.Alto:=15;
        P.Color := clRed;
        P.y := PRUN.y + PRUN.Alto;
        P.x := (PRUN.ancho - P.Ancho) div 2 + PRUN.x;

        P.Hora := getTickCount;
        P.Activo := true;

        Dibujar(P);
        Q.Meter(P)
      end;
end;
}

procedure TForm1.MoverBalaN(PRUN: PCB);
begin
  Borrar(PRUN);
  PRUN.y := PRUN.y + 5;

  if ColisionBalaCanon(PRUN, Canon) then
  begin
    canon.Activo := false;
    Borrar(canon);
  end
  else
  begin
    if (PRUN.y < MaxY)
     then
       begin
          PRUN.Hora := GetTickCount;
          Prun.Activo:=true;
          Dibujar(PRUN);
          Q.Meter(PRUN);
       end;
  end;
end;


procedure TForm1.MoverBalaU(PRUN: PCB);
begin
  Borrar(PRUN);
  PRUN.y := PRUN.y - 5;

    if (PRUN.y > 0)
     then
       begin
          PRUN.Hora := GetTickCount;
          PRUN.Activo:=true;
          Dibujar(PRUN);
          Q.Meter(PRUN);
       end;
end;



function TForm1.ColisionBalaCanon(Bala, Canon: PCB): Boolean;
begin
  result := (Bala.x + bala.Ancho >= Canon.x) and
            (Bala.x <= Canon.x + Canon.Ancho) and
            (Bala.y + Bala.Alto >= Canon.y) and
            (Bala.y <= canon.y + canon.Alto)
end;


function TForm1.ColisionBalaNave(Bala, Nave: PCB): Boolean;
begin
  Result := (Bala.x + Bala.Ancho >= Nave.x) and
            (Bala.x <= Nave.x + Nave.Ancho) and
            (Bala.y + Bala.Alto >= Nave.y) and
            (Bala.y <= Nave.y + Nave.Alto);
end;
//------------ Funciones para Manipular los "Gráficos" -------------------------
procedure TForm1.cls;
begin //Borra el canvas (lienzo) del formulario
  //Rectangulo(0,0, MaxX()+1, MaxY()+1, Color);
  Circulo(0,0, MaxX()+1, MaxY()+1, Color);
end;

procedure TForm1.Dibujar(P: PCB);
begin  //Dibuja al PCB P como un rectangulo en la pantalla.
  //Rectangulo(P.x, P.y, P.Ancho, P.Alto, P.Color);
  Circulo(P.x, P.y, P.Ancho, P.Alto, P.Color);
end;


procedure TForm1.Borrar(P: PCB);
begin //Dibuja al PCB P como un rectangulo en la pantalla, del mismo color del Form.
  //Rectangulo(P.x, P.y, P.Ancho, P.Alto, SELF.Color);
  circulo(P.x, P.y, P.Ancho, P.Alto, SELF.Color);
end;

{
procedure TForm1.Rectangulo(x, y, Ancho, Alto, Color: Integer);
begin   //Dibuja un rectangulo con esquina superior Izq en (x,y).
  Canvas.Pen.Color := Color;
  Canvas.Brush.Color := Color;
  Canvas.Rectangle(x, y, x+Ancho-1, y+Alto-1);
end;
}
procedure TForm1.Circulo(x, y, Ancho, Alto, Color: Integer);
begin
  // Dibuja un círculo dentro de un rectángulo con esquina superior izquierda en (x, y)
  // y dimensiones Ancho y Alto, con el color especificado
  Canvas.Pen.Color := Color;
  Canvas.Brush.Color := Color;
  Canvas.Ellipse(x, y, x + Ancho, y + Alto);
end;



function TForm1.MaxX: Integer;
begin
  RESULT := ClientWidth-1;
end;

function TForm1.MaxY: Integer;
begin
  RESULT := ClientHeight-1;
end;


END.
