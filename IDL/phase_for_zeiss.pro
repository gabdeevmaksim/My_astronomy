pro phase_for_zeiss, DIR=dir, PREFIX=prefix, MODE=mode, OBJNAME=objname, RA=RA, DEC=Dec, PERIOD=period, JDMIN=JDmin;, dh=dh

files=file_search(dir+prefix+'*.fts', count=N)
JD1=dblarr(N) & Nim=0
;openw, lun, DIR+'time.dat', /get_lun & sec=fltarr(N)
for i=0, N-1 do begin
  head=headfits(files[i])
  if (strcompress(sxpar(head,'OBJECT'),/remove_all) eq objname) and (strcompress(sxpar(head,'MODE'),/remove_all) eq mode) and (strcompress(sxpar(head,'IMAGETYP'),/remove_all) eq 'obj') then begin
    time=sxpar(head,'TSTART')
    if sxpar(head, 'DETECTOR') eq 'EEV CCD42-40' then time=sxpar(head,'START')
    if sxpar(head, 'DETECTOR') eq 'E2V CCD42-90 red' then time=sxpar(head,'START')
    hour=double(strmid(time,0,2))
    dh = hour - double(strmid(sxpar(head,'UT'),0,2))
    if dh lt 0 then dh=dh+24
    minute=double(strmid(time,3,2))
    seconds=double(strmid(time,6,5))
    Texp=double(sxpar(head, 'EXPTIME'))
    date=sxpar(head, 'DATE')
    year=double(strmid(date,0,4))
    month=double(strmid(date,5,2))
    day=double(strmid(date,8,2))+(hour)/24.+minute/1440.+(seconds+Texp/2)/24./60./60.-dh/24.
    if (hour)/24.+minute/1440.+(seconds+Texp)/24./60./60. gt 1 then day = day - 1
    juldate, [year, month, day], jdate
    JD1[Nim]=helio_jd(jdate,ten(RA[0],RA[1],RA[2])*15,ten(Dec[0],Dec[1],Dec[2]))
    JD1[Nim]=jdate
    Nim++
  endif
endfor
;close, lun
phase=dblarr(Nim)
openw, lun, dir+'phase_all.dat', /get_lun
openw, lun1, dir+'JD.dat', /get_lun
for i=0,Nim-1 do begin
  ph=(JD1[i]-JDmin)/period
  if ph gt 32000 then ph=ph-32000
  if i eq 0 then Ncyc = fix(ph)
  if ph lt 0 then ph=ph+1
  phase[i]=ph-Ncyc
  printf, lun, phase[i], format='(F7.5,2X)'
  printf, lun1, JD1[i], format='(F11.5)'
endfor
free_lun, lun, lun1
end
phase_for_zeiss, DIR='e:\Observations\BTA\s060322\', prefix = 's', MODE='Spectra', OBJNAME='RX1847+5538',$
                 RA=[18, 46, 58.797], Dec=[+55, 38, 28.77], JDMIN=54676.446d, PERIOD=0.0893869d;, dh=4.
end