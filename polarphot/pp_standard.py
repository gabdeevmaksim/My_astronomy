import astromatic as ast
import pyfits as pf
import numpy as np
import tempfile


def polarPhotStandardPhotometry(conf_dicts):
    #
    #
    #

    if type(conf_dicts) == dict:
        conf = [conf_dicts]
    elif type(conf_dicts) == list:
        conf = conf_dicts
    else:
        print('polarPhotStandardPhotometry: "conf_dicts" parameter must be a list or dictionaty! Exit!')
        return 1

    N_conf = len(conf)

    sex = ast.Sextractor()


    sex['CATALOG_TYPE'] = 'FITS_1.0'
    sex['FILTER'] = 'N'


    for i in range(N_conf):
        params = ['NUMBER', conf[i]['IMAGE_COORD'][0], conf[i]['IMAGE_COORD'][1], \
                  conf[i]['SKY_COORD'][0], conf[i]['SKY_COORD'][1]]

        for j in range(len(conf[i]['MAG'])):
            params.append(conf[i]['MAG'][j])
            params.append(conf[i]['MAGERR'][j])
        for str in conf[i]['PARAMS']:
            params.append(str)

        sex.params(params)

        sex['PARAMETERS_NAME'] = conf[i]['PARAMETERS_NAME']

        if conf[i]['WEIGHT_FILE'][0] != '':
            sex['WEIGHT_THRESH'] = conf[i]['WEIGHT_THRESH']
            sex['WEIGHT_TYPE'] = conf[i]['WEIGHT_TYPE']

        for j in range(conf[i]['NFILTERS']):
            sex['CATALOG_NAME'] = conf[i]['PHOT_TABLE'][j] 
            if conf[i]['WEIGHT_FILE'][0] != '':
                sex['WEIGHT_IMAGE'] = conf[i]['WEIGHT_FILE'][j]

            sex_cfg = tempfile.mkstemp(suffix = '.sex', dir = '.') # unique temporary filename
            sex_cfg = sex_cfg[1]

            ex = None
            try: # run SExtractor
                sex(conf[i]['FILE'][j], config_filename = sex_cfg, del_cat = False, sex_cmdline_opts = conf[i]['CMDLINE_PARAM'])
            except amt.AstromaticException as exc:
                ex = exc
            except amt.SextractorException as exc:
                ex = exc

            if ex is not None:
                print('\npolarPhotStandardPhotometry: SExtractor error occured while creating photometry catalog {}!'.format(conf[i]['PHOT_TABLE'][j]))
                print('polarPhotStandardPhotometry: Error code {}'.format(ex.error()))
                stat = ex.procStatus()
                if stat is not None:
                    print('polarPhotStandardPhotometry: process status {}'.format(stat))
                print('polarPhotStandardPhotometry: Stop photometry!')
                return 1

    return 0


