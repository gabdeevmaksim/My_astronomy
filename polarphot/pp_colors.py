
import numpy as np
import pyfits as pf
import datetime

def deg2six(ra, dec, ra_prec = 2, dec_prec = 1):
    r = ra/15 # to hours
    hours = np.floor(r)
    r = (r-hours)*60
    mins = np.floor(r)
    secs = (r-mins)*60

    # check for effect of rounding 

    if np.round(secs*10**dec_prec)/10**ra_prec >= 60.0:
        secs = 0
        mins += 1
        if mins >= 60.0:
            mins = 0
            hours += 1
    
    # fmt = "%02d:%02d:%0"
    fmt = "%02d%02d%0"
    f = "%d.%df" % (3+ra_prec, ra_prec)
    fmt += f
    ra_str = fmt % (hours, mins, secs)
    
    degs = np.floor(abs(dec))
    r = (abs(dec)-degs)*60
    mins = np.floor(r)
    secs = (r-mins)*60
    
    # check for effect of rounding 

    if np.round(secs*10**dec_prec)/10**dec_prec >= 60.0:
        secs = 0
        mins += 1
        if mins >= 60.0:
            mins = 0
            degs += 1

    # fmt = "%02d:%02d:%0"
    fmt = "%02d%02d%0"
    f = "%d.%df" % (3+dec_prec, dec_prec)
    fmt += f
    
    if dec < 0:
        dec_str = '-'
    else:
        dec_str = '+'
        
    dec_str += fmt % (degs, mins, secs)
    
    return [ra_str, dec_str]


def polarPhotComputeColors(config_dict):
    f = pf.open(config_dict['IDENT_TABLE'])
    ref_image = f[1].header['REFIMAGE']
    data = f[1].data
    ident_cols = f[1].columns
    try:
        flags = f[1].data['FLAGS']
        flag_exists = 1
    except KeyError:
        flag_exists = 0
        
    f.close()

    mag_cols = pf.ColDefs([])
    
    mag_col = []
    magerr_col = []
    for i in range(config_dict['NFILTERS']):
        f_name = config_dict['FILTER'][i]
        mag_col.append(config_dict['MAG_STD_COL'] + '_' + f_name)        
        magerr_col.append(config_dict['MAGERR_STD_COL'] + '_' + f_name)
        mag = data[mag_col[i]]
        mag[np.isnan(mag)] = 99.99
        magerr = data[magerr_col[i]]
        magerr[np.isnan(magerr)] = 99.99
        mag_cols.add_col(pf.Column(name=mag_col[i], format='D', disp='F7.4', array=mag))
        mag_cols.add_col(pf.Column(name=magerr_col[i], format='D', disp='F6.4', array=magerr))
        
    col_idx = config_dict['COLORS']

    names = []
    ra = data[config_dict['SKY_COORD'][0]]
    dec = data[config_dict['SKY_COORD'][1]]
    obj_prefix = config_dict['OBJ_NAME_PREFIX']
    for i in range(len(ra)):
        [ra_str, dec_str] = deg2six(ra[i], dec[i]) 
        names.append(obj_prefix + ra_str + dec_str)
    
    fmt = "A%d" % len(names[0])
    
    name_col = pf.ColDefs([pf.Column(name="NAME", format=fmt, array=names)])   
    
    # ident_cols = name_col + ident_cols[:4]
    ident_cols = name_col + ident_cols[:4] + mag_cols
    
    for i in range(config_dict['NFILTERS']):
        idx = col_idx[i]
        
        mag1 = data[mag_col[idx[0]]]
        magerr1 = data[magerr_col[idx[0]]]
        mag2 = data[mag_col[idx[1]]]
        magerr2 = data[magerr_col[idx[1]]]
                
        
        color = mag1 - mag2
        color_err = np.sqrt(magerr1**2 + magerr2**2)
        
        ii = np.bitwise_or(mag1 == 99.99, mag2 == 99.99)
        color[ii] = 99.99
        color_err[ii] = 99.99
        # color[np.isnan(color)] = 99.99
        # color_err[np.isnan(color_err)] = 99.99
        
        color_name = config_dict['FILTER'][idx[0]] + '-' + config_dict['FILTER'][idx[1]]
        color_err_name = 'ERR_' + color_name

        ident_cols.add_col(pf.Column(name=color_name, format='D', disp='G', array=color))
        ident_cols.add_col(pf.Column(name=color_err_name, format='D', disp='G', array=color_err))
    
 
   
    if flag_exists:
        ident_cols.add_col(pf.Column(name='FLAGS', format='I', disp='G', array=flags))
    
    hdu = pf.BinTableHDU.from_columns(ident_cols)
    hdu.header['REFIMAGE'] = ref_image
    hdu.writeto(config_dict['COLOR_TABLE'], clobber=True)
    
    idx_shift = 5+6
    # return
    if config_dict['COLOR_TABLE_DAT'] != '':
        f = pf.open(config_dict['COLOR_TABLE'])
        d = f[1].data
        c = f[1].columns
        
        header = "\nFIELD OBJECTS COLORS\n\n"
        now = datetime.datetime.now()
        header += "CREATED: %s" % now.strftime("%m/%d/%Y, %H:%M:%S")
        header += "\n\n\nCONFIGURATION FILE: %s" % config_dict['INI_CONFIG']
        header += "\nINPUT IMAGES: %s" % ', '.join(config_dict['FILE'])
        
        if config_dict['WEIGHT_FILE'][0] != '':
            header += "\nWEIGHT IMAGES: %s" % ', '.join(config_dict['WEIGHT_FILE'])
            
        header += "\nPHOTOMETRY TABLES: %s" % ', '.join(config_dict['PHOT_TABLE'])
        header += "\nCROSS-IDENTIFICATION TABLE: %s" % config_dict['IDENT_TABLE']
        
        header += "\n\n\nFORMAT:\n  OBJ_NAME  X_IMAGE(pixels)  Y_IMAGE(pixels)  RA(%s)  DEC(%s)  " % (c[3].name, c[4].name)
        
        delim = config_dict['COLOR_TABLE_DAT_DEL']
        
        fmt = "%s" + delim + "   %7.2f" + delim + "   %7.2f" + delim + "   %11.7f" + delim + "   %11.7f" 
        for i in range(config_dict['NFILTERS']):            
            fmt += delim + "   %7.4f" + delim + "   %6.4f"
            header += "%s   %s   " % (c[i*2+5].name, c[i*2+5+1].name)
        
        for i in range(config_dict['NFILTERS']):
            fmt += delim + "   %7.3f" + delim + "   %7.3f"
            header += "%s  %s  " % (c[i*2+idx_shift].name, c[i*2+idx_shift+1].name)
        if flag_exists:
            fmt += delim + "   %2i"
            # fmt += delim + "   %2d"
            header += "FLAG"
        header += "\n\n\nREFERENCE COORDINATES IMAGE: %s\n\n" % ref_image
        # print(fmt)
        # for i in range(len(d)):
        #     arr = d[i].array
        #     np.savetxt(config_dict['COLOR_TABLE_DAT'], arr, header=header, fmt=fmt, encoding='utf-8')

        np.savetxt(config_dict['COLOR_TABLE_DAT'], [], header=header)
        
        ff = open(config_dict['COLOR_TABLE_DAT'], 'a')
        
        for i in range(len(d)):
            ff.write(fmt % tuple(d[i]))
            ff.write('\n')
       
        # np.savetxt(config_dict['COLOR_TABLE_DAT'], d, header=header, fmt=fmt)
        ff.close()
