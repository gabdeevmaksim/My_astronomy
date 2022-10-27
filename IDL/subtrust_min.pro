pro subtrust_min, DIR=dir

files=file_search(dir+'*.txt',count=count)
tmp=read_table(files[0])
a=size(tmp)
spec=fltarr(count+1,a[2]) & minspec=fltarr(2,a[2])
spec[0,*]=tmp[0,*]
for i=1,count do begin
	tmp=read_table(files[i-1])
	spec[i,*]=tmp[1,*]
endfor
for i=0,a[2]-1 do minspec[1,i]=min(spec[*,i])
set_plot, 'win'
plot, spec[0,*], minspec[1,*]
for i=1,count-1 do begin
	tmp=spec[i,*]-minspec[1,*]
	if i lt 10 then name=strcompress('subt0'+string(i)+'.txt',/remove_all) else $ ; i-1 to i and i lt 11
                  name=strcompress('subt'+string(i)+'.txt',/remove_all) ; i-1 to i
    openw, lun, dir+'Subtr\'+name, /get_lun
  	for j=0,a[2]-1 do printf, lun, spec[0,j], tmp[j], format='(F7.2,2X,E12.4)'
  	free_lun, lun
endfor
end
subtrust_min, dir='d:\Observations\Processed\BTA\s141030\CSS130604\'
end