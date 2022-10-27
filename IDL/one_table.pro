pro one_table, DIR=dir, NAME=name

;set JDorPH equal 1 if want phases, set 0 if want Julian Dates
Ns=0 & JDorPH=0 & dates=['121120','130207','150117','150118'];['120122','120124','121015','121018','121120','121212','121216','150117','150118']
b=size(dates)
for i=0,b[1]-1 do begin
  path=dir+dates[i]+'\'+name
  if JDorPH eq 1 then begin
    JD=read_table(path+'\phase_all.dat', columns=1, /double)
  endif else JD=read_table(path+'\JD.dat', columns=1, /double)
  Mag=read_table(path+'\phot.dat',/double)
  a=size(Mag) & N=a[2] & c=a[1]
  openw, lun, path+'\'+name+'.dat', /get_lun
  if c eq 3 then begin
    for j=0,N-1 do printf, lun, JD[j], Mag[0,j], Mag[2,j], format='(F11.5,2X,2(F6.3,2X))'
  endif else begin
    for j=0,N-1 do printf, lun, JD[j], Mag[0,j], format='(F11.5,2X,F6.3)'
  endelse
  free_lun, lun
endfor
if b[1] eq 1 then goto, fin
for i=0,b[1]-1 do begin
  path=dir+dates[i]+'\'+name+'\'+name+'.dat'
  temp=read_table(path, /double)
  a=size(temp) & Ns=Ns+a[2]
endfor
table=dblarr(2,Ns) & N=0
for i=0,b[1]-1 do begin
  path=dir+dates[i]+'\'+name+'\'
  temp=read_table(path+name+'.dat', /double)
  a=size(temp) & Ns=a[2]+N
  table[*,N:Ns-1]=temp[0:1,*] & N=Ns
endfor
if JDorPH eq 1 then begin
  openw, lun, path+'\phot&phase.dat', /get_lun
 endif else begin
  openw, lun, path+'\phot_all.dat', /get_lun
endelse
for i=0,Ns-1 do printf, lun, table[0,i], table[1,i], format='(F11.5,2X,F6.2)'
free_lun, lun
fin:
end
one_table, DIR='d:\Observations\RAW\Zeiss\', NAME='IPHAS 0528_B'
end


