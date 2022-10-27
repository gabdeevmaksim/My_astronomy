pro mass_deter

K2=[203.,229.,255.] & m2=[0.05d,0.07d,0.1d] & P=0.0893869d & ie=findgen(60)+0.d
f2=dblarr(3) & m1=dblarr(3,n_elements(m2),n_elements(ie)) & q=dblarr(3,n_elements(m2),n_elements(ie)) & q1=findgen(10000)/10000+0.0001d

for i=0,2 do begin
  f2[i]=(1.038e-7)*P*K2[i]^3
  print, f2[i]
  for j=0,n_elements(m2)-1 do begin
    for l=0,n_elements(ie)-1 do begin
      for k=0,9999 do begin
        f=m2[j]*(sin(2*!Pi*(ie[l]/360.)))^3/(q1[k]*(1+q1[k])^2)
        if abs(f2[i]-f) lt 0.00138 then begin
          q[i,j,l]=q1[k] 
          print,q1[k]
        endif
      endfor
    endfor
    m1[i,j,*]=m2[j]/q[i,j,*]
  endfor
endfor
openw, 1, 'C:\Users\gamak\Documents\Papers\MT_Dra\i_q_m1.txt'
for i=0,n_elements(ie)-1 do printf, 1, ie[i], q[1,1,i], m1[1,1,i]
close, 1
set_plot, 'win'
window, 1
!P.multi=[0,3,1]
plot,  ie[*], m1[0,0,*], linestyle=0, xst=1, yrange=[0.0,1], xrange=[70,95]
for i=1,2 do oplot, ie[*], m1[0,i,*], linestyle=0
oplot,  ie[*], m1[1,0,*], linestyle=1;, xst=1, yrange=[0.6,0.9];, xrange=[70,95]
for i=1,2 do oplot, ie[*], m1[1,i,*], linestyle=1
oplot,  ie[*], m1[2,0,*], linestyle=2;, xst=1, yrange=[0.6,0.9];, xrange=[70,95]
for i=1,2 do oplot, ie[*], m1[2,i,*], linestyle=2

plot,  ie[*], q[0,0,*], linestyle=0, xst=1, yrange=[0.2,0.3], xrange=[70,95]
for i=1,2 do oplot, ie[*], q[0,i,*], linestyle=0
oplot,  ie[*], q[1,0,*], linestyle=1;, xst=1, yrange=[0.6,0.9];, xrange=[70,95]
for i=1,2 do oplot, ie[*], q[1,i,*], linestyle=1
oplot,  ie[*], q[2,0,*], linestyle=2;, xst=1, yrange=[0.6,0.9];, xrange=[70,95]
for i=1,2 do oplot, ie[*], q[2,i,*], linestyle=2

plot,  ie[*], m1[0,0,*], linestyle=0, xst=1, yrange=[0.0,1], xrange=[70,95]
for i=1,2 do oplot, ie[*], m1[i,0,*], linestyle=0
oplot,  ie[*], m1[0,1,*], linestyle=1;, xst=1, yrange=[0.6,0.9];, xrange=[70,95]
for i=1,2 do oplot, ie[*], m1[i,1,*], linestyle=1
oplot,  ie[*], m1[0,2,*], linestyle=2;, xst=1, yrange=[0.6,0.9];, xrange=[70,95]
for i=1,2 do oplot, ie[*], m1[i,2,*], linestyle=2
!p.MULTI=[0,1,2]
set_plot, 'PS'
device, file='C:\Users\gamak\Documents\Papers\MT_Dra\masses.ps', /portrait, ys=16;, xs=16
plot,  ie[*], m1[1,0,*], linestyle=0, xst=1, ys=1, xtit='Inclination, deg', ytitle='M1, solar masses', $
       xchar=1.3, ychar=1.3, thick=2, xthick=2, ythick=2, yrange=[0.,1.4], xrange=[0,90]
xyouts, 45, 1, 'K2 = 250 km/sec', chars=1.3, charthick=2
xyouts, 76.5, m1[1,0,n_elements(ie)-1]-.06, '0.05Mo', chars=1.3
xyouts, 76.5, m1[1,1,n_elements(ie)-1], '0.1Mo', chars=1.3
;xyouts, 76.5, m1[1,2,n_elements(ie)-10], '0.11Mo', chars=1.3
for i=1,2 do oplot, ie[*], m1[1,i,*], linestyle=0, thick=2
plot,  ie[*], q[1,0,*], linestyle=0, xst=1, ys=1, xtit='Inclination, deg', ytitle='q', $
       xchar=1.3, ychar=1.3, thick=2, xthick=2, ythick=2, yrange=[0.,.6], xrange=[0,90]
for i=1,2 do oplot, ie[*], q[1,i,*], linestyle=0, thick=2
xyouts, 76.5, q[1,0,n_elements(ie)-1], '0.05Mo', chars=1.3
xyouts, 76.5, q[1,1,n_elements(ie)-5], '0.07Mo', chars=1.3
xyouts, 76.5, q[1,2,n_elements(ie)-1], '0.1Mo', chars=1.3
device, /close
set_plot, 'win'


end