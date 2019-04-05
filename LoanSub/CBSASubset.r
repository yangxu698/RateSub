
CBSA_subset = function(j)
{
  temp = tbl_df(c())
  CBSA_count = c()
  start_time = Sys.time()
  branch.in.CBSA = unlist(Loan_InstitutionDetails %>% filter( cbsa == j) %>% pull(accountnumber))
  for (i in 1:length(file_list))
    {
          deposit.raw = read_delim(paste0("../../../RW_MasterHistoricalLoanData_042018/",file_list[i]), delim = "|") %>%
                        filter(prod_name %in% productfilter) %>%
                        filter(accountnumber %in% branch.in.MSA) %>%
                        select(accountnumber, prod_code, prod_name, date, applicablemeasurement)
          ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
          ## summary(deposit.raw)
          nrow_temp = nrow(temp)
          temp = rbind(temp, deposit.raw %>% filter(accountnumber %in% branch.in.CBSA) %>% select(accountnumber, productcode, rate, surveydate))
          CBSA_count = c(CBSA_count, nrow(temp)-nrow_temp)

    }
  timestamp_CBSA = c(j,as.character(start_time), as.character(Sys.time()), CBSA_count)
  write_csv(temp, paste0("../../../RW_MasterHistoricalLoanData_042018/CBSA/", "CBSA",ifelse(j %in% CBSAcommon, "wMSA", "noMSA"), j ,".csv"))
  return(timestamp_CBSA)
}
