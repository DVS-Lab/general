'''
creates confound files based on fmriprep output
usage: python3 confounds.py <path/to/project/directory>

Caleb Haynes Winter 2020 - built off Jeff Denison's MakeConfounds.py script

'''


'''

Objective:

Read in confound regressor tsvs in fmriprep output. 

Filter for specified columns. 

Write out to derivatives/fsl/confounds directory.


code/

data/
    /bids/
    /derivatives/        
        /fmriprep/sub*/*/*.confounds.tsv <--in
        /fsl/confounds/sub*/counfounds.tsv {filtered} <--out

'''


import glob
import sys
import pandas as pd
import os

confound_list = ['cosine',
                'non_steady_state',
                'aroma',
                'csf',
                'wm'
]


def simple_filter(f): #reads in file, outputs filtered df
    df = pd.read_csv(f,sep='\t')    
    return df.loc[:, df.columns.isin(confound_list)]


proj_dir = sys.argv[1]
file_list = glob.glob(proj_dir + '/**/derivatives/fmriprep/sub*/func/*confounds*.tsv', recursive=True)
out_file = 'data/derivatives/fsl/confounds/'

for cnf_file in file_list:

    cnf_file_path =  cnf_file.split('/')
    
    #subject folder in fmriprep dataset     fmriprep/[subno]/func/confound.tsv
    subno = cnf_file_path[-3]

    #file name in fmriprep dataset          fmriprep/subno/func/[confounds.tsv]
    file_name = cnf_file_path[-1]
    df = simple_filter(cnf_file)
    out_path = out_file + subno + '/' + file_name
    
    print("Writing "+ out_path)
    
    if not os.path.exists(out_path):
        os.makedirs(out_path)
    
    df.to_csv(out_path, index=False,sep='\t',header=False)
