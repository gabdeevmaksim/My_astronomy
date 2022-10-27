pro table_correction

table=read_table('e:\For work\Observations\RAW\BTA\s160414\For WinEF\phot_BTA17.dat')
N=size(table[0,*])
table[0:2,*]=table[0:2,*]+15.74
openw, 1, 'e:\For work\Observations\RAW\BTA\s160414\For WinEF\phot_BTA17_new.dat'
for i=0,N[2]-1 do printf, 1, table[0,i], table[1,i], table[2,i], format='(3(F6.3,2X))'
close, 1
end
