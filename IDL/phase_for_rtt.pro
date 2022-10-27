pro phase_for_RTT, DIR=dir, RA=RA, DEC=Dec, PERIOD=period, JDMIN=JDmin, dh=dh

files=file_search(dir+'*.fit', count=N)
JD1=dblarr(N) & Nim=0
;openw, lun, DIR+'time.dat', /get_lun & sec=fltarr(N)
for i=0, N-1 do begin
  head=headfits(files[i])
  if sxpar(head,'IMAGETYP') eq 'object  ' then begin
    Nim++
    jdate = fxpar(head,'JD',DATATYPE=0.0D) - 2400000
    Texp= fxpar(head, 'EXPTIME')/86400.
    jdate = jdate + Texp/2
    JD=helio_jd(jdate,ten(RA[0],RA[1],RA[2])*15,ten(Dec[0],Dec[1],Dec[2]))
    JD1[i]=JD
  endif
endfor
;close, lun
phase=dblarr(Nim)
openw, lun, dir+'phase_all.dat', /get_lun
openw, lun1, dir+'JD.dat', /get_lun
for i=0,Nim-1 do begin
  ph=(JD1[i]-JDmin)/period
  if ph gt 32000 then ph=ph-32000
  phase[i]=ph-fix(ph)
  if phase[i] lt 0 then phase[i]=1+phase[i]
  printf, lun, phase[i], format='(F7.5,2X)'
  printf, lun1, JD1[i], format='(F11.5)'
endfor
free_lun, lun, lun1
end
phase_for_rtt, DIR='e:\Observations\RTT150\T20200928\SRGAJ21\', $
                 RA=[21,31,51.1], Dec=[49,14,05], JDMIN=59121.34958d, PERIOD=85.6d/1440d, dh=0
end