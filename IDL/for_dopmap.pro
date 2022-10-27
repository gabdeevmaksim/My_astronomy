pro for_dopmap, RDIR=rdir, WDIR=wdir, INP_DAT=inp_dat

if inp_dat eq 0 then begin
  table=read_table(rdir+'spectra.dat')
  phase=read_table(rdir+'phase_all.dat',/double)
  a=size(table)
  N=a(2) & column=a(1)
  openw, lu, strmid(wdir,0,18)+strmid(wdir,18,9)+'.dat', /get_lun
  for i=2,column-1 do begin ; change i=2 to i=1, because of spectra.dat
    if i lt 11 then name=strcompress('f0'+string(i-1)+'.txt',/remove_all) else $ ; i-1 to i and i lt 11
                  name=strcompress('f'+string(i-1)+'.txt',/remove_all) ; i-1 to i
    openw, lun, wdir+name, /get_lun
    for j=0,N-1 do printf, lun, table[0,j], table[i,j], format='(F7.2,2X,E12.4)'
    free_lun, lun
    printf, lu, name, phase[i-2], format='(A7,2X,F7.5)'; change i-2 to i-1
  endfor
free_lun, lu
endif
if inp_dat eq 1 then begin
  phase=read_table(rdir+'phase_all.dat',/double)
  files=file_search(RDIR+'*.txt',count=N)
  table0=read_table(files[0], /double) & S=size(table0)
  openw, 1, strmid(wdir,0,18)+strmid(wdir,18,8)+'.dat'
  for i=0, N-1 do begin
    table=read_table(files[i])
    if i lt 9 then name=strcompress('f0'+string(i+1)+'.txt',/remove_all) else $ 
                  name=strcompress('f'+string(i+1)+'.txt',/remove_all)
    openw, 2, wdir+name
    for j=0,S[2]-1 do printf, 2, table[0,j], table[1,j], format='(F7.2,2X,E12.4)'
    close, 2
    printf, 1, name, phase[i]+.18, format='(A7,2X,F7.5)'
  endfor
close, 1  
endif
end
for_dopmap, RDIR='d:\Observations\Processed\BTA\s180411\IPHAS0528\', WDIR='c:\IDL_lib\dopmap\IPHAS0528_18\', INP_DAT=1
end