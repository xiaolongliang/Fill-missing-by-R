
#研究“互联网使用情况”这一因素对16种慢性病的影响情况
#互联网使用情况：
#Freq:0,1,2,3 表示没有用互联网，使用互联网轻度，中度，重度
#每个慢性病的状态：
#status为1表示患有这一疾病，0表示没有患这一疾病
#以下例子以Chro_1这一慢性疾病为例说明Cox回归的用法

library(survival)
library(tidyverse)

setwd("C:/Users/Administrator/Desktop/李培艺/")
dta <- read.csv("FINAL.csv",header = TRUE)

# 将第一次入组Chro_1就为1的病人删掉
dta %>% group_by(ID) %>% slice(1) %>% filter(Chro_1 == "1") %>% select(ID) -> exclude
exclude <- pull(exclude)
dta %>% filter(!ID %in% exclude) -> dta1
dta1 %>% group_by(ID) %>% slice(-n()) -> dta1  # 去掉最后一行

# 根据ID分组计算year
diff_Age <- function(x){
  res = as.integer(unlist(strsplit(as.character(dta1$Exit[x]),split = "\\."))[1]) - as.integer(unlist(strsplit(as.character(dta1$Entry[x]),split = "\\."))[1])
  return(res)
}

for (i in 1:nrow(dta1)) {
  dta1$DiffAge[i] = diff_Age(i)
}

dta1 %>% group_by(ID) %>% mutate(cumyear=cumsum(DiffAge)) -> dta1

# 筛选Chro_1为1的ID，即status为1
dta1 %>% group_by(ID) %>% filter(Chro_1 == 1) %>% slice(1) %>% select(ID,cumyear,Internet_Use,Freq) %>% mutate(status=1) -> tem1

# status 为 0
rmID = tem1$ID
dta1 %>% filter(!ID %in% rmID) %>% group_by(ID) %>% slice(n()) %>% select(ID,cumyear,Internet_Use,Freq) %>% mutate(status=0) -> tem0
Chro_1 <- rbind(tem0,tem1)

# 数据检查
table(Chro_1$Internet_Use,Chro_1$Freq)
# 有三个人的数据不正常，删除
Chro_1 %>% filter(!ID %in% c(58202126001,94004107001,326359126001)) -> Chro_1

# cox回归
Cox.Chro1 <- coxph(formula = Surv(cumyear,status) ~ Freq,data = Chro_1)
summary(Cox.Chro1)
