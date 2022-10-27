pro plot_CV

cv=read_table('e:\Observations\RTT150\T20200422\111.csv', /double)

print, stddev(cv[3,*],/double), stddev(cv[5,*],/double), stddev(cv[6,*],/double)

!P.multi=[0,1,3]
set_plot, 'ps'
device, file='e:\Observations\RTT150\T20200422\111.ps', /portrait, xs=16, ys=24, xoff=0, yoff=0
cgplot, cv[0,*], cv[3,*], xs=1, ys=1;, yr=[18.5,17.9], psym=4
cgplot, cv[0,*], cv[5,*], xs=1, ys=1;, /overplot, psym=2
cgplot, cv[0,*], cv[6,*], xs=1, ys=1;, /overplot, psym=5
device, /close
set_plot, 'win'

end
