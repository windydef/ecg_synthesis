unit ECGsyntesis;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls, math,
  Vcl.ComCtrls;

type
  arraybaru = array[-99..999999]of real;

  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    GroupBox1: TGroupBox;
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    ScrollBar3: TScrollBar;
    ScrollBar4: TScrollBar;
    ScrollBar5: TScrollBar;
    GroupBox2: TGroupBox;
    ScrollBar6: TScrollBar;
    ScrollBar7: TScrollBar;
    ScrollBar8: TScrollBar;
    ScrollBar9: TScrollBar;
    ScrollBar10: TScrollBar;
    GroupBox3: TGroupBox;
    ScrollBar11: TScrollBar;
    ScrollBar12: TScrollBar;
    ScrollBar13: TScrollBar;
    ScrollBar14: TScrollBar;
    ScrollBar15: TScrollBar;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    ProgressBar1: TProgressBar;
    Chart2: TChart;
    Series2: TLineSeries;
    Chart1: TChart;
    Chart3: TChart;
    Series4: TLineSeries;
    Chart4: TChart;
    Series5: TLineSeries;
    Series1: TLineSeries;
    Series3: TLineSeries;
    procedure sintesisecg;
    procedure rungekutta(t, h : extended);
    procedure derivpqrst(t0:extended;x:array of extended);
    function angfreq(t:extended) : extended;
    procedure parameterpqrs;
    procedure Button1Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure ScrollBar3Change(Sender: TObject);
    procedure ScrollBar4Change(Sender: TObject);
    procedure ScrollBar5Change(Sender: TObject);
    procedure ScrollBar6Change(Sender: TObject);
    procedure ScrollBar7Change(Sender: TObject);
    procedure ScrollBar8Change(Sender: TObject);
    procedure ScrollBar9Change(Sender: TObject);
    procedure ScrollBar10Change(Sender: TObject);
    procedure ScrollBar11Change(Sender: TObject);
    procedure ScrollBar12Change(Sender: TObject);
    procedure ScrollBar13Change(Sender: TObject);
    procedure ScrollBar14Change(Sender: TObject);
    procedure ScrollBar15Change(Sender: TObject);
    procedure ECG;
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  n, sf, hrmean, hrstd :integer;
  lfhfratio, flo, fhi, flostd, fhistd : extended;
  w1, w2, c1, c2, sig1, sig2 : extended;
  rrmean, rrstd, df, dw1, dw2, Nrr, xstd :extended;
  w, hw, sw, ph0, ph, swc, rr, ti, dxdt, ai, bi, x : arraybaru;
  h, tecg, ratio, nt, maxrange, minrange, anoise : extended;
  hrfact, hrfact2, tstep, sfecg, rseed :extended;
  hasilidft, zt, xt, yt : array[0..999999] of extended;
  rrpc : arraybaru;

  const
  xinitial =1.0;
  yinitial =0.0;
  zinitial =0.04;
  seed = 1;

implementation

{$R *.dfm}

{ TForm1 }

{ TForm1 }
procedure Tform1.parameterpqrs;
begin
//PARAMETER UMUM
  sf := 256;                                           //sampling frequency
  hrmean := 60;                                        //heart rate mean
  hrstd := 1;                                          //heart rate standard deviation
  lfhfratio := 0.5;                                    //LF/HF ratio
  rrmean := (60/hrmean);                               //RR mean
  flo := 0.1;                                          //low frequency
  fhi := 0.25;                                         //high frequency
  flostd := 0.01;                                      //lowfrequency std
  fhistd := 0.01;                                      //high frequency std

//INISIALISASI MATRIX
   x[1] := xinitial;
   x[2] := yinitial;
   x[3] := zinitial;

   ti[1] := 10*scrollbar1.Position;
    label8.Caption := floattostr(ti[1]);
   ti[2] := scrollbar2.Position;
    label9.Caption := floattostr(ti[2]);
   ti[3] := scrollbar3.Position;
    label10.Caption := floattostr(ti[3]);
   ti[4] := scrollbar4.Position;
    label11.Caption := floattostr(ti[4]);
   ti[5] := 10*scrollbar5.Position;
    label12.Caption := floattostr(ti[5]);

   ai[1] := scrollbar6.Position;
    label18.Caption := floattostr(ai[1]);
   ai[2] := scrollbar7.Position;
    label19.Caption := floattostr(ai[2]);
   ai[3] := 10*scrollbar8.Position;
    label20.Caption := floattostr(ai[3]);
   ai[4] := scrollbar9.Position/10;
    label21.Caption := floattostr(ai[4]);
   ai[5] := scrollbar10.Position/100;
    label22.Caption := floattostr(ai[5]);

   bi[1] := scrollbar11.Position/100;
    label28.Caption := floattostr(bi[1]);
   bi[2] := scrollbar12.Position/10;
    label29.Caption := floattostr(bi[2]);
   bi[3] := scrollbar13.Position/10;
    label30.Caption := floattostr(bi[3]);
   bi[4] := scrollbar14.Position/10;
    label31.Caption := floattostr(bi[4]);
   bi[5] := scrollbar15.Position/10;
    label32.Caption := floattostr(bi[5]);
