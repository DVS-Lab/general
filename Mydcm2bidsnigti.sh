#!/bin/bash
# Meg and Jamil: July 18, 2017 script reconstructs and moves files into BIDS folder organization scheme
# Updated Feb 26 2018 - Jamil Bhanji
# Updated Mar 12 - Jamil and Jeff
# some important notes -- 
# 1. this script is not meant to be all purpose for everybody's studies, but you can use it as a basis
#    to create your own recon script.
# 2. Copy this script to your study directory, then make the necessary changes. Start by editing the
#    value of "DATADIR"
# 3. For a typical study that uses the 12-channel coil and typical scan parameters you will at least 
#    need to edit the MATCH text to make sure that the script finds the correct scan folders, and change
#    all the relevant TASKNAME1, TASKNAME2, ... variable values (see the #MATCHFILENAME comments)
# 3. For different scan protocols you must make sure to put in the correct field map info if you have field map
#    images (see comment labeled #FIELDMAPPARAMS)
# 4. If you want the fieldmaps to be used correctly, you need to make sure the "IntendedFor" field is
#    specified to include the func scans to which you want it applied (see comment labeled #FMAP_INTENDEDFOR)
#
# 5. Before running this script, create /path/to/main/study/folder/sourcedata/sub-### folder, and put raw scanner files in there.
#
# 6. This script includes removal of face info from the structural scan. You need to have already installed Python 2
#    and pydeface in your home directory. It is recommended that you install Anaconda2.7 (it's not the newest version) and then run
#        /home/myusername/anaconda2/bin/pip install pydeface
#    but note that other utilities require python 3 (fmriprep), so you will need to know how to manage the different versions. See
#    info in the Google Drive document "Setting up fmriprep"
#
# **the BIDS folder should be at the same level as the sourcedata folder (i.e., both in a "studyname" folder)
# IMPORTANT: This script assumes that you scans are numbered/named in the same way for every subject
#  if the order is different (e.g. you have to restart a func scan) then you must edit the code
#  to match the different filenames (look for the MATCHFILENAME comments in the code)
#
# If you plan to use spm for analysis (or other programs that can't open *.gz files) you need to delete the gzip
# commands and change all instances of ".nii.gz" to ".nii" -- you probably also need to unzip the file after the pydeface command

DATADIR=/mnt/delgadolab/Heena/JeffEmily/data_BIDS # Output directory
SOURCEDIR=/mnt/delgadolab/Heena/JeffEmily/sourcedata # source directory
PYTHON2PATH=/home/jdennison/anaconda2/bin 

