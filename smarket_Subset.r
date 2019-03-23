smarket_subset = function(j)
{
  temp = tbl_df(c())
  smarket_count = c()
  start_time = Sys.time()
  for (i in 1:length(files.name.array[1:2]))
    {
          deposit.raw = read_delim(paste0("../",files.name.array[i]), delim = "|")
          ## deposit.raw = deposit.raw %>% mutate_if(is.character, as.factor)
          ## summary(deposit.raw)
          deposit.raw = deposit.raw %>% filter(productcode %in% rates.array)
          branch.in.smarket = j[1,]
          nrow_temp = nrow(temp)
          temp = rbind(temp, deposit.raw %>% filter(accountnumber %in% branch.in.smarket) %>% select(accountnumber, productcode, rate, surveydate))
          smarket_count = c(smarket_count, nrow(temp)-nrow_temp)

    }
  timestamp_smarket = c(j[1,2],as.character(start_time), as.character(Sys.time()), smarket_count)
  write_csv(temp, paste0("../smarket/", "smarket", j[1,2] ,".csv"))
  return(timestamp_smarket)
}
