

;correct calculation arctangens
function  calc_atan,U,Q
N=N_elements(U)
fi=fltarr(N)
for k=0,N-1 do begin
if (U(k) eq 0) and (Q(k) gt 0) then fi(k)=90
if (U(k) eq 0) and (Q(k) lt 0) then fi(k)=270
if U(k) ne 0 then begin
c=abs(Q(k)/U(k))
fi(k)=atan(c)*180/!PI
;print, fi[k]
if (Q(k) ge 0) and (U(k) lt 0) then fi(k)=180-fi(k)
if (Q(k) lt 0) and (U(k) lt 0) then fi(k)=fi(k)+180
if (Q(k) lt 0) and (U(k) gt 0) then fi(k)=360-fi(k)
;print, fi[k]
endif
endfor
return,fi
end