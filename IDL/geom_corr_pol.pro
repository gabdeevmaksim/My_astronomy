pro geom_corr_pol

DIR='d:\Observations\Processed\BTA\s151107\standart_0\05\' ; choose directory
files=file_search(DIR+'neon*.fts',count=Nf) ; neon files
o_files=file_search(DIR+'obj*.fts') ; obj files
fl_files=file_search(DIR+'flat*.fts') ; flat files
for ii=0,Nf-2 do begin ; 
  img=readfits(files[ii],h) ; read neon file
  A=size(img) & Nx=A[1]-350 ; define massif size
  sum=fltarr(Nx) & neon=fltarr(Nx,A[2]) ; define massif
  neon=img[350:*,*] ; write cut image to massif
  nnn=[0,0,2,10] ; rows for ploting and finding peaks 
  sum=neon[*,nnn[ii]] ; write spectra from row nnn to individual variable
  !P.multi=0 
  window, 0, xs=1800
  plot, sum, xs=1
  x=findgen(Nx) & thresh=[250,260,250,250] ; define threshold to fi_peak
  fi_peak, x, sum, thresh[ii], ipix, xpk, ypk, bkpk, ipk
  cgplot, xpk, ypk, /overplot, PSYM=4
  openw, 1, DIR+'xpk0'+strcompress(string(ii+1),/remove_all)+'.txt' ; write peaks information to file
  for i=0, ipk-1 do printf, 1, xpk[i], ypk[i]
  close, 1
  table=read_table(DIR+'xpk-wl0'+strcompress(string(ii+1),/remove_all)+'.txt') ; read table with pixel to wavelength identification
  coef=[3,3,4,7] 
  ipk=ipk-coef[ii]
  new_xpk=fltarr(ipk,A[2]+1)
  w=7
  for i=0,A[2]-1 do begin
    if i ne 0 then xpk=fix(new_xpk[*,i-1]) else xpk[0:ipk]=table[0,*]
    for j=0,ipk-1 do begin
      parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
      ;parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = linbg[i,j]-5000
        parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
        parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 0.
        parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 10.
        parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = xpk[j]-4
        parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = xpk[j]+4
        parinfo(*).value = [0,ypk[j],6,xpk[j]]
      param=mpfitfun('gauss_origin',x[xpk[j]-w:xpk[j]+w],neon[xpk[j]-w:xpk[j]+w,i], 0, parinfo=parinfo, yfit=yy, weight=1, /quiet)
      new_xpk[j,i]=param[3]
   ;  window, 2
   ;  cgplot, x[xpk[j]-w:xpk[j]+w],neon[xpk[j]-w+350:xpk[j]+w+350,i], ys=1
   ;  cgplot, x[xpk[j]-w:xpk[j]+w], yy, color='red', /overplot
    endfor
  endfor
  new_xpk[*,A[2]]=table[2,0:ipk-1]
  openw, 1, DIR+'xpk-wl_new0'+strcompress(string(ii+1),/remove_all)+'.txt'
  for i=0,ipk-1 do printf, 1, new_xpk[i,*], format='(81(F7.2,2X))'
  close, 1
  chisla=intarr(ipk,A[2])
  for i=0,A[2]-1 do chisla[*,i]=i
  window, 1, xsize=1700, ysize=200
  plot, x, findgen(A[2]), /nodata
  for i=0,A[2]-1 do oplot, new_xpk[*,i],chisla[*,i], psym=3

  deg=3 & disp=fltarr(deg+1,A[2]) & errdisp=fltarr(ipk,A[2])
  for i=0,A[2]-1 do begin
    d=goodpoly(new_xpk[*,i],new_xpk[*,A[2]],deg,3,yfit)
    disp[*,i]=d
    errdisp[*,i]=sqrt((new_xpk[*,A[2]]-yfit)^2)
  endfor


  X_Y=fltarr(2,ipk*A[2]) & Z=fltarr(ipk*A[2]) & Y=findgen(A[2])
  openw, 1, DIR+'X_Y0'+strcompress(string(ii+1),/remove_all)+'.txt'
  openw, 2, DIR+'Z0'+strcompress(string(ii+1),/remove_all)+'.txt'
  for i=0,ipk-1 do begin
    for j=0,A[2]-1 do begin
      printf, 1, new_xpk[i,j], y[j]
      printf, 2, table[2,i]
    endfor
  endfor
  close, /all

  X_Y=read_table(DIR+'X_Y0'+strcompress(string(ii+1),/remove_all)+'.txt')
  Z=read_table(DIR+'Z0'+strcompress(string(ii+1),/remove_all)+'.txt')
  EXTRA={EXTRA,X_deg:0, Y_deg:0} & EXTRA.X_deg=5 & EXTRA.Y_deg=3 & p=fltarr((EXTRA.X_deg+1)*(EXTRA.Y_deg+1)) & p[*]=0 
  ;mode=xy_polinom(X_Y[0,*],X_Y[1,*],p,X_deg=5,Y_deg=3)
  param=mpfit2dfun('xy_polinom',X_Y[0,*],X_Y[1,*],Z[*],1,p,weights=1,functargs=EXTRA, yfit=yfit, /quiet)
  ;iplot, X_Y[0,*],X_Y[1,*],Z, /Scatter, syms=4
  ;iplot, X_Y[0,*],X_Y[1,*],yfit, /overplot, color=30000, syms=4, /Scatter
