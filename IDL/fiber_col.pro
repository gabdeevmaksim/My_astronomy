pro fiber_col

tab=read_table('c:\Users\Maxim\IDLWorkspace\Default\Fiber2.dat')

cgplot, tab[0,*], tab[1,*], xs=1, ys=1, psym=4

end 