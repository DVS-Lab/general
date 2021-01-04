#DVS Neuroeconomics Lab

#Caleb Haynes Spring 2021

#Input bids directory, wipes aquistition time info from all scan tsvs and jsob sidecars

'''
usage ex: python3 deidentify.py /data/projects/rutgers-socreward/bids/

'''

import glob
import sys
import pandas as pd
import json

#make lists of tsvs and json files
scans = glob.glob(sys.argv[1] + 's*/**scans.tsv', recursive = True)

scan_jsons = glob.glob(sys.argv[1] + 's*/func/s*.json', recursive = True)


print('searching for scan TSV files...')


for scan in scans:

    print('scrubbing ' + scan)
    df = pd.read_csv(scan, sep = '\t') 
    #remove column for aquisiton time   
    df.drop(columns = ['acq_time'],axis=1,inplace=True)
    
    df.to_csv(scan, sep = '\t', index = False)

for scan in scan_jsons:
    
    with open(scan, 'r+') as f:
        data = json.load(f)
        data['AcquisitionTime'] = '' # write value.
        f.seek(0)        # <--- should reset file position to the beginning.
        json.dump(data, f, indent=4)
        f.truncate()     # remove remaining part
  
    f.close()
