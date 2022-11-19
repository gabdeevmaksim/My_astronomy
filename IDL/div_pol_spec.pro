pro dev_pol_spec, RDIR=rdir, N=n

type=['obj','neon','flat']
for k=0,N-1 do begin
  DIR=RDIR
  if k lt 9 then DIR=RDIR+'0'+strcompress(string(k+1),/remove_all)+'\' else DIR=DIR+strcompress(string(k+1),/remove_all)+'\'
  type=['obj','neon','flat']
  for j=0,2 do begin
    neon=readfits(DIR+type[j]+'_i.fts',h1)
    w=80 & pos_y=[50,175,300,425] & xs=sxpar(h1,'NAXIS1')
    Neon_pol=fltarr(w,xs) & obj_pol=fltarr(w,xs)
    sxaddpar, h, 'NAXIS2', w
    sxaddpar, h1, 'NAXIS2', w
    for i=0,3 do begin
      neon_pol=neon[*,pos_y[i]:pos_y[i]+w-1]
      writefits, DIR+type[j]+'0'+strcompress(string(i+1)+'.fts',/remove_all),neon_pol, h1
      ;obj_pol=obj[*,pos_y[i]:pos_y[i]+w-1]
      ;writefits, DIR+'s01020'+strcompress(string(i+1)+'.fts',/remove_all),obj_pol, h
    endfor
  endfor
endfor
;tv, bytscl(255-obj_pol[*,*])
end
dev_pol_spec, RDIR='d:\Observations\Processed\BTA\s151107\standart_0\', N=5
end
