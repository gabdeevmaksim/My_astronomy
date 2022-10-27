pro srec_compar

flux=read_table('d:\AstroPrograms\SPECTRUM\CORES\flux_3_10.dat', /double)
s015=read_table('d:\Observations\Processed\s110920\OT J071126+440405\s9120703.txt', /double)
s052=read_table('d:\Observations\Processed\s110920\OT J071126+440405\s9120710.txt', /double)
;resid=dblarr()
wl1=flux[0,*]
resid=flux[37,*]-flux[11,*]
save, resid, wl1, filename='d:\AstroPrograms\SPECTRUM\CORES\resid.sav'
restore, 'd:\AstroPrograms\SPECTRUM\CORES\resid.sav'
resid=resid*0.5d-20
window, 1
 
plot, s052[0,*], s052[1,*], xst=1, xrange=[4000,7300], yrange=[0,6d-15]
oplot, s015[0,*],s015[1,*], color=20000
window, 2
plot, wl1, resid, color=2000
;oplot, s015[0,*],s052[1,*]-s015[1,*],color=10000
 
res=spline(s015[0,*],s015[1,*],wl1,/double)
new=res+resid & Nx=N_elements(new)
openw, lun, 'd:\AstroPrograms\SPECTRUM\CORES\new.dat', /get_lun
for i=long(0),long(21997) do printf, lun, wl1[i*3], new[i*3], format='(F8.3,2X,E11.4)'
close, /all

;  result=lowess(wl1,new,Nx/16,3,3)
;  for j=0,3 do begin
;    print, 'ok'
;    robomean, new-result, 3, 0.5,avg,rms
;    RR=where((new-result) gt rms, ind)
;    if ind gt 1 then new(R)=result(R) 
;    result=lowess(wl1, new,Nx/8,3,3)
;  endfor
;  new1=new/result
;   
;  Nx=N_elements(s052[0,*])
;  result=lowess(s052[0,*], s052[1,*],Nx/8,3,3)
;  for j=0,3 do begin
;    robomean, s052[1,*]-result, 3, 0.5,avg,rms
;    RR=where((s052[1,*]-result) gt rms, ind)
;    if ind gt 1 then s052(1,R)=result(R) 
;    result=lowess(s052[0,*], s052[1,*],Nx/8,3,3)
;  endfor
;  s052n=s052[1,*]/result
;  window, 2
;  plot, wl1, new1, xst=1
;  oplot, s052[0,1], s052n, color=2000 
end