pro sdvig_4k, WDIR=WDIR, OBJ=OBJ, OBJPOS=objpos  

files=file_search(path+'sdvig\'+name+'*.fts', count=N_files)
img=readfits(files[0], h)
Ny=sxpar(h,'NAXIS2') & Nx=sxpar(h,'NAXIS1')
;read spectra and determine sky line position
slice=dblarr(N_files,Nx)
w=20 
x=findgen(Nx)
trend=fltarr(N_files,Nx)
for i=0,N_files-1 do begin
  img=readfits(files[i], h)
  slice[i,*]=total(img[*,0:objpos-w],2)+total(img[*,objpos+w:Ny-1],2)
  smoo_slice=slice[i,*]
  for j=0,6 do begin
    ysmoo=lowess(x,smoo_slice,Nx/10,3);,Nx/16,NDEG=3,noise)
    window,6, xsize=1200,ysize=600
    plot, x, slice[i,*],xst=1, /ylog
    oplot, x, ysmoo
    robomean, smoo_slice-ysmoo, 3, 0.5,avg_cont,rms_cont
    R=where(smoo_slice-ysmoo gt 1*rms_cont,ind) &
    if ind gt 1 then smoo_slice[R]=ysmoo(R)
    print, j+1, ' smooth'
  endfor
  slice[i,*]=slice[i,*]-smoo_slice
  trend[i,*]=smoo_slice 
endfor
M=Nx/2
xcross=findgen(M*2+1)-M
pos=fltarr(N_files)
window, 2, title='Cross-correlation'
plot, [xcross[0],xcross[2*M]],[0,0], xst=1, yrange=[0,2.5], /nodata
for i=0, N_files-1 do begin
res=cross_norm(slice[0,*],slice[i,*],M)
pkcut=0.5
fi_peak, xcross, res, pkcut, ipix, xpk, ypk, bkpk, ipk
oplot, xcross, res+0.05*i, color=i*2000
ff=goodpoly(xcross[xpk-3+M:xpk+3+M], res[xpk-3+M:xpk+3+M], 2, 3, yfit, newx, newy)
pos[i]=-ff[1]/ff[2]/2
print, pos[i]
endfor  
save, pos, filename=path+'shift.sav' 
  window, 1, title='Compare the spectra'
  plot, slice[0,*], xst=1;, xrange=[xpos(0,2)-20,xpos(0,2)+20]
for i=1,N_files-1 do oplot, slice[i,*]+500*i, color=5000*i
end
