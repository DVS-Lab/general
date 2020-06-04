# coding: utf-8

# E.G. use
#$ python OutlierID.py --mriqcDir="/data/projects/Tensor_game/NARPS/derivatives/MRIQC" --keys tsnr fdmean

#import seaborn as sb # I import seaborn as sb a lot of other people use sns but I find that harder to remember
import numpy as np 
import json
import pandas as pd
import os
import itertools
import argparse

parser = argparse.ArgumentParser(description='This script creates 3 files from MRIQC data a list of good subjects, bad subjects, and bad runs. isomg  dvars_nstd,tsnr,fd_mean,gsr_x,gsr_y, & aqi ')

parser.add_argument('--mriqcDir',default=None, type=str,help="This is the full path to your mriqc dir",required=True)
parser.add_argument('--keys',default=dvars_nstd tsnr fd_mean gsr_x gsr_y aqi,type=string,nargs='+')
parser.add_argument('--excludesubs',default=none,type=string,nargs='+')

args = parser.parse_args()

mriqc_dir = args.mriqcDir
path_derivative=mriqc_dir[:-5]

keys=args.keys # the IQM's we might care about
exclude=args.excludesubs

j_files=[os.path.join(root, f) for root,dirs,files in os.walk(mriqc_dir) for f in files if f.endswith('bold.json')] #j_files for json files


# Here we make an array that we can import into pandas for easier manipulation
# We open each json file as a python "dictionary" in the j_files array and extract the data we want

sr=['Sub','task','run']
# Open an empty array and fill it. Do this it is a good idea
row=[]
import re # re will let us parse text in a nice way
for i in range(len(j_files)):
    sub=re.search('/mriqc/(.*)/func', j_files[i]).group(1) # this will parse the text for a string that looks like sub-###
    task=re.search('task-(.*)_run',j_files[i]).group(1)
    run=re.search('_run-(.*)_bold.json', j_files[i]).group(1) # this is parsed just as # so we have to put in the run text ourselves if we want later
    with open(j_files[i]) as f: #we load the j_son file and extract the dictionary ingo
        data = json.load(f)
    now=[sub,task,run]+[data[x]for x in keys] #the currently created row in the loop
    if sub not in exclude:
        row.append(now) #through that row on the end
    
df=pd.DataFrame(row,columns=sr+keys) # imaybe later try to do multi-indexing later with sub and run as the index?


# In[5]:



#Making the outlier fences
#find the 1 and 3rd quartile
Q1=df[keys].quantile(0.25)
Q3=df[keys].quantile(0.75)
#find the interquartile range
IQR = Q3 - Q1
#defining fences as 1.5*IQR further than the 1st and 3rd quartile from the mean
lower=Q1 - 1.5 * IQR
upper=Q3 + 1.5 * IQR
upper.tsnr=upper.tsnr*100 # so we don't exclude runs with "too good" signal-noise ratio

print("These are the upper and lower bounds for our metrics")
print(lower.to_frame(name='lower').join(upper.to_frame(name='upper')))

outList=(df[keys]<upper)&(df[keys]>lower)#Here we make comparisons
df['outlier_run']=~outList.all(axis='columns')

df=df.sort_values(by=sr)
print('These are the identifies outlier Runs')
print(df[df['outlier_run']==True])
df.to_csv(path_derivative+"OutlierRuns.tsv",sep="\t",index=False)


# In[6]:


good=df[df.outlier_run==False]
row=[]
for sub,task in itertools.product(good['Sub'].unique(),good['task'].unique()):
    row.append([sub, task, good[(good['Sub']==sub) & (good['task']==task)].shape[0]])
good_task=pd.DataFrame(row,columns=['Sub','Task','Good_Runs'])
good_task.to_csv(path_derivative+"GoodRunNumber.tsv",sep="\t",index=False)

        
    

