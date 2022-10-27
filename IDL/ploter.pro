pro plotter, DIR=dir

slits=['slit1','slit2','slit3']

Ha=fltarr(3,7,203) & N1=fltarr(3,7,203) & S1=fltarr(3,7,203) & S2=fltarr(3,4,203) & N2=fltarr(3,7,203) 
for i=0,2 do begin
  Ha[i,*,*]=read_table(DIR+slits[i]+'\params_Ha.txt')
  S1[i,*,*]=read_table(DIR+slits[i]+'\params_S6717.txt')
  S2[i,*,*]=read_table(DIR+slits[i]+'\params_S6731.txt')
  N1[i,*,*]=read_table(DIR+slits[i]+'\params_N6548.txt')
  N2[i,*,*]=read_table(DIR+slits[i]+'\params_N6583.txt')
endfor



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOT FIG 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!P.multi=[0,2,3]
;window, 1
set_plot, 'ps'
device, file=DIR+'Fig1.ps', /portrait;,xsize=16,ysize=16
x=findgen(N_elements(Ha[0,0,*]))*5 & errS=fltarr(3,203) & errN=fltarr(3,203)
errS=[sqrt(S1[0,1,*])/S1[0,1,*],sqrt(S1[1,1,*])/S1[1,1,*],sqrt(S1[2,1,*])/S1[2,1,*]]
errN=[sqrt(N2[0,1,*])/N2[0,1,*],sqrt(N2[1,1,*])/N2[1,1,*],sqrt(N2[2,1,*])/N2[2,1,*]]
cgplot, x, S1[0,1,*]/Ha[0,1,*], yrange=[0,1.5], title='(a) slit1 [SII]6717/H'+greek('alpha'), charsize=[1.5], xs=1, ytitle='Ratio'
cgerrplot, x, S1[0,1,*]/Ha[0,1,*]-3*errS[0,0,*]*S1[0,1,*]/Ha[0,1,*],S1[0,1,*]/Ha[0,1,*]+errS[0,0,*]*3*S1[0,1,*]/Ha[0,1,*]
cgplot, x, S1[1,1,*]/Ha[1,1,*], yrange=[0,1.5], title='(c) slit2 [SII]6717/H'+greek('alpha'), charsize=[1.5], xs=1, ytitle='Ratio'
cgerrplot, x, S1[1,1,*]/Ha[1,1,*]-3*errS[1,0,*]*S1[1,1,*]/Ha[0,1,*],S1[1,1,*]/Ha[1,1,*]+errS[1,0,*]*3*S1[1,1,*]/Ha[0,1,*]
cgplot, x, S1[2,1,*]/Ha[2,1,*], yrange=[0,1.5], title='(e) slit3 [SII]6717/H'+greek('alpha'), charsize=[1.5], xs=1, ytitle='Ratio'
cgerrplot, x, S1[2,1,*]/Ha[2,1,*]-3*errS[2,0,*]*S1[2,1,*]/Ha[0,1,*],S1[2,1,*]/Ha[2,1,*]+errS[2,0,*]*3*S1[2,1,*]/Ha[0,1,*]
cgplot, x, N2[0,1,*]/Ha[0,1,*], yrange=[0,1.5], title='(b) slit1 [NII]6583/H'+greek('alpha'), charsize=[1.5], xs=1, ytitle='Ratio'
cgerrplot, x, N2[0,1,*]/Ha[0,1,*]-3*errN[0,0,*]*N2[0,1,*]/Ha[0,1,*],N2[0,1,*]/Ha[0,1,*]+errN[0,0,*]*3*N2[0,1,*]/Ha[0,1,*]
cgplot, x, N2[1,1,*]/Ha[1,1,*], yrange=[0,1.5], title='(d) slit2 [NII]6583/H'+greek('alpha'), charsize=[1.5], xs=1, ytitle='Ratio'
cgerrplot, x, N2[1,1,*]/Ha[1,1,*]-3*errN[1,0,*]*N2[1,1,*]/Ha[0,1,*],N2[1,1,*]/Ha[1,1,*]+errN[1,0,*]*3*N2[1,1,*]/Ha[0,1,*]
cgplot, x, N2[2,1,*]/Ha[2,1,*], yrange=[0,1.5], title='(f) slit3 [NII]6583/H'+greek('alpha'), charsize=[1.5], xs=1, ytitle='Ratio'
cgerrplot, x, N2[2,1,*]/Ha[2,1,*]-3*errN[2,0,*]*N2[2,1,*]/Ha[0,1,*],N2[2,1,*]/Ha[2,1,*]+errN[2,0,*]*3*N2[2,1,*]/Ha[0,1,*]
cgtext, 0.5, .0, 'Position along slit, pixels' , ALIGNMENT=.5, /normal
device, /close
set_plot, 'win'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLOT FIG 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
img=readfits(dir+slits[0]+'/sum_1.fts',h)
disp=readfits(dir+slits[0]+'/disper.fts')
map=readfits(dir+slits[0]+'/img_slit1.fts',h)
L_lab=6562.82 & l_posH=1063 & w1=15 & L_S=6717. & l_posS=1351
velos_Ha=fltarr(203) & y_vel=fltarr(101)
for i=0,202 do begin
  l_Ha=poly(l_posH-w1+Ha[0,3,i],disp[0:3,397])
  velos_Ha[i]=imsl_constant('C')*(l_Ha-L_lab)/l_lab/1000
  ;l_sky=poly(l_posH-w1[0]+Ha[6,i],disp[0:3,500])
  ;velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
