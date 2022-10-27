pro plot_spec_lamost

;file=dialog_pickfile(PATH='e:\Observations\MMPP\',filter=['*.txt'])
;  spec=fltarr(2,3909)
;  if file_test('e:\Observations\MMPP\lamost_templ.sav') eq 0 then begin 
;    te=ascii_template(file)
;    save, te, filename='e:\Observations\MMPP\lamost_templ.sav'
;  endif else restore, filename='e:\Observations\MMPP\lamost_templ.sav'
;  t=read_ascii(file,template=te)
;  openw, 1, 'e:\Observations\MMPP\lamost_spec.txt'
;  for i=0,3908 do begin 
;    spec[0,i]=t.field0001[i,0]
;    spec[1,i]=t.field0001[i,1]
;    printf, 1, spec[0,i], spec[1,i], format='(F8.2,2X,F7.3)'
;  endfor
;  close, 1

spec=read_table('e:\Observations\RTT150\T20201124\spec_obj.dat')
  set_plot, 'ps'
  device,  file='C:\Users\gamak\Documents\Conferences\2021, Conf KFU\fig01.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0  
  cgplot, spec[0,*], smooth(spec[1,*],5), xs=1, ys=1, yrange=[60,195], xr=[3800,5500], ytitle='Relative flux', xtitle='Wavelength, '+cgsymbol('angstrom')

xyouts, 3865, 100, 'Na dublet', ori=-90
xyouts, 4100, 160, 'H'+cgsymbol('delta')
xyouts, 4330, 147, 'H'+cgsymbol('gamma')
xyouts, 4300, 90, 'G-band', ori=-90
xyouts, 4650, 108, 'CIII-NIII', ori=90
xyouts, 4700, 188, 'HeII 4686'
xyouts, 4850, 137, 'H'+cgsymbol('beta')
;xyouts, 5925, 0.55, 'HeI 5876',CHARSIZE=.5, ori=90
;xyouts, 6500, 0.42, 'H'+cgsymbol('alpha'),CHARSIZE=.5
;xyouts, 4521, 1.15, 'HeI 4471',CHARSIZE=.5, ori=90
xyouts, 4942, 91, 'HeI 4922', ori=90
;xyouts, 5065, 1.18, 'HeI 5015',CHARSIZE=.5, ori=90
xyouts, 5170, 68, 'Mg triplet'
xyouts, 5431, 86, 'HeII 5411', ori=90
  
  device, /close
  set_plot, 'win'
end 