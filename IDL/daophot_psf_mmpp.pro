pro daophot_psf_MMPP

DIR = 'e:\Observations\MMPP\20201016\J2218\'
files = file_search(DIR, '*.fits', count=N_files)
  adu = 1.1
  ronoise = 2.4
  

for i = 0,N_files-1 do begin
  if i eq 0 and file_test(DIR+'xystars.sav') eq 0 then begin
    image = readfits(DIR+'median_image.fit',img_hdr)
    Nx = sxpar(img_hdr, 'NAXIS1') & Ny = sxpar(img_hdr, 'NAXIS2')
    sky, image, skymode, skysig
    set_plot, 'win'
    !P.multi=0
    window, 2, xsize=Nx*2/3, ysize=Ny*2/3
    display_image, image, 2, options={range:[skymode+skysig,skymode+5*skysig],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
    click_on_max, image, x, y, mark=1
    save, x, y, filename = DIR+'xystars.sav'
    openw, 1, DIR+'phot_m-45.dat'
  endif else restore, DIR+'xystars.sav'
  image = readfits(files[i],img_hdr)
  Nx = sxpar(img_hdr, 'NAXIS1') & Ny = sxpar(img_hdr, 'NAXIS2')
  sky, image, skymode, skysig
  hmin = SQRT(adu*SKYMODE + ronoise)  
  cntrd, image, x, y, x_psf, y_psf, 8
  aper, image, x_psf, y_psf, mags, errap, sky, skyerr, adu, 4, [10,15], [0,60000], /silent  
  getpsf, image, x_psf, y_psf, mags, sky, ronoise, adu, gauss, psf, ['0','1'], 8, 6, DIR+'psf.fits'
  GROUP, x_psf, y_psf, 7, ngroup
  NSTAR, image, sindgen(N_elements(x)), x_psf, y_psf, mags, sky, ngroup,  adu, ronoise, DIR+'psf.fits', magerr, iter, chisq, peak, /SILENT, /VARSKY
  ;set_region,file=DIR+'!stars.reg',string(mags,format='(F5.2)'),string(x_psf,format='(D13.7)'),string(y_psf,format='(D13.7)'),color='red',/nofk5   
  printf, 1, mags, magerr
  x = x_psf & y = y_psf
endfor
close, 1
end