pro filter_curves

file='c:\Users\Maxim\Desktop\FN 657.txt'
table=read_table(file)
s=size(table) 
trans=dblarr(2,s[2])
trans[0,*]=table[0,*] & trans[1,*]=table[1,*]/(table[2,*]*1e-7)
plot, trans[0,*], trans[1,*]
end



