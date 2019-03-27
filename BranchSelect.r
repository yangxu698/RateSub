library(readr)
library(dplyr)

data_complement = read_delim("../Deposit_InstitutionDetails.txt", delim = "|") %>% select(accountnumber = ACCT_NBR, INST_NM, BRANCHDEPOSITS)
data_199901 = read_delim("../depositRateData_1999_01.txt", delim = "|") %>%
              pull(accountnumber) %>% unique()

MSA0680 = read_csv("../MSA0680.csv")
dataA1 = read_csv("../MSA0680.csv") %>%
          left_join(data_complement, by = "accountnumber") %>%
          select(accountnumber, INST_NM) %>%
          group_by(INST_NM) %>%
          unique() %>%
          summarise(branchNBR = table(accountnumber))
table(dataA1$INST_NM,dataA1$accountnumber)
unique(dataA1) %>% group_by(INST_NM) %>% summarise(table(accountnumber))
filter(!accountnumber %in% data_199901)
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
