inst_deposit_subset = function(j)
{
  temp = tbl_df(c())
  start_time = Sys.time()
  inst_count = c()
  for (i in 1:length(files.name.array))
      {
            deposit.raw = read_delim(paste0("../../RW_MasterHistoricalDepositFiles_042018/",files.name.array[i]), delim = "|")
            ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
            summary(deposit.raw)
            deposit.raw = deposit.raw %>% filter(productcode %in% rates.array)
            branch.in.inst_nm = Deposit_InstitutionDetails %>% filter( CERT_NBR == j) %>% pull(ACCT_NBR)
            nrow_temp = nrow(temp)
            temp = rbind(temp, deposit.raw %>% filter(accountnumber %in% branch.in.inst_nm) %>% select(accountnumber, productcode, rate, surveydate))
            inst_count = c(inst_count, nrow(temp)-nrow_temp)

      }
  timestamp_n = c(j,as.character(start_time), as.character(Sys.time()), MSA_count)
  write_csv(temp, paste0("../../InstSelect/", j, "_Deposit", ".csv"))
  rm(temp)
  return(timestamp_n)
}
