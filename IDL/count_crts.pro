pro count_CRTS 

if file_test('C:\Users\gamak\Documents\Report RSF\CRTS.sav') eq 0 then begin
  tem=ascii_template('C:\Users\gamak\Documents\Report RSF\Results.outall2xCV.txt')
  save, tem, filename='C:\Users\gamak\Documents\Report RSF\CRTS.sav'
endif else restore, 'C:\Users\gamak\Documents\Report RSF\CRTS.sav'

tab=read_ascii('C:\Users\gamak\Documents\Report RSF\Results.outall2xCV.txt',template=tem)
rr=where(tab.field05 gt -10, ind)
print, ind

end