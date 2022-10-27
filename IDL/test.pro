pro test

file=dialog_pickfile(PATH='f:\!!!Pract\OBSst\RAW\120817\')
dir='f:\!!!Pract\OBSst\RAW\120817\Standard\'
;dir='f:\!!!Pract\OBSst\RAW\120817\'
bias=readfits('f:\!!!Pract\OBSst\RAW\120817\Reduction\SBias.fit')
flat=readfits('f:\!!!Pract\OBSst\RAW\120817\Reduction\SFlatI.fit')
img=(readfits(file,head)-bias)/flat
XS=sxpar(head, 'NAXIS1') & YS=sxpar(head, 'NAXIS2') & Texp=sxpar(head, 'EXPTIME')
sky, img, skymode, skysig
s=3*skysig & ap=8
find, img, x, y, flux, sharp, roundness,s,ap,[-1.0,1.0],[0.2,0.8], /silent
aper,  img, x, y, mags, errap, sky, skyerr, 2.01, 20, [21,23], $
      [0,56000];, /silent
openw, lun, dir+'aper_phot.txt', /get_lun
for i=0,N_elements(x)-1 do printf, lun, i+1, x[i], y[i], mags[i], format='(I3,2X,3(F8.3,2X))'
close, lun
group, x, y, 50, ngroup
G=where(errap le 0.02,ind)
R=where((ngroup[G] ne ngroup[G-1]) and (ngroup[G] ne ngroup[G+1]))
window, 2, xsize=XS/3*2, ysize=YS/3*2
display_image, img-skymode, 2, $
               options={range:[3*skysig,2500],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
tvcircle, 6, x[G[R]]/3*2, y[G[R]]/3*2, color='red', THICK=1
tvcircle, 8, x/3*2, y/3*2, color='blue', THICK=1
getpsf, img, x, y, mags, sky, 2.9, 2.01, gauss, psf, G[R], 45, 11, $
        dir+'psf.fit';, /DEBUG 
R=where((mags ne 99.999) and (mags gt 0))
N=N_elements(R) & mags1=fltarr(N) & x1=fltarr(N) & y1=fltarr(N) 
sky1=fltarr(N) & ngroup1=fltarr(N)
mags1=mags[R] & x1=x[R] & y1=y[R] & sky1=sky[R] & ngroup1=ngroup[R]
R=findgen(N)
group, x1, y1, 26, ngroup1 
nstar,  img, R, x1, y1, mags1, sky1, ngroup1, 2.01, 2.9, dir+'psf.fit', $
        errmag, iter, chisq, peak, PRINT=dir+'phot.txt'
substar, img, x1, y1, mags1, R, dir+'psf.fit', VERBOSE = verbose
window, 1, xsize=XS/3*2, ysize=YS/3*2
display_image, img, 1, options={range:[skysig,2500],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
tvcircle, 6, x1/3*2, y1/3*2, color='red', THICK=1
end