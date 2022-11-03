import configparser as cp
from validate import Validator, ValidateError
# import math

def process_opt(opt):
    l = opt.replace("\n", "").split(",")
    ll = []
    for str in l:
        str = str.strip()
        ll.append(str)
    return ll


def validateOpt(cfg, name, v_cond):
    vtor = Validator()

    v_conds = list(v_cond)
    if len(v_conds) == 0:
        raise ValidateError

    for vc in v_conds:
        try:
            val = vtor.check(vc, cfg[name])
        except ValidateError:
            validateOpt(cfg, name, v_conds[1:]) # try next condition

    return val

def polarPhotConfig(filename):
    try:    
        config = cp.ConfigParser()
        config.read(filename)    
    except cp.ParsingError:
        print("%s error: An error occured while parsing input config ini-file!" % __name__)
        return {}
        
    if config.sections() == []:
        print("%s error: It seems input config ini-file is empty!" % __name__)
        return {}

    # parse mandatory options
    
    config_dict = {'INI_CONFIG': filename}
    
    try:
        filters = config["filter"]["FILTER"]            
        # filters = filters.replace("\n","").split(",")
        config_dict['FILTER'] = process_opt(filters)
    except cp.NoOptionError:
        print("%s error: There is no filter/FILTER option in config ini-file!" % __name__)
        return {}
        
    try:
        files = config["file"]["FILE"]  
        # files = files.replace("\n", "")
        # files = files.split(",")
        config_dict['FILE'] = process_opt(files)
    except cp.NoOptionError:
        print("%s error: There is no file/FILE option in config ini-file!"  % __name__)
        return {}
       
    if len(config_dict['FILTER']) != len(config_dict['FILE']):
        print("%s warning: Number of filters is not equal to one of input files!" % __name__)
        
    if len(config_dict['FILTER']) <= len(config_dict['FILE']):
        Nfilters = len(config_dict['FILTER'])
    else:
        Nfilters = len(config_dict['FILE'])

    config_dict['NFILTERS'] = Nfilters

    try:
        phot_table = config['result']['PHOT_TABLE']
        # phot_table = phot_table.replace("\n","").split(",")
        phot_table = process_opt(phot_table)
        if len(phot_table) < Nfilters:
            print("%s error: Invalid number of PHOT_TABLE!" % __name__)
            return {}
        config_dict['PHOT_TABLE'] = phot_table
    except cp.NoOptionError:
        print("%s error: There is no result/PHOT_TABLE option in config ini-file!"  % __name__)
        return {}
    except KeyError:
        print("%s error: There is no result/PHOT_TABLE option in config ini-file!"  % __name__)
        return {}

    try:
        ident_table = process_opt(config['result']['IDENT_TABLE'])
        if ident_table == []:
            print("%s error: Invalid value of result/IDENT_TABLE option!"  % __name__)
            return {}
        config_dict['IDENT_TABLE'] = ident_table[0]
    except cp.NoOptionError:
        print("%s error: There is no result/IDENT_TABLE option in config ini-file!"  % __name__)
        return {}
        

    try:
        color_table = config['result']['COLOR_TABLE']            
        # color_table = color_table.replace("\n","").split(",")
        if color_table == []:
                print("%s error: Invalid value of COLOR_TABLE option!" % __name__)
                return {}            
        color_table = process_opt(color_table)
        config_dict['COLOR_TABLE'] = color_table[0]
    except cp.NoOptionError:
        print("%s error: There is no result/COLOR_TABLE option in config ini-file!"  % __name__)
        return {}
    
    try:
        colors = config['result']['COLORS']
        colors = process_opt(colors)
        if colors == []:
                print("%s error: Invalid value of COLORS option!" % __name__)
                return {}            
        cols = []
        for cl in colors:
            cl = cl.strip()
            if len(cl) < 2:
                print("%s error: Invalid value of COLORS option!" % __name__)
                return {}
            try:
                num0 = int(cl[0])
                if num0 > (Nfilters-1):
                    print("%s error: Invalid index of magnitude in COLORS option!" % __name__)
                    return {}
                num1 = int(cl[1])
                if num1 > (Nfilters-1):
                    print("%s error: Invalid index of magnitude in COLORS option!" % __name__)
                    return {}
                cols.append([num0, num1])
            except ValueError:
                print("%s error: Invalid symbol of COLORS option!" % __name__)
                return {}
            
        config_dict['COLORS'] = cols
    except cp.NoOptionError:
        print("%s error: There is no result/COLORS option in config ini-file!"  % __name__)
        return {}
        

    try:
        param_name = process_opt(config['sextractor']['PARAMETERS_NAME'])
        if param_name == []:
            print("%s error: Invalid value of PARAMETER_NAME option!"  % __name__)
            return {}
        config_dict['PARAMETERS_NAME'] = param_name[0]     
    except cp.NoOptionError:
        print("%s error: There is no sextractor/PARAMETER_NAME option in config ini-file!"  % __name__)
        return {}
        
    
    try:
        mag = process_opt(config['sextractor']['MAG'])
        if mag == []:
            print("%s error: Invalid value of MAG option!"  % __name__)
            return {}
        config_dict['MAG'] = mag
    except cp.NoOptionError:
        print("%s error: There is no sextractor/MAG option in config ini-file!"  % __name__)
        return {}
        
        
    try:
        magerr = process_opt(config['sextractor']['MAGERR'])
        if mag == []:
            print("%s error: Invalid value of MAGERR option!"  % __name__)
            return {}
        config_dict['MAGERR'] = magerr
    except cp.NoOptionError:
        print("%s error: There is no sextractor/MAGERR option in config ini-file!"  % __name__)
        return {}

        
    try:
        mag_idx = process_opt(config['sextractor']['MAG_COLOR_IDX'])
        if mag_idx == []:
            print("%s error: Invalid value of MAG_COLOR_IDX option!"  % __name__)
            return {}
        try:
            num = int(mag_idx[0])
        except ValueError:
            print("%s error: Invalid value of MAG_COLOR_IDX option!"  % __name__)
            return {}
            
        config_dict['MAG_COLOR_IDX'] = num
    except cp.NoOptionError:
        print("%s error: There is no sextractor/MAG_COLOR_IDX option in config ini-file!"  % __name__)
        return {}
        
        
    try:
        obj_prefix = process_opt(config['result']['OBJ_NAME_PREFIX'])
        config_dict['OBJ_NAME_PREFIX'] = obj_prefix[0]
    except cp.NoOptionError:
        print("%s error: There is no result/OBJ_NAME_PREFIX option in config ini-file!"  % __name__)
        return {}
    except KeyError:
        print("%s error: There is no result/OBJ_NAME_PREFIX option in config ini-file!"  % __name__)
        return {}
        
    # parse optional 
    
    try:
        color_table_dat = config['result']['COLOR_TABLE_DAT']
        color_table_dat = process_opt(color_table_dat)
        config_dict['COLOR_TABLE_DAT'] = color_table_dat[0]
    except cp.NoOptionError:
        config_dict['COLOR_TABLE_DAT'] = ''
    except KeyError:
        config_dict['COLOR_TABLE_DAT'] = ''
    
    try:
        image_coord = process_opt(config['sextractor']['IMAGE_COORD'])
        if len(image_coord) < 2:
            print("%s error: Invalid number of image coordinates in sextractor/IMAGE_COORD option in config ini-file" % __name__)
            return {}
        config_dict['IMAGE_COORD'] = image_coord[:2]
    except cp.NoOptionError:
        config_dict['IMAGE_COORD'] = ['XWIN_IMAGE', 'YWIN_IMAGE']

    
    try:
        sky_coord = process_opt(config['sextractor']['SKY_COORD'])
        if len(sky_coord) < 2:
            print("%s error: Invalid number of sky coordinates in sextractor/SKY_COORD option in config ini-file" % __name__)
            return {}
        config_dict['SKY_COORD'] = sky_coord[:2]
    except cp.NoOptionError:
        config_dict['SKY_COORD'] = ['ALPHAWIN_J2000', 'DELTAWIN_J2000']

    
    try:
        cmd_pars = process_opt(config['sextractor']['CMDLINE_PARAM'])
        if cmd_pars == []:
            config_dict['CMDLINE_PARAM'] = ['']
        else:
            opts = []
            for opt in cmd_pars:
                l = opt.split()
                for o in l:
                    opts.append(o)
            config_dict['CMDLINE_PARAM'] = opts
    except cp.NoOptionError:
        config_dict['CMDLINE_PARAM'] = ['']
    
    
    try:
        add_pars = process_opt(config['sextractor']['PARAMS'])
        if add_pars == []:
            add_pars = ['']
        config_dict['PARAMS'] = add_pars
    except cp.NoOptionError:
        config_dict['PARAMS'] = ['']
    
    
    try:
        zero_point = config["calibration"]["zero_point"]
        try:
            # l = zero_point.split(",")
            l = process_opt(zero_point)
            zp = []
            for v in l:
                zp.append(float(v))
            zero_point = zp
            if len(zero_point) < Nfilters:
                print("%s error: Invalid length of zero point option in config ini-file!" % __name__)
                return {}            
        except ValueError:
            print("%s error: Invalid zero point option in config ini-file!" % __name__)
            return {}  
    except cp.NoOptionError:
        zero_point = [0.0]*Nfilters
        
    config_dict['ZERO_POINT'] = zero_point
        
    try:
        zero_point_err = config["calibration"]["zero_point_err"]
        try:
            # l = zero_point_err.split(",")
            l = process_opt(zero_point_err)
            zp = []
            for v in l:
                zp.append(float(v))
            zero_point_err = zp
            if len(zero_point_err) < Nfilters:
                print("%s error: Invalid length of zero point error option in config ini-file!" % __name__)
                return {}            
        except ValueError:
            print("%s error: Invalid zero point error option in config ini-file!" % __name__)
            return {}  
    except cp.NoOptionError:
        zero_point_err = [0.0]*Nfilters
        
    config_dict['ZERO_POINT_ERR'] = zero_point_err


    try:
        extin_coeff = config["calibration"]["extin_coeff"]
        try:
            # l = extin_coeff.split(",")
            l = process_opt(extin_coeff)
            ec = []
            for v in l:
                ec.append(float(v))
            extin_coeff = ec
            if len(extin_coeff) < Nfilters:
                print("%s error: Invalid length of extinction coefficient option in config ini-file!" % __name__)
                return {}
        except ValueError:
            print("%s error: Invalid extinction coefficient option in config ini-file!" % __name__)
            return {}      
    except cp.NoOptionError:
        extin_coeff = [0.0]*Nfilters
        
    config_dict['EXTIN_COEFF'] = extin_coeff
    
    try:
        match_radius = config["calibration"]["match_radius"]
        try:
            # l = match_radius.split(",")
            l = process_opt(match_radius)
            match_radius = float(l[0])
        except ValueError:
            print("%s error: Invalid match_radius option in config ini-file!" % __name__)
            return {}
    except cp.NoOptionError:
        match_radius = 1.4E-4 # 0.5 arcsec
    
    config_dict['MATCH_RADIUS'] = match_radius
    
    
    try:
        mag_std_col = config["calibration"]["MAG_STD_COL"]
        mag_std_col = process_opt(mag_std_col)
        if mag_std_col == []:
            config_dict['MAG_STD_COL'] = 'MAG_STD'
        else:
            config_dict['MAG_STD_COL'] = mag_std_col[0]
    except cp.NoOptionError:
        config_dict['MAG_STD_COL'] = 'MAG_STD'
    except KeyError:
        config_dict['MAG_STD_COL'] = 'MAG_STD'
    
    try:
        magerr_std_col = config["calibration"]["MAGERR_STD_COL"]
        magerr_std_col = process_opt(magerr_std_col)
        if magerr_std_col == []:
            config_dict['MAGERR_STD_COL'] = 'MAGERR_STD'
        else:
            config_dict['MAGERR_STD_COL'] = magerr_std_col[0]
    except cp.NoOptionError:
        config_dict['MAGERR_STD_COL'] = 'MAGERR_STD'
    except KeyError:
        config_dict['MAGERR_STD_COL'] = 'MAGERR_STD'
    
    try:
        weight_file = process_opt(config['sextractor']['WEIGHT_FILE'])
        if len(weight_file) < Nfilters:
            print("%s error: Invalid number of weight files!" % __name__)
            return {}
        config_dict['WEIGHT_FILE'] = weight_file[:Nfilters]
        
        try:
            weight_thresh = process_opt(config['sextractor']['WEIGHT_THRESH'])
            if weight_thresh == []:
                config_dict['WEIGHT_THRESH'] = 0.0
            else:
                try:
                    num = float(weight_thresh[0])
                    config_dict['WEIGHT_THRESH'] = num
                except ValueError:
                    print("%s error: Ivalid value of WEIGHT_THRESH option!" % __name__)
                    return {}
        except cp.NoOptionError:
            config_dict['WEIGHT_THRESH'] = 0.0
            
        try:
            weight_type = process_opt(config['sextractor']['WEIGHT_TYPE'])            
            if weight_type == []:
                config_dict['WEIGHT_TYPE'] = 'MAP_WEIGHT'
            else:
                config_dict['WEIGHT_TYPE'] = weight_type[0]
        except cp.NoOptionError:
            config_dict['WEIGHT_TYPE'] = 'MAP_WEIGHT'
    except cp.NoOptionError:
        config_dict['WEIGHT_FILE'] = ['']
    except KeyError:
        config_dict['WEIGHT_FILE'] = ['']
    

    try:
        color_dat_del = config['result']['COLOR_TABLE_DAT_DEL']
        color_dat_del = color_dat_del.split()
        if color_dat_del == []:
            config_dict['COLOR_TABLE_DAT_DEL'] = ' '
        else:
            config_dict['COLOR_TABLE_DAT_DEL'] = str(color_dat_del[0][0])
            
    except cp.NoOptionError:
        config_dict['COLOR_TABLE_DAT_DEL'] = ','
    except KeyError:
        config_dict['COLOR_TABLE_DAT_DEL'] = ','
        
        
    # try:
    #     detect_minarea = config["sextractor"]["DETECT_MINAREA"]
    #     detect_minarea = detect_minarea.split(",")
    #     detect_minarea = float(detect_minarea[0])
    # except cp.NoOptionError:
    #     detect_minarea = math.nan
        
    # try:
    #     detect_thresh = config["sextractor"]["DETECT_THRESH"]
    #     detect_thresh = detect_thresh.split(",")
    #     detect_thresh = float(detect_thresh[0])
    # except cp.NoOptionError:
    #     detect_thresh = math.nan
        
    # try:
    #     analysis_thresh = config["sextractor"]["ANALYSIS_THRESH"]
    #     analysis_thresh = analysis_thresh.split(",")
    #     analysis_thresh = float(analysis_thresh[0])
    # except cp.NoOptionError:
    #     analysis_thresh = math.nan

    return config_dict 


