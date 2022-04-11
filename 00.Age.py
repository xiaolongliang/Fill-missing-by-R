import sys

# fill the Age
f1 = open(sys.argv[1],'r')

"""
python Age.py age.csv > Age1.txt
#翻转文件
tac age.csv age1.csv
python Age.py age1.csv > Age2.txt
"""

for line in f1 :
    line = line.strip().split()
    if line[2] != "NA" :
        iid = line[0]
        entry = line[1]
        age = line[2]
        print(iid+"\t"+entry+"\t"+age)
    else :
        new_iid = line[0]
        new_entry = line[1]
        if new_iid == iid :
            new_age = int(age) + int(new_entry.split(".")[0]) - int(entry.split(".")[0])
            print(new_iid+"\t"+new_entry+"\t"+str(new_age))
        else :
            print(new_iid+"\t"+new_entry+"\t"+"NA")

f1.close()