endfor  
N_vel=l_posH-50+findgen(101)
y_vel=imsl_constant('C')*(poly(N_vel,disp[0:3,397])-L_lab)/l_lab/1000
N_vel_S=l_posS-50+findgen(101)
y_vel_S=imsl_constant('C')*(poly(N_vel_S,disp[0:3,397])-L_S)/l_S/1000

x1=N_elements(Ha[0,0,*])*5-findgen(N_elements(Ha[0,0,*]))*5
!P.multi=[0,1,5]
set_plot, 'ps'
device, file=DIR+'Fig2.ps', /portrait, xsize=16,ysize=24, Yoff=2
errH=sqrt(Ha[0,1,*])/Ha[0,1,*] 
cgplot, x1, alog(Ha[0,1,*]), xs=1, ys=1, charsize=[1.5], yticks=2, yrange=[5,13], ytitle='Log(Intensity)'
cgerrplot, x1, alog(Ha[0,1,*])-3*errH*alog(Ha[0,1,*]),alog(Ha[0,1,*])+3*errH*alog(Ha[0,1,*])
cgtext, 1.02, .91, '(a)' , ALIGNMENT=1, /normal
cgplot, x1, velos_Ha, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgerrplot, x1, velos_Ha-3*errH*velos_Ha, velos_Ha+3*errH*velos_Ha
cgtext, 1.02, .71, '(b)' , ALIGNMENT=1, /normal
tempo=img[N_vel,*]
tempo2=transpose(tempo) & tempo1=mirror_y(tempo2)
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.63, 10.67, /centimeters, xsize=13.85, ysize=3.2
cgplot, x1, y_vel, /nodata, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgtext, 1.02, .51, '(c)' , ALIGNMENT=1, /normal
tempo=img[N_vel_S,*]
tempo2=transpose(tempo) & tempo1=mirror_y(tempo2)
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.63, 5.85, /centimeters, xsize=13.85, ysize=3.2
cgplot, x1, y_vel_S, /nodata, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgtext, 1.02, .31, '(d)' , ALIGNMENT=1, /normal
map2=transpose(map) 
map1=mirror_y(map2)
robomean, map1, 3, 3, avg, avgdev, stddev
m1=avg-1*stddev
m2=avg+3.5*stddev
tv, 255-bytscl(map1[25:992,327:527], m1, m2), 2.33, 1.05, xsize=13.15, ysize=3.2, /centimeters; was 1.76 
y=-100+findgen(201)
cgplot, x1, y,  /nodata, xs=1, ys=1, charsize=[1.5], xtitle='Y, pixels', yticks=0, ytitle='X, pixels'
cgoplot, [0,1055], [0,0], linestyle=2, thick=2
cgtext, 1.02, .11, '(e)' , ALIGNMENT=1, /normal
device, /close
set_plot, 'win'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOT FIG 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
img=readfits(dir+slits[1]+'/sum_2.fts',h)
disp=readfits(dir+slits[0]+'/disper.fts')
map=readfits(dir+slits[1]+'/img_slit2.fts',h)
L_lab=6562.82 & l_posH=1066 & w1=15 & L_S=6717. & l_posS=1351
velos_Ha=fltarr(203) & y_vel=fltarr(101)
for i=0,202 do begin
  l_Ha=poly(l_posH-w1+Ha[1,3,i],disp[0:3,397])
  velos_Ha[i]=imsl_constant('C')*(l_Ha-L_lab)/l_lab/1000
  ;l_sky=poly(l_posH-w1[0]+Ha[6,i],disp[0:3,500])
  ;velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