;  std=fltarr(ipk)
;  for i=0,ipk-1 do begin
;    robomean, Z[i*80:(i+1)*80-1]-yfit[i*80:(i+1)*80-1], 3, 1, avg, avgdev, stddev
;    std[i]=stddev  
;  endfor

  Y=findgen(A[2])
  XI = X # (Y*0 + 1)
  YI = (X*0 + 1) # Y

  ZZ=xy_polinom(XI,YI,param,X_deg=EXTRA.X_deg,Y_deg=EXTRA.Y_deg)
;  if ii eq 0 then begin
    Wl_min=max(ZZ[0,*]) & Wl_max=min(ZZ[Nx-1,*]) & dWl=(Wl_max-Wl_min)/(Nx)
;    save, Wl_min, Wl_max, dWL, FILENAME=DIR+'linear_coef.sav'
;  endif else restore, DIR+'linear_coef.sav'
  restore, DIR+'linear_coef.sav'
  Wl_new=findgen(Nx)*dWl+Wl_min
  XI_new=XI
  for i=0,A[2]-1 do begin
    xx=0
    for j=0,Nx-1 do begin
      xx=xx
      while abs(xy_polinom(xx,YI[j,i],param,X_deg=EXTRA.X_deg,Y_deg=EXTRA.Y_deg)-Wl_new[j]) gt 0.020 do begin xx=xx+0.01 
      ;print, abs(xy_polinom(xx,YI[j,i],param,X_deg=EXTRA.X_deg,Y_deg=EXTRA.Y_deg)-Wl_new[j]) & wait, 0.5
      endwhile
      XI_new[j,i]=xx
    endfor
  endfor

  o=readfits(o_files[ii],h_o)
  fl=readfits(fl_files[ii],h_fl)
  o_new=neon & fl_new=neon
  o_new=o[350:*,*] & fl_new=fl[350:*,*]
  Img_new=interpolate(neon,XI_new,YI)  
  o_new=interpolate(o_new,XI_new,YI)
  fl_new=interpolate(fl_new,XI_new,YI)

;  window,2,xsize=1000,ysize=805
;
;  rms=stdev(neon(Nx/2-Nx/4:Nx/2+Nx/4,*),avg)
;  tv,255-bytscl(congrid(Img_new,1000,400),0,avg+rms),0,0

  writefits, DIR+'corr_'+sxpar(h,'IMAGETYP')+'0'+strcompress(string(ii+1),/remove_all)+'.fts', Img_new, h
  writefits, DIR+'corr_'+sxpar(h_o,'IMAGETYP')+'0'+strcompress(string(ii+1),/remove_all)+'.fts', o_new, h_o
  writefits, DIR+'corr_'+sxpar(h_fl,'IMAGETYP')+'0'+strcompress(string(ii+1),/remove_all)+'.fts', fl_new, h_fl
endfor

end