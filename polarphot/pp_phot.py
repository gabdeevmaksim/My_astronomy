import subprocess as sp
import copy
import pyfits as pf
import math
import numpy as np
import warnings

def polarPhotPhotometry(config_dict):
    warnings.filterwarnings('ignore')
    sex_cmd = ['sex']
    for opts in config_dict['CMDLINE_PARAM']:
        sex_cmd.append(opts.strip())
        
    sex_cmd.append('-PARAMETERS_NAME')
    sex_cmd.append(config_dict['PARAMETERS_NAME'])
    
    sex_cmd.append('-CATALOG_TYPE')
    sex_cmd.append('FITS_1.0')
    
    # write param file
    pars_file = open(config_dict['PARAMETERS_NAME'], "w")
    
    pars_file.write("NUMBER")
    pars_file.write("\n")
    pars_file.write(config_dict['IMAGE_COORD'][0])
    pars_file.write("\n")
    pars_file.write(config_dict['IMAGE_COORD'][1])
    pars_file.write("\n")
    pars_file.write(config_dict['SKY_COORD'][0])
    pars_file.write("\n")
    pars_file.write(config_dict['SKY_COORD'][1])
    pars_file.write("\n")
    for i in range(len(config_dict['MAG'])):
        pars_file.write(config_dict['MAG'][i])    
        pars_file.write("\n")
        pars_file.write(config_dict['MAGERR'][i])    
        pars_file.write("\n")
    for str in config_dict['PARAMS']:
        pars_file.write(str)        
        pars_file.write("\n")
        
    pars_file.close()
    
    
    for i in range(config_dict['NFILTERS']):
        s_cmd = copy.deepcopy(sex_cmd)
        s_cmd.append('-CATALOG_NAME')
        s_cmd.append(config_dict['PHOT_TABLE'][i])
        if config_dict['WEIGHT_FILE'][0] != '':
            s_cmd.append('-WEIGHT_IMAGE')
            s_cmd.append(config_dict['WEIGHT_FILE'][i])
            s_cmd.append('-WEIGHT_THRESH')
            s = "%g" % config_dict['WEIGHT_THRESH']
            s_cmd.append(s)
            s_cmd.append('-WEIGHT_TYPE')
            s_cmd.append(config_dict['WEIGHT_TYPE'])
        s_cmd.append(config_dict['FILE'][i])
        # print(' '.join(s_cmd))
        # print(s_cmd)
        # ret = sp.call(s_cmd)
        ret = sp.run(s_cmd)
        # ret = sp.run(' '.join(s_cmd), shell=True)
        if ret.returncode != 0:
            print("%s error: SExtractor exited with error code %d" % (__name__, ret.returncode))
            return ret.returncode
        
        # compute standard magnitudes
        
        mag_col = config_dict['MAG'][config_dict['MAG_COLOR_IDX']]
        magerr_col = config_dict['MAGERR'][config_dict['MAG_COLOR_IDX']]
        
        fim = pf.open(config_dict['FILE'][i])
        Z = fim[0].header['Z']
        texp = fim[0].header['EXPTIME']
        fim.close()
        
        ftable_name = config_dict['PHOT_TABLE'][i].strip()
        ftable = pf.open(ftable_name)
        
        mag_std = ftable[1].data[mag_col] + config_dict['ZERO_POINT'][i] - config_dict['EXTIN_COEFF'][i]/math.cos(Z*3.14159/180) + 2.5*math.log10(texp)
        magerr_std = np.array(ftable[1].data[magerr_col])**2
        magerr_std = np.sqrt(magerr_std + config_dict['ZERO_POINT_ERR'][i]**2)
        
        t_cols = ftable[1].columns
        new_cols = pf.ColDefs([pf.Column(name=config_dict['MAG_STD_COL'], format='D', array=mag_std),
                               pf.Column(name=config_dict['MAGERR_STD_COL'], format='D', array=magerr_std)])
        ftable.close()
        
        hdu = pf.BinTableHDU.from_columns(t_cols + new_cols)
        hdu.writeto(ftable_name, clobber=True)
        
    return ret.returncode