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
smarket_list = read_csv("smarket_list.csv") %>% pull(smarket)
str(smarket_list)
itx = iter(smarket_list)
itx
source("branchBGrouping.r")
source("smarketBranchLoop.r")

foreach(j = itx, .combine = 'c') %dopar%
  {
      MSABranchLoop(j)
  }

stopImplicitCluster()
