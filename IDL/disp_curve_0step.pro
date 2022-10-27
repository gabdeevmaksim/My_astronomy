pro disp_curve_0step

dir='f:\!!!Pract\OBSst\RAW\dispcurve\'
num_f='1800_660'
image=float(readfits(dir+'VPHG'+num_f+'.fts',h))
Nx=sxpar(h, 'NAXIS1')
Ny=sxpar(h, 'NAXIS2')
w=20
;print,Nx,Ny
x=findgen(Nx)
spec=total(image(*,Ny/2-w:Ny/2+w),2)/(2*w+1)
;writefits,dir+'spec'+num_f+'.fts', spec, h
;img=readfits(dir+'spec'+num_f+'.fts', h)
;plot, img
;stop
;plot obtained spectra snd point peaks
;R=where(spec lt 0,ind) & if ind gt 1 then spec(R)=0
;gamma=0.3
;window,7,xsize=1200,ysize=600
;spec=(spec+1)^gamma
Window,2, xsize=1200,ysize=600
;!P.multi=[0,1,2]
fi_peak,x,spec,1000,ipix,xpk,ypk,bkpk,ipk
;plot,x[0:2000],spec[0:2000],xst=1;, yrange=[900,2000]
 ; oplot,xpk,ypk,psym=6
;plot, x[2000:Nx-1],spec[2000:Nx-1],xst=1
  ;oplot,xpk,ypk,psym=6
  plot, x,spec,xst=1
  oplot,xpk,ypk,psym=6
end