def polarPhotStandardIdent(conf_dicts, coords):
    #
    #
    #

    if type(conf_dicts) == dict:
        conf = [conf_dicts]
    elif type(conf_dicts) == list:
        conf = conf_dicts
    else:
        print('polarPhotStandardIdent: "conf_dicts" parameter must be a list or dictionaty! Exit!')
        return 1

    N_conf = len(conf)


    # k = int(len(output_cols)/conf[0]['NFILTERS'])

    idx_col = np.empty((N_conf,conf[0]['NFILTERS']), dtype = np.int64)
    ra_col = np.empty((N_conf,conf[0]['NFILTERS']), dtype = np.float64)
    dec_col = np.empty((N_conf,conf[0]['NFILTERS']), dtype = np.float64)
    x_col = np.empty((N_conf,conf[0]['NFILTERS']), dtype = np.float64)
    y_col = np.empty((N_conf,conf[0]['NFILTERS']), dtype = np.float64)

    for i in range(N_conf):
        match_radius2 = conf[i]['MATCH_RADIUS'][0]**2

        for j in range(conf[i]['NFILTERS']):
            fp = pf.open(conf[i]['PHOT_TABLE'][j])
            ra = fp[1].data[conf[i]['SKY_COORD'][0]]
            dec = fp[1].data[conf[i]['SKY_COORD'][1]]
            x = fp[1].data[conf[i]['IMAGE_COORD'][0]]
            y = fp[1].data[conf[i]['IMAGE_COORD'][1]]
            fp.close()

            r2 = (coords[0] - ra)**2 + (coords[1] - dec)**2
            idx = np.argmin(r2)
            if r2[idx] <= match_radius2:
                idx_col[i,j] = idx
                ra_col[i,j] = ra[idx]
                dec_col[i,j] = dec[idx]
                x_col[i,j] = x[idx]
                y_col[i,j] = y[idx]
                # ii = j*k
                # output_cols[ii].array = np.array([idx])
                # output_cols[ii+1].array = np.array([ra[idx]])
                # output_cols[ii+2].array = np.array([dec[idx]])
                # output_cols[ii+3].array = np.array([x[idx]])
                # output_cols[ii+4].array = np.array([y[idx]])
            else:
                print('polarPhotStandardIdent: cannot identificate object in {} catalog! Exit!'.format(conf[i]['PHOT_TABLE'][j]))
                return 1

        # if os.path.exists(conf[i]['IDENT_TABLE']):
        #     os.remove(conf[i]['IDENT_TABLE'])

    output_cols = []
    for i in range(conf[0]['NFILTERS']):
        cname = 'IDX_{}'.format(conf[0]['FILTER'][i])
        output_cols.append(pf.Column(name=cname, format="J", array = idx_col[:,i]))

        cname_ra = '{}_{}'.format(conf[0]['SKY_COORD'][0], conf[0]['FILTER'][i])
        cname_dec = '{}_{}'.format(conf[0]['SKY_COORD'][1], conf[0]['FILTER'][i])

        cname_x = '{}_{}'.format(conf[0]['IMAGE_COORD'][0], conf[0]['FILTER'][i])
        cname_y = '{}_{}'.format(conf[0]['IMAGE_COORD'][1], conf[0]['FILTER'][i])

        output_cols.append(pf.Column(name=cname_ra, format="D", disp='F11.7', array = ra_col[:,i]))
        output_cols.append(pf.Column(name=cname_dec, format="D", disp='F11.7', array = dec_col[:,i]))
        output_cols.append(pf.Column(name=cname_x, format="D", disp='F8.3', array = x_col[:,i]))
        output_cols.append(pf.Column(name=cname_y, format="D", disp='F8.3', array = y_col[:,i]))

    tbl = pf.BinTableHDU.from_columns(output_cols)
    tbl.writeto(conf[0]['IDENT_TABLE'], clobber = True)

    return 0


def polarPhotStandardZeroPoints(conf_dicts, std_mags, exptime_kwd = 'EXPTIME', zendist_kwd = 'Z'):
    #
    #
    #

    if type(conf_dicts) == dict:
        conf = [conf_dicts]
    elif type(conf_dicts) == list:
        conf = conf_dicts
    else:
        print('polarPhotStandardZeroPoints: "conf_dicts" parameter must be a list or dictionaty! Exit!')
        return None

    N_conf = len(conf)

    inst_mags = np.empty((N_conf, conf[0]['NFILTERS']), dtype = np.float32)
    zero_points = np.empty(conf[0]['NFILTERS'], dtype = np.float32)

    fp = pf.open(conf[0]['IDENT_TABLE'])
    ident_i = fp[1].data
    fp.close()

    k = int(ident_i[0].end/conf[0]['NFILTERS'])

    for i in range(N_conf):
        mag_i = conf[i]['MAG_COLOR_IDX']

        for j in range(conf[i]['NFILTERS']):
            fp = pf.open(conf[i]['PHOT_TABLE'][j])
            mag = fp[1].data[conf[i]['MAG'][mag_i]]
            magerr = fp[1].data[conf[i]['MAGERR'][mag_i]]
            fp.close()

            mag = mag[ident_i[i][j*k]]
            magerr = magerr[ident_i[i][j*k]]

            exptime = pf.getval(conf[i]['FILE'][j], exptime_kwd)
            Z = pf.getval(conf[i]['FILE'][j], zendist_kwd)


            # mag += 2.5*np.log10(exptime) - conf[i]['EXTIN_COEFF'][j]
            inst_mags[i,j] = mag + 2.5*np.log10(exptime) - conf[i]['EXTIN_COEFF'][j]/np.cos(Z*np.pi/180.0)

    # print(inst_mags)
    mag = np.mean(inst_mags, axis=0)
    magerr = np.std(inst_mags, axis=0)

    print('Standard instrumental manitudes: ')
    for i in range(mag.size):
        print('\t{:8.4f} +/- {:6.4f}'.format(mag[i],magerr[i]))

    zero_points = std_mags - mag

    print('Photometric zero points:')
    for i in range(mag.size):
        print('\t{:7.4f} +/- {:6.4f}'.format(zero_points[i],magerr[i]))

    return {'ZERO_POINT':zero_points, 'ZERO_POINT_ERR':magerr}