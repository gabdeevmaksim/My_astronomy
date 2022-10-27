function test_cosm1, tmp

s=size(tmp) & N1=s[1] & N2=s[2] & N3=s[3]
for i=0,N1-2 do begin
  t=tmp[i,*,*]/tmp[i+1,*,*]
  for j=0,N2-1 do begin
    for k=0,N3-1 do begin
      if t[0,j,k] lt 0.7 then tmp[i+1,j,k]=tmp[i,j,k]
      if t[0,j,k] gt 1.3 then tmp[i,j,k]=tmp[i+1,j,k]
    endfor
  endfor
endfor
return, tmp
end