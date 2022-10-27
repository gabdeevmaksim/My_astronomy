function read_testdata, filename

testdata=read_ascii(filename, data_start=1, delimiter=',')
return, testdata
end