pro test_cosm

dir='f:\!!!Pract\OBSst\RAW\s120826\test\'
img=readfits(dir+'sky.fts',h)
X=sxpar(h,'NAXIS1') & Y=sxpar(h,'NAXIS2') & limit=32768.0
window, 1, xsize=X/4, ysize=Y/2
display_image, img, 1, $
               options={range:[1,100],chop:56000,reverse:0B,stretch: 'linear', color_table: 0L}
s=15 & Y=Y-5 
Hx=intarr(X) & Hy=intarr(X) & j=0
temp=fltarr(s,s) & obj_coor=465 & w=11
for coorX=21,X-1,s/2 do begin
  for coorY=obj_coor-w,obj_coor+w,s/2 do begin
    coorXend=coorX+s & coorYend=coorY+s
    if coorX+s gt X-1 then coorXend=X-1
    if coorY+s gt Y-1 then coorYend=Y-1
    temp=img[coorX:coorXend,coorY:coorYend]
    hist=histogram(temp)
    ;window, 3
    ;plot, hist
    M=where(hist eq max(hist),ind)
    if ind gt 1 then mode=max(M) else mode=M
    nul=where(hist eq 0, ind)
    N=ind 
    if N gt 218 then begin
      k=0
      if N gt limit then N=1000
      for i=0,N-2 do begin
        if (nul[i+1]-nul[i]) eq 1 then k++ else k=0
        if (k eq 10) and (nul[i] gt 1000) then begin
          ex=i
          break
        endif
        ex=i
      endfor
      hits=where(temp gt nul(ex), ind)
      if ind gt 0 then begin
        Hcoor=intarr(2,ind)
        for i=0,ind-1 do begin
          Hcoor[0,i]=hits[i]/s
          Hcoor[1,i]=hits[i]-s*Hcoor[0,i]-1
        endfor  
        Hx[j:j+ind-1]=coorX+Hcoor[0,*] & Hy[j:j+ind-1]=coorY+Hcoor[1,*]
        j=j+ind
      endif
    endif
  endfor
endfor
Rx=where(Hx ne 0, indx) 
if indx gt 0 then begin
  Hix=intarr(indx) & Hix=Hx[Rx]
endif
Ry=where(Hy ne 0, indy) 
if indy gt 0 then begin
  Hiy=intarr(indy) & Hiy=Hy[Ry]
endif
stop, Hix, Hiy
hit=intarr(indx,2)
for i=0,indx do begin
  n=0
  for j=i,indy-1 do if (Hix[i] eq Hix[j]) and (Hiy[i] eq Hiy[j]) then n++
  if n gt 1 then stop, n
  if n gt 3 then begin
    a++ & hit[a,0]=Hix[i] & hit[a,1]=Hiy[i]
  endif
endfor
Rh=where((hit[*,0] ne 0) and (hit[*,1] ne 0), ind)
if ind gt 0 then stop, hit[R,*]     
window, 2, xsize=X/4, ysize=Y/2
display_image, img, 2, $
               options={range:[1,100],chop:56000,reverse:0B,stretch: 'linear', color_table: 0L} 
tvcircle, 1, Hx/4, Hy/2, color='red', THICK=1
writefits, dir+'red_1.fit', img, h  
end