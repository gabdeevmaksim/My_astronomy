pro disp_curve_3step

;read data from files
dir='f:\!!!Pract\OBSst\RAW\dispcurve\'
num_f='1800_660'
img=readfits(dir+'VPHG'+num_f+'.fts', h)
f_spec=dir+'spectra'+num_f+'.dat'
f_peak=dir+'peak_of_line'+num_f+'.dat'
f_elements=dir+'elements'+num_f+'.dat'
grid=sxpar(h,'DISPERSE')
peaks=read_table(f_peak)
spectra=read_table(f_spec)

writefits, dir+grid+'.fit', spectra

N=N_elements(spectra[0,*])
Np=N_elements(peaks[0,*])
N1=N/4
wave=fltarr(4, N1+100)
intens=fltarr(4, N1+100)
wl=fltarr(Np)
elements=strarr(Np)
templ=ascii_template(f_elements)
file=read_ascii(f_elements,template=templ)
wl=file.field1
elements=file.field2
R=where((wl ne 0) and (peaks[1,*] ge 1.5) , ind)
if ind ge 1 then wl=wl[R] & elements=elements[R] & peaks=peaks[*,R] 
;R=where(abs(peaks[0,*]-wl[*]) le 0.5, ind)
;if ind ge 1 then wl=wl[R] & elements=elements[R] & peaks=peaks[*,R] 
Np=N_elements(peaks[0,*])


;partition of array for 4 parts
for i=0,3 do begin
  if (i ge 1) and (i lt 3) then begin
    wave[i,*]=spectra[0,i*N1-50:(i+1)*N1-1+50]  
    intens[i,*]=spectra[1,i*N1-50:(i+1)*N1-1+50]
    endif else begin
      if i eq 0 then begin
        wave[i,*]=spectra[0,i*N1:(i+1)*N1-1+100]  
        intens[i,*]=spectra[1,i*N1:(i+1)*N1-1+100]
      endif else begin  
        wave[i,*]=spectra[0,i*N1-100:(i+1)*N1-1]  
        intens[i,*]=spectra[1,i*N1-100:(i+1)*N1-1]
      endelse
    endelse  
endfor

;goto, fin
;obtaining coefecients of disperce curve by all identificated lines
  x=findgen(N)
  ;window, 1, xsize=1200, ysize=500
  ;plot, peaks[2,*], wl, xst=1
  R=where(elements ne 'dubl', ind)
  if ind gt 0 then w=wl[R] & p=peaks[2,R]
  ndeg=5
  ;disp_coef=goodpoly(peaks[2,*],wl,ndeg,1,yfit,newx,newy)
  disp_coef=goodpoly(p,w,ndeg,1,yfit,newx,newy)
  fit=0 & wave1=0
  for j=0,ndeg do begin
    fit=fit+disp_coef(j)*peaks[2,*]^j
    wave1=wave1+disp_coef(j)*x^j
  endfor
  window, 2, xsize=1200, ysize=500
  plot, wl, wl-fit, xst=1, psym=6, yrange=[-2,2]
  oplot,[0,spectra[0,N-1]],[0,0],linestyle=2 
  ;show average value of deviation and rms of it
  robomean,wl-fit,3,0.5,avg_err,rms_err
  print,avg_err,rms_err

;plot grafics into file
set_plot,'PS'
device,file=dir+'res'+grid+'.ps',xsize=28,ysize=19, /landscape,xoffset=1,yoffset=29
k=0
Np=N_elements(peaks[0,*])

!P.multi=[0,1,2]
for i=0,3 do begin
    ;window, i+1, xsize=1200, ysize=500
    m_int=max(intens[i,*])
    print, m_int
    !P.REGION=[0,0.225,1.2,1]
    plot, wave[i,*],intens[i,*], xst=1, yrange=[0,m_int+m_int/2.5], $
    title = "SCORPIO-2 longslit "+grid+'   lambda  '+string(fix(wave[i,0]))+'   -'+string(fix(wave[i,N1+99]))+'  A', $
    xrange=[wave[i,k],wave[i,N1+99]], xcharsize=0.01, ytitle='Relative intensity' 
    for j=k,Np-1 do begin
        if (peaks[0,j] le wave[i,N1+50]) then begin
            if j gt 0 then begin
              if (peaks[0,j]-peaks[0,j-1]) le 5 then begin 
              xyouts, peaks[0,j]+3, m_int+m_int/10, wl[j], orientation=90, charsize=0.9;, /data
              xyouts, peaks[0,j]+3, m_int+m_int/12+m_int/4, elements[j], orientation=90, charsize=1;, /data
              arrow, peaks[0,j],m_int+m_int/12,peaks[0,j],0, /data, thick=.5, hsize=1/1000
              endif else begin
              xyouts, peaks[0,j]+2, m_int+m_int/10, wl[j], orientation=90, charsize=0.9;, /data
              xyouts, peaks[0,j]+2, m_int+m_int/12+m_int/4, elements[j], orientation=90, charsize=1;, /data
              arrow, peaks[0,j],m_int+m_int/12,peaks[0,j],0, /data, thick=.5, hsize=1/1000
              endelse
            endif else begin
              xyouts, peaks[0,j]+2, m_int+m_int/10, wl[j], orientation=90, charsize=0.9;, /data
              xyouts, peaks[0,j]+2, m_int+m_int/12+m_int/4, elements[j], orientation=90, charsize=1;, /data
              arrow, peaks[0,j],m_int+m_int/12,peaks[0,j],0, /data, thick=.5, hsize=1/1000
            endelse
        endif else break
    endfor
    !P.REGION=[0,0,1.2,.32]
    plot, peaks[0,k:j-1], (wl[k:j-1]-fit[k:j-1]), xst=1, psym=6, $
          symsize=0.5, xrange=[wave[i,k],wave[i,N1+99]], yrange=[-0.6,0.6], $
          xtitle='Wavelength, A', ytitle='error, A'
    oplot,[0,wave[i,N1+99]],[0,0],linestyle=2
    k=j
    endfor
!P.multi=0
!P.REGION=0
device,/close
set_plot,'WIN'
end