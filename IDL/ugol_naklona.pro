pro ugol_naklona

cosA=cos(3./!Pi)
fi=180 & i=dblarr(91*91) & b=dblarr(91*91)
for k=0,90 do begin
	for j=0,90 do begin
		i1=double(k) & b1=double(j)
		A=cos(i1/!Pi)*cos(b1/!Pi)-sin(i1/!pi)*sin(b1/!pi)*cos(fi/!pi)
		if abs(cosA-A) le 0.01 then begin
			i[k*91+j]=i1 & b[k*91+j]=b1
		endif
	endfor
endfor

plot, i, b, psym=6, xtitle='i', ytitle='b'
end
