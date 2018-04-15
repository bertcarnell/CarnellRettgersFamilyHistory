
output_dir <- file.path("C:","Users","Rob","Documents","Repositories",
                        "CarnellRettgersFamilyHistory","search_output")
if (!dir.exists(output_dir))
{
  dir.create(output_dir)
}

library(rvest)
library(lubridate)

findTuesdays <- function(dateToSearchMin, dateToSearchMax, html_format = TRUE)
{
  # Tuesday is 3, Sunday is 1, Saturday is 7
  temp <- wday(dateToSearchMin)
  # if temp is 3 4 5 6 7 1 2
  # then add   0 6 5 4 3 2 1
  firstTuesday <- as.Date(ifelse(temp <= 3, dateToSearchMin + 3 - temp, 
                                 dateToSearchMin + 10 - temp), origin="1970-01-01")
  tuesdays <- seq(firstTuesday, dateToSearchMax, by=7)
  if (html_format)
  {
    html_tuesdays <- gsub("-", "%2F", strftime(tuesdays, "%m-%d-%Y"))
    return(list(tuesdays=tuesdays, html_tuesdays=html_tuesdays))
  } else {
    return(list(tuesdays=tuesdays, html_tuesdays=NA))
  }
}

queryForArticleType <- function(type, html_doc, date, html_article_vector)
{
  temp_ho <- html_nodes(html_doc, paste0("span.field-content :contains('",type,"')")) %>% 
    html_attr("href")
  if (length(temp_ho) > 0)
  {
    temp_html <- paste0('<a href="https://www.genealogybank.com', temp_ho, '">', date, '</a>')
    results <- c(html_article_vector, temp_html)
    return(list(results=results, bfound=TRUE))
  } else
  {
    return(list(results=html_article_vector, bfound=FALSE))
  }
}

queryAdler <- function(article_type, sDateStart, sDateEnd, query_output_file, login_session)
{
  dateToSearchMin <- as.Date(sDateStart)
  dateToSearchMax <- as.Date(sDateEnd)
  
  tuesdays <- findTuesdays(dateToSearchMin, dateToSearchMax)
  print(paste0("Querying for ", length(tuesdays$tuesdays), " days"))
  results <- character()
  for (i in seq_along(tuesdays$html_tuesdays))
  {
    print(tuesdays$tuesdays[i])
    query1 <- paste0("https://www.genealogybank.com/explore/newspapers/all/usa/pennsylvania/reading/reading-adler",
                     "?fname=",
                     "&lname=",
                     "&fullname=",
                     "&rgfromDate=", tuesdays$html_tuesdays[i],
                     "&rgtoDate=", tuesdays$html_tuesdays[i],
                     "&formDate=",
                     "&formDateFlex=exact",
                     "&dateType=range",
                     "&kwinc=",
                     "&kwexc=")
    test <- TRUE  
    while (test)
    {
      page1_session <- jump_to(login_session, query1)
      page1_html <- read_html(page1_session)
      if (article_type == "Obit")
      {
        temp <- queryForArticleType("Historical Obituary", page1_html, tuesdays$tuesdays[i], results)
        results <- temp$results
        bfound <- temp$bfound
        temp <- queryForArticleType("Mortuary Notice", page1_html, tuesdays$tuesdays[i], results)
        results <- temp$results
        bfound <- bfound | temp$bfound
      }
      else if (article_type == "Marriage")
      {
        temp <- queryForArticleType("Matrimony Notice", page1_html, tuesdays$tuesdays[i], results)
        results <- temp$results
        bfound <- temp$bfound
        temp <- queryForArticleType("Marriage/Engagement Notice", page1_html, tuesdays$tuesdays[i], results)
        results <- temp$results
        bfound <- bfound | temp$bfound
      } else
      {
        stop("Article type not recognized")
      }
      
      # go to the next page if nothing was found
      if (!bfound)
      {
        temp_next <- html_nodes(page1_html, "li.page-item.page-next") %>% html_children() %>% 
          html_attr("href")
        if (length(temp_next) == 1)
        {
          test <- TRUE
          query1 <- paste0("https://www.genealogybank.com", temp_next)
          print("Next Page")
        } else if (length(temp_next) == 0)
        {
          test <- FALSE
        } else
        {
          stop("error unknown")
        }
      } else
      {
        test <- FALSE
      }
    }
  }
  
  if (length(results) > 0)
  {
    results_html <- read_html(paste("<p>", paste(results, collapse="</p><p>"), "</p>"))
    write_html(results_html, query_output_file, options = "format")
  } else
  {
    stop("No Results Found")
  }
  
}

###############################################################################

output_file <- file.path(output_dir, "search_result.html")

url <- "https://www.genealogybank.com/"
pgsession <- html_session(url)
pgform <- html_form(pgsession)[[1]] 

filled_form <- set_values(pgform,
                          `username` = "bertcarnell@gmail.com", 
                          `password` = "Navy1998")

submit_form(pgsession,filled_form)

# reading Adler covers 11/29/1796 – 12/26/1876

queryAdler("Obit", "1823-10-15", "1823-12-31", output_file, pgsession)

queryAdler("Marriage", "1840-01-01", "1840-01-31", output_file, pgsession)

  