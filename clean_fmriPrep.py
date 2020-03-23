import os
from os import path
import glob
import sys



def cleaner(prepDir):
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
