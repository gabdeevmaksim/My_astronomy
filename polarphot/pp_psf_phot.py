import astromatic as amt
import tempfile
import pathlib as pl
import pyfits as pf
import warnings
import CCDPACK as ccd
import numpy as np

def polarPhotPsfPhot(conf_dict, verbose = True):
	#
	#
	#

	warnings.filterwarnings('ignore')

	# SExtractor measurements for PSFEx
	sex = amt.Sextractor(full = True)

	pars = ['X_IMAGE', 'Y_IMAGE', \
			'FLUX_RADIUS', 'SNR_WIN', \
			'FLUX_APER(1)', 'FLUXERR_APER(1)', \
			'ELONGATION', 'FLAGS']
	vgn = 'VIGNET({},{})'.format(conf_dict['VIGNET_SIZE'][0], conf_dict['VIGNET_SIZE'][1]) # ADD TO CONFIG!!!!!
	pars.append(vgn)

	sex.params(pars)

	sex['CATALOG_TYPE'] = 'FITS_LDAC'
	sex['PARAMETERS_NAME'] = conf_dict['PARAMETERS_NAME']

	# sex['PHOT_APERTURES'] = conf_dict['PHOT_APERTURES'] # ADD TO CONFIG!!!!!

	if conf_dict['WEIGHT_FILE'][0] != '':
		sex['WEIGHT_THRESH'] = conf_dict['WEIGHT_THRESH']
		sex['WEIGHT_TYPE'] = conf_dict['WEIGHT_TYPE']

	if verbose:
		print('START PSF PHOTOMETRY ...')
		print('\tCreate PSFEx input catalogs:')

	sex_cfg = tempfile.mkstemp(suffix = '.sex', dir = '.') # unique temporary filename
	sex_cfg = sex_cfg[1]

	fwhm_est = np.empty(conf_dict['NFILTERS'], dtype = np.float32)

	for i in range(conf_dict['NFILTERS']):	
		sex['CATALOG_NAME'] = conf_dict['PHOT_TABLE'][i] # temporary use of name of final measurements catalog!!!
		if conf_dict['WEIGHT_FILE'][0] != '':
			sex['WEIGHT_IMAGE'] = conf_dict['WEIGHT_FILE'][i]

		# estimate FWHM and compute aperture size for PSF scaling
		fwhm_est[i] = ccd.ccdpackEstimateFWHM(conf_dict['FILE'][i], sex_cmdline_opts = '-DETECT_THRESH 10 -DETECT_MINAREA 5')
		sex['PHOT_APERTURES'] = np.ceil(conf_dict['N_FWHM']*fwhm_est[i])

		if verbose:
			print("\t\t{}".format(conf_dict['FILE'][i]), end = '     ')

		if verbose:
			print('(FWHM = {:4.1f}, scaling aperture = {})'.format(fwhm_est[i], sex['PHOT_APERTURES']), end = '   ')

		ex = None
		try: # run SExtractor
			sex(conf_dict['FILE'][i], config_filename = sex_cfg, del_cat = False, sex_cmdline_opts = conf_dict['CMDLINE_PARAM'])
		except amt.AstromaticException as exc:
			ex = exc
		except amt.SextractorException as exc:
			ex = exc

		if ex is not None:
			print('\npolarPhotPsfPhot: SExtractor error occured while creating PSFEx input catalog {}!'.format(conf_dict['PHOT_TABLE'][i]))
			print('polarPhotPsfPhot: Error code {}'.format(ex.error()))
			stat = ex.procStatus()
			if stat is not None:
				print('polarPhotPsfPhot: process status {}'.format(stat))
			print('polarPhotPsfPhot: Stop photometry!')
			return 1

		if verbose:
			print('OK!')
			nobj = pf.getval(conf_dict['PHOT_TABLE'][i], 'NAXIS2', ext=2)
			print("\t\t\tfound {} objects".format(nobj))


	if verbose:
		print('\n\tFit and compute PSF image:')

	psfex = amt.PSFEx(full = True)
	psfex['PSF_SIZE'] = '40,40'

	try:
		idx = conf_dict['PSFEX_CMDLINE_PARAM'].index('-PSF_SUFFIX')  # ADD TO CONFIG!!!!
		psf_name_ext = conf_dict['PSFEX_CMDLINE_PARAM'][idx+1]
	except ValueError:
		psf_name_ext = psfex['PSF_SUFFIX']
	except IndexError: # invalid commandline list!!!
		psf_name_ext = psfex['PSF_SUFFIX']

	psf_file = ['']*conf_dict['NFILTERS']

	psfex_cfg = tempfile.mkstemp(suffix = '.psfex', dir = '.') # unique temporary filename
	psfex_cfg = psfex_cfg[1]

	for i in range(conf_dict['NFILTERS']):	
		if verbose:
			print("\t\tprocessing {} catalog ...".format(conf_dict['PHOT_TABLE'][i]), end = '     ')

		try: # run PSFEx
			psfex(conf_dict['PHOT_TABLE'][i], config_filename = psfex_cfg, psfex_cmdline_opts = conf_dict['PSFEX_CMDLINE_PARAM'])
			pt = pl.Path(conf_dict['PHOT_TABLE'][i])
			psf_file[i] = pl.Path.joinpath(pt.parent, pt.stem + psf_name_ext) # form name of PSF image
		except amt.AstromaticException as ex:
			print('\npolarPhotPsfPhot: PSFEx error occured while creating PSF image for {} catalog!'.format(conf_dict['PHOT_TABLE'][i]))
			print('polarPhotPsfPhot: Error code {}'.format(ex.error()))
			stat = ex.procStatus()
			if stat is not None:
				print('polarPhotPsfPhot: process status {}'.format(stat))
			print('polarPhotPsfPhot: Stop photometry!')
			return 1

		if verbose:
			print('OK!')


	# final SExtrator measurements

	if verbose:
		print('\n\n\tFinal Sextractor field photomery:')

	params = ['NUMBER', conf_dict['IMAGE_COORD'][0], conf_dict['IMAGE_COORD'][1], \
			  conf_dict['SKY_COORD'][0], conf_dict['SKY_COORD'][1]]

	for i in range(len(conf_dict['MAG'])):
		params.append(conf_dict['MAG'][i])
		params.append(conf_dict['MAGERR'][i])
	params.append('MAG_PSF')
	params.append('MAGERR_PSF')
	params.append('CHI2_PSF')
	# params.append('NITER_PSF')
	params.append('SPREAD_MODEL')
	params.append('SPREADERR_MODEL')
	params.append('FLAGS')
	for str in conf_dict['PARAMS']:
		params.append(str)

	sex.params(params)

	sex['CATALOG_TYPE'] = 'FITS_1.0'

	sex_cfg = tempfile.mkstemp(suffix = '.sex', dir = '.') # unique temporary filename
	sex_cfg = sex_cfg[1]

	for i in range(conf_dict['NFILTERS']):	
		sex['CATALOG_NAME'] = conf_dict['PHOT_TABLE'][i]
		sex['PSF_NAME'] = psf_file[i]
		if conf_dict['WEIGHT_FILE'][0] != '':
			sex['WEIGHT_IMAGE'] = conf_dict['WEIGHT_FILE'][i]

		if verbose:
			print("\t\tphotometry of {} image ...".format(conf_dict['FILE'][i]), end = '     ')

		ex = None
		try: # run SExtractor
			sex(conf_dict['FILE'][i], config_filename = sex_cfg, del_cat = False, sex_cmdline_opts = conf_dict['CMDLINE_PARAM'])
		except amt.AstromaticException as exc:
			ex = exc
		except amt.SextractorException as exc:
			ex = exc

		if ex is not None:
			print('\npolarPhotPsfPhot: SExtractor error occured while creating final photometry catalog {}!'.format(conf_dict['PHOT_TABLE'][i]))
			print('polarPhotPsfPhot: Error code {}'.format(ex.error()))
			stat = ex.procStatus()
			if stat is not None:
				print('polarPhotPsfPhot: process status {}'.format(stat))
			print('polarPhotPsfPhot: Stop photometry!')
			return 1

		if verbose:
			print('OK!')

		pf.setval(conf_dict['PHOT_TABLE'][i], 'PSF_APER', value = np.ceil(fwhm_est[i]*conf_dict['N_FWHM']), comment = 'PSF scaling aperture')

	if verbose:
		print('SUCCESS!')

	return 0

