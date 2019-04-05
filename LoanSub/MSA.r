unlink(".RData")
rm(list=ls())

## setwd("~/RateWatch/UnzippedData")
library(dplyr)
library(readr)
## setwd("./LoanSub")
## setwd("/home/yang/RateWatch/UnzippedData/deposit/RateSub/LoanSub")
Loan_InstitutionDetails = read_delim("../../../RW_MasterHistoricalLoanData_042018/Loan_InstitutionDetails.txt", delim = "|") %>%
## Loan_InstitutionDetails = read_delim("../../../loan/Loan_InstitutionDetails.txt", delim = "|") %>%
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

rates.array = c("1YrARM175K", "15YrFixMtg175K", "30YrFixMtg175K", "AUTONEW", "AUTOUSED2YR", "HELOC80LTV", "PersonalUnsecLoan")


file_list = read_csv("loan_file_list.csv") %>%
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

productfilter =  c("1 Year ARM @ 175K - Amort","1 Year ARM @ 175K - Caps","1 Year ARM @ 175K - Dwn Pmt",
                      "1 Year ARM @ 175K - Orig Fees","1 Year ARM @ 175K - Points", "1 Year ARM @ 175K - Rate",
                      "15 Yr Fxd Mtg @ 175K - Dwn Pmt","15 Yr Fxd Mtg @ 175K - Orig Fees",
                      "15 Yr Fxd Mtg @ 175K - Points", "15 Yr Fxd Mtg @ 175K - Rate",
                      "30 Yr Fxd Mtg @ 175K - Dwn Pmt", "30 Yr Fxd Mtg @ 175K - Orig Fees",
                      "30 Yr Fxd Mtg @ 175K - Points", "30 Yr Fxd Mtg @ 175K - Rate",
                      "Auto New - 36 Mo Term","Auto New - 60 Mo Term",
                      "Auto Used 2 Yrs - % Financed",
                      "Home E.L.O.C. up to 80% LTV - Annual Fee","Home E.L.O.C. up to 80% LTV - Tier 1",
                      "Home E.L.O.C. up to 80% LTV - Tier 4",
                      "Personal Unsecured Loan - Tier 1", "Personal Unsecured Loan - Tier 4")
  ## "Auto New - % Financed", "Auto New - 48 Mo Term","Auto New - 72 Mo Term","Auto Used 2 Yrs - % Financed", "Auto Used 2 Yrs - 48 Mo Term", "Personal Unsecured Loan - Max Term",
  ## write.csv(j, paste0("../../../MSA/", j,"starts",".csv"))

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
colnames(timestamp) = c("MSA", "start_time", "end_time", file_list)
timestamp = tbl_df(timestamp)
write_csv(timestamp, paste0("../../../RW_MasterHistoricalLoanData_042018/MSA/", "timestamp", as.character(Sys.time()),".csv"))
stopImplicitCluster()
