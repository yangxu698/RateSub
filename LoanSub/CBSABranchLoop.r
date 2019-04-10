CBSABranchLoop = function(j)
{
    CBSA_raw = read_csv(paste0("../../RW_MasterHistoricalLoanData_042018/CBSA/",j))
    str(CBSA_raw)
    ##   Extract institutions with only one branch in this CBSA   ##
    branch =  CBSA_raw %>%
              left_join(data_complement, by = "accountnumber") %>%
              select(accountnumber, prod_code, date, applicablemeasurement, inst_nm, branchdeposits) %>%
              select(accountnumber, inst_nm) %>%
              unique() %>%
              group_by(inst_nm) %>%
              mutate(branchNBR = table(inst_nm))

    branchA = branch %>%
              filter(branchNBR == 1) %>%
              select(-branchNBR) %>%
              mutate(branchType = ifelse(accountnumber %in% branchThrouAcquisition, "A1","A2"))

    branchB = branch %>%
              anti_join(branchA, by = 'inst_nm')


    ##   Extract institutions with possible multiple branches, with Jan.1999 data  ##
    branchB1 =  branchB  %>%  ## $accountnumber) %>%
                filter(!accountnumber %in% branchThrouAcquisition) %>%
                select(accountnumber, inst_nm) %>%
                unique() %>%
                group_by(inst_nm) %>%
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

    branchBXX = CBSA_raw %>%
                filter(accountnumber %in% branchBX$accountnumber) %>%
                left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
                group_by(prod_code, accountnumber) %>%
                mutate(survey_span = table(prod_code)) %>%
                ungroup() %>% group_by(inst_nm,prod_code) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
                ungroup() %>%
                select(accountnumber, inst_nm, prod_name, survey_span) %>%
                filter(prod_name %in% products_in_filter) %>%
                unique()

    ## branchBXX = CBSA_raw %>%
    ##           filter(accountnumber %in% branchBX$accountnumber) %>%
    ##           left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
    ##           group_by(prod_code) %>%
    ##           group_by(accountnumber) %>%  ## grouping by accountnumber
    ##           mutate(survey_span = table(accountnumber)) %>%   ## calculate the survey span
    ##           ungroup() %>% group_by(inst_nm) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
    ##           ungroup() %>%
    ##           select(accountnumber, inst_nm) %>%
    ##           unique()

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

    select_data = CBSA_raw %>%
                  left_join(ABSelect, by = "accountnumber") %>%
                  na.omit()

    write_csv(select_data, paste0("../../RW_MasterHistoricalLoanData_042018/CBSABranchSelect/",j))
    return(j)
}
