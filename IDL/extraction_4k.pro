pro extraction_4k,WDIR=wdir,DPOS=dpos,PLOT=plot,STARNAME=starname,FWHM=fwhm,BIAS=bias,EXTR=extr
print,float(dpos)
if not(keyword_set(bias)) then bias=0
;extraction spectra
Ndeg=1 & tresh=1
p=0 & restore, wdir+'shift.sav'

files=file_search(wdir+'*_sky.fts', count=count) 
  for q=0,count-1 do begin
    header=headfits(files[q])
    if (sxpar(header, 'IMAGETYP') eq 'obj_sky ') and (sxpar(header,'OBJECT') ne starname) then begin
      print, p+1
      obj=readfits(files[q],h,/silent)
      Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
      y=findgen(Ny) & x=findgen(Nx)
      d_lambda=0.5
      disper=readfits(wdir+'dispersion.fit', hdisp)
      Ndeg=N_elements(disper(0,*))-1 & wave=0 & N=N_elements(disper(*,0))
      disp=dblarr(Ndeg+1)
      for j=0,Ndeg do begin
        disp(j)=total(disper(*,j))/N
        wave=wave+disp(j)*x^j
      endfor
      lambda=wave
      !P.multi=0
      if keyword_set(PLOT) then begin
        window, 10, title='spectra'
        plot, lambda, smooth(obj[*,dpos],5), xst=1, xrange=[3700,7300]
      endif   
      Nobj=N_elements(dpos) & print,Nobj
      spectra=fltarr(Nx,Nobj)
      w=fltarr(Nobj)+FWHM/2

      ;correction bias
      obj=obj-bias
      ;begin optimal extraction
      if extr eq 0 then begin
        print,'OPTIMAL EXTRACTION'
        ;create traectory
        Npos=10 & wx=Nx/(Npos+1)
        xpos=findgen(Npos)*wx+wx
        if xpos(Npos-1)+wx gt Nx-1 then xpos(Npos-1)=Nx-wx-1
        ypos=fltarr(Npos,Nobj) & FWHMpos=ypos
        vector=fltarr(Ny)
        for k=0,Npos-1 do begin
          vector(*)=total(obj(xpos(k)-wx:xpos(k)+wx,*),1)
          res=MULTIGAUS(y,vector,dpos,FWHM=w)
          ypos(k,*)=res.center
          FWHMpos(k,*)=res.FWHM
        endfor
        posfit=fltarr(Nx,Nobj)
        FWHMfit=fltarr(Nx,Nobj)
        ;polynomial approximation
        for k=0,Nobj-1 do begin
          f=goodpoly(xpos,ypos(*,k),Ndeg,tresh)
          for j=0,Ndeg do posfit(*,k)=posfit(*,k)+f(j)*x^j
          f=goodpoly(xpos,FWHMpos(*,k),Ndeg,tresh)
          for j=0,Ndeg do FWHMfit(*,k)=FWHMfit(*,k)+f(j)*x^j
        endfor
        ;extraction spectra
        eps=0
        for k=eps,Nx-1-eps do begin
          vector=total(obj(k-eps:k+eps,*),1)/(2*eps+1)
          res=MULTIGAUS(y,vector,posfit(k,*),FWHM=FWHMfit(k,*),FIXpos=1,FIXfwhm=1)
          spectra(k,*)=res.flux
        endfor
        if keyword_set(plot) then begin
          window,11
          !P.multi=[0,1,2]
          plot,[0,Nx],[min(dpos)-10,max(dpos)+10],$
          xst=1,yst=1,/nodata,title='traectory'
          for k=0,Nobj-1 do begin
            oplot,xpos,ypos(*,k),psym=k+5
            oplot,x,posfit(*,k)
          endfor
          plot,[0,Nx],[0,20],xst=1,yst=1,/nodata,title='variation FWHM'
          for k=0,Nobj-1 do begin
            oplot,xpos,FWHMpos(*,k),psym=k+5
            oplot,x,FWHMfit(*,k)
          endfor
        endif
        sxaddhist,'optimal extraction',h
      endif   ; end optimal extraction

    ;begin extraction in strobe
    if extr eq 1 then begin
      print,'STROBE EXTRACTION'
      w=float(FWHM(0))/2.
      tra=readfits(wdir+'traectory.fts',/silent)
      tra_mean=tra(Nx/2)
      for j=0,Nobj-1 do begin
        for k=0,Nx-1 do begin
          y=tra(k)-tra_mean+dpos(j)
          spectra(k,j)=total(obj(k,y-w:y+w,0),2)
        endfor
      endfor
      sxaddhist,'strobe extraction, width'+string(FWHM(0),format='(I2)')+' px',h
    endif

  sent=readfits(wdir+'sent.fts',/silent)
  ;correction extintion
  Texp=sxpar(h,'EXPTIME')
  Z=sxpar(h,'Z')
  GAIN=sxpar(h,'GAIN')
  for j=0,Nobj-1 do begin
    spectra(*,j)=spectra(*,j)*GAIN/calc_ext(lambda,Z)/Texp/d_lambda
  endfor
  ;plot result
  tmp=sxpar(header,'FILE')
  objName=strmid(tmp,0,9)

  print, 'FileName:',  objName

  lambda_N=SIZE(lambda, /DIMENSIONS )
  OPENW, 77, wdir+objName+'s.txt'
  for i=0,lambda_N[0]-1 do begin
    if spectra[i,0] lt 0 then spectra[i,0]=0
    PRINTF, 77, lambda[i]+(pos[p]*d_lambda), spectra[i,0]
  endfor
  CLOSE, 77

  for k=0,Nobj-1 do begin
    spectra(*,k)=spectra(*,k)*sent(*,0)
  endfor


  if keyword_set(plot) then begin
    for k=0,Nobj-1 do begin
      iplot,lambda, spectra(*,k)
    endfor
    window,12
    !P.multi=[0,1,Nobj]
    for k=0,Nobj-1 do begin
      ymin=0 & ymax=max(spectra(*,k))
      R=where(spectra(*,k) lt 0,ind) & if ind gt 1 then ymin=-ymax/20
      plot,lambda, smooth(spectra(*,k ),5),yst=1, xrange=[lambda[0]+400,lambda[Nx-1]],$;,yrange=[ymin,ymax*1.05]
      xst=1,title='object position along slit'$
      +string(dpos(k),format='(I4)')
      iplot,lambda, spectra(*,k)
    endfor
    !P.multi=[0,1,1]
  endif


  lambda_N=SIZE(lambda, /DIMENSIONS )
  OPENW, 66, wdir+objName+'.txt'
  for i=0,lambda_N[0]-1 do begin
     if spectra[i,0] lt 0 then spectra[i,0]=0
     PRINTF, 66, lambda[i]+(pos[p]*d_lambda), spectra[i, 0]
  endfor
  CLOSE, 66


  ;determination units
  s=''
  for k=0,Nobj-1 do begin
    a=string(dpos(k),format='(I3)')
    if k gt 0 then a=','+a
    s=s+a
  endfor
  s=strcompress(s)
  sxaddpar,h,'UNITS','erg/cm^2/sec/A', BEFORE='YPOS'
  sxaddpar,h,'POS_OBJ',s,after='YPOS',' POSITION EXTRACTED SPECTRA ALONG SLIT'
  writefits,wdir+'spectra.fts',spectra,h
  p++
endif
endfor
cont:
end