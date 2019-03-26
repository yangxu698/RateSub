library(readr)
library(dplyr)

Deposit_InstitutionDetails = read_delim("../Deposit_InstitutionDetails.txt", delim = "|")

data_complement = Deposit_InstitutionDetails %>% select(accountnumber = ACCT_NBR, INST_NM, BRANCHDEPOSITS)
data_with_name = left_join(data, data_complement, by = "accountnumber")
data_sorted = data_with_name %>% mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
                                  group_by(accountnumber) %>%
                                  mutate(survey_span = max(date_num) - min(date_num)) %>%
                                  ungroup() %>% group_by(INST_NM) %>% top_n(1, survey_span)  %>%
                                  top_n(1, BRANCHDEPOSITS) %>%
                                  ungroup() %>% select(-date_num)
data_sorted = data_with_name %>% mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
                                 group_by(INST_NM) %>%
                                 top_n(-1, date_num) %>%
                                 top_n(1, BRANCHDEPOSITS) %>%
                                 ungroup() %>% select(-date_num)
data_sorted_with_tied_deposit = data_with_name %>%
                                mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
                                group_by(INST_NM) %>%
                                top_n(-1, date_num)

data = Deposit_InstitutionDetails %>% select(ACCT_NBR, CNTY_FPS, STATE_FPS, MSA, CBSA)
