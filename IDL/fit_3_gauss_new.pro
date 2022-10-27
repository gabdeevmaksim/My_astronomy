pro fit_3_gauss_new

DIR='e:\Observations\BTA\s091021\MTDra\'; chose directory
files = file_search(DIR+'M*.txt',count=Nf); search spectra files 
for i=0,Nf-1 do begin; start cycle for each spectra
  spec=read_table(files[0]); read i spectrum
  w0=4685.68; set laboratory wavelength of line: HII=4685.68, Hb=4861.32
  dA=.88; set spectral resolution of spectra. For 1200G=.88, for 550G=2.1
  RR=where(abs(spec[0,*]-w0) lt dA/2, ind); find nearest wl to lab wl in array
  dw=30; set width of spectra for fiting in Angstrem
  dpx=fix(dw/dA); width of spectra for fiting in pixels
  line=fltarr(2,2*dpx+1); array for extracted line
  line[0,*]=spec[0,RR[0]-dpx:RR[0]+dpx] & line[1,*]=spec[1,RR[0]-dpx:RR[0]+dpx]; extracted line
  set_plot, 'win'
  window, 1
  cgplot,  spec[0,RR[0]-dpx:RR[0]+dpx],spec[1,RR[0]-dpx:RR[0]+dpx]; plot extracted line
  cont=fltarr(2,10); array to calculate continuum
  cont[0,0:4]=line[0,0:4] & cont[0,5:9]=line[0,2*dpx+1-5:*] & cont[1,0:4]=line[1,0:4] & cont[1,5:9]=line[1,2*dpx+1-5:*]; set 5 dots from boarders for continuum
  p1=goodpoly(cont[0,*],cont[1,*],1,3,yfit)
  continuum=poly(line[0,*],p1)
  cgplot, line[0,*], continuum, /overplot 
  window, 2
  cgplot, line[0,*], line[1,*]/continuum
  stop
endfor
end