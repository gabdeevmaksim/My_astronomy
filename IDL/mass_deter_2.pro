pro mass_deter_2 

ie=[50.,56.,60.] & K2=[239.,265.,291.] & P=0.0893869d & f2=fltarr(N_elements(ie))
Nm=27 & m2=dindgen(Nm)/100+0.03d 
Nq=50 & q1=dindgen(Nq)/100+.01d
openw, 1, 'C:\Users\gamak\Documents\Papers\MT_Dra\m1.txt'
printf, 1, '      ie       ,      M1      ,       M2       ,       q       ,        Rl2     '  
for i=0,N_elements(ie)-1 do begin
  f2[i]=(1.038e-7)*P*K2[i]^3
  print, 'f1', f2[i]
  for j=0,Nm-1 do begin
    for k=0,Nq-1 do begin
      f=m2[j]*(sin(2*!Pi*(ie[i]/360.)))^3/(q1[k]*(1+q1[k])^2)
      
      if abs(f-f2[i]) lt .001 then begin
        Rl2=.49*q1[k]^(2./3.)/(.6*q1[k]^(2./3.)+alog(1+q1[k]^(1./3.)))
        m1=m2[j]/q1[k] & G=6.6740831e-11
        a=K2[i]*P*86400/(2*!Pi)/sin(2*!Pi*(ie[i]/360.))/6.9551e5
        a=(G*(m1+m2[j])*1.9885e30*(P*86400)^2/(4*!Pi^2))^(1./3.)/6.9551e8
        print, a;, a1
        print, ie[i], m2[j], q1[k], Rl2, abs(f-f2[i])
        printf, 1, ie[i], m2[j]/q1[k], m2[j], q1[k], Rl2*a
      endif
    endfor
  endfor
endfor
close, 1
end
    
