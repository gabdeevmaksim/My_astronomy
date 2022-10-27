pro count_filds_a_objects

DIR='e:\Observations\MMPP\'
files=file_search(DIR,'*_color.fits',count=N)
N_o=0
for i=0,N-1 do begin
  fxbopen, unit, files[i], 1, h
  fxbread, unit, mag540, 'MAG_STD_470_PSF'
  RR=where(mag540 lt 99, ind)
  if ind gt 0 then N_o=N_o+ind
  fxbclose, unit
endfor
print, N_o, N
end