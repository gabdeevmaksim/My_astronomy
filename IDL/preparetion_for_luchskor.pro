pro preparetion_for_luchskor, WDIR=wdir

files=file_search(wdir+'*.txt', count=count)
print, count/2
tmp=double(read_table(files[0]))
R=where(((tmp[0,*]-4000) le 0.7) and ((tmp[0,*]-4000) ge 0), ind)
a=size(tmp) & Nx=a[2] & k=1
;goto, cont 
velos=dblarr((count/2), a[2]-R[0]); changed
velos[0,*]=tmp[0,R:a[2]-1]
window, 3
plot, velos[0,*], /nodata, xrange=[0,2+count*0.1]
for q=2,count-1,2 do begin
  print, k, ' spectra'
  spectra=double(read_table(files[q]))
  for j=2,Nx-3 do if spectra[1,j] gt (spectra[1,j-2]+spectra[1,j+2]) then spectra[1,j]=(spectra[1,j-2]+spectra[1,j+2])/2
  velos[k,*]=smooth(spectra[1,R:a[2]-1],5)
  window, 2
  plot, velos[0,*], velos[k,*], xst=1
  result=lowess(velos[0,*], velos[k,*],Nx/3,5,1)
  for j=0,3 do begin
    robomean, velos[k,*]-result, 3, 0.5,avg,rms
    RR=where((velos[k,*]-result) gt rms, ind)
    if ind gt 1 then velos(k,R)=result(R) 
    result=lowess(velos[0,*], velos[k,*],Nx/3,5,1)
  endfor
  oplot, velos[0,*], result
  velos[k,*]=velos[k,*]/result
  k++
endfor
save, velos, filename=wdir+'velos.sav'
;cont:
restore, wdir+'velos.sav'
;restore, wdir+'shift.sav'
window, 3
plot, velos[0,*],velos[0,*], /nodata, yrange=[0,2+count/2*0.3], xrange=[4000,7300]
k=N_elements(velos[*,0])-1
for q=1,k do oplot, velos[0,*], velos[q,*]+(q-1)*0.3  
openw, lun, wdir+'spectra.dat', /get_lun
N=N_elements(velos[0,*])-1
print, N+1
k=N_elements(velos[*,0])-1
for q=0,N do begin
  R=where(velos[*,q] lt 0, ind)
  if ind gt 0 then velos[R,q]=1
  printf, lun, velos[*,q], format='(F7.2,1X,26(F7.4,1X))'
endfor
free_lun, lun

end
preparetion_for_luchskor, WDIR='f:\!!!Pract\OBSst\Processed\s110920\OT J003828.7+25092\'
end