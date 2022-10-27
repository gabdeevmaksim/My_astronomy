pro convert_time, inptime, outtime

;print, inptime
minute=double(strmid(inptime,3,2))
hour=double(strmid(inptime,0,2))
second=double(strmid(inptime,6,2))
outtime=hour+minute/60+second/3600
;print, outtime
return
end 

