pro extra_spec_pol, DIR=DIR

files=file_search(DIR+'obj_i.fts',count=N)
disp=readfits(DIR+'disp.fts')
for i=0,N-1 do begin
  img=readfits(files[i],h)
  rr=WHERe(img lt 0, ind)
  if ind gt 0 then img[rr]=0
  sum=total(img,1)
  Ys=sxpar(h,'NAXIS2') & Xs=sxpar(h,'NAXIS1')
  xpl=findgen(Ys)
  cgplot, xpl, sum
  fi_peak, xpl, sum,  1e5, ipix, xpk, ypk, bkpk, ipk
  ;print, xpk
  spec=dblarr(ipk*2,Xs-350) & w=20 & wl=dblarr(ipk*2,Xs-350) 
  xpl=findgen(Xs-350)
  for j=0,ipk-1 do begin
    spec[j*2,*]=total(img[350:*,xpk[j]-w:xpk[j]+w],2)
    wl[j*2,*]=poly(xpl,disp[j,*])
    spec[j*2+1,*]=total(img[350:*,xpk[j]+w+2:xpk[j]+3*w+2],2)
    wl[j*2+1,*]=poly(xpl,disp[j+4,*])
    if j eq 3 then begin
      spec[j*2+1,*]=total(img[350:*,xpk[j]-3*w-2:xpk[j]-w-2],2)
      wl[j*2+1,*]=poly(xpl,disp[j+4,*])     
    endif
  endfor
endfor
xpl=findgen(Xs-350)
openw, 1, 'd:\Observations\Processed\BTA\s151107\standart_lin\spectra.txt'
for i=0,Xs-351 do  printf, 1, wl[*,i], spec[*,i], format='(8(F7.2,2X),8(F9.3,2X))'
close, 1                          
  
!P.multi=0
window,0
cgplot, wl[0,*], spec[0,*], xs=1, ys=1;, xr=[6300,6500]
cgplot, wl[2,*], spec[2,*], /overplot, color='red'
cgplot, wl[4,*], spec[4,*], /overplot, color='blue'
cgplot, wl[6,*], spec[6,*], /overplot, color='green'
window, 1

cgplot, wl[1,*], spec[1,*], xs=1, ys=1;, xr=[5500,5600]
cgplot, wl[3,*], spec[3,*], /overplot, color='red'
cgplot, wl[5,*], spec[5,*], /overplot, color='blue'
cgplot, wl[7,*], spec[7,*], /overplot, color='green'

Dwl=(poly(Xs-350,disp[0,*])-poly(0,disp[0,*]))/(Xs-350)
wl_new=findgen(Xs-350)*Dwl+poly(0,disp[0,*])

for i=0,7 do begin
  par=spl_init(wl[i,*], spec[i,*],/double)
  spec[i,*]=spl_interp(wl[i,*], spec[i,*],par,wl_new,/double)
endfor

!p.MULTI=0
 i=4
fi_peak, wl_new, spec[i,*], 1000, ipix, xpk, ypk, bkpk, ipk
window, 4
cgplot, wl_new, spec[i,*], xs=1, ys=1
cgplot, xpk, ypk, psym=4, /overplot
;stop, xpk
;for i=0,7 do begin
; 
;  fi_peak, xpl, spec[i,*], 1000, ipix, xpk, ypk, bkpk, ipk 
;  w=6
;  for j=0,ipk-1 do begin
;      parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
;      parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = 0
;      parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
;      parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 5.
;      parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 10.
;      parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = xpk[j]-2
;      parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = xpk[j]+2
;      parinfo(*).value = [0,0,6,xpk[j]]
;    param=mpfitfun('gauss_origin',xpl[xpk[j]-w:xpk[j]+w],spec[i,xpk[j]-w:xpk[j]+w], 0, parinfo=parinfo, yfit=yy, weight=1)
;  xpk[j]=param[3]  
;  endfor
;  sky_lines=read_table(DIR+'ident_sky'+strcompress(strInG(I),/remove_all)+'.txt')
;  if ipk eq N_elements(sky_lines) then disp_new=goodpoly(xpk,sky_lines,3,1) else stop, ipk, N_elements(sky_lines)
;  wl_new2=poly(xpl,disp_new)
;  par=spl_init(wl_new2, spec[i,*],/double)
;  spec[i,*]=spl_interp(wl_new2, spec[i,*],par,wl_new,/double)
;endfor

;s_spec=fltarr(8,190) & wl_s=fltarr(190) & w=10
;for j=0,189 do begin
;  wl_s[j]=wl_new[j*w+43]
;endfor
;
;;for i=0,7 do begin  
;;    s_spec[i,j]=median(spec[i,j*w+43-5:j*w+43+4])
;;endfor
s_spec=spec
;for i=0,7 do begin  
;  print, size(spec[i,*],/dim)
;  s_spec[i,*]=median(spec[i,*],10, dim=2)
;endfor
  
Q=(s_spec[2,*]-s_spec[6,*])/(s_spec[2,*]+s_spec[6,*])*100
U=(s_spec[0,*]-s_spec[4,*])/(s_spec[0,*]+s_spec[4,*])*100
Q_sky=(s_spec[1,*]-s_spec[3,*])/(s_spec[1,*]+s_spec[3,*])*100
U_sky=(s_spec[5,*]-s_spec[7,*])/(s_spec[5,*]+s_spec[7,*])*100
;Q_par=goodpoly(wl_s,Q_sky,3,1)
;U_par=goodpoly(wl_s,U_sky,3,1)

;Q=(median(spec[0,*],5)-median(spec[2,*],5))/(median(spec[0,*],5)+median(spec[2,*],5))*100
;U=(median(spec[4,*],5)-median(spec[6,*],5))/(median(spec[4,*],5)+median(spec[6,*],5))*100
;Q_sky=(median(spec[1,*],5)-median(spec[3,*],5))/(median(spec[1,*],5)+median(spec[3,*],5))*100
;U_sky=(median(spec[5,*],5)-median(spec[7,*],5))/(median(spec[5,*],5)+median(spec[7,*],5))*100
;Q_par=goodpoly(wl_new,Q_sky,3,1)
;U_par=goodpoly(wl_new,U_sky,3,1)

window, 5
wl_s=wl_new
!P.multi=0
cgplot, wl_s, spec[1,*], xs=1, ys=1;, xr=[6250,6500]
cgplot, wl_s, spec[3,*], /overplot, color='red'
cgplot, wl_s, spec[5,*], /overplot, color='blue'
cgplot, wl_s, spec[7,*], /overplot, color='green'

window, 2, title='Obj', xs=1200,ys=600
!P.MULTI=[0,1,2]
plot, wl_s, Q, title='Q', yr=[-10,10], xs=1, ys=1
plot, wl_s, U, title='U', yr=[-10,10];, xs=1, ys=1
cgplot, [0,10000], [0,0], color='red', /overplot
window,3, title='Sky', xs=600,ys=600
cgplot, wl_s, Q_sky, xs=1, ys=1, title='Q', yr=[-10,10]
;cgplot, wl_s, poly(wl_s,Q_par), color='red', /overplot
cgplot, wl_s, U_sky, xs=1, ys=1, title='U', yr=[-10,10]
;cgplot, wl_s, poly(wl_s,U_par), color='red', /overplot
end
extra_spec_pol, DIR='d:\Observations\Processed\BTA\s151107\standart_lin\'
end