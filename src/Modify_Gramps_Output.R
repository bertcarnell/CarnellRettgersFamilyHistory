# R must also be installed on Ubuntu
#   sudo echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list
#   gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
#   gpg -a --export E084DAB9 | sudo apt-key add -
#   sudo apt-get update
#   sudo apt-get install r-base r-base-dev
# RStudio is nice - download the Ubuntu / Debian version from Rstudio
#   sudo apt-get install gdebi-core
#   sudo gdebi <downloaded .deb file>
# install required packages
#   sudo R
#   install.packages(c("assertthat","stringr"), repos="http://cran.stat.ucla.edu")

require(assertthat)
require(stringr)

if (grepl("Ubuntu",Sys.info()["version"]))
{
  repository_path <- file.path("~","Documents","repositories")
} else
{
  repository_path <- file.path("C:","Users","Rob","Documents","Repositories")
}
repository_path_ext <- file.path(repository_path, "CarnellRettgersFamilyHistory")
tex_input_path <- file.path(repository_path_ext, "tex_input")
tex_input_private_path <- file.path(repository_path_ext, "tex_input_private")
tex_output_path <- file.path(repository_path_ext, "tex_output")
obituary_input_path <- file.path(repository_path_ext, "other_input")

obituary_input_file <- file.path(obituary_input_path, "NewspaperLinksExport.csv")

if (!dir.exists(tex_output_path)) dir.create(tex_output_path)

ancestor_files <- c(paste0("det_ancestor_report_", 
                         c("Bechtel","Fett","Hartenstine","Rettgers",
                           "Connell","Langston","Smith","Josey"), ".tex"),
                    paste0("det_descendant_report_", 
                         c("Fett","Rettgers",
                           "Connell","Smith"), ".tex"))
ancestor_files_path <- file.path(c(rep(tex_input_path, 8), rep(tex_input_private_path, 4)), ancestor_files)

dummy <- sapply(ancestor_files_path, function(x) {
  assertthat::assert_that(file.exists(x))
})
dummy <- assertthat::assert_that(file.exists(obituary_input_file))

################################################################################

# read the latex files as text
cat("Reading Latex Files\n")
X1 <- lapply(ancestor_files_path, function(x) {
  readLines(x)
})

cat("Processing Latex\n")

# remove the commands before \begin{document} and after \end{document}
X2 <- lapply(X1, function(x){
  ind_begin <- which(str_detect(x, "^[:punct:]begin[:punct:]document[:punct:]"))
  ind_end <- which(str_detect(x, "^[:punct:]end[:punct:]document[:punct:]"))
  temp <- x[(ind_begin+1):(ind_end-1)]
  ind_cut <- match(TRUE, str_detect(temp, "^[:punct:]grminpgtail[:punct:]"))
  temp <- temp[-(1:ind_cut)]
  return(temp)
})

# make other modifications
X3 <- lapply(X2, function(x){
  # Ancestry.com, "...
  y <- str_replace(x, "^Ancestry[.]com[,][ ][:punct:]*", "")
  # Ancestry.com and The Church of Jesus Christ of Latter-day Saints, 
  y <- str_replace(y, "^Ancestry[.]com[ ]and[ ]The[ ]Church[ ]of[ ]Jesus[ ]Christ[ ]of[ ]Latter[-]day[ ]Saints[,][ ]", "")
  # , Name: Ancestry.com Operations Inc; Location: Provo, UT, USA; Date:2010; 
  y <- str_replace(y, "[:punct:]*[,][ ]Name[:punct:][ ]Ancestry[.]com Operations[,]*[ ]Inc[.]*[;][ ]Location[:punct:][ ]Provo[,][ ]UT[,][ ]USA[;][ ]Date[:punct:][ ][0-9][0-9][0-9][0-9][;]","")
  # States, USA
  state_list <- gsub("[ ]", "[ ]", state.name)
  abbrev_list <- state.abb
  assert_that(length(state_list) == length(abbrev_list))
  for (i in seq_along(state_list))
  {
    y <- str_replace_all(y, paste0(state_list[i], "[,][ ]USA"), abbrev_list[i])
  }
  # Ancestry.com citation
  y <- str_replace_all(y, "UT[,][ ]USA", "UT")
  # Unknown (Husband name)
  y <- str_replace_all(y, "Unknown[ ][(][A-Za-z]+[)]", "\\\\underline{\\\\hspace{3em}}")
  # census citation
  #Year: 1940; Census Place: Reading, Berks, Pennsylvania; Roll: T627\_3680; Page: 10A; Enumeration District: 70-72 
  y <- str_replace_all(y, "Year[:punct:][ ]+[12][0-9][0-9][0-9][;][ ]+Census[ ]Place[:punct:][ ]+", "")
  y <- str_replace_all(y, "[;][ ]+Page[:punct:][ ]+", "; pg ")
  y <- str_replace_all(y, "[;][ ]+Enumeration[ ]District[:punct:][ ]+", "; District: ")
  return(y)
})

