import pyfits as pf
import numpy as np

def polarphotLightCurve(filename, *config_dicts):
    #
    #   constuct light curves of objects
    #

    Npoints = len(config_dicts)

    Nmax = 0
    Nmax_idx = 0

    fp = [0]*Npoints
    JD = np.empty((Npoints,config_dicts[0]['NFILTERS']), dtype = np.float64)

    for i in range(Npoints):
        fp[i] = pf.open(config_dicts[i]['COLOR_TABLE'])
        N = fp[i][1].header['NAXIS2']

        if N > Nmax:
            Nmax = N
            Nmax_idx = i
        
        for j in range(config_dicts[i]['NFILTERS']):
            jd = pf.getval(config_dicts[i]['FILE'][j], 'JD')
            JD[i,j] = jd

    fmt = '{}E'.format(config_dicts[0]['NFILTERS']*2) 
    dim = '({},{})'.format(2,config_dicts[0]['NFILTERS']) # FITS 2D-array notation (Ncols, Nrows)


    ref_name = fp[Nmax_idx][1].data['NAME']

    output_cols = [pf.Column(name='NAME', format = 'A{}'.format(len(ref_name[0])), array=ref_name)]

    for flt in config_dicts[0]['FILTER']:
        cname = config_dicts[0]['MAG_STD_COL'] + '_' + flt
        cname_err = config_dicts[0]['MAGERR_STD_COL'] + '_' + flt

        cname_psf = cname + '_PSF'
        cname_err_psf = cname_err + '_PSF'
        # cname_psf = config_dicts[0]['MAG_STD_COL'] + '_' + flt + '_PSF'
        # cname_err_psf = config_dicts[0]['MAGERR_STD_COL'] + '_' + flt + '_PSF'

        light_curve = np.full( (Nmax,config_dicts[0]['NFILTERS'],2), 99.0, dtype = np.float32 )
        light_curve_psf = np.full( (Nmax,config_dicts[0]['NFILTERS'],2), 99.0, dtype = np.float32 )

        for i in range(Npoints):
            if i != Nmax_idx:
                name = fp[i][1].data['NAME']    

            if i == Nmax_idx:
                light_curve[:,i,0] = fp[i][1].data[cname]
                light_curve[:,i,1] = fp[i][1].data[cname_err]
                light_curve_psf[:,i,0] = fp[i][1].data[cname_psf]
                light_curve_psf[:,i,1] = fp[i][1].data[cname_err_psf]
            else:
                for j in range(Nmax):
                    idx = np.where(ref_name[j] == name)[0]
                    if idx.size:
                        # print(name[idx], i)
                        # print(fp[i][1].data[cname][idx])
                        light_curve[j,i,0] = fp[i][1].data[cname][idx]
                        light_curve[j,i,1] = fp[i][1].data[cname_err][idx]
                        light_curve_psf[j,i,0] = fp[i][1].data[cname_psf][idx]
                        light_curve_psf[j,i,1] = fp[i][1].data[cname_err_psf][idx]

        cname = 'LIGHTCURVE_'+flt
        output_cols.append(pf.Column(name = cname, format = fmt, dim = dim, array = light_curve))
        output_cols.append(pf.Column(name = cname+'_PSF', format = fmt, dim = dim, array = light_curve_psf))

    print(output_cols)
    # write table with light curves
    tbl = pf.BinTableHDU.from_columns(output_cols)
    tbl.writeto(filename, clobber = True)
    pf.setval(filename, 'COMMENT', value = 'Light curves', ext=1)

    # write table with JDs

    output_cols = []

    i = 0
    for flt in config_dicts[i]['FILTER']:
        output_cols.append(pf.Column(name = flt, format='D', disp = 'F4.6', array=JD[:,i]))        
        i += 1

    tbl = pf.BinTableHDU.from_columns(output_cols)
    pf.append(filename, tbl.data, tbl.header)
    pf.setval(filename, 'COMMENT', value = 'Julian date')

    for i in range(Npoints):
        fp[i].close()