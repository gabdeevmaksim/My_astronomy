pro compare


img1=readfits('d:\Observations\RAW\BTA\s110921\BS Tri\S9130415.FTS', h1)
img2=readfits('d:\Observations\RAW\BTA\s120826\s10110324.fts', h2)

Nx=sxpar(h1,'NAXIS1') & Ny=sxpar(h1,'NAXIS2')
y=[491,494] & w=6 & N=N_elements(y)
img=fltarr(N,Nx,Ny)
img[0,*,*]=img1 & img[1,*,*]=img2
spec=fltarr(N,Nx,w*2+1) & allspec=fltarr(Nx,w*N*2+N)
for i=0,N-1 do spec[i,*,*]=img[i,0:Nx-1,y[i]-w:y[i]+w]
allspec[*,0:w*2]=spec[0,*,*] & allspec[*,w*2+1:w*N*2+N-1]=spec[1,*,*]

set_plot, 'PS'
;sky, allspec, skym, /silent
dy=4.5 & dx=19
device,filename='f:\For work\Papers\BS Tri\spectra.ps', bits_per_pixel=24,$
xoffset=1,yoffset=1.5,/portrait;, xsize=dx,ysize=6*dy
;m1=skym*1.0
;m2=skym*2.0
;avg_p=fltarr(3) & std_p=fltarr(3) & num=sindgen(Nx)+1
;tv,255-bytscl(congrid(allspec(*,*),Nx/2,(w*N*2+N)/2),min=m1,max=m2),0.5,/centimeter
plot, findgen(Nx)+21, smooth(total(spec[0,*,*],3),3), yrange=[1.2e4,1.8e4], xrange=[2900,3100]
oplot, findgen(Nx), smooth(total(spec[1,*,*],3),3)

device,/close
set_plot, 'win'



end