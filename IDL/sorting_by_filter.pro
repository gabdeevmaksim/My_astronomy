pro sorting_by_filter, DIR=dir

files=file_search(dir+'*.fts', count=Nf)
type=strarr(Nf) & filter=strarr(Nf)

for i=0,Nf-1 do begin
  h=headfits(files(i))
  type[i]=sxpar(h,'IMAGETYP')
  filter[i]=sxpar(h,'FILTER')
endfor

filters=['u','b','v ','r','i']
letter=['U','B','V','R','I']

for i=0,4 do begin
  file_mkdir, DIR+letter[i]
  r=where(filter eq filters[i], ind)
  if ind gt 0 then file_move, files[r], DIR+letter[i]+'\'
endfor
end
sorting_by_filter, DIR='d:\Observations\RAW\Zeiss\180215\IPHAS 0528\'
end



