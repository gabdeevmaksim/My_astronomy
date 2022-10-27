pro create_flat4k,RDIR=rdir,WDIR=wdir,X_SHIFT=x_shift,BIN=bin
;âûäåëåíèå ôàéëîâ flat
files=file_search(rdir+'*.fts',count=count)
img_type='' & slit=''
tmp=readfits(files[0],h)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
flat_tmp=fltarr(count,Nx,Ny) & k=0
for i=0,count-1 do begin
  print, i
  img=readfits(files[i],h)
  img_type=sxpar(h,'IMAGETYP')
  slit=sxpar(h,'SLITMASK')
  if (img_type eq 'flat') and (slit ne '3 dots  ') then begin
    flat_tmp[k,*,*]=img
    k++
    header=h
    print, files[i]
    TexpF=fix(sxpar(h,'EXPTIME'))
  endif
endfor
if k eq 0 then begin
  print, 'FLAT-files has not found'
  goto, fin
endif
;âûäåëåíèå ôàéëîâ ñ äëèííîé ùåëüþ SLITMASK=H mean
N_flat=k
flat=fltarr(N_Flat,Nx,Ny)
flat=flat_tmp(0:N_Flat-1,*,*)
;îïðåäåëåíèå ðàçìåðà èçîáðàæåíèÿ
bias=readfits(wdir+'SBias.fts')
print, mean(bias)
for k=0,N_flat-1 do begin
  flat(k,*,*)=(flat(k,*,*)-bias)/TexpF
endfor
;âûäåëåíèå ôàéëîâ ñ âûñîòîé H mean
ima=fltarr(Nx,Ny)
  for x=0,Nx-1 do begin
  for y=0,Ny-1 do begin
  if N_flat gt 2 then ima(x,y)=median(flat(*,x,y)) else  ima(x,y)=total(flat(*,x,y),1);/N_flat
  endfor&endfor
if keyword_set(x_shift) then ima(*,0:x_shift(0))=shift(ima(*,0:x_shift(0)),x_shift(1),0)
if keyword_set(bin) then begin
a=size(ima)
Nx=(a(1)-20)/bin+20
Ny=(a(2)-20)/bin+20
ima_new=fltarr(Nx,Ny)
ima_new(20:Nx-1,0:Ny-20-1)=congrid(ima(20:a(1)-1,0:a(2)-20-1),(a(1)-20)/2,(a(2)-20)/2)
ima=ima_new
endif
x=findgen(Nx) & wy=50 & k=1
!P.multi=0
  window, 1, title='FLAT-curve'
  plot, x, total(ima[20:Nx-2,0:Ny-21],2)/(Ny-21), xst=1;, xrange=[0,1000]
  Result = LOWESS(x[20:Nx-2], total(ima[20:Nx-2,0:Ny-21],2)/(Ny-21),Nx/16, 3, 3)
  oplot, x, result, color=90
  for j=0,Ny-1 do ima[20:Nx-2,j]=ima[20:Nx-2,j]/result
  window, 2, title='Normolized FLAT'
  plot, x, total(ima[20:Nx-2,0:Ny-21],2)/(Ny-21), xrange=[20,Nx-2]
  ;ima[20:1000,*]=mean(ima[1001:1010,*])
  ima[20:400,*]=1
  oplot, x, total(ima[20:Nx-2,0:Ny-21],2)/(Ny-21), color=200
writefits,wdir+'SFlat.fts',ima,header
fin:
END
