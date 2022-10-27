pro sdvig_4k, WDIR=WDIR, OBJPOS=objpos, STARNAME=starname

files=file_search(wdir+'*_red.fts', count=N_files)
img=readfits(files[0], h)
Ny=sxpar(h,'NAXIS2') & Nx=sxpar(h,'NAXIS1')
;read spectra and determine sky line position
slice=dblarr(N_files,Nx)
w=20 & k=0
x=findgen(Nx)
trend=fltarr(N_files-1,Nx)
slice1=fltarr(N_files-1,Nx)
!P.multi=0
;goto, cont
for i=0,N_files-1 do begin
  Print, files[i]
  h=headfits(files[i],/silent)
  if (sxpar(h, 'IMAGETYP') eq 'obj_rh  ') and (sxpar(h,'OBJECT') ne starname) then begin
  img=readfits(files[i], h)
  slice[i,*]=total(img[*,0:objpos-w],2)+total(img[*,objpos+w:Ny-1],2)
  smoo_slice=slice[i,*]
  for j=0,6 do begin
    ysmoo=lowess(x,smoo_slice,Nx/12,3);,Nx/16,NDEG=3,noise)
    window,6, xsize=600,ysize=300
    plot, x, slice[i,*],xst=1, /ylog
    oplot, x, ysmoo, color=500
    robomean, smoo_slice-ysmoo, 3, 0.5,avg_cont,rms_cont
    R=where(smoo_slice-ysmoo gt 1*rms_cont,ind) &
    if ind gt 1 then smoo_slice[R]=ysmoo(R)
    print, j+1, ' smooth'
  endfor
  slice1[k,*]=slice[i,*]-smoo_slice
  R=where(slice1[k,*] lt 0, ind)
  if ind gt 0 then slice1[k,*]=0
  trend[k,*]=smoo_slice
  k++
  endif
endfor
save, slice1, FILENAME=wdir+'slices.sav'
;stop
;cont:
restore, wdir+'slices.sav'
M=Nx/2
xcross=findgen(M*2+1)-M
pos=fltarr(N_files)
window, 2, title='Cross-correlation'
plot, [xcross[0],xcross[2*M]],[0,0], xst=1, yrange=[0,2.5], /nodata
for i=0, N_files-2 do begin
window, 24, title='Test'
plot, slice1[0,*], xst=1
oplot, slice1[i,*], color=300
res=cross_norm(slice1[0,*],slice1[i,*],M)
pkcut=0.7
fi_peak, xcross, res, pkcut, ipix, xpk, ypk, bkpk, ipk
oplot, xcross, res+0.05*i, color=i*2000
ff=goodpoly(xcross[xpk-3+M:xpk+3+M], res[xpk-3+M:xpk+3+M], 2, 3, yfit, newx, newy)
pos[i]=-ff[1]/ff[2]/2
print, pos[i]
if pos[i]*0 ne 0 then pos[i]=0
endfor
save, pos, filename=wdir+'shift.sav'
  window, 1, title='Compare the spectra'
  plot, slice1[0,*], xst=1;, xrange=[xpos(0,2)-20,xpos(0,2)+20]
for i=1,N_files-2 do oplot, slice1[i,*]+500*i, color=5000*i
end
