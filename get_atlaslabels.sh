#!/bin/sh

OUTFILE=lmax_${1}.txt

cluster --in=$1 --thresh=0.95 --olmax=$OUTFILE --mm

SUBOUT=subcort_labels_$1
CORTOUT=cort_labels_$1
rm -rf ${SUBOUT}.txt ${CORTOUT}.txt
echo "cortical labels" >> ${CORTOUT}.txt
echo "subcortical labels" >> ${SUBOUT}.txt

count=0
cat $OUTFILE | 
while read a; do 
set -- $a
	let count=$count+1
	if [ $count -gt 1 ]; then
		x=$3
		y=$4
		z=$5
		atlasquery -a "Harvard-Oxford Cortical Structural Atlas" -c $x,$y,$z >> ${CORTOUT}.txt
		atlasquery -a "Harvard-Oxford Subcortical Structural Atlas" -c $x,$y,$z >> ${SUBOUT}.txt
	fi
done

sed -e 's@<b>Harvard-.*<br>@@g' <${CORTOUT}.txt> ${CORTOUT}_edited.txt
sed -e 's@<b>Harvard-.*<br>@@g' <${SUBOUT}.txt> ${SUBOUT}_edited.txt

paste -d '\0' ${CORTOUT}_edited.txt ${SUBOUT}_edited.txt lmax_${1}.txt > ${1}_table.txt
rm ${CORTOUT}_edited.txt ${SUBOUT}_edited.txt lmax_${1}.txt ${CORTOUT}.txt ${SUBOUT}.txt

