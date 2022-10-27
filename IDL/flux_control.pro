pro flux_control

table=read_table('d:\Observations\Processed\BTA\CSS130605\fluxes.txt'); read a table with fluxes

cols=[1,2,12] & Nc=size(cols);  columns with a brightest stars, size of the array 
N=size(table);  determine(det) table size
Ref_flux=fltarr(N[2]);  array for referend fluxes
avgf=fltarr(Nc[1]); arr for avg fluxes
for i=0, Nc[1]-1 do begin     ;  cicle to det avarage for fluxes
  robomean, table[cols[i],N[2]-6:N[2]-1],3, 1, avg, avgdev, stddev; took 5 best dots to calc avg
  avgf[i]=avg; write avg values in the array
endfor
normal=avgf/max(avgf); normalizing to max value
!P.multi=[0,1,3] 
; ploting fluxes of brightest stars and multiplied for normalization coefficient
window, 1, title='Fluxes and avareges', xsize=1000, ysize=1000
cgplot, table[cols[0],*], psym=4, ys=1
cgoplot, table[cols[1],*], psym=1
cgoplot, table[cols[2],*], psym=2
cgplot, table[cols[0],*]/normal[0], psym=4, color='red', ys=1
cgoplot, table[cols[1],*]/normal[1], psym=1, color='red'
cgoplot, table[cols[2],*]/normal[2], psym=2, color='red'
ref_flux=(table[cols[0],*]/normal[0]+table[cols[1],*]/normal[1]+table[cols[2],*]/normal[2])/Nc[1]; calculate average fluxes changes
cgplot, ref_flux/ref_flux[0], ys=1
!P.MULTI=0
for i=0,N[1]-1 do begin
  window, i+2
  poly=goodpoly(findgen(N[2]),table[i,*]/(ref_flux/ref_flux[0]),1,3, yfit)
  cgplot, table[i,*]/(ref_flux/ref_flux[0]), ys=1
  cgoplot, yfit, color='red'
endfor
end



