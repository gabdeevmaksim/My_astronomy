pro interstellar_extinction, DIR=dir, NAME=name

path=dir+name+'\'
files=file_search(path+'*.fts', count=N)
pol_mode=['Polaroid -60','Polaroid 0','Polaroid +60']
type=strarr(N) & pol=strarr(N) & his=strarr(N) & paran=fltarr(N) & rotan=fltarr(N) & constan=131.5
;apert=fix(findgen(16)+4)
apert=12
pi=3.14159265359d;imsl_constant('Pi')

for i=0,N-1 do begin
  h=headfits(files[i])
  type[i]=sxpar(h,'IMAGETYP')
  pol[i]=sxpar(h,'POLAMODE')
  his[i]=sxpar(h,'CHANGES')
  paran[i]=sxpar(h,'PARANGLE')
  rotan[i]=sxpar(h,'ROTANGLE')
endfor

xs=sxpar(h,'NAXIS1') & ys=sxpar(h,'NAXIS2')

obj_files=where(type eq 'obj', obj_i)
bias_files=where(type eq 'bias', bias_i)
flat_files=where((type eq 'flat') or (type eq 'neon'), flat_i)


;f_i=file_test(path+'SBias.fit')
;if f_i eq 0 then mkbias, path, 'SBias.fit', files[bias_files], 0, bias
f_i=file_test(path+'SFlat_'+pol_mode[0]+'.fit')
if f_i eq 0 then begin
  for i=0,2 do begin
    flat_1=where(pol[flat_files] eq pol_mode[i])
    ;mkflat, path, 'SFlat_'+pol_mode[i]+'.fit', files[flat_files[flat_1]], 0, dir+'SBias.fit'
    flat_for_pol, files[flat_files[flat_1]], path+'SFlat_'+pol_mode[i]+'.fit'
  endfor
endif
;bias=readfits(path+'SBias.fit')
pos=fltarr(4,4) & bias1=fltarr(4,20,20)
pos[0,*]=[0,19,0,19] & pos[1,*]=[xs-20,xs-1,0,19] & pos[2,*]=[0,19,ys-20,ys-1] & pos[3,*]=[xs-20,xs-1,ys-20,ys-1]
for i=0,2 do begin
  flat=readfits(path+'SFlat_'+pol_mode[i]+'.fit')
  for j=i,N_elements(obj_files)-1,3 do begin
    tmp=readfits(files[obj_files[j]],head)
    if his[obj_files[j]] ne 'Reduced ' then begin
      for l=0,3 do bias1[l,*,*]=tmp[pos[l,0]:pos[l,1],pos[l,2]:pos[l,3]]
      bias=mean(bias1)
      tmp=(tmp-bias)/flat
      sxaddpar, head, 'CHANGES', 'Reduced', format='(A7)', after='COMMENT'
      Z=where(tmp lt 0, ind)
      if ind gt 0 then tmp[Z]=0
      writefits, files[obj_files[j]], tmp, head
    endif
  endfor
endfor

if file_test(path+'coord.sav') eq 0 then begin
set_plot, 'win'
window, 1, xsize=xs/2, ysize=ys/2
img=readfits(files[obj_files[0]], h)
sky, img, skym, /silent
display_image, img, 1, /modify_opt;, options={range:[skym/2-20,skym/2+50],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L} ;
click_on_max, img, x, y, mark=1
wdelete, 1
save, x, y, filename=path+'coord.sav'
endif else begin
  restore, path+'coord.sav'
  img=readfits(files[obj_files[0]], h)
  sky, img, skym, /silent
endelse
Nx=N_elements(x) & Napert=N_elements(apert)
x_cen=fltarr(Nx) & y_cen=fltarr(Nx) & fmax=intarr(Nx) & avg_p=fltarr(Nx) & eavg_p=fltarr(Nx)
flux=dblarr(Napert,Nx) & eflux=dblarr(Napert,Nx) & skyerr=dblarr(Napert,Nx)


for i=0,Nx-1 do begin
  centrod, img, x[i], y[i], 12, 13, 15, skym, x1, y1, coun
  x_cen[i]=x1 & y_cen[i]=y1
endfor


