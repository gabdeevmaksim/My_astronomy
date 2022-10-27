 pro temp 
  RA=[02,09,29.82] & Dec=[28,32,29.4]
  openw, lun, 'f:\!!!Pract\OBSst\RAW\s121205\BSTri_ecl.dat', /get_lun
  for h=0.501,2.499,0.001 do begin
    juldate, [2012, 12, 5.+h], jdate
    JD1=helio_jd(jdate,ten(RA[0],RA[1],RA[2])*15,ten(Dec[0],Dec[1],Dec[2]))
    ;print, JD1
    JDmin=53666.543d
    period=0.06685d
    ph=(JD1-JDmin)/period
    if (ph-65536-fix(ph) lt 0.015) then print, JD1, ph-65536-fix(ph), h;, form='(F11.5,2X,F7.5,2X,F4.2)' 
    if (ph-65536-fix(ph) lt 0.015) then begin
      t=(h*24.+4.)
      if (t gt 24) and (t lt 48) then printf, lun, strcompress(string(fix(t-24))+':'+string(fix((t-fix(t))*60)),/remove_all)
      if t gt 48 then printf, lun, strcompress(string(fix(t-48))+':'+string(fix((t-fix(t))*60)),/remove_all)
      if t lt 24 then printf, lun, strcompress(string(fix(t))+':'+string(fix((t-fix(t))*60)),/remove_all)
    endif
  endfor
  close, /all
 end 