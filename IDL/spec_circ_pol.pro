pro spec_circ_pol, DIR=dir

;f=file_search(DIR+'s*_red.fts', count=N)
Nspec=4 & Nimg=1
for i=0,Nimg-1 do begin
  RDIR=DIR
  if Nimg ne 1 then begin
    if i lt 9 then RDIR=DIR+'0'+strcompress(string(i+1),/remove_all)+'\' else RDIR=DIR+strcompress(string(i+1),/remove_all)+'\'
  endif
  DIR=RDIR
  for j=0,Nspec-1 do begin
    if j lt 9 then RDIR=DIR+'0'+strcompress(string(j+1),/remove_all)+'\' else RDIR=DIR+strcompress(string(j+1),/remove_all)+'\'
    if j eq 0 then begin 
      tmp=readfits(RDIR+'obj_spect_1.fts')
      ;A=size(tmp) & s=A[1]-2 & me=10 & kub=dblarr(N,Ns,s/me)   & Q=dblarr(N,s/me) & U=dblarr(N,s/me) & In=dblarr(N,s/me)
      A=size(tmp) & s=A[1]-2 & me=10 & kub=dblarr(Nimg,Nspec,s)   & Q=dblarr(s) & U=dblarr(s) & In=dblarr(s)
    endif 
    tmp=readfits(RDIR+'obj_spect_1.fts') 
    kub[i,j,*]=tmp[0:s-1]
;    for k=1,s/me do begin
;      kub[i,j,k-1]=median(tmp[5*k-5:5*k+4])
;    endfor
  endfor 
;  In[i,*]=(kub[i,0,*]+kub[i,1,*])
;  Q[i,*]=(kub[i,0,*]-kub[i,1,*])/(kub[i,0,*]+kub[i,1,*])
;  U[i,*]=(kub[i,2,*]-kub[i,3,*])/(kub[i,2,*]+kub[i,3,*])
endfor
kub_tot=dblarr(Nspec,s)
for j=0,Nspec-1 do kub_tot[j,*]=total(kub[*,j,*],1)
  V=-0.7*(kub_tot[0,*]-kub_tot[1,*])/(kub_tot[0,*]+kub_tot[1,*])+0.7*(kub_tot[2,*]-kub_tot[3,*])/(kub_tot[2,*]+kub_tot[3,*])
  V=V*100
writefits, DIR+'V_Stoks_sum.fts', Q


restore, DIR+'linear_coef.sav'
x=findgen(A[1]-2)*dWl+Wl_min
set_plot, 'ps'
device,file=DIR+'V_Stoks_sum.ps',xsize=18,ysize=24,xoffset=1,yoffset=2.5,/portrait 
cgplot, x, kub_tot[0,*], xs=1, ys=1
cgoplot, x, kub_tot[1,*], color='red'
!p.MULTI=[0,1,2]
for i=0,Nimg-1 do begin
  plot, x, V, xs=1, ys=1, title='V,%', xr=[3900,7000], yrange=[10,-10]
  oplot, [0,10000], [0,0]
endfor
!p.MULTI=0
device, /close
set_plot, 'win'
!p.MULTI=0
end
spec_circ_pol, DIR='d:\Observations\Processed\BTA\s151107\standart_circ\'
end
   