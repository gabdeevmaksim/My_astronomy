pro focus

dir='c:\Users\Maxim\IDLWorkspace\Default\'
dat=read_table(dir+'focus.dat')

ff=goodpoly(dat[0,*],dat[1,*],2,3,yfi,newx,newy)
peak=-ff[1]/ff[2]/2
x=findgen(300)/50+dat[0,0]
y=poly(x,ff)
plot, dat[0,*], dat[1,*], xst=1, psym=6, title='min on'+peak, yrange=[min(dat[1,*])-0.5,max(dat[1,*]+0.5)]
oplot, x, y;, linestyle=1
arrow, peak, max(dat[1,*]+0.5), peak, min(dat[1,*])-0.5, /data
print, peak
end