MSA_subset = function(j)
{

  temp = tbl_df(c())
  MSA_count = c()
  start_time = Sys.time()
  for (i in 1:2) ##length(files.name.array))
      {
            deposit.raw = read_delim(paste0("../",files.name.array[i]), delim = "|")
            ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
            summary(deposit.raw)
            deposit.raw = deposit.raw %>% filter(productcode %in% rates.array)
            branch.in.MSA = unlist(Deposit_InstitutionDetails %>% filter( MSA == j) %>% select(ACCT_NBR))
            nrow_temp = nrow(temp)
            temp = rbind(temp, deposit.raw %>% filter(accountnumber %in% branch.in.MSA) %>% select(accountnumber, productcode, rate, surveydate))
            MSA_count = c(MSA_count, nrow(temp)-nrow_temp)

      }
  timestamp_MSA = c(j,as.character(start_time), as.character(Sys.time()), MSA_count)
  write_csv(temp, paste0("../E12core/", "MSA", j ,".csv"))
    ## rm(temp)
  return(timestamp_MSA)
}
