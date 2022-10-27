pro UBVRcIc, WDIR=wdir

files=file_search(wdir+'total*.txt', count=count)
filt=file_search(wdir+'*.dat')
tmp=read_table(files(1))
a=size(tmp)
N=a(2)
curve=fltarr(5,2,N) 
for i=1,count-1 do curve[i-1,*,*]=read_table(files(i))

lambda=fltarr(5) & lambda2=fltarr(5) & w=fltarr(5) & expos=fltarr(5)
for i=0,count-2 do begin 
  lambda1=0 
  filter=read_table(filt[i])
  R=where(curve[i,0,*] eq min(filter[0,*])) & R1=R[0]
  R=where(curve[i,0,*] eq max(filter[0,*])+50) & R2=R[0]
  ;if (i eq 1) or (i eq 2) then R2=N-1 
  ;if (i eq 2) then R1=0
  ;av=avg(curve[i,0,R1:R2])
  for j=R1,R2 do begin
    lambda1=lambda1+curve[i,0,j]*curve[i,1,j]
    lambda2[i]=lambda2[i]+curve[i,1,j]
  endfor
  lambda[i]=lambda1/lambda2[i]
  for j=R1,R2 do w[i]=w[i]+(curve[i,0,j]-lambda[i])^2*curve[i,1,j]
  w[i]=sqrt(w[i]/lambda2[i])
endfor
for i=0,count-2 do expos[i]=lambda[4]/lambda[i] 

set_plot,'PS'
device,file=wdir+'Filters.ps',xsize=28,ysize=18,/landscape,yoffset=29,xoffset=0.5, /isolatin1;,
tmp=read_table(files(0))
plot, tmp[0,*], tmp[1,*]/max(tmp[1,*]), yrange=[0.06,1], xrange=[3500,10000], /nodata, xst=1, yst=1, $
  xtitle='Wavelength, A', ytitle='Transmition, %', title='Filters for Photometer-Polarimeter', XCHARSIZE=1.3, YCHARSIZE=1.3
  lambda1=[3700,4300,5300,6250,7850]
  fil=['U','B','V','R','I']
  hi=[0.2,0.3,0.4,0.35,0.3]
for i=1,count-1 do begin
  xyouts, lambda1[i-1], hi[i-1], fil[i-1], CHARSIZE=2.5, CHARTHICK=2
  oplot, curve[i-1,0,*], smooth(curve[i-1,1,*],5), thick=1.3, MIN_VALUE=0.05
  ;oplot, [lambda[i-1],lambda[i-1]],[0,1] 
endfor
x=[7350,7350,9700,9700,7350]
y=[0.98,0.65,0.65,0.98,0.98]
oplot, x,y
ind=[3,0,4,2,1]
for i=0,4 do begin
x=[7520,7520,7520,7520,7520]
y=[0.92,0.895,0.87,0.845,0.82]
fil=['B','I','R','U','V']
xyouts, x[i], y[i], fil[ind[i]], CHARSIZE=1.1
x=[7700,7700,7700,7700,7700]
y=[0.92,0.895,0.87,0.845,0.82]
xyouts, x[i], y[i], string(fix(lambda[ind[i]])), CHARSIZE=1.0
x=[8540,8500,8540,8500,8500]
tmp=['1000','1450','1620','420','950']
xyouts, x[i], y[i], tmp[ind[i]], CHARSIZE=1.0
x=[9080,9080,9080,9080,9080]
exp=['1.25','0.68','0.82','1.47','1.00']
xyouts, x[i], y[i], exp[ind[i]], CHARSIZE=1.0
x=[7520,7520,7520,7520,7520]
y=[0.765,0.740,0.715,0.690,0.665]
fil=['B','I','R','U','V']
xyouts, x[i], y[i], fil[ind[i]], CHARSIZE=1.1
x=[7900,7900,7900,7900,7900]
tmp=['4407','8640','6846','3518','5479']
xyouts, x[i], y[i], tmp[ind[i]], CHARSIZE=1.0
x=[8540,8540,8540,8500,8500]
tmp=['927','2194','2090','684','875']
xyouts, x[i], y[i], tmp[ind[i]], CHARSIZE=1.0
x=[9080,9080,9080,9080,9080]
exp=['1.30','0.48','0.71','1.60','1.00']
xyouts, x[i], y[i], exp[ind[i]], CHARSIZE=1.0
j++
endfor

x=[7935,8520,9040]
y=[0.95,0.95,0.95]
xyouts, x, y, [cgsymbol('lambda',/PS)+'_eff', 'Width', 'Rel. Exp'], CHARSIZE=1.0, FONT=1
xyouts, 8200, 0.795, 'Johnson system', FONT=1
device,/close

set_plot, 'WIN'

f=2.8*0.51/1.51
openw, lun, wdir+'filters.txt',/get_lun
printf, lun, cgsymbol('lambda',/UNICODE), '  Width', '  Rel. Exp', '  delta f' 
for i=0,count-2 do begin
R=where(curve[i,1,*] ge max(curve[i,1,*])/2)
w=max(curve[i,0,R])-min(curve[i,0,R])
printf, lun, strmid(filt[i],25,1), fix(lambda[i]), fix(w), expos[i], f, format='(A1,2X,I6,4X,I5,2(4X,F5.2))'
endfor
free_lun, lun    
end  
UBVRcIc, WDIR='f:\!!!Pract\filters\'  
end
   
  