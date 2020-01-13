
# coding: utf-8

# E.G. use 
#$ python MakeConfounds.py --fmriprepDir="/data/projects/Tensor_game/Data/Raw/NARPS/derivatives/fmriprep"



import numpy as np
import pandas as pd
import argparse
import os
import re

parser = argparse.ArgumentParser(description='Give me a path to your fmriprep output')
group = parser.add_mutually_exclusive_group(required=True)

group.add_argument('--fmriprepDir',default=None, type=str,help="This is the full path to your fmriprep dir")
args = parser.parse_args()

fmriprep_path = args.fmriprepDir

print("finding confound files located in %s"%(fmriprep_path))
#make list of confound tsvs
cons=[]
for root, dirs, files in os.walk(fmriprep_path):
    for f in files:
        if f.endswith('-confounds_regressors.tsv'):
            cons.append(os.path.join(root, f))
            

for f in cons:
    sub=re.search('/func/(.*)_task', f).group(1)
    run=re.search('_run-(.*)_', f).group(1)
    task=re.search('_task-(.*)_',f).group(1)
    derivitive_path=re.search('(.*)fmriprep/sub',f).group(1)
    
    output=derivitive_path+"/fsl/counfounds/%s/%s_task-%s_run-%s_desc-fslConfounds.tsv" %(sub,sub,task,run)
    print("%s"%(output))
    
    #read in the confounds, aroma mixing, and aroma confound indexes
    con_regs=pd.read_csv(f,sep='\t')
    
    other=['csf','white_matter']
    cosine = [col for col in con_regs if col.startswith('cosine')]
    NSS = [col for col in con_regs if col.startswith('non_steady_state')]
    #motion_out=[col for col in con_regs if col.startswith('motion_outlier')]
    aroma_motion=[col for col in df1 if col.startswith('aroma')]
    
    filter_col=np.concatenate([cosine,NSS,aroma_motion,other])#here we combine all NSS AROMA motion & the rest 
    
    #This Dataframe will be the full filter matrix
    df_all=con_regs[filter_col]   
    
    
    df_all.to_csv(output,index=False,sep='\t',header=False)

