unlink(".RData")
rm(list=ls())

library(readr)
library(dplyr)

data_complement = read_delim("../Deposit_InstitutionDetails.txt", delim = "|") %>% select(accountnumber = ACCT_NBR, INST_NM, BRANCHDEPOSITS)
data_199901 = read_delim("../depositRateData_1999_01.txt", delim = "|") %>%
              pull(accountnumber) %>% unique()
branchThrouAcquisition = read_delim("../DepositCertChgHist.txt", delim = "|") %>%
                          pull(acctnbr)
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
source("branchBGrouping.r")
source("MSABranchLoop.r")

foreach(j = itx, combine = 'c') %dopar%
  {
      MSABranchLoop(j)
  }

stopImplicitCluster()
