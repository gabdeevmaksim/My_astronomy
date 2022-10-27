pro fit_lines_vel_4

DIR='e:\Observations\BTA\s080502\MTDra\'; chose directory
spec=read_table(DIR+'spectra.dat'); read spectra file
phase=read_table(DIR+'phase_all.dat'); read phase file
velos=read_table(DIR+'velos.dat'); read velosity file
spot=read_table(DIR+'flux45_new.dat'); read visibility of reradiation spot
;dV=-340; velosity shift
;xc=-.36 & w=.5 & A=1000. & y0=-340.  ; highspeed part
;xc_1=-.1 & w_1=.5 & A_1=320. & y0_1=-340. ; first stream
;xc_2=.4 & w_2=.5 & A_2=320. & y0_2=-340. ; second stream
w0=4861.32; laboratory wavelength of line HII=4685.68, Hb=4861.32
dA=.88; spectral resolution of spectra. For 1200G=.88, for 550G=2.1
RR=where(abs(spec[0,*]-w0) lt dA/2, ind); find nearest wl to lab wl in array
if ind eq 1 then begin  ; number of found wl, must be 1 
  dw=35; width of spectra for fiting in Angstrem
  dpx=fix(dw/dA); width of spectra for fiting in pixels
  N=size(spec); array sizes of readed file spectra.dat
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
  parlines=fltarr(13,N[1]-2) & par_w=w0 & dw1=1 & fwhm_h = 7 & Amax=25
  
  for i=0,N[1]-3 do begin
    if i eq 0 then begin
      y=y0+A*sin(!pi*(phase(i)-xc)/w); calculating velocity of highspeed part
      y1=y0_1+A_1*sin(!pi*(phase(i)-xc_1)/w_1); calculating velocity of first pole
      y2=y0_2+A_2*sin(!pi*(phase(i)-xc_2)/w_2); calculating velocity of second pole
      w1=(y1)*1000/imsl_constant('c')*w0+w0; 
      w2=(y2)*1000/imsl_constant('c')*w0+w0
      w_high=(y)*1000/imsl_constant('c')*w0+w0
    endif else begin
      w1=parms[3]
      w2=parms[6]
      w_high=parms[9]
      w0=parms[12]
    endelse
    dA=abs(phase(i)-fix(phase(i)) - spot[0,*])
    RR=where(dA eq min(dA), ind)
    if ind eq 1 then A=Amax*spot[1,RR] else stop, 'ind mast be 1'
    parinfo = replicate({value:0.D, fixed:0, limited:[0,0], limits:[0.D,0]}, 13)
      parinfo(0).limited(0) = 1 &  parinfo(0).limits(0)  = 0.95
      parinfo(0).limited(1) = 1 &  parinfo(0).limits(1)  = 1.05
      ;narrow part
      parinfo(1).limited(0) = 1 &  parinfo(1).limits(0)  = 0
      parinfo(1).limited(1) = 1 &  parinfo(1).limits(1)  = 100
      parinfo(2).limited(0) = 1 &  parinfo(2).limits(0)  = 5.7
      parinfo(2).limited(1) = 1 &  parinfo(2).limits(1)  = fwhm_h
      parinfo(3).limited(0) = 0 &  parinfo(3).limits(0)  = w1-dw1
      parinfo(3).limited(1) = 0 &  parinfo(3).limits(1)  = w1-dw1
      ;first stream part
      parinfo(4).limited(0) = 1 &  parinfo(4).limits(0)  = 0
      parinfo(4).limited(1) = 0 &  parinfo(4).limits(1)  = 100
