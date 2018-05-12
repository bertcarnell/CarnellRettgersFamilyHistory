#!/usr/bin/env Rscript
# run this as a script with command line arguments
stopifnot(require(assertthat))
tmp <- assertthat::assert_that(require(optparse))
tmp <- assertthat::assert_that(require(rvest))
tmp <- assertthat::assert_that(require(lubridate))
tmp <- assertthat::assert_that(require(RSelenium))

currSys <- tolower(Sys.info()["sysname"])

if (currSys != "linux")
{
  require(rstudioapi)
}

if (currSys == "linux")
{
  repository_path <- file.path("~","repositories","CarnellRettgersFamilyHistory")
} else
{
  repository_path <- file.path("C:","Users","Rob","Documents","Repositories",
                               "CarnellRettgersFamilyHistory")
}
tmp <- assertthat::assert_that(dir.exists(repository_path))

option_list <- list(
  make_option(c("-d", "--output_dir"), type="character", 
              default=file.path(repository_path,"search_output"), 
              help="html output directory and Rdata output directory [default= %default]", metavar="character"),
  make_option(c("-i", "--image_dir"), type="character", 
              default=file.path(repository_path,"search_output","img"), 
              help="output image directory [default = %default]", metavar="character"),
  make_option(c("-b", "--start_date"), type="character",
              default="1796-11-29",
              help="start date [default = %default]", metavar="character"),
  make_option(c("-e", "--end_date"), type="character",
              default="1876-12-26",
              help="end date [default = %default]", metavar="character"),
  make_option(c("-p", "--passwd"), type="character",
              default=NULL,
              help="password", metavar="character"),
  make_option(c("-t", "--article_type"), type="character",
              default="obit",
              help="Type of article (obit or marriage)", metavar="character"),
  make_option(c("-g", "--get_image"), type="logical",
              default=FALSE,
              help="Get images?", metavar="logical"),
  make_option(c("-q","--query"), type="logical",
              default=TRUE,
              help="run link query", metavar="logical")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

tmp <- assertthat::assert_that(opt$article_type == "obit" || opt$article_type == "marriage")
tmp <- assertthat::assert_that(is.Date(as.Date(opt$start_date)))
tmp <- assertthat::assert_that(is.Date(as.Date(opt$end_date)))

if (FALSE)
{
  # Testing
  opt <- list(output_dir = file.path(repository_path,"search_output"),
              image_dir = file.path(repository_path,"search_output","img"),
              start_date = "1876-10-01",
              end_date = "1876-12-26",
              passwd = "test",
              article_type = "obit",
              get_image = FALSE)
}

output_dir <- opt$output_dir
output_file <- file.path(output_dir, paste0("search_result", opt$end_date, "_",
                                            opt$article_type, ".html"))
output_save_file <- file.path(output_dir, paste0("links", opt$end_date, "_", 
                                                 opt$article_type, ".Rdata"))
img_output_dir <- opt$image_dir
if (!dir.exists(output_dir))
{
  dir.create(output_dir)
}
if (!dir.exists(img_output_dir))
{
  dir.create(img_output_dir)
}
tmp <- assertthat::assert_that(dir.exists(output_dir))
tmp <- assertthat::assert_that(dir.exists(img_output_dir))

url <- "https://www.genealogybank.com/"

if (currSys != "linux" && is.null(opt$passwd))
{
  passwd_str <- rstudioapi::askForPassword("Enter GenealogyBank pw")
} else 
{
  passwd_str <- opt$passwd
}

###############################################################################

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

getArticleImage <- function(remDr, html_link, type="", sleep_time=2)
{
  #html_link <- links[1]
  #type <- "Obituary"
  #sleep_time <- 2
  
  remDr$navigate(html_link)
  #elem <- remDr$findElement(using="link text", value="Historical Obituary")
  #elem$clickElement()
  
  # click on the save button
  elem <- remDr$findElement(using="id", value="clip-download-click-target")
  elem$clickElement()
  #elem <- remDr$findElement(using="xpath", value="//input[@id = 'edit-download-type-pdf']")
  #elem$getElementAttribute("checked") # true
  
  Sys.sleep(sleep_time)
  # click to save an image instead of a pdf
  elem <- remDr$findElement(using="xpath", value="//label[@for = 'edit-download-type-img']")
  elem$clickElement()
  
  download_filename <- remDr$findElement(using = "xpath", value="//input[@name = 'file_name']")
  download_filename <- download_filename$getElementAttribute("value")[[1]]
  
  # click to download image
  elem <- remDr$findElement(using="xpath", value="//button[@id = 'download_page_form_submit_button']")
  elem$clickElement()
  
  #file.copy(from = file.path("C:","Users", "Rob", "Downloads", paste0(download_filename, ".gif")),
  #          to = file.path(img_output_dir, paste0(download_filename, "_", type, ".gif")), 
  #          overwrite = TRUE)
  download_filename_full <- file.path("/home","pi", "Downloads", paste0(download_filename, ".gif"))
  Sys.sleep(2*sleep_time)
  if (!file.exists(download_filename_full))
    stop(paste0("File did not download: ", download_filename_full))
  res <- file.copy(from = download_filename_full,
                   to = file.path(img_output_dir, paste0(download_filename, "_", type, ".gif")), 
                   overwrite = TRUE)
  assertthat::assert_that(res)
  #file.remove(file.path("C:","Users", "Rob", "Downloads", paste0(download_filename, ".gif")))
  res <- file.remove(download_filename_full)
  assertthat::assert_that(res)
  return(remDr)
}

###############################################################################
if (opt$query)
{
  pgsession <- html_session(url)
  pgform <- html_form(pgsession)[[1]] 
  
  filled_form <- set_values(pgform,
                            `username` = "bertcarnell@gmail.com", 
                            `password` = passwd_str)
  
  pg_session_logged_in <- submit_form(pgsession, filled_form)
  
  #links <- queryAdler("Obit", "1796-11-29", "1798-01-01", output_file, pg_session_logged_in)
  #links <- queryAdler("Obit", "1798-01-01", "1810-01-01", output_file, pg_session_logged_in)
  
  #marriage_links <- queryAdler("Marriage", "1796-11-29", "1798-01-01", output_file_marriage, 
  #                             pg_session_logged_in)
  #marriage_links <- queryAdler("Marriage", "1798-01-01", "1810-01-01", output_file_marriage, 
  #                             pg_session_logged_in)
  
  #save(links, marriage_links, file = file.path(output_dir, "links1798.Rdata"))
  #save(links, marriage_links, file = file.path(output_dir, "links1810.Rdata"))
  #load(file = file.path(output_dir, "links1798.Rdata"))
  #load(file = file.path(output_dir, "links1810.Rdata"))
  
  if (opt$article_type == "obit")
  {
    links <- queryAdler("Obit", opt$start_date, opt$end_date, output_file, pg_session_logged_in)
  } else if (opt$article_type == "marriage")
  {
    links <- queryAdler("Marriage", opt$start_date, opt$end_date, output_file, pg_session_logged_in)
  } else
  {
    stop("Article Type Not Recognized")
  }
  save(links, file = output_save_file)
}

if (opt$get_image)
{
  load(file = output_save_file)
  remDr <- RSelenium::remoteDriver(remoteServerAddr = "localhost",
                                   port = 4444L,
                                   browserName = "chrome")
  driver_stats <- remDr$open()
  assertthat::assert_that(tolower(driver_stats$browserName) == "chrome")
  
  #######
  # login
  remDr$navigate(url)
  elem <- remDr$findElement(using="id", value="dropdowntoggle-login")
  elem$clickElement()
  elem <- remDr$findElement(using="id", value="username")
  elem$sendKeysToElement(list('bertcarnell@gmail.com'))
  
  elem <- remDr$findElement(using="id", value="password")
  elem$sendKeysToElement(list(passwd_str))
  elem <- remDr$findElement(using="id", value="btnLogin")
  elem$clickElement()
  
  for (i in seq_along(links))
  {
    print(paste0(i, ": ", links[i]))
    print("Downloading...")
    if (opt$article_type == "obit")
    {
      remDr <- getArticleImage(remDr, links[i], "Obituary")
    } else if (opt$article_type == "marriage")
    {
      remDr <- getArticleImage(remDr, links[i], "Marriage")
    } else
    {
      stop("Article Type Not Recognized")
    }
  }
  
  remDr$close()
}

