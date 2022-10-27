pro linear_for_UAGS

DIR='e:\Observations\RTT150\' & stand='fg191b2b.dat' & night='T20201124\'
file_neon=dialog_pickfile(PATH=DIR+night+'RAW\',filter=['*.fts','*.fit'])
file_obj=dialog_pickfile(PATH=DIR+night+'RAW\',filter=['*.fts','*.fit'])
;file_star=dialog_pickfile(PATH=DIR+'RAW\',filter=['*.fts','*.fit'])
neon=readfits(file_neon, hn)
obj=readfits(file_obj, ho)
;star=readfits(file_star, hs)
SP_pix=[0,0]

Ny=sxpar(ho,'NAXIS2') & Nx=sxpar(ho,'NAXIS1') & x=findgen(Ny)   ; find Y position of object spectra
fi_peak, x, obj[Nx/2,*], median(obj), ipix, xpk, ypk, bkpk, ipk  ; find Y position of object spectra
if ipk eq 1 and ipix ne 0 then begin
  Sp_pix[0]=ipix 
endif else begin
  if file_test(DIR+night+'obj_pos.sav') eq 1 then begin
    restore, DIR+night+'obj_pos.sav' 
    Sp_pix[0]=obj_pos
    print, 1
  endif else begin
    print, 'Print pixel where object is!'
    read, obj_pos
    save, obj_pos, filename=DIR+night+'obj_pos.sav'
    Sp_pix[0]=obj_pos
   
  endelse
endelse 
   
stop
;Ny=sxpar(hs,'NAXIS2') & Nx=sxpar(hs,'NAXIS1') & x=findgen(Ny)   ; find Y position of STAR spectra
;fi_peak, x, star[Nx/2,*], median(obj), ipix, xpk, ypk, bkpk, ipk & Sp_pix[1]=ipix ; find Y position of STAR spectra


x=findgen(Nx) 
for i=0,0 do begin
  RR=where(neon[*,Sp_pix[i]] eq 57000, ind)
  if ind gt 0 then neon[RR,Sp_pix[i]]=median(neon)
  fi_peak, x, neon[*,Sp_pix[i]], median(neon[*,Sp_pix[i]])/20, ipix, xpk, ypk, bkpk, ipk
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
 
;set_plot, 'win'
;window, 2, xs=1200,ys=300
;plot, x, neon[*,SP_pix[i]], xs=1, ys=1;, xrange=[1500,2000];, yrange=[870, 2200]
;oplot, new_xpk, ypk, PSYM=4
; ;;;;;;;;;;;;;;;;;;;;;;;
; ;plot neon spectra with found lines and their position
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;for i=0,ipk-1 do xyouts, new_xpk[i],ypk[i],strcompress(string(new_xpk[i])), orientation=90
;openw, 1, DIR+'xpk.txt'
;printf, 1, new_xpk, format='(F7.2)'
;close, 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;plot spectra of FeAr lamp with wavelenghts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;window, 1, xs=1200,ys=400
;ss=smooth(readfits('e:\Observations\RTT150\output15364.fits'),15)
;lines=read_ascii('e:\Observations\RTT150\line15364.list.txt')
;plot, ss, xrange=[0,13000], xs=1
;for i=0,49 do xyouts, lines.field1[1,i], 3e4, strcompress(string(lines.field1[3,i])),orientation=90
 
  x_wl=read_table(DIR+'RTT_15.txt')
  s=size(x_wl) 
  for i=0,s[2]-1 do begin
    rr=where(abs(new_xpk-x_wl[0,i]) lt 5, ind)
    if ind ne 0 then x_wl[0,i]=new_xpk[rr[0]] else x_wl[1,i]=0
  endfor
  d=goodpoly(x_wl[0,*],x_wl[1,*],3,1,yfit)
  save, d, filename=DIR+night+'disp.sav'
  stop
  wl=poly(x,d) & a=0.012 & c=0.12 & z=[sxpar(ho,'Z'),sxpar(hs,'Z')] & expos=[sxpar(ho,'EXPTIME'),sxpar(hs,'EXPTIME')]
  if i eq 0 then begin
    sxaddpar, ho, 'CDELT1', (wl[Nx-1]-wl[0])/Nx
    sxaddpar, ho, 'CRVAL1', wl[0]
    sxaddpar, ho, 'CRPIX1', 1
    writefits, DIR+'Gabdeev\obj.fit', obj, ho
    set_plot, 'PS'
    spextra_proc, DIR+night+'obj.fit', [150, Sp_pix[0], 3.8], foncont=[2,20.,50.,100.,130], par_smo=[0], wdir=wdir, /plot, lim_fwhm=[1.,8.], lim_cent=[9.,9.], aper=[1,3,3]
    set_plot, 'win'
    obj_sp=readfits(DIR+night+'obj_spect_1.fts') & obj_sp_new=fltarr(2,N_elements(obj_sp))
    wl_new=findgen(Nx)*sxpar(ho,'CDELT1')+wl[0]
    par=spl_init(wl,obj_sp)
    obj_sp_new[1,*]=spl_interp(wl,obj_sp,par,wl_new)
    obj_sp_new[0,*]=wl_new
    extin_tab=((a*1./(wl_new/10000.)^4.)+c);*2.5*alog10(exp(1))
    obj_sp_new[1,*]=smooth((obj_sp_new[1,*]-(extin_tab/cos(z[i]*!DTOR)))/expos[i],5)
    ;cgplot, wl_new, obj_sp_new
    ;cgplot, wl, obj_sp[1,*], color='red', linestyle=2, /overplot
  endif else begin
    sxaddpar, hs, 'CDELT1', (wl[Nx-1]-wl[0])/Nx
    sxaddpar, hs, 'CRVAL1', wl[0]
    sxaddpar, hs, 'CRPIX1', 1
    writefits, DIR+night+'star.fit', star, hs  
    set_plot, 'PS'
    spextra_proc, DIR+night+'star.fit', [150, Sp_pix[1], 3.8], foncont=[2,20.,50.,100.,130], par_smo=[0], wdir=wdir, /plot, lim_fwhm=[1.,8.], lim_cent=[9.,9.], aper=[1,3,3]
    set_plot, 'win'
    obj_sp=readfits(DIR+night+'obj_spect_1.fts') & star_sp_new=fltarr(2,N_elements(obj_sp))
    wl_new=findgen(Nx)*sxpar(ho,'CDELT1')+wl[0]
    par=spl_init(wl,obj_sp)
    star_sp_new[1,*]=spl_interp(wl,obj_sp,par,wl_new)
    star_sp_new[0,*]=wl_new
    extin_tab=((a*1./(wl_new/10000.)^4.)+c)
    star_sp_new[1,*]=smooth((star_sp_new[1,*]-(extin_tab/cos(z[i]*!DTOR)))/expos[1],5)
    endelse
endfor
  ST=read_table('c:\IDL_lib\scorpio_2K.lib\standards\fg191b2b.dat')
  par=spl_init(ST[0,*],ST[1,*])
  ST_new=spl_interp(ST[0,*],ST[1,*],par,wl_new)
  obj_flu=obj_sp_new[1,*]/star_sp_new[1,*]*ST_new
  ;obj_flu=star_sp_new[1,*]*ST_new
  openw, 1, DIR+night+sxpar(ho,'OBJECT')+'.dat'
  for i=0,Nx-1 do printf, 1, obj_sp_new[0,i], obj_flu[i], format='(F7.2,2X,E12.4)'
  close, 1
end
