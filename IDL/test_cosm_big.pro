pro test_cosm_big

file1='d:\Observations\RAW\BTA\Nacvlishvily\s121114\Mrk1506\s10411606.fts'
file2='d:\Observations\RAW\BTA\Nacvlishvily\s121114\Mrk1506\s10411609.fts'
tmp1=fltarr(1024,1024) & tmp2=fltarr(1024,1024)
tmp1=readfits(file1,h1) & tmp2=readfits(file2,h2)
s=size(tmp1) & N2=s[1] & N3=s[2]
t=tmp1/tmp2
for j=0,N2-1 do begin
  for k=0,N3-2 do begin
    if t[j,k] lt 0.7 then tmp2[j,k]=tmp1[j,k]
    if t[j,k] gt 1.3 then tmp1[j,k]=tmp2[j,k]
  endfor
endfor

writefits, 'd:\Observations\RAW\BTA\Nacvlishvily\s121114\Mrk1506\s10411606_n.fts', tmp1, h1
writefits, 'd:\Observations\RAW\BTA\Nacvlishvily\s121114\Mrk1506\s10411609_n.fts', tmp2, h2
end