endfor  
N_vel=l_posH-50+findgen(101)
y_vel=imsl_constant('C')*(poly(N_vel,disp[0:3,397])-L_lab)/l_lab/1000
N_vel_S=l_posS-50+findgen(101)
y_vel_S=imsl_constant('C')*(poly(N_vel_S,disp[0:3,397])-L_S)/l_S/1000

x1=N_elements(Ha[0,0,*])*5-findgen(N_elements(Ha[0,0,*]))*5
!P.multi=[0,1,5]
set_plot, 'ps'
device, file=DIR+'Fig3.ps', /portrait, xsize=16,ysize=24, Yoff=2
errH=sqrt(Ha[1,1,*])/Ha[1,1,*] 
cgplot, x, alog(Ha[1,1,*]), xs=1, ys=1, charsize=[1.5], yticks=2, yrange=[5,13], ytitle='Log(Intensity)'
cgerrplot, x, alog(Ha[1,1,*])-3*errH*alog(Ha[1,1,*]),alog(Ha[1,1,*])+3*errH*alog(Ha[1,1,*])
cgtext, 1.02, .91, '(a)' , ALIGNMENT=1, /normal
cgplot, x, velos_Ha, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgerrplot, x, velos_Ha-3*errH*velos_Ha, velos_Ha+3*errH*velos_Ha
cgtext, 1.02, .71, '(b)' , ALIGNMENT=1, /normal
tempo=img[N_vel,*]
tempo1=transpose(tempo) 
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.63, 10.67, /centimeters, xsize=13.85, ysize=3.2
cgplot, x, y_vel, /nodata, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgtext, 1.02, .51, '(c)' , ALIGNMENT=1, /normal
tempo=img[N_vel_S,*]
tempo1=transpose(tempo) 
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.63, 5.85, /centimeters, xsize=13.85, ysize=3.2
cgplot, x, y_vel_S, /nodata, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgtext, 1.02, .31, '(d)' , ALIGNMENT=1, /normal
map1=transpose(map) 
;map1=mirror_y(map2)
robomean, map1, 3, 3, avg, avgdev, stddev
m1=avg-1.5*stddev
m2=avg+.5*stddev
tv, 255-bytscl(map1[25:1045,379:579], m1, m2), 1.83, 1.05, xsize=13.15, ysize=3.2, /centimeters; was 1.76 
y=-100+findgen(201)
cgplot, x, y,  /nodata, xs=1, ys=1, charsize=[1.5], xtitle='Y, pixels', yticks=0, ytitle='X, pixels'
cgoplot, [0,1055], [0,0], linestyle=2, thick=2
cgtext, 1.02, .11, '(e)' , ALIGNMENT=1, /normal
device, /close
set_plot, 'win'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  PLOT FIG 4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
img=readfits(dir+slits[2]+'/sum_3.fts',h)
disp=readfits(dir+slits[0]+'/disper.fts')
map=readfits(dir+slits[2]+'/img_slit3.fts',h)
L_lab=6562.82 & l_posH=1067 & w1=15 & L_S=6717. & l_posS=1349
velos_Ha=fltarr(203) & y_vel=fltarr(101)
for i=0,202 do begin
  l_Ha=poly(l_posH-w1+Ha[2,3,i],disp[0:3,397])
  velos_Ha[i]=imsl_constant('C')*(l_Ha-L_lab)/l_lab/1000
  ;l_sky=poly(l_posH-w1[0]+Ha[6,i],disp[0:3,500])
  ;velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
