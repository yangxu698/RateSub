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

smarket_raw = read_csv("../../RW_MasterHistoricalLoanData_042018/smarket/smarketInOne.csv")
str(smarket_raw)

    ##   Extract institutions with only one branch in this smarket   ##
    branch =  smarket_raw %>%
              left_join(data_complement, by = "accountnumber") %>%
              ## select(accountnumber, prod_code, date, applicablemeasurement, inst_nm, branchdeposits) %>%
              select(accountnumber, inst_nm, StateCounty) %>%
              unique() %>%
              group_by(StateCounty, inst_nm) %>%
              mutate(branchNBR = table(inst_nm)) %>%
              ungroup()

    branchA = branch %>%
              filter(branchNBR == 1) %>%
              select(-branchNBR) %>%
              mutate(branchType = ifelse(accountnumber %in% branchThrouAcquisition, "A1","A2"))

    branchB = branch %>%
              anti_join(branchA, by = 'accountnumber')


    ##   Extract institutions with possible multiple branches, with Jan.1999 data  ##
    branchB1 =  branchB  %>%  ## $accountnumber) %>%
                filter(!accountnumber %in% branchThrouAcquisition) %>%
                select(accountnumber, inst_nm, StateCounty) %>%
                unique() %>%
                group_by(StateCounty, inst_nm) %>%
                mutate(branchNBR = table(inst_nm)) %>%
                filter(branchNBR == 1) %>%
                mutate(branchType = "B1") %>%
                select(-branchNBR)

    ##   Extract institutions with possible multiple branches, no Jan.1999 data  ##
    branchBX = branchB %>% anti_join(branchB1, by="inst_nm") %>%
               select(accountnumber, inst_nm) %>%
               unique()

    products_in_filter = c("1 Year ARM @ 175K - Rate",
                          "15 Yr Fxd Mtg @ 175K - Rate",
                          "30 Yr Fxd Mtg @ 175K - Rate",
                          "Auto New - 36 Mo Term","Auto New - 60 Mo Term",
                          "Auto Used 2 Yrs - % Financed",
                          "Home E.L.O.C. up to 80% LTV - Annual Fee",
                          "Home E.L.O.C. up to 80% LTV - Tier 1",
                          "Home E.L.O.C. up to 80% LTV - Tier 4",
                          "Personal Unsecured Loan - Tier 1",
                          "Personal Unsecured Loan - Tier 4")

    branchBXX = smarket_raw %>%
                filter(accountnumber %in% branchBX$accountnumber) %>%
                left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
                group_by(prod_code, accountnumber) %>%
                mutate(survey_span = table(prod_code)) %>%
                ungroup() %>% group_by(inst_nm,prod_code) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
                ungroup() %>%
                select(accountnumber, inst_nm, prod_name, survey_span) %>%
                filter(prod_name %in% products_in_filter) %>%
                unique()

  ##   branchBXX = smarket_raw %>%
  ##             filter(accountnumber %in% branchBX$accountnumber) %>%
  ##             left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
  ##             group_by(prod_code) %>%
  ##             group_by(accountnumber) %>%  ## grouping by accountnumber
  ##             mutate(survey_span = table(accountnumber)) %>%   ## calculate the survey span
  ##             ungroup() %>% group_by(inst_nm) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
  ##             ungroup() %>%
  ##             select(accountnumber, inst_nm, survey_span) %>%
  ##             unique()

    branchB2 = branchBXX %>%
               group_by(prod_name, inst_nm) %>%
               mutate(branchNBR = table(inst_nm)) %>%
               filter(branchNBR == 1) %>%
               mutate(branchType = "B2") %>%
               ungroup() %>%
               select(-branchNBR, -survey_span)

    branchB3 = branchBXX %>%
               anti_join(branchB2, by = "accountnumber") %>%
               left_join(data_complement %>% select(-inst_nm), by = "accountnumber") %>%
               group_by(prod_name, inst_nm) %>%
               top_n(1, branchdeposits) %>%
               ungroup() %>%
               select(-branchdeposits, -prod_name, - survey_span) %>%
               mutate(branchType = "B3")

    branchB2 = branchB2 %>% select(-prod_name)

    ABSelect = rbind(tbl_df(branchA), tbl_df(branchB1), tbl_df(branchB2), tbl_df(branchB3))

    select_data = smarket_raw %>%
                  left_join(ABSelect, by = "accountnumber") %>%
                  na.omit()

    write_csv(select_data, paste0("../../RW_MasterHistoricalLoanData_042018/smarketBranchSelect/",j))
