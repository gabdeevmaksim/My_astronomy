pro linear_for_ZTSh

DIR='e:\Observations\ZTSh\' & night='191025\'
file_neon=dialog_pickfile(PATH=DIR+night+'RAW\',filter=['*.fts','*.fit'])
file_star=dialog_pickfile(PATH=DIR+'RAW\',filter=['*.fts','*.fit'])
neon=readfits(file_neon, hn)
obj=readfits(file_neon, ho)
;star=readfits(file_star, hs)


Ny=sxpar(ho,'NAXIS2') & Nx=sxpar(ho,'NAXIS1') & x=findgen(Ny)   ; find Y position of object spectra
fi_peak, x, obj[Nx/2,*], median(obj), ipix, xpk, ypk, bkpk, ipk  ; find Y position of object spectra
if ipk eq 1 and ipix ne 0 then begin
  Sp_pix=ipix 
endif else begin
  if file_test(DIR+night+'obj_pos.sav') eq 1 then begin
    restore, DIR+night+'obj_pos.sav' 
    Sp_pix=obj_pos
    print, 1
  endif else begin
    print, 'Print pixel where object is!'
    read, obj_pos
    save, obj_pos, filename=DIR+night+'obj_pos.sav'
    Sp_pix=obj_pos
   
  endelse
endelse 
   

;Ny=sxpar(hs,'NAXIS2') & Nx=sxpar(hs,'NAXIS1') & x=findgen(Ny)   ; find Y position of STAR spectra
;fi_peak, x, star[Nx/2,*], median(obj), ipix, xpk, ypk, bkpk, ipk & Sp_pix[1]=ipix ; find Y position of STAR spectra


x=findgen(Nx) 
  RR=where(neon[*,Sp_pix] eq 57000, ind)
  if ind gt 0 then neon[RR,Sp_pix]=median(neon)
  fi_peak, x, neon[*,Sp_pix], median(neon)/1.5, ipix, xpk, ypk, bkpk, ipk
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

 ;;;;;;;;;;;;;;;;;;;;;;;;
 ;plot crioton spectra with found lines and their position
;;;;;;;;;;;;;;;;;;;;;;;;;;
;set_plot, 'win'
;window, 2, xs=1200,ys=300
;plot, x, neon[*,SP_pix], xs=1, ys=1;, xrange=[1500,2000];, yrange=[870, 2200]
;oplot, new_xpk, ypk, PSYM=4
;
;
;for i=0,ipk-1 do xyouts, new_xpk[i],ypk[i],strcompress(string(new_xpk[i])), orientation=90
;openw, 1, DIR+'xpk.txt'
;printf, 1, new_xpk, format='(F7.2)'
;close, 1

x_wl=read_table(DIR+'651_4861.txt')
s=size(x_wl)
  for i=0,s[2]-1 do begin
    rr=where(abs(new_xpk-x_wl[0,i]) lt 5, ind)
    if ind ne 0 then x_wl[0,i]=new_xpk[rr[0]] else x_wl[1,i]=0
  endfor

d=goodpoly(x_wl[0,*],x_wl[1,*],3,3,yfit,newx,newy)
save, d, filename=DIR+night+'disp.sav'
end