pro Z_extinction, DIR=dir, OBJ_NAME=obj_name

letter=['U','B','V','R','I'] & apert=15
Fi=(43.+39./60.+12./3600.)/180*!PI
for q=0,4 do begin
  path=dir+obj_name+'\'+letter[q]+'\'
  files=file_search(path+'*.fts', count=N)
  t=strarr(N) & Dec=strarr(N) & Z=fltarr(N) & Z_calc=fltarr(N) & am=fltarr(N)
  if files[0] ne '' then begin
    openw, lun, path+'phot.txt', /get_lun
    openw, lun1, path+'phot1.txt', /get_lun
    printf, lun, 'Photometry of stars in field of ' +  obj_name + '. Filter ' + letter[q] + '.'
    printf, lun, ' '
    for i=0,N-1 do begin 
      h=headfits(files[i])
      XS=1024 & YS=1024
      RA_r=sxpar(h,'RA') & Dec_r=sxpar(h,'Dec') & ST_r=sxpar(h,'ST')
      RA1=double(strmid(RA_r,1,2)) & RA2=double(strmid(RA_r,4,2)) & RA3=double(strmid(RA_r,7,4))
      ST1=double(strmid(ST_r,1,2)) & ST2=double(strmid(ST_r,4,2)) & ST3=double(strmid(ST_r,7,4))
      Dec1=double(strmid(Dec_r,1,2)) & Dec2=double(strmid(Dec_r,4,2)) & Dec3=double(strmid(Dec_r,7,4))
      t[i]=((ST1-RA1)*15+(ST2-RA2)/60.*15+(ST3-RA3)/3600.*15)/180*!PI
      Dec[i]=(Dec1+dec2/60+Dec3/3600.)/180*!PI
      if strmid(Dec_r,0,1) eq '-' then Dec[i]=-Dec[i]
      Z[i]=sxpar(h,'Z')
      Z_calc[i]=180/!PI*acos(Sin(Dec[i])*Sin(Fi)+Cos(Dec[i])*Cos(Fi)*Cos(t[i]))
      x = 1.0/cos(Z[i]/(180/!PI))-1
      am[i] = float(1.0+(0.9981833d0-(0.002875d0+0.0008083d0*x)*x)*x)
      printf, lun, (i+1), 'st image. Z from header =',  Z[i], '. Z calculated = ', Z_calc[i], '.'
      printf, lun, ''
      his=sxpar(h,'HISTORY')
      if n_elements(his) eq 1 then first_reduction, dir, obj_name, letter[q]
      img_f=readfits(files[i])
      img=img_f[0:1024,0:1024]
      sky, img, skymode, skysig
      s=3*skysig & ap=8
      window, 2, xsize=XS/1.5, ysize=YS/1.5
      if i eq 0 then begin
        display_image, img, 2, options={range:[1*skysig,2500],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
        click_on_max, img, x_ref, y_ref, mark=1
      endif
      a=N_elements(x_ref)
      printf, lun, '#', 'X', 'Y', 'Magnitude', 'Error', format='(A2,2X,2(A6,2X),2X,A9,1X,A5)'
        for j=0,a-1 do begin
          centrod, img, x_ref[j], y_ref[j], 20, 21, 23, skym, x1, y1, coun
          x_ref[j]=x1 & y_ref[j]=y1
        endfor  
      aper,  img, x_ref, y_ref, mags, errap, sky, skyerr, 2.01, apert, [apert+4,apert+5], $
             [0,32500], /silent          
        ;find, img, x, y, flux, sharp, roundness,3*skysig,apert-2,[-1.0,1.0],[0.2,0.8], /silent
        ;window, 2, xsize=XS/3*2, ysize=YS/3*2
        ;display_image, img-skymode, 2, $
        ;       options={range:[1*skysig,800],chop:56000,reverse:1B,stretch: 'logarithm', color_table: 0L}
        ;tvcircle, 6, x/3*2, y/3*2, color='red', THICK=1
        ;aper,  img, x, y, mags, errap, sky, skyerr, 2.01, apert, [apert+4,apert+5], $
        ;       [0,32500], /flux, /silent  
        ;print, mags/(skysig*sqrt(apert^2*!PI))
        ;if letter[q] eq 'U' then RR=where(mags/(skyerr*sqrt(apert^2*!PI)) gt 75., ind)
        ;if letter[q] eq 'B' then RR=where(mags/(skyerr*sqrt(apert^2*!PI)) gt 100., ind)
        ;if letter[q] eq 'R' then RR=where(mags/(skyerr*sqrt(apert^2*!PI)) gt 307., ind)
        ;if letter[q] eq 'V' then RR=where(mags/(skyerr*sqrt(apert^2*!PI)) gt 206., ind)
        ;if letter[q] eq 'I' then RR=where(mags/(skyerr*sqrt(apert^2*!PI)) gt 310., ind)
        ;x=x[RR] & y=y[RR] & SNR=fltarr(ind)
        ;SNR=mags[RR]/(skyerr[RR]*sqrt(apert^2*!PI))
      for j=0,a-1 do printf, lun, j+1, x_ref[j], y_ref[j], mags[j], errap[j], format='(I2,2X,2(F7.2,2X),1X,F6.3,3X,F5.3)'
      printf, lun, ' '
      printf, lun1, Z[i], am[i], mags, format='(2(F6.3,2X),50(F6.3,2X))'
    endfor
    close, /all
    window, 3
     
    ;stop
  endif 
endfor
end
Z_extinction, DIR='d:\Observations\RAW\Zeiss\Extinction\130307\', OBJ_NAME='3C 196'
end