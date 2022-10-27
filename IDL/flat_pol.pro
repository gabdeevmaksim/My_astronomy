pro flat_pol, DIR=dir

files=file_search(DIR+'s13480410.fts', count=N)
img=readfits('d:\Observations\Processed\BTA\s151107\standart_lin\old\obj_i.fts',h)
rr=WHERe(img lt 0, ind)
if ind gt 0 then img[rr]=0
sum=total(img,1)
Ys=sxpar(h,'NAXIS2') & Xs=sxpar(h,'NAXIS1')
xpl=findgen(Ys)
fi_peak, xpl, sum,  1e5, ipix, xpk1, ypk1, bkpk1, ipk1
flat=readfits(files[0],h) & flat1=dblarr(8,Xs-350) & w=10 & xpl=findgen(Xs-350) 
for i=0,ipk1-1 do begin
  flat1[i*2,*]=total(flat[350:*,xpk1[i]-w:xpk1[i]+w],2,/double)
  flat1[i*2+1,*]=total(flat[350:*,xpk1[i]+w+2:xpk1[i]+3*w+2],2,/double)
  if i eq 3 then flat1[i*2+1,*]=total(flat[350:*,xpk1[i]-3*w-2:xpk1[i]-w-2],2,/double)
endfor
openw, 1, 'd:\Observations\Processed\BTA\s151107\standart_lin\flat.txt'
for i=0,Xs-351 do  printf, 1, flat1[*,i], format='(8(F11.3,2X))'
close, 1 
end
flat_pol, DIR='d:\Observations\Processed\BTA\s151107\standart_lin\'
end