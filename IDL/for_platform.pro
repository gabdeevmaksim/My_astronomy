pro for_platform

img=readfits('d:\Observations\For_atrometr.fts',h)
RA=[76.377589d,76.354779d,76.342322d] & Dec=[52.831104d,52.840172d,52.828804d]
;RA=[76.377d,76.354d,76.342d] & Dec=[52.831d,52.840d,52.828d]
X=[240.,501.,624.] & Y=[321.,169.,383.]

STARAST,ra,dec,x,y,hdr=h
;XYAD, h, x[1],y[1],R,D,/print

writefits, 'd:\Observations\For_atrometr1.fts', img, h

kxy=readfits('d:\Observations\k_xy.fts', h1)
help, kxy
print, kxy
end