cgDisplay, WID=0
       pos = cgLayout([2,2])
       FOR j=0,3 DO BEGIN
                 cgPlot, cgDemoData(17), NoErase=j NE 0, Position=pos[*,j], Title='Plot ' + StrTrim(j+1,2)
        ENDFOR
       cgText, 0.5, 0.925, /Normal, 'Example Plot Layout', Alignment=0.5, Charsize=cgDefCharsize()*1.25
   end