import pyfits as pf
import numpy as np
from CCDPACK import ccdpackMatchLists

def polarPhotMatchCycles(*conf_dicts, verbose = True):
    #
    #   match objects in cycles
    #       matched object will have the same names (photometry tables column will be edited)
    #

    Ntables = len(conf_dicts)

    # name = [0]*len(conf_dicts)
    tabs = [0]*Ntables
    fp = [0]*Ntables

    if verbose:
        print('START MATCHING COLOR TABLES IN {} CYCLES:'.format(Ntables))
        print('\tRead input color tables:')

    i = 0
    for conf_dict in conf_dicts:
        fp[i] = pf.open(conf_dict['COLOR_TABLE'], mode = 'update')

        # name[i] = fp[i][1].data['NAME']

        Nobj = fp[i][1].header['NAXIS2']
        # tabs[i] = np.empty((name[i].size,4), dtype = np.float64)
        tabs[i] = np.empty((Nobj,4), dtype = np.float64)

        tabs[i][:,0] = fp[i][1].data[conf_dict['IMAGE_COORD'][0]]
        tabs[i][:,1] = fp[i][1].data[conf_dict['IMAGE_COORD'][1]]
        tabs[i][:,2] = fp[i][1].data[conf_dict['SKY_COORD'][0]]
        tabs[i][:,3] = fp[i][1].data[conf_dict['SKY_COORD'][1]]

        if verbose:
            print('\t\t{} objects in {}'.format(Nobj,conf_dict['COLOR_TABLE']))

        # fp.close()

        i += 1


    if verbose:
        print('\tMatching ...')

    match_idx, ref_idx = ccdpackMatchLists(*tabs, sky_tol = conf_dicts[0]['MATCH_RADIUS'][0], image_tol = conf_dicts[0]['MATCH_RADIUS'][1], \
        degree = conf_dicts[0]['POLYDEG'])
    # print(match_idx)
    if match_idx is None:
        if verbose:
            print('polarPhotMatchCycles: cannot match cycles! Exit!')
            return 1

    # change names
    ref_name = fp[ref_idx][1].data['NAME']

    for i in range(Ntables):
        if i == ref_idx:
            continue

        idx = np.where(match_idx[:,i] != -1)[0]
        if verbose:
            print('\t\t{} ==> {}: {} objects matched'.format(fp[i].filename(), fp[ref_idx].filename(), idx.size))

        if idx.size == 0:
            continue

        fp[i][1].data['NAME'][match_idx[idx, i]] = ref_name[match_idx[idx, ref_idx]]



    for i in range(len(conf_dicts)):
        fp[i].close()


    NN = 0
    if verbose:
        print('\tSummary:')
        Nmatched = np.sum(match_idx > -1, axis = 1)
        for Nm in range(Ntables, 1, -1):
            idx = np.where(Nmatched == Nm)
            print('\t\t{} objects matched in {} tables'.format(idx[0].size, Nm))
            NN += idx[0].size
        print('\t\t{} mismatched objects'.format(Nmatched.size - NN))


    if verbose:
        print('SUCCESS!')

    return 0