;Determining of best aperture. Excluded!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;for i=0, Napert-1 do begin
;  aper, img, x_cen, y_cen, fl, efl, skyf,serr, 2.1, apert[i], [apert[i]+3,apert[i]+5], $
;        [-32767,56000], /flux, /silent
;  ;print, fl[*]/(serr[*]*sqrt(apert[i]^2*pi))
;  flux[i,*]=fl & eflux[i,*]=efl & skyerr[i,*]=serr
;endfor

;for i=0,Nx-1 do fmax[i]=where((flux[*,i]/(skyerr[*,i]*sqrt(apert[*]^2*pi))) eq max(flux[*,i]/(skyerr[*,i]*sqrt(apert[*]^2*pi))) and (max(flux[*,i]/(skyerr[*,i]*sqrt(apert[*]^2*pi))) gt 15))
;fg=where(fmax ge 0, Nx)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

img=fltarr(obj_i/3,xs,ys) & tpm=fltarr(xs,ys) & PA=fltarr(obj_i/3,Nx) & ePA=fltarr(obj_i/3,Nx) & z=fltarr(obj_i/3) & small_img=fltarr(obj_i/3,59,59)
P=fltarr(obj_i/3,Nx) & Ip=fltarr(obj_i/3,3,Nx) & eI=fltarr(obj_i/3,3,Nx) & eP=fltarr(obj_i/3,Nx) & PAtg=fltarr(obj_i/3,Nx)
U=fltarr(obj_i/3,Nx) & Q=fltarr(obj_i/3,Nx) & eU1=fltarr(obj_i/3,Nx) & eQ1=fltarr(obj_i/3,Nx)


for k=0,2 do begin
  for i=0,obj_i-1,3 do begin
    img[i/3,*,*]=readfits(files[obj_files[i+k]],h,/silent)
    z[i/3]=sxpar(h,'Z')
  endfor
  for j=0,Nx-1 do begin
    for i=0,obj_i-1,3 do begin
      tmp[*,*]=img[i/3,*,*]
      ;sky, tmp[*,*], skym, skysig, /silent
      ;tmp[*,*]=tmp[*,*]-skym
      zero=where(tmp lt 0, ze)
      if ze gt 0 then tmp[zero]=0
      x1=x_cen[j] & y1=y_cen[j]
      ;centrod, tpm, x_cen[j], y_cen[j], apert, apert+1, apert+3, skym, x1, y1, count
      ;aper, tpm, x1, y1, fl,efl,skyf,serr, 2.1, apert, [apert,apert], $
      ;     [-32767,56000], /flux, /silent, SETSKY=skym;SETSKYVAL=[skym,skysig,10000]
      sky, tmp((x1-29):(x1+29),(y1-29):(y1+29)), skym, skysig, /silent, /meanback
      robomean, tmp((x1-29):(x1+29),(y1-29):(y1+29)), 3, .5, avg, avd, std
      small_img[i/3,*,*]=tmp((x1-29):(x1+29),(y1-29):(y1+29))
      small_img[i/3,*,*]=small_img[i/3,*,*]-avg-1*std
      for l1=0,58 do for l2=0,58 do if small_img[i/3,l1,l2] lt 0 then small_img[i/3,l1,l2]=0
      ;R=where(small_img[i/3,*,*] gt skym)
      fl=total(small_img[i/3,*,*])
      x = 1.0/cos(z[i/3]/(180/!PI))-1
      am = float(1.0+(0.9981833d0-(0.002875d0+0.0008083d0*x)*x)*x)
      Ip[i/3,k,j]=fl*am; & eI[i/3,k,j]=efl
    endfor
  endfor
