PRO PS_Plotter, image, $
      European=european, $   ; Set this keyword if you want European measurements.
      Object=object          ; Output variable to return FSC_PSConfig object.

      ; Get an image if one is not passed in.

   IF N_Elements(image) EQ 0 THEN BEGIN
      image = BytArr(360, 360)
      file = Filepath(SubDirectory=['examples', 'data'], 'worldelv.dat')
      OpenR, lun, file, /Get_Lun
      ReadU, lun, image
      Free_Lun, lun
   ENDIF

      ; Create the PostScript configuration object.

   object = Obj_New('FSC_PSConfig');, European=Keyword_Set(european))

      ; We want hardware fonts.

   thisFontType = !P.Font
   !P.Font = 1

      ; Get user input to PostScript configuration.

   object->GUI

      ; Configure the PostScript Device.

   thisDevice = !D.Name
   Set_Plot, 'PS'
   keywords = object->GetKeywords(FontType=fonttype)
   Device, _Extra=keywords

      ; Draw the example plots.

   ;!P.Multi = [ 0, 1, 2]
   ;cgImage, image
   ;Plot, Histogram(image), Title='Example Histogram Plot', XTitle='Pixel Value', $
   ;   YTitle='Number of Pixels', XStyle=1, Max_Value=5000

   tab1=read_table('d:\Observations\For Plot\USNO0825.Pol_V.txt')
   tab2=read_table('d:\Observations\For Plot\USNO0825.PhotV.txt')
   img=readfits('d:\Observations\RAW\BTA\s101106\USNO 0825\S8120114.FTS',h)
   phot=read_table('d:\Observations\RAW\BTA\s101106\USNO 0825\PhotStars.txt')
   pol=read_table('d:\Observations\RAW\BTA\s101106\USNO 0825\PolStars.txt')
   xs=sxpar(h, 'NAXIS1') & ys=sxpar(h, 'NAXIS2')
   m1=900 & m2=1700 & img1=fltarr(xs,ys)
	for i=0,xs-1 do begin
		for j=0,ys-1 do img1[i,ys-1-j]=img[i,j]
	endfor

   ;for i=0,2 do begin
   ;	robomean, phot[i,*], 3, 0.5, avg_obj, obj_err, obj_std
   ;	robomean, pol[i,*], 3, 0.5, avg_obj1, obj_err1, obj_std1
   ;	stop, avg_obj, obj_err, obj_std, avg_obj1, obj_err1, obj_std1
   ;endfor
   !P.Multi = [ 0, 1, 2]
   plot, findgen(40)+1, pol[0,*], xtitle='Number of image', ytitle='Pv, %', PSYM=6, SYMSIZE=0.5, yst=1 $
   		, xst=1, xthick=2, ythick=2, charthick=2, charsize=1.2, yrange=[-3.,3], xrange=[-1,41]
   oplot, pol[1,*], PSYM=4, SYMSIZE=0.5
   oplot, pol[2,*], PSYM=5, SYMSIZE=0.5
   oplot, [0,41], [0,0]
   ;cgerrplot, tab2[0,*], tab2[1,*]-tab2[2,*], tab2[1,*]+tab2[2,*]
   xyouts, 0.9, 0.44, '(b)', font=1, charthick=2, charsize=1.2, /norm
   plot, findgen(80)+1, phot[0,*], xtitle='Number of image', ytitle='V, Magnitude', PSYM=6, SYMSIZE=0.5, yst=1, $
   		 xst=1, xthick=2, ythick=2, charthick=2, charsize=1.2, xrange=[-1,81], yrange=[17.9,17.5]
   oplot, phot[1,*], PSYM=4, SYMSIZE=0.5
   oplot, phot[2,*], PSYM=5, SYMSIZE=0.5
   oplot, [0,81], [17.62,17.62]
   oplot, [0,81], [17.785,17.785]
   ;cgerrplot,  tab1[0,*], tab1[1,*]-tab1[2,*], tab1[1,*]+tab1[2,*]
   xyouts, 0.9, 0.94, '(a)', font=1, charthick=2, charsize=1.2, /norm


   ;tv,255-bytscl(congrid(img1(*,*),xs/2,ys/2),min=m1,max=m2),0.5,/centimeter
   ;cgarrow,.5,.3,.52,.32,color='black',/norm
      ; Clean up.

   !P.Multi = 0
   Device, /Close_File
   Set_Plot, thisDevice
   !P.Font = thisfontType

      ; Return the PS_Configuration object or destroy it.

   IF Arg_Present(object) EQ 0 THEN Obj_Destroy, object
   END