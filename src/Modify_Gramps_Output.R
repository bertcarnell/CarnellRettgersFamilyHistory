require(assertthat)
require(stringr)

repository_path <- file.path("C:","Users","Rob","Documents","Repositories")
tex_input_path <- file.path(repository_path,"CarnellRettgersFamilyHistory","tex_input")

ancestor_files <- paste0("det_ancestor_report_", c("Bechtel","Fett","Hartenstine","Rettgers"), ".tex")

dummy <- sapply(file.path(tex_input_path, ancestor_files), function(x) {
  assertthat::assert_that(file.exists(x))
})

# read the latex files as text
X1 <- lapply(file.path(tex_input_path, ancestor_files), function(x) {
  readLines(x)
})

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
  y <- str_replace(y, "[:punct:]*[,][ ]Name[:punct:][ ]Ancestry[.]com Operations[,]*[ ]Inc[.]*[;][ ]Location[:punct:][ ]Provo[,][ ]UT[,][ ]USA[;][ ]Date[:punct:][0-9][0-9][0-9][0-9][;]","")
  # States, USA
  y <- str_replace_all(y, "Pennsylvania[,][ ]USA", "PA")
  y <- str_replace_all(y, "Georgia[,][ ]USA", "GA")
  y <- str_replace_all(y, "South[ ]Carolina[,][ ]USA", "SC")
  y <- str_replace_all(y, "North[ ]Carolina[,][ ]USA", "NC")
  y <- str_replace_all(y, "Ohio[,][ ]USA", "OH")
  y <- str_replace_all(y, "New[ ]York[,][ ]USA", "NY")
  y <- str_replace_all(y, "Delaware[,][ ]USA", "DE")
  # Unknown (Husband name)
  y <- str_replace_all(y, "Unknown[ ][(].+[)]", "_____")
  return(y)
})

dummy <- mapply(function(x, f){
  fnew <- str_replace(f, "[.]tex$", "_mod.tex")
  writeLines(x, con=file.path(tex_input_path, fnew))
}, X3, ancestor_files)
