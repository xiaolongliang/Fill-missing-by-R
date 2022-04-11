#!/bin/python3
import re
import sys,os

# Fill the Internet_Use and Freq!

def main(file,col):
    tem = {}
    with open(file,"r") as f:
        for line in f:
            content = line.split()
            if content[0] not in tem:
                tem[content[0]] = [content[int(col)]]
            else:
                tem[content[0]].append(content[int(col)])
    return tem

def deal():
    tem = main(file,col)
    for key,value in tem.items():
        if value.count("NA") == len(value):
            for v in value:
                print(key,v)
            continue
        else:
            #va = [i for i in value if (i !="NA" and int(i) > 0)]
            for i in range(len(value)):
                if value[i] == "NA":
                    if i == 0:
                        value[i] = 0
                    else:
                        value[i] = value[i-1]
                else:
                    continue
        for v in value:
            print(key,v)

if __name__ == "__main__":
    file = "ZBL.txt"
    col = sys.argv[1]
    deal()
        

