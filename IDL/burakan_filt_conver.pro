pro burakan_filt_conver, DIR

DIR='d:\Papers\Burakan.Filters\Filters\'
f_filt=file_search(DIR+'*.res',count=Nf)
f_spec=file_search(DIR+'*.txt',count=Ns)
f_sdss_stars=file_search(DIR+'\SDSS_stars\*.fits', count=NsdssS)
f_sdss_polar=file_search(DIR+'\SDSS_polars\*_phot.txt', count=NsdssP)
f_sdss_gal=file_search(DIR+'\SDSS_galaxies\*_phot.txt', count=NsdssG)
;tm=read_table(f_spec[0])
;N=size(tm)
;spec_tot=dblarr(N[2])
;for i=0,Ns-1 do begin
;  tm=read_table(f_spec[i])
;  spec_tot[*]=spec_tot[*]+tm[1,*]
;endfor
x_int=[4250,4500,4750,5000,5250,5750,6000,6250,6500,6750,7000]
x=['4250','4500','4750','5000','5250','5750','6000','6250','6500','6750','7000']
print, NsdssS
filt_tot=dblarr(Ns,Nf)
filt_sdssS=dblarr(NsdssS,Nf)
filt_sdssP=dblarr(NsdssP,Nf)
filt_sdssG=dblarr(NsdssG,Nf)

for i=0,Nf-1 do begin
  filter=read_table(f_filt[i])
  if i eq 0 then par_interp=dblarr(Nf,N_elements(filter[1,*]))
  par_interp[i,*]=spl_init(filter[0,*], filter[1,*],/double)
endfor
print, 'Step 4 > Start'
for j=0,NsdssS-1 do begin
   read_sdss, f_sdss_stars[j], spec, name
   spec[1,*]=spec[1,*]*1e-17
   openw, 1, f_sdss_stars[j]+'_spec.txt'
   N=size(spec)
   for i=0,N[2]-1 do printf, 1, spec[0,i], spec[1,i], format='(F8.2,2X,E12.4)'
   close, 1
   for i=0,Nf-1 do begin
    filter=read_table(f_filt[i])
    Y=spl_interp(filter[0,*], filter[1,*],par_interp[i,*],spec[0,*],/double)
    filt_sdssS[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
   endfor
   openw, 1, f_sdss_stars[j]+'_phot.txt'
   printf, 1, filt_sdssS[j,*], format='(11(F6.3,2X))'
   close, 1
endfor

for i=0,NsdssG-1 do begin
  if i lt Ns then filt_tot[i,*]=read_table(f_spec[i])
  if i lt NsdssP then filt_sdssP[i,*]=read_table(f_sdss_polar[i])
  ;if i lt NsdssS then filt_sdssS[i,*]=read_table(f_sdss_stars[i])
  filt_sdssG[i,*]=read_table(f_sdss_gal[i])
endfor  
;print, 'Step 1 > Start'

;for j=0,Ns-1 do begin
;  openw, 1, DIR+strcompress(strmid(f_spec[j],43,8))+'.txt'
;  for i=0,Nf-1 do begin
;    spec=read_table(f_spec[j])
;    filter=read_table(f_filt[i])
;    Y=spl_interp(filter[0,*], filter[1,*],par_interp[i,*],spec[0,*],/double)
;    filt_tot[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;  endfor 
;  printf, 1, filt_tot[j,*], format='(11(F6.3,2X))'
;  close, 1
;endfor   
;print, 'Step 2 > Start'
;for j=0,NsdssP-1 do begin
;   read_sdss, f_sdss_polar[j], spec, name
;   spec[1,*]=spec[1,*]*1e-17
;   openw, 1, f_sdss_polar[j]+'_spec.txt'
;   N=size(spec)
;   for i=0,N[2]-1 do printf, 1, spec[0,i], spec[1,i], format='(F8.2,2X,E12.4)'
;   close, 1
;   for i=0,Nf-1 do begin
;    filter=read_table(f_filt[i])
;    Y=spl_interp(filter[0,*], filter[1,*],par_interp[i,*],spec[0,*],/double)
;    filt_sdssP[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;   endfor
;   openw, 1, f_sdss_polar[j]+'_phot.txt'
;   printf, 1, filt_sdssP[j,*], format='(11(F6.3,2X))'
;   close, 1
;endfor
;print, 'Step 3 > Start', NsdssG
;for j=0,NsdssG-1 do begin
;   read_sdss, f_sdss_gal[j], spec, name
;   spec[1,*]=spec[1,*]*1e-17
;   openw, 1, f_sdss_gal[j]+'_spec.txt'
;   N=size(spec)
;   for i=0,N[2]-1 do printf, 1, spec[0,i], spec[1,i], format='(F8.2,2X,E12.4)'
;   close, 1
;   for i=0,Nf-1 do begin
;    filter=read_table(f_filt[i])
;    Y=spl_interp(filter[0,*], filter[1,*],par_interp[i,*],spec[0,*],/double)
;    filt_sdssG[j,i]=-2.5*alog10(total(Y*spec[1,*]/0.349e-6))
;   endfor
;   openw, 1, f_sdss_gal[j]+'_phot.txt'
;   printf, 1, filt_sdssG[j,*], format='(11(F6.3,2X))'
;   close, 1
;endfor




;for i=0,Nf-2 do begin
;  for j=i+2,Nf-1 do begin
;    cgplot, filt_sdss[*,i]-filt_sdss[*,i+1],filt_sdss[*,i]-filt_sdss[*,j], psym=2, $
;      xtit=x[i]+'-'+x[i+1], ytit=x[i]+'-'+x[j], xs=1, ys=1;, xr=[-3,3], yr=[-3,3]
;    cgoplot, filt_tot[*,i]-filt_tot[*,i+1],filt_tot[*,i]-filt_tot[*,j], psym=4, color='red';
;    endfor
;endfor
;
set_plot, 'ps'
device, file=DIR+'Color-Color.ps', /portrait,$
        xsize=16, ysize=16, yoff=4
;!P.multi=[0,1,2]
  cgplot, filt_sdssG[*,7]-filt_sdssG[*,8],filt_sdssG[*,8]-filt_sdssG[*,9], psym=3, $
    xtit=x[7]+'-'+x[7], ytit=x[8]+'-'+x[9], xs=1, ys=1, xr=[-1,1], yr=[-1,1]
  cgoplot, filt_sdssS[*,7]-filt_sdssS[*,8],filt_sdssS[*,8]-filt_sdssS[*,9], psym=2
  cgoplot, filt_tot[*,7]-filt_tot[*,8],filt_tot[*,8]-filt_tot[*,9], psym=4, color='red';
  cgoplot, filt_sdssP[*,7]-filt_sdssP[*,8],filt_sdssP[*,8]-filt_sdssP[*,9], psym=4, color='blue';
  cgplot, filt_sdssG[*,1]-filt_sdssG[*,2],filt_sdssG[*,2]-filt_sdssG[*,3], psym=3, $
    xtit=x[1]+'-'+x[2], ytit=x[2]+'-'+x[3], xs=1, ys=1, xr=[-1,1], yr=[-1,1]
  cgoplot, filt_sdssS[*,1]-filt_sdssS[*,2],filt_sdssS[*,2]-filt_sdssS[*,3], psym=2
  cgoplot, filt_tot[*,1]-filt_tot[*,2],filt_tot[*,2]-filt_tot[*,3], psym=4, color='red';
  cgoplot, filt_sdssP[*,1]-filt_sdssP[*,2],filt_sdssP[*,2]-filt_sdssP[*,3], psym=4, color='blue';
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


