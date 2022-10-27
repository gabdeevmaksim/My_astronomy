pro plot_SDSS

DIR='e:\Observations\MMPP\specSDSS\CSS110920\'
files=file_search(DIR+'*.txt',count=N)
f_filt=file_search('c:\Users\gamak\Documents\Conferences\2019, Shamahy\*.txt',count=Nfilt)
set_plot, 'ps'
device, file='e:\Observations\MMPP\specSDSS\CSS110920\SDSS_spec.eps', /landscape, xsize=24, ysize=16;, yoff=0, xoff=0
mag=fltarr(3)
openw, 1, 'e:\Observations\MMPP\specSDSS\CSS110920\colors_SDSS.dat'
for i=0,N-1,2 do begin
  spec_b=read_table(files[i])
  spec_r=read_table(files[i+1])
  Nb=N_elements(spec_b[0,*]) & Nr=N_elements(spec_r[0,*]) 
  r=where(spec_r[0,*]-spec_b[0,Nb-1] gt 0, ind)
  spec=fltarr(2,Nb+ind)
  spec[*,0:Nb-1]=spec_b & spec[*,Nb:*]=spec_r[*,r]
  for j=0,Nfilt-1 do begin
    filter=read_table(f_filt[j])
    par=spl_init(filter[0,*]*10,filter[1,*],/double)
    Y=spl_interp(filter[0,*]*10,filter[1,*],par,spec[0,*],/double)/100
    mag[j]=-2.5*alog10(int_tabulated(spec[0,*],spec[1,*]*Y))
  endfor

  printf, 1, mag[0]-mag[1], mag[1]-mag[2], format='(2(F6.3,2X))'
  cgplot, spec[0,*], spec[1,*], ys=1, xs=1, color='blue';, xr=[4600,4900]
;  cgplot, spec_r[0,*], spec_r[1,*], color='red', /overplot
  openw, 2, 'e:\Observations\MMPP\specSDSS\CSS110920\0'+strcompress(string(i/2),/remove_all)+'.dat'
  for j=0,N_elements(spec[0,*])-1 do printf, 2, spec[0,j], spec[1,j], format='(F9.3,2X,F9.3)'
  close, 2 
endfor
close, 1
device, /close
set_plot, 'win'

end