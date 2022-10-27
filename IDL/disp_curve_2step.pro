pro disp_curve_2step

;reading data about specta and lines from files 
dir='f:\!!!Pract\OBSst\RAW\dispcurve\'
num_f='1800_660'
img=readfits(dir+'VPHG'+num_f+'.fts', h)
f_spec=dir+'spectra'+num_f+'.dat'
f_peak=dir+'peak_of_line'+num_f+'.dat'
f_elem=['NeII','NeI','ArI','HeII','ArII']
Nf=N_elements(f_elem)
grid=sxpar(h,'DISPERSE')
peaks=read_table(f_peak)
spectra=read_table(f_spec)

  
N=N_elements(wave)
Np=N_elements(peaks[0,*])
N1=N/4
wl1=0.0 
elem1='' & elem=''
;fltarr(3,10)
Nelem=0
N2=intarr(Nf+1)
N2[0]=0

for i=1,Nf do begin 
  N2[i]=file_lines(dir+f_elem[i-1]+'.dat')
  Nelem=Nelem+N2[i]
  N2[i]=N2[i]+N2[i-1]
endfor

elements=dblarr(3,Nelem)
name_elem=strarr(Nelem)

  
  for i=1,Nf do begin
  print, i
    read_elements_table, f_elem[i-1], table
    elements[0,N2[i-1]:N2[i]-1]=double(table[1,*])
    name_elem[N2[i-1]:N2[i]-1]=table[2,*]
    elements[1,N2[i-1]:N2[i]-1]=double(table[3,*])
    elements[2,N2[i-1]:N2[i]-1]=double(table[4,*])
  endfor
  ;stop
  
  ;identification of lines wavelengths and name of element and writing it in file  
  ;openw, lun, dir+'table'+num_f+'.dat' , /get_lun
  openw, lun, dir+'elements'+num_f+'.dat' , /get_lun
  ;printf, lun, 'num','Wavelength', 'Wavelength', '   Name   ', format='(A3,4X,A10,4X,A10,4X,A10)'
  ;printf, lun,     ' of peak  ', 'of element', 'of element', format='(7X,A10,4X,A10,4X,A10)'
  for j=0,Np-1 do begin
    R=where(abs(peaks[0,j]-elements[0,*]) le 0.36, ind) 
    if ind ge 1 then begin
    wl1=elements[0,R]
    elem1=name_elem[R]
    if ind eq 1 then begin
      ;printf, lun, j, peaks[0,j], wl1, elem1, format='(I3,4X,D8.2,6X,D8.2,9X,A4)'
      printf, lun, wl1, elem1, format='(D8.2,4X,A4)'
    endif else begin
      ;RR=where(abs(wl1-peaks[0,j]) eq min(abs(wl1-peaks[0,j])))
      RR=where(elements[1,R] eq min(elements[1,R]), in)
      if (in ne 1) then begin printf, lun, wl1[RR[0]], 'dubl', format='(D8.2,4X,A4)' 
      ;printf, lun, j, peaks[0,j], wl1[RR], elem1[RR], format='(I3,4X,D8.2,6X,D8.2,9X,A4)'
      endif else begin printf, lun, wl1[RR], elem1[RR], format='(D8.2,4X,A4)'
      endelse  
    endelse  
    endif else printf, lun, 0, '_', format='(F8.2,4X,A4)'
  endfor 
  free_lun, lun
end


