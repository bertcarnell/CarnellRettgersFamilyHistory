# Copyright (c) 2018 Robert Carnell

# Modify Gedcom for input into Gramps
#   Call with Rscript --vanilla Modify_GEDCOM.R GEDCOM_filename

# take filename from the command line
args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0 | length(args) > 1) stop("GEDCOM filename and path must be supplied")

if (FALSE)
{
  # debugging
  args <- "Carnell - Rettgers.ged"
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

###############################################
# Remove _APID tags

ind <- grep("^[1-9][ ][_]APID", X)
if (length(ind) > 0)
{
  X <- X[-ind]
}

###############################################
# Remove empty notes and subordinate text

ind <- grep("^[1][ ]NOTE[ ]$", X)
if (length(ind) > 0)
{
  to_delete <- ind
  for (i in seq_along(ind))
  {
    ind2 <- grep("^[0-1]", X[(ind[i]+1):(ind[i]+100)])
    if (length(ind2) == 0)
      next
    if (ind2[1] == 1)
      next
    to_delete <- c(to_delete, (ind[i]+1):(ind[i] + ind2[1] - 1))
  }
  X <- X[-to_delete]  
}

ind <- grep("^[2][ ]NOTE[ ]$", X)
if (length(ind) > 0)
{
  to_delete <- ind
  for (i in seq_along(ind))
  {
    ind2 <- grep("^[0-2]", X[(ind[i]+1):(ind[i]+100)])
    if (length(ind2) == 0)
      next
    if (ind2[1] == 1)
      next
    to_delete <- c(to_delete, (ind[i]+1):(ind[i] + ind2[1] - 1))
  }
  X <- X[-to_delete]  
}

ind <- grep("^[3][ ]NOTE[ ]$", X)
if (length(ind) > 0)
{
  to_delete <- ind
  for (i in seq_along(ind))
  {
    ind2 <- grep("^[0-3]", X[(ind[i]+1):(ind[i]+100)])
    if (length(ind2) == 0)
      next
    if (ind2[1] == 1)
      next
    to_delete <- c(to_delete, (ind[i]+1):(ind[i] + ind2[1] - 1))
  }
  X <- X[-to_delete]  
}

###############################################
# Remove DATA followed by TEXT

ind <- grep("^[1-9][ ]DATA$", X)
if (length(ind) > 0)
{
  to_delete <- ind
  for (i in seq_along(ind))
  {
    if (grepl("^[1-9][ ]TEXT", X[ind[i] + 1]))
      to_delete <- c(to_delete, ind[i] + 1)
  }
  X <- X[-to_delete]  
}

###############################################
# Remove Bare FAMC and all CALN

ind <- grep("^[1-9][ ]FAMC$", X)
if (length(ind) > 0)
{
  X <- X[-ind]  
}

ind <- grep("^[1-9][ ]CALN", X)
if (length(ind) > 0)
{
  X <- X[-ind]  
}

###########################################33
# Remove OBJE and following lines 

ind <- grep("^[2][ ]OBJE$", X)
if (length(ind) > 0)
{
  to_delete <- ind
  for (i in seq_along(ind))
  {
    ind2 <- grep("^[0-2]", X[(ind[i]+1):(ind[i]+100)])
    if (length(ind2) == 0)
      next
    if (ind2[1] == 1)
      next
    to_delete <- c(to_delete, (ind[i]+1):(ind[i] + ind2[1] - 1))
  }
  X <- X[-to_delete]  
}

ind <- grep("^[3][ ]OBJE$", X)
if (length(ind) > 0)
{
  to_delete <- ind
  for (i in seq_along(ind))
  {
    ind2 <- grep("^[0-3]", X[(ind[i]+1):(ind[i]+100)])
    if (length(ind2) == 0)
      next
    if (ind2[1] == 1)
      next
    to_delete <- c(to_delete, (ind[i]+1):(ind[i] + ind2[1] - 1))
  }
  X <- X[-to_delete]  
}

###########################################
# Remove Any Hierarchy 1 tags after sex 
#    In GEDCOM 5.5 there are no sub-events after SEX

ind <- grep("^[1][ ]SEX", X)
to_delete <- NULL
if (length(ind) > 0)
{
  for (i in seq_along(ind))
  {
    ind2 <- grep("^[1]", X[(ind[i]+1):(ind[i]+100)])
    if (ind2[1] == 1)
      next
    to_delete <- c(to_delete, (ind[i]+1):(ind[i] + ind2[1] -1))
  }
  X <- X[-to_delete]  
}

################################################
# write results
writeLines(X, con=args[1])
