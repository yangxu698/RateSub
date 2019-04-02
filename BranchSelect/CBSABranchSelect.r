unlink(".RData")
rm(list=ls())
library(readr)
library(dplyr)
data_complement = read_delim("../../Deposit_InstitutionDetails.txt", delim = "|") %>% select(accountnumber = ACCT_NBR, INST_NM, BRANCHDEPOSITS)
data_199901 = read_delim("../../depositRateData_1999_01.txt", delim = "|") %>%
              pull(accountnumber) %>% unique()
branchThrouAcquisition = read_delim("../../DepositCertChgHist.txt", delim = "|") %>%
                          pull(acctnbr)
library(foreach)
library(doParallel)
library(iterators)
cores_number = 4
## timestamp = tbl_df(c())
registerDoParallel(cores_number)
CBSA_list = read_csv("CBSA_list.csv") %>% pull(CBSA)
str(CBSA_list)
itx = iter(CBSA_list)
itx
source("branchBGrouping.r")
source("CBSABranchLoop.r")

foreach(j = itx, .combine = 'c') %dopar%
  {
      MSABranchLoop(j)
  }

stopImplicitCluster()
