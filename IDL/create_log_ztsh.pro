pro create_log_ZTSh

PATH='e:\Observations\ZTSh\'
DIR_N=dialog_pickfile(PATH=PATH, /DIRECTORY, TITLE='Choose directory')
files=file_search(DIR_N+'*.fit',COUNT=Nf)
openw, 1, DIR_N+'!log.txt'
h=headfits(files[0])
printf, 1, 'DATE-OBS:', sxpar(h,'GPS-DATE'), format='(A20,2X,A'+string(strlen(sxpar(h,'GPS-DATE')))+')'
printf, 1, 'TELESCOP:', sxpar(h,'TELESCOP')+' '+sxpar(h,'OBSERVAT'), format='(A20,2X,A'+string(strlen(sxpar(h,'TELESCOP')+' '+sxpar(h,'OBSERVAT')))+')'
printf, 1, 'INSTRUME:', sxpar(h,'INSTRUME'), format='(A20,2X,A'+string(strlen(sxpar(h,'INSTRUME')))+')'
printf, 1, 'OBSERVER:', sxpar(h,'OBSERVER'), format='(A20,2X,A'+string(strlen(sxpar(h,'OBSERVER')))+')'
;printf, 1, 'PROPOSAL ID:', sxpar(h,'PID'), format='(A20,2X,A'+string(strlen(sxpar(h,'PID')))+')'
;printf, 1, 'AUTHOR:', sxpar(h,'PI'), format='(A20,2X,A'+string(strlen(sxpar(h,'PI')))+')'
printf, 1, ' '
printf, 1, ' '
printf, 1, ' '
printf, 1, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
printf, 1, 'FILE    |','OBJECT    |','TIME-OBS    |','TEXP,s     |','FILTER     |','DISPERSER   |','RA APP     |','DEC APP     |','HA   |','Z     |', format='(10(A16,2X),A10,2X,A9)'
printf, 1, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
for i=0,Nf-1 do begin
  h=headfits(files[i])
  printf, 1, strmid(files[i],9,6,/reverse_offset)+'  |',sxpar(h,'OBJECT')+'  |',string(sxpar(h,'TIME-OBS'))+'|',string(sxpar(h,'EXPTIME'))+' |',sxpar(h,'FILTER')+' |',sxpar(h,'DISP1')+' |', $
    sxpar(h,'RA')+' |',sxpar(h,'DEC')+' |',sxpar(h,'HA')+'|',sxpar(h,'ZD')+'|', format='(8(A16,2X),A10,2X,A9)'
endfor
close, 1 


end

