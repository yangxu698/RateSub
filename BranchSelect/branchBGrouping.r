branchBGrouping = function(branchBXXXXXX, MSA_raw)
{
  branchBX1 = branchBXXXXXX %>%
              group_by(INST_NM) %>%
              mutate(branchNBR = table(INST_NM)) %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = paste0(branchType,"1")) %>%
              select(-branchNBR)
  branchBX2_temp = branchBXXXXXX %>%
                  anti_join(branchBX1, by="INST_NM")
  branchBX = branchBX2_temp %>%
                  mutate(Acquisition = ifelse(accountnumber %in% branchThrouAcquisition, "YES", "NO")) %>%
                  group_by(INST_NM) %>%
                  mutate(branchNBR = table(Acquisition)[2]/table(INST_NM))   ## ratio that acquired branch over total branches, equal to "1" means all are from acquired

  branchBX2 = branchBX %>%
              filter(Acquisition == "NO") %>%
              ## filter(branchNBR != 1 | is.na(branchNBR)) %>%
              select(-Acquisition) %>%
              mutate(branchNBR = table(INST_NM)) %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = paste0(branchType, "2")) %>%
              select(-branchNBR)

  branchBX3_temp = branchBX %>%
                  anti_join(branchBX2, by = "INST_NM")

  branchBX3 = MSA_raw %>%
              filter(accountnumber %in% branchBX3_temp$accountnumber & productcode == "12MCD10K") %>%
              ## mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
              left_join(branchBXXXXXX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
              group_by(accountnumber) %>%  ## grouping by accountnumber
              mutate(survey_span = table(accountnumber)) %>%   ## calculate the survey span
              ungroup() %>% group_by(INST_NM) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
              ungroup() %>%
              select(accountnumber, INST_NM, branchType) %>%
              unique() %>%
              group_by(INST_NM) %>%
              mutate(branchNBR = table(INST_NM)) %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = paste0(branchType,"3")) %>%
              select(-branchNBR)

    branchBX4_temp = branchBX3_temp %>%
              anti_join(branchBX3, by="INST_NM") %>%
              select(-Acquisition)

    branchBX4 = branchBX4_temp %>%
                 left_join(data_complement[,c(1,3)], by = "accountnumber") %>%
                 group_by(INST_NM) %>%
                 top_n(1,BRANCHDEPOSITS) %>%
                 ungroup() %>%
                 select(-BRANCHDEPOSITS,-branchNBR)  %>%
                 mutate(branchType = paste0(branchType,"4"))
    category4 = rbind(tbl_df(branchBX1), tbl_df(branchBX2), tbl_df(branchBX3), tbl_df(branchBX4))
    institutionAllacquired = branchBX %>% filter(branchNBR == 1) %>% select(accountnumber, INST_NM)
    branchBX5 = branchBXXXXXX %>%
                anti_join(category4, by = "INST_NM") %>%
                mutate(branchType = ifelse(accountnumber %in% institutionAllacquired$accountnumber, paste0(branchType,"A"),paste0(branchType,"X")))
    if(nrow(tbl_df(branchBX5))>0)
    {
      write_csv(tbl_df(branch_BX5), paste0("AlertBranches",j,".csv"))
    }
    return(rbind(category4, tbl_df(branchBX5)))

}
