pro spec_lin_pol, DIR=dir

;f=file_search(DIR+'s*_red.fts', count=N)
Nspec=4 & Nimg=5
for i=0,Nimg-1 do begin
  if Nimg ne 1 then begin
    if i lt 9 then RDIR=DIR+'0'+strcompress(string(i+1),/remove_all)+'\' else RDIR=DIR+strcompress(string(i+1),/remove_all)+'\'
  endif
  for j=0,Nspec-1 do begin
    if j lt 9 then RDIR1=RDIR+'0'+strcompress(string(j+1),/remove_all)+'\' else RDIR=RDIR+strcompress(string(j+1),/remove_all)+'\'
    if i eq 0 and j eq 0 then begin 
      tmp=readfits(RDIR1+'obj_spect_aper_1.fts')
      ;A=size(tmp) & s=A[1]-2 & me=10 & kub=dblarr(N,Ns,s/me)   & Q=dblarr(N,s/me) & U=dblarr(N,s/me) & In=dblarr(N,s/me)
      A=size(tmp) & s=A[1]-2 & me=10 & kub=dblarr(Nimg,Nspec,s)   & Q=dblarr(Nimg,s) & U=dblarr(Nimg,s) & PAtg=fltarr(Nimg,s) & In=dblarr(s) & equ=dblarr(Nimg,Nspec) & equ1=dblarr(Nimg,Nspec)
    endif 
    tmp=readfits(RDIR1+'obj_spect_aper_1.fts') 
    kub[i,j,*]=tmp[0:s-1]
;    for k=1,s/me do begin
;      kub[i,j,k-1]=median(tmp[5*k-5:5*k+4])
;    endfor
    equ1[i,j]=mean(kub[i,j,750:1250])
  endfor 
;  In[i,*]=(kub[i,0,*]+kub[i,1,*])
;  Q[i,*]=(kub[i,0,*]-kub[i,1,*])/(kub[i,0,*]+kub[i,1,*])
;  U[i,*]=(kub[i,2,*]-kub[i,3,*])/(kub[i,2,*]+kub[i,3,*])
endfor
kub_tot=dblarr(Nspec,s)
for i=0,Nimg-1 do begin
  for j=0,Nspec-1 do begin
    equ[i,j]=equ1[i,j]/max(equ1[*,j])
    kub[i,j,*]=kub[i,j,*]/equ[i,j]
  endfor
endfor
h=headfits('d:\Observations\Processed\BTA\s151107\standart_lin\obj_i.fts')
paran=sxpar(h,'PARANGLE')
rotan=sxpar(h,'ROTANGLE')
constan=131.5
for j=0,Nimg-1 do begin
  Q[j,*]=.5*(kub[j,0,*]-kub[j,1,*])/(kub[j,0,*]+kub[j,1,*])
  U[j,*]=.5*(kub[j,2,*]-kub[j,3,*])/(kub[j,2,*]+kub[j,3,*])
  PAtg[j,*]=paran-rotan+constan-0.5*calc_atan(U[j,*],Q[j,*])
endfor  
Q=Q*100 & U=U*100


Qav=fltarr(s) & Uav=fltarr(s) & errQav=fltarr(s) & errUav=fltarr(s) & PAav=fltarr(s) & errPAav=fltarr(s)
for i=0,s-1 do begin
  robomean, Q[*,i], 3, 3, avg, avgdev, stddev
  Qav[i]=avg & errQav[i]=stddev
  robomean, U[*,i], 3, 3, avg, avgdev, stddev
  Uav[i]=avg & errUav[i]=stddev
  robomean, PAtg[*,i], 3, 3, avg, avgdev, stddev
  PAav[i]=avg & errPAav[i]=stddev
endfor  
writefits, DIR+'Q_Stoks_sum.fts', Qav
writefits, DIR+'U_Stoks_sum.fts', Uav

restore, DIR+'linear_coef.sav'
x=findgen(A[1]-2)*dWl+Wl_min
set_plot, 'ps'
device,file=DIR+'Q&U_Stoks_sum.ps',xsize=18,ysize=24,xoffset=1,yoffset=2.5,/portrait 
cgplot, x, kub[0,0,*], xs=1, ys=1
cgoplot, x, kub[1,0,*], color='red'
cgoplot, x, kub[2,0,*], color='green'
cgoplot, x, kub[3,0,*], color='blue'
cgoplot, x, kub[4,0,*], color='yellow'
!p.MULTI=[0,1,4]

  plot, x, Qav, xs=1, ys=1, title='Q,%', xr=[4100,7000], yrange=[-5,5]
  oplot, [0,10000], [0,0]
  plot, x, errQav, xs=1, ys=1, title='errQ,%', xr=[4100,7000], yrange=[0,5]
  oplot, [0,10000], [0,0]
  plot, x, Uav, xs=1, ys=1, title='U,%', xr=[4100,7000], yrange=[-5,5]
  oplot, [0,10000], [0,0]
  plot, x, errUav, xs=1, ys=1, title='errU,%', xr=[4100,7000], yrange=[0,5]
  oplot, [0,10000], [0,0]
  
!p.MULTI=[0,1,3]
cgplot, x, sqrt(Qav^2+Uav^2), xs=1, ys=1, title='P,%', xr=[4100,7000], yrange=[-5,10] 
oplot, [0,10000], [0,0]
cgplot, x, PAtg, xs=1, ys=1, title='PA,%', xr=[4100,7000];, yrange=[-5,5]
cgplot, x, errPAav, xs=1, ys=1, title='errPA,%', xr=[4100,7000]
!p.MULTI=0
device, /close
set_plot, 'win'
!p.MULTI=0
end
spec_lin_pol, DIR='d:\Observations\Processed\BTA\s151107\standart_0\'
end