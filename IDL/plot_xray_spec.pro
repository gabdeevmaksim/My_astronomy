pro plot_xray_spec

files=file_search('e:\AstroPrograms\SpecX\SpecX\bin\Debug\','model_m44*.spe',count=Nf)

xspec=dblarr(Nf,2,100) 
for i=0,Nf-1 do begin 
  tab=read_table(files[i],/double)
  xspec[i,1,*]=tab[1,*]/4.13e-18*tab[0,*]
  xspec[i,0,*]=tab[0,*]
endfor

set_plot,'ps'
device, file='e:\AstroPrograms\SpecX\SpecX\bin\Debug\Results\UZ_For.eps',xs=16,ys=16, /portrait
cgplot, xspec[0,0,*], xspec[0,1,*], /xlog, /ylog, xs=1, ys=1, yra=[1e13,2e16], $
        xtitle='E, keV', ytitle='E*Fe',color='red', title='B=50 MG, M=0.44' + cgsymbol('sun')
;xyouts, .2, 1e14, 'dotted - acc rate 0.5, +/-10% R';0.94 M'+cgSymbol('sun')

cgplot, xspec[1,0,*], xspec[1,1,*], /overplot, thick=3
cgplot, xspec[2,0,*], xspec[2,1,*], color='blue', /overplot
xyouts, xspec[1,0,55], xspec[1,1,50], 'AR = 0.1'

cgplot, xspec[3,0,*], xspec[3,1,*],color='red', /overplot
cgplot, xspec[4,0,*], xspec[4,1,*], /overplot, thick=3
cgplot, xspec[5,0,*], xspec[5,1,*],color='blue', /overplot
xyouts, xspec[4,0,55], xspec[4,1,50], 'AR = 0.5'

cgplot, xspec[6,0,*], xspec[6,1,*],color='red', /overplot
cgplot, xspec[7,0,*], xspec[7,1,*], /overplot, thick=3
cgplot, xspec[8,0,*], xspec[8,1,*],color='blue', /overplot
xyouts, xspec[7,0,55], xspec[7,1,50], 'AR = 1'

xyouts, xspec[7,0,20], 6e13, 'red - Rwd-10%'
xyouts, xspec[7,0,20], 5e13, 'blue -  Rwd+10%'


;files1=file_search('e:\AstroPrograms\SpecX\SpecX\bin\Debug\','*38*.spe',count=Nf1)
;xspec1=dblarr(Nf1,2,100)
;
;print, Nf1
;
;for i=0,Nf1-1 do begin 
;  tab=read_table(files1[i],/double)
;  xspec1[i,1,*]=tab[1,*]/4.13e-18*tab[0,*]
;  xspec1[i,0,*]=tab[0,*]
;endfor
;
;cgplot, xspec1[0,0,*], xspec1[0,1,*],color='green', /overplot, thick=2, linest=2
;cgplot, xspec1[1,0,*], xspec1[1,1,*],color='green', /overplot, thick=2, linest=3
;cgplot, xspec1[2,0,*], xspec1[2,1,*],color='green', /overplot, thick=2, linest=4
;
;
;cgplot, xspec1[12,0,*], xspec1[12,1,*],color='yellow', /overplot, thick=2, linest=2
;cgplot, xspec1[13,0,*], xspec1[13,1,*],color='yellow', /overplot, thick=2, linest=3
;cgplot, xspec1[14,0,*], xspec1[14,1,*],color='yellow', /overplot, thick=2, linest=4
;
;xyouts, xspec1[7,0,20], 4e13, 'green - Mwd-10%'
;xyouts, xspec1[7,0,20], 3e13, 'yellow - Mwd+10%'


device, /close
set_plot, 'win'

end