from astropy.io import fits
import os
import fnmatch

def main(path, imagetype, updated_keywords_dict):
    """
    Main function to update FITS file headers.

    Args:
        path (str): Directory containing the FITS files.
        imagetype (str): Type of images to consider ('spec', 'image', 'all').
        updated_keywords_dict (dict): Dictionary containing keywords and values to update.

    Raises:
        TypeError: If there are no FITS files found.

    """
    files_list = make_a_list_of_files(path, imagetype)

    if not files_list:
        raise TypeError("There are no FITS files found!")

    for f in files_list:
        change_fitshead(f, updated_keywords_dict)

def make_a_list_of_files(path, imagetype):
    """
    Create a list of FITS files in the specified directory.

    Args:
        path (str): Directory containing the FITS files.
        imagetype (str): Type of images to consider ('spec', 'image', 'all').

    Returns:
        list: List of FITS files matching the specified criteria.

    """
    extensions = ['fit', 'fits', 'fts', 'FIT', 'FITS', 'FTS']
    matching_files = []

    if imagetype == 'spec':
        check = '1x2'
    elif imagetype == 'image':
        check = '2x2'
    elif imagetype == 'all':
        check = 0

    for root, dirs, files in os.walk(path):
        for file in files:
            for ext in extensions:
                if fnmatch.fnmatch(file, f'*.{ext}'):
                    hdul = fits.open(os.path.join(root, file))
                    if check == 0:
                        matching_files.append(os.path.join(root, file))
                    elif hdul[0].header.get('BINNING') == check:
                        matching_files.append(os.path.join(root, file))
                    hdul.close()

    return matching_files

def change_fitshead(file, keywords):
    """
    Change FITS file header keywords with provided values.

    Args:
        file (str): File path of the FITS file.
        keywords (dict): Dictionary of keywords and values to update.

    Raises:
        TypeError: If 'file' is not a string or 'keywords' is not a dictionary.

    """
    if not isinstance(file, str):
        raise TypeError("'file' should be a string.")

    if not isinstance(keywords, dict):
        raise TypeError("'keywords' should be a dictionary.")

    with fits.open(file, 'update') as f:
        for hdu in f:
            for key in keywords:
                hdu.header[key] = keywords[key]
