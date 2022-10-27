function moffat, Xval, p 

m1=p[0]+p[1]/(1+(Xval-p[3])^2/(p[2])^2)^p[4]

return, m1

end
                                  