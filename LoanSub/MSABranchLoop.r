MSABranchLoop = function(j)
{
    MSA_raw = read_csv(paste0("../../RW_MasterHistoricalLoanData_042018/MSA/",j))
    str(MSA_raw)
    ##   Extract institutions with only one branch in this MSA   ##
    branch =  MSA_raw %>%
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


    branchBXX = MSA_raw %>%
                left_join(branchBX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
                group_by(prod_code, accountnumber) %>%
                mutate(survey_span = table(prod_code)) %>%
                ungroup() %>% group_by(inst_nm,prod_code) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
                ungroup() %>%
                select(accountnumber, inst_nm, prod_name, survey_span) %>%
                filter(prod_name %in% products_in_filter) %>%
                unique()

  ##   branchBXX = MSA_raw %>%
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
               ungroup() %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Amort", branchType = "B2_ARM_Amort") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Caps", branchType = "B2_ARM_Caps") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Dwn Pmt", branchType = "B2_Dwn_Pmt") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Orig Fees", branchType = "B2_ARM_Orig_Fees") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Points", branchType = "B2_ARM_Points") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Rate", branchType = "B2_ARM_Rate") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Dwn Pmt", branchType = "B2_15YrFxdMtg_DwnPmt") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Orig Fees", branchType = "B2_15YrFxdMtg_OrigFees") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Points", branchType = "B2_15YrFxdMtg_Points") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Rate", branchType = "B2_15YrFxdMtg_Rate") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Dwn Pmt", branchType = "B2_30YrFxdMtg_DwnPmt") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Orig Fees", branchType = "B2_30YrFxdMtg_OrigFees") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Points", branchType = "B2_30YrFxdMtg_Points") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Rate", branchType = "B2_30YrFxdMtg_Rate") %>%
               mutate_if(prod_name =="Auto New - 36 Mo Term", branchType = "B2_AutoNew_36MoTerm") %>%
               mutate_if(prod_name =="Auto New - 60 Mo Term", branchType = "B2_AutoNew_60MoTerm") %>%
               mutate_if(prod_name =="Auto Used 2 Yrs - % Financed", branchType = "AutoUsed2YR_%Financed") %>%
               mutate_if(prod_name =="Home E.L.O.C. up to 80% LTV - Annual Fee", branchType = "B2_HomeELOC80%LTV_AnnualFee") %>%
               mutate_if(prod_name =="Home E.L.O.C. up to 80% LTV - Tier 1", branchType = "B2_HomeELOC80%LTV_Tier1") %>%
               mutate_if(prod_name =="Home E.L.O.C. up to 80% LTV - Tier 4", branchType = "B2_HomeELOC80%LTV_Tier4") %>%
               mutate_if(prod_name =="Personal Unsecured Loan - Tier 1", branchType = "B2_PersonalUnsecuredLoan_Tier1") %>%
               mutate_if(prod_name =="Personal Unsecured Loan - Tier 4", branchType = "B2_PersonalUnsecuredLoan_Tier4")
               ungroup() %>%
               select(-branchNBR, -survey_span)

    branchB3 = branchBXX %>%
               anti_join(branchB2, by = "accountnumber") %>%
               left_join(data_complement %>% select(-inst_nm), by = "accountnumber") %>%
               group_by(prod_name, inst_nm) %>%
               top_n(1, branchdeposits) %>%
               ungroup() %>%
               select(-branchdeposits, -survey_span) %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Amort", branchType = "B3_ARM_Amort") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Caps", branchType = "B3_ARM_Caps") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Dwn Pmt", branchType = "B3_Dwn_Pmt") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Orig Fees", branchType = "B3_ARM_Orig_Fees") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Points", branchType = "B3_ARM_Points") %>%
               mutate_if(prod_name =="1 Year ARM @ 175K - Rate", branchType = "B3_ARM_Rate") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Dwn Pmt", branchType = "B3_15YrFxdMtg_DwnPmt") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Orig Fees", branchType = "B3_15YrFxdMtg_OrigFees") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Points", branchType = "B3_15YrFxdMtg_Points") %>%
               mutate_if(prod_name =="15 Yr Fxd Mtg @ 175K - Rate", branchType = "B3_15YrFxdMtg_Rate") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Dwn Pmt", branchType = "B3_30YrFxdMtg_DwnPmt") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Orig Fees", branchType = "B3_30YrFxdMtg_OrigFees") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Points", branchType = "B3_30YrFxdMtg_Points") %>%
               mutate_if(prod_name =="30 Yr Fxd Mtg @ 175K - Rate", branchType = "B3_30YrFxdMtg_Rate") %>%
               mutate_if(prod_name =="Auto New - 36 Mo Term", branchType = "B3_AutoNew_36MoTerm") %>%
               mutate_if(prod_name =="Auto New - 60 Mo Term", branchType = "B3_AutoNew_60MoTerm") %>%
               mutate_if(prod_name =="Auto Used 2 Yrs - % Financed", branchType = "AutoUsed2YR_%Financed") %>%
               mutate_if(prod_name =="Home E.L.O.C. up to 80% LTV - Annual Fee", branchType = "B3_HomeELOC80%LTV_AnnualFee") %>%
               mutate_if(prod_name =="Home E.L.O.C. up to 80% LTV - Tier 1", branchType = "B3_HomeELOC80%LTV_Tier1") %>%
               mutate_if(prod_name =="Home E.L.O.C. up to 80% LTV - Tier 4", branchType = "B3_HomeELOC80%LTV_Tier4") %>%
               mutate_if(prod_name =="Personal Unsecured Loan - Tier 1", branchType = "B3_PersonalUnsecuredLoan_Tier1") %>%
               mutate_if(prod_name =="Personal Unsecured Loan - Tier 4", branchType = "B3_PersonalUnsecuredLoan_Tier4")

    ## branchB2 = branchB2 %>% select(-prod_name)

    ABSelect = rbind(tbl_df(branchA), tbl_df(branchB1))
    B1B2Select = rbind(tbl_df(branchB2), tbl_df(branchB3)) %>%
                 left_join(MSA_raw, by = c("accountnumber",  "prod_name"))

    select_data = MSA_raw %>%
                  left_join(ABSelect, by = "accountnumber") %>%
                  na.omit() %>%
                  select(colnames(B1B2Select)) %>%
                  rbind(B1B2Select)

    write_csv(select_data, paste0("../../RW_MasterHistoricalLoanData_042018/MSABranchSelect/",j))
    return(j)
}
