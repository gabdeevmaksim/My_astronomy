pro ns_subtruction, WDIR=wdir, FILE=file, SLITPOS=slitpos, WY=wy

ima=readfits(file,h)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
IF TOTAL(IMA) NE 0 THEN BEGIN
  window,2,xsize=Nx/4,ysize=Ny/4
  map=congrid(ima,Nx/4,Ny/4)
  tv,255-bytscl(map,-50,300),0,Ny/2
;for i=0,1 do begin
;map=ima(*,0+Ny/2*i:Ny/2-1+Ny/2*i)
;y=findgen(Ny/2)
;w=10
;V=total(map(Nx/2-w:Nx/2+w,*),1)/(2*w+1)
;îïðåäåëåíèå îáëàñòè àïïðîêñèìàöèè íî÷íîãî íåáà
;robomean,V,1,0.5,mean,rms
;R=where(V lt mean+rms/5, ind) & print,ind
;for k=0,Nx-1 do begin
;V(*)=map(k,*)
yy=findgen(Ny)
regions=[slitpos-150, slitpos-20,slitpos+20,slitpos+150]
reg1=(yy ge regions(0))and(yy le regions(1))
reg2=(yy ge regions(2))and(yy le regions(3))
reg3=bytarr(Ny)
if n_elements(regions) eq 6 then begin
  reg3=(yy ge regions(4))and(yy le regions(5))
  ; help,reg3
  ;reg2=where(reg2 or reg3)
endif
rec=where(reg1 or reg2 or reg3,cc)
if cc lt 2 then begin
  res=dialog_message('Please, check a keyword REGIONS !')
  return
endif
y=yy(rec)
;for i=0,Nx-1 do begin
 ; tmp=ima(i,rec)
 ; f=goodpoly(y,tmp,1,2)
 ; sky=poly(yy,f)
 ; ima(i,*)=ima(i,*)-sky
;endfor
  sky=ima
  for i=0,Nx-1 do sky[i,slitpos-wy:slitpos+wy]=(sky[i,slitpos-wy-1]+sky[i,slitpos+wy+1])/2
  map=congrid(sky,Nx/4,Ny/2)
  tv,255-bytscl(map,-50,300),0,0
  wait,1
  ima=ima-sky
  window,3,xsize=Nx/4,ysize=Ny/4
  map=congrid(ima,Nx/4,Ny/2)
  tv,255-bytscl(map,-50,50),0,0
  wait,1
endif
tmp=sxpar(h,'FILE')
file=strmid(tmp,0,9)
sxaddpar,h,'IMAGETYP', 'obj_sky'
writefits,wdir+file+'_sky.fts',ima,h
end