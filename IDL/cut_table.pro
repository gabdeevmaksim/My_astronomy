pro cut_table

dir='d:\Observations\Processed\s110921\1RXS J184542.4+483\'
f=file_search(dir+'*.txt', count=c)
for i=0,c-1 do begin
	tmp=read_table(f[i])
	cut=where(tmp[0,*] lt 4000.00, n)
	if i lt 9 then openw, lun, dir+'New\0'+string(i+1,form='(I1)')+'.txt', /get_lun else openw, lun, dir+'New\'+string(i+1,form='(I2)')+'.txt', /get_lun
	for j=0,N_elements(tmp[0,*])-n-1 do printf, lun, tmp[0,n+j], tmp[1,n+j], format='(F8.3,2X,E14)'
	close, /all
endfor
end