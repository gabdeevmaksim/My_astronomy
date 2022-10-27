function mirror_x, IMG

a=size(img) & Nx=a[1] & Ny=a[2] & img_new=fltarr(Nx,Ny)

for i=0,Nx-1 do begin
  for k=0,Ny-1 do begin
    img_new[i,Ny-1-k]=img[i,k]
  endfor
endfor
return, img_new
end  