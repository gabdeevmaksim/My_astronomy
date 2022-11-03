import pyfits as pf
import numpy as np


def polarPhotCrossIdent(config_dict):
    # compute output table dimansion
    for i in range(config_dict['NFILTERS']):
        filename = config_dict['PHOT_TABLE'][i]
        f = pf.open(filename)
        if i == 0:
            ref_idx = 0
            n = f[1].header['NAXIS2']
        else:
            if f[1].header['NAXIS2'] > n:
                ref_idx = i
                n = f[1].header['NAXIS2']
        f.close()
                
    x_name = config_dict['IMAGE_COORD'][0]
    y_name = config_dict['IMAGE_COORD'][1]
    ra_name = config_dict['SKY_COORD'][0]
    dec_name = config_dict['SKY_COORD'][1]
    
    # reference table
    filename = config_dict['PHOT_TABLE'][ref_idx]
    f = pf.open(filename)
    x = f[1].data[x_name]
    y = f[1].data[y_name]
    ra_ref = f[1].data[ra_name]
    dec_ref = f[1].data[dec_name]
    
    try:
        ref_flag = f[1].data['FLAGS']
        flag_exists = 1
    except KeyError:
        flag_exists = 0
    
    f.close()
     
    cols = [pf.Column(name=x_name, format='D', array=x, disp='G'),
            pf.Column(name=y_name, format='D', array=y, disp='G'),
            pf.Column(name=ra_name, format='D', array=ra_ref, disp='F11.7'),
            pf.Column(name=dec_name, format='D', array=dec_ref, disp='F11.7')]
    
    
    # cross identification
    idx_arr = np.empty([n, config_dict['NFILTERS']], dtype=np.int32)
    if flag_exists:
        flags = np.empty([n, config_dict['NFILTERS']], dtype=np.int16)
        flags[:,ref_idx] = ref_flag
        
    r2_rad = config_dict['MATCH_RADIUS']*config_dict['MATCH_RADIUS']
    # print("R2_RAD = ", r2_rad)

    for i in range(config_dict['NFILTERS']):
        if i == ref_idx:
            continue
        filename = config_dict['PHOT_TABLE'][i]
        f = pf.open(filename)
        ra = f[1].data[ra_name]
        dec = f[1].data[dec_name]  
        f.close()

        for j in range(ra_ref.size):            
            idx_arr[j,ref_idx] = j
            # r = np.sqrt((ra-ra_ref[j])**2 + (dec-dec_ref[j])**2)
            r = (ra-ra_ref[j])**2 + (dec-dec_ref[j])**2
            min_i = np.argmin(r)
            # if r[min_i] <= config_dict['MATCH_RADIUS']:
            if r[min_i] <= r2_rad:
                idx_arr[j,i] = min_i
            else:
                idx_arr[j,i] = -1
    
    # print(idx_arr)
    
    for i in range(config_dict['NFILTERS']):
        filename = config_dict['PHOT_TABLE'][i]
        f = pf.open(filename)
        mag = f[1].data[config_dict['MAG_STD_COL']]
        magerr = f[1].data[config_dict['MAGERR_STD_COL']]
        ra = f[1].data[ra_name]
        dec = f[1].data[dec_name]
        if flag_exists:
            flag = f[1].data['FLAGS']
        f.close()
        
        mag_name = config_dict['MAG_STD_COL'] + '_' + config_dict['FILTER'][i]
        magerr_name = config_dict['MAGERR_STD_COL'] + '_' + config_dict['FILTER'][i]
        if i == ref_idx:
            cols.append(pf.Column(name=mag_name, format='D', array=mag, disp='G'))
            cols.append(pf.Column(name=magerr_name, format='D', array=magerr, disp='G'))
        else:
            m = np.empty(ra_ref.size)
            me = np.empty(ra_ref.size)
            r = np.empty(ra_ref.size)
            d = np.empty(ra_ref.size)
            idx_match = idx_arr[:,i] != -1
            m[idx_arr[:,i] == -1] = np.nan
            me[idx_arr[:,i] == -1] = np.nan
            
            r[idx_arr[:,i] == -1] = np.nan
            d[idx_arr[:,i] == -1] = np.nan
            r[idx_arr[idx_match,ref_idx]] = ra[idx_arr[idx_match,i]]
            d[idx_arr[idx_match,ref_idx]] = dec[idx_arr[idx_match,i]]
            
            cols.append(pf.Column(name=ra_name+'_' + config_dict['FILTER'][i], format='D', array=r, disp='F11.7'))
            cols.append(pf.Column(name=dec_name+'_' + config_dict['FILTER'][i], format='D', array=d, disp='F11.7'))
            
            m[idx_arr[idx_match,ref_idx]] = mag[idx_arr[idx_match,i]]
            me[idx_arr[idx_match,ref_idx]] = magerr[idx_arr[idx_match,i]]
            cols.append(pf.Column(name=mag_name, format='D', array=m, disp='G'))
            cols.append(pf.Column(name=magerr_name, format='D', array=me, disp='G'))

            if flag_exists:
                ref_flag[idx_arr[idx_match,ref_idx]] = np.bitwise_or(ref_flag[idx_arr[idx_match,ref_idx]], flag[idx_arr[idx_match,i]])
    
    if flag_exists:
        cols.append(pf.Column(name="FLAGS", format='I', array=ref_flag))
        
    cols_def = pf.ColDefs(cols)
    
    hdu = pf.BinTableHDU.from_columns(cols_def)
    hdu.header['REFIMAGE'] = config_dict['PHOT_TABLE'][ref_idx]
    hdu.writeto(config_dict['IDENT_TABLE'], clobber=True)