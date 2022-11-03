import CCDPACK as ccd
import sexpy
import pyfits as pf
import numpy as np


def polarPhotCreateFindFile(config_dict):
	#
	# create "find" image from input "measurement" images
	# "measurement" images must be WCS-calibrated!
	#

	ref_idx = 0
	sum_image, hdr = pf.getdata(config_dict['FILE'][ref_idx], header = True)

	if sum_image is None:
		print('polarPhotCreateFindFile: Exit due to previous errors!')
		return

	tr_coeffs = []

	for idx in range(config_dict['NFILTERS']):
		if idx == ref_idx:
			continue

		image, coeffs = ccd.ccdpackAlignWcsImage(config_dict['FILE'][ref_idx], config_dict['FILE'][idx], None, \
			match_radius = config_dict["MATCH_RADIUS"]*3600.0, transf_coeffs = True)

		sum_image += image
		tr_coeffs.append(coeffs)

	hdr.add_history('-'*70, after=-1)
	hdr.add_history('Find image (Python "polarphot" module)')
	hdr.add_history('Input images: ' + ', '.join(config_dict['FILE']))
	hdr.add_history('Reference image: ' + config_dict['FILE'][ref_idx])
	hdr.add_history('-'*70)

	pf.writeto(config_dict['FINDFILE'], sum_image, header = hdr, clobber = True) # preserve WCS-info from reference image
	
	# write coefficients
	i = 0
	for idx in range(config_dict['NFILTERS']):
		if idx == ref_idx:
			continue

		pf.append(config_dict['FINDFILE'], np.asarray(tr_coeffs[i]))
		pf.setval(config_dict['FINDFILE'], 'INDEX', value = idx, comment = 'Index value of transformed image', ext = i+1)
		pf.setval(config_dict['FINDFILE'], 'COMMENT', value = 'Transformation coefficients for image: ' + config_dict['FILE'][idx], ext = i+1)
		i += 1

def polarPhotFindObjects(config_dict):
	#
	# run SExtractor's search in find image
	#

	sex = sexpy.Sextractor()

	for opt in config_dict['CMDLINE_PARAM']:
		l = opt.split()
		if len(l) == 1:
			print('polarPhotFindObjects: invalid "CMDLINE_PARAM" config option! Exit!')
			return
		sex[l[0].strip()] = l[1].strip()

	sex['CATALOG_TYPE'] = 'FITS_1.0'
	sex['CATALOG_NAME'] = config_dict['IDENT_TABLE']

	# sex['PARAMETERS_NAME'] = config_dict['PARAMETERS_NAME']

	sex.params("NUMBER")
	sex.addParams(config_dict['IMAGE_COORD'])
	sex.addParams(config_dict['SKY_COORD'])
	sex.addParams("FWHM_IMAGE")

	sex(config_dict['FINDFILE'], del_cat = False)