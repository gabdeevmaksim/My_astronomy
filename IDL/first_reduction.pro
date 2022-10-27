pro first_reduction, path, obj_name, filter

fi=fileinfo(path+'\reduction\SBias.fit')
if fi.exist eq 0 then create_red_files, DIR=path+'reduction\' 
bias=readfits(path+'\reduction\SBias.fit',h, /NO_UNSIGNED)
flat=readfits(path+'\reduction\SFlat'+filter+'.fit',h, /NO_UNSIGNED)

f_name=file_search(path+obj_name+'\*.FTS', count=count)
if count eq 0 then f_name=file_search(path+obj_name+'\*.FITS', count=count)
if n_elements(f_name) le 1 then f_name=file_search(path+obj_name+'\'+filter+'\*.FTS', count=count)
for i=0,count-1 do begin
  tmp=readfits(f_name[i],h)
  filt=strcompress(string(sxpar(h,'FILTER')), /remove_all)
  if filt eq filter then begin
    tmp=(tmp-bias)/(flat)
    R=where(tmp gt 65000, ind)
    if ind gt 0 then tmp[R]=0 
    sxaddpar, h, 'HISTORY', 'After first_reduction'
    Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
    tmp1=fltarr(Nx-20,Ny-20)
    tmp1=tmp[0:Nx-20,0:Ny-21]
    writefits, f_name[i], tmp1, h
  endif
endfor

end
  