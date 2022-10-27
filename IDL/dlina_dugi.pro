pro dlina_dugi

R=0.7*6.9551e5 & d=5000.
L=2.*!Pi*R/180.*asin(d/(2*R))*57.3

L1=!Pi*R/180*acos(1-(d^2/(2*R^2)))*57.3
print, L, L1



end