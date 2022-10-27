pro flat_for_pol, files, endfile

n=N_elements(files)
for k=0,n-1 do begin
  tm=readfits(files[k],h)
  if k eq 0 then begin
    Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
    flat=fltarr(n,Nx,Ny) & flat_new=fltarr(Nx,Ny) & bias=fltarr(4,20,20) & pos=intarr(4,4)
    pos[0,*]=[0,19,0,19] & pos[1,*]=[Nx-20,Nx-1,0,19] & pos[2,*]=[0,19,Ny-20,Ny-1] & pos[3,*]=[Nx-20,Nx-1,Ny-20,Ny-1]
  endif
  for l=0,3 do bias[l,*,*]=tm[pos[l,0]:pos[l,1],pos[l,2]:pos[l,3]]
  flat[k,*,*]=tm-mean(bias)
  print, mean(bias)
endfor

for i=0,Nx-1 do begin
  for j=0,Ny-1 do begin
    robomean, flat[*,i,j], 3, .5, avf, avdf, stdf
    flat_new[i,j]=avf
  endfor
endfor
robomean, flat_new[(Nx-1)/2-2:(Nx-1)/2+3,(Ny-1)/2-2:(Ny-1)/2+3], 3, 0.5, av, avd, std
flat_new=flat_new/av
writefits, endfile, flat_new, h
end