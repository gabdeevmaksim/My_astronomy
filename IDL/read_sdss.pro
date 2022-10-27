pro read_sdss

file='e:\Observations\MMPP\spec-3949-55650-0814_CSS110920.fits'

for ext=4,13 do begin
  fxbopen, unit, file, ext, h
  fxbread, unit, wl, 'loglam'
  fxbread, unit, flux, 'flux'
  dat0=sxpar(h,'DATE-OBS')
  dat=strmid(dat0,0,4)+strmid(dat0,5,2)+strmid(dat0,8,5)+strmid(dat0,14,2)+strmid(dat0,17,4)
  openw, 2, 'e:\Observations\MMPP\specSDSS\'+'CSS110920\'+dat+'_'+sxpar(h,'CAMERAS')+'.txt'
  for i=0,sxpar(h,'NAXIS2')-1 do printf, 2, 10^wl[i], flux[i], format='(F9.3,2X,F7.3)'
  close, 2
  fxbclose, unit
endfor
end