endfor
relav1=fltarr(obj_i/3,3,Nx) & allav=fltarr(obj_i/3,3) & eallav=fltarr(obj_i/3,3) & Ipav1=fltarr(3,Nx) & eIav1=fltarr(3,Nx) & good=intarr(3,Nx)
good[*]=1
print, Nx
set_plot, 'win'
;window, 1, xs=1000, ys=650
;!P.multi=[0,3,3]
; estimation of tranceparansy of atmosphere
for k=0,2 do begin                                                    ; in every position of Polaroid
  for j=0,Nx-1 do begin                                               ; for each object
    robomean, Ip[*,k,j], 3, 0.5, avg, avgdev, stdd                  ; calculate average value of intensity from all cycles
    ;robomean, Ip[R,k,j], 3, 0.5, avg, avgdev, stddev
    relav1[*,k,j]=Ip[*,k,j]/avg                                       ; and then coefficient of deviation from average for every object in each image

  endfor

  for i=0,obj_i-1,3 do begin                                ; and for each cycle
    robomean, relav1[i/3,k,*], 3, 0.5, avg1, avgdev1, stddev1   ; calculate mean value of deviation from average by all objects
    allav[i/3,k]=avg1 & eallav[i/3,k]=stddev1                ; remember mean value of deviation from average by all objects and its std dev
    Ip[i/3,k,*]=Ip[i/3,k,*]/allav[i/3,k]                    ; correction for mean value of deviation from average by all objects
  endfor
;  for j=0,Nx-1 do begin                                               ; for each object
;    robomean, Ip[*,k,j], 3, 0.5, avg, avgdev, stddev                  ; calculate average value of intensity from all cycles
;    relav1[*,k,j]=Ip[*,k,j]/avg                                       ; and then coefficient of deviation from average for every object in each image
;    r=where((relav1[*,k,j] gt 1.025) or (relav1[*,k,j] lt 0.975), ind1)  ; checking if coefficient of deviation from average for every object satisfy
;    if ind1 gt 0 then good[k,j]=0
;    Ipav1[k,j]=avg & eIav1[k,j]=stddev                                ; remember mean value of intensity and standard deviation of every object
;  endfor
endfor

;for k=0,2 do begin
;  for j=0,2 do begin
;    plot, relav1[k,j,*], psym=6, title=string(allav[k,j]), yrange=[.9,1.1]
;    oplot, [0,100], [.98,.98], linest=0
;    oplot, [0,100], [1.02,1.02], linest=0
;  endfor
;endfor
;window, 2, xs=1000, ys=650
;!P.multi=[0,3,3]
for k=0,2 do begin
  for j=0,Nx-1 do begin                                               ; for each object
    robomean, Ip[*,k,j], 3, 0.5, avg, avgdev, stddev                  ; calculate average value of intensity from all cycles
    relav1[*,k,j]=Ip[*,k,j]/avg                                       ; and then coefficient of deviation from average for every object in each image
  endfor
  ;for j=0,2 do begin
  ;  plot, relav1[k,j,*], psym=6, title=string(allav[k,j]), yrange=[0.9,1.1]
  ;  oplot, [0,100], [.98,.98], linest=0
  ;  oplot, [0,100], [1.02,1.02], linest=0
  ;endfor
endfor
;stop
;window, 1, xsize=400, ysize=800
set_plot, 'PS'
img=readfits(files[obj_files[0]], h)
sky, img[300:700,300:700], skym, /silent
dy=4.5 & dx=19
device,filename=path+name+'.ps', xsize=dx,bits_per_pixel=24,$
	ysize=6*dy,xoffset=1,yoffset=1.5,/portrait
m1=skym*1.0
m2=skym*2.0
avg_p=fltarr(3) & std_p=fltarr(3) & num=sindgen(Nx)+1
tv,255-bytscl(congrid(img(*,*),xs/2,ys/2),min=m1,max=m2),0.5,/centimeter
xp=fltarr(Nx) & yp=fltarr(Nx)

xp=x_cen[*]/xs & yp=y_cen[*]/ys*0.705
cgarrow,xp[*]+.02,yp[*]-.02,xp[*],yp[*],color='black',/norm
xyouts,xp[*]+.02,yp[*]-.02,strcompress(num[*]), color=10,font=1, /norm

