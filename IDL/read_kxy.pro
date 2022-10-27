pro read_KXY

k1=readfits('c:\IDL_lib\K_XY.fts')
k2=readfits('c:\IDL_lib\remote\K_XY.fts')
help, k1, k2
print, k1-k2

end