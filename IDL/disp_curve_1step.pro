pro disp_curve_1step
;reading fits file
dir='f:\!!!Pract\OBSst\RAW\dispcurve\'
num_f='940_600'
ima=float(readfits(dir+'VPHG'+num_f+'.fts',h))
Nx=sxpar(h, 'NAXIS1')
Ny=sxpar(h, 'NAXIS2')
overscan=20
image=ima(overscan:Nx-1,*)
Nx=Nx-overscan
w=20
x=findgen(Nx)
spec=total(image(*,Ny/2-w:Ny/2+w),2)/(2*w+1)
;plot obtained spectra and point peaks
Window,1, xsize=1000,ysize=400
plot,x+3570,spec,xst=1;, xrange=[2900+3570,Nx+3570];, yrange=[0,10000]
fi_peak,x,spec,400,ipix,xpk,ypk,bkpk,ipk
oplot,xpk+3570,ypk,psym=6


;reading dat file with walelength of peaks
l=fltarr(ipk)
ll=read_ascii(dir+'line_test'+num_f+'.dat')
l=float(ll.field1)
n=file_lines(dir+'line_test'+num_f+'.dat')
;show line that must be aproximate
window, 2, xsize=1200, ysize=600
R=where(l gt 0) & l=l(R) & xpk=xpk(R)
plot, xpk, l
;stop, n, ipk
Ndeg=5
;stop
;create accuracy line position
Npos=N_elements(xpk)
xpos=fltarr(Npos)
wx=2
for j=0,Npos-1 do begin
  ff=goodpoly(x(xpk(j)-wx:xpk(j)+wx),spec(xpk(j)-wx:xpk(j)+wx),2,3,Yfit)
  xpos(j)=-ff(1)/ff(2)/2
  ;print,xpk(j),xpos(j)
  endfor
xpk=xpos

;transition to wavelength scale
disp=goodpoly(xpk,l,Ndeg,3,yfit,newx,newy)
;print, disp
fit=0 & wave=0
for j=0,Ndeg do begin
  fit=fit+disp(j)*xpk^j
  wave=wave+disp(j)*x^j
endfor
window, 3, xsize=1200, ysize=600
plot, xpk, l-fit,psym=6;, yrange=[-2, 2]
oplot,[0,Nx],[0,0],linestyle=2
print,stdev(l-fit,mean),mean
;show average value of deviation and rms of it
robomean,l-fit,3,0.5,avg_err,rms_err
print,avg_err,rms_err
;stop
;
;dispersion=0
;for j=1,Ndeg do dispersion=dispersion+disp(j)*x^(j-1)*j
;window,4
;plot,wave,dispersion
;plot, newx, (l-yfit), PSYM=2, SYMSIZE=1.5

;linerization of spectra
;d_wave=dispersion[(Nx-1)/2];(max(dispersion)+min(dispersion))/2
;N_lin=FIX((wave(Nx-1)-wave(0))/d_wave)
;wave_lin=findgen(N_lin)*d_wave+wave(0)
;spectra_lin=INTERPOL(spec,wave,wave_lin)
;window,5, xsize=1000,ysize=400
;plot,wave_lin,spectra_lin,xst=1

;conducting and substructing of the continuum
spec=spec-1000
spec=spec-min(spec)+1
spectra_smooth=spec

for i=0,6 do begin
  ysmoo=lowess(x,spectra_smooth,Nx/10,3);,Nx/16,NDEG=3,noise)
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
fi_peak,x,spec,1.5,ipix,xpk,ypk,bkpk,ipk
;plot,wave_lin,spectra_lin,xst=1
;oplot,wave_lin(xpk),ypk,psym=6
;stop

;finding accuracy position of line in wavelength scale and writing it in file
N_peak=N_elements(xpk)
xpos=fltarr(N_peak)
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
end
disp_curve_1step
end
