#!/bin/bash
for i in {2..15};do
	if [ "$i" -eq "2" ];then
		awk '{print $1,$  2}'  $i > ${i}_1
	else
		awk '{print $2}' $i > ${i}_1
	fi
done
for i in {2..15};do
	paste out ${i}_1 >> tem
	mv tem out
done
rm *_1

cat out | while read line;do
eval echo $line  | tr -s " " "\t" >> Chrom.txt
done
