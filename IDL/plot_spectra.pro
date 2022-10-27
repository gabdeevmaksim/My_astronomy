pro plot_spectra, WDIR=wdir, OBJ=obj

files=file_search(wdir+obj+'*.txt', count=count)
phase=read_table(wdir+'phase_all.dat')
if phase[0] eq 0 then phase=fltarr(count)
set_plot,'PS'
device,file=wdir+'spectra.ps',xsize=18,ysize=24,xoffset=1,yoffset=2.5,/portrait
!P.multi=[0,1,4]
spectra=double(read_table(files[0]))
a=size(spectra) & sumspec=dblarr(a[2]) & step=a[2]/100
for q=0,count-1,1 do begin
  spectra=double(read_table(files[q]))
  RR=where(spectra[1,*] lt 0, ind)
  if ind gt 0 then spectra[1,RR]=0
  ;for j=2,a[2]-3 do if spectra[1,j] gt (spectra[1,j-2]+spectra[1,j+2]) then spectra[1,j]=(spectra[1,j-2]+spectra[1,j+2])/2
  ;RR=where(spectra[1,*] gt 6e-15, ind)
  ;if ind gt 0 then spectra[1,RR]=spectra[1,RR+5]
  spectra[1,*]=smooth(spectra[1,*],3)
    plot,spectra[0,*],spectra[1,*],xst=1,title='Spectra from image '+strmid(files[q],19,15,/reverse_offset)+'    Phase: '+string(phase[q]), $
    xtitle='Wavelength, A',ytitle='Flux, erg/sec', yrange=[0,2.5e-15];,xrange=[4000,7200];
    sumspec=sumspec+spectra[1,*]
endfor
openw, lun, wdir+'sum.dat', /get_lun
for i=0,1949 do printf, lun, spectra[0,i], sumspec[i]
close, /all
plot,spectra[0,*],sumspec,xst=1,title='SumSpectra', $
    xtitle='Wavelength, A',ytitle='Flux, erg/sec';,xrange=[4000,7300];, yrange=[0,2.5e-16];, xrange=[4050,5800];
device,/close
set_plot, 'WIN'
  !P.multi=0
end
plot_spectra, WDIR='e:\Observations\BTA\s060322\MTDra\', obj = 'RX 1847+5538'
end