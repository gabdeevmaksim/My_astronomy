pro extra_RA_DEC_f_CASJOB

file='c:\Users\gamak\Documents\training_set.csv\MyTable_QSO_Dedulek.csv'
if file_test('c:\Users\gamak\Documents\training_set.csv\temp_f_extra_RA_DEC.sav') eq 0 then begin
  templat=ascii_template(file)
  save, templat, filename='c:\Users\gamak\Documents\training_set.csv\temp_f_extra_RA_DEC.sav'
endif else restore, 'c:\Users\gamak\Documents\training_set.csv\temp_f_extra_RA_DEC.sav'
tab=read_ascii(file,template=templat)
N=size(tab.field03)
openw, 1, 'c:\Users\gamak\Documents\training_set.csv\MyTable_QSO_Dedulek_1.csv'
for i=0,N[1]-1 do printf, 1, tab.field03[i],',',tab.field04[i], format='(F9.5,A1,F10.6)'
close, 1
end