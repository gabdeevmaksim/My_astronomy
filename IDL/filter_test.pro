pro filter_test, FILT_NAME=filt_name, DIR=dir

files=file_search(dir+'*.fts', count=Nf)
type=strarr(Nf) & filter=strarr(Nf)
for i=0,Nf-1 do begin
  h=headfits(files(i))
  type[i]=sxpar(h,'IMAGETYP')
  Nx=sxpar(h,'NAXIS1')
endfor
b=where(type eq 'bias', ind)
r1=[1,2,3] & r2=[4,5,6]
mkbias, dir, 'SBias.fit', files[b], 0, bias
flat=readfits(files[1])
filter=readfits(files[8])
flat=flat-bias & filter=filter-bias
curve=filter/flat
disp=readfits('d:\Observations\Processed\s140815\disper.fts')
neon=poly(indgen(Nx),disp(0:3,150))

!P.multi=0
plot,neon, smooth(curve(*,518),5), xrange=[6800,8000], yrange=[0,1]
ma=max(curve(100:*,518))
print, ma
m=where(curve[100:*,518] gt ma/2, ind)
print, neon(m[ind-1])-neon(m[0])

writefits, dir+'filter.fts', curve, h

end
filter_test, FILT_NAME='SED607', DIR='d:\Observations\RAW\BTA\s140815\'
end



