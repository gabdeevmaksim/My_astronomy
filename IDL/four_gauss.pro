function four_gauss, Xval, p;, Yval=yval, ERRval=errval

;model=y0+(A/(w*sqrt(!Pi/2)))*exp(-2(x-xc)/w)^2)
;y0=p[0], A=p[1], w=p[2], xc=p[3]

g1=(p[1]/(p[2]*sqrt(!Pi/2)))*exp(-2*((Xval-p[3])/p[2])^2)

g2=(p[4]/(p[5]*sqrt(!Pi/2)))*exp(-2*((Xval-p[6])/p[5])^2)

g3=(p[7]/(p[8]*sqrt(!Pi/2)))*exp(-2*((Xval-p[9])/p[8])^2)

g4=(p[10]/(p[11]*sqrt(!Pi/2)))*exp(-2*((Xval-p[12])/p[11])^2)

model=p[0]+g1+g2+g3+g4
return, model

end