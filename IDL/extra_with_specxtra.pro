pro extra_with_specxtra, RDIR, Nfold=Nfold

for j=0,Nfold-1 do begin
  DIR=RDIR+'0'+strcompress(string(j+1),/remove_all)+'\'
  o_file=file_search(DIR+'corr_o*.fts',count=N)
  fl_file=file_search(DIR+'corr_f*.fts', count=N)
  for i=0,N-1 do begin
    o=readfits(o_file[i],H_o)
    fl=double(readfits(fl_file[i],H_fl))
    ;m=mean(fl[900:1000,35:45]) & fl=fl/m
    ;o=o/fl
    A=size(o)
    XS=A[1] & YS=A[2]
    restore, DIR+'linear_coef.sav'
    sxaddpar, H_o, 'NAXIS1', XS
    sxaddpar, H_o, 'CDELT1', dWl
    sxaddpar, H_o, 'CRVAL1', Wl_min
    sxaddpar, H_o, 'CRPIX1', 1
    sxaddpar, H_o, 'HISTOR', 'Corrected & flated'
    if i lt 9 then name='0'+strcompress(string(i+1),/remove_all)+'.fts' else name=strcompress(string(i+1),/remove_all)+'.fts'
    par_gauss=read_table(DIR+'par_gauss.txt')
    file_mkdir, DIR+strmid(name,0,2)
    wdir=DIR+strmid(name,0,2)+'\'
    writefits, wDIR+name, o, H_o
    set_plot, 'PS'
    spextra_proc, wDIR+name, par_gauss, foncont=[2,15.,29.,51.,64.], par_smo=[2.,2.], wdir=wdir, /plot, lim_fwhm=[2.,8.], lim_cent=[9.,9.], aper=[1,3,3]
    set_plot, 'win'
  endfor
endfor
end
extra_with_specxtra, 'd:\Observations\Processed\BTA\s151107\standart_0\', Nfold=5
end