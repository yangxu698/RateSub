unlink(".RData")
rm(list=ls())

## setwd("~/RateWatch/UnzippedData")
library(readr)
library(dplyr)
Loan_InstitutionDetails = read_delim("../../../RW_MasterHistoricalLoanData_042018/Loan_InstitutionDetails.txt", delim = "|") %>%
                          select(accountnumber = acct_nbr, inst_nm, state, city, county, branchdeposits, state_fps, cnty_fps, msa, cbsa)

Loan_InstitutionDetails = read_delim("/home/yang/RateWatch/UnzippedData/loan/Loan_InstitutionDetails.txt", delim = "|") %>%
                          select(accountnumber = acct_nbr, inst_nm, state, city, county, branchdeposits, state_fps, cnty_fps, msa, cbsa)
rates.array = c("1YrARM175K", "15YrFixMtg175K", "30YrFixMtg175K", "AUTONEW", "AUTOUSED2YR", "HELOC80LTV", "PersonalUnsecLoan")


file_list = read_csv("loan_file_list.csv") %>%
              mutate(code = gsub("(^.+_)(\\w+)(_.+$)","\\2", file_list)) %>%
              filter(code %in% rates.array) %>%
              pull(file_list) %>%
              sort()

file_list

smarket = Loan_InstitutionDetails %>% filter( is.na(msa) & is.na(cbsa) ) %>%
        mutate( StateCounty = paste0(state_fps,".",cnty_fps)) %>%
        arrange(StateCounty) %>% select(accountnumber, StateCounty)
smarket_code = smarket  %>%
        pull(StateCounty) %>% unique()  ## %>%
        ## group_by(StateCounty) %>% sample_frac(0.25, replace = FALSE)


str(smarket_code)
## CBSA = sample(CBSA, 200)

library(foreach)
library(doParallel)
library(iterators)
cores_number = 4
## timestamp = tbl_df(c())
source("smarketSubset.r")

registerDoParallel(cores_number)
itx = iter(smarket_code)
itx$length
timestamp = foreach( j = itx, .combine = 'rbind') %dopar%
## for (j in 1:length(CBSA))
    {
      smarket_subset(j)
    }
print(timestamp)
colnames(timestamp) = c("small_market", "start_time", "end_time", file_list)
str(timestamp)
timestamp = tbl_df(timestamp)
str(timestamp)
write_csv(timestamp, paste0("../../smarket/", "timestamp",".csv"))
stopImplicitCluster()
