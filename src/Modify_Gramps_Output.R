# Copyright (c) 2021 Robert Carnell

args <- commandArgs(trailingOnly=TRUE)
private <- TRUE

if (length(args) == 0 | length(args) > 1) stop("repository path must be supplied")

if (FALSE)
{
  # debugging
  args <- as.character(file.path("C:","repositories","CarnellRettgersFamilyHistory"))
  private <- FALSE
}

stopifnot(require(assertthat))
stopifnot(require(stringr))
stopifnot(require(xml2))

repository_path_ext <- args[1]

assertthat::assert_that(dir.exists(repository_path_ext),
                        msg = paste("Repository Path does not exist", args[1]))

tex_input_path <- file.path(repository_path_ext, "tex_input")
if (private)
  tex_input_private_path <- file.path(repository_path_ext, "tex_input_private")
tex_output_path <- file.path(repository_path_ext, "tex_output")

obituary_input_path <- file.path(repository_path_ext, "docs")
obituary_input_file <- file.path(obituary_input_path, "NewspaperArticles.xml")
obituary_schema_file <- file.path(obituary_input_path, "NewspaperArticles.xsd")

if (!dir.exists(tex_output_path)) 
  dir.create(tex_output_path)

ancestor_files <- c(paste0("det_ancestor_report_", 
                           c("Bechtel","Fett","Hartenstine","Rettgers",
                             "Connell","Langston","Smith","Josey"), ".tex"))
ancestor_files_path <- file.path(rep(tex_input_path, 8), ancestor_files)

if (private)
{
  ancestor_files <- c(ancestor_files, 
                    paste0("det_descendant_report_", 
                         c("Fett","Rettgers",
                           "Connell","Smith"), ".tex"))
  ancestor_files_path <- file.path(c(rep(tex_input_path, 8), 
                                     rep(tex_input_private_path, 4)), ancestor_files)
}

dummy <- sapply(ancestor_files_path, function(x) {
  assertthat::assert_that(file.exists(x), msg = paste("File Does Not Exist: ", x))
})

dummy <- assertthat::assert_that(file.exists(obituary_input_file), msg = paste("File Does Not Exist: ", obituary_input_file))
dummy <- assertthat::assert_that(file.exists(obituary_schema_file), msg = paste("File Does Not Exist: ", obituary_schema_file))

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
obits <- read_xml(obituary_input_file)
schema <- read_xml(obituary_schema_file)

