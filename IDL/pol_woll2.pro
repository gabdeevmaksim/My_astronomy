pro pol_woll2 

DIR='e:\Observations\BTA\s210613\'
files=file_search(DIR+'s189505*.fts', count=N)
window, 2, xsize=700, ysize=700
times = fltarr(3,N)
wx=6 & wy1=[11,wx,wx,wx] & wy2=[wx,wx,wx,11]
dy=[0,208,442,651]
openw, lun, DIR+'result.dat', /get_lun
for i = 0,N-1 do begin
  h=headfits(files(i))
  UT = sxpar(h, 'UT')
  Time = sxpar(h,'TIME-OBS')
  E = sxpar(h,'EXPTIME')
  times[0,i] = UT & times[1,i] = Time & times[2,i] = E
  fits = readfits(files[i], h)
  if i eq 0 then begin
      display_image, fits, 2, options={range:[1700,2200],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
      click_on_max, fits, x_ref, y_ref, mark=1
      N_obj=N_elements(x_ref)
      results = fltarr(3*N_obj,N)
      intens = fltarr(4)
      m_pol = fltarr(4)
  endif

  for k=0,N_obj-1 do begin
    for j=0,3 do begin
      cntrd, fits, x_ref[k], y_ref[k]+dy[j], xcen, ycen, 8, SILENT = silent
      if xcen eq -1 then begin
        ycen = y_ref[k]+dy[j] & xcen = x_ref[k]
      endif
      sky, fits[xcen-2*wx:xcen+2*wx,ycen-2*wy1[j]:ycen+2*wy2[j]], m, ms, /meanback, /silent
      m_pol[j] = m
      ;print, median(fits[xcen-3*wx:xcen+3*wx,ycen-3*wy1[j]:ycen+3*wy2[j]])
      intens[j] = total(fits[xcen-wx:xcen+wx,ycen-wy1[j]:ycen+wy2[j]],/double) - (m)*(2*wx+1)*(wy1[j]+wy2[j]+1)
      ;print, total(fits[xcen-wx:xcen+wx,ycen-wy1[j]:ycen+wy2[j]],/double), (m+ms)*2*wx*(wy1[j]+wy2[j])
      if j eq 1 then aper, fits, xcen, ycen, flux, eflux, sky,skyerr, 1, wx*2, [wx*2,wx*2+1], [-32767,80000], /flux, /silent
    endfor    
    results[3*k,i]= 50*((intens[0]-intens[1])/(intens[0]+intens[1])-(intens[2]-intens[3])/(intens[2]+intens[3])); +  
    ;print, 50*((m_pol[0]-m_pol[1])/(m_pol[0]+m_pol[1])+(m_pol[2]-m_pol[3])/(m_pol[2]+m_pol[3]))
    results[3*k+1,i] = flux
    ;print, intens[0], intens[1]
  endfor
  for k=0,N_obj-1 do results[3*k+2,*]=-2.5*alog10(results[3*k+1,*]/results[4,*])+18.81
  printf, lun, results[*,i], format='('+strcompress(string(3*N_obj),/remove_all)+'(F10.3,2X))'
endfor
close, lun
end