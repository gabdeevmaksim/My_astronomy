pro plot_img

DIR='d:\Observations\RAW\Zeiss\161230\CSS110114\'
file_img=file_search(DIR+'*.fts')
img=readfits(file_img[0],h)
coord=read_table(DIR+'stars_coord.txt') 
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2') & N=size(coord)
coord=fltarr(3,2) & coord[*,0]=[524.000,  497.946,  523.000] & coord[*,1]=Ny-[489.000,  520.474,  689.000]
set_plot, 'ps'
device, file=DIR+'map.eps', xsize=8, ysize=8, yoff=1,  /portrait
img=mirror_x(img)
av=median(img)
;cgplot, findgen(Nx), findgen(Ny), /nodata
tv, 255-bytscl(img, 0, av*1.5), 0, 0, xsize=8, ysize=8, /centimeters 
;arrow, .9, .8, .90, .950, /normalized, Thick=3
;arrow, .9, .8, .75, .8, /normalized, Thick=3
;xyouts, .92, .940, 'N', /normal, chart=2
;xyouts, .73, .75, 'E', /normal, chart=2
;xyouts, .1, .9, '6x6', /normal, chart=2
;arrow, .125, .93, .126, .937, /normalized, Thick=2, hsize=0
;arrow, .18, .93, .181, .937, /normalized, Thick=2, hsize=0
for i=0,N[1]-1 do begin
  cgPlotS, CIRCLE(coord[i,0]*7.68, coord[i,1]*7.68, 100), /Device
  xyouts, coord[i,0]/Nx+.015, coord[i,1]/Ny+.015, strcompress(string(i+1),/remove_all), /normal, chart=3, chars=.75
endfor  
;cgPlotS, CIRCLE(3815, 4550, 100), /Device
;cgPlotS, CIRCLE(4350, 4600, 100), /Device
;cgPlotS, CIRCLE(3145, 5990, 100), /Device

;xyouts, .45, .59, 'Ref', /normal, chart=3, chars=.75
;xyouts, .55, .6, 'Comp1', /normal, chart=3, chars=.75
;xyouts, .41, .76, 'Comp2', /normal, chart=3, chars=.75
device, /close
set_plot, 'win'

end