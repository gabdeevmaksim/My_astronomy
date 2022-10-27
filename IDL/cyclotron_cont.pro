pro cyclotron_cont, DIR=dir

d1=120 & d2=100
goto, cont
files=file_search(dir+'*.txt', count=N)
;goto, cont1
for i=0,N-1 do begin
  print, i+1, ' spectra'
  temp1=read_table(files[i])
  if i eq 0 then begin 
    R=where(temp1[0,*] ge 4050, ind)
    if ind gt 0 then begin 
      a=N_elements(R) & b=size(temp1)
      spec=dblarr(N,a-(d1+d2)) & cont=dblarr(N,a-(d1+d2)) & spec1=dblarr(N,a-(d1+d2)) & temp=dblarr(2,a-(d1+d2))
    endif
  endif 
  temp[0,*]=temp1[0,b[2]-a+d1:b[2]-1-d2] & temp[1,*]=temp1[1,b[2]-a+d1:b[2]-1-d2]
  spec[i,*]=smooth(temp[1,*],5)
  result=lowess(temp[0,*],spec[i,*],a/4,4,1)
  for j=0,3 do begin
    robomean, temp[1,*]-result, 3, 0.5,avg,rms
    RR=where(abs(temp[1,*]-result) gt rms, ind)
    if ind gt 1 then temp(1,RR)=result(RR) 
    result=lowess(temp[0,*], temp[1,*],a/8,3,1)
  endfor
  cont[i,*]=result
  spec1=spec1+spec
endfor
!P.multi=[0,1,N]
window, 1, xsize=350, ysize=700
for i=0,N-1 do begin
  plot, temp[0,*], spec[i,*], xst=1, xrange=[4050+d1,7350-d2], yrange=[0,2.5e-15]
  oplot, temp[0,*], cont[i,*], color=2000
endfor
save, cont, temp, spec, spec1, FILENAME=dir+'cyc_cont.sav'

cont:
restore, dir+'cyc_cont.sav'
a=size(temp) & N=a[2] & totl=fltarr(N)
totl=lowess(temp[0,*], total(cont,1),a[2]/8,3,1)
!P.multi=[0,1,2]
set_plot, 'PS'
device, file=dir+'cyc_cont.ps',xsize=16,ysize=16, /portrait ;, xoffset=25,yoffset=5
plot, temp[0,*], total(spec1,1)*10e14, xst=1, xrange=[4050,7350], CHARSIZE=1.5, $
XCHARSIZE=1.1, YCHARSIZE=1.1, CHARTHICK=2
plot, temp[0,*], totl*10e14, xst=1, xrange=[4050,7350], xtitle='Wavelength, A', ytitle='Intensity, 10e-15', CHARSIZE=1.5, $
XCHARSIZE=1.1, YCHARSIZE=1.1, CHARTHICK=2, yrange=[2,4]
device, /close
set_plot, 'win'
!P.multi=0

N1=2 & !P.multi=[0,1,N1]
window, 3, xsize=500, ysize=700
for i=0,N1-1 do begin
  plot, temp[0,*], spec[i,*], xst=1, xrange=[4050+d1,7350-d2], yrange=[0,2.5e-15]
  oplot, temp[0,*], cont[i,*], color=2000
endfor
!P.multi=0
window, 2
plot, temp[0,*], cont[1,*], xrange=[4000,7500]
oplot, temp[0,*], cont[0,*], color=2000
oplot, temp[0,*], (cont[1,*]+cont[0,*])/2, color=20000
openw, lun, dir+'cyc_cont.dat', /get_lun
for i=0,N-1 do printf, lun, temp[0,i], cont[0,i], cont[1,i], (cont[1,i]+cont[0,i])/2, $
    format='(F8.3,2X,3(E12.5,2X))'
close, lun
;oplot, temp[0,*], cont[0,*]+(cont[1,N-1]-cont[0,N-1]), color=2000
;plot, temp[0,*], cont[1,*]/cont[0,*]
;cont1:
;for i=0,N-1 do begin
;  print, i+1, ' spectra'
;  temp=read_table(files[i])
;  if i eq 0 then begin 
;    a=size(temp)
;    spec=dblarr(N,a[2]) & cont=dblarr(N,a[2]) & spec1=dblarr(N,a[2])
;  endif
;  spec[i,*]=temp[1,*]
;endfor
;plot, temp[0,*], (spec[0,*]+spec[1,*])/2-spec[2,*], xst=1, xrange=[4000,7300], yrange=[0,2e-15]
;result=lowess(temp[0,*], (spec[0,*]+spec[1,*])/2-spec[2,*],a[2]/6,5,2)
;oplot, temp[0,*], result, color=2000
end
cyclotron_cont, DIR='f:\!!!Pract\OBSst\Processed\s110920\OT J071126+440405\Cyclotron\'
end