pro star_position, DIR=dir, APERT=apert 

files=file_search(dir+'*.fts', count=N)
openw, lun, dir+'positions.txt', /get_lun
printf, lun, 'X', 'Y', 'RA', 'Dec', format='(2(A6,6X),A9,4X,A12)'
for i=0,N-1 do begin
  img1=readfits(files[i],h)
  Xs=sxpar(h, 'NAXIS1') & Ys=sxpar(h, 'NAXIS2') 
  Dec=sxpar(h, 'DEC') & RA=sxpar(h, 'RA')
  img=fltarr(Xs-20,Ys-21)
  img=img1[0:Xs-20,0:Ys-21]
  ;find, img, x, y, flux, sharp, roundness, /print
  if i eq 0 then begin
      window, 2, XSize=xs*2/3, YSize=ys*2/3
      display_image, img, 2, options={range:[500,5000],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
      click_on_max, img, x_ref, y_ref, mark=1
  endif
  centrod, img, x_ref, y_ref, apert, apert+1, apert+2, 0, x, y, coun
  ;RR=where(flux gt 300000, ind)
  ;if ind gt 0 then for j=0,ind-1 do print, x[RR[j]],  y[RR[j]],  flux[RR[j]]
  ;stop
  printf, lun, x, y, RA, DEC, format='(2(F9.4,4X),2(A12,2X))'
endfor
close, lun
end  
star_position, DIR='d:\Observations\RAW\Zeiss\130609\RXS J152506\', apert=12 
end


