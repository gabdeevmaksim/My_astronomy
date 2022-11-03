import CCDPACK as ccd
import MMPP
import subprocess as sp
import pyfits as pf
from .pp_const import __pp_filter

def convToStrList(par):
	if isinstance(par, str):
		return [par]
	else:
		try:
			it = iter(par)
			ll = []
			for el in par:
				ll.append(str(el))
			return ll
		except TypeError:
			return [str(par)]


def polarPhotReduction(night_info, calib_info, filter_name = __pp_filter, obj_name = None):
	#
	#	Standard basic reduction sequence for polars photonetry package.
	#	It includes de-biasing, correction for flat field, cosmic hits filtering 
	#	and WCS-calibration
	#
	#	The function returns MMPP reduction sequence dictionary or None in the case of errors
	#


	valid_names = MMPP.mmpp_night_info_objects(night_info, exp_type = MMPP.__exptype_obj)

	if obj_name is not None:
		objs = convToStrList(obj_name)
		i = 0
		for obj in objs:
			if obj not in valid_names:
				print("polarPhotReduction: cannot find object name {} in night info! Skip it!".format(obj))
				del objs[i]
			else:
				i += 1

		if len(objs) == 0:
			print("polarPhotReduction: invalid object name list! Exit!")
			return None
	else:
		objs = valid_names


	valid_filter = MMPP.mmpp_night_info_filters(night_info, exp_type = MMPP.__exptype_obj, device_mode = MMPP.__device_mode_phot, \
		obj_name = objs)

	if filter_name is not None:
		flts = convToStrList(filter_name)
		i = 0
		for flt in flts:
			if flt not in valid_filter:
				print('polarPhotReduction: cannot find filter name {} in night info! Skip it!'.format(flt))
				del flts[i]
			else:
				i += 1
		if len(flts) == 0:
			print("polarPhotReduction: invalid filter name list! Exit!")
			return None
	else:
		flts = valid_filter

	for flt in flts:
		if flt not in calib_info['FILTER']:
			print('polarPhotReduction: cannot find filter name {} in calibration info! Exit!'.format(flt))
			return None

	id_name = ['WEIGHT', 'WCS']
	prefix = ['weight_', 'wcs_']

	reduc_info = MMPP.mmpp_reduc_seq(night_info, filter=flts, obj_name=objs, device_mode=MMPP.__device_mode_phot, \
		add_name=id_name, add_name_prefix=prefix)

	if reduc_info is None:
		print("polarPhotReduction: cannot create reduction sequence! Exit!")
		return None

	wcs_cmd = ['mmpp_ast_solution.py', '', '', '-T']

	for flt in reduc_info.keys():
		flt_idx = calib_info['FILTER'].index(flt)
		try:
			flat_name = calib_info['FLAT_NAME'][flt_idx]
		except IndexError:
			print("polarPhotReduction: invalid calibration info! Cannot find flat field corresponded to {} filter name! Exit!".format(flt))
			return None

		for obj in reduc_info[flt].keys():
			for i in range(len(reduc_info[flt][obj][MMPP.__red_seq_key_raw])):
				raw_file = reduc_info[flt][obj][MMPP.__red_seq_key_raw][i]
				red_file = reduc_info[flt][obj][MMPP.__red_seq_key_red][i]
				weight_file = reduc_info[flt][obj]['WEIGHT'][i]
				wcs_file = reduc_info[flt][obj]['WCS'][i]

				if ccd.ccdpackFitsReduction(raw_file, red_file, calib_info['BIAS_NAME'], flat_name):
					print("polarPhotReduction: cannot process {} raw file! Exit!".format(raw_file))
					return None

				ret = ccd.ccdpackLacosmicx(red_file, red_file, mask_filename = weight_file, add_mask_filename = flat_name, \
					cosmic_value = -1.0E-10, gain = 1.1, readnoise = 2.4)
				if ret is None:
					print("polarPhotReduction: cosmic hits filtering failed for {} reduced file! Exit!".format(red_file))
					return None

				# for astrometry.net solve-field use of '-T' (no SIP polynomial) since SExtrator cannot work with it
				wcs_cmd[1] = red_file
				wcs_cmd[2] = wcs_file
				ret = sp.run(wcs_cmd, stdout=sp.PIPE, stderr=sp.PIPE)

				# ret = ccd.ccdpackAstrometryNet(red_file, wcs_file, user_opts = ['--use-sextractor', '-p', '-O', '-L', '0.2', '-H', '1.0', '-u', \
				# 	'app', '-5', '0.5', '-R', 'none', '-B', 'none', '-M', 'none', '-S', 'none', '--temp-axy', '-U', 'none', '--crpix-center', '-T'])
				if ret.returncode != 0:
					print("polarPhotReduction: WCS-calibration failed for reduced file {}! Skip!".format(red_file))

	return reduc_info