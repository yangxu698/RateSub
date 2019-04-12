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

smarket_raw = read.csv("../../RW_MasterHistoricalLoanData_042018/smarket/smarketInOne.csv", stringsAsFactors = FALSE)
str(smarket_raw)

    ##   Extract institutions with only one branch in this smarket   ##
    branch =  smarket_raw %>%
              left_join(data_complement, by = "accountnumber") %>%
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
              anti_join(branchA, by = 'accountnumber') %>%
              filter(!accountnumber %in% branchThrouAcquisition)


    ##   Extract institutions with possible multiple branches, with Jan.1999 data  ##
    branchB1 =  branchB  %>%  ## $accountnumber) %>%
                select(accountnumber, inst_nm, StateCounty) %>%
                unique() %>%
                group_by(StateCounty, inst_nm) %>%
                mutate(branchNBR = table(inst_nm)) %>%
                filter(branchNBR == 1) %>%
                mutate(branchType = "B1") %>%
                select(-branchNBR)

    ##   Extract institutions with possible multiple branches, no Jan.1999 data  ##
    branchBX = branchB %>% anti_join(branchB1, by="accountnumber") %>%
               select(accountnumber, inst_nm, StateCounty) %>%
               unique()

    branchBXX = smarket_raw %>%
                select(-StateCounty) %>%
                filter(accountnumber %in% branchBX$accountnumber) %>%
                left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
                group_by(StateCounty, prod_code, accountnumber) %>%
                mutate(survey_span = table(prod_code)) %>%
                ungroup() %>% group_by(StateCounty,inst_nm,prod_code) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
                ungroup() %>%
                select(accountnumber, inst_nm, prod_name, survey_span, StateCounty) %>%
                ## filter(prod_name %in% products_in_filter) %>%
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
               group_by(StateCounty, inst_nm, prod_name) %>%
               mutate(branchNBR = table(inst_nm)) %>%
               filter(branchNBR == 1) %>%
               mutate(branchType = "B2") %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Amort","B2_1ARM_Amort", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Caps","B2_1ARM_Caps", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Dwn Pmt","B2_1ARM_Dwn_Pmt", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Orig Fees","B2_1ARM_Orig_Fees", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Points","B2_1ARM_Points", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Rate","B2_1ARM_Rate", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Dwn Pmt","B2_15YrFxdMtg_DwnPmt", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Orig Fees","B2_15YrFxdMtg_OrigFees", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Points","B2_15YrFxdMtg_Points", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Rate","B2_15YrFxdMtg_Rate", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Dwn Pmt","B2_30YrFxdMtg_DwnPmt", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Orig Fees","B2_30YrFxdMtg_OrigFees", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Points","B2_30YrFxdMtg_Points", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Rate","B2_30YrFxdMtg_Rate", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Auto New - 36 Mo Term","B2_AutoNew_36MoTerm", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Auto New - 60 Mo Term","B2_AutoNew_60MoTerm", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Auto Used 2 Yrs - % Financed","B2_AutoUsed2Yr_%Financed", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Home E.L.O.C. up to 80% LTV - Annual Fee","B2_HomeELOC80%LTV_AnnualFee", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Home E.L.O.C. up to 80% LTV - Tier 1","B2_HomeELOC80%LTV_Tier1", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Home E.L.O.C. up to 80% LTV - Tier 4","B2_HomeELOC80%LTV_Tier4", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Personal Unsecured Loan - Tier 1","B2_PersonalUnsecuredLoan_Tier1", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Personal Unsecured Loan - Tier 4","B2_PersonalUnsecuredLoan_Tier4", .))) %>%               ungroup() %>%
               select(-branchNBR, -survey_span)

    branchB3 = branchBXX %>%
               anti_join(branchB2, by = c("StateCounty","prod_name","inst_nm")) %>%
               left_join(data_complement %>% select(-inst_nm), by = "accountnumber") %>%
               group_by(prod_name, inst_nm) %>%
               top_n(1, branchdeposits) %>%
               ungroup() %>%
               select(-branchdeposits,  -survey_span) %>%
               mutate(branchType = "B3") %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Amort","B3_1ARM_Amort", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Caps","B3_1ARM_Caps", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Dwn Pmt","B3_1ARM_Dwn_Pmt", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Orig Fees","B3_1ARM_Orig_Fees", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Points","B3_1ARM_Points", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "1 Year ARM @ 175K - Rate","B3_1ARM_Rate", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Dwn Pmt","B3_15YrFxdMtg_DwnPmt", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Orig Fees","B3_15YrFxdMtg_OrigFees", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Points","B3_15YrFxdMtg_Points", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "15 Yr Fxd Mtg @ 175K - Rate","B3_15YrFxdMtg_Rate", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Dwn Pmt","B3_30YrFxdMtg_DwnPmt", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Orig Fees","B3_30YrFxdMtg_OrigFees", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Points","B3_30YrFxdMtg_Points", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "30 Yr Fxd Mtg @ 175K - Rate","B3_30YrFxdMtg_Rate", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Auto New - 36 Mo Term","B3_AutoNew_36MoTerm", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Auto New - 60 Mo Term","B3_AutoNew_60MoTerm", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Auto Used 2 Yrs - % Financed","B3_AutoUsed2Yr_%Financed", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Home E.L.O.C. up to 80% LTV - Annual Fee","B3_HomeELOC80%LTV_AnnualFee", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Home E.L.O.C. up to 80% LTV - Tier 1","B3_HomeELOC80%LTV_Tier1", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Home E.L.O.C. up to 80% LTV - Tier 4","B3_HomeELOC80%LTV_Tier4", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Personal Unsecured Loan - Tier 1","B3_PersonalUnsecuredLoan_Tier1", .))) %>%
               mutate_at(vars(contains("branchType")), funs(ifelse(prod_name == "Personal Unsecured Loan - Tier 4","B3_PersonalUnsecuredLoan_Tier4", .)))

    ABSelect = rbind(tbl_df(branchA), tbl_df(branchB1))
    B2B3Select = rbind(tbl_df(branchB2), tbl_df(branchB3)) %>%
                 left_join(smarket_raw, by = c("accountnumber",  "prod_name", "StateCounty"))
    select_data = smarket_raw %>%
                  left_join(ABSelect, by = c("accountnumber", "StateCounty")) %>%
                  na.omit() %>%
                  select(colnames(B2B3Select)) %>%
                  rbind(B2B3Select)

    write_csv(select_data, "../../../smarketBranchSelectInOne.csv")
    write_csv(select_data, paste0("../../RW_MasterHistoricalLoanData_042018/smarketBranchSelect/",j))
