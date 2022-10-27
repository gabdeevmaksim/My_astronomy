function xy_polinom, Xval, Yval, p, X_deg=X_deg, Y_deg=Y_deg

;XVal - 2 dimension array
;p = 
;          1      2      3        4      5       6        7      8       9        10    11      12       13  14    15      16      17       18      19      20      21      22      23     24      25    26      27     28          
;model=(x^5*y+x^5*y^2+x^5*y^3)+(x^4*y+x^4*y^4+x^4*y^3)+(x^3*y+x^3*y^2+x^3*y^3)+(x^2*y+x^2*y^2+x^2*y^3)+(x*y+x*y^2+x*y^3)+(x^5*x^4+x^5*x^3+x^5*x^2+x^5*x)+(x^4*x^3+x^4*x^2+x^4*x)+(x^3*x^2+x^3*x)+x^2*x+(y^3*y^2+y^3*y)+y^2*y+y^2+x^2
k=0 & model=0.0
model+=p[0]
for i=1,X_deg do model+=p[++k]*Xval^i
for i=0,X_deg do begin
  tem1=Xval^i
  for j=1,Y_deg do begin
    tem2=Yval^j
    model+=p[++k]*tem1*tem2
  endfor
endfor
return, model

end