pro test_moffat

profil = read_table('c:\Users\gamak\Documents\Papers\MT_Dra\skyline06.csv')
set_plot, 'win'
window, 1
cgplot, profil[0,*],profil[1,*]
param = [0,10000,5,10,1.5]
parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 5)
parinfo(*).value = param
parms = MPFITFUN('moffat', profil[0,*],profil[1,*], ERR=0, parinfo=parinfo, yfit=yy, /quiet)
cgplot, profil[0,*],yy,color = 'red', thick=3, /overplot
print, parms
param = [0,10000,5,10]
parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 4)
parinfo(*).value = param
parms = MPFITFUN('gauss_origin', profil[0,*],profil[1,*], ERR=0, parinfo=parinfo, yfit=yy1, /quiet)
cgplot, profil[0,*],yy1,color = 'blue', /overplot
print, parms
end
