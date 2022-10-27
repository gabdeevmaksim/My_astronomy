pro daophot_test

DIR = 'e:\Observations\RTT150\20211209\obsdata\SRGA213151\'
files = file_search(DIR, '*.fit', count=N_files)

image = readfits(files[0],img_hdr)
Nx = sxpar(img_hdr, 'NAXIS1') & Ny = sxpar(img_hdr, 'NAXIS2')
sky, image, skymode, skysig
adu = sxpar(img_hdr, 'GAINM')
ronoise = sxpar(img_hdr, 'RDNOISE')
hmin = SQRT(adu*SKYMODE + ronoise)
find, image, x, y, flux, sharp, roundness, hmin, 6, [-1.0,1.0], [0.2,1.0]
;t_find, image, img_hdr, DIR+'find.fits', hmin, 6;, [-1.0,-1.0], [0.2,1.0]
aper, image, x, y, mags, errap, sky, skyerr, adu, 6, [8,10], [0,60000], /silent
;t_aper, image, DIR+'find.fits', 6, [8,10], [0,60000], NEWTABLE = DIR+'aper.fits', print = DIR+'aper.dat'
stop
;; search isolated stars
;;1) choose measured stars
;  rr = where(mags ne 99.999 and mags gt 0, ind)
;  if ind gt 0 then begin
;    x_meas = x[rr] & y_meas = y[rr] & m_meas = mags[rr]
;  endif
;;2) choose stars with median brightness in the center part of field
;  rr = where(m_meas lt median(m_meas)-0.5*stdev(m_meas) and m_meas gt median(m_meas)-1*stdev(m_meas) and $
;           x_meas lt Nx-Nx/4 and x_meas gt Nx/4 and y_meas lt Ny-Ny/4 and y_meas gt Ny/4,ind)
;  if ind ge 1 then begin
;    x_med = x_meas[rr] & y_med = y_meas[rr] & m_med = m_meas[rr]
;  endif
;;print, N_elements(x_med), x_med[0], y_med[0], m_med[0]
;;3) choose independent stars 
;  j=0 & r=30.
;  for i = 0,N_elements(x_med)-1 do begin
;    rr=where((x_med[i]-x)^2+(y_med[i]-y)^2 lt (r^2), ind)
;    if ind le 1 then j++
;  endfor
;  x_psf = fltarr(j) & y_psf = fltarr(j) & m_psf = fltarr(j) & sky_psf = fltarr(j) & k=0
;  for i = 0,N_elements(x_med)-1 do begin
;    rr=where((x_med[i]-x)^2+(y_med[i]-y)^2 lt (r^2), ind)
;    if ind le 1 then begin
;      x_psf[k] = x_med[i] & y_psf[k]=y_med[i] & m_psf[k] = m_med[i] & sky_psf[k]=sky[i] & k++
;    endif
;  endfor
;stop, x_psf*2, y_psf*2
x = [462, 499, 495] & y = [451, 499, 502] 
cntrd, image, x, y, x_psf, y_psf, 3
aper, image, x_psf, y_psf, mags, errap, sky, skyerr, adu, 4, [10,15], [0,60000], /silent
getpsf, image, x_psf, y_psf, mags, sky, ronoise, adu, gauss, psf, '0', 5, 4, DIR+'psf.fits'
;help, psf
;stop
group, x_psf, y_psf, 10, ngroup
nstar, image, sindgen(N_elements(x)), x_psf, y_psf, mags, sky, ngroup, adu, ronoise, DIR+'psf.fits', magerr, iter, chisq, peak
;stop, mags
substar, image, x_psf, y_psf, mags, ['1','2'],  DIR+'psf.fits'
writefits, DIR+'sub1.fit', image, img_hdr
end