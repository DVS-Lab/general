#!/bin/sh
# Script for Dominic to help make difference images and run randomise.
# For more information about why we do this instead of FEAT, see the discussion
# in the FSL Archive - Re: GLM (https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;eb928af2.1112)
# this is important for Dominic since he wants a group-level covariate

# Notes about this script:
# Assumes data are in standard space
# Calculating as Approach - Avoid (note counterbalancing)
# Only looking at first contrast (cope1.nii.gz), so this may need to change
# Create group-level design.mat and design.con files using the Glm GUI
# IMPORTANT: note that merged output (merged_cope1_diff) will be ordered based on subject number, so create design.mat file accordingly

## Approach first subs
for subj in SB018_fu2 SB019_fu2 SB034_fu2 SB036_fu2 SB064_fu2 SB067_fu2 SB088_fu2 SB115_fu2 SB126_fu2 SB133_fu2 SB154_fu2 SB163_fu2 SB182_fu2 SB186_fu2 SB234_fu2 SB236_fu2 SB277_fu2 SB278_fu2 SB282_fu2 SB283_fu2 SB306_fu2 SB317_fu2 SB415_fu2 SB420_fu2b SB422_fu2 SB424_fu2 SB425_fu2 SB426_fu2 SB431_fu2 SB432_fu2; do
	datadir=/danl/SB/${subj}/RewAv/fsl

	# cope images to compare
	approach=$datadir/L1_RewAv_model02_CF_1.feat/stats/cope1.nii.gz #first contrast
	avoid=$datadir/L1_RewAv_model02_CF_2.feat/stats/cope1.nii.gz #first contrast

	# joint mask
	fslmaths $datadir/L1_RewAv_model02_CF_1.feat/mask.nii.gz -mas $datadir/L1_RewAv_model02_CF_1.feat/mask.nii.gz tmpmask

	# create diference image and delete tmpmask
	fslmaths $approach -sub $avoid -mas tmpmask sub-${subj}_cope1_diff
	rm tmpmask.nii.gz
done

## Avoid first subs
for subj in SB002_fu2 SB103_fu2 SB131_fu2 SB135_fu2 SB152_fu2 SB164_fu2 SB169_fu2 SB170_fu2 SB181_fu2 SB190_fu2 SB197_fu2 SB198_fu2 SB235_fu2 SB240_fu2 SB245_fu2 SB256_fu2 SB300_fu2 SB414_fu2 SB417_fu2 SB418_fu2 SB427_fu2 SB434_fu2 SB435_fu2 SB436_fu2 SB437_fu2; do
	datadir=/danl/SB/${subj}/RewAv/fsl

	# cope images to compare
	approach=$datadir/L1_RewAv_model02_CF_2.feat/stats/cope1.nii.gz #first contrast
	avoid=$datadir/L1_RewAv_model02_CF_1.feat/stats/cope1.nii.gz #first contrast

	# joint mask
	fslmaths $datadir/L1_RewAv_model02_CF_1.feat/mask.nii.gz -mas $datadir/L1_RewAv_model02_CF_1.feat/mask.nii.gz tmpmask

	# create diference image
	fslmaths $approach -sub $avoid -mas tmpmask sub-${subj}_cope1_diff
	rm tmpmask.nii.gz
done

fslmerge -t sub-*_cope1_diff.nii.gz merged_cope1_diff
fslmaths merged_cope1_diff -Tmin -bin mask
randomise -i merged_cope1_diff -o rand_out_cope1 -d design.mat -t design.con -T -c 3.1
