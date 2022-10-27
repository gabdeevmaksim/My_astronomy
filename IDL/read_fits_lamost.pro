pro read_fits_lamost

file = 'E:\Observations\spec.fits\spec-56207-M31011N44B1_sp14-144.fits'

fits = readfits(file, h)

plot, fits[*,2], fits[*,0]

N = N_elements(fits[*,2])
openw, lun, 'E:\Observations\spec.fits\spec.dat', /get_lun
for i = 0,N-1 do printf, lun, fits[i,2], fits[i,0], format = '(F10.4,2X,F10.4)'
close, lun
end 