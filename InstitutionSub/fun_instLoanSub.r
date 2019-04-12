inst_loan_subset = function(j)
{
  temp = tbl_df(c())
  start_time = Sys.time()
  inst_count = c()

  for (i in 1:length(file_list))
      {
            branch.in.inst_nm = Loan_InstitutionDetails %>% filter( inst_nm == j) %>% pull(accountnumber)
            ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
            loan.raw = read_delim(paste0("../../RW_MasterHistoricalLoanData_042018/",file_list[i]), delim = "|") %>%
                        filter(prod_name %in% rates.array) %>%
                        filter(accountnumber %in% branch.in.inst_nm) %>%
                        select(accountnumber, prod_code, prod_name, date, applicablemeasurement)
            nrow_temp = nrow(temp)
            temp = rbind(temp, loan.raw)
            inst_count = c(inst_count, nrow(temp)-nrow_temp)

      }
  timestamp_n = c(j,as.character(start_time), as.character(Sys.time()), inst_count)
  write_csv(temp, paste0("../../InstSelect/", j, "Loan", ".csv"))
  rm(temp)
  return(timestamp_n)
}
