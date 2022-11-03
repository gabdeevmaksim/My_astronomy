import pyfits as pf
import numpy as np
import warnings
from CCDPACK import computePolyTransform

def transformXY(xy, coeffs, deg):
	Ncoeffs = (deg[0]+1)*(deg[1]+1)
	N = xy.shape[0]

	A = np.ones((N,Ncoeffs), dtype=np.float64)

	d = deg[1]+1

	term = xy[:,1]
	for dg in range(1, d):
		if dg > 1:
			term *= xy[:,1]
		for j in range(0, Ncoeffs, d):
			A[:, j + dg] = term

	term = xy[:,0]
	for dg in range(1, d):
		if dg > 1:
			term *= xy[:,0]
		for j in range(d):
			A[:, j + dg*d] *= term

	return np.dot(A,coeffs) 


def polarPhotMatchCatalogs(config_dict, verbose = True):
	warnings.filterwarnings('ignore')

    # compute output table dimension
	ref_idx = 0
	max_N_obj = 0
	for i in range(config_dict['NFILTERS']):
		n = pf.getval(config_dict['PHOT_TABLE'][i], 'NAXIS2', ext=1)
		if n > max_N_obj:
			ref_idx = i
			max_N_obj = n

	x_name = config_dict['IMAGE_COORD'][0]
	y_name = config_dict['IMAGE_COORD'][1]
	ra_name = config_dict['SKY_COORD'][0]
	dec_name = config_dict['SKY_COORD'][1]
    
	# reference table
	filename = config_dict['PHOT_TABLE'][ref_idx]
	fp = pf.open(filename)
	ra_ref = fp[1].data[ra_name]
	dec_ref = fp[1].data[dec_name]
	xy_ref = np.empty((ra_ref.size,2), dtype = np.float32)
	xy_ref[:,0] = fp[1].data[x_name]
	xy_ref[:,1] = fp[1].data[y_name]

	fp.close()

	match_radius2 = config_dict['MATCH_RADIUS'][0]**2
	# match_radius2 = config_dict['MATCH_RADIUS']**2
	# print(match_radius2)
	m_radius_pix2 = config_dict['MATCH_RADIUS'][1]**2

	match_idx = np.empty((max_N_obj, config_dict['NFILTERS']),dtype=np.int64)
	match_idx[:, ref_idx] = np.arange(max_N_obj)

	if verbose:
		print('SEARCH FOR COMMON OBJECTS IN THE INPUT CATALOGS')


	if verbose:
		print('\tMatch objects in WCS-space and compute image-to-image transformation in pixel space ... \n')

	deg = config_dict['POLYDEG']

	tr_coeffs = [0]*config_dict['NFILTERS']
	Niter = config_dict['NITER']

	for i in range(config_dict['NFILTERS']):
		if i == ref_idx:
			continue
		fp = pf.open(config_dict['PHOT_TABLE'][i])
		ra = fp[1].data[ra_name]
		dec = fp[1].data[dec_name]
		xy = np.empty((ra.size, 2), dtype = np.float32)
		xy[:,0] = fp[1].data[x_name]
		xy[:,1] = fp[1].data[y_name]
		fp.close()

		# match in WCS-space
		Nmatched = 0
		for j in range(max_N_obj):
			r2 = (ra-ra_ref[j])**2 + (dec-dec_ref[j])**2
			idx = np.argmin(r2)
			# print(r2[idx])
			if r2[idx] <= match_radius2:
				match_idx[j,i] = idx
				Nmatched += 1
			else:
				match_idx[j,i] = -1

		if verbose:
			print('\t{} ==> {}: {} objects matched (WCS-space)'.format(config_dict['PHOT_TABLE'][i],config_dict['PHOT_TABLE'][ref_idx],Nmatched))

		if Nmatched == 0:
			print('No objects matched! Exit!')
			return 1

		# image-to-image transformation (iterative)
		i_iter = 0
		while True:
			Nmatched_i = Nmatched
			ids = np.where(match_idx[:,i] > -1)[0]
			coeffs = computePolyTransform(xy[match_idx[ids,i], :], xy_ref[match_idx[ids, ref_idx], :], degree = deg, reform = False)

			xy_tr = transformXY(xy, coeffs, deg)
			# match_idx[:,i] = np.full(max_N_obj, -1)
			# match in pixel space (more accurate)

			Nmatched = 0
			for j in range(max_N_obj):
				r2 = (xy_tr[:,0]-xy_ref[j,0])**2 + (xy_tr[:,1]-xy_ref[j,1])**2
				idx = np.argmin(r2)
				# print(r2[idx])
				if r2[idx] <= m_radius_pix2:
					match_idx[j,i] = idx
					Nmatched += 1
				else:
					match_idx[j,i] = -1

			if Nmatched == 0:
				break

			i_iter += 1

			if (Nmatched_i == Nmatched) | (i_iter > Niter):
				break

		tr_coeffs[i] = coeffs

		if verbose:
			print('\t{} ==> {}: {} objects matched (pixel space, {} iterations)'.format(config_dict['PHOT_TABLE'][i],config_dict['PHOT_TABLE'][ref_idx],Nmatched,i_iter))

		if Nmatched == 0:
			print('No objects matched! Exit!')
			return 1

	# find rows with NFILTER, NFILTER-1, NFILTER-3 ... matches

	print('\n')
	Nmatched = np.sum(match_idx > -1, axis = 1)
	ids = np.argsort(Nmatched)
	ids = np.flip(ids) # in descending order

	N = 0
	N_common = 0
	N_miss = max_N_obj
	j = 0
	for Nflt in range(config_dict['NFILTERS'], 1, -1):
		flag = True
		while flag:
			if Nmatched[ids[j]] == Nflt:
				N += 1
				j += 1
				# if j == ids.size:
				# 	flag = False
			else:
				if verbose:
					print('\tNumber of matched objects in {} catalogs: {}'.format(Nflt, N))
				if Nflt == config_dict['NFILTERS']:
					N_common = N
				N_miss -= N
				N = 0
				flag = False

	if verbose:
		print('\tNumber of mismatched objects: {}'.format(N_miss))

    # save results

	output_cols = []

	for i in range(config_dict['NFILTERS']):
		cname = 'IDX_{}'.format(config_dict['FILTER'][i])
		# output_cols.append(pf.Column(name=cname, format="J", array=match_idx[:,i]))
		output_cols.append(pf.Column(name=cname, format="J", array=match_idx[ids,i]))

	# r = np.empty(ra_ref.size, dtype = np.float64)
	# d = np.empty(ra_ref.size, dtype = np.float64)

	ra_ref = ra_ref[ids]
	dec_ref = dec_ref[ids]

	xy_ref = xy_ref[ids,:]

	for i in range(config_dict['NFILTERS']):
		cname_ra = '{}_{}'.format(ra_name, config_dict['FILTER'][i])
		cname_dec = '{}_{}'.format(dec_name, config_dict['FILTER'][i])

		cname_x = '{}_{}'.format(x_name, config_dict['FILTER'][i])
		cname_y = '{}_{}'.format(y_name, config_dict['FILTER'][i])
		
		if i != ref_idx:
			fp = pf.open(config_dict['PHOT_TABLE'][i])
			ii = np.where(match_idx[ids,i] > -1)[0]

			r = np.full(ra_ref.size, np.nan, dtype = np.float64)
			d = np.full(ra_ref.size, np.nan, dtype = np.float64)
			# r = np.empty(ra_ref.size, dtype = np.float64)
			# d = np.empty(ra_ref.size, dtype = np.float64)

			xy = np.full((ra_ref.size,2), np.nan, dtype = np.float64)
			# xy = np.empty((ra_ref.size,2), dtype = np.float64)

			r[ii] = (fp[1].data[ra_name])[match_idx[ids[ii],i]]
			d[ii] = (fp[1].data[dec_name])[match_idx[ids[ii],i]]

			xy[ii,0] = (fp[1].data[x_name])[match_idx[ids[ii],i]]
			xy[ii,1] = (fp[1].data[y_name])[match_idx[ids[ii],i]]
			# r[:ii.size] = (fp[1].data[ra_name])[match_idx[ids[ii],i]]
			# d[:ii.size] = (fp[1].data[dec_name])[match_idx[ids[ii],i]]

			# xy[:ii.size,0] = (fp[1].data[x_name])[match_idx[ids[ii],i]]
			# xy[:ii.size,1] = (fp[1].data[y_name])[match_idx[ids[ii],i]]

			fp.close()

			# r[ii.size:] = np.nan
			# d[ii.size:] = np.nan

			# xy[ii.size:,0] = np.nan
			# xy[ii.size:,1] = np.nan

			output_cols.append(pf.Column(name=cname_ra, format="D", disp='F11.7', array=r))
			output_cols.append(pf.Column(name=cname_dec, format="D", disp='F11.7', array=d))

			output_cols.append(pf.Column(name=cname_x, format="D", disp='F8.3', array=xy[:,0]))
			output_cols.append(pf.Column(name=cname_y, format="D", disp='F8.3', array=xy[:,1]))

			cname_r = 'DIST_{}_{}'.format(config_dict['FILTER'][i], config_dict['FILTER'][ref_idx])
			d = np.sqrt( (r-ra_ref)**2 + (d-dec_ref)**2 )*3600.0
			output_cols.append(pf.Column(name=cname_r, format="D", disp='G', array=d))

			# residuals in pixel space (after transformatiion to reference catalog sustem)
			cname_rp = 'DISTPIX_{}_{}'.format(config_dict['FILTER'][i], config_dict['FILTER'][ref_idx])
			xy = transformXY(xy, tr_coeffs[i], deg)
			xy = np.sqrt( (xy[:,0] - xy_ref[:,0])**2 + (xy[:,1] - xy_ref[:,1])**2 )
			output_cols.append(pf.Column(name=cname_rp, format="D", disp='G', array=xy))
		else:
			output_cols.append(pf.Column(name=cname_ra, format="D", disp='F11.7', array=ra_ref))
			output_cols.append(pf.Column(name=cname_dec, format="D", disp='F11.7', array=dec_ref))

			output_cols.append(pf.Column(name=cname_x, format="D", disp='F11.7', array=xy_ref[:,0]))
			output_cols.append(pf.Column(name=cname_y, format="D", disp='F11.7', array=xy_ref[:,1]))


	tbl = pf.BinTableHDU.from_columns(output_cols)
	tbl.writeto(config_dict['IDENT_TABLE'], clobber=True)

	for i in range(config_dict['NFILTERS']):
		v = "CAT{}".format(i)
		pf.setval(config_dict['IDENT_TABLE'], v, value = config_dict['PHOT_TABLE'][i], comment = "Input photometry catalog")
	pf.setval(config_dict['IDENT_TABLE'],"NMATCH", value = N_common, comment = "Number of matched objects", ext=1)
	pf.setval(config_dict['IDENT_TABLE'],"MATCHRAD", value = config_dict['MATCH_RADIUS'][0], comment = "Match radius in WCS units")
	# pf.setval(config_dict['IDENT_TABLE'],"MATCHRAD", value = config_dict['MATCH_RADIUS'], comment = "Match radius")
	pf.setval(config_dict['IDENT_TABLE'],"PIXRAD", value = config_dict['MATCH_RADIUS'][1], comment = "Match radius in pixels")
	pf.setval(config_dict['IDENT_TABLE'],"REF-IDX", value = ref_idx, comment = "Reference catalog index (zero-based)")
	pf.setval(config_dict['IDENT_TABLE'],"COMMENT", value = "   MATCHED OBJECTS INDICES (zero-based)")

	return 0