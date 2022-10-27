pro fit_lines, DIR=dir, N_peaks=N_peaks

name=['sum_3']
l_pos=1067
img=readfits(dir+name+'.fts',h)
w=15 & Ny=sxpar(h,'NAXIS2') & tempo=fltarr(Ny-1,1+2*w) & step=5  
t=fltarr(1+2*w) & x=findgen(2*w+1) & YVALS=fltarr((Ny-1)/step,2*w+1) & YVALS1=fltarr((Ny-1)/step,2*w+1)
tempo=img[l_pos-w:l_pos+w,0:Ny-2]
set_plot, 'PS'
device, file=DIR+'Ha.ps',xsize=16,ysize=16, /portrait
openw, lun, DIR+'Ha_line.txt', /get_lun
openw, lun1, DIR+'params_Ha.txt', /get_lun


if N_peaks eq 2 then begin
;;;;;;;;;;;;;;;;;  for TWO-peak gaussin ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

A=fltarr((Ny-1)/step,7)
coef=[10.,   -0.0360988,  0.000828844,-7.77327e-006, 3.19875e-008,-4.86245e-011] & xk=poly(findgen(Ny/step),coef)
coef2=[10600.,      56.9874,   -0.0711947,  -0.00282802, 9.99942e-006,-1.06415e-008] & Ak=poly(findgen(Ny/step),coef2)

for k=0,Ny-2-step,step do begin
  t=total(tempo[*,k:k+step],2)
  printf, lun, t, format='(31(F7.2,2X))'
  fi_peak, x, t, 3, ipix, xpk, ypk, bkpk, ipk

  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 7)    
      parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = bkpk[0]-200
      parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
      parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 5.6
      parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 5.4
      parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = 13.0
      ;parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = 9.0
      parinfo(4).limited(1) = 1 &  parinfo(4).limits(1)  = Ak[k/step]+250
      parinfo(4).limited(0) = 1 &  parinfo(4).limits(0)  = Ak[k/step]-250
      parinfo(5).limited(1) = 1 &  parinfo(5).limits(1)  = 5.6
      parinfo(5).limited(0) = 1 &  parinfo(5).limits(0)  = 5.4     
      parinfo(6).limited(1) = 1 &  parinfo(6).limits(1)  = xk[k/step]+.1
      parinfo(6).limited(0) = 1 &  parinfo(6).limits(0)  = xk[k/step]-.1  
                                                                
    if N_elements(xpk) gt 1 then parinfo(*).value = [bkpk[0],500,5.5,15.5,Ak[k/step],5.5,xk[k/step]] else parinfo(*).value = [bkpk[0],500,5.5,15.5,Ak[k/step],5.5,xk[k/step]]
    parms = MPFITFUN('two_gauss', x, t, ERR=0, parinfo=parinfo, yfit=yy, WEIGHTS=1)
    o=k/step & A[o,*]=parms
    printf, lun1, parms[0], parms[1],parms[2],parms[3],parms[4],parms[5],parms[6], format='(F7.2,2X,F9.1,2X,F7.4,2X,F7.3,2X,F9.1,2X,F7.4,2X,F7.3)'
    p=[A(o,0),A(o,1),A(o,2),A(o,3)]  
    p1=[A(o,0),A(o,4),A(o,5),A(o,6)]
    YVALS[o,*] = gauss_origin(x, p[0:3])
    yvals1[o,*] = gauss_origin(x, p1)
    cgplot, t, title=string(k)+string(A(o,3))+string(A(o,2))+string(A(o,1)/A(o,0))
    cgoplot, YVALS[o,*], color='red'
    cgoplot, YVALS1[o,*], color='green'
endfor

x2=findgen((Ny-1)/step)
coef=ROBUST_POLY_FIT(X2,A[*,3],5, Yfit)
coef1=ROBUST_POLY_FIT(X2,A[*,6],5, Yfit)
coef2=ROBUST_POLY_FIT(X2,A[*,1],5, Yfit2)
print, coef, coef1, coef2
cgplot, x2, A[*,3], yrange=[5,25], title='Peak position'
cgoplot, x2, yfit, color='red'
cgplot, x2, A[*,1], title='Area';, yrange=[0,10000]
cgoplot, x2, yfit2, color='red'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; for ONE-peak gaussian ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endif else begin

A=fltarr((Ny-1)/step,4)

for k=0,Ny-2-step,step do begin
  t=total(tempo[*,k:k+step],2)
  printf, lun, t, format='(31(F7.2,2X))'
  fi_peak, x, t, 3, ipix, xpk, ypk, bkpk, ipk
  parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
      parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = bkpk[0]-100
      parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
      parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 5.6
      parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 5.4
      ;parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = xpk[0]-2
      ;parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = xpk[0]+2
      
  if N_elements(xpk) gt 1 then parinfo(*).value = [bkpk[0],500,5.4,xpk[0]] else parinfo(*).value = [bkpk[0],500,5.4,xpk[0]]

  parms = MPFITFUN('gauss_origin', x, t, ERR=0, parinfo=parinfo, yfit=yy, WEIGHTS=1)
  o=k/step & A[o,*]=parms
  printf, lun1, parms[0], parms[1],parms[2],parms[3], format='(F7.2,2X,F9.1,2X,F7.4,2X,F7.3)'
  p=[A(o,0),A(o,1),A(o,2),A(o,3)]
  YVALS[o,*] = gauss_origin(x, p[0:3])
  cgplot, t, title=string(k)+string(A(o,3))+string(A(o,2))+string(A(o,1)/A(o,0))
  cgoplot, YVALS[o,*], color='red'
endfor
;close, /all
x2=findgen((Ny-1)/step)
coef=ROBUST_POLY_FIT(X2,A[*,3],5, Yfit)
coef2=ROBUST_POLY_FIT(X2,A[*,1],5, Yfit2)
print, coef, coef2
cgplot, x2, A[*,3], yrange=[5,25], title='Peak position'
cgoplot, x2, yfit, color='red'
cgplot, x2, A[*,1], title='Area';, yrange=[0,10000]
cgoplot, x2, yfit2, color='red'
endelse


device, /close
close, /all
set_plot, 'win'
end
fit_lines, DIR='d:\Observations\Processed\BTA\s160826\', N_peaks=2
end  
  
  