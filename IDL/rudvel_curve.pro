pro rudvel_curve, WDIR=wdir, EFEM=efem

vel=read_table(wdir+'velos.dat')

restore, wdir+'phase.sav'
;if keyword_set(EFEM) then begin
set_plot, 'WIN'  

R=where(vel[0,*] ne 0, ind)
if ind gt 0 then begin
  Ph1=Ph[R] & vel1=vel[1,R]
window, 20, title='Rudial Velocities'
help, Ph1, vel1
plot, Ph1, vel1, xst=1, xtitle='Phase', ytitle='V, km/sec', psym=6, xrange=[-0.1,1.1]
endif

set_plot, 'PS'
device, file=wdir+'rud_velos.ps',xsize=28,ysize=16, /landscape,xoffset=1,yoffset=29
;plot, UT-UT[0], vel[1,*], xst=1, xtitle='UT, hour', ytitle='V, km/sec', psym=6
plot, Ph1, vel1, xst=1, xtitle='Phase', ytitle='V, km/sec', psym=6, xrange=[-0.1,1.1]
;oplot, x, y
device, /close
set_plot, 'WIN'

end
rudvel_curve, WDIR='f:\!!!Pract\OBSst\Processed\s110921\OT J071126+440405\'
end
