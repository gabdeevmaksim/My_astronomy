pro control_of_photometry

dir='f:\!!!Pract\OBSst\RAW\Phot_Control\'
Zeiss=file_search(dir+'*.fit')
SCO=file_search(dir+'*.fts')
saves=file_search(dir+'*.sav', count=CS)

m_ref=16.57 & apert=12
fits=readfits(Zeiss,Zh)
TexpZ=sxpar(Zh,'EXPTIME')
Nx=sxpar(Zh, 'NAXIS1')
Ny=sxpar(Zh, 'NAXIS2')
if CS ne 2 then begin
  set_plot, 'WIN'
  window, 2, xsize=Nx*2/3, ysize=Ny*2/3
  display_image, fits, 2, $
                options={range:[100,1500],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
  click_on_max, fits, x_ref, y_ref, mark=1
  ;centrod, fits, x_ref, y_ref, 12, 14, 17, 0, x, y, coun
  x=x_ref & y=y_ref
  save, x, y, filename=dir+'Zcoor.sav'
endif else restore, dir+'Zcoor.sav'  
aper, fits, x, y, fl, efl, sky,skyerr, 2.1, apert, [apert+1,apert+2], $
      [0,5e6], /flux, /silent

m_objZ=m_ref-2.5*alog10(fl/fl[0])


m_objSd=fltarr(N_elements(m_objZ))
m_objS=fltarr(2,N_elements(m_objZ))
flS=fltarr(2,N_elements(m_objZ))
for i=0,1 do begin
  fits=readfits(SCO[i],Sh)
  Nx=sxpar(Sh, 'NAXIS1')
  Ny=sxpar(Sh, 'NAXIS2')
  if CS ne 2 then begin
    if i eq 0 then begin
      set_plot, 'WIN'
      window, 2, xsize=Nx*2/3, ysize=Ny*2/3
      display_image, fits, 2, $
                options={range:[1000,3500],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
      click_on_max, fits, x_ref, y_ref, mark=1
      xS=fltarr(N_elements(x_ref)) & yS=fltarr(N_elements(x_ref))
      for j=0,N_elements(x)-1 do begin 
        centrod, fits, x_ref[j], y_ref[j], 12, 14, 17, 0, x1, y1, coun
        xS[j]=x1 & yS[j]=y1
      endfor
    save, xS, yS, filename=dir+'Scoor.sav'
    endif
   endif else restore, dir+'Scoor.sav'   
   aper, fits, xS, yS, fl, efl, sky,skyerr, 2.1, apert, [apert+1,apert+2], $
        [0,5e6], /flux, /silent
    for j=0,N_elements(fl)-1,2 do flS[i,j/2]=fl[j]+fl[j+1]    
endfor
m_objS[0,*]=m_ref-2.5*alog10(flS[0,*]/flS[0,0])
m_objS[1,*]=m_ref-2.5*alog10(flS[1,*]/flS[1,0])
m_objSd=m_ref-2.5*alog10((flS[0,*]+flS[1,*])/(flS[0,0]+flS[1,0]))

for i=0,N_elements(m_objZ)-1 do print, m_objZ[i], m_objSd[i], m_objS[0,i], m_objS[1,i], format='(4(F6.3,2X))'   
end