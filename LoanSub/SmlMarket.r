unlink(".RData")
rm(list=ls())

## setwd("~/RateWatch/UnzippedData")
library(readr)
library(dplyr)
Loan_InstitutionDetails = read_delim("../../../RW_MasterHistoricalLoanData_042018/Loan_InstitutionDetails.txt", delim = "|") %>%
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
