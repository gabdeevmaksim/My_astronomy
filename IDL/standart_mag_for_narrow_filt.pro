pro standart_mag_for_narrow_filt

file='e:\IDL_lib\scorpio_2K.lib\standards\data\fg191B2B.dat'
DQE_file='c:\Users\gamak\Documents\Conferences\2019, Shamahy\DQE\'
tab=read_table(file)
DQE=read_table(DQE_file)
f_filt=file_search('c:\Users\gamak\Documents\Conferences\2019, Shamahy\*.txt',count=Nfilt)
Yb=dblarr(Nfilt,600) & f_mag=fltarr(Nfilt) & extin_tab=fltarr(3,600) & mag_tab=fltarr(3,600) & df=fltarr(Nfilt)
a=0.012 & c=0.12 & z_star=[14.89,14.44,14.00]
for i=0,Nfilt-1 do begin
  filter_b=read_table(f_filt[i],double=1)
  ;par=spl_init(filter_b[0,*]*10, filter_b[1,*],/double)
  ;Yb[i,*]=spl_interp(filter_b[0,*]*10,filter_b[1,*],par,tab[0,*],/double) ;Yb[i,*]=interpolate(tab[1,*],filter_b[0,0:599]*10+1200)
  ;mag=tab[1,*]*Yb[i,*]/100
  ;f_mag[i,*]=int_tabulated(tab[0,*],mag)/int_tabulated(tab[0,*], Yb[i,*])
;  !P.MULTI=[0,1,2]
;  window, i
;  cgplot, tab[0,*], mag, xs=1
;  cgplot, tab[0,*], Yb[i,*], xs=1
  par=spl_init(tab[0,*]/10, tab[1,*],/double)
  par1=spl_init(DQE[0,*], DQE[1,*],/double)
  Yb[i,*]=spl_interp(tab[0,*]/10,tab[1,*],par,filter_b[0,120:719],/double)
  Ydqe=spl_interp(DQE[0,*], DQE[1,*],par1,filter_b[0,120:719],/double)
  cgplot, filter_b[0,120:719], Ydqe
  mag=filter_b[1,120:719]*Yb[i,*]/100*Ydqe/100
  f_mag[i]=int_tabulated(filter_b[0,120:719],mag)/int_tabulated(filter_b[0,120:719], filter_b[1,120:719]/100)
  !P.MULTI=[0,1,2]
  window, i
  cgplot, filter_b[0,120:719], mag, xs=1
  cgplot, filter_b[0,120:719], filter_b[1,120:719], xs=1
  extin_tab[i,*]=(a*1./((filter_b[0,120:719]/1000.)^4.)+c)*2.5*alog10(exp(1))
  mag_tab[i,*]=extin_tab[i,*]/cos(z_star[i]*!DTOR)
  mag_tab[i,*]=mag_tab[i,*]*filter_b[1,120:719]/100
  df[i]=int_tabulated(filter_b[0,120:719],mag_tab[i,*])/int_tabulated(filter_b[0,120:719], filter_b[1,120:719]/100)
endfor
df=10^(-df/2.512)

flux=[870010.875,584812.688,338181.656]; 19.01.31
;flux=[31910.758,29994.629,24997.057]; 18.12.02 ;,33864.656,31650.977,26988.086,31337.078,23632.992,21480.355]
;flux=[206083.516,142887.250,79886.430]; 19.03.03
;flux=[33864.656,31650.977,26988.086]
;mag_inst=-2.5*alog10(flux)
;print, mag_inst
flux=flux/df
f_mag=f_mag/f_mag[0] & flux=flux/flux[0]
print, f_mag
print, flux
end
