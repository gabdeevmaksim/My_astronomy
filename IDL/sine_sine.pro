pro sine_sine

A=360.51 & A1=180 & y1=0 & y2=268.71 & xc1=0 & xc2=0.0632 & w=0.5
vel=read_table('k:\BS Tri\velos.txt')
x=findgen(100)/100 & y=fltarr(100) & y0=fltarr(100)
y=y1+A*sin(!Pi*(x-xc1)/w)
window, 0
plot, x, y, yrange=[-400,1000]
y0=y2+A1*sin(!Pi*(x-xc2)/w)
oplot, x, y0, linestyle=1
;y[24]=y[24]+y0[24]
y[25:87]=y[25:87]+0.1*y0[25:87]
window,1
plot, x, y
oplot, vel[0,*], vel[1,*], psym=4
end