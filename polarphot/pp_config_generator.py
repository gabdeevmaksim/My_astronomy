import MMPP
import math
import pathlib as pl
from .pp_configparser import polarPhotCreateIniConfig

#
#
#

def polarPhotGenerateConfig(red_info, obj_name, ini_file_rootname, filters = ['470', '540', '656'], colors = ['01', '12', '02'], \
						    phot_suffix = "phot", ident_suffix = 'ident', color_suffix = "color", \
							phot_ext = "fits", ident_ext = "fits", color_ext = "fits", color_dat_ext = "dat", \
							use_mask = True, use_wcs = True, params_file_ext = "param", **kwargs):
	# try:
	# 	it = iter(filters)
	# 	if len(filters) < 2:
	# 		print('polarPhotGenerateConfig: At least two filter names must be given! Exit!')
	# 		return
	# 	for el in filters:
	# 		if not isinstance(el, 'str'):
	# 			print('polarPhotGenerateConfig: filter name must be a string! Exit!')
	# 			return
	# except TypeError:
	# 	print('polarPhotGenerateConfig: "filters" parameter must be a list of strings! Exit!')
	# 	return


	flts = list(red_info.keys())
	if len(flts) < 2:
		print('polarPhotGenerateConfig: At least two filter names must exist in reduction info! Exit!')
		return

	Nfiles = []

	# check for filters and object existance

	for f in filters:
		if f not in flts:
			print('polarPhotGenerateConfig: cannot find "{}" filter name in reduction info! Exit!'.format(f))
			return
		if obj_name.strip() not in red_info[f].keys():
			print('polarPhotGenerateConfig: cannot find "{}" object name in reduction info! Exit!'.format(obj_name))
			return

		if use_mask:
			# if len(red_info[f][obj_name][MMPP.__red_seq_key_mask]) == 0:
			if len(red_info[f][obj_name][MMPP.__red_seq_key_weight]) == 0:
				print('polarPhotGenerateConfig: mask images are not present in reduction info! Exit!')
				return
		if use_wcs:
			if len(red_info[f][obj_name][MMPP.__red_seq_key_wcs]) == 0:
				print('polarPhotGenerateConfig: WCS images are not present in reduction info! Exit!')
				return

		N = len(red_info[f][obj_name][MMPP.__red_seq_key_red])
		if N == 0:
			print('polarPhotGenerateConfig: reduced images are not present in reduction info! Exit!')
			return

		Nfiles.append(N)

	# find number of full blocks of filters

	N = float("inf")
	for i in Nfiles:
		if i < N:
			N = i


	# create INI-config files

	ini_files = []

	# mask_files = [""]

	p = pl.Path(ini_file_rootname)
	pp = p.parent
	name = p.stem
	ext = p.suffix

	root_name = str(pl.PurePath.joinpath(pp, name))

	if N > 1:		
		Ndigits = math.floor(math.log10(N))+1
		dig_fmt = "{{:0{}d}}".format(Ndigits)
	else: 
		ini_file = ini_file_rootname
		ident_file = root_name + '_' + ident_suffix + '.' + ident_ext
		color_file = root_name + '_' + color_suffix + '.' + color_ext
		color_dat_file = root_name + '_' + color_suffix + '.' + color_dat_ext
		param_file = root_name + '.' + params_file_ext

	for i in range(N):
		if N > 1:
			dig_str = dig_fmt.format(i+1)
			ini_file = root_name + '_' + dig_str + ext
			ident_file = root_name + '_' + ident_suffix + '_' + dig_str + '.' + ident_ext
			color_file = root_name + '_' + color_suffix + '_' + dig_str + '.' + color_ext
			color_dat_file = root_name + '_' + color_suffix + '_' + dig_str + '.' + color_dat_ext
			param_file = root_name + '_' + dig_str + '.' + params_file_ext


		input_files = []		
		phot_files = []
		mask_files = []

		for f in filters:
			if use_wcs:
				ifile = red_info[f][obj_name][MMPP.__red_seq_key_wcs][i]
			else:
				ifile = red_info[f][obj_name][MMPP.__red_seq_key_red][i]
			input_files.append(ifile)

			if use_mask:
				# mask_files.append(red_info[f][obj_name][MMPP.__red_seq_key_mask][i])
				mask_files.append(red_info[f][obj_name][MMPP.__red_seq_key_weight][i])

			p1 = pl.Path(ifile)
			pp1 = p1.parent
			pname = p1.stem + "_" + phot_suffix + "." + phot_ext

			pname = str(pl.PurePath.joinpath(pp1, pname))

			phot_files.append(pname)

		ini_files.append(ini_file)

		polarPhotCreateIniConfig(ini_file, FILE = input_files, FILTER = filters, COLORS = colors, WEIGHT_FILE = mask_files, PHOT_TABLE = phot_files, \
			IDENT_TABLE = ident_file, COLOR_TABLE = color_file, COLOR_TABLE_DAT = color_dat_file, PARAMETERS_NAME = param_file, **kwargs)

	return ini_files