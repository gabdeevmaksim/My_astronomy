pro prepare_data_ShC280

DIR='e:\Observations\ShC280\20200210\'
f_bias=file_search(DIR+'bdf\*Bias.fit',count=N_b)
f_dark=file_search(DIR+'bdf\*Dark300s.fit',count=N_d)
f_flat=file_search(DIR+'bdf\*FlatG.fit',count=N_f)

if file_test(DIR+'bdf\SBias.fit') eq 0 then mkbias, DIR+'bdf\', 'SBias.fit', f_bias, 0, bias else bias=readfits(DIR+'bdf\SBias.fit')
if file_test(DIR+'bdf\SDark.fit') eq 0 then mkdark, DIR+'bdf\', 'SDark.fit', f_dark, 0, bias, dark else dark=readfits(DIR+'bdf\SDark.fit')
if file_test(DIR+'bdf\SFlatG.fit') eq 0 then mkflat, DIR+'bdf\', 'SFlatG.fit', f_flat, 0, bias, dark, flat else flat=readfits(DIR+'bdf\SFlatG.fit')

f=dialog_pickfile(PATH=DIR,get_path=DIR_o)
f_obj=file_search(DIR_o+'*.fit',count=N_o)
for i=0,N_o-1 do begin
  img=readfits(f_obj[i],h)
  img=(img-bias-dark)/flat
  sxaddpar, h, 'HISTORY', 'First reduction complite: bias, dark, flat'
  sxaddpar, h, 'NAXIS1', 3340
  writefits, f_obj[i], img[0:3339,*], h
endfor
end