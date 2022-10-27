pro search_for_candidates

DIR='e:\Observations\MMPP\20190702\'
name=create_input_for_searching(DIR)
if file_test('E:\Observations\MMPP\stars_temp.sav') ne 1 then begin  
  temp=ascii_template('E:\Observations\MMPP\stellar_colors_470-540-656.dat')
  save, temp, filename='E:\Observations\MMPP\stars_temp.sav'
endif
restore, 'E:\Observations\MMPP\stars_temp.sav'
stars=read_ascii('E:\Observations\MMPP\stellar_colors_470-540-656.dat',template=temp)
restore, 'E:\Observations\MMPP\mag.sav'
restore, 'E:\Observations\MMPP\color.sav'
col_shi=read_table( 'E:\Observations\MMPP\color.dat')
cAM=fltarr(2,48)
cAM[0,*]=mag[0,*]-mag[1,*] & cAM[1,*]=mag[1,*]-mag[2,*]
restore, 'E:\Observations\MMPP\magm15.sav'
colour=['red','orange','yellow','green','blue','dark slate blue','purple','Medium Orchid','Thistle','Salmon']
for l=0,N_elements(name)-1 do begin
  files=file_search(DIR+name[l]+'_color.fits')
  fits_open, files, fcb
  fits_info, files, /silent, N_ext=N
  openw, 1, DIR+name[l]+'_res.dat'
  set_plot, 'ps'
  device, file=DIR+name[l]+'_res.eps', /portrait, xsize=20, ysize=20, yoff=0, xoff=0  
  cgplot, stars.field2, stars.field3, xs=1, ys=1, xr=[-1.0,1.5], yr=[-1.0,2.], PSYM=2, SYMSIZE=0.5, xtit='470-540', ytit='540-656'
  ;cgplot, cAM[0,*], cAM[1,*], color='red', /overplot, PSYM=2, SYMSIZE=2
  ;cgplot, cAMm15[0,*], cAMm15[1,*], color='green', /overplot, PSYM=2, SYMSIZE=2
  cgplot, col_shi[1,*], col_shi[2,*],  color='red', /overplot, PSYM=1, SYMSIZE=2
  ;cgplot, col_shi[1,*]-.5, col_shi[2,*]-.8,  color='blue', /overplot, PSYM=1, SYMSIZE=2
  cgplot, color[0,*], color[1,*], color='green', /overplot, psym=6
  cgplot, [-1.5,-.175], 1.2121*[-1.5,-.175]+0.2121, /overplot
  cgplot, [-.175, 0],11.4286*[-.175, 0]+2, /overplot
  for i=0,N-1 do begin 
    ftab_ext, fcb, '470-540_PSF,540-656_PSF,Name,MAG_STD_540_PSF,MAG_STD_470_PSF,MAG_STD_656_PSF,ERR_470-540_PSF', EXTEN_NO=i+1, v1,v2,v3, mag, mag2, mag3, errcol
    cgplot, v1, v2, /overplot, PSYM=3, Symsize=4
    RR=where((v1 lt -.175 and v2 gt 1.2121*v1+0.2121) or (v1 gt -.175 and v2 gt 11.4286*v1+2) and v1 lt 99.00 and v2 lt 99.00,ind);and mag2 lt 18.5
    ;print, 'ind', ind, i
    if ind gt 0 then begin
      printf, 1, 'Name', '470-540', '540-656', '540', '470', '656', 'Cycle', format='(A21,2X,A10,2X,A10,2X,A7,2X,A7,2X,A7,2X,A5)' 
      for k=0,ind-1 do printf, 1, v3[RR[k]], v1[RR[k]], v2[RR[k]], mag[RR[k]], mag2[RR[k]], $
        mag3[RR[k]], i+1, format='(A21,2X,F11.7,2X,F11.7,2X,F7.4,2X,F7.4,2X,F7.4,2X,I1)'
      ;cgplot, v1[RR], v2[RR], /overplot, PSYM=4, color=colour[i], symsize=2
      ;xyouts, v1[RR], v2[RR], strcompress(string(i+1),/remove_all)          
      for j=0,N-1 do begin
        if j ne i then begin
          ftab_ext, fcb, '470-540_PSF,540-656_PSF,Name,MAG_STD_540_PSF,MAG_STD_470_PSF,MAG_STD_656_PSF', EXTEN_NO=j+1, v11,v21,v31, mag1, mag12, mag13
          for k=0,ind-1 do printf, 1, v31[RR[k]], v11[RR[k]], v21[RR[k]], mag1[RR[k]],$
              mag12[RR[k]], mag13[RR[k]], j+1, format='(A21,2X,F11.7,2X,F11.7,2X,F7.4,2X,F7.4,2X,F7.4,2X,I1)'
          ;cgplot, v11[RR], v21[RR],  /overplot, PSYM=4, color=colour[j], symsize=2
          ;xyouts, v11[RR], v21[RR], strcompress(string(j+1),/remove_all)
        endif
      endfor
    endif
  endfor
  fits_close, fcb
  close, 1
  device, /close
endfor
;device, file=DIR+name+'_err_color.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0  
;cgplot, mag, errcol, xs=1, ys=1, PSYM=2, xr=[11,21], yr=[0,.2], xtitle='SED540', ytitle='err (SED470-SED540)'
;device, /close
set_plot, 'win'
end 
