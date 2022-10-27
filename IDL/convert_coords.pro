pro convert_coords

if file_test('e:\Observations\ShC280\Coords_te.sav') eq 0 then begin
  te=ascii_template('e:\Observations\ShC280\Coords.txt')
  save, te, FILENAME='e:\Observations\ShC280\Coords_te.sav'
endif else restore, 'e:\Observations\ShC280\Coords_te.sav'
t=read_ascii('e:\Observations\ShC280\Coords.txt',template=te)
N=N_elements(t.field1)
openw, 1, 'e:\Observations\ShC280\Coords.dat'
for i=0,N-1 do begin  
  RA=(t.field2[i]+t.field3[i]/60.+t.field4[i]/3600.)*15
  Dec=t.field5[i]+t.field6[i]/60.+t.field7[i]/3600.
  printf, 1, t.field1[i], RA, Dec, format='(A10,2X,F9.5,2X,F9.5)'
endfor
close, 1
end 