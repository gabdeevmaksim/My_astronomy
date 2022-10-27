pro for_chalenge, testdata

DIR='C:\Users\gamak\Documents\training_set.csv\'
;metadata=read_ascii(DIR+'training_set_metadata.csv', data_start=1, delimiter=',')
;help, metadata, /str
;target=intarr(7848) & obj_id=fltarr(7848) & zspec=fltarr(7848) & EBV=fltarr(7848)
;target=metadata.field01[11,*]
;help, target
;classes=intarr(14)
;openw, 1, DIR+'Targets.txt'
;j=0
;for i=0,99 do begin
;  rr=where(target eq i,ind)
;  if ind ne 0 then begin
;    printf, 1, i
;    classes[j]=i
;    j++
;  endif
;endfor
;close, 1
;obj_id=metadata.field01[0,*] & zspec=metadata.field01[6,*] & EBV=metadata.field01[10,*]
;for i=0,13 do begin
;  openw, 1, DIR+'Nid_class_'+strcompress(string(classes[i]),/remove_all)+'.txt'
;  rr=where(target eq classes[i], ind)
;  for j=0,ind-1 do printf, 1, obj_id[rr[j]], zspec[rr[j]], EBV[rr[j]], format='(I10,2X,F6.4,2X,F5.3)'
;  close, 1
;endfor

;testdata=read_ascii(DIR+'training_set.csv', data_start=1, delimiter=',')
help, testdata, /str
N=1421705 & ID=intarr(N) & JD=fltarr(N) & PB=intarr(N) & Fl=fltarr(N) & eF=fltarr(N)
ID=testdata.field1[0,*]
JD=testdata.field1[1,*]
PB=testdata.field1[2,*]
Fl=testdata.field1[3,*]
eF=testdata.field1[4,*]
class6=read_table(DIR+'Nid_class_6.txt') & ind=intarr(6)
rr0=where(ID eq class6[0] and PB eq 0, count) & ind[0]=count
rr1=where(ID eq class6[0] and PB eq 1, count) & ind[1]=count
rr2=where(ID eq class6[0] and PB eq 2, count) & ind[2]=count
rr3=where(ID eq class6[0] and PB eq 3, count) & ind[3]=count
rr4=where(ID eq class6[0] and PB eq 4, count) & ind[4]=count
rr5=where(ID eq class6[0] and PB eq 5, count) & ind[5]=count
phot_table=fltarr(6,max(ind))
;openw, 1, DIR+strcompress(string(class6[0,i]),/remove_all)+'.txt'
;if 
s=sort(ID) & ID=ID[s] & JD=JD[s] & PB=PB[s] & Fl=Fl[s] & eF=eF[s] 

;if ind ne 0 then cgplot, JD[rr], Fl[rr]


end