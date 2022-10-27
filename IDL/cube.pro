pro cube
f_name=file_search('f:/!!!Pract/OBSst/RAW/s110824/\*.FTS')
first=readfits(f_name(0),head)
Nx=sxpar(head, 'NAXIS1')
Ny=sxpar(head, 'NAXIS2')
c=size(f_name)
num=c[1]
PolMode=sxpar(head, 'POLAMODE')
deg0=fix(strmid(PolMode,9,2))
cube=fltarr(Nx,Ny,2,num/2)
for i=0,num-1 do begin
  fits=readfits(f_name(i),h);,/NO_UNSIGNED);, /NOSCALE)
  ;print, fits[512,278]
   mode=sxpar(h, 'POLAMODE')
  deg=fix(strmid(mode,9,2))
  if deg0 eq deg then begin
    cube[*,*,0,i/2]=fits
  endif else begin
  cube[*,*,1,(i-1)/2]=fits
  endelse
endfor
stop
writefits, 'f:/!!!Pract/OBSst/RAW/s110824/Pol_Cube.fits', cube
window,2,xsize=Nx,ysize=Ny
tv,255-bytscl(cube[*,*,0,0],3000,5000)
end    
 