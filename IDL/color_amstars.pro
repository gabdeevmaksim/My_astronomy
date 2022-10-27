pro color_AMstars

f_filt=file_search('c:\Users\gamak\Documents\Conferences\2019, Shamahy\*.txt',count=Nfilt)
t=read_ascii('c:\Users\gamak\Documents\Conferences\2019, Shamahy\fluxall1.dat')
N=size(t.field01)
mag=fltarr(Nfilt,N[1]-1) & Yb=dblarr(Nfilt,N[1]-1,210)
for j=0,N[1]-2 do begin
  for i=0,Nfilt-1 do begin
    filter_b=read_table(f_filt[i],double=1)
    par=spl_init(t.field01[0,*]/10, t.field01[j+1,*],/double)
    Yb[i,j,*]=spl_interp(t.field01[0,*]/10,t.field01[j+1,*],par,filter_b[0,260:469],/double)
    f_mag=filter_b[1,260:469]*Yb[i,j,*]/100
    mag[i,j]=int_tabulated(filter_b[0,260:469],f_mag);/int_tabulated(filter_b[0,250:469], filter_b[1,250:469]/100)
  endfor
mag[*,j]=-2.5*alog10(mag[*,j]/mag[1,j])
color=fltarr(2,N[1]-1)
color[0,*]=mag[0,*]-mag[1,*] & color[1,*]=mag[1,*]-mag[2,*]
endfor
!P.multi=0
save, color, filename='c:\Users\gamak\Documents\Conferences\2019, Shamahy\color.sav'
cgplot, filter_b[0,260:469], Yb[0,2,*]
cgplot, t.field01[0,*]/10,t.field01[2,*], /overplot, color='red'
end