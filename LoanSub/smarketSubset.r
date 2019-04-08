smarket_subset = function(j)
{
  temp = tbl_df(c())
  smarket_count = c()
  start_time = Sys.time()
  branch.in.smarket = unlist(smarket %>% filter( StateCounty == j) %>% pull(accountnumber))
  for (i in 1:length(file_list))
    {
          deposit.raw = read_delim(paste0("../../../RW_MasterHistoricalLoanData_042018/",file_list[i]), delim = "|") %>%
                        filter(prod_name %in% productfilter) %>%
                        filter(accountnumber %in% branch.in.smarket) %>%
                        select(accountnumber, prod_code, prod_name, date, applicablemeasurement) %>%
                        left_join(smarket, by = "accountnumber")
          ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
          ## summary(deposit.raw)
          nrow_temp = nrow(temp)
          temp = rbind(temp,deposit.raw)
          smarket_count = c(smarket_count, nrow(temp)-nrow_temp)

    }
  timestamp_smarket = c(j,as.character(start_time), as.character(Sys.time()), smarket_count)
  ## write_csv(temp, paste0("../../../RW_MasterHistoricalLoanData_042018/smarket/", "smarket", j ,".csv"))
  ## return(timestamp_smarket)
  return(list(df = temp, stamp = timestamp_smarket))
}
