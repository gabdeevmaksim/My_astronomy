pro sum_spectra, dir

files=file_search(dir+'*.dat',count=Nf)
for i=0,Nf-1 do begin
  temp=read_table(files[i],/double)
  if i eq 0 then begin
    a=size(temp) & N=a[2] & table=dblarr(Nf,N)
  endif
  table[i,*]=temp[1,*]
endfor
spec=dblarr(N)
spec=total(table, 1)
;window
;plot, temp[0,*], spec
;spec=smooth(table[0,1,*],5)+smooth(table[1,1,*],5)
;window, 2
;plot, table[0,0,*], spec
;low=lowess(table[0,0,*], spec, N/4,3,1)
;oplot, table[0,0,*], low, color=100
;window, 3
;plot, table[0,0,*], spec/low+0.015
;oplot, [table[0,0,0],table[0,0,N-1]],[1,1], color=200
openw, lun, dir+'sum'+strmid(DIR,38,9)+'.txt', /get_lun
for i=0,N-1 do printf,lun, temp[0,i], spec[i];, format='(F7.2,2X,F6.3)'
free_lun, lun
set_plot, 'ps'
device, file=dir+'sum.eps', /landscape, xsize=30, yoff=30;,$
        ;xsize=8, ysize=30, yoff=0, xoff=0
        
        plot, temp[0,*], spec[*], xs=1, ys=1, xtitle='Wavelength, '+cgsymbol('angstrom'), ytitle='Flux, erg!U-1 !Ncm!U-1 !Ns!U-1!N'+cgSymbol('Angstrom')+'!U-1 !N10!U-15', $
              xrange=[3350,7750], CHARSIZE=.7, yrange=[0,350]
;xyouts, 4300, 1.22, 'H'+cgsymbol('gamma'),CHARSIZE=.5
;xyouts, 4820, 1.85, 'H'+cgsymbol('beta'),CHARSIZE=.5
;xyouts, 4720, 1.69, 'HeII 4686',CHARSIZE=.5, ori=90
;xyouts, 5925, 0.55, 'HeI 5876',CHARSIZE=.5, ori=90
;xyouts, 6500, 0.42, 'H'+cgsymbol('alpha'),CHARSIZE=.5
;xyouts, 4521, 1.15, 'HeI 4471',CHARSIZE=.5, ori=90
;xyouts, 4972, 1.28, 'HeI 4922',CHARSIZE=.5, ori=90
;xyouts, 5065, 1.18, 'HeI 5015',CHARSIZE=.5, ori=90
;xyouts, 5430, 0.8, 'HeI 5411',CHARSIZE=.5, ori=90
device, /close
set_plot, 'win'
end  
sum_spectra, 'd:\Observations\RAW\UAGS\Gabdeev\3BS050549.99+461746.7\'
end   
  