endfor  
N_vel=l_posH-50+findgen(101)
y_vel=imsl_constant('C')*(poly(N_vel,disp[0:3,397])-L_lab)/l_lab/1000
N_vel_S=l_posS-50+findgen(101)
y_vel_S=imsl_constant('C')*(poly(N_vel_S,disp[0:3,397])-L_S)/l_S/1000

x1=N_elements(Ha[0,0,*])*5-findgen(N_elements(Ha[0,0,*]))*5
!P.multi=[0,1,5]
set_plot, 'ps'
device, file=DIR+'Fig4.ps', /portrait, xsize=16,ysize=24, Yoff=2
errH=sqrt(Ha[2,1,*])/Ha[2,1,*] 
cgplot, x, alog(Ha[2,1,*]), xs=1, ys=1, charsize=[1.5], yticks=2, yrange=[5,13], ytitle='Log(Intensity)'
cgerrplot, x, alog(Ha[2,1,*])-3*errH*alog(Ha[2,1,*]),alog(Ha[2,1,*])+3*errH*alog(Ha[2,1,*])
cgtext, 1.02, .91, '(a)' , ALIGNMENT=1, /normal
cgplot, x, velos_Ha, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgerrplot, x, velos_Ha-3*errH*velos_Ha, velos_Ha+3*errH*velos_Ha
cgtext, 1.02, .71, '(b)' , ALIGNMENT=1, /normal
tempo=img[N_vel,*]
tempo1=transpose(tempo) 
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.63, 10.67, /centimeters, xsize=13.85, ysize=3.2
cgplot, x, y_vel, /nodata, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgtext, 1.02, .51, '(c)' , ALIGNMENT=1, /normal
tempo=img[N_vel_S,*]
tempo1=transpose(tempo) 
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.63, 5.85, /centimeters, xsize=13.85, ysize=3.2
cgplot, x, y_vel_S, /nodata, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$'
cgtext, 1.02, .31, '(d)' , ALIGNMENT=1, /normal
map1=transpose(map) 
;map1=mirror_y(map2)
robomean, map1, 3, 3, avg, avgdev, stddev
m1=avg-1.5*stddev
m2=avg+.5*stddev
tv, 255-bytscl(map1[60:1045,379:579], m1, m2), 1.635, 1.05, xsize=13.5, ysize=3.2, /centimeters; was 1.76 
y=-100+findgen(201)
cgplot, x, y,  /nodata, xs=1, ys=1, charsize=[1.5], xtitle='Y, pixels', yticks=0, ytitle='X, pixels'
cgoplot, [0,1055], [0,0], linestyle=2, thick=2
cgtext, 1.02, .11, '(e)' , ALIGNMENT=1, /normal
device, /close
set_plot, 'win'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   PLOT FIG 5    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
L_lab=6562.82 & l_posH=1067 & wH=15 & L_Slab=6717. & l_posS=1351 & wS=11 & L_Nlab=6583. & L_posN=1105 & wN=11
velos_Ha=fltarr(203) & y_vel=fltarr(101) & velos_N=fltarr(203) & velos_S=fltarr(203)
for i=0,202 do begin
  l_Ha=poly(l_posH-wH+Ha[0,3,i],disp[0:3,397])
  velos_Ha[i]=imsl_constant('C')*(l_Ha-L_lab)/l_lab/1000
  ;l_sky=poly(l_posH-w1[0]+Ha[6,i],disp[0:3,500])
  ;velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
  l_N=poly(l_posN-wN+N2[0,3,i],disp[0:3,397])
  velos_N[i]=imsl_constant('C')*(l_N-L_Nlab)/l_Nlab/1000
  l_S=poly(l_posS-wS+S1[0,3,i],disp[0:3,397])
  velos_S[i]=imsl_constant('C')*(l_S-L_Slab)/l_Slab/1000
endfor  
N_vel=l_posH-50+findgen(101)
y_vel=imsl_constant('C')*(poly(N_vel,disp[0:3,397])-L_lab)/l_lab/1000
N_vel_S=l_posS-50+findgen(101)
y_vel_S=imsl_constant('C')*(poly(N_vel_S,disp[0:3,397])-L_S)/l_S/1000