# check that the xml is valid
assertthat::assert_that(xml_validate(obits, schema), 
                        msg = paste("Invalid XML schema for ", obituary_input_file))

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
obit_lines <- character(100000)
count <- 1
berror <- FALSE
temp <- xml_children(xml_root(obits))
xget <- function(node, element_name)
{
  xml_text(xml_child(node, element_name))
}
for (i in 1:length(temp))
{
  first_name <- paste(xget(temp[[i]], "FirstName"), " ")
  middle_name_temp <- xget(temp[[i]], "Middle")
  middle_name <- ifelse(!is.na(middle_name_temp) & nchar(middle_name_temp) > 0, paste(middle_name_temp, " "), "")
  maiden_name_temp <- xget(temp[[i]], "MaidenName")
  maiden_name <- ifelse(!is.na(maiden_name_temp) & nchar(maiden_name_temp) > 0, paste(maiden_name_temp, " "), "")
  last_name <- xget(temp[[i]], "LastName")
  obit_lines[count] <- paste0("\\section{", first_name, middle_name, maiden_name, last_name, "}")
  count <- count + 1
  obit_lines[count] <- "\\begin{itemize}"
  count <- count + 1
  # catch errors that might be thrown by normDate and indicate problems
  tryCatch({
    type_temp <- xget(temp[[i]], "Type")
    if (type_temp == "Obituary")
    {
      day_of_week_temp <- xget(temp[[i]], "DayOfTheWeek")
      date_of_death_temp <- xget(temp[[i]], "DateOfDeath")
      dayOfWeek <- ifelse(day_of_week_temp == "",
                          strftime(strptime(normDate(date_of_death_temp), "%d %b %Y"), "%A"),
                          day_of_week_temp)
      obit_lines[count] <- paste0("\\item \\textbf{Died}: ", dayOfWeek, 
                                  ", ", normDate(date_of_death_temp))
      count <- count + 1
    } else if (type_temp == "Marriage")
    {
      obit_lines[count] <- paste0("\\item \\textbf{Marriage}")
      count <- count + 1
    } else if (type_temp == "Other")
    {
      obit_lines[count] <- paste0("\\item \\textbf{Other Article}")
      count <- count + 1
    } else
    {
      stop(paste("unrecognized type", temp[[i]]))      
    }
    newspaper_name_temp <- xget(temp[[i]], "NewspaperName")
    newspaper_day_temp <- xget(temp[[i]], "NewspaperDay")
    newspaper_date_temp <- xget(temp[[i]], "NewspaperDate")
    newspaper_page_temp <- xget(temp[[i]], "Page")
    newspaper_col_temp <- xget(temp[[i]], "Column")
    obit_lines[count] <- paste0(
      ifelse(!is.na(newspaper_name_temp) & newspaper_name_temp != "NA", 
             paste0("\\item \\textbf{Newspaper}: ", newspaper_name_temp, ", "), 
             paste0("\\item \\textbf{Published}: ")),
      ifelse(!is.na(newspaper_day_temp), 
             paste0(newspaper_day_temp, ", "), ""),
      ifelse(!is.na(normDate(newspaper_date_temp)), normDate(newspaper_date_temp), ""),
      ifelse(!is.na(newspaper_page_temp),
             paste0(", pg ", newspaper_page_temp),
             ""),
      ifelse(!is.na(newspaper_col_temp) & newspaper_col_temp > 0,
             paste0(", Column ", newspaper_col_temp),
             ""))      
  }, error=function(e) {print(e); print(temp[[i]]); berror <- TRUE})
  count <- count + 1
  obit_lines[count] <- "\\end{itemize}"
  count <- count + 1
  trans <- xget(temp[[i]], "Transcription")
  if (!is.na(trans)) 
  {
    obit_lines[count] <- trans
    count <- count + 1
  }
  transl <- xget(temp[[i]], "Translation")
  if (!is.na(transl))
  {
    obit_lines[count] <- transl
    count <- count + 1
  }
}

obit_lines <- gsub("[&]amp[;]", "&", obit_lines)
obit_lines <- gsub("[&]quot[;]", '"', obit_lines)
obit_lines <- gsub("&", "\\&", obit_lines, fixed = TRUE) # fixed = TRUE is required for the replacement
obit_lines <- gsub("[#]", "\\\\#", obit_lines)
obit_lines <- gsub("[$]", "\\\\$", obit_lines)
obit_lines <- gsub("[<]div[>]", "", obit_lines)
obit_lines <- gsub("[<][/]div[>]", "\n", obit_lines)
obit_lines <- gsub("[<]p[>]", "", obit_lines)
obit_lines <- gsub("[<][/]p[>]", "\n", obit_lines)
obit_lines <- gsub("[<]h[1-5][>]", "", obit_lines)
obit_lines <- gsub("[<][/]h[1-5][>]", "\n", obit_lines)

obit_lines <- str_replace_all(obit_lines, "\u2014", "-")
obit_lines <- str_replace_all(obit_lines, "\u2019", "'")


#iconv(obit_lines[160], from = "UTF-8", to = "ASCII", sub = "Unicode")

if (berror) 
  stop("errors with Obituary parsing")

# ensure the output is utf-8 for latex
obit_lines <- enc2utf8(obit_lines)

cat("Writing Obits\n")
writeLines(obit_lines[1:count], con=file.path(tex_output_path, "obituaries.tex"), useBytes = TRUE)