mod_date <- function(x)
{
  # because when a string is replaced, it changes the string, I can't find all the instances and then
  #  replace them.
  # find one at a time
  for (i in 1:length(x))
  {
    year_month <- "[0-2][0-9][0-9][0-9]-[0-1][0-9]-00"
    year_month_day <- "[0-2][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]"
    while (str_detect(x[i], year_month))
    {
      test <- stringi::stri_extract_first(x[i], regex=year_month)
      test_loc <- stringi::stri_locate_first(x[i], regex=year_month)
      test <- str_replace(test, "-00", "-01")
      test <- strftime(as.Date(test, format="%Y-%m-%d"), format="%b %Y")
      str_sub(x[i], test_loc[,1], test_loc[,2]) <- test
    }
    while (str_detect(x[i], year_month_day))
    {
      test <- stringi::stri_extract_first(x[i], regex=year_month_day)
      test_loc <- stringi::stri_locate_first(x[i], regex=year_month_day)
      test <- strftime(as.Date(test, format="%Y-%m-%d"), format="%d %b %Y")
      str_sub(x[i], test_loc[,1], test_loc[,2]) <- test
    }
  }
  x <- str_replace_all(x, "[Jj]anuary", "Jan")
  x <- str_replace_all(x, "[Ff]ebruary", "Feb")
  x <- str_replace_all(x, "[Mm]arch", "Mar")
  x <- str_replace_all(x, "[Aa]pril", "Apr")
  x <- str_replace_all(x, "[Jj]une", "Jun")
  x <- str_replace_all(x, "[Jj]uly", "Jul")
  x <- str_replace_all(x, "[Aa]ugust", "Aug")
  x <- str_replace_all(x, "[Ss]eptember", "Sep")
  x <- str_replace_all(x, "[Oo]ctober", "Oct")
  x <- str_replace_all(x, "[Nn]ovember", "Nov")
  x <- str_replace_all(x, "[Dd]ecember", "Dec")

  return(x)
}

X3 <- lapply(X3, mod_date)

# Eliminate strange "relationship with Unknown" instances
X3 <- lapply(X3, function(x){
  x <- str_replace_all(x, "[.][ ]+He also had a relationship with Unknown[.]", ".")
  x <- str_replace_all(x, "[.][ ]+She also had a relationship with Unknown[.]", ".")
  x <- str_replace_all(x, "[.][ ]+He had a relationship with Unknown[.]", ".")
  x <- str_replace_all(x, "[.][ ]+She had a relationship with Unknown[.]", ".")
  x <- str_replace_all(x, "[}][ ]*He also had a relationship with Unknown[.]", "}")
  x <- str_replace_all(x, "[}][ ]*She also had a relationship with Unknown[.]", "}")
  x <- str_replace_all(x, "[}][ ]*He had a relationship with Unknown[.]", "}")
  x <- str_replace_all(x, "[}][ ]*She had a relationship with Unknown[.]", "}")
  return(x)
})

#####################################################################################
# Find all remaining instances of "had a relationship with" for output and correction
cat("Finding instances of 'had a relationship with'\n")
harw <- lapply(X3, function(x) {
  ind <- which(str_detect(x, "had a relationship with"))
  if (length(ind) == 0) return(NA)
  return(x[ind])  
})
outputLines <- unlist(harw)
outputLines2 <- character(2*length(outputLines))
outputLines2[seq(1, 2*length(outputLines), by=2)] <- outputLines
writeLines(outputLines2, con=file.path(tex_output_path, "RelationshipError.txt"))

# \newpage%
# \grprepnoleader%
# \grminpghead{0}{0}%
# 
# \sffamily\itshape\large  Endnotes \upshape\rmfamily\normalsize %
# 
# \grminpgtail%

# cut off the end notes and make a separate file
X4 <- lapply(X3, function(x) {
  ind <- which(str_detect(x, "[:punct:]sffamily[:punct:]itshape[:punct:]large[:space:]+Endnotes[:space:]+[:punct:]upshape[:punct:]rmfamily[:punct:]normalsize"))
  if (length(ind) == 0) stop("Check that endnotes are enabled")
  ind2 <- max(which(str_detect(x[1:ind], "[:punct:]newpage[:punct:]")))
  if (is.na(ind2)) stop("Check that pagebreaks are enabled before the Endnotes")
  return(x[1:(ind2-1)])
})

X5 <- lapply(X3, function(x) {
  #x <- X3[[1]]
  ind <- which(str_detect(x, "[:punct:]sffamily[:punct:]itshape[:punct:]large[:space:]+Endnotes[:space:]+[:punct:]upshape[:punct:]rmfamily[:punct:]normalsize"))
  ind2 <- min(which(str_detect(x[(ind+1):length(x)], "[:punct:]grminpgtail[:punct:]")))  
  return(x[(ind+ind2+1):length(x)])
})

