pro Heise_read
dir='d:\Observations\RAW\BTA\Nacvlishvily\'
close,1

openr, 1, dir+'p15.out'
nr_inputs = 9286 

zbignr = dblarr(nr_inputs)
zhdnr=zbignr
zbdnr=zbignr
zcdnr=zbignr
zcpdnr=zbignr
zell = dblarr( nr_inputs)
zbee = zell

zpol = fltarr( nr_inputs)
zsigpol = zpol
zthetaeq = zpol
zthetagal = zpol
zsigtheta = zpol
zebmv = zpol
zthetadiff = zpol
zvmag = zpol
zdist = zpol

zidcat = intarr( nr_inputs)
zpolref = zidcat
zjdone = zidcat
zcatnr=intarr(22, nr_inputs)

zsptype = strarr( nr_inputs)

fbignr = 1.0d0
fhdnr=fbignr
fbdnr=fbignr
fcdnr=fbignr
fcpdnr=fbignr
fell = 1.0d0
fbee = fell

fvmag=5.
fvdist=5.
fidcat = 5
fpolref = 5
fjdopne = 5
fcatnr = intarr(22)
fsptype = 'a'

for j = 0, nr_inputs-1 do begin  

readf, 1, fbignr, fhdnr, fbdnr, fcdnr, fcpdnr, $
  fpol, fsigpol, fthetaeq, fsigtheta, fthetagal, $
  fell, fbee, febmv, fthetadiff, fidcat, $
  fvmag, fdist, $
  fsptype, fcatnr, fjdone, $
format='( f18.8,f10.1,3f11.6, 2f9.3,3f7.1, 2f9.4, f7.2, f7.1, i5, f7.1,f8.1, 2x,a16, 22i1, i5)'

zbignr[j] = fbignr
zhdnr[j] = fhdnr
zbdnr[j] = fbdnr
zcdnr[j] = fcdnr
zcpdnr[j] = fcpdnr
zell(j) = fell  
zbee(j) = fbee  
zpol(j) = fpol  
zsigpol(j) = fsigpol  
zthetaeq(j) = fthetaeq  
zthetagal(j) = fthetagal  
zsigtheta(j) = fsigtheta  
zebmv(j) = febmv  
zthetadiff(j) = fthetadiff  
zidcat(j) = fidcat  
zpolref(j) = fpolref  
zcatnr(*, j) = fcatnr  
zvmag[j] = fvmag
zdist[j] = fdist
zsptype[j] = fsptype
zjdone[j] = fjdone
endfor
close, 1

end

;print, bignr[j],hdnr[j],bdnr[j],cdnr[j],cpdnr[j]
;
;print, ell(j),bee(j),thetadiff(j) 
;
;print, idcat(j),sptype[j],jdone[j]
;
;print, catnr(*, j)
