pro coloursofpolars
 ;                 AN UMa                         EG Lyn                        GG Leo                       HS Cam                         LW Cam                        PT Per
 ;                V1309 Ori                    J0733+2619                      J0922+1333                   J0953+1458                    J2250+5731                    J2340+7642
names=['AN_UMa','EG_Lyn','GG_Leo','HS_Cam','LW_Cam','PT_Per','V1309_Ori','J0733+2619','J0922+1333','J0953+1458', 'J2250+5731','J2340+7642','EU Lyn','J0759+1914','J0837+3830','J0859.1+0537','WX_LMi', $
       'BY_Cam','FR_Lyn','IPHAS0528','V808_Aur']
coordsH=[11, 04, 25.65, +45, 03, 13.94, 08, 20, 50.97, +49, 34, 31.30, 10, 15, 34.67, +09, 04, 41.98,07, 19, 14.51, +65, 57, 44.30,07, 04, 10.02, +62, 03, 27.94,02, 42, 51.19, +56, 41, 31.25,  $
        05, 15, 41.41, +01, 04, 40.47, 07, 33, 46.27, +26, 19, 26.30, 09, 24, 56.00, +13, 20, 53.00, 09, 53, 08.10, +14, 58, 36.00,22, 50, 37.00, +57, 31, 54.00,23, 40, 20.60, +76, 42, 11.00,   $
        07, 52, 40.50, +36, 28, 23.00, 07, 59, 39.80, +19, 14, 17.00, 08, 37, 51.00, +38, 30, 12.00, 08, 59, 09.20, +05, 36, 55.00,10, 26, 27.50, +38, 45, 04.00,05, 42, 48.90, +60, 51, 32.00,   $
        08, 54, 14.00, +39, 05, 37.00, 05, 28, 32.70, +28, 38, 37.60, 07, 11, 26.00, +44, 04, 05]
    
files=file_search('d:\Papers\RSI-1\20181218\*.dat')        
N=N_elements(names)
coordsD=fltarr(2,N) & colors=fltarr(2,N)
;templ=ASCII_TEMPLATE(files[0])
;save, templ, filename='d:\Papers\RSI-1\20181218\templ.sav'
restore, 'd:\Papers\RSI-1\20181218\templ.sav'
;tab=read_ascii(files[1],template=templ)
;help, tab

Nu=['1','2','3'] & 
stars=read_ascii('d:\Papers\RSI-1\stellar_colors_470-540-656.dat')
print, N
set_plot, 'ps'
device, file='d:\Papers\RSI-1\Fig_04a.eps', /portrait, xsize=8, ysize=8, yoff=0, xoff=0
;for j=0,2 do begin
j=0
  print, string(j+1)+' cycle' 
  for i=0,N-1 do begin
    coordsD[0,i]=15*(coordsH[i*6+0]+coordsH[i*6+1]/60+coordsH[i*6+2]/3600)
    coordsD[1,i]=coordsH[i*6+3]+coordsH[i*6+4]/60+coordsH[i*6+5]/3600
    t=file_test('d:\Papers\RSI-1\20181218\'+names[i]+'_'+Nu[j]+'_colors.dat')
    if t eq 1 then begin
      tab=read_ascii('d:\Papers\RSI-1\20181218\'+names[i]+'_'+Nu[j]+'_colors.dat',template=templ)
      RR=where(sqrt((tab.field04-coordsD[0,i])^2+(tab.field05-coordsD[1,i])^2) le 0.002 and tab.field08 ne 99.9900, ind)
      if ind gt 0 then begin 
       print, names[i], tab.field12[RR], tab.field14[RR], format='(A10,2(2X,F6.3))'
       colors[*,i]=[tab.field12[RR], tab.field14[RR]]
      endif else colors[*,i]=[10,10]
    endif else colors[*,i]=[10,10]
  endfor
  cgplot, colors[0,*], colors[1,*], xtit='470-540', ytit='540-656', xrange=[-1,1.5], yrange=[-1.,1.5], psym=4, xs=1, ys=1, charsize=0.7
  cgoplot, stars.field1[1,*], stars.field1[2,*], PSYM=2, symsize=.5;, color='red'
  cgoplot, [-1,.08,.5], [-1,0.3,1.5]
  ;xyouts,  colors[0,*], colors[1,*], names, charsize=0.7
  xyouts, 1.2, 1.3, 'a)'
;endfor
device, /close
device, file='d:\Papers\RSI-1\Fig_04b.eps', /portrait, xsize=8, ysize=8, yoff=0, xoff=0
cgplot, [-1,1.5],[-1,1.5], xs=1, ys=1, /nodata, xtit='470-540', ytit='540-656', charsize=0.7
cgoplot, stars.field1[1,*], stars.field1[2,*], PSYM=2, symsize=.5;
cgoplot, [-1,.08,.5], [-1,0.3,1.5]
xyouts, 1.2, 1.3, 'b)'
for j=0,2 do begin
  tab=read_ascii('d:\Papers\RSI-1\20181218\IPHAS0528_'+Nu[j]+'_colors.dat',template=templ)
  cgoplot, tab.field12, tab.field14, PSYM=j+4, symsize=0.5
endfor
device, /close
set_plot, 'win'

end