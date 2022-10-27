pro subtruct_spec, DIR=dir

files=file_search(dir+'*.txt',count=count)
tot0=dblarr(count,2040) & t0=dblarr(2,2040)
for i=0,count-1 do begin
  tmp=read_table(files[i])
  tot0[i,*]=tmp[1,*]
endfor
t0[0,*]=tmp[0,*]
for i=0,2039 do begin
  RR=where(tot0[*,i] eq min(tot0[*,i]))
  t0[1,i]=tot0[RR,i]
endfor
plot, t0[0,*], t0[1,*]
tot=dblarr(count+1,2040)
tot[0,*]=t0[0,*]
window, 1
plot, t0[0,*], t0[1,*], /nodata
for i=0,count-1 do begin
  t1=read_table(files[i])
  tot[i+1,*]=smooth(t1[1,*]-t0[1,*],5)
  oplot, tot[0,*], tot[i,*], color=i*1000
  openw, lun1, dir+'spectra'+strcompress(string(i+10),/remove_all)+'.txt', /get_lun
  for j=0,2039 do printf, lun1, tot[0,j], tot[i+1,j], format='(F7.2,2X,E12.4)'
  free_lun, lun1
endfor
openw, lun, dir+'spectra1.dat', /get_lun
for i=0,2039 do printf, lun, tot[*,i], format='(F7.2,2X,30(E12.4,2X))'
free_lun, lun
end
subtruct_spec, DIR='d:\Observations\Processed\s100803\Spectra\'
end