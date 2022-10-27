pro Polar , path, mag

;flat=readfits(path+'reduction\SFlat.fts', /NO_UNSIGNED)
f_name1=file_search(path+'*.FTS');('f:/!!!Pract/OBSst/RAW/s110824/)
c=size(f_name1)
num1=c[1] & num=0

head=headfits(f_name1(0))
Nx=sxpar(head, 'NAXIS1')
Ny=sxpar(head, 'NAXIS2')
obj_pos=fltarr(4)
flat=fltarr(2,Nx,Ny) & nf=fltarr(2) & nb=0. & bias=fltarr(Nx,Ny)
f_name=strarr(242)
ycoor=[323,509,691]

for i=0,num1-1 do begin
  head=headfits(f_name1(i))
  if sxpar(head, 'IMAGETYP') eq 'obj' then begin
    f_name[num]=f_name1[i] & num++
    endif else begin
    if sxpar(head, 'IMAGETYP') ne 'bias' then begin
      temp=readfits(f_name1(i))
      temp=float(temp)
      for j=0,Nx-1 do begin
        temp[j,0:ycoor[1]]=float(temp[j,0:ycoor[1]])/float(temp[j,ycoor[0]])
        temp[j,ycoor[1]:(Ny-1)]=float(temp[j,ycoor[1]:(Ny-1)])/float(temp[j,ycoor[2]])
      endfor
      if sxpar(head, 'POLAMODE') eq 'Lambda/4 0' then begin
        nf[0]++
        flat[0,*,*]=flat[0,*,*]+temp
      endif else begin
        nf[1]++
        flat[1,*,*]=flat[1,*,*]+temp
      endelse
    endif
  endelse
  if sxpar(head, 'IMAGETYP') eq 'bias' then begin
  temp=readfits(f_name1(i))
  nb++ & bias=bias+temp
  endif
endfor
if (nf[0] eq 0) or (nf[1] eq 0) then begin
  flat[0,*,*]=1 & flat[1,*,*]=1
endif else begin
flat[0,*,*]=flat[0,*,*]/nf[0] & flat[1,*,*]=flat[1,*,*]/nf[1] & bias=1000;bias=bias/nb
endelse

first=readfits(f_name(20),head)
window, 1, xsize=Nx*2/3, ysize=Ny*2/3
display_image, (first-bias)/flat[0,*,*], 1, /MODIFY_OPT
click_on_max, first, x, y, mark=1, N_SELECT=4
x1=TOTAL(x[0:1])/2 & obj_pos[0:1]=[y[0],y[1]]
x2=TOTAL(x[2:3])/2 & obj_pos[2:3]=[y[2],y[3]]

Npol=2;sxpar(head, 'NAXIS3')
Nexp=num/2;sxpar(head, 'NAXIS4')
Npos=4
PolMode=sxpar(head, 'POLAMODE')
deg0=fix(strmid(PolMode,9,2))

cube=fltarr(Nx,Ny,Npol,Nexp)
xcen=fltarr(Npol,Nexp,Npos)
ycen=fltarr(Npol,Nexp,Npos)
count=fltarr(Npol,Nexp,Npos)
flux=fltarr(Npol,Nexp,Npos)
eflux=fltarr(Npol,Nexp,Npos)
star=fltarr(num)
obj=fltarr(num) & err1=fltarr(num)
P_star=fltarr(Nexp)
P_obj=fltarr(Nexp)
Str_err=fltarr(Nexp)
Obj_err=fltarr(Nexp)
time=fltarr(Nexp)

for i=0,num-1 do begin
  fits=readfits(f_name(i),h);,/NO_UNSIGNED);, /NOSCALE)
  ;print, fits[512,278]
   mode=sxpar(h, 'POLAMODE')
   deg=fix(strmid(mode,9,2))
  if deg0 eq deg then begin
    cube[*,*,0,i/2]=(fits-bias)/flat[0,*,*];/flat*(TOTAL(flat)/(Nx*Ny))
    convert_time, sxpar(h, 'TIME-OBS'), outtime
    t=sxpar(h,'EXPTIME')/3600
    if outtime lt 8 then time[i/2]=24+outtime+t else time[i/2]=outtime+t
  endif else begin
  cube[*,*,1,(i-1)/2]=(fits-bias)/flat[1,*,*];*(TOTAL(flat)/(Nx*Ny))
  endelse
endfor

;window,2,xsize=Nx,ysize=Ny
;tv,255-bytscl(cube(*,*,1,19),3000,5000)
;stop

for j=0,Npol-1 do begin
  for k=0,Nexp-1 do begin
    for i=0,Npos-1 do begin
      if i lt 2 then begin
        centrod, cube(*,*,j,k), x1, obj_pos[i],12,14,17,0, x, y, coun
        xcen[j,k,i]=x & ycen[j,k,i]=y
        count[j,k,i]=coun
        endif else begin
        centrod, cube(*,*,j,k), x2, obj_pos[i],12,14,17,0, x, y, coun
        xcen[j,k,i]=x & ycen[j,k,i]=y
        count[j,k,i]=coun
        endelse
     endfor
  endfor
endfor



