pro cut_spec_from_image, FILE=file, POS=pos

img=readfits(file, h)
img[*,pos-20:pos+20]=img[*,pos-60:pos-20]
writefits, file, img, h
end
cut_spec_from_image, FILE='d:\Observations\RAW\BTA\s160309\S13890705.FTS', POS=564
end
