# coding: utf-8

# E.G. use
#$ python OutlierID.py --mriqcDir="/data/projects/Tensor_game/NARPS/derivatives/MRIQC"

import numpy as np
import pandas as pd
import argparse
import os
import re

parser = argparse.ArgumentParser(description='Give me the full path to your mriqc output, Make sure the path is in quotes and ')
group = parser.add_mutually_exclusive_group(required=True)

group.add_argument('--mriqcDir',default=None, type=str,help="This is the full path to your mriqc dir")
args = parser.parse_args()

path_Mriqc = args.mriqcDir
path_derivative=path_Mriqc[:-5]

print("finding group files files located in %s"%(path_Mriqc))

#MRIQC creates a group level tsv file that I think we can easily read in and play with using pandas
group_files=[f for f in os.listdir(path_Mriqc) if "group" in f]
print("These are all of the group MRIQC Files")
print(group_files)
print("  ")
keys=['bids_name','dvars_nstd','tsnr','fd_mean','gsr_x','gsr_y','aqi'] # the IQM's we might care about


#We read in the MRIWC group bold data and filter in only the IQM's we want
mr_QC=pd.read_csv(path_Mriqc+'/group_bold.tsv',sep='\t')
mr_QC=mr_QC[keys]

#Making the outlier fences
#find the 1 and 3rd quartile
Q1=mr_QC.quantile(0.25)
Q3=mr_QC.quantile(0.75)
#find the interquartile range
IQR = Q3 - Q1
#defining fences as 1.5*IQR further than the 1st and 3rd quartile from the mean
lower=Q1 - 1.5 * IQR
upper=Q3 + 1.5 * IQR
upper.tsnr=upper.tsnr*100 # so we don't exclude runs with "too good" signal-noise ratio

print("These are the upper and lower bounds for our metrics")
print(lower.to_frame(name='lower').join(upper.to_frame(name='upper')))

#Here we make comparisons
dfLower=mr_QC<lower #We get a dataframe of Booleans where True is below out lower bound
dfUpper=mr_QC>upper # We get a dataframe of Booleans where True is above our upper bound
dfUpper.drop(labels=['bids_name'],inplace=True,axis=1) # we drop bidsname because for some reason it's True

# Here we get a list of values where it is below or above any of our lower or upper bounds respectively
lowerList=dfLower.any(axis="columns")
upperList=dfUpper.any(axis="columns")
mr_QC['outlier']=np.logical_or(lowerList,upperList)
print(mr_QC[mr_QC['outlier']==True].head())

mr_QC.to_csv(path_derivative+"OutlierRuns.tsv",sep="\t")
            
import re
outlier_files=mr_QC[mr_QC["outlier"]==True].bids_name
all_subs=[re.search("(.*)_task",f).group(1) for f in outlier_files]
bad_subs=[i for i in np.unique(all_subs) if all_subs.count(i)>2]

all_subs=[re.search("(.*)_task",f).group(1) for f in mr_QC.bids_name]
good_subs=pd.DataFrame([sub for sub in np.unique(all_subs) if sub not in bad_subs],columns=['sub_number'])

bad_subs=pd.DataFrame(bad_subs)
bad_subs.to_csv(path_derivative+"/BAD_subs.tsv",sep="\t",index=False,header=False)
good_subs.to_csv(path_derivative+"/GOOD_subs.tsv",sep="\t",index=False,header=False)


#Display Bad subjects
print("The following list of subjects have 3 or more Bad Runs \n")
print(bad_subs.T)
print type(good_subs)

print ("to view details see the BAD_subs.tsv, GOOD_subs.tsv, and OutlierRuns.tsv saved in your derivatives folder")


