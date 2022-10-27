pro MMPP_phot, DIR, obj_name

filter=['470','540','656']
files=file_search(DIR+obj_name+'/*.FITS',count=N)
h_tmp=headfits(files[0])
t=sxpar(h_tmp,'HISTORY')
if strlen(t) eq 12 then for i=0,2 do first_reduction, DIR, obj_name, filter[i]
openw, 33, DIR+obj_name+'\fluxes.txt'
for i=0,N-1 do begin
  img=readfits(files[i],h)
  img=mirror_y(img)
  if i eq 0 then begin
    if file_test(DIR+obj_name+'/stars_coord.txt') eq 0 then begin
      window, 1, xs=1005, ys=1004
      display_image, img, 1, options={range:[10,1000],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
      click_on_max, img, x_ref, y_ref, mark=1
      N_obj=n_elements(x_ref) & flux=fltarr(N,N_obj)
      openw, 44, DIR+obj_name+'\stars_coord.txt'
      printf, 44, x_ref, format='('+strcompress(string(N_obj))+'(F6.2,2X))'
      printf, 44, y_ref, format='('+strcompress(string(N_obj))+'(F6.2,2X))'
      close, 44
    endif else begin
      x_y=read_table(DIR+obj_name+'/stars_coord.txt') 
      x_ref=x_y[*,0] & y_ref=x_y[*,1] 
      N_obj=n_elements(x_ref) & flux=fltarr(N,N_obj)  
    endelse
  endif
  window, 1, xs=1005, ys=1004
  display_image, img, 1, options={range:[10,1000],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
  crosses, img, x_ref, y_ref, /EXISTING
  apert=12
  for j=0,N_obj-1 do begin
    centrod, img, x_ref[j], y_ref[j], apert, apert+2, apert+4, 0, x, y, coun
    x_ref[j]=x & y_ref[j]=y
  endfor  
  aper, img, x_ref, y_ref, fl, efl, sky, skyerr, 2.1, apert, [apert+1,apert+2], $
      [-32767,56000],/flux;, /silent
  flux[i,*]=fl
  
  printf, 33, flux[i,*], format='('+strcompress(string(N_obj))+'(F9.2,2X))'

endfor
close, 33
colour=fltarr(3,3,N_obj)
set_plot, 'ps'
device, file=DIR+obj_name+'\'+obj_name+'.ps', /portrait,$
        xsize=16, ysize=16, yoff=4
for i=0,8,3 do begin
  colour[0,i/3,*]=-2.5*(alog10(flux[i,*]/flux[i,1])-alog10(flux[i+1,*]/flux[i+1,1]))
  colour[1,i/3,*]=-2.5*(alog10(flux[i+2,*]/flux[i+2,1])-alog10(flux[i+1,*]/flux[i+1,1]))
  colour[2,i/3,*]=-2.5*(alog10(flux[i+1,*]/flux[i+1,1]))
;  colour[0,i/3,*]=flux[i,*]-flux[i+1,*]
;  colour[1,i/3,*]=flux[i+2,*]-flux[i+1,*]
;  colour[2,i/3,*]=flux[i+1,*]
  cgplot, colour[0,i/3,*], colour[1,i/3,*], PSYM=2
  cgarrow,  colour[0,i/3,0]+.1, colour[1,i/3,0]+.1, colour[0,i/3,0], colour[1,i/3,0], color='red', /DATA
endfor
cgplot, total(colour[0,*,*],2)/3, total(colour[1,*,*],2)/3, PSYM=2
cgarrow,  total(colour[0,*,0],2)/3+.1, total(colour[1,*,0],2)/3+0.1, total(colour[0,*,0],2)/3, total(colour[1,*,0],2)/3,color='red', /DATA
cgplot, total(colour[2,*,*],2)/3, total(colour[0,*,*],2)/3,  PSYM=2
cgarrow,  total(colour[2,*,0],2)/3+.1, total(colour[0,*,0],2)/3+0.1, total(colour[2,*,0],2)/3, total(colour[0,*,0],2)/3, color='red', /DATA
device, /close
set_plot, 'win'
;cgplot, findgen(3), colour[2,1,*], psym=2;, ys=1
end
