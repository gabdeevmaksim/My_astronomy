pro rtt_extra

DIR='e:\Observations\RTT150\'
file=dialog_pickfile(PATH=DIR,filter=['*.fit','*fts','*.fits'],GET_PATH=DIR)
if file_test(DIR+'obj_pos.sav') eq 1 then restore, DIR+'obj_pos.sav' else read, obj_pos $
& save,obj_pos,filename=DIR+'obj_pos.sav' 
fits=readfits(file, h)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2') & w1=49 & w2=15
spec_img=fits(*,obj_pos-w1:obj_pos+w1)
;set_plot, 'win'
;window, 1, xs=Nx/2, ys=w1
;display_image, spec_img, 1, /modify_opt
;click_on_max, spec_img, x, y, /mark
x=fltarr(5) & y=x & dx=202
for i=1,5 do begin
  fi_peak,  findgen(2*w1+1), total(spec_img[i*dx-5:i*dx+5,*],1), median(total(spec_img[i*dx-5:i*dx+5,*],1))/10, ipix, xpk, ypk, bkpk, ipk 
  x[i-1]=i*dx-1 & y[i-1]=ipix[0]
endfor
;y=[49,49,48,48,48]
par1=goodpoly(x,y,1,1, yfit, newx, newy)
xpk=poly(findgen(Nx),par1)
spec=fltarr(Nx)
bkg=fltarr(2,40) 
bkg[0,0:19]=findgen(20) & bkg[0,20:39]=findgen(20)+(2*w1+1)-20
if file_test(DIR+'disp.sav') eq 1 then begin
   restore,  DIR+'disp.sav'
endif else begin
  file_neon=dialog_pickfile(PATH=DIR,filter=['*.fts','*.fit'])
  neon=readfits(file_neon, hn)
  RR=where(neon[*,obj_pos] eq 57000, ind)
  if ind gt 0 then neon[RR,Sp_pix[i]]=median(neon)
  fi_peak, x, neon[*,obj_pos], median(neon[*,obj_pos])/20, ipix, xpk, ypk, bkpk, ipk
  new_xpk=xpk & w=7
  for j=0,ipk-1 do begin
   parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
   parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
   parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 0.
   parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 10.
   parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = xpk[j]-4
   parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = xpk[j]+4
   parinfo(*).value = [0,ypk[j],6,xpk[j]]
   param=mpfitfun('gauss_origin',x[xpk[j]-w:xpk[j]+w],neon[xpk[j]-w:xpk[j]+w,ipix], 0, parinfo=parinfo, yfit=yy, weight=1, /quiet)
   new_xpk[j]=param[3]
  endfor
  x_wl=read_table('e:\Observations\RTT150\RTT_15.txt')
  s=size(x_wl) 
  for i=0,s[2]-1 do begin
    rr=where(abs(new_xpk-x_wl[0,i]) lt 5, ind)
    if ind ne 0 then x_wl[0,i]=new_xpk[rr[0]] else x_wl[1,i]=0
  endfor
  d=goodpoly(x_wl[0,*],x_wl[1,*],3,1,yfit)
  save, d, filename=DIR+'disp.sav'
endelse
wl=poly(findgen(Nx),d)
set_plot, 'ps'
device, file=DIR+'profiles.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0 
openw, 1, DIR+'spec_'+strmid(file,5,2,/rever)+'!.txt'
openw, 2, DIR+'spec_int_'+strmid(file,5,2,/rever)+'!.txt'
ypk=150
for i=0,Nx-1 do begin
  raw=spec_img[i,*]
  bkg[1,0:19]=raw[0:19] & bkg[1,20:39]=raw[2*w1-19:2*w1]
  par1=goodpoly(bkg[0,*],bkg[1,*],1,3, yfit, newx, newy)
  ;raw=raw-poly(findgen(2*w1+1),par1);+3*stddev(poly(findgen(2*w1+1),par1))
  ;raw(where(raw lt 0))=0
  x=findgen(2*w1+1)
  ;fi_peak, x, raw, median(raw)+5*stddev(raw), ipix, xpk, ypk, bkpk, ipk
  ;if ipk eq 1 and ipix[0] ne 0 and ipix[0] ge w2+1 and ipix[0] le 2*w1-w2 then begin
   
   
   parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
   parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
;   parinfo(1).limited(1) = 1 &  parinfo(1).limits(1)  = 76000
   parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 4
   parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 7.
   parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = xpk[i]-4
   parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = xpk[i]+4
   parinfo(*).value = [0,ypk,5.5,xpk[i]]
   param=mpfitfun('gauss_origin',x[xpk[i]-w2:xpk[i]+w2],raw[xpk[i]-w2:xpk[i]+w2], 0, parinfo=parinfo, yfit=yy, weight=1, /quiet)
   
   
   spec[i]=total(raw[xpk[i]-w2:xpk[i]+w2]) 
   printf, 2, wl[i], spec[i], format='(F10.3,2X,F10.2)'
   spec[i]=param[1]
   printf, 1, wl[i], spec[i], format='(F10.3,2X,F10.2)'
   
   ;if param[3] eq 0 then xpk=w1 else xpk=param[3]
   ;if param[1] eq 0 then ypk=3*stddev(spec_img) else ypk=param[1]
   cgplot, raw[xpk[i]-w2:xpk[i]+w2], ys=1
   cgplot, yy, /overplot
   xyouts, 4000, 4000, string(param[1]), /device, charsize=3
   ;endif else spec[i]=0
endfor
close, /all
device, /close
set_plot, 'win'
window, 1, xs=Nx/2, ys=400
plot, wl, spec 
end

