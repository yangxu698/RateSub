unlink(".RData")
rm(list=ls())

library(dplyr)
library(readr)
Loan_InstitutionDetails = read_delim("../../RW_MasterHistoricalLoanData_042018/Loan_InstitutionDetails.txt", delim = "|") %>%
      select(accountnumber = acct_nbr, inst_nm, cert_nbr, state, city, county, branchdeposits, state_fps, cnty_fps, msa, cbsa)
inst_list = read_csv("InstitutionFilter.csv") %>% pull(CERT_NBR)
rates.array = c("1YrARM175K", "15YrFixMtg175K", "30YrFixMtg175K", "AUTONEW", "AUTOUSED2YR", "HELOC80LTV", "PersonalUnsecLoan")
file_list = read_csv("loan_file_list.csv") %>%
              mutate(code = gsub("(^.+_)(\\w+)(_.+$)","\\2", file_list)) %>%
              filter(code %in% rates.array) %>%
              pull(file_list) %>%
              sort()
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
source("fun_instLoanSub.r")
cores_number = 4
registerDoParallel(cores_number)
itx = iter(inst_list)
itx
timestamp_deposit = foreach(j = itx,.combine = 'rbind') %dopar%
                    {
                      inst_loan_subset(j)
                    }
colnames(timestamp_deposit) = c("inst_nm", "start_time", "end_time", file_list)
timestamp_deposit= tbl_df(timestamp_deposit)
write_csv(timestamp_deposit, paste0("../../InstSelect/", "timestamp_loan", as.character(Sys.time()),".csv"))
stopImplicitCluster()