for subject in 205 206 207 208 210 211 212 213 214 215 216 217 219  #enter subject IDs here (3-digit number, use 001, 002, for low numbers)
#subject folders should be named "sub-###" 
do
  echo subject sub-${subject}
  SUBJECTBIDSDIR=${DATADIR}/sub-${subject}
  mkdir -p ${DATADIR}/sub-${subject}
  cd ${DATADIR}/sub-${subject}
  if [ ! -d "anat" ]; then  #if "anat" does not exist
    mkdir anat
  fi
  if [ ! -d "fmap" ]; then  #if "fmap" does not exist
    mkdir fmap  
  fi
  if [ ! -d "func" ]; then  #if "func" does not exist
    mkdir func  
  fi
  if [ -d ${DATADIR}/derivatives/sub-${subject} ]; then
    mkdir -p ${DATADIR}/derivatives/sub-${subject}
  fi
  mkdir -p ${DATADIR}/derivatives/sub-${subject}/fmap
  cd ${SOURCEDIR}
  if [ -d sub-${subject} ]; then  #if "sourcedata" DOES exist
    SUBJECTSOURCEDIR=${SOURCEDIR}/sub-${subject}
    SUBJECTDERIVDIR=${DATADIR}/derivatives/sub-${subject}
    cd ${SUBJECTSOURCEDIR}
    #MATCHFILENAME below for the anatomical folder - okay to use * as wildcard but must only match one foldername
    ANATMATCH1=*mprage*  #EDIT THIS LINE TO UNIQUELY MATCH ANAT FOLDERNAME
    /mnt/delgadolab/generaltools/mricrogl_lx/dcm2niix -z n -o ${SUBJECTBIDSDIR}/anat/ -b y ${ANATMATCH1}/ 
    gzip ${SUBJECTBIDSDIR}/anat/*.nii  #gzip the file (optional) -- dcm2niix compression option is not working at this moment
    mv ${SUBJECTBIDSDIR}/anat/${ANATMATCH1}.nii.gz ${SUBJECTBIDSDIR}/anat/sub-${subject}_T1w.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
    mv ${SUBJECTBIDSDIR}/anat/${ANATMATCH1}.json ${SUBJECTBIDSDIR}/anat/sub-${subject}_T1w.json
    #remove the face -- you must have deface installed to run with python2 (e.g.: /home/bhanji/anaconda2/bin/pip install pydeface )
    ${PYTHON2PATH}/python ${PYTHON2PATH}/pydeface.py ${SUBJECTBIDSDIR}/anat/sub-${subject}_T1w.nii.gz
    mv ${SUBJECTBIDSDIR}/anat/sub-${subject}_T1w_defaced.nii.gz ${SUBJECTBIDSDIR}/anat/sub-${subject}_T1w.nii.gz
    
    #MATCHFILENAME below - okay to use * as wildcard but must only match one foldername
    FUNCMATCH1=*card* #EDIT THIS LINE TO UNIQUELY MATCH BOLD FOLDERNAME
    TASKNAME1=CardTask
    RUN=01
    /mnt/delgadolab/generaltools/mricrogl_lx/dcm2niix -z n -o ${SUBJECTBIDSDIR}/func/ -b y ${FUNCMATCH1}/  
    gzip ${SUBJECTBIDSDIR}/func/*.nii  #gzip the file (optional) -- dcm2niix compression option is not working at this moment
    mv ${SUBJECTBIDSDIR}/func/${FUNCMATCH1}.nii.gz ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME1}_run-${RUN}_bold.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
    mv ${SUBJECTBIDSDIR}/func/${FUNCMATCH1}.json ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME1}_run-${RUN}_bold.json
    sed -i "1s/{/{\n\t\"TaskName\": \"${TASKNAME1}\",/g" ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME1}_run-${RUN}_bold.json

    #MATCHFILENAME below  - okay to use * as wildcard but must only match one foldername
    FUNCMATCH2=*pav* #EDIT THIS LINE TO UNIQUELY MATCH BOLD FOLDERNAME
    TASKNAME2=Pavlovian
    RUN=01
    /mnt/delgadolab/generaltools/mricrogl_lx/dcm2niix -z n -o ${SUBJECTBIDSDIR}/func/ -b y ${FUNCMATCH2}/ 
    gzip ${SUBJECTBIDSDIR}/func/*.nii  #gzip the file (optional) -- dcm2niix compression option is not working at this moment
    mv ${SUBJECTBIDSDIR}/func/${FUNCMATCH2}.nii.gz ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME2}_run-${RUN}_bold.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
    mv ${SUBJECTBIDSDIR}/func/${FUNCMATCH2}.json ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME2}_run-${RUN}_bold.json
    sed -i "1s/{/{\n\t\"TaskName\": \"${TASKNAME2}\",/g" ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME2}_run-${RUN}_bold.json
    
    #MATCHFILENAME below  - okay to use * as wildcard but must only match one foldername
    FUNCMATCH3=*transfer* #EDIT THIS LINE TO UNIQUELY MATCH BOLD FOLDERNAME
    TASKNAME3=InstTransfer
    RUN=01
    /mnt/delgadolab/generaltools/mricrogl_lx/dcm2niix -z n -o ${SUBJECTBIDSDIR}/func/ -b y ${FUNCMATCH3}/ 
    gzip ${SUBJECTBIDSDIR}/func/*.nii  #gzip the file (optional) -- dcm2niix compression option is not working at this moment
    mv ${SUBJECTBIDSDIR}/func/${FUNCMATCH3}.nii.gz ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME3}_run-${RUN}_bold.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
    mv ${SUBJECTBIDSDIR}/func/${FUNCMATCH3}.json ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME3}_run-${RUN}_bold.json
    sed -i "1s/{/{\n\t\"TaskName\": \"${TASKNAME3}\",/g" ${SUBJECTBIDSDIR}/func/sub-${subject}_task-${TASKNAME3}_run-${RUN}_bold.json

   
    #MATCHFILENAME below  - okay to use * as wildcard but must only match one foldername
    FMAPMATCH1=*fieldmap1* #EDIT THIS LINE TO UNIQUELY MATCH FOLDERNAME (e.g. distinguish "field_mapping" from "field_mapping-2", so don't put a * at the end)
    /mnt/delgadolab/generaltools/mricrogl_lx/dcm2niix -z n -o ${SUBJECTBIDSDIR}/fmap/ -b y ${FMAPMATCH1}/ 
    gzip ${SUBJECTBIDSDIR}/fmap/*.nii  #gzip the file (optional) -- dcm2niix compression option is not working at this moment
    if [ -e ${SUBJECTBIDSDIR}/fmap/*_e?.nii.gz ]; then   
      #FIELD MAPS DON'T ALWAYS COME OUT IN THE SAME ORDER-- SO WE CHECK IF THERE IS AN EXTRA IMAGE AFTER RECON (meaning it's magnitude, not phase)
      #this was the magnitude image folder because there was an extra *e2 image
      echo magnitude image  ${FMAPMATCH1}
      mv ${SUBJECTBIDSDIR}/fmap/*_e?.nii.gz ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude2.nii.gz
      mv ${SUBJECTBIDSDIR}/fmap/*_e?.json ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude2.json
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH1}*.nii.gz ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude1.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH1}*.json ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude1.json
    else #this was the phase image folder
      echo phase image  ${FMAPMATCH1}
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH1}*.nii.gz ${SUBJECTBIDSDIR}/fmap/sub-${subject}_phasediff.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH1}*.json ${SUBJECTBIDSDIR}/fmap/sub-${subject}_phasediff.json
    fi
      
    #MATCHFILENAME below  - okay to use * as wildcard but must only match one foldername
    FMAPMATCH2=*fieldmap2* #EDIT THIS LINE TO UNIQUELY MATCH FOLDERNAME (e.g. distinguish "field_mapping" from "field_mapping-2")
    /mnt/delgadolab/generaltools/mricrogl_lx/dcm2niix -z n -o ${SUBJECTBIDSDIR}/fmap/ -b y ${FMAPMATCH2}/ 
    gzip ${SUBJECTBIDSDIR}/fmap/*.nii  #gzip the file (optional) -- dcm2niix compression option is not working at this moment
    #FIELD MAPS DON'T ALWAYS COME OUT IN THE SAME ORDER-- SO WE CHECK IF THERE IS AN EXTRA IMAGE AFTER RECON (meaning it's magnitude)
    if [ -e ${SUBJECTBIDSDIR}/fmap/*_e?.nii.gz ]; then 
      #this was the magnitude image folder
      echo magnitude image  ${FMAPMATCH2}
      mv ${SUBJECTBIDSDIR}/fmap/*_e?.nii.gz ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude2.nii.gz
      mv ${SUBJECTBIDSDIR}/fmap/*_e?.json ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude2.json
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH2}*.nii.gz ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude1.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH2}*.json ${SUBJECTBIDSDIR}/fmap/sub-${subject}_magnitude1.json
    else
      echo phase image  ${FMAPMATCH2}
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH2}*.nii.gz ${SUBJECTBIDSDIR}/fmap/sub-${subject}_phasediff.nii.gz  #use .nii.gz for each filename if you compressed in reconstruction
      mv ${SUBJECTBIDSDIR}/fmap/${FMAPMATCH2}*.json ${SUBJECTBIDSDIR}/fmap/sub-${subject}_phasediff.json
    fi
    
    #Include necessary info in json sidecar files for the fieldmap images
    # Echo times are 0.00519 and 0.00765 for standard epi change this if using high res or other scanning protocol 
    sed -i "1s/{/{\n\t\"EchoTime1\": \".00519\",\n\t\"EchoTime2\": \".00765\",/g" ${SUBJECTBIDSDIR}/fmap/sub-${subject}_phasediff.json
    
    #FMAP_INTENDEDFOR  set the list of func filenames correctly here (relative paths starting from within sub-### folder)
      #  Be mindful of the run numbers in the filenames! You can use the TASKNAME variables created above, but you need to
      #  change the run numbers if you have run numbers > 01
    FUNC_F1_RUN=01
    FUNC_FILENAME1=\"sub-${subject}_task-${TASKNAME1}_run-${FUNC_F1_RUN}_bold.nii.gz\"
    FUNC_F2_RUN=01
    FUNC_FILENAME2=\"sub-${subject}_task-${TASKNAME2}_run-${FUNC_F2_RUN}_bold.nii.gz\"
    FUNC_F3_RUN=01
    FUNC_FILENAME3=\"sub-${subject}_task-${TASKNAME3}_run-${FUNC_F3_RUN}_bold.nii.gz\"

    #FMAP_INTENDEDFOR edit the line below so that it only includes as many FUNC_FILENAME as you need
    #the formatting of this line is kind of tricky with all the special characters: \n \t 
    #be sure to include ,\n\t\t in between each ${FUNCFILENAME} (but not after the last one)
    #after the last ${FUNCFILENAME} in the line there should be the characters ],/g before the closing quotation mark (")
    sed -i "1s/{/{\n\t\"IntendedFor\": [${FUNC_FILENAME1},\n\t\t${FUNC_FILENAME2},\n\t\t${FUNC_FILENAME3}],/g" ${SUBJECTBIDSDIR}/fmap/sub-${subject}_*.json
    
    #compute field map for use (with FSL FEAT)
    cd ${SUBJECTBIDSDIR}/fmap
    bet sub-${subject}_magnitude1 sub-${subject}_magnitude1_bet -R -B
    fsl_prepare_fieldmap SIEMENS sub-${subject}_phasediff sub-${subject}_magnitude1_bet sub-${subject}_fmapradians 2.46
    mv sub-${subject}_magnitude1_bet.nii.gz ${SUBJECTDERIVDIR}/fmap/
    mv sub-${subject}_magnitude1_bet_mask.nii.gz ${SUBJECTDERIVDIR}/fmap/
    mv sub-${subject}_fmapradians.nii.gz ${SUBJECTDERIVDIR}/fmap
  fi
done

