# Modify Gedcom for input into Gramps
#   Call with Rscript --vanilla Modify_GEDCOM.R GEDCOM_filename

# take filename from the command line
args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0 | length(args) > 1) stop("GEDCOM filename and path must be supplied")

if (FALSE)
{
  # debugging
  args <- "~/share/Carnell_2017-12-20.ged"
}

################################################
# _FOOT sections are not understood by Gramps
#  They are followed by any number of CONC lines

X <- readLines(args)

foot_instances <- grep("^3[ ][_]FOOT", X)
if (length(foot_instances) > 0)
{
  to_delete <- NULL
  
  for (i in foot_instances)
  {
    to_delete <- c(to_delete, i)
    ind <- i + 1
    while (grepl("^4[ ]CONC", X[ind]))
    {
      to_delete <- c(to_delete, ind)
      ind <- ind + 1
    }
  }
  
  X <- X[-to_delete]
}

###############################################
# This link is not parsed by Gramps for no understood reason

#107017
ind <- grep("3[ ][_]LINK[ ]https[:][/][/]familysearch[.]org[/]pal[:][/]MM9[.]3[.]1[/]TH[-]1951[-]21118[-]5954[-]43[?]cc[=]1589502", X)
if (length(ind) > 0)
{
  X <- X[-ind]
}

################################################
# write results
writeLines(X, con=args[1])


