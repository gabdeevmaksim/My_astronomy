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

def polarPhotCatalog(conf_dict, exptime_kwd = 'EXPTIME', zendist_kwd = 'Z'):
	#
    #
    #

    # read ident table
    fp = pf.open(conf_dict['IDENT_TABLE'])

    ref_idx = fp[0].header['REF-IDX']

    max_N_obj = fp[1].header['NAXIS2']
    match_idx = np.empty((max_N_obj,conf_dict['NFILTERS']), dtype = np.int64)


    for i in range(conf_dict['NFILTERS']):
        cname = 'IDX_{}'.format(conf_dict['FILTER'][i])
        match_idx[:,i] = fp[1].data[cname]

    # 08.11.2019: correct x, y, RA and DEC 
    x = fp[1].data[ conf_dict['IMAGE_COORD'][0]+'_'+conf_dict['FILTER'][ref_idx] ]
    y = fp[1].data[ conf_dict['IMAGE_COORD'][1]+'_'+conf_dict['FILTER'][ref_idx] ]
    ra = fp[1].data[ conf_dict['SKY_COORD'][0]+'_'+conf_dict['FILTER'][ref_idx] ]
    dec = fp[1].data[ conf_dict['SKY_COORD'][1]+'_'+conf_dict['FILTER'][ref_idx] ]

    fp.close()

    # x, y, ra, dec from reference catalog

    x_name = conf_dict['IMAGE_COORD'][0]
    y_name = conf_dict['IMAGE_COORD'][1]
    ra_name = conf_dict['SKY_COORD'][0] 
    dec_name = conf_dict['SKY_COORD'][1] 

    # fp = pf.open(conf_dict['PHOT_TABLE'][ref_idx])

    # x = fp[1].data[ x_name ]
    # y = fp[1].data[ y_name ]
    # ra = fp[1].data[ ra_name ]
    # dec = fp[1].data[ dec_name ] # !!!!!!!!! REARRANGE ARRAY ACCORDING TO MATCH TABLE !!!!

    # fp.close()

    name = ['']*x.size
    for i in range(x.size):
        [ra_str, dec_str] = deg2six(ra[i], dec[i])
        name[i] = '{}J{}{}'.format(conf_dict['OBJ_NAME_PREFIX'], ra_str, dec_str)

    fmt = "A%d" % len(name[0])

    output_cols = [pf.Column(name = 'NAME', format = fmt, array = name), \
                   pf.Column(name = x_name, format="D", disp='F10.3', array=x), \
                   pf.Column(name = y_name, format="D", disp='F10.3', array=y), \
                   pf.Column(name = ra_name, format="D", disp='F11.7', array=ra), \
                   pf.Column(name = dec_name, format="D", disp='F11.7', array=dec)]

    # coefficients from SExtractor documentation: https://sextractor.readthedocs.io/en/latest/Model.html#model-based-star-galaxy-separation-spread-model
    spread_k = 4.0
    spread_eps = 5.0E-3

    mag_i = conf_dict['MAG_COLOR_IDX']

    mag = np.full((max_N_obj,conf_dict['NFILTERS']), 99.0, dtype=np.float32)
    mag_err = np.full((max_N_obj,conf_dict['NFILTERS']), 99.0, dtype=np.float32)

    mag_psf = np.full((max_N_obj,conf_dict['NFILTERS']), 99.0, dtype=np.float32)
    mag_psf_err = np.full((max_N_obj,conf_dict['NFILTERS']), 99.0, dtype=np.float32)
    # mag = np.full((max_N_obj,conf_dict['NFILTERS']), np.nan, dtype=np.float32)
    # mag_err = np.full((max_N_obj,conf_dict['NFILTERS']), np.nan, dtype=np.float32)

    # mag_psf = np.full((max_N_obj,conf_dict['NFILTERS']), np.nan, dtype=np.float32)
    # mag_psf_err = np.full((max_N_obj,conf_dict['NFILTERS']), np.nan, dtype=np.float32)

    # spread = np.full((max_N_obj,conf_dict['NFILTERS']), np.nan, dtype=np.float32)
    # spread_err = np.full((max_N_obj,conf_dict['NFILTERS']), np.nan, dtype=np.float32)
    obj_class = np.full((max_N_obj,conf_dict['NFILTERS']), 'U', dtype = np.dtype(str))

    flag = np.full((max_N_obj,conf_dict['NFILTERS']), 0, dtype=np.int8)


    for i in range(conf_dict['NFILTERS']):
        fp = pf.open(conf_dict['PHOT_TABLE'][i])
        Nobj = fp[1].header['NAXIS2']

        # object class:  'S' - stellar, 'E' - extended        
        spread = fp[1].data['SPREAD_MODEL']
        spread_err = fp[1].data['SPREADERR_MODEL']

        sp_thresh = np.sqrt(spread_eps**2 + (spread_k*spread_err)**2) # formula from PSFex manual!

        cl = np.where(spread > sp_thresh, 'E', 'S')

        ids = np.where(match_idx[:,i] > -1)[0]

        obj_class[ids,i] = cl[match_idx[ids,i]]

        mag[ids, i] = (fp[1].data[conf_dict['MAG'][mag_i]])[match_idx[ids,i]]
        mag_err[ids, i] = (fp[1].data[conf_dict['MAGERR'][mag_i]])[match_idx[ids,i]]

        mag_psf[ids, i] = (fp[1].data['MAG_PSF'])[match_idx[ids,i]]
        mag_psf_err[ids, i] = (fp[1].data['MAGERR_PSF'])[match_idx[ids,i]]

        # mag_psf[mag_psf[:,i] > 90, i] = np.nan
        # mag_psf_err[mag_psf[:,i] > 90, i] = np.nan

        flag[ids, i] = (fp[1].data['FLAGS'])[match_idx[ids,i]]

        fp.close()

        # compute standard magnitudes

        good_idx = np.where(mag[:,i] < 99.0)[0] 
        good_idx_psf = np.where(mag_psf[:,i] < 99.0)[0] # SExtractor's special value

        texp = pf.getval(conf_dict['FILE'][i], exptime_kwd)
        Z = pf.getval(conf_dict['FILE'][i], zendist_kwd)
        
        mag_corr = 2.5*np.log10(texp) - conf_dict['EXTIN_COEFF'][i]/np.cos(Z*np.pi/180.0) + conf_dict['ZERO_POINT'][i]
        # print(mag[20,i], mag_corr, conf_dict['EXTIN_COEFF'][i], conf_dict['ZERO_POINT'][i])
        # print(2.5*np.log10(texp), np.cos(Z*np.pi/180.0))

        mag[good_idx,i] += mag_corr
        mag_err[good_idx,i] = np.sqrt( mag_err[good_idx,i]**2 + conf_dict['ZERO_POINT_ERR'][i]**2)
        mag_psf[good_idx_psf,i] += mag_corr
        mag_psf_err[good_idx_psf,i] = np.sqrt( mag_psf_err[good_idx_psf,i]**2 + conf_dict['ZERO_POINT_ERR'][i]**2)

        # mag[:,i] += mag_corr
        # mag_err[:,i] = np.sqrt( mag_err[:,i]**2 + conf_dict['ZERO_POINT_ERR'][i]**2)
        # mag_psf[:,i] += mag_corr
        # mag_psf_err[:,i] = np.sqrt( mag_psf_err[:,i]**2 + conf_dict['ZERO_POINT_ERR'][i]**2)



    # compute colors

    N_cols = len(conf_dict['COLORS'])
    col_idx = conf_dict['COLORS']

    col = np.empty( (max_N_obj,N_cols), dtype = np.float32)
    col_err = np.empty( (max_N_obj,N_cols), dtype = np.float32)

    col_psf = np.empty( (max_N_obj,N_cols), dtype = np.float32)
    col_psf_err = np.empty( (max_N_obj,N_cols), dtype = np.float32)

    for i in range(N_cols):
        # good_idx = np.where( (mag[:,col_idx[i][0]] < 99.0) & (mag[:,col_idx[i][1]] < 99.0) )[0]
        # good_idx_psf = np.where( (mag_psf[:,col_idx[i][0]] < 99.0) & (mag_psf[:,col_idx[i][1]] < 99.0) )[0]

        good_idx = np.bitwise_and(mag[:,col_idx[i][0]] < 99.0, mag[:,col_idx[i][1]] < 99.0)
        good_idx_psf = np.bitwise_and(mag_psf[:,col_idx[i][0]] < 99.0, mag_psf[:,col_idx[i][1]] < 99.0)

        col[:,i] = np.where(good_idx, mag[:,col_idx[i][0]] - mag[:,col_idx[i][1]], 99.0)
        col_err[:,i] = np.where(good_idx, np.sqrt( mag_err[:,col_idx[i][0]]**2 + mag_err[:,col_idx[i][1]]**2 ), 99.0)
        col_psf[:,i] = np.where(good_idx_psf, mag_psf[:,col_idx[i][0]] - mag_psf[:,col_idx[i][1]], 99.0)
        col_psf_err[:,i] = np.where(good_idx_psf, np.sqrt( mag_psf_err[:,col_idx[i][0]]**2 + mag_psf_err[:,col_idx[i][1]]**2 ), 99.0)

        # col[:,i] = mag[:,col_idx[i][0]] - mag[:,col_idx[i][1]]
        # col_err[:,i] = np.sqrt( mag_err[:,col_idx[i][0]]**2 + mag_err[:,col_idx[i][1]]**2 )
        # col_psf[:,i] = mag_psf[:,col_idx[i][0]] - mag_psf[:,col_idx[i][1]]
        # col_psf_err[:,i] = np.sqrt( mag_psf_err[:,col_idx[i][0]]**2 + mag_psf_err[:,col_idx[i][1]]**2 )

    for i in range(conf_dict['NFILTERS']):
        # mag[np.isnan(mag)] = 99.00
        # mag_err[np.isnan(mag_err)] = 99.00
        # mag_psf[np.isnan(mag_psf)] = 99.00
        # mag_psf_err[np.isnan(mag_psf_err)] = 99.00
        # mag_psf[mag_psf > 100] = 99.00

        mag_cname = '{}_{}'.format(conf_dict['MAG_STD_COL'], conf_dict['FILTER'][i])
        magerr_cname = '{}_{}'.format(conf_dict['MAGERR_STD_COL'], conf_dict['FILTER'][i])

        output_cols.append(pf.Column(name=mag_cname, format='E', disp = 'F6.3', array = mag[:,i]))
        output_cols.append(pf.Column(name=magerr_cname, format='E', disp = 'F5.3', array = mag_err[:,i]))

        mag_cname = '{}_{}_PSF'.format(conf_dict['MAG_STD_COL'], conf_dict['FILTER'][i])
        magerr_cname = '{}_{}_PSF'.format(conf_dict['MAGERR_STD_COL'], conf_dict['FILTER'][i])

        output_cols.append(pf.Column(name=mag_cname, format='E', disp = 'F6.3', array = mag_psf[:,i]))
        output_cols.append(pf.Column(name=magerr_cname, format='E', disp = 'F5.3', array = mag_psf_err[:,i]))


    for i in range(N_cols):
        col[np.isnan(col)] = 99.00
        col_err[np.isnan(col_err)] = 99.00
        col_psf[np.isnan(col_psf)] = 99.00
        col_psf_err[np.isnan(col_psf_err)] = 99.00

        col_cname = '{}-{}'.format(conf_dict['FILTER'][col_idx[i][0]], conf_dict['FILTER'][col_idx[i][1]])
        col_err_cname = 'ERR_{}'.format(col_cname)

        output_cols.append(pf.Column(name=col_cname, format='D', disp='G', array = col[:,i]))
        output_cols.append(pf.Column(name=col_err_cname, format='D', disp='G', array = col_err[:,i]))

        col_cname = '{}-{}_PSF'.format(conf_dict['FILTER'][col_idx[i][0]], conf_dict['FILTER'][col_idx[i][1]])
        col_err_cname = 'ERR_{}'.format(col_cname)

        output_cols.append(pf.Column(name=col_cname, format='D', disp='G', array = col_psf[:,i]))
        output_cols.append(pf.Column(name=col_err_cname, format='D', disp='G', array = col_psf_err[:,i]))



    for i in range(conf_dict['NFILTERS']):
        cname = 'CLASS_{}'.format(conf_dict['FILTER'][i])
        output_cols.append(pf.Column(name=cname, format='A', array = obj_class[:,i]))

    for i in range(conf_dict['NFILTERS']):
        cname = 'FLAG_{}'.format(conf_dict['FILTER'][i])
        output_cols.append(pf.Column(name=cname, format='I', array = flag[:,i]))


    tbl = pf.BinTableHDU.from_columns(output_cols)
    tbl.writeto(conf_dict['COLOR_TABLE'], clobber=True)

