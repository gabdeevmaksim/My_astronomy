pro plot_sdss_colors

DIR='d:\Papers\CVns\'
fits_open, DIR+'CVns_1_Dedulek.fit', fcb
ftab_ext, fcb, 'u,g,r,i', u,g,r,i
set_plot, 'ps'
device, file=DIR+'_res.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0  
cgplot, g-r, u-g, xs=1, ys=1, xtit='g-r', ytit='u-g', psym=3
cgplot, r-i, g-r, xs=1, ys=1, xtit='r-i', ytit='g-r', psym=3
device, /close
set_plot, 'win'
fits_close, fcb
end