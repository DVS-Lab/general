#!/bin/sh

# this script takes a z-stat image (voxel thresholded, not cluster) and outputs
# a series of spheres centered on the peaks.
# inputs: thresh_zstat image, a z-threshold, minimum "cluster" size
#
#
# example usage:
# bash makeSpheres.sh thresh_zstat1.nii.gz 6 10

# make these flexible inputs
img=$1
zthr=$2
minsize=$3


# create table of coordinates
cluster --in=$img --thresh=$zthr --olmax=junk >> grot


count=0
cat grot |
while read a; do
set -- $a
	let count=$count+1
	#echo "$0 $1 $2 $minsize"
	if [ $count -gt 1 ] && [ $1 -gt $minsize ]; then # second column (1) is cluster size
		x=$3
		y=$4
		z=$5
		let roinum=$count-1
		roinum_pad=`zeropad $roinum 2`

		# use fslmaths to create a point at the peak voxel (making sure to use fsl voxel coords)
		fslmaths thresh_zstat1.nii.gz -mul 0 -add 1 -roi $x 1 $y 1 $z 1 0 1 point-$roinum_pad -odt float

		# specify a sphere around that point
		fslmaths point-$roinum_pad -kernel sphere 5 -fmean sphere-$roinum_pad -odt float

		# binarize the sphere
		fslmaths sphere-$roinum_pad -bin sphere-${roinum_pad}
	fi
done

rm -rf grot junk point*
