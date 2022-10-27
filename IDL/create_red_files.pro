pro create_red_files, DIR=dir

files=file_search(dir+'*.fts', count=Nf)
if Nf eq 0 then files=file_search(dir+'*.fits', count=Nf)
type=strarr(Nf) & filter=strarr(Nf)

; изменение имэйджтайпа
;for i=10,12 do begin
;  tmp=readfits(files[i],h)
;  sxaddpar, h, 'IMAGETYP', strcompress('flat', /remove_all)
;  writefits, files[i], tmp, h
;endfor

for i=0,Nf-1 do begin
  h=headfits(files(i))
  type[i]=strcompress(sxpar(h,'IMAGETYP'),/remove_all)
  if type[i] eq 0 then type[i]=strcompress(sxpar(h,'EXPTYPE'),/remove_all)
  filter[i]=strcompress(sxpar(h,'FILTER'),/remove_all)
endfor
b=where(type eq 'bias' or type eq 'BIAS', ind)
if ind le 0 then message, 'Did not find bias-files'   
f=where(type eq 'flat' or type eq 'FLAT', ind)
if ind le 0 then message, 'Did not find flat-files'
mkbias, dir, 'SBias.fit', files[b], 0, bias
filters=['u','b','v','r','i',656,540,470]
letter=['U','B','V','R','I','656','540','470']
for i=0,7 do begin
  print, i
  r=where(filter eq filters[i] and (type eq 'flat' or type eq 'FLAT'), ind)
  if ind gt 0 then mkflat, dir, 'SFlat'+letter[i]+'.fit', files[r], 0, dir+'SBias.fit'
endfor
end
;create_red_files, DIR='d:\Observations\RAW\Zeiss\171215\Reduction\'
;end