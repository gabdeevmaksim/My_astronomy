pro crea_sent_4k, WDIR=wdir, FILE=file,PLOT=plot,Manual=manual,starpos=starpos, STARNAME=starname

;(BAN: Menyal str~47 : print,'Crea_sent: Use Yrange: ',Nmax-wy,Nmax+wy

;on_error,2
message,'creation spectral sensitivities curves GG',/cont
print,'TESTTTTT2'
;!P.background=2^24-1
;!P.color=0

;read image star
ima=readfits(file,h,/silent)


;read image parameters
d_lambda=0.5
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')

print,'STARPOS1=', starpos
;;;;if keyword_set(starpos) then starpos=Ny/2 ;MY
;print,'STARPOS2=', starpos

Texp=sxpar(h,'EXPTIME')
Z=sxpar(h,'Z')
star_name=strcompress(sxpar(h,'object'))
date_obs=strcompress(sxpar(h,'date-obs'))
grating=strcompress(sxpar(h,'DISPERSE'))
GAIN=sxpar(h,'GAIN')
x=findgen(Nx) & y=findgen(Ny)
disper=readfits(wdir+'dispersion.fit', hdisp)
Ndeg=N_elements(disper(0,*))-1 & wave=0 & N=N_elements(disper(*,0))
disp=dblarr(Ndeg+1)
for j=0,Ndeg do begin
  disp(j)=total(disper(*,j))/N
  wave=wave+disp(j)*x^j
endfor
lambda=wave
vector=fltarr(Ny)
;find position star along slit
w=100
vector=total(ima(Nx/2-w:Nx/2+w,*),1)
;maxstar=max(vector(starpos-w:starpos+w),Nmax)
;;;starpos=260 ;549 ;246    ;530;470;530 (menyat'!) ;;MY
w=70 & Ny=2*w+1; w=30
vector=fltarr(Ny)

print, w
print, starpos

ima=ima(*,starpos-w:starpos+w)
;create traectory
Npos=50  & wy=20; wy=7
wx=Nx/(Npos+1)-1 & xpos=findgen(Npos)*wx+wx & ypos=findgen(Npos)
for k=0,Npos-1 do begin
vector(*)=total(ima(xpos(k)-wx:xpos(k)+wx,*),1)
vector=median(vector,5)
max_value=max(vector,Nmax)
;klinit na test=N5548s051227!
print,'Crea_sent: Use Yrange: ',Nmax-wy,Nmax+wy
fit=gaussfit(y(Nmax-wy:Nmax+wy),vector(Nmax-wy:Nmax+wy),G)
ypos(k)=G(1)
endfor

Ndeg=3 & f=goodpoly(xpos,ypos,Ndeg,3)
tra=0 & for j=0,Ndeg do tra=tra+f(j)*x^j
print,'star position=',total(tra)/N_elements(tra)
;substraction background
w=50  & S=5 & w=w*S & N=2*W+1
;w=50  & S=3 & w=w*S & N=2*W+1 ;MY
;w=15  & S=3 & w=w*S & N=2*W+1
y=findgen(N)
star=findgen(Nx,N/S)
ima=rebin(ima,Nx,Ny*S)
help, ima
vector=fltarr(N)
for k=0,Nx-1 do begin
;print, 'k, trak', k, (tra(k)*S+w)-(tra(k)*S-w)+1, N
a=size(ima(k,tra(k)*S-w:tra(k)*S+w))
if a(2) ne N then vector(*)=ima(k,tra(k)*S-w:tra(k)*S+w-1) else vector(*)=ima(k,tra(k)*S-w:tra(k)*S+w)
R=where(y lt N/2-w/2 OR y gt N/2+w/2)
f=goodpoly(y(R),vector(R),Ndeg,3)
fon=0 & for j=0,Ndeg do fon=fon+f(j)*y^j
star(k,*)=congrid(vector-fon,N/S)
endfor
N=N/S & w=w/S & y=findgen(N)
;estimation seeing
gau=gaussfit(y,total(star(Nx/2-wx:Nx/2+wx,*),1),G)
FWHM=g(2)*2.345
scale=sxpar(h,'CDELT2')
print,'seeing '+STRING(FWHM*scale,format='(F3.1)')+' arcsec'
;extraction star
star=total(star(*,N/2-FWHM:N/2+FWHM),2)
;read table star
;table_name=strcompress(name_tab(logfile))
table_name=strcompress('d:\IDL_lib\scorpio_2K.lib\standards\data\f'+strcompress(starname,/remove_all)+'.dat')
print, 'TABLENAME: ', table_name
flux=read_st(table_name,lambda,/print)
;correction shift spectra star
dc=20 & xc=findgen(dc*2+1)-dc
v_obs=star-smooth(star,50,/edge_truncate)
v_tab=flux-smooth(flux,50,/edge_truncate)
vc=cross_norm(v_obs,v_tab,dc)
tmp=max(vc,Nmax)& dc=xc(Nmax)
star=shift(star,-dc-1)
;correction secondary order
;hh=headfits(wdir+'2D_coeff.fts')
;order2=sxpar(hh,'order2')

D=star/flux
D=median(d,3)
D=LOWESS(x,D,50,2)
D=D/max(D)
if lambda(0)*2 lt lambda(Nx-1) then begin
M=fix((lambda(Nx-1)/2-lambda(0))/d_lambda)
dflux=flux(0:M-1)*D(0:M-1) & dflux=congrid(dflux,2*M)
flux(Nx-M*2:Nx-1)=flux(Nx-M*2:Nx-1);+dflux*order2
endif
;calculation DQE
S=2.52E5		     ;square 6-m mirror
N_star=flux*2.8E11*S
star_obs=star*GAIN/calc_ext(lambda,Z)/Texp/d_lambda

DQE=LOWESS(x,star_obs/N_star,Nx/5,3)
if keyword_set(plot) then begin
window,2
!P.multi=[0,1,2]
plot,lambda,star,xst=1,title=date_obs+', star '+star_name+', Texp='+$
	string(Texp,format='(I3)')+' s, z='+string(z,format='(I3)')+' deg',$
	xtitle='Wavelength, A',ytitle='Flux, ADU'
plot,lambda,DQE*100,xst=1,linestyle=1,$
	xtitle='Wavelength, A',ytitle='DQE, %'
	oplot,lambda,star_obs*100./N_star
!P.multi=[0,1,1]
endif
writefits,wdir+'star_obs.fts',star_obs,h
writefits,wdir+'star_tab.fts',N_star,h
writefits,wdir+'DQE.fts',DQE,h
if manual eq 1 then DQE=MANUAL_FIT(DQE,lambda);,SPLINE=spline

set_plot,'PS'
device,file=wdir+'DQE.ps',xsize=18,ysize=16,xoffset=1,yoffset=5,/portrait
plot,lambda,DQE*100,xst=1,title=date_obs+', grating '+grating+', star '+star_name+', Texp='+$
	string(Texp,format='(I3)')+'s, z='+string(z,format='(I2)')+'deg',$
	xtitle='Wavelength, A',ytitle='DQE, %'
device,/close
if os_family() eq 'unix' then set_plot,'X' else set_plot,'WIN'
;create sensitivity curves
sent=fltarr(Nx,2)
sent(*,0)=1/(DQE*2.8E11*S)				;erg
sent(*,1)=sent(*,0)*lambda^2*3.3356E7	;mJy
;save result
writefits,wdir+'traectory.fts',tra
tra=readfits(wdir+'traectory.fts',htra)
sxaddpar,htra,'SEEING',FWHM*scale
writefits,wdir+'traectory.fts',tra,htra
writefits,wdir+'sent.fts',sent
;iplot,sent

end