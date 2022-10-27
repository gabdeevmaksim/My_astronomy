pro phase_of_period, DIR=dir, JDMIN=jdmin, RA=RA, DEC=Dec, PERIOD=period

restore, dir+'Time.sav'

print, UT, Tstart
a=size(UT) & N=a(2) & JD=dblarr(N)
for i=0,N-1 do begin
  year=fix(strmid(date[i],0,4))
  month=fix(strmid(date[i],5,2))
  if (Tstart[i]-UT[i]) lt 0 then begin
    day=double(strmid(date[i],8,2))-1+UT[i]/24+Texp[i]/2/24/60/60
  endif else day=double(strmid(date[i],8,2))+UT[i]/24+Texp[i]/2/24/60/60
  juldate, [year, month, day], jdate
  JD[i]=helio_jd(jdate,ten(RA[0],RA[1],RA[2])*15,ten(Dec[0],Dec[1],Dec[2]))
  ;stop, UT[i], Date[i]
endfor
JD=(JD-jdmin)
ph=JD/period
;ph=ph-fix(ph[0])

files=file_search(dir+'*.txt',count=count)
j=0 & openw, lun, dir+'071126.dat', /get_lun
for i=1,count-1,2 do begin
  if j lt 9 then name=strcompress('f0'+string(j+1)+'.txt',/remove_all) else name=strcompress('f'+string(j+1)+'.txt',/remove_all)
  if ph[j] gt 32000 then ph[j]=ph[j]-32000
  ph[j]=ph[j]-fix(ph[j])
  printf, lun, name ,ph[j], format='(A7,2X,F6.4)'
  j++
endfor
free_lun, lun
save, ph, filename=dir+'phase.sav'
h=(21.+6./60)/24.
juldate, [2012,04,18+h], tmp1
tmp2=(tmp1-jdmin)/period
print, tmp2-fix(tmp2)
end
phase_of_period, DIR='d:\Observations\Processed\s120826\BS Tri\', $
RA=[02,09,29.82], DEC=[28,32,29.4], JDMIN=53666.543, PERIOD=0.06685
end