end;

//Tombol
procedure TForm1.Button1Click(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

//PROSES ECG
procedure TForm1.sintesisecg;
var
  I,k,j: Integer;
  timev,range :extended;

begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

//RR TACHOGRAM
  w1 := 2*pi*flo;
  w2 := 2*pi*fhi;
  c1 := 2*pi*flostd;
  c2 := 2*pi*fhistd;
  sig2 :=1;
  sig1 := lfhfratio;
  rrmean := 60/hrmean;
  rrstd := 60*hrstd/(hrmean*hrmean);
  Nrr := Power(2,ceil(log10(N*rrmean*sf)/log10(2)));   //panjang RR time series

   hrfact := sqrt(hrmean/60);
   hrfact2 := sqrt(hrfact);


   //change ti to radian
   for i:=0 to 5 do
     begin
      ti[i] := ti[i]*PI/180;
     end;


  for i := 1 to 5 do
   begin
     bi[i]:=bi[i]*hrfact;
   end;

   ti[1]:=ti[1]*hrfact2;  ti[2]:=ti[2]*hrfact; ti[3]:=ti[3]*1.0; ti[4]:=ti[4]*hrfact; ti[5]:=ti[5]*1.0;
//stepsize
   h := 1.0/sf;
   tstep := 1.0/sf;

   rseed := -seed;

//PLOT RR TACHOGRAM
  df := sf/Nrr;
     for i := 1 to round(nrr) do
     begin
        w[i] := (i-1)*2.0*PI*df;
     end;

 { for I := 1 to round(Nrr) do
  begin
      dw1 := w[i] - w1;
      dw2 := w[i] - w2;
      Hw[i] := sig1*exp(-dw1*dw1/(2.0*c1*c1))/sqrt(2*PI*c1*c1) + sig2*exp(-dw2*dw2/(2.0*c2*c2))/sqrt(2*PI*c2*c2);
      series1.AddXY(i,hw[i]);
    end; }
    for i := 1 to round(nrr) do
     begin
        dw1 := w[i]-w1;
        dw2 := w[i]-w2;
        Hw[i] := sig1*exp(-dw1*dw1/(2.0*c1*c1))/sqrt(2*PI*c1*c1)
            + sig2*exp(-dw2*dw2/(2.0*c2*c2))/sqrt(2*PI*c2*c2);
        series1.AddXY(i*sf/nrr, hw[i]);
     end;

//INVERSE
  for i := 1 to round(Nrr) do
    begin
      Sw[i] := (sf/2.0)*sqrt(Hw[i]);

    end;
  for i := round(nrr/2)+1 to n do
    begin
      Sw[i] := (sf/2.0)*sqrt(Hw[n-i+1]);
    end;

//RANDOM PHASE
    for i := 1 to round((nrr/2)-1) do
     begin
       ph0[i] := 2.0*PI*random;
     end;
     ph[1] := 0.0;
     for i := 1 to round((nrr/2)-1) do
     begin
       ph[i+1] := ph0[i];
     end;
     for i := 1 to round((nrr/2)-1) do
     begin
       ph[round(nrr-i)+1] := - ph0[i];
     end;

//COMPLEX SPECTRUM
  for I := 1 to round(Nrr) do
    begin
      swc[2*i-1] := sw[i]*cos(ph[i]);
      swc[2*i] := sw[i]*sin(ph[i]);
    end;

  //IDFT
  for k := 1 to round(Nrr) do
    begin
      hasilidft[k] := 0;
      for j := 1 to round(Nrr) do
        begin
          hasilidft[k] := hasilidft[k] +  swc[2*j-1]*cos(2*PI*(k)*(j)/Nrr) + swc[2*j]*sin(2*PI*k*j/Nrr);
        end;
    end;
  xstd := stddev(hasilidft);
  ratio := rrstd/xstd;

  for i:=1 to Round(Nrr) do
    begin
      hasilidft[i]:=(hasilidft[i]*ratio)+rrmean;
      series2.AddXY(i/sf,hasilidft[i]);
    end;
  h := 1/sf;
  tecg:=0;
  i:=1;
  j:=1;

//RR Peak
  while i<= Round(Nrr) do
    begin
      tecg:=tecg+hasilidft[j];
      j:=Round(tecg/h);
      for k:=i to j do rrpc[k]:=hasilidft[i];
      i:=j+1;
    end;
   for i := 1 to round(Nrr) do
    begin
      series3.addxy(i/sf,rrpc[i]);
    end;
  nt:=j;
  ECG;
end;

procedure Tform1.ECG;
var
i: integer;
timev,range :extended;
begin
  for i := 1 to round(nt) do
     begin
       xt[i]:=x[1];
       yt[i]:=x[2];
       zt[i]:=x[3];

       rungekutta(timev,h);
       series4.AddXY((i-1)/sf,zt[i]);             //PLOT ECG
       timev:=timev+h;
       progressbar1.Position:= round(timev);
     end;

   maxrange := maxvalue(zt);
   minrange := minvalue(zt);
   range := maxrange-minrange;
   for i := 1 to round(nt) do
     begin
       zt[i] := (zt[i]-minrange)*(1.6)/(maxrange-minrange) - 0.4;
       zt[i] := zt[i]+Anoise*(2.0*random - 1.0);
       series5.AddXY((i-1)/sf,zt[i]);             //NORMALISASI
     end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   {label8.Caption := inttostr(scrollbar1.Position);
   label9.Caption := inttostr(scrollbar2.Position);
   label10.Caption := inttostr(scrollbar3.Position);
   label11.Caption := inttostr(scrollbar4.Position);
   label12.Caption := inttostr(scrollbar5.Position);
   label18.Caption := inttostr(scrollbar6.Position);
   label19.Caption := inttostr(scrollbar7.Position);
   label20.Caption := inttostr(scrollbar8.Position);
   label21.Caption := inttostr(scrollbar9.Position);
   label22.Caption := inttostr(scrollbar10.Position);
    label28.Caption := inttostr(scrollbar11.Position);
   label29.Caption := inttostr(scrollbar12.Position);
   label30.Caption := inttostr(scrollbar13.Position);
   label31.Caption := inttostr(scrollbar14.Position);
   label32.Caption := inttostr(scrollbar15.Position);}
   parameterpqrs;
end;

procedure TForm1.ScrollBar10Change(Sender: TObject);
begin
sintesisecg;
end;

procedure TForm1.ScrollBar11Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar12Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar13Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar14Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar15Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar3Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar4Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar5Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar6Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar7Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar8Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

procedure TForm1.ScrollBar9Change(Sender: TObject);
begin
  series1.Clear;
  series2.Clear;
  series3.Clear;
  series4.Clear;
  series5.Clear;

  N := strtoint(edit1.Text);
  parameterpqrs;
  sintesisecg;
end;

//RUNGE KUTTA ORDE 4
procedure TForm1.rungekutta(t, h: extended);
var
  i:integer;
  xh,hh,h6:extended;
  k1,k2,k3,k4,y:array [0..3] of extended;
  ytt:array [0..3] of extended;

begin
  hh:=h*0.5;
  h6:=h/6;
  xh:=t+hh;
  for i :=1 to 3 do
    begin
      y[i]:=x[i];
    end;
  derivpqrst(t,y);
  for i := 1 to 3 do
    begin
      k1[i]:=dxdt[i];
      ytt[i]:=y[i]+hh*k1[i];
    end;
  derivpqrst(xh,ytt);
  for i:=1 to 3 do
    begin
      k2[i]:=dxdt[i];
      ytt[i]:=y[i]+hh*k2[i];
    end;
  derivpqrst(xh,ytt);
  for i := 1 to 3 do
    begin
      k3[i]:=dxdt[i];
      ytt[i]:=y[i]+k3[i]*h;
    end;
  derivpqrst(t+h,ytt);
  for i := 1 to 3 do
    begin
      k4[i]:=dxdt[i];
    end;
  for i := 1 to 3 do
    begin
      x[i]:= y[i]+h6*(k1[i]+k4[i]+2*k2[i]+2*k3[i]);
    end;
end;

//THE EXACT NONLINEAR DERIVATIVES
procedure TForm1.derivpqrst(t0 : extended ; x : array of extended);
var
   i,k:integer;
   a0,w0,r0,x0,y0,z0:extended;
   t,dt,dt2,zbase:extended;
   xi,yi:array of extended;

begin
   k := 5;
   setlength(xi,5+1);
   setlength(yi,5+1);
   w0 := angfreq(t0);
   r0 := 1.0; x0 := 0.0;  y0:= 0.0;  z0 := 0.0;
   a0 := 1.0 - sqrt((x[1]-x0)*(x[1]-x0) + (x[2]-y0)*(x[2]-y0))/r0;
   for i := 1 to k do
   begin
     xi[i]:=cos(ti[i]);
     yi[i]:=sin(ti[i]);
   end;

   zbase := 0.005*sin(2.0*PI*fhi*t0);

   if x[1]=0 then
   begin
     t:=0
   end
   else
   begin
   t:=arctan2(x[2],x[1]);
   end;

   dxdt[1] := a0*(x[1] - x0) - w0*(x[2] - y0);
   dxdt[2] := a0*(x[2] - y0) + w0*(x[1] - x0);
   dxdt[3] := 0.0;

   for i := 1 to k do
   begin
     dt:=fmod(t-ti[i],2*pi);
     dt2:=sqr(dt);
     if bi[i]=0 then
     begin
         dxdt[3]:=dxdt[3]+(-ai[i]*dt*exp(0));
     end
     else
     begin
         dxdt[3]:=dxdt[3]+(-ai[i]*dt*exp(-0.5*dt2/(bi[i]*bi[i])));
     end;
   end;

   dxdt[3] :=dxdt[3]+( -1.0*(x[3] - zbase));

end;

//THE ANGULAR FREQUENCY
function TForm1.angfreq(t:extended):extended;
var
 i:integer;
begin
  i:=1+floor(t/h);
  if rrpc[i]=0 then
  begin
    angfreq:=2*pi/1;
  end
  else
  begin
    angfreq:=2*pi/rrpc[i];
  end;

end;

end.