for j=0,Npol-1 do begin
  for k=0,Nexp-1 do begin
      ;print, 1
      aper, cube(*,*,j,k),xcen(j,k,*),ycen(j,k,*),fl, efl, sky,skyerr, 2.1, 13, [14,16], $
      [-32767,32767], /flux, /silent
      ;print, (efl[0]+efl[1])/2/(fl[0]-fl[1])*100, format='(F9.2,2X,F9.2,2X,F9.2,2X,F9.2)'
      flux(j,k,*)=fl
      eflux(j,k,*)=efl
      endfor&endfor


for j=0,Nexp-1 do begin
  obj1=flux(0,j,0)+flux(0,j,1);+flux(1,j,0)+flux(1,j,1)
  obj2=flux(1,j,0)+flux(1,j,1)
  star1=flux(0,j,2)+flux(0,j,3);+flux(1,j,2)+flux(1,j,3)
  star2=flux(1,j,2)+flux(1,j,3)
  obj[j*2]=mag-2.5*alog10(obj1/star1)
  err1[j*2]=(eflux[0,j,0]+eflux[0,j,1])/obj1*obj[j]
  obj[(j*2)+1]=mag-2.5*alog10(obj2/star2)
  err1[(j*2)+1]=(eflux[1,j,0]+eflux[1,j,1])/obj2*obj[(j*2)+1]
endfor


P_obj=((flux(0,*,0)-flux(0,*,1))/(flux(0,*,0)+flux(0,*,1))-(flux(1,*,0)-flux(1,*,1))/(flux(1,*,0)+flux(1,*,1)))/2
P_star=((flux(0,*,2)-flux(1,*,3))/(flux(0,*,2)+flux(1,*,3))-(flux(1,*,2)-flux(1,*,3))/(flux(1,*,2)+flux(1,*,3)))/2
;Odj_err=((eflux(0,*,0)-eflux(0,*,1))/(eflux(0,*,0)+eflux(0,*,1))-(eflux(1,*,0)-eflux(1,*,1))/(eflux(1,*,0)+eflux(1,*,1)))/2
;Str_err=((eflux(0,*,2)-eflux(1,*,3))/(eflux(0,*,2)+eflux(1,*,3))-(eflux(1,*,2)-eflux(1,*,3))/(eflux(1,*,2)+eflux(1,*,3)))/2


robomean, P_star, 3, 0.5, avr, err, std
print, avr, err, std
ph=read_table(path+'phase.dat')
if n_elements(ph) eq 1 then time=time-time[0] else time=ph
window, 1, xsize=1200, ysize=600
!P.multi=[0,1,2]
plot, time, P_obj*100,xst=1,yst=1, Psym=5, yrange=[min(P_obj)*100-1,max(P_obj)*100+7],xtitle='Phase',ytitle='Pv, %';, xrange=[0,1]
oplot,time, P_star*100;, linestyle=2
oplot,time, P_star*100, Psym=6
oplot,time, P_obj*100;, linestyle=1
errplot, time, (P_obj-std)*100, (P_obj+std)*100
;errplot, time, (P_star-std)*100, (P_star+std)*100
plot, findgen(Nexp*2), obj, xst=1,yst=1, Psym=5, yrange=[max(obj)+1,min(obj)-1]
errplot, findgen(Nexp*2), (obj-err1), (obj+err1)
;plot,30-2.5*ALOG10(star),xst=1,yst=1, yrange=[20,10],xtitle='Phase',ytitle='V-magnitude',linestyle=2;,title='s5 0716+714, 6/11/2010, SCORPIO-2'; xrange=[0,1],
;oplot,30-2.5*ALOG10(obj)
;oploterr, Ph, P_obj*100,Obj_err*100, PSYM=1
;USERSYM, [0, 0], [-.5, .5]
;stop

set_plot,'PS'
device,file=path+'res.ps',xsize=28,ysize=16, /landscape,xoffset=1,yoffset=29
!P.multi=[0,1,2]
;!P.charsize=2
plot,time,P_obj*100,xst=1,yst=1,Psym=5, yrange=[min(P_obj)*100-1,max(P_obj)*100+7],xtitle='Phase',ytitle='Pv, %';, xrange=[0,1]
oplot,time,P_star*100;,linestyle=2
errplot, time, (P_obj-std)*100, (P_obj+std)*100
;errplot, time, (P_star-std)*100, (P_star+std)*100
;plot,30-2.5*ALOG10(star),xst=1,yst=1, yrange=[16,14],xtitle='Phase',ytitle='V-magnitude',linestyle=2;,title='s5 0716+714, 6/11/2010, SCORPIO-2'; xrange=[0,1],
;oplot,30-2.5*ALOG10(obj)
plot, obj, xst=1,yst=1, Psym=5, yrange=[max(obj)+1,min(obj)-1]
device,/close
set_plot,'WIN'

openw, 1, path+'Pol_dat.dat'
for i=0,Nexp-1 do printf, 1, P_obj[i]*100, Obj_err[i]*100, P_star[i]*100, Str_err[i]*100, format='(4(F6.2,2X))'
close, 1
openw, 2, path+'Phot.dat'
for i=0,Nexp*2-1 do printf, 2, obj[i], format='(F6.3,2X,F5.3)';, err1[i]
close, 2
end
polar, 'd:\Observations\RAW\BTA\s101106\USNO 0825\', 16.702
end
