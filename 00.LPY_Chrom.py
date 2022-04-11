#!/bin/bash

"""
fill the Chrom1,...Chrom15
Use: in the Linux
for i in {2..15};do python 00.LPY_Chrom.py $i > $i;done
sh combind.sh
"""
import sys
import os,re
def main(file,col):
    chrom = {}
    with open(file,"r") as f:
        for line in f:
            content = line.strip().split()
            if content[0] not in chrom:
                chrom[content[0]] = [content[int(col)]]
            else:
                chrom[content[0]].append(content[int(col)])
    return chrom

def deal():
    chrom = main(file,col)
    for key,value in chrom.items():
        if value.count("NA") == len(value):
            for v in value:
                print(key,str(v))
            continue
        if "1" not in value:
            for i in range(len(value)-1):
                if value[i] == "NA":
                    value[i] = 0
                else:
                    continue
        if "0" not in value:
            for i in range(len(value)-1):
                if value[i] == "NA":
                    value[i] = 1
                else:
                    continue
        if "1" in value:
            n = 0
            for i in range(len(value)-1):
                if value[i] == "NA":
                    indexna = value.index("NA",n)
                    index1 = value.index("1")
                    if indexna < index1:
                        value[i] = 0
                    else:
                        value[i] = 1
                    n += 1
                else:
                    continue
        #print(key,value)
        for v in value:
            print(key,str(v))
      
if __name__ == "__main__":
    file = "be1.csv"
    col = sys.argv[1]
    deal()
