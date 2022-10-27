pro Edmund_filt_conver, DIR

DIR='d:\Papers\Burakan.Filters\Filters\'
DIR1='d:\Observations\RAW\UAGS\Gabdeev\3BS050549.99+461746.7\'
f_spec=file_search(DIR1+'sum*.dat',count=Ns)
f_sdss_stars=file_search(DIR+'\SDSS_stars\*spec.txt', count=NsdssS)
f_sdss_polar=file_search(DIR+'\SDSS_polars\*spec.txt', count=NsdssP)
f_sdss_gal=file_search(DIR+'\SDSS_galaxies\*spec.txt', count=NsdssG)

;f_spec=file_search(DIR+'*Edmund.txt',count=Ns)
;f_sdss_stars=file_search(DIR+'\SDSS_stars\*Edmund.txt', count=NsdssS)
;f_sdss_polar=file_search(DIR+'\SDSS_polars\*Edmund.txt', count=NsdssP)
;f_sdss_gal=file_search(DIR+'\SDSS_galaxies\*Edmund.txt', count=NsdssG)

spec=read_table(DIR+'sum_spec_0711_20.09.dat')
f_filt=file_search('d:\Papers\Burakan.Filters\*.txt',count=Nfilt)
Yb=dblarr(Nfilt,N_elements(spec[0,*]))
for i=0,Nfilt-1 do begin
  filter_b=read_table(f_filt[i],double=1)
  ;par=spl_init(filter_b[0,*]*10, filter_b[1,*],/double)
  ;Yb[i,*]=spl_interp(filter_b[0,*]+10, filter_b[1,*],par,spec[0,*],/double)
  Yb[i,*]=interpolate(filter_b[1,*],(spec[0,*]-2000)/10)
endfor



;x_int=[4300,4400,4700,4805,4860,5000,5150,5250,5400,6560,7000]
;x=['4300','4400','4700','4805','4860','5000','5150','5250','5400','6560','7000']
x_int=[4700,5400,6560];,5150
x=['470','540','656'];,'515'
print, NsdssS
Nf=N_elements(x_int)
filt_tot=dblarr(Ns,Nf)
filt_sdssS=dblarr(NsdssS,Nf)
filt_sdssP=dblarr(NsdssP,Nf)
filt_sdssG=dblarr(NsdssG,Nf)

ff=[0,1,2]

set_plot, 'ps'
device, file=DIR+'For_presentation2.ps', /portrait,$
        xsize=16, ysize=16, yoff=4
N=size(spec)
R1=where(spec[0,*] gt x_int[ff[0]]-50 and spec[0,*] lt x_int[ff[0]]+50)
R2=where(spec[0,*] gt x_int[ff[1]]-50 and spec[0,*] lt x_int[ff[1]]+50)
R3=where(spec[0,*] gt x_int[ff[2]]-50 and spec[0,*] lt x_int[ff[2]]+50)
Y=fltarr(N[2]) & Y[R1]=0.9 & Y[R2]=0.9 & Y[R3]=0.9 
;!p.MULTI=[0,1,2]
cgplot, spec[0,*], Yb[ff[0],*], xr=[4000,7300], ytit='Transmission, %', xs=1, xtit='Wavelength, A'
cgplot, spec[0,*], Yb[ff[1],*], /overplot
cgplot, spec[0,*], Yb[ff[2],*], /overplot
device, /close
device, file='d:\Papers\RSI-1\Fig_02.eps', /portrait,$
        xsize=8, ysize=8, yoff=0, xoff=0
cgplot, spec[0,*], 3*spec[1,*]/max(spec[1,*]), xs=1, ys=1, CHARSIZE=.5, xr=[4000,7300], xtit='Wavelength, '+cgSymbol('Angstrom'), ytitle='Relative intensities', yr=[0, 1];, tit='Specta of polar V808 Aur'
cgplot, spec[0,*], Yb[ff[0],*]/100, /overplot
cgplot, spec[0,*], Yb[ff[1],*]/100, /overplot
cgplot, spec[0,*], Yb[ff[2],*]/100, /overplot
xyouts, 4050, 0.51, 'H'+cgsymbol('delta'),CHARSIZE=.5
xyouts, 4300, 0.65, 'H'+cgsymbol('gamma'),CHARSIZE=.5
xyouts, 4730, 0.71, 'HeII 4686',CHARSIZE=.5, ori=90
xyouts, 4850, 0.9, 'H'+cgsymbol('beta'),CHARSIZE=.5
xyouts, 5925, 0.71, 'HeI 5876',CHARSIZE=.5, ori=90
xyouts, 6600, 0.95, 'H'+cgsymbol('alpha'),CHARSIZE=.5
xyouts, 6728, 0.7, 'HeI 6678',CHARSIZE=.5, ori=90
xyouts, 7105, 0.7, 'HeI 7065',CHARSIZE=.5, ori=90
xyouts, 4521, 0.44, 'HeI 4471',CHARSIZE=.5, ori=90
xyouts, 4972, 0.44, 'HeI 4922',CHARSIZE=.5, ori=90
xyouts, 5065, 0.44, 'HeI 5015',CHARSIZE=.5, ori=90
xyouts, 5430, 0.5, 'HeI 5411',CHARSIZE=.5, ori=90
device, /close
set_plot, 'win'
!p.MULTI=0


