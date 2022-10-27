pro read_fluxall, file

file='c:\Users\gamak\Documents\Conferences\2019, Shamahy\fluxall.dat'

;te=ascii_template(file)
;save, te, filename='c:\Users\gamak\Documents\Conferences\2019, Shamahy\flux_te.sav'
;restore, filename='c:\Users\gamak\Documents\Conferences\2019, Shamahy\flux_te.sav'
;spectra=read_ascii(file,template=te)

;spec=read_table(file)
;help, spectra, /structures
openr, 1, file
read, 1, specs 
close, 1
help, specs
end