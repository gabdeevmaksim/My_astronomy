pro spec_unit, dir=dir

files=file_search(dir+'*.txt',count=N)
tot=dblarr(N+1,2000)
for i=0,N-1 do begin
  openr, lun, files[i], /get_lun
  if i eq 0 then begin  
    tot[0:1,*]=read_table(files[i])
    tot[1,*]=smooth(tot[1,*],5)
  endif else begin
    tm=read_table(files[i])
    tot[i+1,*]=smooth(tm[1,*],5)
  endelse
  close, lun
endfor
openw, lun, dir+'spectra.dat', /get_lun
for i=0,1999 do printf, lun, tot[*,i], format='(F7.2,2X,15(E11.4,2X))'
close, lun
end
spec_unit, dir='d:\Observations\Processed\s130401\SBS 1108\'
end
