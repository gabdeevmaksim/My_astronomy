pro phase_for_polar, DIR=dir, RA=RA, DEC=Dec, PERIOD=period, JDMIN=JDmin, dT=dt

files=file_search(dir+'*.fts', count=N)

JD1=dblarr(N) & Nim=0
for i=0, N-1 do begin 
  head=headfits(files[i])
  if sxpar(head,'IMAGETYP') eq 'obj' then begin
    Nim++
    convert_time, sxpar(head, 'UT'), outtime 
    date=sxpar(head, 'DATE-OBS') 
    Texp=double(sxpar(head, 'EXPTIME'))
    year=double(strmid(date,0,4))
    month=double(strmid(date,8,2))
    convert_time, sxpar(head, 'START'), time
    ;if (time-outtime) lt 0 then begin
      ;day=double(strmid(date,8,2))-1+(time)/24+Texp/2/24/60/60 
    ;endif else day=double(strmid(date,8,2))+(time)/24+Texp/2/24/60/60
    day=double(strmid(date,5,2))+(time)/24.+Texp/2./24./60./60.
    juldate, [year, month, day], jdate
    JD1[i]=helio_jd(jdate,ten(RA[0],RA[1],RA[2])*15,ten(Dec[0],Dec[1],Dec[2]))
    JD1[i]=jdate-dT/24.
  endif
endfor
JD=dblarr(Nim/2) & phase=dblarr(Nim/2)
openw, lun, dir+'phase.dat', /get_lun
openw, lun1, dir+'JD.dat', /get_lun
for i=0,Nim-1,2 do begin 
  JD[i/2]=(JD1[i+1]+JD1[i])/2.  
  ph=(JD[i/2]-JDmin)/period
  phase[i/2]=ph-fix(ph)
  printf, lun, phase[i/2], format='(F10.8)'
  printf, lun1, JD[i/2], format='(F11.5)'
endfor
free_lun, lun, lun1
pol=read_table(dir+'Pol_dat.dat')
window, 1 
plot, phase, pol[0,*], xst=1, psym=6
end 
phase_for_polar, DIR='d:\Observations\RAW\BTA\s121115\IPHAS 0528\', $
                 RA=[05,28,32.69], Dec=[28,38,37.6], JDMIN=55949.2479d, PERIOD=0.055591331d, dT=4.
end