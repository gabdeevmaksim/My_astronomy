pro acc_sky_sub, DIR=dir

name=['obj-sky1']
n=n_elements(name)
for i=0,N-1 do begin
  img=readfits(dir+name[i]+'.fts',h)
  b=size(img) & Nx=b(1) & Ny=b(2) & L_pos=[923,867,893,959,1189,1217] & w=16 & tempo=fltarr(Nx-1,1+2*w) & step=5 
  tempo1=fltarr(Nx-1/step,1+2*w) & t=fltarr(1+2*w) & x=findgen(2*w+1) & A=fltarr(Nx/step,7)
  for j=0,N_elements(L_pos) do begin
    tempo=img[0:Nx-2,l_pos[j]-w:l_pos[j]+w]
    ;& err=fltarr(Nx)
    ;img[*,y]=img[*,y]/max(img[*,y])
    ;for j=0,Nx-1 do err[j]=1e-18
    for k=100,Nx-200-step-2,step do begin
      t=total(tempo[k:k+step,*],1)
      plot, t
      fi_peak, x, t, 3, ipix, xpk, ypk, bkpk, ipk
      if k eq 0 then lim=ypk-bkpk
      t=t-bkpk[0]
      ;xpk=11.4
      parinfo = replicate({value:0.D, fixed:0, limited:[0,0], $
                       limits:[0.D,0]}, 7)
      ;parinfo(1).fixed = 1
      ;parinfo(4).fixed = 1
      parinfo(0).limited(0) = 1
      parinfo(0).limits(0)  = 0
      parinfo(1).limited(0) = 1
      parinfo(1).limits(0)  = 0
      parinfo(2).limited(0) = 1
      parinfo(2).limits(0)  = 0
      parinfo(3).limited(0) = 1
      parinfo(3).limits(0)  = 0
      parinfo(4).limited(0) = 1
      parinfo(4).limits(0)  = 0;xpk-.5
      parinfo(4).limited(1) = 1 
      parinfo(4).limits(1)  = 30;xpk+.5
      parinfo(5).limited(0) = 1 
      parinfo(5).limits(0)  = 0
      parinfo(5).limited(1) = 1
      parinfo(5).limits(1)  = 10
      parinfo(6).limited(0) = 1
      parinfo(6).limits(0)  = 0
      if N_elements(xpk) gt 1 then begin
        parinfo(*).value = [ypk[0],xpk[0],3.5,ypk[1],xpk[1],3.5,10]
      endif else begin
        if xpk lt w then parinfo(*).value = [ypk,xpk,3.5,ypk,xpk+10,3.5,10] else parinfo(*).value = [ypk,xpk-10,3.5,ypk,xpk,3.5,10]
      endelse
      ;if ypk-bkpk gt lim then parinfo(*).value = [ypk,xpk-5,3.5,0.7*ypk,xpk,2.8,0] else parinfo(*).value = [0.5*ypk,xpk-5,3.5,ypk,xpk,2.8,0]
      parms = MPFITFUN('two_gauss', x, t, ERR, parinfo=parinfo, WEIGHTS=1, yfit=yy)
      o=k/step
      A[o,*]=parms
      area=A(o,0)*A(o,2)*SQRT(2*!DPI)
      p=[A(o,1),A(o,2),A(o,0)]
      YVALS = GAUSS1(x, p, /peak)
      area=A(o,3)*A(o,5)*SQRT(2*!DPI)
      p=[A(o,4),A(o,5),A(o,3)]
      YVALS1 = GAUSS1(x, p, /peak)
      set_plot, 'win'
      window, 1
      plot, x, t
      oplot, x, yvals, color=5000
      oplot, x, yvals1, color=5000
      oplot, x, yy
      tempo1[o,*]=yy
    endfor
    window, 2
  plot, A[*,3]
  writefits, DIR+'line2_1.fts', tempo1
  set_plot, 'ps'
  device,file=DIR+'1_iter2'+'.ps',xsize=18,ysize=24,xoffset=1,yoffset=2.5,/portrait
  robomean,A[*,4],3,1,avg1,avgdev1,stddev1
  robomean,A[*,5],3,1,avg2,avgdev2,stddev2
  plot, A[*,4], title='Avg_peak='+string(avg1)+'+/-'+string(stddev1)+' sigma='+string(avg2)+'+/-'+string(stddev2), color=0
  oplot, A[*,5]
  oplot, smooth(A[*,1],5), linestyle=1
  device,file=DIR+'line1'+'.ps',xsize=18,ysize=24,xoffset=1,yoffset=2.5,/portrait
  tv, tempo1
  device,/close
  stop, avg1, stddev1, avg2,stddev2
  endfor
endfor
end
acc_sky_sub, DIR='d:\Observations\Processed\BTA\s160826\'
end
