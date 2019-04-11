unlink(".RData")
rm(list=ls())
library(readr)
library(dplyr)
data_complement = read_delim("../../RW_MasterHistoricalLoanData_042018/Loan_InstitutionDetails.txt", delim = "|") %>%
                      select(accountnumber = acct_nbr, inst_nm, branchdeposits)

## data_complement = read_delim("../../../loan/Loan_InstitutionDetails.txt", delim = "|") %>%
##                       select(accountnumber = acct_nbr, inst_nm, branchdeposits)
branchThrouAcquisition = read_delim("../../RW_MasterHistoricalLoanData_042018/LoanInstCertChgs.txt", delim = "|") %>%
                          pull(acctnbr) %>% unique()
## branchThrouAcquisition = read_delim("../../../loan/LoanInstCertChgs.txt", delim = "|") %>%
##                           pull(acctnbr) %>% unique()
library(foreach)
library(doParallel)
library(iterators)
cores_number = 24
## timestamp = tbl_df(c())
registerDoParallel(cores_number)
CBSA_list = read_csv("CBSA_list.csv") %>% pull(CBSA)
str(CBSA_list)
itx = iter(CBSA_list)
itx
source("CBSABranchLoop.r")

foreach(j = itx, .combine = 'c') %dopar%
  {
      CBSABranchLoop(j)
  }

stopImplicitCluster()
