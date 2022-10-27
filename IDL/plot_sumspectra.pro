pro plot_sumspectra, WDIR=wdir

files=file_search(wdir+'*.txt', count=count)
spectra=double(read_table(files[0]))
spectra1=double(spectra[0,*]) & spectra1=0
set_plot,'PS'
device,file=wdir+'SumSpectra.ps',xsize=28,ysize=36,/landscape, xoffset=2.5,yoffset=29
for q=0,count-1,2 do begin
  spectra=double(read_table(files[q]))
  a=size(spectra)
  RR=where(spectra[1,*] lt 0, ind)
  if ind gt 0 then spectra[1,RR]=0  
  RR=where(spectra[1,*] gt 6e-15, ind)
  if ind gt 0 then spectra[1,RR]=spectra[1,RR+5]
  spectra1=spectra1+smooth(spectra[1,*],3)
endfor  
plot,spectra[0,*],spectra1/(q-1),xst=1,title='Summary spectra of '+strmid(files[0],36,5), $
    xtitle='Wavelength, A',ytitle='Flux, erg/sec', xrange=[4000,7300], yrange=[2e-13,5e-13]
device,/close
set_plot, 'WIN'
end
plot_sumspectra, WDIR='f:\!!!Pract\OBSst\Processed\s110921\V2468 Cyg\'
end