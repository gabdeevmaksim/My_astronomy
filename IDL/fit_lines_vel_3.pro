pro fit_lines_vel_3

DIR='e:\Observations\BTA\s060322\MTDra\'; chose directory
spec=read_table(DIR+'spectra.dat'); read spectra file
phase=read_table(DIR+'phase_all.dat'); read phase file
velos=read_table(DIR+'velos.dat'); read velosity file
dV=0; velosity shift
xc=-.0 & w=.5 & A=720. & y0=-31.  ; set up sinus parameters for wide line
xc_n=0.08 & w_n=.5 & A_n=240. & y0_n=61. ; set up sinus parameters for narrow line
xc_b=.17 & w_b=.5 & A_b=327. & y0_b=325. ; set up sinus parameters for narrow line
w0=4861.32; laboratory wavelength of line HII=4685.68, Hb=4861.32
dA=.88; spectral resolution of spectra. For 1200G=.88, for 550G=2.1
RR=where(abs(spec[0,*]-w0) lt dA/2, ind); find nearest wl to lab wl in array
if ind eq 1 then begin  ; number of found wl, must be 1 
  dw=35; width of spectra for fiting in Angstrem
  dpx=fix(dw/dA); width of spectra for fiting in pixels
  N=size(spec); array sizes of read file spectra.dat
  line=fltarr(N[1]-2,dpx*2+1); array for extracted lines
  x=spec[0,RR[0]-dpx:RR[0]+dpx]; array for wavelength
  for i=2,N[1]-1 do begin; cycle for all spectra in file
    line[i-2,*]=spec[i,RR[0]-dpx:RR[0]+dpx]; write line for fiting to array
  endfor; end of cycle for all spectra in file
;  set_plot, 'win'
;  window, 1
;  cgplot,  line[0,*], title='All lines'; plot extracted lines
;  for i=0,N[1]-3 do cgoplot, line[i,*]; plot extracted lines
  set_plot, 'ps'
  device, file=DIR+'fit_'+strcompress(string(w0),/remove_all)+'.ps',/portrait; open file for graphic output
  openw, 1, DIR+'parameters_'+strcompress(string(w0),/remove_all)+'.dat'; open file for Gauss parameters output
  openw, 2, DIR+'veloses_'+strcompress(string(w0),/remove_all)+'.dat'; open file for velosity output
  parlines=fltarr(10,N[1]-2) & par_w=w0 & A_wide_line=25. & width_wide_line=17
  
  for i=0,N[1]-3 do begin
    y=y0+A*sin(!pi*(phase(i)-xc)/w)
    y_n=y0_n+A_n*sin(!pi*(phase(i)-xc_n)/w)
    y_b=y0_b+A_b*sin(!pi*(phase(i)-xc_b)/w)
    w1=(velos[1,i]+dV)*1000/imsl_constant('c')*w0+w0
    w2=(y)*1000/imsl_constant('c')*w0+w0
    w_n = (y_n)*1000/imsl_constant('c')*w0+w0
    w_b = (y_b)*1000/imsl_constant('c')*w0+w0
    ;print, phase[i], phase(i)-xc_n, y_n, y, w_n
    ;if i eq 5 then w1=w0
    parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 10)
      parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = 0.95
      parinfo(0).limited(1) = 1 &  parinfo(0).limits(1)  = 1.05
      parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0.
      ;if i eq 5 then parinfo(1).limits(0)  = 0.
      ;if i gt 13 then parinfo(1).limits(0)  = parlines[1,i-1]-4
      parinfo(1).limited(1) = 1 &  parinfo(1).limits(1)  = 100
      ;if i eq 5 then parinfo(1).limits(1)  = 2.
      parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 5.7
      parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = 8
      parinfo(3).limited(0) = 1 &  parinfo(3).limits(0)  = w_n-1
      parinfo(3).limited(1) = 1 &  parinfo(3).limits(1)  = w_n+1
      
      parinfo(4).limited(0) = 1 &  parinfo(4).limits(0)  = 0
      parinfo(4).limited(1) = 1 &  parinfo(4).limits(1)  = 100
;      if i eq 6 then parinfo(4).limits(1)  = 3.
;      if i gt 13 then parinfo(4).limits(1)  = par_A
;      if i eq 17 then parinfo(4).limits(1)  = 5.
      parinfo(5).limited(0) = 1 &  parinfo(5).limits(0)  = 5.7     
      parinfo(5).limited(1) = 1 &  parinfo(5).limits(1)  = 8
      parinfo(6).limited(0) = 0 &  parinfo(6).limits(0)  = w_b-1     
      parinfo(6).limited(1) = 0 &  parinfo(6).limits(1)  = w_b+1
      
;      parinfo(7).limited(0) = 1 &  parinfo(7).limits(0)  = 2.2
;      parinfo(7).limited(1) = 0 &  parinfo(7).limits(1)  = 30.
      parinfo(7).limited(0) = 1 &  parinfo(7).limits(0)  = A_wide_line-2.2
      parinfo(7).limited(1) = 1 &  parinfo(7).limits(1)  = A_wide_line+2.2
      parinfo(8).limited(0) = 1 &  parinfo(8).limits(0)  = width_wide_line-2 
      parinfo(8).limited(1) = 1 &  parinfo(8).limits(1)  = width_wide_line+2
      parinfo(9).limited(0) = 1 &  parinfo(9).limits(0)  = w2-2     
      parinfo(9).limited(1) = 1 &  parinfo(9).limits(1)  = w2+2
    parinfo(*).value = [1,2.3,7,w_n,2.3,7,w0,A_wide_line,width_wide_line,w2]
    parms = MPFITFUN('three_gauss', x, line[i,*], ERR=0, parinfo=parinfo, yfit=yy, WEIGHTS=1,/quiet)
    parlines[*,i]=parms
    printf, 1, phase[i], parms[0],parms[1],parms[2],parms[3],parms[4],parms[5],parms[6],parms[7],parms[8],parms[9],format='(F7.5,2X,F4.2,2X,3(F5.1,2X,F4.1,2X,F8.3))'
    printf, 2, phase[i], (parlines[3,i]-w0)/w0*imsl_constant('c')/1000, (parlines[6,i]-w0)/w0*imsl_constant('c')/1000, (parlines[9,i]-w0)/w0*imsl_constant('c')/1000
    cgplot, x, line[i,*], linestyle = 2, title=strcompress(string(phase[i]),/remove_all), yrange=[0,6]
    cgoplot, x, yy, color='black'
    cgoplot, x, gauss_origin(x,parlines[0:3,i]), color='green'
    par_blue=[parlines[0,i],parlines[4:6,i]]
    cgoplot, x, gauss_origin(x,par_blue), color='blue'
    par_red=[parlines[0,i],parlines[7:9,i]]
    cgoplot, x, gauss_origin(x,par_red), color='red'
    par_w=parlines[6,i]
    A_wide_line=parlines[7,i]
    width_wide_line=parlines[8,i]
    ;if i gt 12 then par_A=parlines[4,i]
  endfor
  x1=findgen(N[1]-2)
  cgplot, phase, parlines[3,*], yrange=[w0-dw,w0+dw], color='green'
  cgoplot, phase, parlines[6,*], color='blue'
  cgoplot, phase, parlines[9,*], color='red'
  close, /all
  device, /close
  
endif else print, 'Change resolution (dA) of spectra'


;dopin,gam=0,w0=4685.68,delw=65,wc1=[4590,4610],wc2=[4770,4790]


end