!P.multi=0
plot,[0],[0],xst=5,yst=5,/nodata
for j=0,Nx-1 do begin                                               ; for each object
  for k=0,2 do begin                                                    ; in every position of Polaroid
    robomean, Ip[*,k,j], 3, 0.5, avg, avgdev, stdd                  ; calculate average value of intensity from all cycles
    avg_p[k]=avg & std_p[k]=stdd
  endfor
  if j lt 33 then begin
  xyouts, .01, 0.97, '#  <I-60> +/- err    <I0> +/- err    <I+60> +/- err'
  xyouts, 0.01, .97-0.03*num[j], strcompress(num[j])+'  '+string(avg_p[0],format='(F11.3)')+' +/-'+string(std_p[0],format='(F9.3)')+'  '+$
		string(avg_p[1],format='(F11.3)')+' +/-'+string(std_p[1],format='(F9.3)')+'  '+string(avg_p[2],format='(F11.3)')+' +/-'+ $
		string(std_p[2],format='(F9.3)'), font=1
  endif else begin
    if j eq 33 then begin
	  plot,[0],[0],xst=5,yst=5,/nodata
	  xyouts, .01, 0.97, '#  <I-60> +/- err    <I0> +/- err    <I+60> +/- err'
	endif
    xyouts, 0.01, .97-0.03*num[j-33], strcompress(num[j])+'  '+string(avg_p[0],format='(F11.3)')+' +/-'+string(std_p[0],format='(F9.3)')+'  '+$
		string(avg_p[1],format='(F11.3)')+' +/-'+string(std_p[1],format='(F9.3)')+'  '+string(avg_p[2],format='(F11.3)')+' +/-'+ $
		string(std_p[2],format='(F9.3)'), font=1
  endelse
endfor

!P.multi=[0,1,3]
for k=0,2 do begin
  plot, findgen(obj_i/3)+1, allav[*,k], yrange=[0.95,1.05], xrange=[0,obj_i/3+1], ytitle='Relative Intensity', xtitle='N# of cicle', title=pol_mode[k], linestyle=3, psym=6
  errplot, findgen(obj_i/3)+1, allav[*,k]-eallav[*,k], allav[*,k]+eallav[*,k]
  oplot, [0,100], [1,1], linestyle=2
endfor
;U=fltarr(Nx) & Q=fltarr(Nx) &  & P=fltarr(Nx) & eP=fltarr(Nx) & PAtg=fltarr(Nx)

U1=fltarr(Nx) & Q1=fltarr(Nx) & avI=fltarr(3,Nx) & avdI=fltarr(3,Nx) & stI=fltarr(3,Nx) & eU1=fltarr(Nx) & eQ1=fltarr(Nx)
per=fltarr(3)
U1[*]=0 & Q1[*]=0
;for i=0,(obj_i-1)/3 do begin
  for j=0,Nx-1 do begin
    for k=0,2 do begin
      robomean, Ip[*,k,j], 3, .5, av, avd, std
      R=where(abs(Ip[*,k,j]-av) lt std, rr)
      robomean, Ip[R,k,j], 3, .5, av, avd, std
      avI[k,j]=av & stI[k,j]=std & per[k]=stI[k,j]/avI[k,j]
    endfor
    if (per[0] lt 0.02) and (per[1] lt 0.02) and (per[2] lt 0.02) then begin
      Isum=total(avI[*,j])
      U1[j]=(2*avI[1,j]-avI[0,j]-avI[2,j])/Isum*100
      ;U[i,j]=(2*Ip[i,1,j]-Ip[i,0,j]-Ip[i,2,j])/Isum
      Q1[j]=(avI[2,j]-avI[0,j])/(sqrt(3)*(Isum))*100
      ;Q[i,j]=(Ip[i,0,j]-Ip[i,2,j])/(sqrt(3)*(Isum))
      eU1[j]=3/Isum^2*sqrt((avI[0,j]+avI[2,j])^2*stI[1,j]^2+avI[1,j]^2*(stI[0,j]^2+stI[2,j]^2))*100
      eQ1[j]=100*sqrt((-avI[2,j]+avI[0,j])^2*stI[1,j]^2+(avI[1,j]+2*avI[2,j])^2*stI[0,j]^2+(avI[1,j]+2*avI[0,j])^2*stI[2,j])/sqrt(3)/Isum^2
    endif
  endfor
nen=where(U1 ne 0, id)
if id ne 0 then begin
  U=fltarr(id) & Q=fltarr(id) & eU2=fltarr(id) & eQ2=fltarr(id)
  U=U1[nen] & Q=Q1[nen] & eU2=eU1[nen] & eQ2=eQ1[nen]
