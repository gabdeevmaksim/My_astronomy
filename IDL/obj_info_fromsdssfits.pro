pro obj_info_fromSDSSfits

DIR='d:\Papers\Burakan.Filters\Filters\SDSS_polars\'
files=file_search(DIR+'*.fits', count=N)
openw, 1, DIR+'obj_list.txt'
printf, 1, 'FITS_name', 'RA', 'Dec', format='(A20,2X,A9,2X,A9)'
for i=0,N-1 do begin
  fits_open, files[i], fcb
  ftab_ext, fcb, 'PLUG_RA,PLUG_DEC', RA, Dec, EXTEN_NO=2
  printf, 1,  strmid(files[i],46,20),RA, Dec, format='(A20,2X,F9.5,2X,F9.5)' 
endfor
close,1
end
  
  
   
  