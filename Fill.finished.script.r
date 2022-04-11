#!/bin/R
rm(list = ls())
library(tidyverse)
library(zoo)

## read csv data
setwd("C:/Users/Administrator/Desktop/help/李培艺")
dta <- read.csv("DATA.CSV",header = TRUE)

## 1. Fill the constant variate(include "Gender","Edu","Nat","Rel","Work") by Mode(众数)
# Mode function 
GetZHShu <- function(x){
  uniqv <- unique(x)
  uniqv[which.max(tabulate(match(x,uniqv)))]
}
#test Mode function:
# v <- c(2,1,2,3,1,2,3,4,1,5,5,3,2,3)
# GetZHShu(v)

dta %>% select(ID,Wave,Entry,Exit,Gender,Edu,Nat,Rel,Work) %>% 
                                          group_by(ID) %>%
                                          summarise(
                                          count = n(),
                                          n_Gender = sum(is.na(Gender)), #Gender有几个缺失值
                                          n_Edu = sum(is.na(Edu)),
                                          n_Nat = sum(is.na(Nat)),
                                          n_Rel = sum(is.na(Rel)),
                                          n_Work = sum(is.na(Work)),
                                          ZS_Gender = GetZHShu(Gender), #计算众数
                                          ZS_Edu = GetZHShu(Edu),
                                          ZS_Nat = GetZHShu(Nat),
                                          ZS_Rel = GetZHShu(Rel),
                                          ZS_Work = GetZHShu(Work)) -> ConsVar

#fill function
f <- function(x,var){
  for (i in 1:nrow(x)) {
    if(x[["ID"]][i] %in% ConsVar[["ID"]]){
      index = match(x[["ID"]][i],ConsVar[["ID"]])
      if(is.na(x[[var]][i])){
        x[[var]][i] =  ConsVar[[paste("ZS",var,sep = "_")]][index]
      }
    }else{next}
  }
}

for (i in c("Gender","Edu","Nat","Rel","Work")) {
  f(dta,i)
}

# when finished the fill, every patient need to fix the varients("Gender","Edu","Nat","Rel","Work") in same value(Mode), alse, fix by Mode
for (i in 1:nrow(dta1)) {
  if(dta1$ID[i] %in% ConsVar$ID){
    index = match(dta1$ID[i],ConsVar$ID)
    dta1$Gender[i] = ConsVar$ZS_Gender[index]   #dta1$Edu[i] = ConsVar$ZS_Edu[index] ...
  }else{
    next
  }
}

## 2. fill out the Age
dta %>% select(ID,Entry,Age) %>% group_by(ID) %>% head()
write.csv(tem,"age.csv",row.names = FALSE,quote = FALSE,sep = ",")
# fill the Age by python script: Age.py; the detail in documental in Age.py
# when finished the fill process, some patient Age is not consistent with real situation, fix by:

diff_Age <- function(x){
  res = as.integer(unlist(strsplit(as.character(dta$Exit[x]),split = "\\."))[1]) - as.integer(unlist(strsplit(as.character(dta$Entry[x]),split = "\\."))[1])
  return(res)
}

diff_Age_o <- c()
for (i in 1:nrow(dta)) {
  diff_Age_o <- c(diff_Age_o,diff_Age(i))
}

dta$diff_Ages <- diff_Age_o

fixAge <- function(dta){
  for (i in 1:(nrow(dta)-1)) {
    if(dta$ID[i+1] == dta$ID[i]){
      if(!is.na(dta$diff_Ages[i])){
        dta$Age[i+1] = dta$Age[i] + dta$diff_Ages[i]
      }else{
        dta$Age[i+1] = dta$Age[i+1]
      } 
    }else{
      next
    }
  }
  return(dta)
}
dta1 <- fixAge(dta)

# filter out patient that Age more than 45
dta1 %>% group_by(ID) %>% filter(Age>45) %>% ungroup() -> dta1

## 3. Area
dta %>% select(ID,Entry,Area) %>% filter(Entry=="2015.07" | Entry == "2018.07")  %>% group_by(ID) %>% fill(Area,.direction = "downup") -> tem_area
tem_area15 <- tem_area %>% filter(Entry == "2015.07")
tem_area18 <- tem_area %>% filter(Entry == "2018.07")

for (i in 1:nrow(dta)) {
  if(is.na(dta$Area[i])){
    index = match(dta$ID[i],tem_area15$ID)
    if(!is.na(index)){
      dta$Area[i] = tem_area15$Area[index]
    }else{
      index = match(dta$ID[i],tem_area18$ID)
      dta$Area[i] = tem_area18$Area[index]
    }
  }else{
    next
  }
}


## 4. mari
dta  <- dta %>%  group_by(ID) %>% fill(Mari,.direction = "downup") %>% ungroup()

# fill usage: Direction in which to fill missing values. Currently either "down" (the default), "up", "downup" (i.e. first down and then up) or "updown" (first up and then down).

## 5.Inc
dta$Inc <- ifelse(dta$Inc==0,NA,dta$Inc)
dta %>% select(ID,Entry,Inc) %>% group_by(ID) %>% summarise(means = mean(Inc,na.rm=TRUE)) -> tem_inc 
for (i in 1:nrow(dta)) {
  if(is.na(dta$Inc[i])){
    index = match(dta$ID[i],tem_inc$ID)
    dta$Inc[i] = tem_inc$means[index]
  }else{
    next
  }
}

## 6. Ins
dta %>% select(ID,Entry,Ins) %>% filter(!Entry %in% "2015.07") %>% group_by(ID) %>% fill(Ins,.direction = "downup") -> tem_ins
tem_ins %>% filter(Entry == "2013.07") -> tem_ins13
tem_ins %>% filter(Entry == "2018.07") -> tem_ins18
dta %>% select(ID,Entry,Ins) %>% filter(Entry %in% "2015.07") -> tem_ins15

for (i in 1:nrow(tem_ins15)) {
  if(is.na(tem_ins15$Ins[i])){
    index = match(tem_ins15$ID[i],tem_ins13$ID)
    tem_ins15$Ins[i] = tem_ins13$Ins[index]}
    if(is.na( tem_ins15$Ins[i])){
      index = match(tem_ins15$ID[i],tem_ins18$ID)
      tem_ins15$Ins[i] = tem_ins18$Ins[index]
    }
  else{next}
}

dta[dta$Entry %in% tem_ins15$Entry,]$Ins = tem_ins15$Ins
dta[!dta$Entry %in% tem_ins15$Entry,]$Ins = tem_ins$Ins

# 7. Liv
dta %>% group_by(ID) %>% fill(Liv,.direction = "downup") %>% ungroup() -> dta

## 因变量
#8. chro Fill
dta %>% select(ID,Entry,contains("Chro")) -> Chro
write.csv(Chro,"be.csv",quote = FALSE,row.names = FALSE)

"""
python script
for i in {2..15};do python 00.LPY_Chrom.py $i > $i;done
sh combind.sh
"""

#9. 自变量
# Internet_Use,Freq fill: python script
dta %>% select(ID,Entry,Internet_Use,Freq) -> data
write.table(data,"ZBL.txt",quote = FALSE,row.names = FALSE)
# python 
# 00.freq.py

#10. fill the Vis and Dep
dta %>% group_by(ID) %>% fill(Vis,Dep,.direction = "downup") %>% ungroup() -> dta1

#11. rm count ID equal 1
dta1 %>% group_by(ID) %>% filter(sum(!is.na(ID)) > 1) %>% select(-diff_Ages) -> dta1

#12. save the end result
write.csv(dta1,"DATA2_out.csv",quote = FALSE,row.names = FALSE)
