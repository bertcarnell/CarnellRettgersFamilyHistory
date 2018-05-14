# nohup Rscript GenealogyBank_ReadingAdler_Search.R -b '1820-01-01' -e '1830-01-01' -p 'Navy1998' -t 'obit' -g TRUE -q FALSE > log1830_obit_v2.txt

dirpath <- file.path("~", "repositories","CarnellRettgersFamilyHistory","search_output")

filelist <- list.files(file.path(dirpath, "img"))
length(filelist)

checkDateSet <- function(image_string, link_file, filelist)
{
  e <- new.env()
  print(length(grep(image_string, filelist)))
  load(file.path(dirpath, link_file), envir=e)
  links <- get("links", envir=e)
  print(length(links))
  
  file_dates <- as.Date(substring(filelist[grep(image_string, filelist)], 15, 24))
  for (i in seq_along(links))
  {
    ind <- regexpr("rgfromDate=[0-9][0-9][/][0-9][0-9][/][0-9][0-9][0-9][0-9]", links[i])
    link_date <- substring(links[i], ind+11, ind + attr(ind, "match.length") - 1)
    link_date <- as.Date(strptime(link_date, "%m/%d/%Y"))
    ind2 <- which(file_dates == link_date)
    if (length(ind2) == 0)
    {
      print(paste0("Link ", i, ": ", link_date))
    }
  }
}
checkDateSet("Reading_Adler_182.*Obituary.[gp][in][fg]", "links1830-01-01_obit.Rdata", filelist)
# no missing dates found
checkDateSet("Reading_Adler_182.*Marriage.[gp][in][fg]", "links1830-01-01_marriage.Rdata", filelist)
# no missing dates found

checkDateSet("Reading_Adler_181.*Obituary.[gp][in][fg]", "links1820-01-01_obit.Rdata", filelist)
# no missing dates found
checkDateSet("Reading_Adler_181.*Marriage.[gp][in][fg]", "links1820-01-01_marriage.Rdata", filelist)
# no missing dates found

checkDateSet("Reading_Adler_1[78][90].*Obituary.[gp][in][fg]", "links1810-01-01_obit.Rdata", filelist)
# no missing dates found
checkDateSet("Reading_Adler_180.*Marriage.[gp][in][fg]", "links1810-01-01_marriage.Rdata", filelist)
# no missing dates found

checkDateSet("Reading_Adler_183.*Obituary.[gp][in][fg]", "links1840-01-01_obit.Rdata", filelist)
checkDateSet("Reading_Adler_183.*Marriage.[gp][in][fg]", "links1840-01-01_marriage.Rdata", filelist)

checkDateSet("Reading_Adler_184.*Obituary.[gp][in][fg]", "links1850-01-01_obit.Rdata", filelist)
checkDateSet("Reading_Adler_184.*Marriage.[gp][in][fg]", "links1850-01-01_marriage.Rdata", filelist)

load(file.path(dirpath, "links1798.Rdata"))



