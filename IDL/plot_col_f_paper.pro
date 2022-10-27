pro plot_col_f_paper

files=['e:\Observations\MMPP\20191206\CSS131014_color.fits','e:\Observations\MMPP\20200321\CSS110920_color.fits']
restore, 'E:\Observations\MMPP\stars_temp.sav'
stars=read_ascii('E:\Observations\MMPP\stellar_colors_470-540-656.dat',template=temp)
for i=0,2 do begin
  fxbopen, unit, files[0], i+1, h1
  if i eq 0 then begin
    color1=fltarr(3,3,sxpar(h1,'NAXIS2'))
    ;fxbread, unit, mag470_1, 'MAG_STD_470_PSF'
  endif
  fxbread, unit, c, '470-540_PSF'
  color1[i,0,*]=c
  fxbread, unit, c, '540-656_PSF'
  color1[i,1,*]=c
  fxbread, unit, c, 'MAG_STD_540_PSF'
  color1[i,2,*]=c
  fxbclose, unit
endfor  
for i=0,2 do begin
  fxbopen, unit, files[1], i+1, h2
  if i eq 0 then begin
    color2=fltarr(3,3,sxpar(h2,'NAXIS2'))
    ;fxbread, unit, mag470_2, 'MAG_STD_470_PSF'
  endif
  fxbread, unit, c, '470-540_PSF'
  color2[i,0,*]=c
  fxbread, unit, c, '540-656_PSF'
  color2[i,1,*]=c
  fxbread, unit, c, 'MAG_STD_540_PSF'
  color2[i,2,*]=c
  fxbclose, unit
endfor  
;rr1=where(mag470_1 le 20, ind)
;rr2=where(mag470_2 le 20, ind)
;set_plot, 'ps'
;device, file='e:\Observations\MMPP\for_paper.eps', /portrait, xsize=20, ysize=20, yoff=0, xoff=0
;cgplot, stars.field2, stars.field3, xs=1, ys=1, xr=[-.7,1.], yr=[-.9,1.2], PSYM=2, SYMSIZE=0.5, xtit='SED470-SED540', ytit='SED540-SED656'
;  for i=0,2 do begin 
;    cgplot, color1[i,0,rr1], color1[i,1,rr1], psym=4, symsize=0.5, /overplot
;    cgplot, color2[i,0,rr2], color2[i,1,rr2], psym=4, symsize=0.5, /overplot    
;  endfor
;device, /close 
;set_plot, 'win'

;r1=where(mag470_1 gt 17.5 and mag470_1 lt 18.0, ind)
;cgplot, [-1.5,1.5],[-1.5,1.5], xs=1, ys=1, /nodata
;for i=0,ind-1 do begin
; for j=0,2 do begin
;  print, mag470_1[r1[i]], color1[j,0,r1[i]], color1[j,1,r1[i]]
;  cgplot, color1[j,0,r1], color1[j,1,r1], psym=4, /overplot
;  ;print, stddev(color1[*,0,r1[i]]), stddev(color1[*,1,r1[i]])
; endfor
;endfor

N_o=sxpar(h2,'NAXIS2')
av_470=fltarr(N_o) & av_540=fltarr(N_o) & av_656=fltarr(N_o)
for i=0,N_o-1 do begin
  av_470[i]=mean(color2[*,2,i]+color2[*,0,i])
  av_656[i]=mean(color2[*,2,i]-color2[*,1,i])
  av_540[i]=mean(color2[*,2,i])
endfor

av_470[*]=av_470[*]-av_540[*]
av_656[*]=av_656[*]-av_540[*]
av_540[*]=av_540[*]-av_540[*]
;print, 1
openw, 1, 'e:\Observations\MMPP\20200321\sum_col.dat'
printf, 1, av_470, format='('+strcompress(string(N_o),/remove_all)+'(F7.4,2X))'
printf, 1, av_540, format='('+strcompress(string(N_o),/remove_all)+'(F7.4,2X))'
printf, 1, av_656, format='('+strcompress(string(N_o),/remove_all)+'(F7.4,2X))'
close, 1
end 