QC=read_table('c:\Users\Maxim\IDLWorkspace\Default\QC.txt')
window, 1, title='Quantum Efficiency Curve'
plot, QC[0,*], QC[1,*], psym=1, symsize=1
ff=goodpoly(QC[0,*],QC[1,*],5,1,yfit,xnew,ynew)
print, ff, max(QC[0,*]), min(QC[0,*])
x=findgen((max(QC[0,*]-min(QC[0,*]))/0.1))*0.1+QC[0,0]
QCnew=poly(x,ff)
oplot, x,QCnew, color=130
end