cat("Writing Tex\n")
dummy <- mapply(function(x, f){
  fnew <- str_replace(f, "[.]tex$", "_mod.tex")
  writeLines(x, con=file.path(tex_output_path, fnew))
}, X4, ancestor_files)

dummy <- mapply(function(x, f){
  fnew <- str_replace(f, "[.]tex$", "_mod_notes.tex")
  writeLines(x, con=file.path(tex_output_path, fnew))
}, X5, ancestor_files)

################################################################################

cat("Reading Obits\n")
obits <- read.csv(obituary_input_file, 1, stringsAsFactors=FALSE)

normDate <- function(s)
{
  if (is.na(s) || s == "" || s == " ") return("")
  s <- gsub("[ -]Sept[ -]", "Sep", s)
  if (nchar(s) < 5) 
  {
    stop(paste("short date detected: ", s))
    return("")
  }
  # 29-Mar-1976 or 29-March-1976
  if (!is.na(strptime(s, "%d-%b-%Y")))
  {
    temp_time <- strptime(s, "%d-%b-%Y")
    # check for two digit years like 29-Mar-76 instead of 29-Mar-1976
    if (temp_time$year + 1900 < 100) stop(paste("Two digit year used: ", s))
    ret <- strftime(temp_time, "%d %b %Y")
    if (!is.na(ret))
    {
      return(ret)
    } 
  # 29 Mar 1976 or 29 March 1976
  } else if (!is.na(strptime(s, "%d %b %Y")))
  {
    temp_time <- strptime(s, "%d %b %Y")
    # check for two digit years like 29-Mar-76 instead of 29-Mar-1976
    if (temp_time$year + 1900 < 100) stop(paste("Two digit year used: ", s))
    ret <- strftime(temp_time, "%d %b %Y")
    if (!is.na(ret))
    {
      return(ret)
    } 
  }
  stop(paste("Unrecognized Date Format: ", s))
}
dummy <- assertthat::assert_that(normDate("29-Mar-1976") == "29 Mar 1976")
dummy <- assertthat::assert_that(normDate("29 Mar 1976") == "29 Mar 1976")
dummy <- assertthat::assert_that(normDate("29-March-1976") == "29 Mar 1976")
dummy <- assertthat::assert_that(normDate("29 March 1976") == "29 Mar 1976")

cat("Processing Obits\n")
obit_lines <- character(10000)
count <- 1
berror <- FALSE
for (i in 1:nrow(obits))
{
  first_name <- paste(obits$FirstName[i], " ")
  middle_name <- ifelse(nchar(obits$Middle[i]) > 0, paste(obits$Middle[i], " "), "")
  maiden_name <- ifelse(nchar(obits$Maiden[i]) > 0, paste(obits$MaidenName[i], " "), "")
  last_name <- obits$LastName[i]
  obit_lines[count] <- paste0("\\section{", first_name,middle_name, maiden_name, last_name, "}")
  count <- count + 1
  obit_lines[count] <- "\\begin{itemize}"
  count <- count + 1
  # catch errors that might be thrown by normDate and indicate problems
  tryCatch({
    dayOfWeek <- ifelse(obits$DayOfTheWeek[i] == "",
                        strftime(strptime(normDate(obits$DateOfDeath[i]), "%d %b %Y"), "%A"),
                        obits$DayOfTheWeek[i])
    obit_lines[count] <- paste0("\\item \\textbf{Died}: ", dayOfWeek, 
                               ", ", normDate(obits$DateOfDeath[i]))
    count <- count + 1
    obit_lines[count] <- paste0("\\item \\textbf{Newspaper}: ", 
                                gsub("[&]","\\\\&", obits$NewspaperName[i]), ", ", 
                                obits$NewspaperDay[i], ", ", 
                                normDate(obits$NewspaperDate[i]),
                                ", pg ", obits$Page[i], 
                                ifelse(obits$Column[i] > 0, paste0(", Column ", obits$Column[i]), ""))
  }, error=function(e) {print(e); print(obits[i,1:12]); berror <- TRUE})
  count <- count + 1
  obit_lines[count] <- "\\end{itemize}"
  count <- count + 1
  trans <- gsub("[&]", "\\\\&", obits$Transcription[i])
  trans <- gsub("[#]", "\\\\#", trans)
  trans <- gsub("[$]", "\\\\$", trans)
  obit_lines[count] <- trans
  count <- count + 1
}

if (berror) stop("errors with Obituary parsing")

# ensure the output is utf-8 for latex
obit_lines <- enc2utf8(obit_lines)

cat("Writing Obits\n")
writeLines(obit_lines[1:count], con=file.path(tex_output_path, "obituaries.tex"))

