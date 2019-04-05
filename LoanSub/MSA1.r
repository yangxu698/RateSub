unlink(".RData")
rm(list=ls())

## setwd("~/RateWatch/UnzippedData")
library(dplyr)
library(readr)
## setwd("./LoanSub")
Loan_InstitutionDetails = read_delim("../../../RW_MasterHistoricalLoanData_042018/Loan_InstitutionDetails.txt", delim = "|") %>%
      select(accountnumber = acct_nbr, inst_nm, state, city, county, branchdeposits, state_fps, cnty_fps, msa, cbsa)
MSA = Loan_InstitutionDetails %>% pull(msa) %>% unique() %>% na.omit() %>% sort()
CBSA = Loan_InstitutionDetails %>% pull(cbsa) %>% unique() %>% na.omit() %>% sort()
str(MSA)
str(CBSA)
str(Loan_InstitutionDetails)
## DepNameChgHis = DepNameChgHis %>% mutate_if(is.character, as.factor)
## Deposit_acct_join  = Deposit_acct_join %>% mutate_if(is.character, as.factor)
## DepositCertChgHist = DepositCertChgHist %>% mutate_if(is.character, as.factor)
## Deposit_InstitutionDetails = Deposit_InstitutionDetails %>% mutate_if(is.character, as.factor)

## summary(DepNameChgHis)
## summary(DepositCertChgHist)
## summary(Deposit_InstitutionDetails)

rates.array = c("1YrARM175K", "15YrFixMtg175k", "30YrFixMtg175K", "AUTONEW", "AUTOUSED2YR", "PersonalUnsecLoan")  ## not sure which one is home equity 60 months

files.name.array = read_csv("loan_file_list.csv")

file_list = files.name.array %>%
              mutate(code = gsub("(^.+_)(\\w+)(_.+$)","\\2", file_list)) %>%
              filter(code %in% rates.array) %>%
              pull(file_list) %>%
              sort()

file_list
## MSA_list = read.csv("../MSAGet1.csv", stringsAsFactors = FALSE) %>%
##            mutate( MSA = substr(MSA,4,7)) %>% pull(MSA)
## ARM1Yr = read_delim("/home/yang/RateWatch/UnzippedData/loan/loanRateData_1YrARM175K_2005.txt", delim = "|")
## FixMtg15Yr = read_delim("/home/yang/RateWatch/UnzippedData/loan/loanRateData_15YrFixMtg175K_2005.txt", delim = "|")
## FixMtg30Yr = read_delim("/home/yang/RateWatch/UnzippedData/loan/loanRateData_30YrFixMtg175K_2005.txt", delim = "|")
## AUTONEW  = read_delim("/home/yang/RateWatch/UnzippedData/loan/loanRateData_AUTONEW_2005.txt", delim = "|")
## AUTOUSED2YR = read_delim("/home/yang/RateWatch/UnzippedData/loan/loanRateData_AUTOUSED2YR_2005.txt", delim = "|")
## PersonalUnsecLoan = read_delim("/home/yang/RateWatch/UnzippedData/loan/loanRateData_PersonalUnsecLoan_2005.txt", delim = "|")


library(foreach)
library(doParallel)
library(iterators)
source("MSAsubset.r")
cores_number = 4
## timestamp = tbl_df(c())
registerDoParallel(cores_number)
itx = iter(MSA)
itx
timestamp = foreach(j = itx,.combine = 'rbind') %dopar%
## for (j in 1:length(MSA))
              {
                MSA_subset(j)
              }
colnames(timestamp) = c("MSA", "start_time", "end_time", files.name.array)
timestamp = tbl_df(timestamp)
write_csv(timestamp, paste0("../../../RW_MasterHistoricalLoanData_042018/MSA/", "timestamp", as.character(Sys.time()),".csv"))
stopImplicitCluster()
