pro plot_colors_AMstars

DIR='c:\Users\gamak\Documents\Conferences\2019, Shamahy\'
restore, DIR+'mag.sav'
restore, DIR+'magm15.sav'
restore, DIR+'magp03.sav'
restore, DIR+'stars_temp.sav'
restore, DIR+'color.sav'
stars=read_ascii(DIR+'stellar_colors_470-540-656.dat',template=temp)
col_shi=read_table(DIR+'color.dat')
col_SDSS=read_table('e:\Observations\MMPP\specSDSS\CSS110920\colors_SDSS.dat')
cAM=fltarr(2,48)
cAM[0,*]=mag[0,*]-mag[1,*] & cAM[1,*]=mag[1,*]-mag[2,*]
temp_log=strarr(48)
temp_log[0:15]=strcompress(string(findgen(16)*500+3500),/remove_all) 
temp_log[16:31]=strcompress(string(findgen(16)*500+3500),/remove_all) 
temp_log[32:47]=strcompress(string(findgen(16)*500+3500),/remove_all) 
set_plot, 'ps'
device, file='e:\Observations\MMPP\specSDSS\CSS110920\res.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0  
cgplot, stars.field2, stars.field3, xs=1, ys=1, xr=[-1.0,1.5], yr=[-1.0,1.5], PSYM=2, SYMSIZE=0.5, xtit='470-540', ytit='540-656'
cgplot, col_SDSS[0,*], col_SDSS[1,*], color='red', /overplot, PSYM=2
cgplot, [-1.5,-.175], 1.2121*[-1.5,-.175]+0.2121, /overplot
cgplot, [-.175, 0],11.4286*[-.175, 0]+2, /overplot
;cgplot, color[0,*], color[1,*], color='red', /overplot, PSYM=2
;cgplot, cAM[0,*], cAM[1,*], color='red', /overplot, PSYM=2
;cgplot, cAMm15[0,*], cAMm15[1,*], color='green', /overplot, PSYM=2
;cgplot, cAMp03[0,*], cAMp03[1,*], color='blue', /overplot, PSYM=2
;for i=4,41,3 do xyouts, color[0,i/3], color[1,i/3], temp_log[i], charth=2
device, /close
set_plot, 'win'
end