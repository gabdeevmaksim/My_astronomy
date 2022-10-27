pro spec_phase, DIR=dir, LAMBDA=lambda

restore, dir+'velos.sav'
restore, dir+'phase.sav'

a=size(phase) & N=a[2]-1
for i=0,9 do begin
  R=where(abs(ph-0.1*i) eq min(abs(ph-0.1*i)))
  if i eq 0 then begin
    window, 1
    R1=where(abs(velos[0,*]-lambda[0]) eq min(abs(velos[0,*]-lambda[0])))
    R2=where(abs(velos[0,*]-lambda[1]) eq min(abs(velos[0,*]-lambda[1])))
    plot, velos[0,R1:R2], velos[R+2,R1:R2], xst=1, yrange=[0,15]
    xyouts, velos[0,R1]+2, velos[R+2,R1]+0.1, ph[R]
  endif else begin
    oplot, velos[0,R1:R2], velos[R+2,R1:R2]+1*i
    xyouts, velos[0,R1]+2, velos[R+2,R1]+0.1+1*i, ph[R]
  endelse
endfor
end
spec_phase, DIR='f:\!!!Pract\OBSst\Processed\s110920\OT J071126+440405\', LAMBDA=[4600,5000]
end