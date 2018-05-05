
repository_path <- file.path("C:","Users","Rob","Documents","Repositories",
                             "CarnellRettgersFamilyHistory")
output_dir <- file.path(repository_path,"search_output")
img_output_dir <- file.path(repository_path,"search_output","img")
if (!dir.exists(output_dir))
{
  dir.create(output_dir)
  dir.create(img_output_dir)
}
url <- "https://www.genealogybank.com/"

require(rvest)
require(lubridate)
require(rstudioapi)

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

queryForArticleType <- function(type, html_doc, date, html_article_vector, link_vector)
{
  temp_ho <- html_nodes(html_doc, paste0("span.field-content :contains('",type,"')")) %>% 
    html_attr("href")
  if (length(temp_ho) > 0)
  {
    temp_html <- paste0('<a href="https://www.genealogybank.com', temp_ho, '">', date, '</a>')
    links <- c(link_vector, paste0("https://www.genealogybank.com", temp_ho))
    results <- c(html_article_vector, temp_html)
    return(list(results=results, bfound=TRUE, links=links))
  } else
  {
    return(list(results=html_article_vector, bfound=FALSE, links=link_vector))
  }
}

queryAdler <- function(article_type, sDateStart, sDateEnd, query_output_file, login_session)
{
  dateToSearchMin <- as.Date(sDateStart)
  dateToSearchMax <- as.Date(sDateEnd)
  
  tuesdays <- findTuesdays(dateToSearchMin, dateToSearchMax)
  print(paste0("Querying for ", length(tuesdays$tuesdays), " days"))
  results <- character()
  links <- character()
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
      tryCatch(expr = {
        page1_session <- jump_to(login_session, query1)
        page1_html <- read_html(page1_session)
      }, error = function(e) {print("Error with query"); return(links)})
      if (article_type == "Obit")
      {
        temp <- queryForArticleType("Historical Obituary", page1_html, tuesdays$tuesdays[i], 
                                    results, links)
        results <- temp$results
        bfound <- temp$bfound
        links <- temp$links
        temp <- queryForArticleType("Mortuary Notice", page1_html, tuesdays$tuesdays[i], 
                                    results, links)
        results <- temp$results
        links <- temp$links
        bfound <- bfound | temp$bfound
      }
      else if (article_type == "Marriage")
      {
        temp <- queryForArticleType("Matrimony Notice", page1_html, tuesdays$tuesdays[i], 
                                    results, links)
        results <- temp$results
        links <- temp$links
        bfound <- temp$bfound
        temp <- queryForArticleType("Marriage/Engagement Notice", page1_html, tuesdays$tuesdays[i], 
                                    results, links)
        results <- temp$results
        links <- temp$links
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
  return(links)
}

###############################################################################

pgsession <- html_session(url)
pgform <- html_form(pgsession)[[1]] 

passwd_str <- rstudioapi::askForPassword("Enter GenealogyBank pw")

filled_form <- set_values(pgform,
                          `username` = "bertcarnell@gmail.com", 
                          `password` = passwd_str)

pg_session_logged_in <- submit_form(pgsession, filled_form)

# reading Adler covers 11/29/1796 - 12/26/1876
output_file <- file.path(output_dir, "search_result.html")
links <- queryAdler("Obit", "1796-11-29", "1798-01-01", output_file, pg_session_logged_in)

output_file_marriage <- file.path(output_dir, "search_result_marriage.html")
marriage_links <- queryAdler("Marriage", "1796-11-29", "1798-01-01", output_file_marriage, 
                             pg_session_logged_in)

save(links, marriage_links, file = file.path(output_dir, "links1798.Rdata"))

rm(filled_form)
rm(pg_session_logged_in)
rm(pgform)
rm(pgsession)

###############################################################################

# Plan:
# 1. get all links using rvest
# 2. Iterate through links, downloading each image with RSelenium

###############################################################################

# set up Selenium server
require(RSelenium)
# if Windows
rD <- rsDriver()
remDr <- rD[["client"]]
if (FALSE) {
  # if Linux
  startServer()
  remDr <- removeDriver$new()
  remDr$open()
}

#######
# login
remDr$navigate(url)
elem <- remDr$findElement(using="id", value="dropdowntoggle-login")
elem$clickElement()
elem <- remDr$findElement(using="id", value="username")
elem$sendKeysToElement(list('bertcarnell@gmail.com'))

passwd_str <- rstudioapi::askForPassword("Enter GenealogyBank pw")

elem <- remDr$findElement(using="id", value="password")
elem$sendKeysToElement(list(passwd_str))
elem <- remDr$findElement(using="id", value="btnLogin")
elem$clickElement()

#########################
# navigate to image links

getArticleImage <- function(remDr, html_link, type="")
{
  #html_link <- links[1]
  #type <- "Obituary"
  
  remDr$navigate(html_link)
  #elem <- remDr$findElement(using="link text", value="Historical Obituary")
  #elem$clickElement()
  
  # click on the save button
  elem <- remDr$findElement(using="id", value="clip-download-click-target")
  elem$clickElement()
  #elem <- remDr$findElement(using="xpath", value="//input[@id = 'edit-download-type-pdf']")
  #elem$getElementAttribute("checked") # true
  
  # click to save an image instead of a pdf
  elem <- remDr$findElement(using="xpath", value="//label[@for = 'edit-download-type-img']")
  elem$clickElement()
  
  # click to download image
  elem <- remDr$findElement(using="xpath", value="//button[@id = 'download_page_form_submit_button']")
  elem$clickElement()
  
  download_filename <- remDr$findElement(using = "xpath", value="//input[@name = 'file_name']")
  download_filename <- download_filename$getElementAttribute("value")[[1]]
  
  file.copy(from = file.path("C:","Users", "Rob", "Downloads", paste0(download_filename, ".gif")),
            to = file.path(img_output_dir, paste0(download_filename, "_", type, ".gif")), 
            overwrite = TRUE)
  file.remove(file.path("C:","Users", "Rob", "Downloads", paste0(download_filename, ".gif")))
  return(remDr)
}

for (i in seq_along(links))
{
  remDr <- getArticleImage(remDr, links[i], "Obituary")
}

remDr$close()
rD[["server"]]$stop()