endif
Nx=id
;window, 3
!P.multi=[0,1,3]
for k=0,2 do begin
  plot, avI[k,*], stI[k,*]/avI[k,*], xtitle='Intensity', ytitle='Error', title=pol_mode[k]+' '+string(id, form='(I2)')+' stars below 2% accuracy' , psym=2, /xlog, $
        yrange=[-0.02,max(stI[k,*]/avI[k,*]+0.03)], charsize=1.3
  oplot, [1e2,1e10], [.02,.02], linestyle=0;, color=2000
endfor
bin=0.5 & tm=intarr(Nx) & thresh=1
  robomean, U, thresh, 0.5, avU, avdU, stdU
  ;Ru=where(abs(U-avU) lt stdU, ur)
!P.multi=[0,1,2]
;print, avU, avdU, stdU
robomean, Q, thresh, 0.5, avQ, avdQ, stdQ
;print, avQ, avdQ, stdQ
;Rq=where(abs(Q-avQ) lt stdQ, uq)
;R1=where(Ru eq Rq, uq)
cgHistoplot, Q[*],  BACKCOLORNAME = 'white', CHARSIZE = 1.2,  DATACOLORNAME = 'black', AXISCOLORNAME = 'black', $
             ytickformat = '(F4.1)', TITLE = 'Q(5500) = ' + string(avQ,format='(F5.2)')+'!9+!3'+string(stdQ,format='(F5.3)'), $
             XTITLE = 'Q, % ', YTITLE='Number of stars',  BINSIZE=bin, xrange=[-3,3];, /window,
cgHistoplot, U[*],  BACKCOLORNAME = 'white', CHARSIZE = 1.2,  DATACOLORNAME = 'black', AXISCOLORNAME = 'black', $
             ytickformat = '(F4.1)', TITLE = 'U(5500) = ' + string(avU,format='(F5.2)')+'!9+!3'+string(stdU,format='(F5.3)'), $
             XTITLE = 'U, % ', YTITLE='Number of stars', BINSIZE=bin, xrange=[-3,3];, xrange=[-2,2], /window
U1=fltarr(Nx) & Q1=fltarr(Nx) & errU=fltarr(Nx) & errQ=fltarr(Nx) & P=fltarr(Nx) & eP=fltarr(Nx) & PAtg=fltarr(Nx)
P=sqrt(avU^2+avQ^2)
eP=sqrt(stdQ^2+stdU^2)
PAtg=paran[0]-rotan[0]+constan-0.5*calc_atan(avU,avQ)
ePAtg=28.1*eP
if PAtg lt 0 then PAtg=360+PAtg
if PAtg gt 180 then PAtg=PAtg-180
plot,[0],[0],xst=5,yst=5,/nodata
if stdQ lt 0.01 then stdQ=0.01
if stdU lt 0.01 then stdU=0.01
xyouts, .01, 0.97, 'U = '+string(avU,format='(F5.2)')+'!9+!3'+string(stdU,format='(F5.2)')+'  Q = '+string(avQ, format='(F5.2)')+'!9+!3'+string(stdQ, format='(F5.2)'), /norm
xyouts, .01, 0.94, 'Lin.Pol = '+string(P, format='(F5.2)')+'!9+!3'+string(eP, format='(F4.2)')+'  PA = '+string(PAtg, format='(F7.2)')+'!9+!3'+string(ePAtg, format='(F6.2)'), /norm
device, /close
set_plot, 'win'
openw, lun, path+name+'.txt', /get_lun
printf, lun, 'U = ', avU, '+/-', stdU, 'Q = ', avQ, '+/-', stdQ, format='(A4,F5.2,A3,F5.2,2X,A4,F5.2,A3,F5.2)'
printf, lun, ' '
printf, lun, 'Lin.Pol = ', P,'+/-', eP, 'PA = ', PAtg, '+/-', ePAtg, format='(A10,F5.2,A3,F4.2,2X,A5,F7.2,A3,F6.2)'
close, lun
end

interstellar_extinction, DIR='d:\Observations\RAW\BTA\Nacvlishvily\s121115\', NAME='SDSS J095207+25525'

end