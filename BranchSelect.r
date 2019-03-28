library(readr)
library(dplyr)

data_complement = read_delim("../Deposit_InstitutionDetails.txt", delim = "|") %>% select(accountnumber = ACCT_NBR, INST_NM, BRANCHDEPOSITS)
data_199901 = read_delim("../depositRateData_1999_01.txt", delim = "|") %>%
              pull(accountnumber) %>% unique()
MSA_raw = read_csv("../MSA0680.csv")
##   Extract institutions with only one branch in MSA   ##
branch =  MSA_raw %>%
          left_join(data_complement, by = "accountnumber") %>%
          select(accountnumber, INST_NM) %>%
          group_by(INST_NM) %>%
          unique() %>%
          mutate(branchNBR = table(INST_NM))

branchA1 = branch %>%
          filter(branchNBR == 1) %>%
          mutate(branchType = "A1") %>%
          select(-branchNBR)
branchB = branch %>%
          filter(branchNBR > 1)

dataA1 = MSA_raw %>%
         left_join(branchA1, by = "accountnumber") %>%
         na.omit()

branchB

##   Extract institutions with multiple branches, no Jan.1999 data  ##
branchB2 = MSA_raw %>%
          filter(accountnumber %in% branchB$accountnumber) %>%
          filter(accountnumber %in% data_199901 ) %>%
          left_join(data_complement, by = "accountnumber") %>%
          select(accountnumber, INST_NM) %>%
          unique() %>%
          mutate(branchType = "B2")
branchB1 = branchB %>% anti_join(branchB2, by="INST_NM")%>%
          select(accountnumber, INST_NM) %>%
          unique() %>%
          mutate(branchType = "B1")

branchB1
branchB2

branchB_grouping = function(branchB)
{
  branchBX1 = branchB1 %>%
              mutate(branchNBR = table(INST_NM)) %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = paste0(branchType,"1")) %>%
              select(-branchNBR)
  branchBX2_temp = branchB1 %>%
                    anti_join(branchBX1, by="INST_NM")
branchBX = MSA_raw %>%
              filter(accountnumber %in% branchBX2_temp$accountnumber & productcode == "12MCD10K") %>%
              mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
              left_join(branchB1, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
              group_by(accountnumber) %>%  ## grouping by accountnumber
              mutate(survey_span = max(date_num) - min(date_num)) %>%   ## calculate the survey span
              ungroup() %>% group_by(INST_NM) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
              ungroup() %>%
              select(accountnumber, INST_NM, branchType) %>%
              unique() %>%
              mutate(branchNBR = table(INST_NM))

branchBX2 =   branchBX %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = paste0(branchType,"2")) %>%
              select(-branchNBR)

branchThrouAcquisition = read_delim("../DepositCertChgHist.txt", delim = "|") %>%
                            pull(acctnbr)
branchBX3_temp = branchBX %>%
                  filter(branchNBR > 1) %>%
                  select(-branchNBR) %>%
                  filter(! accountnumber %in% branchThrouAcquisition) %>%
                  mutate(branchNBR = table(INST_NM))
branchBX3 = branchBX3_temp %>%
            filter(branchNBR == 1)
            mutate(branchType = paste0(branchType,"3")) %>%
            select(-branchNBR)
branchBX4 = branchBX3 %>%
                  filter(branchNBR > 1) %>%
                  left_join(data_complement[,c(1,3)], by = "accountnumber") %>%
                  group_by(INST_NM) %>%
                  top_n(1,BRANCHDEPOSITS) %>%
                 ungroup() %>%
                 select(-BRANCHDEPOSITS)  %>%
                 mutate(branchType = paste0(branchType,"4"))

return(rbind(branchBX1, branchBX2, branchBX3, branchBX4))

}




read_csv("../MSA0680.csv") %>% filter(accountnumber == "CA02600002")
data = read_csv("../MSA0680.csv") %>% filter(accountnumber = CA)
          mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
          left_join(data_complement, by = "accountnumber") %>%
          select(accountnumber, INST_NM) %>%
          group_by(INST_NM) %>%
          unique() %>%
branchB$surveydate

summary(dataA1)
data_sorted = MSA0680 %>% mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%   ## convert the survey data to number
                                  filter(accountnumber %in% data_199901 & productcode == "12MCD10K") %>%   ## select accountnumber that has data in Jan.1999 and productcode "12MCD10K"
                                  left_join(data_complement, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
                                  group_by(accountnumber) %>%  ## grouping by accountnumber
                                  mutate(survey_span = max(date_num) - min(date_num)) %>%   ## calculate the survey span
                                  ungroup() %>% group_by(INST_NM) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
                                  ungroup()
str(data_sorted)
## At this point, we need to check if there is tie for each institution
tier_indicator = data_sorted %>% group_by(INST_NM) %>% summarise(branchNBR = table(unique(accountnumber)))
str(tier_indicator)
head(tier_indicator,25)
table(data_sorted$INST_NM)

top_n(1, BRANCHDEPOSITS) %>%
ungroup() %>% select(-date_num)

summary(data_sorted,25)
data = Deposit_InstitutionDetails %>% select(ACCT_NBR, CNTY_FPS, STATE_FPS, MSA, CBSA)
