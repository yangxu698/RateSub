CBSA_subset = function(j)
{
  temp = tbl_df(c())
  CBSA_count = c()
  start_time = Sys.time()
  for (i in 1:length(files.name.array[1:2]))
    {
          deposit.raw = read_delim(paste0("../",files.name.array[i]), delim = "|")
          ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
          ## summary(deposit.raw)
          deposit.raw = deposit.raw %>% filter(productcode %in% rates.array)
          branch.in.CBSA = unlist(Deposit_InstitutionDetails %>% filter( CBSA == j) %>% select(ACCT_NBR))
          nrow_temp = nrow(temp)
          temp = rbind(temp, deposit.raw %>% filter(accountnumber %in% branch.in.CBSA) %>% select(accountnumber, productcode, rate, surveydate))
          CBSA_count = c(CBSA_count, nrow(temp)-nrow_temp)

    }
  timestamp_CBSA = c(j,as.character(start_time), as.character(Sys.time()), CBSA_count)
  write_csv(temp, paste0("../CBSA/", "CBSA", j ,".csv"))
  return(timestamp_CBSA)
}
