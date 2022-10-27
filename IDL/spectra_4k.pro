pro spectra_4k, RDIR=rdir, WDIR=wdir, OBJPOS=objpos, STARPOS=starpos, STARNAME=starname

files=file_search(rdir+'*.fts', count=count)
start:
print, 'Choose procedure: 1 - Create meanBias'
print, '                  2 - Create FLAT'
print, '                  3 - Geometry correction'
print, '                  4 - Create dispersion curve'
print, '                  5 - Linearisation of srectra'
print, '                  6 - FLAT-filding and BIAS subtructing'
print, '                  7 - Remove Cosmic Hits'
print, '                  8 - Night Sky subtructing'
print, '                  9 - Create sensitive curve'
print, '                  10- Determine shift'
print, '                  11- Extracting spectra'
print, '                  0 - Quit program'
read, proc

n=12
num=findgen(n)
R=where(proc eq num, ind)
if ind ne 1 then begin
  print, 'Wrong number of procedure'
  goto, start
endif

if proc eq 0 then goto, fin

if proc eq 1 then begin
  ; create Bias
  cre_bias_2m, dir = rdir, binning = '2x4', w_dir = wdir, fileout = 'SBias.fts'
  time=fltarr(3,count) & num=0 & date=strarr(count)
  for q=0,count-1 do begin
    head=headfits(files[q])
    if ((sxpar(head, 'IMAGETYP') eq 'obj') and (sxpar(head,'OBJECT') ne starname)) then begin
      convert_time, sxpar(head, 'START'), outtime & time[0,num]=outtime
      convert_time, sxpar(head, 'UT'), outtime & time[1,num]=outtime
      time[2,num]=float(sxpar(head,'EXPTIME'))
      date[num]=sxpar(head, 'DATE') & num++
    endif
  endfor
  RR=where(time[0,*] ne 0, ind)
  if ind gt 0 then $
    UT=time[1,RR] & Tstart=time[0,RR] & Texp=time[2,RR]
  save, UT, Tstart, Texp, date, filename=wdir+'Time.sav'
  print, 'SBias.fts has created'
endif

if proc eq 2 then begin
  ;create FLAT
  create_flat4k,RDIR=rdir,wdir=wdir
  print, 'flat_i.fts has just created'
endif

if proc eq 3 then begin
  print, '                        Geometry correction is begin'
  for q=0,count-1 do begin
    head=headfits(files[q])
    if (sxpar(head,'IMAGETYP') eq 'eta' or sxpar(head,'IMAGETYP') eq 'flat') and (sxpar(head,'SLITMASK') eq  '3 dots  ') then ima=readfits(files[q])
    if sxpar(head,'IMAGETYP') eq 'neon' then  neon=readfits(files[q])
  endfor
  ;create traectory
  tra=create_traectory(ima,NP=12,WX=40,NDEG=2,/plot)
  writefits,wdir+'traectory.fit',tra
  ;create geometry
  geometry_new,neon,tra,DY=40,X0,Y0,X1,Y1,/plot
  Nc=N_elements(X0)
  coords=[X0,Y0,X1,Y1]
  C=reform(coords,Nc,4)
  writefits,wdir+'geometry.fit',C,h
  slit=900

  ;correction of image geometry
  ima=readfits(wdir+'SFlat.fts', header, /silent)
  ima=WARP_TRI(c(*,0),c(*,1),c(*,2),c(*,3),ima)
  a=size(ima)
  writefits,wdir+'flat.fts',ima(65:a(1)-1,30:a(2)-1),header
  for q=0,count-1 do begin
    head=headfits(files[q])
    if (sxpar(head, 'IMAGETYP') eq 'obj') or (sxpar(head, 'IMAGETYP') eq 'neon') then begin
      ima=readfits(files[q], header, /silent)
      tmp=sxpar(header,'FILE')
      file=strmid(tmp,0,9)
      ima=WARP_TRI(c(*,0),c(*,1),c(*,2),c(*,3),ima)
      a=size(ima)
      if (sxpar(head, 'IMAGETYP') eq 'neon') then writefits,wdir+'neon.fts',ima(65:a(1)-1,30:a[2]-1),header $
      else writefits,wdir+file+'.fts',ima(65:a(1)-1,30:a[2]-1),header
      print,'correction   ', file
    endif
  endfor

print, 'Geometry correction has completed'
endif


if proc eq 4 then begin
  ;create dispersion curve
  neon=readfits(wdir+'neon.fts')
  ident_table=rdir+'ident.txt'
  Ndeg=3
  D=dispersion_2D(neon,ident_table,N_DEG=Ndeg,/plot);,,TRESH=tresh,PLOT=plot)
  writefits,wdir+'dispersion.fit',D;,h
  print, 'Creation of dispersion curve has completed'
endif


