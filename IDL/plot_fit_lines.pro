pro plot_fit_lines, DIR=dir

Ha=read_table(DIR+'params_Ha.txt')
SII=read_table(DIR+'params_S6717.txt')
NII=read_table(DIR+'params_N6583.txt')

name=['sum_3']
l_pos=1067 & L_lab=[6562.82,6583.,6717.] & l_posS=1349 & l_posN=1096
img=readfits(dir+name+'.fts',h)
disp=readfits(dir+'disper.fts')
map=readfits(dir+'img_slit3.fts',h) & XX=sxpar(h,'NAXIS1') & YY=sxpar(h,'NAXIS2')
w=50 & Ny=sxpar(h,'NAXIS2') & tempo=fltarr(Ny-1,1+2*w) & w1=[15,15,12]
tempo=img[l_pos-w:l_pos+w,150:1000]

S_Ha=SII[1,*]/Ha[1,*] & errS=(sqrt(SII[1,*])+sqrt(Ha[1,*]))/(Ha[1,*])
N_Ha=NII[1,*]/Ha[1,*] & errN=(sqrt(NII[1,*])+sqrt(Ha[1,*]))/(Ha[1,*])

out1=where(S_Ha gt 1.5 or S_Ha lt 0.0)
out2=where(N_Ha gt 1.5 or N_Ha lt 0.0) 
S_Ha[out1]=median(S_Ha) 
N_Ha[out2]=median(N_Ha)
X_l=findgen(2*w+1)+1013
lambda=poly(X_l,disp[0:3,500])
velos=imsl_constant('C')*(lambda-L_lab[0])/l_lab[0]/1000
a=size(Ha) & Nrow=a[2] & Ncol1=a[1]
set_plot, 'ps'
device, file=DIR+'Relation.ps',xsize=16,ysize=16, /portrait
!P.multi=1
;map1=mirror_y(map)
;map1=mirror_x(map2)
map1=map
robomean, map1, 3, 3, avg, avgdev, stddev
m1=avg-1*stddev
m2=avg+1*stddev
tv, 255-bytscl(map1, m1, m2), 2.77, 1.11, xsize=12.4, ysize=13.34, /centimeters; was 1.76 
cgplot, findgen(XX), YY-findgen(YY), /nodata, xs=1, ys=1, xtitle='X, pixels', ytitle='Y, pixels', color='black'
cgoplot, [475.5,475.5], [0,YY];, color='white'
cgoplot, [478.5,478.5], [0,YY];, color='white'

!P.multi=[0,1,4]
x1=29 & y_img=findgen(w*2+1) & dx=174 & x2=202
x=x1*5+findgen(dx)*5
cgplot, x, velos, /nodata, xs=1, title='Around H_alpha', xtitle='Y, pixels', ytitle='Velocity, km sec-1'
tempo1=transpose(tempo); & tempo1=mirror_y(tempo2)
robomean, tempo1, 3, 3, avg, avgdev, stddev
m1=avg-2*stddev
m2=avg+10*stddev
tv,  255-bytscl(tempo1, m1, m2), 1.4, 12.9, /centimeters, xsize=14.15, ysize=2.65
cgplot, x, Ha[1,x1:x2], xs=1, ytitle='Intensity', title='H_alpha', xtitle='Y, pixels'
cgplot, x, S_Ha[x1:x2], yrange=[0,1.5], xs=1, ytitle='Ratio', title='SII6717/H_alpha', xtitle='Y, pixels'
cgerrplot, x, S_Ha[x1:x2]-errS[x1:x2], S_Ha[x1:x2]+errS[x1:x2]
cgplot, x, N_Ha[x1:x2], /nodata, xs=1, title='NII6583/H_alpha', ytitle='Ratio', xtitle='Y, pixels', yrange=[0,1.5]
cgoplot, x, N_Ha[x1:x2]
cgerrplot, x, N_Ha[x1:x2]-errN[x1:x2], N_Ha[x1:x2]+errN[x1:x2]
;cgplot, x, N_Ha[x1:150], yrange=[0,1], xs=1, xtitle='Ratio', ytitle='Pixel', title='NII/H_alpha'
;cgerrplot, x, N_Ha[x1:150]-errN[x1:150], N_Ha[x1:150]+errN[x1:150]

;;;;;;;;;; plot velocity  ;;;;;;;;;;
velos_Ha=fltarr(dx) & velos_N=fltarr(dx) & velos_S=fltarr(dx) & velos_sky=fltarr(dx) 
for i=x1,x2 do begin
  l_Ha=poly(l_pos-w1[0]+Ha[3,i],disp[0:3,500])
  velos_Ha[i-x1]=imsl_constant('C')*(l_Ha-L_lab[0])/l_lab[0]/1000
  l_sky=poly(l_pos-w1[0]+Ha[6,i],disp[0:3,500])
  velos_sky[i-x1]=imsl_constant('C')*(l_sky-L_lab[0])/l_lab[0]/1000
  l_N=poly(l_posN-w1[1]+NII[3,i],disp[0:3,500])
  velos_N[i-x1]=imsl_constant('C')*(l_N-L_lab[1])/l_lab[1]/1000
  l_S=poly(l_posS-w1[2]+SII[3,i],disp[0:3,500])
  velos_S[i-x1]=imsl_constant('C')*(l_S-L_lab[2])/l_lab[2]/1000
  
endfor  
;R=where(velos_Ha lt -50, ind) & for i=0,ind-1 do velos_Ha[R[i]]=median(velos_Ha[R[i]-5:R[i]+5])
R=where(velos_N lt -100) & velos_N[R]=0;median(velos_N[R-2:R+2])
R=where(velos_S gt 300 or velos_S lt -100, ind) & for i=0,ind-1 do velos_S[R[i]]=median(velos_S[R[i]-5:R[i]+5])
poly_Ha=goodpoly(x, velos_Ha, 2, 3, yfit)
cgplot, x, velos_Ha, xs=1, title=string(poly_Ha[0])+string(poly_Ha[1])+string(poly_Ha[2]);, yrange=[-100,100], xtitle='Y, pixel', ytitle='Velocity, km/sec'
cgoplot, x, yfit, color='red'
;cgoplot, x, velos_sky, psym=3
;poly_sky=goodpoly(x, velos_sky, 2, 3, yfit)
;cgoplot, x, yfit, color='blue'
poly_N=goodpoly(x, velos_N, 2, 3, yfit)
cgplot, x, velos_N, xs=1, title=string(poly_N[0])+string(poly_N[1])+string(poly_N[2]);, yrange=[-100,100], xtitle='Y, pixel', ytitle='Velocity, km/sec'
cgoplot, x, yfit, color='red'
poly_S=goodpoly(x, velos_S, 2, 3, yfit)
cgplot, x, velos_S, xs=1, title=string(poly_S[0])+string(poly_S[1])+string(poly_S[2]);, yrange=[-100,100], xtitle='Y, pixel', ytitle='Velocity, km/sec'
cgoplot, x, yfit, color='red'
device, /close
set_plot, 'win'
end
plot_fit_lines, DIR='d:\Observations\Processed\BTA\s160826\slit3\'
end