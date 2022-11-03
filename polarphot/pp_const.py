#
#	Some constants for MMPP Polars Photometry package
#

# filters of survey

__pp_filter = ['470', '540', '656']
__pp_colors = ['01', '12', '02']

# extinction coefficients (not measured but computed from SAO RAS extinction curve!!!)

__pp_extin_coeff = [0.397547, 0.283614, 0.200239]


# defaults for values of photometry configuration

__pp_config_defaults = {"OBJ_NAME_PREFIX": "3BS",
                        "COLOR_TABLE_DAT_DEL": ',', 
                        "WEIGHT_THRESH": 0, 
                        "PARAMS": ['SNR_WIN', 'FWHM_IMAGE', 'KRON_RADIUS', 'AWIN_IMAGE', 'BWIN_IMAGE', 'FLAGS'],
                        "CMDLINE_PARAM": ['-DETECT_MINAREA 10', '-DETECT_THRESH 3.0', '-FILTER Y', '-PHOT_APERTURES 40', '-GAIN 1.1', '-SATUR_LEVEL 60000'],
                        "MAG": ['MAG_BEST', 'MAG_APER', 'MAG_PETRO'], 
                        "MAGERR": ['MAGERR_BEST', 'MAGERR_APER', 'MAGERR_PETRO'], 
                        "MATCH_RADIUS": 0.0007}


__polarPhotConfigDesc = {'NFILTERS': ('integer(min=3)', 3),
                         'FILTER': ('string_list(min=3)', __pp_filter),
                         'FILE': ('string_list(min=3)',),
                         'PARAMETERS_NAME': ('string', ''),
                         'IMAGE_COORD': ('string_list(min=2)', ['XWIN_IMAGE', 'YWIN_IMAGE']),
                         'SKY_COORD': ('string_list(min=2)', ['ALPHAWIN_J2000', 'DELTAWIN_J2000']),
                         'MAG': (['string_list(min=1)', 'string(min=1)'], 'MAGERR_BEST'),
                         'MAGERR': (['string_list(min=1)', 'string(min=1)'], 'MAGERR_BEST'),
                         'MAG_COLOR_IDX': ('integer(min=0)', 0),
                         'CMDLINE_PARAM': (['string_list(min=1)', 'string'], ''), # additional SExtractor's commandline arguments
                         'PARAMS': (['string_list(min=1)', 'string'], ''), # additional SExtractor's output parameters
                         'WEIGHT_FILE': (['string_list(min=3)', 'string'], ''),
                         'WEIGHT_THRESH': ('float', 0),
                         'WEIGHT_TYPE': ('option(NONE, BACKGROUND, MAP_RMS, MAP_VAR, MAP_WEIGHT)', 'MAP_WEIGHT'),
                         'PSFEX_CMDLINE_PARAM': (['string_list', 'string'], ''), # PSFEx additional commandline arguments
                         'VIGNET_SIZE': ('int_list(min=2)', [50,50]),  # SExtractor's VIGNET_SIZE parameter for PSFEx input catalog
                         'PHOT_APERTURES': ('integer(min=2)', 40),    # SExtractors's PHOT_APERTURES config parameter for flux measurements used in PSFEx input catalog
                         'N_FWHM': ('float(min=1.0)', 4.0),           # number of FWHM to compute PHOT_APERTURES config parameter for flux measurements used in PSFEx input catalog
                         'MATCH_RADIUS': ('float_list(min=2)', [0.00014, 1.5]),  # match radius to match objects in measurement catalogs ( 0 - in units of SKY_COORD, 1 - in pixels)
                         'POLYDEG': ('int_list(min=2)', [1,1]),        # degrees of 2D-polynomial for coordinate system transformation in matching algorithm
                         'NITER': ('integer', 5),              # maximal number of iterations for coordinate system transformation in matching algorithm
                         'EXTIN_COEFF': ('float_list(min=3)', [0.0, 0.0, 0.0]),
                         'ZERO_POINT': ('float_list(min=3)', [0.0, 0.0, 0.0]),
                         'ZERO_POINT_ERR': ('float_list(min=3)', [0.0, 0.0, 0.0]),
                         'OBJ_NAME_PREFIX': ('string(min=1)', '3BS '),
                         'MAG_STD_COL': ('string(min=1)', 'MAG_STD'),
                         'MAGERR_STD_COL': ('string(min=1)', 'MAGERR_STD'),
                         'COLORS': ('string_list(min=2)', __pp_colors),
                         'PHOT_TABLE': ('string_list(min=3)',),
                         'IDENT_TABLE': ('string(min=1)',),
                         'COLOR_TABLE': ('string(min=1)',),
                         'COLOR_TABLE_DAT': ('string', ''),
                         'COLOR_TABLE_DAT_DEL': ('string(min=1)', ',')
}

# __polarPhotConfigCycleKeys = ['FILE', 'WEIGHT_FILE', 'PHOT_TABLE'] # keys in each cycle description
__polarPhotConfigCycleKeys = {'FILE': True, 'WEIGHT_FILE': False, 'PHOT_TABLE': True} # keys in each cycle description
																					  # True - mandatory, Flase - optional
__polarPhotConfigCycleTitle = 'CYCLE'
