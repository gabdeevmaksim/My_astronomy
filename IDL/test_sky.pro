pro test_sky
  
dir='f:\!!!Pract\OBSst\RAW\s120826\test\'
img=readfits(dir+'s10110318_red.fts',h)
X=sxpar(h,'NAXIS1') & Y=sxpar(h,'NAXIS2') & limit=32768.0
Ay=findgen(Y) & new_img=fltarr(X,Y) & Yc=[275,424,525,674] & Yv=intarr(300) & Iv=fltarr(300)
for i=21,X-1 do begin
  Yv[0:149]=Ay[Yc[0]:Yc[1]] & Yv[150:299]=Ay[Yc[2]:Yc[3]]
  Iv[0:149]=img[i,Yc[0]:Yc[1]] & Iv[150:299]=img[i,Yc[2]:Yc[3]]
  rez=robust_poly_fit(Yv, Iv, 2, yfit)
  pol=poly(Ay,rez)
  new_img[i,*]=img[i,*]-pol
endfor
writefits, dir+'sky.fts', new_img, h
end  