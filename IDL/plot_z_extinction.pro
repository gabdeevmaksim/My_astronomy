pro plot_z_extinction, DIR=dir, OBJ_NAME=obj_name, FILTER=filter

path=dir+obj_name+'\'+filter+'\'
phot=read_table(path+'phot1.txt')
a=size(phot) & raws=a[2] & col=a[1] & f=fltarr(col-2,2)
for i=2,col-1 do begin
  x=phot[1,*] & y=phot[i,*]
  f[i-2,*]=poly_fit(x,y,1)
endfor
x1=findgen(150)*.2+1
set_plot, 'PS'
device,file=path+filter+'_A_mean'+strcompress(string(mean(f[*,1])))+'_Graphs.ps',xsize=18,ysize=24,xoffset=1,yoffset=2.5,/portrait
;xyouts, .9, .9, 'Mean value of exctinction coefficient equal ' + strcompress(string(mean(f[*,1])))
!P.multi=[0,2,3]
plot, phot[1,*], phot[2,*], PSYM=6, yrange=[max(phot[2,*])+.2,min(phot[2,*])-.2], $
      title='M0 ='+strcompress(string(f[0,0]))+' A ='+strcompress(string(f[0,1])), $
      xtitle='Airmass', ytitle='Instrumental Mag'
oplot, x1, poly(x1,f[0,*])
for i=3,col-1 do begin
  plot, phot[1,*], phot[i,*], PSYM=6, yrange=[max(phot[i,*])+.2,min(phot[i,*])-.2], $
      title='M0 ='+strcompress(string(f[i-2,0]))+' A ='+strcompress(string(f[i-2,1])), $
      xtitle='Airmass', ytitle='Instrumental Mag'
  oplot, x1, poly(x1,f[i-2,*])
endfor
device,/close
set_plot, 'WIN'
!P.multi=0
end

plot_z_extinction, DIR='d:\Observations\RAW\Zeiss\Extinction\130307\', OBJ_NAME='3C 196', FILTER='I'
end