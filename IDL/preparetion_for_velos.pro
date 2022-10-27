pro preparetion_for_velos, WDIR=wdir, SUBTR=subtr

files=file_search(wdir+'*.txt', count=count)
tmp=double(read_table(files[0]))
R=where(((tmp[0,*]-4050) le 0.5) and ((tmp[0,*]-4050) ge 0), ind)
a=size(tmp) & Nx=a[2] & k=2
r=file_test(wdir+'velos.sav')
if r eq 0 then begin
  velos=dblarr((count)+2, Nx-R[0]-10); changed
  velos[0,*]=tmp[0,R:Nx-11]
  ;window, 3
  ;plot, velos[0,a[2]-1], /nodata, xrange=[0,2+count*0.1]
  for q=0,count-1,1 do begin
    print, k-1, ' spectra'
    ;if q ne 16 then begin
    spectra=double(read_table(files[q])) & b=size(spectra)
    ;for j=2,Nx-3 do if spectra[1,j] gt (spectra[1,j-2]+spectra[1,j+2]) then spectra[1,j]=(spectra[1,j-2]+spectra[1,j+2])/2
	velos[k,*]=smooth(spectra[1,R:Nx-11],5)
    window, 2
    plot, velos[0,*], velos[k,*], xst=1
    result=lowess(velos[0,*], velos[k,*],Nx/8,1,3)
    for j=0,3 do begin
      robomean, velos[k,*]-result, 3, 0.5,avg,rms
      RR=where((velos[k,*]-result) gt rms, ind)
      if ind gt 1 then velos(k,R)=result(R)
      result=lowess(velos[0,*], velos[k,*],Nx/8,1,3)
    endfor
    oplot, velos[0,*], result
    velos[k,*]=velos[k,*]/result
    k++
    ;endif
  endfor

save, velos, filename=wdir+'velos.sav'
endif else restore, wdir+'velos.sav'

window, 3
plot, velos[0,*],velos[1,*], yrange=[0,2+count/2*0.3], xrange=[4000,7300], /nodata
k=N_elements(velos[*,0])-1
;R=where(total(velos[*,*],1) eq max(total(velos[*,*],1)))
velos[1,*]=velos[2,*]
for q=1,k do oplot, velos[0,*], velos[q,*]+(q-1)*0.3
openw, lun, wdir+'spectra.dat', /get_lun
N=N_elements(velos[0,*])-1
print, N+1
k=N_elements(velos[*,0])-1
for q=0,N do begin
  R=where(velos[*,q] lt 0, ind)
  if ind gt 0 then velos[R,q]=1
  printf, lun, velos[*,q], format='(F7.2,1X,52(F9.4,1X))'
endfor
free_lun, lun

end
preparetion_for_velos, WDIR='d:\Observations\Processed\BTA\s180411\IPHAS0528\'
end