pro equiv_width

path='d:\Observations\Processed\s100803\Equivalent Width\'
data=read_table(path+'result.dat')
phase=read_table(path+'phase.dat')


lines=[4686.24,4861.36]; wavelength of elements

;determine number of line in array
R=intarr(2)
for i=0,1 do begin
RR=where((data[0,*] eq lines[i]), ind)
R[i]=RR
endfor

d=25
;window, 1, xsize=600, ysize=400
!P.multi=[0,3,1]
!P.multi=0
;for i=0,2 do plot, data[0,R[i]-d:R[i]+d], data[2,R[i]-d:R[i]+d]

eq_w=fltarr(2,26)
for k=2,27 do begin
  for i=0,1 do begin
    peak=max(data[k,R[i]-d:R[i]+d])
    RR=where(data[k,*] eq peak)
    ;print, RR, data[0,RR], data[10,RR]
    ;plot, data[0,RR-d:RR+d], data[k,RR-d:RR+d]
    print, total(data[k,R[i]-d:R[i]+d])-d*2
    eq_w[i,k-2]=total(data[k,R[i]-d:R[i]+d])-d*2
  endfor
  print, '-'
endfor

;evaluate Gauss profile
;psf = psf_gaussian([peak-1,25,7],npixel=50)
;window, 2, xsize=300, ysize=300
;!P.multi=0
;plot, psf+1
;oplot, data[10,RR-d:RR+d], linestyle=2

set_plot,'PS'
device,file=path+'Eq_width.ps', /portrait, xsize=10, ysize=15
!P.multi=[0,1,2]
plot, phase, eq_w[0,*], psym=5, yrange=[0,60], xtitle='Phase', ytitle='Equivalent width', $
	  charthick=1.3
      ;title='From spectra obtained 100803',
oplot, phase, eq_w[1,*], psym=6;, color=25000; linestyle=2
;oplot, phase, eq_w[2,*], psym=4;, color=50000; linestyle=3
;xyouts, [0.1,0.1],[67.5,60],$
;        ['Triangles - HeII 4686','Squares - H'+greek('beta')], $
;        charthick=1.2
plot, phase, eq_w[0,*]/eq_w[1,*], psym=6, xtitle='Phase', ytitle='HeII 4686/H'+greek('beta'), $
	  charthick=1.3
oplot, [-.2,10], [1,1]
device,/close
set_plot, 'WIN'
end