pro disper_pol, DIR=DIR

files=file_search(DIR+'s13480408.fts', count=N)
img=readfits('d:\Observations\Processed\BTA\s151107\standart_lin\old\obj_i.fts',h)
rr=WHERe(img lt 0, ind)
if ind gt 0 then img[rr]=0
sum=total(img,1)
Ys=sxpar(h,'NAXIS2') & Xs=sxpar(h,'NAXIS1')
xpl=findgen(Ys)
fi_peak, xpl, sum,  1e5, ipix, xpk1, ypk1, bkpk1, ipk1
neon=readfits(files[0],h) & neon1=fltarr(8,Xs-350) & w=10 & Nl=44 & Linpos=fltarr(8,Nl) & xpl=findgen(Xs-350) & linint=fltarr(8,Nl) & linbg=fltarr(8,Nl)
f_lines=file_search(DIR+'ident_n*.txt',count=Nlines)
lines=fltarr(Nlines,Nl)
for i=0,Nlines-1 do lines[i,*]=read_table(f_lines[i])
window, 1, xs=1800, ys=1000
!p.MULTI=[0,1,4]
for i=0,ipk1-1 do begin
  neon1[i,*]=total(neon[350:*,xpk1[i]-w:xpk1[i]+w],2)
  pkcut=500.0 & ipk=0
  while ipk ne 44 do begin
    fi_peak, xpl, neon1[i,*], pkcut, ipix, xpk, ypk, bkpk, ipk
    ;print, i, ipk
    pkcut=pkcut+50
  endwhile
  linpos[i,*]=xpk & linint[i,*]=ypk & linbg[i,*]=bkpk
  plot, neon1[i,*], xs=1, ys=1
  oplot, xpk, ypk, PSYM=4;, /overplot
  xyouts, xpk, ypk, string(lines[i,*]), orient=90; , color=3000
endfor
window, 2, xs=1800, ys=1000
!p.MULTI=[0,1,4]
for i=4,2*ipk1-1 do begin
  neon1[i,*]=total(neon[350:*,xpk1[i-4]+w+2:xpk1[i-4]+3*w+2],2)
  if i eq 7 then neon1[i,*]=total(neon[350:*,xpk1[i-4]-3*w-2:xpk1[i-4]-w-2],2)
  pkcut=500 & ipk=0
  while ipk ne Nl do begin
    fi_peak, xpl, neon1[i,*], pkcut, ipix, xpk, ypk, bkpk, ipk
    pkcut=pkcut+10
    ;print, i, ipk
  endwhile
  linpos[i,*]=xpk & linint[i,*]=ypk & linbg[i,*]=bkpk
  plot, neon1[i,*], xs=1, ys=1, xr=[176,188]
  oplot, xpk, ypk, PSYM=4;, /overplot 
  xyouts, xpk, ypk, string(lines[i,*]), orient=90; , color=3000
endfor
openw, 1, DIR+'lin_pos.txt'
for i=0,Nl-1 do printf, 1, linpos[*,i], format='(8(F7.2,2X))'
close, 1
!p.multi=0
;window, 3
;w=6
;for i=0,7 do begin
;  for j=0,Nl-1 do begin
;    parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
;      parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = linbg[i,j]-5000
;      parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
;      parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 5.
;      parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 10.
;      parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = linpos[i,j]-2
;      parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = linpos[i,j]+2
;      ;start=[0,linint[i,j]-linbg[i,j],6,linpos[i,j]]
;      parinfo(*).value = [linbg[i,j],linint[i,j]-linbg[i,j],6,linpos[i,j]]
;    param=mpfitfun('gauss_origin',xpl[linpos[i,j]-w:linpos[i,j]+w],neon1[i,linpos[i,j]-w:linpos[i,j]+w], 0, parinfo=parinfo, yfit=yy, weight=1)
;    ;cgplot, xpl[linpos[i,j]-w:linpos[i,j]+w],neon1[i,linpos[i,j]-w:linpos[i,j]+w], xs=1, ys=1
;    ;cgplot, xpl[linpos[i,j]-w:linpos[i,j]+w], yy, /overplot, color='red'
;    linpos[i,j]=param[3]
;endfor & endfor
;openw, 1, DIR+'lin_pos_new.txt'
;for i=0,Nl-1 do printf, 1, linpos[*,i], format='(8(F7.2,2X))'
;close, 1
disp=fltarr(8,4)
for i=0,7 do disp[i,*]=goodpoly(linpos[i,*],lines[i,*],3,1,yfit)
writefits, DIR+'disp.fts', disp  
cgplot, poly(xpl,disp[0,*]), xs=1,ys=1
end
disper_pol, DIR='d:\Observations\Processed\BTA\s151107\standart_lin\'
end