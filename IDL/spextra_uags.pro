pro spextra_UAGS

restore, 'd:\Observations\RAW\UAGS\disp.sav'
file_obj=dialog_pickfile(PATH='d:\Observations\RAW\UAGS\',filter='*.fts')
obj=readfits(file_obj, ho)
Ny=sxpar(ho,'NAXIS2') & Nx=sxpar(ho,'NAXIS1')
img=obj[40:2040,*]
x=findgen(Nx)
end