pro phot_zeiss, path, obj_name, m_ref, apert, filter, I_min, I_max

if m_ref eq 0 then restore, path+'\'+obj_name+'\m_ref_'+filter+'.sav'
print, m_ref
f_name=file_search(path+'\'+obj_name+'\'+filter+'\*.FTS', count=count)
h_tmp=headfits(f_name[0])
t=sxpar(h_tmp,'HISTORY')
if n_elements(t) eq 1 then first_reduction, path, obj_name, filter
N=count
Nx=sxpar(h_tmp, 'NAXIS1')
Ny=sxpar(h_tmp, 'NAXIS2')
set_plot, 'win'
!P.multi=0
window, 2, xsize=Nx*2/3, ysize=Ny*2/3

time=fltarr(N)

openw, lun, path+obj_name+'\'+obj_name+'_phot.txt', /get_lun
printf, lun, ' Time  ', '  Mobj  ', 'Obj_err ', ' Mcomp'
openw, 33, path+obj_name+'\fluxes.txt'
openw, 44, path+obj_name+'\stars_coord.txt'
for i=0,N-1 do begin
  fits=readfits(f_name(i),h, /NO_UNSIGNED)
  fits=mirror_x(fits)
    if i eq 0 then begin
      print, 'Choose reference star'
      display_image, fits, 2, options={range:[I_min,I_max],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
      click_on_max, fits, x_ref, y_ref, mark=1
    endif
  centrod, fits, x_ref, y_ref, apert, apert+10, apert+4, 0, x, y, coun
  aper, fits, x, y, fl, efl, sky,skyerr, 2.1, apert, [apert+1,apert+2], $
      [-32767,56000], /flux, /silent
  t=fix(sxpar(h, 'EXPTIME'))
  convert_time, sxpar(h, 'TSTART'), outtime
  if outtime eq 0 then begin
    convert_time, sxpar(h, 'UT'), outtime
    outtime=outtime+4
  endif
  if outtime lt 8 then time[i]=24+outtime else time[i]=outtime
  fl_ref=fl & x_ref=x & y_ref=y;/t
  ;print, fl_ref
    if i eq 0 then begin
      print, 'Choose at first object and then comparison stars'
      display_image, fits,2, options={range:[I_min,I_max],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
      click_on_max, fits, x0, y0, mark=1;, N_SELECT = 4
      N_obj=N_elements(x0) 
      m_obj=fltarr(N_obj,N) & fluxes=fltarr(N_obj,N) & x_obj=fltarr(N_obj,N+1) & y_obj=fltarr(N_obj,N+1)
    endif
  for k=0,N_obj-1 do begin
    centrod, fits, x0[k], y0[k], apert, apert+10, apert+4, 0, x_cen, y_cen, coun
    aper, fits, x_cen, y_cen, fl, efl, sky,skyerr, 2.1, apert, [apert+1,apert+2], $
          [-32767,56000], /flux, /silent
  ;print, fl
    x0[k]=x_cen & y0[k]=y_cen
    x_obj[k,i+1]=x_cen & y_obj[k,i+1]=y_cen;/t
    m_obj[k,i]=m_ref-2.5*alog10(fl/fl_ref)
    fluxes[k,i]=fl
  ;print, m_obj[i]
  endfor
  RR=where(fluxes lt 0, ind)
  if ind ne 0 then fluxes[RR]=0
  printf, 33, fluxes[*,i], format='('+strcompress(string(N_obj))+'(F9.2,2X))'
  printf, 44, x_obj[*,i+1]-x_obj[*,i], format='('+strcompress(string(N_obj))+'(F6.2,2X))'
  printf, 44, y_obj[*,i+1]-y_obj[*,i], format='('+strcompress(string(N_obj))+'(F6.2,2X))'
endfor
close, 33
close, 44
RR=where(finite(m_obj,/NAN) or m_obj lt 0, ind)
if ind ne 0 then m_obj[RR]=0 
;robomean, m_obj[1,*], 3, 0.5, avg_obj, obj_err, obj_std
;robomean, m_obj[2,*], 3, 0.5, avg, com_err, com_std
;obj_std=fltarr(N_obj)
;obj_std=com_std*10^((m_obj[0,*]-avg)/2.5)
for i=0,N-1 do printf, lun, time[i]-time[0], m_obj[0,i], m_obj[2,i], format='(F5.2,2X,2(F6.3,2X))'
;printf, lun, '       ErrObj ', '        ErrComp'
;printf, lun, '     ', com_std, format='(A5,2X,2(F6.3,2X))'
free_lun, lun

;  printf, lun, 'Coord in pix:    ', 'x', 'y', format='(A17,5X,A1,8X,A1)'
;  printf, lun, 'Position of obj: ', x_obj[0], y_obj[0], format='(A17,2X,F8.3,2X,F8.3)'
;  printf, lun, 'Position of ref: ', x_ref, y_ref, format='(A17,2X,F8.3,2X,F8.3)'
;  printf, lun, 'Position of comp: ', x_obj[2], y_obj[2], format='(A17,2X,F8.3,2X,F8.3)'
 
  
wdelete, 2
;stop

time=time-time[0]
;stop

;print, avg_obj, obj_err, obj_std
plot, time, m_obj[0,*], yrange=[max(m_obj)+0.1,min(m_obj)-0.1],$
      xrange=[min(time)-0.1,max(time)+0.1], color=2000
oplot, time, m_obj[2,*], linestyle=2;, color=10000
;errplot, time, m_obj[0,*]-obj_std[*], m_obj[0,*]+obj_std[*]
;errplot, time, m_obj[2,*]-com_std, m_obj[2,*]+com_std

set_plot, 'PS'
device, file=path+'\'+obj_name+'\'+obj_name+'_phot.ps',xsize=28,ysize=16, /landscape,xoffset=1,yoffset=29
plot, time, m_obj[0,*], yrange=[max(m_obj)+0.1,min(m_obj)-0.1],$
      xtitle='Time, hour', ytitle='Magnitude', title=obj_name, $
      xrange=[min(time)-0.1,max(time)+0.1]
oplot, time, m_obj[2,*]
oplot, time, m_obj[0,*], psym=6
;errplot, time, m_obj[0,*]-obj_std, m_obj[0,*]+obj_std
;errplot, time, m_obj[2,*]-com_std, m_obj[2,*]+com_std
device, /close
set_plot, 'WIN'

openw, lun, path+'\'+obj_name+'\phot.dat', /get_lun
for i=0,N-1 do $
printf, lun, time[i]-time[0], m_obj[*,i], format='(F5.3,2X,'+strcompress(string(N_obj))+'(F6.3,4X))'
close, lun
end
phot_zeiss, 'd:\Observations\RAW\Zeiss\171216\', 'IPHAS 0528', 14.33, 12, 'R', 400, 1000
end