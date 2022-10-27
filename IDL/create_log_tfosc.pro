pro create_log_TFOSC

PATH='e:\Observations\RTT150\'
DIR_N=dialog_pickfile(PATH=PATH, /DIRECTORY, TITLE='Choose directory')
files=file_search(DIR_N+'*.fit',COUNT=Nf)
openw, 1, DIR_N+'!log.txt'
h=headfits(files[0])
printf, 1, 'OBS DATE:', sxpar(h,'GPS-DATE'), format='(A20,2X,A'+string(strlen(sxpar(h,'GPS-DATE')))+')'
printf, 1, 'TELESCOPE:', sxpar(h,'TELESCOP')+' '+sxpar(h,'OBSERVAT'), format='(A20,2X,A'+string(strlen(sxpar(h,'TELESCOP')+' '+sxpar(h,'OBSERVAT')))+')'
printf, 1, 'INSTRUMENT:', sxpar(h,'INSTRUME'), format='(A20,2X,A'+string(strlen(sxpar(h,'INSTRUME')))+')'
printf, 1, 'OBSERVERS:', sxpar(h,'OBSERVER'), format='(A20,2X,A'+string(strlen(sxpar(h,'OBSERVER')))+')'
printf, 1, 'PROPOSAL ID:', sxpar(h,'PID'), format='(A20,2X,A'+string(strlen(sxpar(h,'PID')))+')'
printf, 1, 'AUTHOR:', sxpar(h,'PI'), format='(A20,2X,A'+string(strlen(sxpar(h,'PI')))+')'
printf, 1, ' '
printf, 1, ' '
printf, 1, ' '
printf, 1, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
printf, 1, 'FILE    |','OBJECT    |','TYPE     |','GPS TIME    |','TEXP,s     |','MODE     |','FILTER     |','GRISM   |','RA APP     |','DEC APP     |','A   |','Z     |', format='(10(A16,2X),A10,2X,A9)'
printf, 1, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
for i=0,Nf-1 do begin
  h=headfits(files[i])
  printf, 1, sxpar(h,'FILENAME')+'  |',sxpar(h,'OBJECT')+'  |',sxpar(h,'IMAGETYP')+'  |',string(sxpar(h,'DATE-OBS'))+'|',string(sxpar(h,'EXPTIME'))+' |',sxpar(h,'APERTURE')+'|',sxpar(h,'FFILTERW')+' |',sxpar(h,'GRISM')+' |', $
    sxpar(h,'RA')+' |',sxpar(h,'DEC')+' |',sxpar(h,'AZIMUTH')+'|',sxpar(h,'ZENITH')+'|', format='(10(A16,2X),A10,2X,A9)'
endfor
close, 1 


end

