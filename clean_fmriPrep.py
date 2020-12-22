#script for deleting unnecessary files from an fmriprep directory

#usage: python3 clean_fmriPrep.py <path/to/fmriprep/directory/>

#Caleb Haynes Spring 2020

import os
from os import path
import glob
import sys


def cleaner(prepDir):
    '''
    this function tests to see whether the first argument is a directory (below
    it defaults to sys.argv[1] or the first argument you supply in the command
    line fter the name of the script). Then it uses glob (essentially regex) to 
    make a list to toRemove files. This is done piecemeal to allow for 'commenting 
    out' filetypes that you would like to maintain in your directory or other future customization
    '''
    if os.path.isdir(prepDir):
        print("Found directory {}".format(prepDir))
        MNI_fileList_anat = glob.glob("{}*/anat/*MNI152NLin6Asym*".format(prepDir))
        MNI_fileList_func = glob.glob("{}*/func/*MNI152NLin6Asym*".format(prepDir))
        h5_fileList = glob.glob("{}*/anat/*.h5".format(prepDir))
        dseg = glob.glob("{}*/anat/*dseg*".format(prepDir))
        probseg = glob.glob("{}*/anat/*probseg*".format(prepDir))
        labels = glob.glob("{}*/anat/*label*".format(prepDir))        
        toRemove = MNI_fileList_anat + MNI_fileList_func + h5_fileList + dseg + probseg + labels
        for i in toRemove:
            print('Removing', i)
            os.remove(i)
        print('Done')
    else:
        print('Not a valid directory')
cleaner(sys.argv[1])
