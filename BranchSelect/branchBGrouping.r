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
  branchBX = MSA_raw %>%
              filter(accountnumber %in% branchBX2_temp$accountnumber & productcode == "12MCD10K") %>%
              mutate(date_num = as.numeric(as.POSIXct(surveydate))) %>%
              left_join(branchBXXXXXX, by = "accountnumber") %>%  ## append the info: institution name and branch deposits
              group_by(accountnumber) %>%  ## grouping by accountnumber
              mutate(survey_span = max(date_num) - min(date_num)) %>%   ## calculate the survey span
              ungroup() %>% group_by(INST_NM) %>% top_n(1, survey_span)  %>% ## grouping by institution name and select the longest survey span
              ungroup() %>%
              select(accountnumber, INST_NM, branchType) %>%
              unique() %>%
              group_by(INST_NM) %>%
              mutate(branchNBR = table(INST_NM))

    branchBX2 = branchBX %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = paste0(branchType,"2")) %>%
              select(-branchNBR)

    branchBX3_temp = branchBX %>%
                  anti_join(branchBX2, by = "INST_NM") %>%
                  filter(! accountnumber %in% branchThrouAcquisition) %>%
                  group_by(INST_NM) %>%
                  mutate(branchNBR = table(INST_NM))
    branchBX3 = branchBX3_temp %>%
                filter(branchNBR == 1) %>%
                mutate(branchType = paste0(branchType,"3")) %>%
                select(-branchNBR)
    branchBX4_temp = branchBX %>%
                  anti_join(branchBX2, by = "INST_NM") %>%
                  filter(accountnumber %in% branchThrouAcquisition) %>%
                  anti_join(branchBX3, by = "INST_NM") %>%
                  group_by(INST_NM) %>%
                  mutate(branchNBR = table(INST_NM))
    branchBX4 = branchBX3_temp %>%
                 filter(branchNBR > 1) %>%
                 rbind(branchBX4_temp) %>%
                 left_join(data_complement[,c(1,3)], by = "accountnumber") %>%
                 group_by(INST_NM) %>%
                 top_n(1,BRANCHDEPOSITS) %>%
                 ungroup() %>%
                 select(-BRANCHDEPOSITS,-branchNBR)  %>%
                 mutate(branchType = paste0(branchType,"4"))

return(rbind(tbl_df(branchBX1), tbl_df(branchBX2), tbl_df(branchBX3), tbl_df(branchBX4)))

}
