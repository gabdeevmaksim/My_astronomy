pro sorting_by_name, DIR=DIR

f=file_search(DIR+'*.fits', count=N)

names=strarr(N)
for i=0,N-1 do begin
  h=headfits(f[i])
  names[i]=sxpar(h,'OBJECT')
endfor

j=0
while j lt N-1 do begin
  rr=where(names eq names[j],ind)
  file_mkdir, DIR+strcompress(names[j],/remove_all)+'\'
  for i=0,ind-1 do file_copy, f[j+i], DIR+strcompress(names[j],/remove_all)+'\', /overwrite
  j=j+ind
endwhile

end
