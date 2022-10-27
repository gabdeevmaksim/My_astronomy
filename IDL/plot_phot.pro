pro plot_phot, DIR=dir

f=file_search(DIR+'*.txt',count=c)
f2=fltarr(c) & f1=fltarr(c)
for i=0, c-1 do begin
  t=read_table(f[i], col=7, /double)
  r1=where(t[0,*] lt 270 and t[0,*] gt 268,ind1)
  r2=where(t[1,*] lt 224 and t[1,*] gt 221,ind2)
  f2[i]=t[r1,r2]
  r1=where(t[0,*] lt 300 and t[0,*] gt 397,ind1)
  r2=where(t[1,*] lt 419 and t[1,*] gt 416,ind2) 
  f1[i]=t[r1,r2] 
endfor
m=-2.5*alog(f2/f1)
cgplot, m
end
plot_phot, DIR='d:\Observations\Processed\BTA\CSS130605\'
end
