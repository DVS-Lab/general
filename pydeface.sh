#!/usr/bin/env bash

# example code for pydeface
# runs pydeface on input subject, but need to fix permisions on input data first
# usage: bash run_pydeface.sh sub
# example: bash run_pydeface.sh 102 <bidsroot>

sub=$1
bidsroot=$2

echo $sub
echo $bidsroot

# defacing anatomicals to ensure compatibility with data sharing
pydeface.py ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w.nii.gz
mv -f ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w_defaced.nii.gz ${bidsroot}/sub-${sub}/anat/sub-${sub}_T1w.nii.gz

