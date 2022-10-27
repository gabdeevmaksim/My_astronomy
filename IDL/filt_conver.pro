pro filt_conver

filter_b=read_table('d:\Variety files\SCORPIO\filters\bvri\scorp_b.txt')
filter_v=read_table('d:\Variety files\SCORPIO\filters\bvri\scorp_v.txt')
filter_r=read_table('d:\Variety files\SCORPIO\filters\bvri\scorp_r.txt')
DIR='d:\Observations\Processed\BTA\s130912\IPHAS0528\'
ph=read_table(DIR+'phase_all.dat')
f_spec=file_search(DIR+'*.txt',count=N)
spec=read_table(f_spec[0])

par=spl_init(filter_b[0,*], filter_b[1,*],/double)
Yb=spl_interp(filter_b[0,*], filter_b[1,*],par,spec[0,*],/double)
par=spl_init(filter_v[0,*], filter_v[1,*],/double)
Yv=spl_interp(filter_v[0,*], filter_v[1,*],par,spec[0,*],/double)
par=spl_init(filter_r[0,*], filter_r[1,*],/double)
Yr=spl_interp(filter_r[0,*], filter_r[1,*],par,spec[0,*],/double)

set_plot, 'win'
;window, 1
;cgplot, filter[0,*],filter[1,*], psym=4
;cgplot, spec[0,*], Yb, color='blue'
;cgoplot, spec[0,*], Yv, color='green'
;cgoplot, spec[0,*], Yr, color='red'
flux_b=fltarr(N) & flux_v=fltarr(N) & flux_r=fltarr(N) & flux_tot_b=fltarr(N) & flux_tot_v=fltarr(N) & flux_tot_r=fltarr(N)
flux=fltarr(N) & flux_tot=fltarr(N)
openw, 1, DIR+'spec_phot.dat'
for i=0,N-1 do begin
  tmp1=read_table(f_spec[i])
  flux[i]=total(tmp1[1,*])
  flux_b[i]=total(Yb*tmp1[1,*])
  flux_v[i]=total(Yv*tmp1[1,*])
  flux_r[i]=total(Yr*tmp1[1,*])
  flux_tot[i]=-2.5*alog10(flux[i]/0.349e-6)
  flux_tot_b[i]=-2.5*alog10(flux_b[i]/0.349e-6)
  flux_tot_v[i]=-2.5*alog10(flux_v[i]/0.349e-6)
  flux_tot_r[i]=-2.5*alog10(flux_r[i]/0.349e-6)
  printf, 1, ph[i], flux_tot[i], flux_tot_b[i], flux_tot_b[i], flux_tot_b[i]
endfor
close, /all

ph=ph+.18
!P.multi=[0,2,2]
set_plot, 'ps'
device, file=DIR+'spec_phot.eps', /portrait
cgplot, ph, flux_tot, PSYM=4, xtitle='Phase', ytitle='Relative magnitude', ys=1, yrange=[13.5,12]
cgplot, ph, flux_tot_b, PSYM=4, xtitle='Phase', ytitle='Relative magnitude, B', ys=1, yrange=[17.5,12.8]
cgplot, ph, flux_tot_v, PSYM=4, xtitle='Phase', ytitle='Relative magnitude, V', ys=1, yrange=[17.5,12.]
cgplot, ph, flux_tot_r, PSYM=4, xtitle='Phase', ytitle='Relative magnitude, R', ys=1, yrange=[16.,11.]
device, /close
set_plot, 'win'
;cgoplot, ph, flux, PSYM=1
end
  