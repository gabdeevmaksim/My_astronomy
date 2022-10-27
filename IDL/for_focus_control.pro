pro for_focus_control

DIR='d:\Observations\RAW\MMPP\20190702\For_focus\'

files=file_search(DIR+'*.fits', count=N)
FZS=create_struct('Filter',strarr(N),'Z',fltarr(N),'X_s',fltarr(N),'Y_s',fltarr(N))
apert=12
IDPSF=0
restore, filename=DIR+'FZS.sav'
;for i=56,N-1 do begin
;  print, i
;  img=readfits(files[i],h)
;  type=strcompress(sxpar(h,'EXPTYPE'), /remove_all)
;  print, type, strlen(type)
;  window, 1, xs=1024, ys=1024
;  display_image, img, 1, options={range:[2100,10000],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L};, /modify_opt;
;  click_on_max, img, x_ref, y_ref, mark=1
;  aper, img, x_ref, y_ref, mags, errap, sky, skyerr, 1.1, apert, [apert+1,apert+2],[0,56000]
;  getpsf, img, x_ref, y_ref, mags, sky, 1., 1.1, gauss, psf, IDPSF, 12, 4, DIR+'psf.fts'
;  FZS.filter[i]=sxpar(h,'FILTER')
;  FZS.Z[i]=sxpar(h,'Z')
;  FZS.X_s[i]=gauss[3]
;  FZS.Y_s[i]=gauss[4]
;  save, FZS, filename=DIR+'FZS.sav' 
;endfor
cgplot, FZS.Z, FZS.X_s, xs=1, ys=1, PSYM=4, yrange=[0.8,1.7]
xyouts, FZS.Z, FZS.X_s, FZS.filter, color=0

end