;N=size(spec)
;RR=where(spec[0,*] gt x_int[3]-50 and spec[0,*] lt x_int[3]+50)
;Y=fltarr(N[2]) & Y[RR]=0.9 
;cgplot, spec[0,*], Y
;stop 


;for i=0,NsdssG-1 do begin
;  if i lt Ns then filt_tot[i,*]=read_table(f_spec[i])
;  if i lt NsdssP then filt_sdssP[i,*]=read_table(f_sdss_polar[i])
;  if i lt NsdssS then filt_sdssS[i,*]=read_table(f_sdss_stars[i])
;  filt_sdssG[i,*]=read_table(f_sdss_gal[i])
;endfor  

print, 'Step 1 > Start'
Nf=3
for j=0,Ns-1 do begin
  openw, 1, DIR1+strcompress(strmid(f_spec[j],43,8))+'_Edmund.txt'
  spec=read_table(f_spec[j])
  for i=0,Nf-1 do begin
;    N=size(spec)
;    RR=where(spec[0,*] gt x_int[i]-50 and spec[0,*] lt x_int[i]+50)
;    Y=fltarr(N[2]) & Y[RR]=0.9 
    filter_b=read_table(f_filt[i],double=1)
    Y=interpolate(filter_b[1,*],spec[0,*]/10-filter_b[0,0])
    filt_tot[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
  endfor 
  printf, 1, filt_tot[j,*], format='(11(F7.3,2X))'
  close, 1
endfor   
;print, 'Step 2 > Start'
;for j=0,NsdssP-1 do begin
;   spec=read_table(f_sdss_polar[j])
;   N=size(spec)
;   spec[1,*]=spec[1,*]*1e-17
;   for i=0,Nf-1 do begin
;;    RR=where(spec[0,*] gt x_int[i]-50 and spec[0,*] lt x_int[i]+50)
;;    Y=fltarr(N[2]) & Y[RR]=0.9 
;;    filt_sdssP[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;    filter_b=read_table(f_filt[i],double=1)
;    Y=interpolate(filter_b[1,*],(spec[0,*]-2000)/10)
;    filt_sdssP[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;   endfor
;   openw, 1, f_sdss_polar[j]+'_Edmund.txt'
;   printf, 1, filt_sdssP[j,*], format='(11(F6.3,2X))'
;   close, 1
;endfor
;print, 'Step 3 > Start', NsdssG
;for j=0,NsdssG-1 do begin
;   spec=read_table(f_sdss_gal[j])
;   N=size(spec)
;   spec[1,*]=spec[1,*]*1e-17
;   for i=0,Nf-1 do begin
;;    RR=where(spec[0,*] gt x_int[i]-50 and spec[0,*] lt x_int[i]+50,ind)
;;    Y=fltarr(N[2]) 
;;    if ind ne 0 then Y[RR]=0.9
;;    filt_sdssG[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;    filter_b=read_table(f_filt[i],double=1)
;    Y=interpolate(filter_b[1,*],(spec[0,*]-2000)/10)
;    filt_sdssG[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;   endfor
;   openw, 1, f_sdss_gal[j]+'_Edmund.txt'
;   printf, 1, filt_sdssG[j,*], format='(11(F6.3,2X))'
;   close, 1
;endfor
print, 'Step 4 > Start'
for j=0,NsdssS-1 do begin
   spec=read_table(f_sdss_stars[j])
   N=size(spec)
   spec[1,*]=spec[1,*]*1e-17
   for i=0,Nf-1 do begin
;    RR=where(spec[0,*] gt x_int[i]-50 and spec[0,*] lt x_int[i]+50)
;    Y=fltarr(N[2]) 
;    if ind ne 0 then Y[RR]=0.9
;    filt_sdssS[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
    filter_b=read_table(f_filt[i],double=1)
    Y=interpolate(filter_b[1,*],spec[0,*]/10-filter_b[0,0])
    filt_sdssS[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
   endfor
   openw, 1, f_sdss_stars[j]+'_Edmund.txt'
   printf, 1, filt_sdssS[j,*], format='(11(F6.3,2X))'
   close, 1
endfor



;for i=0,Nf-2 do begin
;  for j=i+2,Nf-1 do begin
;    cgplot, filt_sdss[*,i]-filt_sdss[*,i+1],filt_sdss[*,i]-filt_sdss[*,j], psym=2, $
;      xtit=x[i]+'-'+x[i+1], ytit=x[i]+'-'+x[j], xs=1, ys=1;, xr=[-3,3], yr=[-3,3]
;    cgoplot, filt_tot[*,i]-filt_tot[*,i+1],filt_tot[*,i]-filt_tot[*,j], psym=4, color='red';
;    endfor
;endfor
;


set_plot, 'ps'
device, file='d:\Papers\RSI-1\Fig_03.eps', /portrait,$
        xsize=8, ysize=8, yoff=0, xoff=0
;!P.multi=[0,1,2]
  ;cgplot, filt_sdssG[*,2]-filt_sdssG[*,5],filt_sdssG[*,5]-filt_sdssG[*,7], psym=3, $
  ; xtit=x[2]+'-'+x[5], ytit=x[5]+'-'+x[7], xs=1, ys=1, xr=[-1,1], yr=[-1.5,1.5]
  cgplot, filt_sdssS[*,ff[0]]-filt_sdssS[*,ff[1]],filt_sdssS[*,ff[1]]-filt_sdssS[*,ff[2]], psym=2,$
   xtit='SED'+x[0]+'-'+'SED'+x[1], ytit='SED'+x[1]+'-'+'SED'+x[2], xs=1, ys=1, CHARSIZE=.5, xr=[-1,1.5], yr=[-1.,1.5] , symsize=.5
  cgoplot, filt_tot[*,ff[0]]-filt_tot[*,ff[1]],filt_tot[*,ff[1]]-filt_tot[*,ff[2]], psym=4, symsize=1, color='red';
;  cgoplot, filt_sdssP[*,ff[0]]-filt_sdssP[*,ff[1]],filt_sdssP[*,ff[1]]-filt_sdssP[*,ff[2]], psym=6, symsize=.5; , color='blue'
  x1=[-2,2]
  cgoplot, x1, 1.44*x1+0.25;, col='green'
;  cgplot, filt_sdssG[*,1]-filt_sdssG[*,2],filt_sdssG[*,2]-filt_sdssG[*,3], psym=3, $
;    xtit=x[1]+'-'+x[2], ytit=x[2]+'-'+x[3], xs=1, ys=1, xr=[-1,1], yr=[-1,1]
;  cgoplot, filt_sdssS[*,1]-filt_sdssS[*,2],filt_sdssS[*,2]-filt_sdssS[*,3], psym=2
;  cgoplot, filt_tot[*,1]-filt_tot[*,2],filt_tot[*,2]-filt_tot[*,3], psym=4, color='red';
;  cgoplot, filt_sdssP[*,1]-filt_sdssP[*,2],filt_sdssP[*,2]-filt_sdssP[*,3], psym=4, color='blue';
;!P.multi=0
device, /close 


;for i=1,Nf-1 do begin
;  cgplot, filt_sdss[*,8], (filt_sdss[*,8]-filt_sdss[*,i]), $
;      xtit=x[8], ytit=x[8]+'-'+x[i], psym=2, xs=1, ys=1; xr=[-42,10]
;  cgoplot, filt_tot[*,8], (filt_tot[*,8]-filt_tot[*,i]), psym=4, color='red'
;endfor
   
;cgplot, tm[0,*],spec_tot, xs=1, xrange=[4000,7100]
;cgplot, x, filt_tot, title='Spectral destribution', PSYM=4, xrange=[4000,7100], xs=1
;cgplot, filt_tot[2]-filt_tot[1],filt_tot[2]-filt_tot[3], xtitle='4750-4500', ytitle='4750-5000'

;device, file=DIR+'Filt_spec.ps', /portrait,$
;        xsize=16, ysize=16, yoff=4
;for i=0,Ns-1 do cgplot, x_int, filt_tot[i,*], title=strmid(f_spec[i],47,7), yr=[25,15], psym=4
;device, /close
set_plot, 'win'
end