x1=N_elements(Ha[0,0,*])*5-findgen(N_elements(Ha[0,0,*]))*5
!P.multi=[0,1,4]
set_plot, 'ps'
device, file=DIR+'Fig5.ps', /portrait, xsize=16,ysize=20, Yoff=2
errH=sqrt(Ha[0,1,*])/Ha[0,1,*] & errS=sqrt(S1[0,1,*])/S1[0,1,*] & errN=sqrt(N2[0,1,*])/N2[0,1,*]
cgplot, x1, alog(Ha[0,1,*]), xs=1, ys=1, charsize=[1.5], yticks=2, yrange=[5,13], ytitle='Log(Intensity)', title='H$\alpha$'
cgerrplot, x1, alog(Ha[0,1,*])-3*errH*alog(Ha[0,1,*]),alog(Ha[0,1,*])+3*errH*alog(Ha[0,1,*])
cgtext, 1.02, .88, '(a)' , ALIGNMENT=1, /normal
cgplot, x1, velos_Ha, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', title='H$\alpha$'
cgerrplot, x1, velos_Ha-3*errH*velos_Ha, velos_Ha+3*errH*velos_Ha
cgtext, 1.02, .63, '(b)' , ALIGNMENT=1, /normal
cgplot, x1, velos_S, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', title='S[II]6717'
cgerrplot, x1, velos_S-3*errS*velos_S, velos_S+3*errS*velos_S
cgtext, 1.02, .38, '(c)' , ALIGNMENT=1, /normal
cgplot, x1, velos_N, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', xtitle='Position along slit, pixels', title='N[II]6583'
cgerrplot, x1, velos_N-3*errN*velos_N, velos_N+3*errN*velos_N
cgtext, 1.02, .13, '(d)' , ALIGNMENT=1, /normal
device, /close
set_plot, 'win'




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOT FIG 6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
L_lab=6562.82 & l_posH=1066 & wH=15 & L_Slab=6717. & l_posS=1351 & wS=12 & L_Nlab=6583. & L_posN=1096 & wN=18
velos_Ha=fltarr(203) & y_vel=fltarr(101) & velos_N=fltarr(203) & velos_S=fltarr(203)
for i=0,202 do begin
  l_Ha=poly(l_posH-wH+Ha[1,3,i],disp[0:3,397])
  velos_Ha[i]=imsl_constant('C')*(l_Ha-L_lab)/l_lab/1000
  ;l_sky=poly(l_posH-w1[0]+Ha[6,i],disp[0:3,500])
  ;velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
  l_N=poly(l_posN-wN+N2[1,3,i],disp[0:3,397])
  velos_N[i]=imsl_constant('C')*(l_N-L_Nlab)/l_Nlab/1000
  l_S=poly(l_posS-wS+S1[1,3,i],disp[0:3,397])
  velos_S[i]=imsl_constant('C')*(l_S-L_Slab)/l_Slab/1000
endfor  
N_vel=l_posH-50+findgen(101)
y_vel=imsl_constant('C')*(poly(N_vel,disp[0:3,397])-L_lab)/l_lab/1000
N_vel_S=l_posS-50+findgen(101)
y_vel_S=imsl_constant('C')*(poly(N_vel_S,disp[0:3,397])-L_S)/l_S/1000

