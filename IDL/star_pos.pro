pro star_pos, DIR=dir

files=file_search(dir+'*.fts', count=n)
coor=read_ascii(dir+'stars_coord.txt',template=temple)
coor1=float(coor.field1) 
x=coor1[3,1:3] & y=coor1[4,1:3]
img=readfits(files[n-1],h)
window, 1, xsize=sxpar(h,'NAXIS1'), ysize=sxpar(h,'NAXIS2')
display_image, img, 1, /modify_opt
tvcircle, 6, x, y, color='red'
end
star_pos, DIR='d:\Observations\RAW\Zeiss\120122\IPHAS 0528\'
end
