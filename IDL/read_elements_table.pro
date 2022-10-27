pro read_elements_table, filename, table
dir='f:\!!!Pract\OBSst\RAW\dispcurve\'
Nl=file_lines(dir+filename+'.dat')
table1=strarr(Nl)
table=strarr(5,Nl)
openr, lun, dir+filename+'.dat', /get_lun
readf, lun, table1
free_lun, lun
table1=strcompress(table1)
for i=0,Nl-1 do begin
  t=str_sep(table1[i],' ')
  for k=0,3 do  table[k,i]=t[k]
endfor
end