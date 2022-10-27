;test_ maxim
file='spectra013.dat'
N=numlines(file)
print,N
value=fltarr(2,N)
openr,1,file
readf,1,value
close,1
window,1
x=findgen(N)
wave=value(0,*) & spectra=value(1,*)
spectra=spectra-min(spectra)+1

fi_peak,x,spectra,0,ipix,xpk,ypk,bkpk,ipk
print,ipk
tmp=spectra
for k=0,5 do begin
cont=LOWESS(x,tmp,N/8,3)
robomean,tmp-cont,1,0.5,avg_cont,rms_cont
R=where(tmp-cont gt  rms_cont,ind) & if ind gt 1 then tmp(R)=cont(R)

endfor
spectra=spectra- cont
R=where(spectra lt 0,ind) & if ind gt 1 then spectra(R)=0
gamma=0.3
window,2,xsize=1600,ysize=500
spectra=(spectra+1)^gamma
plot,x,spectra,xst=1
fi_peak,x,spectra,0,ipix,xpk,ypk,bkpk,ipk
oplot,xpk,ypk,psym=6
end