x1=N_elements(Ha[0,0,*])*5-findgen(N_elements(Ha[0,0,*]))*5
!P.multi=[0,1,4]
set_plot, 'ps'
device, file=DIR+'Fig6.ps', /portrait, xsize=16,ysize=20, Yoff=2
errH=sqrt(Ha[1,1,*])/Ha[1,1,*] & errS=sqrt(S1[1,1,*])/S1[1,1,*] & errN=sqrt(N2[1,1,*])/N2[1,1,*]
cgplot, x, alog(Ha[1,1,*]), xs=1, ys=1, charsize=[1.5], yticks=2, yrange=[5,13], ytitle='Log(Intensity)', title='H$\alpha$'
cgerrplot, x, alog(Ha[1,1,*])-3*errH*alog(Ha[1,1,*]),alog(Ha[1,1,*])+3*errH*alog(Ha[1,1,*])
cgtext, 1.02, .88, '(a)' , ALIGNMENT=1, /normal
cgplot, x, velos_Ha, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', title='H$\alpha$', yrange=[-200,200]
cgerrplot, x, velos_Ha-3*errH*velos_Ha, velos_Ha+3*errH*velos_Ha
cgtext, 1.02, .63, '(b)' , ALIGNMENT=1, /normal
cgplot, x, velos_S, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', title='S[II]6717', yrange=[-200,200]
cgerrplot, x, velos_S-3*errS*velos_S, velos_S+3*errS*velos_S
cgtext, 1.02, .38, '(c)' , ALIGNMENT=1, /normal
cgplot, x, velos_N, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', xtitle='Position along slit, pixels', title='N[II]6583', yrange=[-200,200]
cgerrplot, x, velos_N-3*errN*velos_N, velos_N+3*errN*velos_N
cgtext, 1.02, .13, '(d)' , ALIGNMENT=1, /normal
device, /close
set_plot, 'win'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOT FIG 7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
L_lab=6562.82 & l_posH=1067 & wH=15 & L_Slab=6717. & l_posS=1349 & wS=12 & L_Nlab=6583. & L_posN=1096 & wN=15
velos_Ha=fltarr(203) & y_vel=fltarr(101) & velos_N=fltarr(203) & velos_S=fltarr(203)
for i=0,202 do begin
  l_Ha=poly(l_posH-wH+Ha[2,3,i],disp[0:3,397])
  velos_Ha[i]=imsl_constant('C')*(l_Ha-L_lab)/l_lab/1000
  ;l_sky=poly(l_posH-w1[0]+Ha[6,i],disp[0:3,500])
  ;velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
  l_N=poly(l_posN-wN+N2[2,3,i],disp[0:3,397])
  velos_N[i]=imsl_constant('C')*(l_N-L_Nlab)/l_Nlab/1000
  l_S=poly(l_posS-wS+S1[2,3,i],disp[0:3,397])
  velos_S[i]=imsl_constant('C')*(l_S-L_Slab)/l_Slab/1000
endfor  
N_vel=l_posH-50+findgen(101)
y_vel=imsl_constant('C')*(poly(N_vel,disp[0:3,397])-L_lab)/l_lab/1000
N_vel_S=l_posS-50+findgen(101)
y_vel_S=imsl_constant('C')*(poly(N_vel_S,disp[0:3,397])-L_S)/l_S/1000

x1=N_elements(Ha[0,0,*])*5-findgen(N_elements(Ha[0,0,*]))*5
!P.multi=[0,1,4]
set_plot, 'ps'
device, file=DIR+'Fig7.ps', /portrait, xsize=16,ysize=20, Yoff=2
errH=sqrt(Ha[2,1,*])/Ha[2,1,*] & errS=sqrt(S1[2,1,*])/S1[2,1,*] & errN=sqrt(N2[2,1,*])/N2[2,1,*]
cgplot, x, alog(Ha[2,1,*]), xs=1, ys=1, charsize=[1.5], yticks=2, yrange=[5,13], ytitle='Log(Intensity)', title='H$\alpha$'
cgerrplot, x, alog(Ha[2,1,*])-3*errH*alog(Ha[2,1,*]),alog(Ha[2,1,*])+3*errH*alog(Ha[2,1,*])
cgtext, 1.02, .88, '(a)' , ALIGNMENT=1, /normal
cgplot, x, velos_Ha, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', title='H$\alpha$', yrange=[-100,100]
cgerrplot, x, velos_Ha-3*errH*velos_Ha, velos_Ha+3*errH*velos_Ha
cgtext, 1.02, .63, '(b)' , ALIGNMENT=1, /normal
cgplot, x, velos_S, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', title='S[II]6717', yrange=[-100,100]
cgerrplot, x, velos_S-3*errS*velos_S, velos_S+3*errS*velos_S
cgtext, 1.02, .38, '(c)' , ALIGNMENT=1, /normal
cgplot, x, velos_N, xs=1, ys=1, charsize=[1.5], yticks=0, ytitle='Velocity, km s$\up-1$', xtitle='Position along slit, pixels', title='N[II]6583', yrange=[-100,100]
cgerrplot, x, velos_N-3*errN*velos_N, velos_N+3*errN*velos_N
cgtext, 1.02, .13, '(d)' , ALIGNMENT=1, /normal
device, /close
set_plot, 'win'
end
plotter, DIR='d:\Observations\Processed\BTA\s160826\'
end