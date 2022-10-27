pro clean_sky_remain, WDIR=wdir

files=file_search(wdir+'*.txt', count=count)
for i=0,count-1 do begin
	tmp=read_table(files[i])
	r=where(tmp[0,*] eq 5575.84)
	m=median(tmp[1,r-10:r+10])
	tmp[1,r-5:r+8]=m
	if i le 8 then openw, 1, wdir+'\New\'+strcompress('0'+string(i+1)+'.txt',/remove_all) else openw, 1, wdir+'\New\'+strcompress(string(i+1)+'.txt',/remove_all)
	N=N_elements(tmp[0,*])
	for j=0,N-1 do printf, 1, tmp[0,j], tmp[1,j], format='(F7.2,2X,E12.4)'
	close, 1
endfor
end
clean_sky_remain, WDIR='d:\Observations\Processed\s110921\1RXS J184542.4+483\New\'
end