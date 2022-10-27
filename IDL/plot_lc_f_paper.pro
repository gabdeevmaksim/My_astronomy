pro plot_lc_f_paper

lc=read_table('e:\Observations\MMPP\result_web_CSS110920.csv',/double, head=1)
l_c=read_table('e:\Observations\MMPP\CSS110920_period.dat', /double)
phase=(54466.5232d - l_c[0,*])/0.054437d
;phase=(54466.5232d - lc[5,*])/0.054437d
;ind=1
;while ind gt 0 do begin
;  rr=where(phase lt 0, ind)
;  if ind gt 0 then phase[rr]=phase[rr]+32000
;endwhile
phase=phase-fix(phase)+0.7
;rr=where(lc[1,*] lt 18.7 and lc[1,*] gt 18.1, ind)
set_plot,'ps'
device, file='C:\Users\gamak\Documents\Papers\3BS Results\fig02a.eps', xsi=16, ysi=16, /portrait, xoff=0, yoff=0
cgplot, phase, l_c[1,*], xs=1, ys=1, PSYM=4, xr=[-.3,1.3], xtit='Phase', ytit='V, magnitude', yr=[19.2,17.]
cgplot, phase+1, l_c[1,*], PSYM=4, /overplot

;cgplot, l_c[0,*], l_c[1,*], xs=1, ys=1, PSYM=4
rr=where(lc[1,*] gt 18.7, ind)
rr1=where(lc[1,*] lt 18.7, ind)
;print, mean(lc[2,rr]), mean(lc[2,rr1])
for i=0,N_elements(phase)-1 do begin
 rr2=where(l_c[0,i] eq lc[5,*], ind2)
if ind2 gt 0 then begin  
  errplot, phase[i], l_c[1,i]-lc[2,rr2], l_c[1,i]+lc[2,rr2], color=cgcolor('grey')
  errplot, phase[i]+1, l_c[1,i]-lc[2,rr2], l_c[1,i]+lc[2,rr2], color=cgcolor('grey')
endif
endfor
device, /close
set_plot, 'win'
end