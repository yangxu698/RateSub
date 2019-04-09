MSABranchLoop = function(j)
{
    MSA_raw = read_csv(paste0("../../RW_MasterHistoricalLoanData_042018/MSA/",j))
    str(MSA_raw)
    ##   Extract institutions with only one branch in this MSA   ##
    branch =  MSA_raw %>%
              left_join(data_complement, by = "accountnumber") %>%
              select(accountnumber, prod_code, date, applicablemeasurement, inst_nm, branchdeposits) %>%
              ## group_by(prod_code) %>%
              select(accountnumber, inst_nm) %>%
              ## group_by(inst_nm, prod_code) %>%
              unique() %>%
              group_by(inst_nm) %>%
              mutate(branchNBR = table(inst_nm))

    branchA = branch %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = "A") %>%
              select(-branchNBR) %>%
              mutate(branchType = ifelse(branchType %in% branchThrouAcquisition, paste0(branchType,"1"),paste0(branchType,"2")))
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
                mutate(branchType = "B1")

    ##   Extract institutions with possible multiple branches, no Jan.1999 data  ##
    branchBX = branchB %>% anti_join(branchB1, by="inst_nm") %>%
               ## group_by(prod_code) %>%
               select(accountnumber, inst_nm) %>%
               ## group_by(inst_nm)
               unique()
               ## mutate(branchType = "B1")


    branchBXX = MSA_raw %>%
              filter(accountnumber %in% branchBX$accountnumber) %>%
              left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
              group_by(prod_code, accountnumber) %>%
              mutate(survey_span1 = table(prod_code)) %>%
              ## group_by(accountnumber) %>%  ## grouping by accountnumber
              ## mutate(survey_span = table(accountnumber)) %>%   ## calculate the survey span
              ## ungroup() %>% group_by(inst_nm) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
              ungroup() %>% group_by(inst_nm,prod_code) %>% top_n(1, survey_span1)  %>% ## grouping by institution name and select the longest survey span
              ungroup() %>%
              select(accountnumber, inst_nm, prod_name, survey_span1) %>%
              unique()

    branchBXX1 = MSA_raw %>%
              filter(accountnumber %in% branchBX$accountnumber) %>%
              left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
              group_by(prod_code) %>%
              group_by(accountnumber) %>%  ## grouping by accountnumber
              mutate(survey_span = table(accountnumber)) %>%   ## calculate the survey span
              ungroup() %>% group_by(inst_nm) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
              ungroup() %>%
              select(accountnumber, inst_nm, survey_span) %>%
              unique()

    branchB2 = branchBXX %>%
               group_by(inst_nm) %>%
               mutate(branchNBR = table(inst_nm)) %>%
               filter(branchNBR == 1) %>%
               mutate(branchType = "B2") %>%
               select(-branchNBR)

    branchB3 = branchBXX %>%
               anti_join(branchB2, by = "inst_nm") %>%
               left_join(data_complement %>% select(-inst_nm), by = "accountnumber") %>%
               group_by(inst_nm) %>%
               top_n(1, branchdeposits) %>%
               select(-branchdeposits) %>%
               mutate(branchType = "B3")

    ABSelect = rbind(tbl_df(branchA), tbl_df(branchB1), tbl_df(branchB2), tbl_df(branchB3))

    select_data = MSA_raw %>%
                  left_join(ABSelect, by = "accountnumber") %>%
                  na.omit()

    write_csv(select_data, paste0("../../RW_MasterHistoricalLoanData_042018/MSABranchSelect/",j))
    return(j)
}