def polarPhotCreateIniConfig(filename, delimiter=',', **kwargs):
    # use only first character in delimiter string!!!
    
    if len(delimiter) == 0:
        delimiter = ','
    
    # create an config dictionary with some default values
    config_dict = {
            'NFILTER': 0,
            # "filter" section
            'FILTER': [''],
            # "file" section
            'FILE': [''],
            # "sextractor" section
            'PARAMETERS_NAME': '',
            'IMAGE_COORD': ['XWIN_IMAGE', 'YWIN_IMAGE'],
            'SKY_COORD': ['ALPHAWIN_J2000', 'DELTAWIN_J2000'],
            'MAG': 'MAG_BEST',
            'MAGERR': 'MAGERR_BEST',
            'MAG_COLOR_IDX': 0,
            'CMDLINE_PARAM': [''],
            'PARAMS': ['FLAGS'],
            'WEIGHT_FILE': [''],
            'WEIGHT_THRESH': 0,
            'WEIGHT_TYPE': 'MAP_WEIGHT',
            # "calibration" section
            'MATCH_RADIUS': 0.00014,
            'EXTIN_COEFF': '',
            'ZERO_POINT': '',
            'ZERO_POINT_ERR': '',
            # "result" section
            'OBJ_NAME_PREFIX': '',
            'MAG_STD_COL': ['MAG_STD'],
            'MAGERR_STD_COL': ['MAGERR_STD'],
            'COLORS': [''],
            'PHOT_TABLE': [''],
            'IDENT_TABLE': '',
            'COLOR_TABLE': '',
            'COLOR_TABLE_DAT': '',
            'COLOR_TABLE_DAT_DEL': ' '
    }
    
    section_n = [0, 1, 2, 13, 17]
    section = ['[filter]', '[file]', '[sextractor]', '[calibration]', '[result]']
    config_keys = list(config_dict.keys())
       
    # user values
    for key, value in kwargs.items():
        try:
            kwd = key.upper()
            idx = config_keys.index(kwd)
            if kwd != 'NFILTER':
                config_dict[kwd] = value
        except ValueError:
            continue
    
    # write to file
    
    file = open(filename, 'w')
       
    i = 0
    sec_i = 0
    for key, value in config_dict.items():
        if key == 'NFILTER':
            continue 
        
        if i == section_n[sec_i]:
            file.write('\n\n' + section[sec_i] + '\n')
            sec_i += 1
            if sec_i == len(section):
                sec_i -= 1
        
        if type(value) == type(''):
            file.write('{0} = {1}\n'.format(key, value))
        else:
            try:
                iter(value)
            except TypeError: # just try to convert to string as is
                file.write('{0} = {1}\n'.format(key, str(value)))                
            else: # value is iterable, try to convert elements to string
                s = ""
                for el in value:
                    s += str(el) + delimiter[0] + ' '
                s = s[:-2] # delete last delimiter and whitespace
                file.write('{0} = {1}\n'.format(key, s))
        i += 1
        
    file.close()
    
    config_dict['NFILTER'] = len(config_dict['FILE'])