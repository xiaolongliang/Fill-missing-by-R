This is the all scripts written by R and Python and input and out data

the input data is DATA.CSV;

1. the Fill.finished.script.r is the main script to fill the DATA.CSV;

2. the variant Age was filled by 00.Age.py:
the input file is be1.csv,output is Age2.txt

    python Age.py age.csv > Age1.txt
    turn out the age.csv to bed2.csv
    tac age.csv age1.csv
    python Age.py age1.csv > Age2.txt 

3. the variants Chrom were filled by 00.LPY_Chrom.py
the input file is be1.csv,and output is Chrom.txt

    for i in {2..15};do python 00.LPY_Chrom.py $i > $i;done
    sh combind.sh

4. the variants Internet_Use,Freq were filled by 00.Indep_variable.py
the input file is ZBL.txt,and output is Indep_variable.txt

    python 00.Indep_variable.py ZBL.txt > Indep_variable.txt
