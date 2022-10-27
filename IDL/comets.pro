pro comets, DIR=dir, NAME=name

path=dir+name+'\'
files=file_search(path+'*.fts', count=N)
pol_mode=['Polaroid -60','Polaroid 0','Polaroid +60']
type=strarr(N) & pol=strarr(N) & his=strarr(N) & obj_name=strarr(N) & paran=fltarr(N) & rotan=fltarr(N) & obj_name=strarr(N) & constan=131.5
;apert=fix(findgen(16)+4)
apert=12
pi=3.14159265359d

for i=0,N-1 do begin
  h=headfits(files[i])
  obj_name[i]=sxpar(h,'OBJECT')
  type[i]=sxpar(h,'IMAGETYP')
  pol[i]=sxpar(h,'POLAMODE')
  his[i]=sxpar(h,'CHANGES')
  paran[i]=sxpar(h,'PARANGLE')
  rotan[i]=sxpar(h,'ROTANGLE')
endfor

xs=sxpar(h,'NAXIS1') & ys=sxpar(h,'NAXIS2')

obj_files=where(obj_name eq '2014A4  ' , obj_i)
bias_files=where(type eq 'bias', bias_i)
flat_files=where((obj_name eq 'sunsky polarization'), flat_i)


;f_i=file_test(path+'SBias.fit')
;if f_i eq 0 then mkbias, path, 'SBias.fit', files[bias_files], 0, bias
f_i=file_test(path+'SFlat_'+pol_mode[0]+'.fit')
if f_i eq 0 then begin
  for i=0,2 do begin
    flat_1=where(pol[flat_files] eq pol_mode[i])
    ;mkflat, path, 'SFlat_'+pol_mode[i]+'.fit', files[flat_files[flat_1]], 0, dir+'SBias.fit'
    flat_for_pol, files[flat_files[flat_1]], path+'SFlat_'+pol_mode[i]+'.fit'
  endfor
endif

;bias=readfits(path+'SBias.fit')
pos=fltarr(4,4) & bias1=fltarr(4,20,20)
pos[0,*]=[0,19,0,19] & pos[1,*]=[xs-20,xs-1,0,19] & pos[2,*]=[0,19,ys-20,ys-1] & pos[3,*]=[xs-20,xs-1,ys-20,ys-1]
for i=0,2 do begin
  flat=readfits(path+'SFlat_'+pol_mode[i]+'.fit')
  for j=i,N_elements(obj_files)-1,3 do begin
    tmp=readfits(files[obj_files[j]],head)
    if his[obj_files[j]] ne 'Reduced ' then begin
      for l=0,3 do bias1[l,*,*]=tmp[pos[l,0]:pos[l,1],pos[l,2]:pos[l,3]]
      bias=mean(bias1)
      tmp=(tmp-bias)/flat
      sxaddpar, head, 'CHANGES', 'Reduced', format='(A7)', after='COMMENT'
      Z=where(tmp lt 0, ind)
      if ind gt 0 then tmp[Z]=0
      writefits, files[obj_files[j]], tmp, head
    endif
  endfor
endfor


img=fltarr(obj_i/3,xs,ys) & tpm=fltarr(xs,ys) & z=fltarr(obj_i/3)

x1=500 & y1=500 & w=100 & pol_img=fltarr(3,xs,ys)

for k=0,2 do begin
  for i=0,obj_i-1,3 do begin
    img[i/3,*,*]=readfits(files[obj_files[i+k]],h,/silent)
    z[i/3]=sxpar(h,'Z')
  endfor
  for i=0,obj_i-1,3 do begin
      tmp[*,*]=img[i/3,*,*]
      zero=where(tmp lt 0, ze)
      if ze gt 0 then tmp[zero]=0
      robomean, tmp((x1-w):(x1+w),(y1-w):(y1+w)), 3, .5, avg, avd, std
      tmp=tmp-avg-1*std
      zero=where(tmp lt 0, ze)
      if ze gt 0 then tmp[zero]=0
      x = 1.0/cos(z[i/3]/(180/!PI))-1
      am = float(1.0+(0.9981833d0-(0.002875d0+0.0008083d0*x)*x)*x)
      img[i/3,*,*]=tmp*am
      pol_img[k,*,*]=pol_img[k,*,*]+img[i/3,*,*]
  endfor
endfor

U=fltarr(xs,ys) & Q=fltarr(xs,ys) & P=fltarr(xs,ys) & PAtg=fltarr(xs,ys)
U[*,*]=(2*pol_img[1,*,*]-pol_img[0,*,*]-pol_img[2,*,*])/(pol_img[0,*,*]+pol_img[1,*,*]+pol_img[2,*,*])*100
for i=0,xs-1 do for j=0,ys-1 do Q[i,j]=(pol_img[2,i,j]-pol_img[0,i,j])/(sqrt(3)*(pol_img[0,i,j]+pol_img[1,i,j]+pol_img[2,i,j]))*100
P=sqrt(U^2+Q^2)
for i=0,xs-1 do for j=0,ys-1 do PAtg[i,j]=paran[0]-rotan[0]+constan-0.5*calc_atan(U[i,j],Q[i,j])

mnogo=where(P gt 100, im)
if im gt 0 then P[mnogo]=0
writefits, path+'result.fts', P
end

comets, DIR='d:\Observations\RAW\BTA\s151105\', NAME='2014A4'

end