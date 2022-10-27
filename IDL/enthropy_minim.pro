pro enthropy_minim

path='d:\Observations\Processed\s100803\Equivalent Width\'
data=read_table(path+'result.dat')
phase=read_table(path+'phase.dat')

nul_ph=where(abs(phase-0) eq min(abs(phase-0)))
wl=4676.56 & d=20 & y=[0.9,3]
R=where((data[0,*] eq wl), ind)

RR=where(data[nul_ph,*] eq max(data[nul_ph,R-d/2:R+d/2]))
nul_wl=data[0,RR]
!P.multi=0
window, 0
plot, data[0,RR-d:RR+d], data[nul_ph,RR-d:RR+d], yrange=[y[0],y[1]], xst=1
;stop
Pi=!Pi
c=2.997924580*10e5 
var=25
line=fltarr(500/20,d*2+1)
dif=fltarr(var*2+1)
step=20

for ampl=20,500,step do begin
  for k=2,26 do begin
    v=ampl*sin(phase[k-2]*2*Pi+Pi)
    ;plot, phase, ampl*sin(phase[*]*2*Pi+Pi)
    dwl=v*nul_wl/c
    new_wl=nul_wl+dwl
    ;R=where(abs(data[0,RR-15:RR+15]-new_wl) eq min(abs(data[0,RR-15:RR+15]-new_wl)))
    for i=-var,var do dif[i+var]=abs(data[0,RR+i]-new_wl)
    R=where(dif eq min(dif))
    line[ampl/step-1,*]=line[ampl/step-1,*]+data[k,RR-var+R-d:RR-var+R+d]
    ;stop, v, dwl
  endfor
  print, wl, new_wl
  line[ampl/step-1,*]=line[ampl/step-1,*]/25
endfor

window,2
!P.multi=0
plot, line[0,*], yrange=[y[0],y[1]]
for i=1,24 do oplot, line[i,*], color=i*5000    
x=findgen(2*d+1) & hw=fltarr(500/20) 
window,1,xsize=700,ysize=700
!P.multi=[0,5,5]
openw, lun, path+'profiles.txt', /get_lun
for i=0,24 do begin
  plot, x, smooth(line[i,*],5), yrange=[y[0],y[1]], title='Amplitude='+string((i+1)*step)+'km/sec'
  result=gaussfit(x,smooth(line[i,*],5),A)
  hw[i]= 2*SQRT(2*ALOG(2))*A[2]
  oplot, x, result, color=20000
endfor  
for i=0,24 do print, 'Velocity ='+string((i+1)*step)+'  FWHM ='+string(hw[i])
for j=0,2*d do printf, lun, j+1, line[*,j], format='(I2,25(2X,F5.3))'
free_lun, lun
!P.multi=0
end

