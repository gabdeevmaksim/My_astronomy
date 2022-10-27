pro plot_spectrum_eps

spec=read_table('e:\Observations\RTT150\T20201125\MLSNov25G8norm.DAT')

set_plot, 'ps'
device, file='C:\Users\gamak\Documents\Papers\RTT_Varibles\fig03.eps', /portrait,$
        xsize=16, ysize=16, yoff=0, xoff=0
        
        cgplot, spec[0,*], spec[1,*], xs=1, ys=1, xtitle='Wavelength, '+cgsymbol('angstrom') , ytitle='Intensity'$
              ,yrange=[0.9,2.5],xrange=[6525,6595], thick =2 ;, CHARSIZE=.7, ytitle='Flux, erg!U-1 !Ncm!U-1 !Ns!U-1!N'+cgSymbol('Angstrom')+'!U-1 !N10!U-16'
             
;xyouts, 4080, 9, 'H'+cgsymbol('delta'),CHARSIZE=1.3;.5
;xyouts, 4340, 9.3, 'H'+cgsymbol('gamma'),CHARSIZE=1.3;.5
;;xyouts, 4387, 5.2, 'HeI 4387',CHARSIZE=1.5, ori=90
;xyouts, 4511, 5.2, 'HeI 4471',CHARSIZE=1., ori=90
;xyouts, 4860, 8.2, 'H'+cgsymbol('beta'),CHARSIZE=1.3;.5
;xyouts, 5055, 4.3, 'HeI 5015',CHARSIZE=1., ori=90
;xyouts, 5209, 4.2, 'FeII 4169',CHARSIZE=1., ori=90
;xyouts, 5926, 3.6, 'HeI 5876',CHARSIZE=1., ori=90
;xyouts, 6560, 6, 'H'+cgsymbol('alpha'),CHARSIZE=1.3;.5
;xyouts, 6728, 2.9, 'HeI 6678',CHARSIZE=1., ori=90
;;xyouts, 4720, 1.69, 'HeII 4686',CHARSIZE=.5, ori=90


;
;xyouts, 4972, 1.28, 'HeI 4922',CHARSIZE=.5, ori=90

;xyouts, 5430, 0.8, 'HeI 5411',CHARSIZE=.5, ori=90

device, /close
set_plot, 'win'

end
        