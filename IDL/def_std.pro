pro def_std, dir, obj_name, mag_std, m_ref, filter

f_name_std=file_search(dir+'\standards\*.fts')
c=size(f_name_std)
N=c[1]

fl_std=fltarr(N)

bias=readfits(dir+'reduction\SBias.fit',h, /NO_UNSIGNED)
flat=readfits(dir+'reduction\SFlat'+filter+'.fit',h, /NO_UNSIGNED)

Nx=sxpar(h, 'NAXIS1')
Ny=sxpar(h, 'NAXIS2')
window, 1, xsize=Nx*2/3, ysize=Ny*2/3
j=0
for i=0,N-1 do begin
  fits=readfits(f_name_std(i),h,/NO_UNSIGNED)
  f=string(sxpar(h,'FILTER'))
  ;if f eq 'v ' then begin; for V-filter need to compare with 'v ', for other filters work keyword FILTER
    fits=(fits-bias)/flat
    if j eq 0 then begin
      print, 'Choose standard star'
      display_image, fits, 1, /MODIFY_OPT
      click_on_max, fits, x_std, y_std, mark=1
    endif
    centrod, fits, x_std, y_std, 12, 14, 17, 0, x, y, coun
    aper, fits, x, y, fl, efl, sky,skyerr, 2.1, 12, [14,17], $
      [-32767,32767], /flux, /silent
      x_std=x & y_std=y
      t=fix(sxpar(h, 'EXPTIME'))
      z_std=fix(sxpar(h, 'Z'))
      fl_std[i]=fl/t
      j++
  ;endif
endfor

f_name=file_search(dir+'\'+obj_name+'\*.FTS')
c=size(f_name)
N=c[1]

j=0
fl_ref=fltarr(N)
z=intarr(N)


for k=0,N-1 do begin
  fits=readfits(f_name(k), h, /NO_UNSIGNED )
  z[k]=fix(sxpar(h, 'Z'))
  if z[k] eq z_std then begin
      if j eq 0 then begin
      print, 'Choose reference star'
      display_image, fits, 1, /MODIFY_OPT
      click_on_max, fits, x_ref, y_ref, mark=1
      endif
      centrod, fits, x_ref, y_ref, 12, 14, 17, 0, x, y, coun
      aper, fits, x, y, fl, efl, sky,skyerr, 2.1, 12, [14,17], $
      [-32767,32767], /flux, /silent
      t=fix(sxpar(h, 'EXPTIME'))
      fl_ref[j]=fl/t
      j=j+1
  endif
endfor

;stop, z, z_std

if j eq 0 then begin
  R=where(abs(z-z_std) eq min(abs(z-z_std)))
  for k=0, N_elements(R) do begin
    fits=readfits(f_name(k),h, /NO_UNSIGNED)
    print, 'Choose reference star'
    if k eq 0 then begin
      display_image, fits, 1, /MODIFY_OPT
      click_on_max, fits, x_ref, y_ref, mark=1
    endif
    centrod, fits, x_ref, y_ref, 12, 14, 17, 0, x, y, coun
    aper, fits, x, y, fl, efl, sky,skyerr, 2.1, 12, [14,17], $
       [-32767,32767], /flux, /silent
    t=fix(sxpar(h, 'EXPTIME'))
    x_ref=x & y_ref=y
    fl_ref[k]=fl/t
  endfor
  endif

;stop

R=where(fl_ref ne 0) & fl_ref=fl_ref[R]
c=size(fl_ref)
N=c[1]

m_ref=mag_std-2.5*alog10(TOTAL(fl_ref, /NAN)*(i)/TOTAL(fl_std)/N)
;stop

print, m_ref
wdelete, 1
save, filename=dir+'\'+obj_name+'\m_ref_'+filter+'.sav', m_ref
return
end
def_std, 'd:\Observations\RAW\Zeiss\141124\', 'RXS J215427', 0, m_ref, 'r'
end



