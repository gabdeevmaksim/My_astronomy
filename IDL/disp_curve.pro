pro disp_curve
;reading fits file
wdir='f:\!!!Pract\OBSst\RAW\dispcurve\test\'
num_f='2300_520'
;goto, cont
ima=readfits(wdir+'eta.fts')
  ;create traectory
  tra=create_traectory(ima,NP=13,WX=40,NDEG=2,/plot)
  writefits,wdir+'traectory.fit',tra
  ;create geometry
  neon=readfits(wdir+'VPHG'+num_f+'.fts')
  ;traectory=readfits(wdir+'traectory.fit')
  geometry_new,neon,tra,DY=40,X0,Y0,X1,Y1,/plot
  Nc=N_elements(X0)
  coords=[X0,Y0,X1,Y1]
  C=reform(coords,Nc,4)
  writefits,wdir+'geometry.fit',C,h
  ;correction of distortion of geometry
  ;C=readfits(wdir+'geometry.FIT')
  ;tra=readfits(wdir+'traectory.fit')
  slit=900

  ;correction of image geometry
  ;type=['neon','flat',fname]
  ;for k=0,2 do begin
    ima=readfits(wdir+'VPHG'+num_f+'.fts',header)
    ima=WARP_TRI(c(*,0),c(*,1),c(*,2),c(*,3),ima)
    a=size(ima)
    writefits,wdir+'VPHG'+num_f+'_g.fts',ima(65:a(1)-1,30:960),header
    ;print,'correction   ',type(k)
  ;endfor
  goto, fin

  ;cont:
  ;create dispersion curve
  neon=readfits(wdir+'VPHG'+num_f+'_g.fts',hn)
  ident_table=wdir+'ident'+num_f+'.txt'
  Ndeg=5
  D=dispersion_2D(neon,ident_table,N_DEG=Ndeg,/plot);,,TRESH=tresh,PLOT=plot)
  writefits,wdir+'dispersion.fit',D;,h
 
 
  !P.multi=0

;transition to wavelength scale
;print, disp
spectra=double(total(neon,2))
table=read_table(ident_table)
pos=DOUBLE(table[0,*])
lpos=DOUBLE(table[1,*])
N_lines=N_elements(pos)
wx=5
Nx=sxpar(hn, 'NAXIS1')
N=N_elements(D(*,0))
x=findgen(Nx)
xpk=dblarr(N_lines)
for j=0,N_lines-1 do begin
  p=goodpoly(x(pos(j)-wx:pos(j)+wx),spectra(pos(j)-wx:pos(j)+wx),2,2,fit)
  xpk[j]=-p[1]/p[2]/2
endfor
fit=0 & wave=0
disp=dblarr(Ndeg+1)
for j=0,Ndeg do begin
  disp(j)=total(D(*,j))/N
  fit=fit+disp(j)*xpk^j
  wave=wave+disp(j)*x^j
endfor

window, 2, xsize=1200, ysize=600
plot, x, spectra, xst=1
oplot, xpk, spectra(xpk), psym=6

window, 4, xsize=1200, ysize=600
plot, xpk, lpos-fit,psym=6;, yrange=[-2, 2]
oplot,[0,Nx],[0,0],linestyle=2
print,stdev(lpos-fit,mean),mean

;show average value of deviation and rms of it
robomean,lpos-fit,3,0.5,avg_err,rms_err
print,avg_err,rms_err
;stop
;
;dispersion=0
;for j=1,Ndeg do dispersion=dispersion+disp(j)*x^(j-1)*j
;window,4
;plot,wave,dispersion
;plot, newx, (l-yfit), PSYM=2, SYMSIZE=1.5

;conducting and substructing of the continuum
spec=spectra-min(spectra)+1
spectra_smooth=spec

for i=0,6 do begin
  ysmoo=lowess(x,spectra_smooth,Nx/18,3);,Nx/16,NDEG=3,noise)
  window,6, xsize=1200,ysize=600
  plot, wave, spec,xst=1, /ylog
  oplot, wave, ysmoo
  robomean, spectra_smooth-ysmoo, 3, 0.5,avg_cont,rms_cont
  R=where(spectra_smooth-ysmoo gt 1*rms_cont,ind) &
  if ind gt 1 then spectra_smooth(R)=ysmoo(R)
  print, i+1, ' smooth'
endfor
  window,6, xsize=1200,ysize=600
  plot, wave, spec,xst=1, /ylog
  oplot, wave, ysmoo
;stop
spec=spec-ysmoo

;transition to relative intensitise by power-law dependence
R=where(spec lt 0,ind) & if ind gt 1 then spec(R)=0
gamma=0.3
;window,7,xsize=1200,ysize=600
spec=(spec+1)^gamma
fi_peak,x,spec,15,ipix,xpk,ypk,bkpk,ipk
;plot,wave_lin,spectra_lin,xst=1
;oplot,wave_lin(xpk),ypk,psym=6
;stop

;finding accuracy position of line in wavelength scale and writing it in file
N_peak=N_elements(xpk)
xpos=fltarr(N_peak)
dir='f:\!!!Pract\OBSst\RAW\dispcurve\'
openw, 1, dir+'peak_of_line'+num_f+'.dat'

for j=0,N_peak-1 do begin
    ff1=goodpoly(x(xpk[j]-wx:xpk[j]+wx),spec(xpk[j]-wx:xpk[j]+wx),2,3,Yfit)
    xpos(j)=-ff1(1)/ff1(2)/2
    wavepos=0
    for i=0,Ndeg do wavepos=wavepos+disp[i]*xpos[j]^i
    printf,1, wavepos, ypk[j],xpos[j], format='(F8.2,4X,F10.3,4X,F8.2)'
endfor
close, 1

window,7,xsize=1200,ysize=600
plot,wave,spec,xst=1;,xrange=[5300,5400]
oplot, wave(xpk),ypk, psym=6
;stop
;writing obtained spectra in file
openw, lun, dir+'spectra'+num_f+'.dat', /get_lun
for i=0,Nx-1 do printf,lun, wave[i], spec[i], format='(F8.2,4X,F10.3)'
free_lun, lun
fin:
end
;disp_curve_1step
;end
