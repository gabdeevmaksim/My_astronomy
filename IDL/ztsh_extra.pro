pro ZTSh_extra

DIR='e:\Observations\ZTSh\' 
file=dialog_pickfile(PATH=DIR,filter=['*.fit','*fts','*.fits'],GET_PATH=DIR)
if file_test(DIR+'obj_pos.sav') eq 1 then restore, DIR+'obj_pos.sav' else read, obj_pos $
& save, obj_pos, filename=DIR+'obj_pos.sav'
spec_img=readfits(file, h)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2') & w2=15
set_plot, 'win'
window, 1, xs=Nx/2, ys=Ny
display_image, spec_img, 1, /modify_opt
click_on_max, spec_img, x, y, /mark
par1=goodpoly(x,y,1,3, yfit, newx, newy)
xpk=poly(findgen(Nx),par1)
spec=fltarr(Nx)
bkg=fltarr(2,40) 
bkg[0,0:19]=findgen(20)+obj_pos-25 & bkg[0,20:39]=findgen(20)+obj_pos+5
restore, DIR+'disp.sav'
wl=poly(findgen(Nx),d)
set_plot, 'ps'
device, filename=DIR+'profiles.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0 
openw, 1, DIR+'spec.txt'
ypk=150
for i=0,Nx-1 do begin
  raw=spec_img[i,*]
  bkg[1,0:19]=raw[obj_pos-25:obj_pos-6] & bkg[1,20:39]=raw[obj_pos+6:obj_pos+25]
  par1=goodpoly(bkg[0,*],bkg[1,*],1,3, yfit, newx, newy)
  raw=raw-poly(findgen(Ny),par1);+3*stddev(poly(findgen(2*w1+1),par1))
  raw(where(raw lt 0))=0
  x=findgen(Ny)
  ;fi_peak, x, raw, median(raw)+5*stddev(raw), ipix, xpk, ypk, bkpk, ipk
  ;if ipk eq 1 and ipix[0] ne 0 and ipix[0] ge w2+1 and ipix[0] le 2*w1-w2 then begin
   
   
   parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
   parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
   parinfo(1).limited(1) = 1 &  parinfo(1).limits(1)  = 10000
   parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 2
   parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 6.
   parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = xpk[i]-4
   parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = xpk[i]+4
   parinfo(*).value = [0,ypk,4,xpk[i]]
   param=mpfitfun('gauss_origin',x[xpk[i]-w2:xpk[i]+w2],raw[xpk[i]-w2:xpk[i]+w2], 0, parinfo=parinfo, yfit=yy, weight=1, /quiet)
   
   
   spec[i]=total(raw[xpk[i]-w2:xpk[i]+w2]) 
   spec[i]=param[1]
   printf, 1, wl[i], spec[i], format='(F10.3,2X,F10.2)'
   ;if param[3] eq 0 then xpk=w1 else xpk=param[3]
   ;if param[1] eq 0 then ypk=3*stddev(spec_img) else ypk=param[1]
   cgplot, raw[xpk[i]-w2:xpk[i]+w2], ys=1
   cgplot, yy, /overplot, color='red'
   xyouts, 4000, 4000, string(param[1]), /device, charsize=3
   ;endif else spec[i]=0
endfor
close, 1
device, /close
set_plot, 'win'
window, 1, xs=Nx/2, ys=400
plot, wl, spec 
end