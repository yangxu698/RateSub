MSA_subset = function(j)
{

  temp = tbl_df(c())
  MSA_count = c()
  start_time = Sys.time()
  branch.in.MSA = unlist(Loan_InstitutionDetails %>% filter( msa == j) %>% pull(accountnumber))
  for (i in 1:length(file_list))
      {
            deposit.raw = read_delim(paste0("../../../RW_MasterHistoricalLoanData_042018/",file_list[i]), delim = "|") %>%
                          filter(prod_name %in% productfilter) %>%
                          filter(accountnumber %in% branch.in.MSA) %>%
                          select(accountnumber, prod_code, prod_name, date, applicablemeasurement)

            ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
            ## summary(deposit.raw)
            nrow_temp = nrow(temp)
            temp = rbind(temp, deposit.raw)
            MSA_count = c(MSA_count, nrow(temp)-nrow_temp)

      }
  timestamp_MSA = c(j,as.character(start_time), as.character(Sys.time()), MSA_count)
  write_csv(temp, paste0("../../../RW_MasterHistoricalLoanData_042018/MSA/", "MSA", j ,".csv"))
  rm(temp)
  return(timestamp_MSA)
}