;      if i eq 6 then parinfo(4).limits(1)  = 3.
;      if i gt 13 then parinfo(4).limits(1)  = par_A
;      if i eq 17 then parinfo(4).limits(1)  = 5.
      parinfo(5).limited(0) = 1 &  parinfo(5).limits(0)  = 5.7     
      parinfo(5).limited(1) = 1 &  parinfo(5).limits(1)  = fwhm_h
      parinfo(6).limited(0) = 0 &  parinfo(6).limits(0)  = w2-dw1    
      parinfo(6).limited(1) = 0 &  parinfo(6).limits(1)  = w2+dw1
      ;highspeed part
      parinfo(7).limited(0) = 1 &  parinfo(7).limits(0)  = 1.
      parinfo(7).limited(1) = 1 &  parinfo(7).limits(1)  = 35.
      parinfo(8).limited(0) = 1 &  parinfo(8).limits(0)  = 15.   
      parinfo(8).limited(1) = 1 &  parinfo(8).limits(1)  = 26
      parinfo(9).limited(0) = 0 &  parinfo(9).limits(0)  = w_high-dw1     
      parinfo(9).limited(1) = 0 &  parinfo(9).limits(1)  = w_high-dw1
      ;second stream part
      parinfo(10).limited(0) = 1 &  parinfo(10).limits(0)  = A-5
      parinfo(10).limited(1) = 1 &  parinfo(10).limits(1)  = A+3
      parinfo(11).limited(0) = 1 &  parinfo(11).limits(0)  = 5.7   
      parinfo(11).limited(1) = 1 &  parinfo(11).limits(1)  = 6.
      parinfo(12).limited(0) = 0 &  parinfo(12).limits(0)  = w0-dw     
      parinfo(12).limited(1) = 0 &  parinfo(12).limits(1)  = w0-dw
    parinfo(*).value = [1.,2.3, 6, w1,$
                          2.3, 7, w2,$
                          4., 15, w_high,$
                          A, 6, w0]
    parms = MPFITFUN('four_gauss', x, line[i,*], ERR=0, parinfo=parinfo, yfit=yy, WEIGHTS=1, STATUS=status, /quiet)
;   stop, status
    ;print, w1, w2, w_high
    parlines[*,i]=parms
    printf, 1, phase[i], parms[0],parms[1],parms[2],parms[3],parms[4],parms[5],parms[6],parms[7],parms[8],parms[9],parms[10],parms[11],parms[12],format='(F6.4,2X,F4.2,2X,4(F5.1,2X,F4.1,2X,F8.3))'
    printf, 2, phase[i], (parlines[3,i]-w0)/w0*imsl_constant('c')/1000, (parlines[6,i]-w0)/w0*imsl_constant('c')/1000, (parlines[9,i]-w0)/w0*imsl_constant('c')/1000, (parlines[12,i]-w0)/w0*imsl_constant('c')/1000
    cgplot, x, line[i,*], linestyle = 2, title=strcompress(string(phase[i]),/remove_all), yrange=[0,6]
    cgoplot, x, yy, color='black'
    cgoplot, x, gauss_origin(x,parlines[0:3,i]), color='green'
    y_outs=5.5
    xyouts, parms[3], y_outs, '1'
    par_blue=[parlines[0,i],parlines[4:6,i]]
    cgoplot, x, gauss_origin(x,par_blue), color='blue'
    xyouts, parms[6], y_outs, '2'
    par_red=[parlines[0,i],parlines[7:9,i]]
    cgoplot, x, gauss_origin(x,par_red), color='red'
    xyouts, parms[9], y_outs, '3'
    par_yellow=[parlines[0,i],parlines[10:12,i]]
    cgoplot, x, gauss_origin(x,par_yellow), color='orange'
    xyouts, parms[12], y_outs, '4'
    par_w=parlines[6,i]
    ;if i gt 12 then par_A=parlines[4,i]
  endfor
  x1=findgen(N[1]-2)
  cgplot, phase, parlines[3,*], yrange=[w0-dw,w0+dw], color='green'
  cgoplot, phase, parlines[6,*], color='blue'
  cgoplot, phase, parlines[9,*], color='red'
  cgoplot, phase, parlines[12,*], color='orange', thick=2
  close, /all
  device, /close
  
endif else print, 'Change resolution (dA) of spectra'


;dopin,gam=0,w0=4685.68,delw=65,wc1=[4590,4610],wc2=[4770,4790]


end

