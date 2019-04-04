MSA_subset = function(j)
{

  temp = tbl_df(c())
  MSA_count = c()
  start_time = Sys.time()
  productfilter =  c("1 Year ARM @ 175K - Amort","1 Year ARM @ 175K - Caps","1 Year ARM @ 175K - Dwn Pmt",
                      "1 Year ARM @ 175K - Orig Fees","1 Year ARM @ 175K - Points", "1 Year ARM @ 175K - Rate",
                      "15 Yr Fxd Mtg @ 175K - Dwn Pmt","15 Yr Fxd Mtg @ 175K - Orig Fees","15 Yr Fxd Mtg @ 175K - Points",
                      "15 Yr Fxd Mtg @ 175K - Rate", "30 Yr Fxd Mtg @ 175K - Dwn Pmt", "30 Yr Fxd Mtg @ 175K - Orig Fees",
                      "30 Yr Fxd Mtg @ 175K - Points", "30 Yr Fxd Mtg @ 175K - Rate",
                      "Auto New - 36 Mo Term","Auto New - 60 Mo Term", "Auto Used 2 Yrs - 36 Mo Term",
                      "Auto Used 2 Yrs - 60 Mo Term", "Personal Unsecured Loan - Tier 1")
  ## "Auto New - % Financed", "Auto New - 48 Mo Term","Auto New - 72 Mo Term","Auto Used 2 Yrs - % Financed", "Auto Used 2 Yrs - 48 Mo Term", "Personal Unsecured Loan - Max Term",
  ## write.csv(j, paste0("../../../MSA/", j,"starts",".csv"))
  branch.in.MSA = unlist(Loan_InstitutionDetails %>% filter( msa == j) %>% pull(accountnumber))
  for (i in 1:length(files_list))
      {
            deposit.raw = read_delim(paste0("../../../RW_MasterHistoricalLoanData_042018/",files_list[i]), delim = "|") %>%
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
