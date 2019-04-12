unlink(".RData")
rm(list=ls())

library(dplyr)
library(readr)
Deposit_InstitutionDetails = read_delim("../../RW_MasterHistoricalDepositFiles_042018/Deposit_InstitutionDetails.txt", delim = "|")

rates.array = c("06MCD10K", "12MCD10K", "60MCD10K", "INTCK0K", "INTCK2.5K", "FIXIRA0K", "VARIRA0K", "SAVE2.5K", "MM10K", "MM25K")

files.name.array = c("depositRateData_2000_09.txt","depositRateData_2003_09.txt","depositRateData_2006_09.txt","depositRateData_2009_09.txt","depositRateData_2012_09.txt","depositRateData_2015_09.txt",
"depositRateData_2000_10.txt","depositRateData_2003_10.txt","depositRateData_2006_10.txt","depositRateData_2009_10.txt","depositRateData_2012_10.txt","depositRateData_2015_10.txt",
"depositRateData_2000_11.txt","depositRateData_2003_11.txt","depositRateData_2006_11.txt","depositRateData_2009_11.txt","depositRateData_2012_11.txt","depositRateData_2015_11.txt",
"depositRateData_2000_12.txt","depositRateData_2003_12.txt","depositRateData_2006_12.txt","depositRateData_2009_12.txt","depositRateData_2012_12.txt","depositRateData_2015_12.txt",
"depositRateData_1998_01.txt","depositRateData_2001_01.txt","depositRateData_2004_01.txt","depositRateData_2007_01.txt","depositRateData_2010_01.txt","depositRateData_2013_01.txt","depositRateData_2016_01.txt",
"depositRateData_1998_02.txt","depositRateData_2001_02.txt","depositRateData_2004_02.txt","depositRateData_2007_02.txt","depositRateData_2010_02.txt","depositRateData_2013_02.txt","depositRateData_2016_02.txt",
"depositRateData_1998_03.txt","depositRateData_2001_03.txt","depositRateData_2004_03.txt","depositRateData_2007_03.txt","depositRateData_2010_03.txt","depositRateData_2013_03.txt","depositRateData_2016_03.txt",
"depositRateData_1998_04.txt","depositRateData_2001_04.txt","depositRateData_2004_04.txt","depositRateData_2007_04.txt","depositRateData_2010_04.txt","depositRateData_2013_04.txt","depositRateData_2016_04.txt",
"depositRateData_1998_05.txt","depositRateData_2001_05.txt","depositRateData_2004_05.txt","depositRateData_2007_05.txt","depositRateData_2010_05.txt","depositRateData_2013_05.txt","depositRateData_2016_05.txt",
"depositRateData_1998_06.txt","depositRateData_2001_06.txt","depositRateData_2004_06.txt","depositRateData_2007_06.txt","depositRateData_2010_06.txt","depositRateData_2013_06.txt","depositRateData_2016_06.txt",
"depositRateData_1998_07.txt","depositRateData_2001_07.txt","depositRateData_2004_07.txt","depositRateData_2007_07.txt","depositRateData_2010_07.txt","depositRateData_2013_07.txt","depositRateData_2016_07.txt",
"depositRateData_1998_08.txt","depositRateData_2001_08.txt","depositRateData_2004_08.txt","depositRateData_2007_08.txt","depositRateData_2010_08.txt","depositRateData_2013_08.txt","depositRateData_2016_08.txt",
"depositRateData_1998_09.txt","depositRateData_2001_09.txt","depositRateData_2004_09.txt","depositRateData_2007_09.txt","depositRateData_2010_09.txt","depositRateData_2013_09.txt","depositRateData_2016_09.txt",
"depositRateData_1998_10.txt","depositRateData_2001_10.txt","depositRateData_2004_10.txt","depositRateData_2007_10.txt","depositRateData_2010_10.txt","depositRateData_2013_10.txt","depositRateData_2016_10.txt",
"depositRateData_1998_11.txt","depositRateData_2001_11.txt","depositRateData_2004_11.txt","depositRateData_2007_11.txt","depositRateData_2010_11.txt","depositRateData_2013_11.txt","depositRateData_2016_11.txt",
"depositRateData_1998_12.txt","depositRateData_2001_12.txt","depositRateData_2004_12.txt","depositRateData_2007_12.txt","depositRateData_2010_12.txt","depositRateData_2013_12.txt","depositRateData_2016_12.txt",
"depositRateData_1999_01.txt","depositRateData_2002_01.txt","depositRateData_2005_01.txt","depositRateData_2008_01.txt","depositRateData_2011_01.txt","depositRateData_2014_01.txt","depositRateData_2017_01.txt",
"depositRateData_1999_02.txt","depositRateData_2002_02.txt","depositRateData_2005_02.txt","depositRateData_2008_02.txt","depositRateData_2011_02.txt","depositRateData_2014_02.txt","depositRateData_2017_02.txt",
"depositRateData_1999_03.txt","depositRateData_2002_03.txt","depositRateData_2005_03.txt","depositRateData_2008_03.txt","depositRateData_2011_03.txt","depositRateData_2014_03.txt","depositRateData_2017_03.txt",
"depositRateData_1999_04.txt","depositRateData_2002_04.txt","depositRateData_2005_04.txt","depositRateData_2008_04.txt","depositRateData_2011_04.txt","depositRateData_2014_04.txt","depositRateData_2017_04.txt",
"depositRateData_1999_05.txt","depositRateData_2002_05.txt","depositRateData_2005_05.txt","depositRateData_2008_05.txt","depositRateData_2011_05.txt","depositRateData_2014_05.txt","depositRateData_2017_05.txt",
"depositRateData_1999_06.txt","depositRateData_2002_06.txt","depositRateData_2005_06.txt","depositRateData_2008_06.txt","depositRateData_2011_06.txt","depositRateData_2014_06.txt","depositRateData_2017_06.txt",
"depositRateData_1999_07.txt","depositRateData_2002_07.txt","depositRateData_2005_07.txt","depositRateData_2008_07.txt","depositRateData_2011_07.txt","depositRateData_2014_07.txt","depositRateData_2017_07.txt",
"depositRateData_1999_08.txt","depositRateData_2002_08.txt","depositRateData_2005_08.txt","depositRateData_2008_08.txt","depositRateData_2011_08.txt","depositRateData_2014_08.txt","depositRateData_2017_08.txt",
"depositRateData_1999_09.txt","depositRateData_2002_09.txt","depositRateData_2005_09.txt","depositRateData_2008_09.txt","depositRateData_2011_09.txt","depositRateData_2014_09.txt","depositRateData_2017_09.txt",
"depositRateData_1999_10.txt","depositRateData_2002_10.txt","depositRateData_2005_10.txt","depositRateData_2008_10.txt","depositRateData_2011_10.txt","depositRateData_2014_10.txt","depositRateData_2017_10.txt",
"depositRateData_1999_11.txt","depositRateData_2002_11.txt","depositRateData_2005_11.txt","depositRateData_2008_11.txt","depositRateData_2011_11.txt","depositRateData_2014_11.txt","depositRateData_2017_11.txt",
"depositRateData_1999_12.txt","depositRateData_2002_12.txt","depositRateData_2005_12.txt","depositRateData_2008_12.txt","depositRateData_2011_12.txt","depositRateData_2014_12.txt","depositRateData_2017_12.txt",
"depositRateData_2000_01.txt","depositRateData_2003_01.txt","depositRateData_2006_01.txt","depositRateData_2009_01.txt","depositRateData_2012_01.txt","depositRateData_2015_01.txt","depositRateData_2018_01.txt",
"depositRateData_2000_02.txt","depositRateData_2003_02.txt","depositRateData_2006_02.txt","depositRateData_2009_02.txt","depositRateData_2012_02.txt","depositRateData_2015_02.txt","depositRateData_2018_02.txt",
"depositRateData_2000_03.txt","depositRateData_2003_03.txt","depositRateData_2006_03.txt","depositRateData_2009_03.txt","depositRateData_2012_03.txt","depositRateData_2015_03.txt","depositRateData_2018_03.txt",
"depositRateData_2000_04.txt","depositRateData_2003_04.txt","depositRateData_2006_04.txt","depositRateData_2009_04.txt","depositRateData_2012_04.txt","depositRateData_2015_04.txt","depositRateData_2018_04.txt",
"depositRateData_2000_05.txt","depositRateData_2003_05.txt","depositRateData_2006_05.txt","depositRateData_2009_05.txt","depositRateData_2012_05.txt","depositRateData_2015_05.txt","depositRateData_2018_05.txt",
"depositRateData_2000_06.txt","depositRateData_2003_06.txt","depositRateData_2006_06.txt","depositRateData_2009_06.txt","depositRateData_2012_06.txt","depositRateData_2015_06.txt",
"depositRateData_2000_07.txt","depositRateData_2003_07.txt","depositRateData_2006_07.txt","depositRateData_2009_07.txt","depositRateData_2012_07.txt","depositRateData_2015_07.txt",
"depositRateData_2000_08.txt","depositRateData_2003_08.txt","depositRateData_2006_08.txt","depositRateData_2009_08.txt","depositRateData_2012_08.txt","depositRateData_2015_08.txt")

files.name.array = sort(files.name.array)
## setwd("./InstitutionSub")
inst_list = read_csv("BankNameList.csv") %>% pull(BankNamefromData)

library(foreach)
library(doParallel)
library(iterators)
source("fun_instDepoSub.r")
cores_number = 4
registerDoParallel(cores_number)
itx = iter(inst_list)
itx
timestamp_deposit = foreach(j = itx,.combine = 'rbind') %dopar%
                    {
                      inst_deposit_subset(j)
                    }
colnames(timestamp) = c("MSA", "start_time", "end_time", files.name.array)
timestamp = tbl_df(timestamp)
write_csv(timestamp, paste0("../../InstSelect/", "timestamp_deposit", as.character(Sys.time()),".csv"))
stopImplicitCluster()
