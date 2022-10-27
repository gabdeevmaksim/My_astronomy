pro create_bias, path

dir=path+'Reduction\'
files=file_search(dir+'bias*.fts', count=N_bias)

tmp=readfits(files[0],h)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
ima=fltarr(Nx,Ny,N_bias)
for k=0,N_bias-1 do begin
  tmp=READFITS(files[k],h)
  ima(*,*,k)=tmp(*,*)
endfor
bias=remove_hits(ima)/N_bias
robomean,bias(Nx/2-50:Nx/2+50,Ny/2-50:Ny/2+50),3,0.5,avg_bias,rms_bias
out_str='mean bias='+string(avg_bias,format='(F6.1)')$
  +' ADU  RON='+string(rms_bias,format='(F6.2)')+' ADU'
sxaddhist,out_str,h
writefits,dir+'SBias.fts', bias, h
end
create_bias, 'f:\!!!Pract\OBSst\RAW\120124\'
end

