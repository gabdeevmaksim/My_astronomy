pro sum_img, DIR=dir

name=['obj_1','obj_2','obj_3','obj_4','obj_5']
a=size(name)
file=dir+name[0]+'.fts'
h=headfits(file)
x=sxpar(h,'NAXIS1')
y=sxpar(h,'NAXIS2')
N=a[1] & imgs=fltarr(N,x,y)
for i=0,N-1 do begin
  file=dir+name[i]+'.fts'
  imgs[i,*,*]=readfits(file)
endfor
img_tot=total(imgs,1)
writefits, dir+'sum_2.fts', img_tot, h
end
sum_img, dir='d:\Observations\Processed\BTA\s160826\'
end