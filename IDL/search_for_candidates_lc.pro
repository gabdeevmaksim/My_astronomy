pro search_for_candidates_LC

DIR='e:\Observations\MMPP\20220205\'
name=create_input_for_searching(DIR)
for l=0,N_elements(name)-1 do begin
  files=file_search(DIR+name[l]+'_color.fits')
  fits_open, files, fcb
  fits_info, files, /silent, N_ext=N
  fits_open, DIR+name[l]+'_lightcurve.fits', fcb1
  ftab_ext, fcb1, 'NAME,MAG_STD_470_PSF_CORR,MAG_STD_540_PSF_CORR,MAG_STD_656_PSF_CORR', name_o, l470, l540, l656
  ;l470[where(FInite(l470) eq 0)]=99.00 & l540[where(finite(l540) eq 0)]=99.00 & l656[where(finite(l656) eq 0)]=99.00
  ftab_ext, fcb1, 'MAGERR_STD_470_PSF,MAGERR_STD_540_PSF,MAGERR_STD_656_PSF,JD_470,JD_540,JD_656', er470,er540, er656, JD470, JD540,JD656, EXTEN_NO=2
  mer470=mean(er470) & mer540=mean(er540) & mer656=mean(er656) & koef=20
  set_plot, 'ps'
  device, file=DIR+name[l]+'_LC.eps', /portrait, xsize=16, ysize=16, yoff=0, xoff=0  
  for i=0,N-1 do begin
    ftab_ext, fcb, '470-540_PSF,540-656_PSF,Name,MAG_STD_540_PSF,MAG_STD_470_PSF,MAG_STD_656_PSF,ERR_470-540_PSF', EXTEN_NO=i+1, v1,v2,v3, mag, mag2, mag3, errcol
    ;v1[where(FInite(v1) eq 0)]=99.00 & v2[where(FInite(v2) eq 0)]=99.00 & mag[where(FInite(mag) eq 0)]=99.00 & mag2[where(FInite(mag2) eq 0)]=99.00 & mag3[where(FInite(mag3) eq 0)]=99.00
    RR=where((v1 lt -.175 and v2 gt 1.2121*v1+0.2121) or (v1 gt -.175 and v2 gt 11.4286*v1+2) and v1 lt 99.00 and v2 lt 99.00,ind);and mag2 lt 18.5
    if ind gt 0 then begin
      for m=0,ind-1 do begin
        RR2=where(name_o eq v3[RR[m]], ind2)
        ml470=mean(l470[*,RR2]) & ml540=mean(l540[*,RR2]) & ml656=mean(l656[*,RR2])
        !P.multi=[0,1,3]
        cgplot, JD470, l470[*,RR2], title=name_o[RR2]+' SED470', xtitle='JD', YTITLE='Magnitude', PSYM=4, ys=1, yrange=[ml470+koef*mer470,ml470-koef*mer470]
        cgplot, [0,10e10], [ml470,ml470], /overplot, LineSTYLE=0
        cgplot, [0,10e10], [ml470-3*mer470,ml470-3*mer470], /overplot, LineSTYLE=1
        cgplot, [0,10e10], [ml470+3*mer470,ml470+3*mer470], /overplot, LineSTYLE=1
        cgplot, JD540, l540[*,RR2], title=name_o[RR2]+' SED540', xtitle='JD', YTITLE='Magnitude', PSYM=4, ys=1, yrange=[ml540+koef*mer540,ml540-koef*mer540]
        cgplot, [0,10e10], [ml540,ml540], /overplot, LineSTYLE=0
        cgplot, [0,10e10], [ml540-3*mer540,ml540-3*mer540], /overplot, LineSTYLE=1
        cgplot, [0,10e10], [ml540+3*mer540,ml540+3*mer540], /overplot, LineSTYLE=1
        cgplot, JD656, l656[*,RR2], title=name_o[RR2]+' SED656', xtitle='JD', YTITLE='Magnitude', PSYM=4, ys=1, yrange=[ml656+koef*mer656,ml656-koef*mer656]
        cgplot, [0,10e10], [ml656,ml656], /overplot, LineSTYLE=0
        cgplot, [0,10e10], [ml656-3*mer656,ml656-3*mer656], /overplot, LineSTYLE=1
        cgplot, [0,10e10], [ml656+3*mer656,ml656+3*mer656], /overplot, LineSTYLE=1
        !P.multi=0
      endfor
    endif
  endfor
  fits_close, fcb
  fits_close, fcb1
  close, 1
  device, /close
endfor
set_plot, 'win'
end 