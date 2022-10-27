pro plot_cyc_f_paper

files=file_search('C:\Users\gamak\Documents\Papers\3BS Results\tables','*.dat')

s_obs=read_table('e:\Observations\MMPP\specSDSS\CSS110920\01.dat')
s_m_15=read_table(files[3], head=1)
s_m_25=read_table(files[4], head=1)
s_m_35=read_table(files[5], head=1)

set_plot, 'ps'
device,  file='C:\Users\gamak\Documents\Papers\3BS Results\fig01.ps', xs=16, ys=16, /portrait, xoff=0, yoff=0
cgplot, s_obs[0,*], smooth(s_obs[1,*],5), xs=1, ys=1, xr=[4000,10000], yr=[0,25], color='grey', $
  ytitle='Relative flux', xtitle='Wavelength, '+cgsymbol('angstrom')
cgplot, s_m_15[0,*], s_m_15[1,*], /overplot, linestyle=2, thick=3
cgplot, s_m_35[0,*], s_m_35[1,*], /overplot, linestyle=3, thick=3
cgplot, s_m_25[0,*], s_m_25[1,*], /overplot, linestyle=0, thick=3
cgplot, s_m_25[0,*], s_m_25[2,*], /overplot, linestyle=0, thick=3
cgplot, s_m_25[0,*], s_m_25[3,*], /overplot, linestyle=0, thick=3
device, /close
set_plot, 'win'
end