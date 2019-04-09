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
cores_number = 4
## timestamp = tbl_df(c())
registerDoParallel(cores_number)
MSA_list = read_csv("MSA_list.csv") %>% pull(MSA)
str(MSA_list)
itx = iter(MSA_list)
itx
source("MSABranchLoop.r")

foreach(j = itx, .combine = 'c') %dopar%
  {
      MSABranchLoop(j)
  }

stopImplicitCluster()
