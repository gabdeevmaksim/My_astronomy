function gauss_origin, Xval, p;, Yval=yval, ERRval=errval

;model=y0+(A/(w*sqrt(!Pi/2)))*exp(-2(x-xc)/w)^2)
;y0=p[0], A=p[1], w=p[2], xc=p[3]

model=p[0]+(p[1]/(p[2]*sqrt(!Pi/2)))*exp(-2*((Xval-p[3])/p[2])^2)

return, model

end