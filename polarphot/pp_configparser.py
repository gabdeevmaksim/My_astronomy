import configobj as co
from validate import Validator, ValidateError

def polarPhotGetDefaultConfig():
    # create an config dictionary with some default values
    config_dict = {
            'INI_CONFIG': '',
            'NFILTERS': 0,
            'FILTER': '',    # list of filter names
            'FILE': '',      # list of measurement images filenames corresponded to FILTER list of filter names
            # 'FINDFILE': '',  # filename of combined find-image (sum of measurement images)
            # 'REF_IDX': 0,    # index of reference image to produce FIND_FILE (to be used to align measurement images)
            'PARAMETERS_NAME': '',
            'IMAGE_COORD': ['XWIN_IMAGE', 'YWIN_IMAGE'],
            'SKY_COORD': ['ALPHAWIN_J2000', 'DELTAWIN_J2000'],
            'MAG': ['MAG_BEST'],
            'MAGERR': ['MAGERR_BEST'],
            'MAG_COLOR_IDX': 0,
            'CMDLINE_PARAM': '', # additional SExtractor's commandline arguments
            'PARAMS': ['SNR_WIN'], # additional SExtractor's output parameters
            'WEIGHT_FILE': [''],
            'WEIGHT_THRESH': 0,
            'WEIGHT_TYPE': 'MAP_WEIGHT',
            'PSFEX_CMDLINE_PARAM': '', # PSFEx additional commandline arguments
            'VIGNET_SIZE': [50,50],  # SExtractor's VIGNET_SIZE parameter for PSFEx input catalog
            'PHOT_APERTURES': 40,    # SExtractors's PHOT_APERTURES config parameter for flux measurements used in PSFEx input catalog
            'N_FWHM': 4.0,           # number of FWHM to compute PHOT_APERTURES config parameter for flux measurements used in PSFEx input catalog
            'MATCH_RADIUS': [0.00014, 1.5],  # match radius to match objects in measurement catalogs ( 0 - in units of SKY_COORD, 1 - in pixels)
            'POLYDEG': [1,1],        # degrees of 2D-polynomial for coordinate system transformation in matching algorithm
            'NITER': 5,              # maximal number of iterations for coordinate system transformation in matching algorithm
            'EXTIN_COEFF': '',
            'ZERO_POINT': '',
            'ZERO_POINT_ERR': '',
            'OBJ_NAME_PREFIX': '',
            'MAG_STD_COL': 'MAG_STD',
            'MAGERR_STD_COL': 'MAGERR_STD',
            'COLORS': '',
            'PHOT_TABLE': '',
            'IDENT_TABLE': '',
            'COLOR_TABLE': '',
            'COLOR_TABLE_DAT': '',
            'COLOR_TABLE_DAT_DEL': ' '
    }
    
    return config_dict    


#
#   Create and save user configuration INI-file
#
def polarPhotCreateIniConfig(filename, **kwargs):
    config_dict = polarPhotGetDefaultConfig()
    config_dict['INI_CONFIG'] = filename

    config_keys = list(config_dict.keys())
       
    # user values
    for key, value in kwargs.items():
        try:
            kwd = key.upper()
            config_keys.index(kwd)
            if kwd != 'NFILTERS' and kwd != 'INI_CONFIG_FILENAME' :
                config_dict[kwd] = value
        except ValueError:
            continue

    config_dict['NFILTERS'] = len(config_dict['FILTER'])
    if config_dict['EXTIN_COEFF'] == '':
        config_dict['EXTIN_COEFF'] = [0.0]*config_dict['NFILTERS']
    if config_dict['ZERO_POINT'] == '':
        config_dict['ZERO_POINT'] = [0.0]*config_dict['NFILTERS']
    if config_dict['ZERO_POINT_ERR'] == '':
        config_dict['ZERO_POINT_ERR'] = [0.0]*config_dict['NFILTERS']

    # write to file

    config = co.ConfigObj(config_dict, write_empty_values=True)
    config.filename = filename
    
    config.write()


