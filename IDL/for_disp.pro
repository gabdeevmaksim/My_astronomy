pro for_disp


wdir='f:\!!!Pract\OBSst\RAW\dispcurve\test\'
goto, cont
ima=readfits(wdir+'eta.fts')
  ;create traectory
  tra=create_traectory(ima,NP=13,WX=40,NDEG=2,/plot)
  writefits,wdir+'traectory.fit',tra
  ;create geometry
  neon=readfits(wdir+'VPHG940_600.fts')
  ;traectory=readfits(wdir+'traectory.fit')
  geometry_new,neon,tra,DY=40,X0,Y0,X1,Y1,/plot
  Nc=N_elements(X0)
  coords=[X0,Y0,X1,Y1]
  C=reform(coords,Nc,4)
  writefits,wdir+'geometry.fit',C,h
  ;correction of distortion of geometry
  ;C=readfits(wdir+'geometry.FIT')
  ;tra=readfits(wdir+'traectory.fit')
  slit=900

  ;correction of image geometry
  ;type=['neon','flat',fname]
  ;for k=0,2 do begin
    ima=readfits(wdir+'VPHG940_600.fts',header)
    ima=WARP_TRI(c(*,0),c(*,1),c(*,2),c(*,3),ima)
    a=size(ima)
    writefits,wdir+'VPHG940_600_g.fts',ima(65:a(1)-1,30:960),header
    ;print,'correction   ',type(k)
  ;endfor
  
  cont:
  ;create dispersion curve
  neon=readfits(wdir+'VPHG940_600_g.fts')
  ident_table=wdir+'ident.txt'
  Ndeg=3
  D=dispersion_2D(neon,ident_table,N_DEG=Ndeg,/plot);,,TRESH=tresh,PLOT=plot)
  writefits,wdir+'dispersion.fit',D;,h
end