if proc eq 5 then begin
  ;linearisation of spectra
  D=readfits(wdir+'dispersion.fit')
  Nlin=2548 & lambda_0=3417 & d_lambda=2.2
  files=file_search(wdir+'*.fts', count=count)
  for q=0,count-1 do begin
    header=headfits(files[q])
    if (sxpar(header, 'IMAGETYP') eq 'obj') or (sxpar(header, 'IMAGETYP') eq 'neon') then begin
      ima=FLOAT(readfits(files[q], /silent))
      PARAM=[lambda_0,d_lambda,Nlin]
      ima=linerisation_2D4K(ima,D);,PARAM=PARAM)
      sxaddpar,header,'CRVAL1',lambda_0
      sxaddpar,header,'CDELT1',d_lambda,after='CRVAL1'
      if sxpar(header,'IMAGETYP') eq 'neon' then sxaddpar,header,'IMAGETYP','neon_lin' $
      else sxaddpar,header,'IMAGETYP', 'obj_lin'
      tmp=sxpar(header,'FILE')
      file=strmid(tmp,0,9)
      if sxpar(header,'IMAGETYP') eq 'neon' then writefits,wdir+'neon_lin.fts',ima,header $
      else writefits,wdir+file+'_lin.fts',ima,header
      print,'linerisation   ', file
    endif
  endfor
  print, 'Linearisation of spectra has completed'
endif

if proc eq 6 then begin
  ;FLAT-filding and BIAS substructing
  bias=readfits(wdir+'SBias.fts')
  flat=readfits(wdir+'flat.fts')
  files=file_search(wdir+'*.fts', count=count)
  for q=0,count-1 do begin
    header=headfits(files[q])
    if (sxpar(header, 'IMAGETYP') eq 'obj') or (sxpar(header, 'IMAGETYP') eq 'neon') then begin
      ima=readfits(files[q],header)
      if sxpar(header,'IMAGETYP') eq 'neon' then sxaddpar,header,'IMAGETYP','neon_red' $
      else sxaddpar,header,'IMAGETYP', 'obj_red'
      tmp=sxpar(header,'FILE')
      file=strmid(tmp,0,9)
      if sxpar(header,'IMAGETYP') eq 'neon' then writefits,wdir+'neon_red.fts',(ima-bias)/flat,header $
      else writefits,wdir+file+'_red.fts',(ima-bias)/flat,header
      print,'subtructing   ', file
    endif
  endfor
  print,'Subtructing and FLAT-fielding has completed'
endif

if proc eq 7 then begin
  ;clean Cosmic Hits
  files=file_search(wdir+'*.fts', count=count)
  for q=0,count-1 do begin
    header=headfits(files[q])
    if (sxpar(header, 'IMAGETYP') eq 'obj_red ') then begin
      if sxpar(header, 'OBJECT') eq starname then hitsrem, WDIR=wdir, FILE_NAME=files[q], OBJ_POS=starpos $
      else hitsrem, WDIR=wdir, FILE_NAME=files[q], OBJ_POS=objpos
      print,'cleaning   ', files[q]
    endif
  endfor

  print, 'Cleaning has completed'
endif


if proc eq 8 then begin
  ; Night Sky subtrucing
  files=file_search(wdir+'*.fts', count=count)
  for q=0,count-1 do begin
    header=headfits(files[q])
    if (sxpar(header, 'IMAGETYP') eq 'obj_red ') then begin
      if sxpar(header, 'OBJECT') eq starname then ns_subtruction, WDIR=wdir, FILE=files[q], SLITPOS=starpos, WY=18 $
      else ns_subtruction, WDIR=wdir, FILE=files[q], SLITPOS=objpos, WY=13
      print,'cleaning   ', files[q]
    endif
  endfor
endif

if proc eq 9 then begin
  ; Create sensitive curve
  files=file_search(wdir+'*.fts', count=count)
  for q=0,count-1 do begin
    header=headfits(files[q])
    if (sxpar(header, 'IMAGETYP') eq 'obj_sky ') and (sxpar(header,'OBJECT') eq starname) then $
    crea_sent_4k, WDIR=wdir,FILE=files[q],PLOT=plot,MANUAL=0,starpos=starpos, STARNAME=starname
  endfor
endif

if proc eq 10 then begin
  ;determine shift
  sdvig_4k, WDIR=wdir, OBJPOS=objpos, STARNAME=starname
endif

if proc eq 11 then begin
  ;extracting spectra
  extraction_4k,WDIR=wdir,DPOS=objpos,STARNAME=starname,FWHM=7,EXTR=0
endif
goto, start
fin:
print, 'Bye, bye!'
end
spectra_4k, RDIR='d:\Observations\RAW\BTA\s151107\standart_lin\', WDIR='d:\Observations\Processed\BTA\s151107\standart_lin\', OBJPOS=500, STARPOS=468, STARNAME='bd33d2642'
end