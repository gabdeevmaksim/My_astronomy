pro change_fitshead

DIR='e:\Observations\BTA\s061021\'
files=file_search(DIR+'s*.fts',count=N)
print, N
for i=0,N-1 do begin
  f=readfits(files[i],h)  
  if sxpar(h, 'DISPERSE') eq 'VPHG550G 2.1 A/px' then sxaddpar, h, 'DISPERSE', 'VPHG1200G 0.88 A/px'
  ;sxaddpar, h, 'EXPTYPE', 'OBJ     ' 
  ;sxaddpar, h, 'OBJECT', 'F191853+430330'
  writefits, files[i], f, h
endfor
end  
