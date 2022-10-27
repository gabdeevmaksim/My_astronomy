pro err_of_phot

DIR='d:\Observations\RAW\MMPP\20190702\Results\'
name='F191653+430330'
files=file_search(DIR+name+'*.fits',count=N)
fits_open, files[0], fcb
h=headfits(files[0], ext=1)
mag470=dblarr(3,sxpar(h,'NAXIS2')) &  mag540=dblarr(3,sxpar(h,'NAXIS2')) & mag656=dblarr(3,sxpar(h,'NAXIS2'))  
avg_mag470=dblarr(2,sxpar(h,'NAXIS2')) &  avg_mag540=dblarr(2,sxpar(h,'NAXIS2')) & avg_mag656=dblarr(2,sxpar(h,'NAXIS2')) 
ftab_ext, fcb, 'MAG_STD_470,MAG_STD_540,MAG_STD_656,ALPHAWIN_J2000,DELTAWIN_J2000', mag01, mag02, mag03, alp, dec
    fits_open, files[1], fcb1
    ftab_ext, fcb1, 'MAG_STD_470,MAG_STD_540,MAG_STD_656,ALPHAWIN_J2000,DELTAWIN_J2000', mag11, mag12, mag13, alp1, dec1
    fits_open, files[2], fcb2
    ftab_ext, fcb2, 'MAG_STD_470,MAG_STD_540,MAG_STD_656,ALPHAWIN_J2000,DELTAWIN_J2000', mag21, mag22, mag23, alp2, dec2
Ns=N_elements(mag01)
for i=0,Ns-1 do begin
    RR=where(((alp1-alp[i])^2+(dec1-dec[i])^2) lt (7e-4)^2, ind)
    if ind eq 1 then RR1=where(((alp2-alp[i])^2+(dec2-dec[i])^2) lt (7e-4)^2, ind1)
    if ind eq 1 and ind1 eq 1 then begin 
      mag470[0,i]=mag01[i] & mag540[0,i]=mag02[i] & mag656[0,i]=mag03[i] 
      mag470[1,i]=mag11[RR] & mag540[1,i]=mag12[RR] & mag656[1,i]=mag13[RR]
      mag470[2,i]=mag21[RR1] & mag540[2,i]=mag22[RR1] & mag656[2,i]=mag23[RR1]
    endif
endfor  
fits_close, fcb 
fits_close, fcb1
fits_close, fcb2
for i=0,Ns-1 do begin
  avg_mag470[0,i]=mean(mag470[*,i]) & avg_mag470[1,i]=stddev(mag470[*,i])
  avg_mag540[0,i]=mean(mag540[*,i]) & avg_mag540[1,i]=stddev(mag540[*,i])
  avg_mag656[0,i]=mean(mag656[*,i]) & avg_mag656[1,i]=stddev(mag656[*,i])
endfor
m=dblarr(2,8)
for i=13,20 do begin
  RR=where(avg_mag470[0,*] ge i and avg_mag470[0,*] lt i+1, ind)
  m[0,i-13]=ind
  if ind gt 1 then m[1,i-13]=median(avg_mag470[1,RR])
endfor
print, m
set_plot, 'ps'
device, file=DIR+name+'_err_col.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0
cgplot, findgen(9)+13.5, m[1,*], xs=1, ys=1, xrange=[13,21], yr=[0,.1], xtitle='Magnitude, SED470', ytitle='Median error'
xyouts, findgen(9)+13.5, m[1,*], strcompress(string(fix(m[0,*])),/remove_all)
cgplot, avg_mag470[0,*], avg_mag470[1,*], xs=1, ys=1, xtitle='Magnitude, SED470', ytitle='Stddev', psym=4, symsize=.5, xrange=[13,21], yrange=[0,.3]
cgplot, avg_mag540[0,*], avg_mag540[1,*], xs=1, ys=1, xtitle='Magnitude, SED540', ytitle='Stddev', psym=4, symsize=.5, xrange=[13,21], yrange=[0,.3]
cgplot, avg_mag656[0,*], avg_mag656[1,*], xs=1, ys=1, xtitle='Magnitude, SED656', ytitle='Stddev', psym=4, symsize=.5, xrange=[13,21], yrange=[0,.3]
device, /close
set_plot, 'win'
end