UNIT uCola;

                             INTERFACE
CONST
  NAVE  = 0;
  BALAU = 1;
  BALAN = 2;

TYPE
  PCB = RECORD
          PID  : Integer;
          Dir  : Integer;
          Tipo : Integer;    //NAVE, BALAU, BALAN.
          x, y, Ancho, Alto, Color : Integer;
          Hora, Retardo             : Cardinal;
        END;



CONST
  MAX = 200;

TYPE
  Cola = class
    private
      V : Array[1..MAX] of PCB;   //Implementacion: Cola Circular
      F, A : Integer;

    public
      constructor Create;
       //Construye una cola vacía.

      procedure Init;
       //Inicializa la cola.  Es decir, pone a la cola vacía.

      function Length : Integer;
       //Devuelve la cantidad de elementos de la cola.

      procedure Meter(P : PCB);
       //Inserta P a la cola.

      function Sacar : PCB;
       //Saca un PCB de la cola.
  end;


  
                          IMPLEMENTATION
uses SysUtils;


constructor Cola.Create;
begin
  Init();
end;

procedure Cola.Init;
begin
  A := 0;
end;

function Cola.Length: Integer;
begin
  if (A=0) then
     RESULT := 0
  else
    if (F <= A) then
       RESULT := A-F+1
    else
      RESULT := A + (MAX-F+1);
end;


procedure Cola.Meter(P: PCB);
begin
  if (Length() = MAX) then
     raise Exception.Create('Cola.Meter: Cola llena.');

  if (A = 0) then
     begin  //Primera inserción.
       A:=1;  F:=1;
     end
  else
    A := (A MOD MAX) + 1;

  V[A] := P;
end;


function Cola.Sacar: PCB;
begin
  if (Length() = 0) then
     raise Exception.Create('Cola.Sacar: Cola vacía.');

  RESULT := V[F];

  if (F=A) then
     Init() //Dar condición de vacío.
  else
    F := (F MOD MAX) + 1;
end;


END.
