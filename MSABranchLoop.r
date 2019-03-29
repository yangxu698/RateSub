MSABranchLoop = function(j)
{
    MSA_raw = read_csv(paste0("../MSA/",j))
    str(MSA_raw)
    ##   Extract institutions with only one branch in this MSA   ##
    branch =  MSA_raw %>%
              left_join(data_complement, by = "accountnumber") %>%
              select(accountnumber, INST_NM) %>%
              group_by(INST_NM) %>%
              unique() %>%
              mutate(branchNBR = table(INST_NM))

    branchA1 = branch %>%
              filter(branchNBR == 1) %>%
              mutate(branchType = "A1") %>%
              select(-branchNBR)
    branchB = branch %>%
              filter(branchNBR > 1)


    ##   Extract institutions with possible multiple branches, with Jan.1999 data  ##
    branchB2 = MSA_raw %>%
              filter(accountnumber %in% branchB$accountnumber) %>%
              filter(accountnumber %in% data_199901 ) %>%
              left_join(data_complement, by = "accountnumber") %>%
              select(accountnumber, INST_NM) %>%
              unique() %>%
              mutate(branchType = "B2")

    ##   Extract institutions with possible multiple branches, no Jan.1999 data  ##
    branchB1 = branchB %>% anti_join(branchB2, by="INST_NM")%>%
              select(accountnumber, INST_NM) %>%
              unique() %>%
              mutate(branchType = "B1")

    B1group = branchBGrouping(branchB1)
    B2group = branchBGrouping(branchB2)

    ABSelect = rbind(tbl_df(branchA1), B1group, B2group)

    select_data = MSA_raw %>%
                  left_join(ABSelect, by = "accountnumber") %>%
                  na.omit()

    write_csv(select_data, paste0("../MSABranchSelect/",j))
    return(j)
}
