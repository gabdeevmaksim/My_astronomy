pro wave_to_velos, DIR=DIR, gamma=gamma

files=file_search(DIR+'*.txt', count=c)
lambda0=[4686,4861]
for i=0,c-1 do begin
  t=read_table(files[i])
  lambda1=(gamma/(imsl_constant('c')/1000)+1)*lambda0
  for k=0,1 do begin
    r=where(abs(t[0,*] - lambda0[k]) lt 0.42,ind)
    n1=r[0]+findgen(100)-49
    r1=where(t[1,n1] eq max(t[1,n1]),ind)
    n2=n1[0]+r1[0]+findgen(100)-49
    v=(t[0,n2]-lambda1[k])/lambda1[k]*imsl_constant('c')/1000
  openw, 1, DIR+strcompress(string(lambda0[k]),/remove_all)+string(i+1)+'.dat'
  for j=0,99 do printf, 1, v[j], t[1,n2[j]], format='(F9.2,2X,E0)'
  close, 1
  endfor
endfor  
end
wave_to_velos, DIR='d:\Observations\Processed\BTA\s110921\OT J071126+440405\3D Dop\', gamma=61.
end
  
    
  