#
#   Read and parse user configuration INI-file
#    
def polarPhotConfig(filename):
    try:
        config = co.ConfigObj(filename, file_error=True)
    except IOError:
        print("%s error: An error occured while opening input config ini-file!" % __name__)
        return {}
    except co.ParseError:
        print("%s error: An error occured while parsing input config ini-file!" % __name__)
        return {}
    # except co.ConfigObjError:    
    #     print("%s error: An error occured while parsing input config ini-file!" % __name__)
    #     return {}

    # parse mandatory options
    
    config_dict = polarPhotGetDefaultConfig()
    config_dict['INI_CONFIG'] = filename
    
    vtor = Validator()
    
    error_nokey = lambda keyname: print('%s error: Invalid value of %s mandatory option in config ini-file!' % ( __name__, keyname))
    error_invalid = lambda keyname: print("%s error: Invalid value of %s option!" % ( __name__, keyname))
    
    try:
        filter = vtor.check('string_list(min=2)', config['FILTER'])
        
        Nfilter = len(filter)
    except ValidateError:
        error_invalid('FILTER')
        return {}
    except KeyError:
        error_nokey('FILTER')
        return {}
            
    try:
        file = vtor.check('string_list(min=2)', config['FILE'])
        
        if Nfilter != len(file):
            print('%s warning: Number of elements in FILTER and FILE options is not equal!' % __name__)
            
        if Nfilter >= len(file):
            Nfilter = len(file)
            
        config_dict['NFILTERS'] = Nfilter
        config_dict['FILTER'] = filter
        config_dict['FILE'] = file
    except ValidateError:
        error_invalid('FILE')
        return {}
    except KeyError:
        error_nokey('FILE')
        return {}


    # try:
    #     config_dict['FIND_FILE'] = vtor.check('string(min=1)', config['FIND_FILE'])   
    # except ValidateError:
    #     error_invalid('FIND_FILE')
    #     return {}
    # except KeyError:
    #     error_nokey('FIND_FILE')
    #     return {}
    

           
    try:
        config_dict['PARAMETERS_NAME'] = vtor.check('string(min=1)', config['PARAMETERS_NAME'])   
    except ValidateError:
        error_invalid('PARAMETERS_NAME')
        return {}
    except KeyError:
        error_nokey('PARAMETERS_NAME')
        return {}
    
    
    try:
        config_dict['IMAGE_COORD'] = vtor.check('string_list(min=2)', config['IMAGE_COORD'])   
    except ValidateError:
        error_invalid('IMAGE_COORD')
        return {}
    except KeyError:
        error_nokey('IMAGE_COORD')
        return {}
            
    try:
        config_dict['SKY_COORD'] = vtor.check('string_list(min=2)', config['SKY_COORD'])   
    except ValidateError:
        error_invalid('SKY_COORD')
        return {}
    except KeyError:
        error_nokey('SKY_COORD')
        return {}
        
    
    try:
        config_dict['MAG'] = vtor.check('string_list(min=1)', config['MAG'])
    except ValidateError: # is it just string?
        try:
            config_dict['MAG'] = [vtor.check('string(min=1)', config['MAG'])]
        except ValidateError:
            error_invalid('MAG')
            return {}
    except KeyError:
        error_nokey('MAG')
        return {}

            
    try:
        config_dict['MAGERR'] = vtor.check('string_list(min=1)', config['MAGERR'])
    except ValidateError: # is it just string?
        try:
            config_dict['MAGERR'] = [vtor.check('string(min=1)', config['MAGERR'])]
        except ValidateError:
            error_invalid('MAGERR')
            return {}
    except KeyError:
        error_nokey('MAGERR')
        return {}
        
    
    try:
        config_dict['COLORS'] = vtor.check('string_list(min=1)', config['COLORS'])              
    except ValidateError: # is it just string?
        try:
            config_dict['COLORS'] = [vtor.check('string(min=1)', config['COLORS'])]
        except ValidateError:
            error_invalid('COLORS')
            return {}
    except KeyError:
        error_nokey('COLORS')
        return {}
    
    cols = config_dict['COLORS']
    config_dict['COLORS'] = []
    for col in cols:
        if len(col) < 2:
            error_invalid('COLORS')
            return {}
        try:
            col1 = int(col[0])
            col2 = int(col[1])
            config_dict['COLORS'].append([col1,col2])
        except ValueError:
            error_invalid('COLORS')
            return {}
                
    
    try:
        config_dict['PHOT_TABLE'] = vtor.check('string_list(min=2)', config['PHOT_TABLE'])
        if len(config_dict['PHOT_TABLE']) < Nfilter:
            print('%s error: Invalid number of files in PHOT_TABLE option!' % __name__)
            return {}
    except ValidateError:
        error_invalid('PHOT_TABLE')
        return {}
    except KeyError:
        error_nokey('PHOT_TABLE')
        return {}
        

    try:
        config_dict['IDENT_TABLE'] = vtor.check('string(min=1)', config['IDENT_TABLE'])   
    except ValidateError:
        error_invalid('IDENT_TABLE')
        return {}
    except KeyError:
        error_nokey('IDENT_TABLE')
        return {}
        
    
    try:
        config_dict['COLOR_TABLE'] = vtor.check('string(min=1)', config['COLOR_TABLE'])   
    except ValidateError:
        error_invalid('COLOR_TABLE')
        return {}
    except KeyError:
        error_nokey('COLOR_TABLE')
        return {}
        
    
    #
    # parse optionals
    #
    
    # try:
    #     ref_idx = vtor.check('integer(min=0)', config['REF_IDX'])
    #     if ref_idx >= config_dict['NFILTERS']:
    #         error_invalid('REF_IDX')
    #         return {}
    # except ValidateError:
    #     error_invalid('REF_IDX')
    #     return {}
    # except KeyError:
    #     pass


    try:
        config_dict['MAG_COLOR_IDX'] = vtor.check('integer(min=0)', config['MAG_COLOR_IDX'])   
    except ValidateError:
        error_invalid('MAG_COLOR_IDX')
        return {}
    except KeyError:
        pass        
    
    try:
        # config_dict['CMDLINE_PARAM'] = vtor.check('string_list(min=1)', config['CMDLINE_PARAM'])
        cmd_pars = vtor.check('string_list(min=1)', config['CMDLINE_PARAM'])
        config_dict['CMDLINE_PARAM'] = []
        for pars in cmd_pars:
            l = pars.split()
            if len(l) < 2:
                continue
            if l[0][0] != '-':
                continue
            config_dict['CMDLINE_PARAM'].append(l[0])
            config_dict['CMDLINE_PARAM'].append(l[1])
    except ValidateError: # is it just string?
        try:
            # config_dict['CMDLINE_PARAM'] = [vtor.check('string(min=1)', config['CMDLINE_PARAM'])]
            config_dict['CMDLINE_PARAM'] = [vtor.check('string(min=0)', config['CMDLINE_PARAM'])]
        except ValidateError:
            error_invalid('CMDLINE_PARAM')
            return {}
    except KeyError:
        pass        
    
    try:
        cmd_pars = vtor.check('string_list(min=1)', config['PSFEX_CMDLINE_PARAM'])
        config_dict['PSFEX_CMDLINE_PARAM'] = []
        for pars in cmd_pars:
            l = pars.split()
            if len(l) < 2:
                continue
            if l[0][0] != '-':
                continue
            # print(l)
            config_dict['PSFEX_CMDLINE_PARAM'].append(l[0])
            config_dict['PSFEX_CMDLINE_PARAM'].append(l[1])
    except ValidateError: # is it just string?
        try:
            # config_dict['PSFEX_CMDLINE_PARAM'] = [vtor.check('string(min=1)', config['PSFEX_CMDLINE_PARAM'])]
            config_dict['PSFEX_CMDLINE_PARAM'] = [vtor.check('string(min=0)', config['PSFEX_CMDLINE_PARAM'])]
        except ValidateError:
            error_invalid('PSFEX_CMDLINE_PARAM')
            return {}
    except KeyError:
        pass        

    
    try:
        config_dict['PARAMS'] = vtor.check('string_list(min=1)', config['PARAMS'])
    except ValidateError: # is it just string?
        try:
            config_dict['PARAMS'] = [vtor.check('string(min=1)', config['PARAMS'])]
        except ValidateError:
            error_invalid('PARAMS')
            return {}
    except KeyError:
        pass        
    
    try:
        config_dict['WEIGHT_FILE'] = vtor.check('string_list(min=2)', config['WEIGHT_FILE'])   
        
        if len(config_dict['WEIGHT_FILE']) < Nfilter:
            print('%s error: Invalid number of files in WEIGHT_FILE option!' % __name__)
            return {}
        
        try:
            config_dict['WEIGHT_THRESH'] = vtor.check('float(min=0)', config['WEIGHT_THRESH'])   
        except ValidateError:
            error_invalid('WEIGHT_THRESH')
            return {}
        except KeyError:
            pass
        
        try:
            config_dict['WEIGHT_TYPE'] = vtor.check('option(NONE, BACKGROUND, MAP_RMS, MAP_VAR, MAP_WEIGHT)', config['WEIGHT_TYPE'])   
        except ValidateError:
            error_invalid('WEIGHT_TYPE')
            return {}
        except KeyError:
            pass
        
    except ValidateError:
        error_invalid('WEIGHT_FILE')
        return {}
    except KeyError:
        pass
    

    # try:
    #     config_dict['MATCH_RADIUS'] = vtor.check('float(min=1.0E-30)', config['MATCH_RADIUS'])   
    # except ValidateError:
    #     error_invalid('MATCH_RADIUS')
    #     return {}
    # except KeyError:
    #     pass
    try:
        config_dict['MATCH_RADIUS'] = vtor.check('float_list(min=2)', config['MATCH_RADIUS'])   
        if ( config_dict['MATCH_RADIUS'][0] <= 0.0 ) | ( config_dict['MATCH_RADIUS'][1] <= 0.0 ):
            error_invalid('MATCH_RADIUS')
            return {}            
    except ValidateError:
        error_invalid('MATCH_RADIUS')
        return {}
    except KeyError:
        pass
    
    
    try:
        config_dict['EXTIN_COEFF'] = vtor.check('float_list(min=2)', config['EXTIN_COEFF'])   
        
        if len(config_dict['EXTIN_COEFF']) < Nfilter:
            print('%s error: Invalid number of values in EXTIN_COEFF option!' % __name__)
            return {}            
    except ValidateError:
        error_invalid('EXTIN_COEFF')
        return {}
    except KeyError:
       config_dict['EXTIN_COEFF'] = [0.0]*Nfilter
       
       
    try:
        config_dict['ZERO_POINT'] = vtor.check('float_list(min=2)', config['ZERO_POINT'])   
        
        if len(config_dict['ZERO_POINT']) < Nfilter:
            print('%s error: Invalid number of values in ZERO_POINT option!' % __name__)
            return {}            
    except ValidateError:
        error_invalid('ZERO_POINT')
        return {}
    except KeyError:
       config_dict['ZERO_POINT'] = [0.0]*Nfilter

    
    try:
        config_dict['ZERO_POINT_ERR'] = vtor.check('float_list(min=2)', config['ZERO_POINT_ERR'])   
        
        if len(config_dict['ZERO_POINT_ERR']) < Nfilter:
            print('%s error: Invalid number of values in ZERO_POINT_ERR option!' % __name__)
            return {}            
    except ValidateError:
        error_invalid('ZERO_POINT_ERR')
        return {}
    except KeyError:
       config_dict['ZERO_POINT_ERR'] = [0.0]*Nfilter
    

    try:
        config_dict['OBJ_NAME_PREFIX'] = vtor.check('string(min=0)', config['OBJ_NAME_PREFIX'])
    except ValidateError:
        error_invalid('OBJ_NAME_PREFIX')
        return {}
    except KeyError:
        pass        

    
    try:
        config_dict['MAG_STD_COL'] = vtor.check('string(min=1)', config['MAG_STD_COL'])
    except ValidateError:
        error_invalid('MAG_STD_COL')
        return {}
    except KeyError:
        pass        

    
    try:
        config_dict['MAGERR_STD_COL'] = vtor.check('string(min=1)', config['MAGERR_STD_COL'])
    except ValidateError:
        error_invalid('MAGERR_STD_COL')
        return {}
    except KeyError:
        pass        
    

    try:
        config_dict['COLOR_TABLE_DAT'] = vtor.check('string(min=1)', config['COLOR_TABLE_DAT'])
    except ValidateError:
        error_invalid('COLOR_TABLE_DAT')
        return {}
    except KeyError:
        pass        
    

    try:
        config_dict['COLOR_TABLE_DAT_DEL'] = vtor.check('string(min=1)', config['COLOR_TABLE_DAT_DEL'])
    except ValidateError:
        error_invalid('COLOR_TABLE_DAT_DEL')
        return {}
    except KeyError:
        pass        
    

    try: 
        config_dict['VIGNET_SIZE'] = vtor.check('float_list(min=2)', config['VIGNET_SIZE'])   
        
        if (config_dict['VIGNET_SIZE'][0] <= 1) | (config_dict['VIGNET_SIZE'][1] <= 1):
            print('%s error: VIGNET_SIZE option must be array of numbers greater or equal 1!' % __name__)
            return {}     

        for i in range(2): # be sure vignet size is integer numbers
            config_dict['VIGNET_SIZE'][i] = int(config_dict['VIGNET_SIZE'][i])
    except ValidateError:
        error_invalid('VIGNET_SIZE')
        return {}
    except KeyError:
       pass


    try:
        config_dict['PHOT_APERTURES'] = vtor.check('float(min=1.0E-30)', config['PHOT_APERTURES'])
    except ValidateError:
        error_invalid('PHOT_APERTURES')
    except KeyError:
        pass

    try:
        config_dict['N_FWHM'] = vtor.check('float(min=1.0E-30)', config['N_FWHM'])
    except ValidateError:
        error_invalid('N_FWHM')
    except KeyError:
        pass


    try:
        config_dict['POLYDEG'] = vtor.check('int_list(min=2)', config['POLYDEG'])
        if ( config_dict['POLYDEG'][0] < 0 ) | ( config_dict['POLYDEG'][1] < 0 ):
            error_invalid('POLYDEG')
            return {}    
    except ValidateError:
        error_invalid('POLYDEG')
        return {}
    except KeyError:
        pass


    try:
        config_dict['NITER'] = vtor.check('integer(min=1)', config['NITER'])   
    except ValidateError:
        error_invalid('NITER')
        return {}
    except KeyError:
        pass
    


    return config_dict    