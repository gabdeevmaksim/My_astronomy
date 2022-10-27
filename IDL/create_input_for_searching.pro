function create_input_for_searching, DIR

;DIR='e:\Observations\MMPP\' 
;file=dialog_pickfile(PATH=DIR,filter=['*.fit','*fts','*.fits'],GET_PATH=DIR)
files=file_search(DIR+'*_color.fits', count=N)
length=strlen(DIR) & name=strarr(N)
for i=0,N-1 do begin
  simbol=strmid(files[i],length,1)
  print, simbol
  if simbol eq ('C' or 'M') then name[i]=strmid(files[i],length,9) else name[i]=strmid(files[i],length,9)
endfor 
return, name
end
