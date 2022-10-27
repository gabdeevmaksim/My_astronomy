pro create_disperse2D_new

dir_eta='D:\IDL_lib\scorpio_2K.lib\'
N=2048
Neta=N_elements(files)
neon=fltarr(N)
;for k=0,Neta-1 do begin & 
neon_tmp=fltarr(2048)
tmp=readfits(dir_eta+'etalon_'+'VPHG1200G'+'.fts',/silent)
;print, 'eta', dir_eta
if N_elements(tmp) lt 2048 then begin
Ntmp=N_elements(tmp)
neon_tmp(2048-Ntmp:2047)=tmp
neon(*,k)=neon_tmp
endif ELSE neon(*)=tmp

wdir='f:\!!!Pract\OBSst\Processed\s080502\'
neon_ima=readfits(wdir+'neon.fts',h,/silent)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
bin=sxpar(h,'BINNING') & bin=str_sep(bin,'x') & bin=float(bin(0))
;identefication grating  and direction of dispersion
neon_vec=total(neon_ima(*,Ny/2-Ny/4:Ny/2+Ny/4),2)  ;
;create background substraction vector
x=findgen(Nx)
fi_peak,x,neon_vec,0,ipix,xpk,ypk,bkpk,ipk
bkpk=smooth(bkpk,5,/edge_truncate)
fon=interpol(bkpk,xpk,x,/LSQUADRATIC)
fon=lowess(x,fon,Nx/10,3,3)
neon_vec=neon_vec-fon
;correction size etalon spectra
neon=congrid(neon,N/bin,Neta)

;window, 1, xsize=1200, ysize=500
;plot, neon_vec, xst=1
;window, 2, xsize=1200, ysize=500
;plot, neon, xst=1


print, 'etalon', dir_eta+'etalon_VPHG1200G.txt'
N_lines=numlines(dir_eta+'etalon_VPHG1200G.txt')
table=fltarr(2,N_lines)
openr,1,dir_eta+'etalon_'+'VPHG1200G'+'.txt'
readf,1,table
close,1
param=table(*,0:1)
table=table(*,2:N_lines-1) 
line=table(0,*) & N_lines=N_lines-2
;pos=(N*rev+(1-2*rev)*table(1,*))/bin+dx
N_pos=N_elements(pos)
;print, table

;tresh=10
;robomean,neon_vec,3,0.5,avg_level,rms_level
fi_peak,x,neon_vec,0,ipix,xpk,ypk,bkpk,ipk
fi_peak,x,neon,0,ipixn,xpkn,ypkn,bkpkn,ipkn

!P.MULTI=[0,1,2]
window, 4, xsize=1200, ysize=700
plot, x,neon_vec/max(neon_vec), xst=1
oplot, xpk, ypk/max(neon_vec), psym=6
plot, x,neon/max(neon), xst=1
oplot, xpkn, ypkn/max(neon), psym=6
!P.MULTI=0

window, 5, xsize=1200, ysize=700
plot, neon_vec/max(neon_vec)/neon*max(neon), xst=1
k=ipk-ipkn
print, k
print, xpk[0:ipk-k-1]-xpkn
;for i=0,k-1 do begin
 ; R=where(ypk ne min(ypk)) & ypk=ypk[R] & xpk=xpk[R]
;endfor

;line_pos=fltarr(2,N_lines) & j=0
;for i=0,ipk-1 do begin
 ; R=where(abs(xpk[i]-table[1,*]) le 12, ind)
 ;  if ind ne 0 then line_pos[0,j]=xpk[R] & line_pos[1,j]=line[j] & j++
;endfor
;window, 3, xsize=1200, ysize=500
;plot, line_pos[0,*], line_pos[1,*]  
end