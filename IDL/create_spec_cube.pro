pro create_spec_cube, LOGFILE

;read LOGFILE
Nlines=file_lines(LOGFILE)
log=strarr(Nlines)
openr, lun, LOGFILE, /get_lun
readf, lun, log
free_lun, lun

;read info from LOGFILE
rdir=sxpar(log,'r_dir')
wdir=sxpar(log,'w_dir')
night=sxpar(log,'night')
Nspec=sxpar(log,'N')
stop, log, Nspec, night

;check of obj_i file existence
if FILE_TEST(wdir+'obj_i.fts') eq 1 then begin
  print, 'file obj_i.fts exist!
  return
endif

;write to array .fts files from r_dir
files=file_search(rdir+'*.fts',count=Nfiles)

ima=readfits(files[Nspec/2], h)
Nx=sxpar(h,'NAXIS1') & Ny=sxpar(h,'NAXIS2')
cube_obj=fltarr(Nx,Ny,Nspec) & k=0
for i=0,Nfiles-1 do begin
  ima=readfits(files[i], h)
  type=sxpar(h,'IMAGETYPE') & mode=sxpar(h,'MODE')
  if (type eq 'obj') and (mode='spectra') then begin
    cube_obj[*,*,k]=ima
    k++
  endif
endfor

sxaddpar, h, 'NAXIS3', Nspec, 'NUMBER OF SPECTRA'    
writefits, w_dir+'obj_i.fts', cube_obj, h 

end
LOGFILE=DIALOG_PICKFILE(/READ, FILTER = '*.txt',path='f:\!!!Pract\OBSst\RAW\LogFiles\')
create_spec_cube, LOGFILE
end

