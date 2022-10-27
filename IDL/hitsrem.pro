pro hitsrem, WDIR=wdir, FILE_NAME=file_name, OBJ_POS=obj_pos

;Keyword:
;NOISE - it measuring in median values of column
;
;Notes:
;Use only with Bias-subtructed images

image=readfits(file_name,h)
Nx=sxpar(h,'naxis1') & Ny=sxpar(h,'naxis2')

for i=0,Nx-1 do begin
  mn=median(image(i,*))
  robomean, image(i,*), 3, 0.5, avg, avgdev, stddev
  ;R=where(image[i,obj_pos-5:obj_pos+5] eq max(image[i,obj_pos-5:obj_pos+5]),ind)
  ;if ind gt 1 then noise=image[i,obj_pos]/mn else noise=image[i,obj_pos+R-11]/mn
  noise=max(image[i,obj_pos-3:obj_pos+3])/mn*100; changed
  for j=0,Ny-1 do begin
    if image(i,j)/mn gt noise then image(i,j)=mn
  endfor
endfor

tmp=sxpar(h,'FILE')
file=strmid(tmp,0,9)
sxaddpar,h,'IMAGETYP', 'obj_rh'
writefits, wdir+file+'_rh.fts', image(0:Nx-2,*), h
end
