# script to download a GEDCOM from ancestry.com
#   Prereqs
#   1 . must have a docker running selenium available
#       sudo docker run -d -p 4445:4444 selenium/standalone-firefox:2.53.1
#   2.  must have RSelenium and httr installed
#       install.packages("RSelenium")

args <- commandArgs(trailingOnly=TRUE)

if (FALSE)
{
  args <- c("localhost", "4445", "*********")
}

# expect arg1 = removeServerAddr for the other docker
#        arg2 = port for the other docker

if (length(args) < 3 || length(args) > 3) 
{
  stop("remoteServerAddr and port options are expected.  Rscript --vanilla Ancestry_gedcom_download.R localhost 4445", call.=FALSE)
} else {
  my_remoteServerAddr <- args[1]
  my_port <- args[2]
  my_passwd <- arg[3]
}

if (!require(RSelenium) || !require(httr))
  stop("RSelenium and httr are required to be installed")

remDr <- remoteDriver(
  remoteServerAddr = my_remoteServerAddr,
  port = as.integer(my_port),
  browserName = "firefox"
)

remDr$open()

Sys.sleep(5)

if (length(remDr$getStatus()) != 3)
  stop(paste("server status is", remDr$getStatus()))

ancestry_url <- "https://www.ancestry.com"
ancestry_list <- httr::parse_url(ancestry_url)
ancestry_list$path <- "account/signin"
ancestry_list$query <- list(signUpReturnUrl="https://www.ancestry.com%2Fcs%2Foffers%2Fsubscribe%3Fsub%3D1")

cat("Navigating to Ancestry.com\n")
remDr$navigate(httr::build_url(ancestry_list))

Sys.sleep(5)

# <input tabindex="1" aria-required="true" class="success required" id="username" maxlength="64" name="username" placeholder="Email Address or Username" type="text" value="" autocorrect="off" autocapitalize="none" required="true">
# <input tabindex="2" aria-required="true" class="success required" id="password" name="password" placeholder="Password" type="password" value="" required="true">
# <button tabindex="3" id="signInBtn" class="ancBtn lrg" data-track-click="sign in : sign in" type="submit">Sign in</button>

remDr$switchToFrame(Id = "signInFrame")

username_element <- remDr$findElement(using = "id", value = "username")
password_element <- remDr$findElement(using = "id", value = "password")
button_element <- remDr$findElement(using = "id", value = "signInBtn")

cat("Entering Username and Password\n")

username_element$sendKeysToElement(list("bertcarnell@gmail.com"))
Sys.sleep(1)
password_element$sendKeysToElement(list(my_passwd))
Sys.sleep(1)
button_element$clickElement()
Sys.sleep(5)

ancestry_list <- httr::parse_url(ancestry_url)
ancestry_list$path <- "family-tree/tree/71905785/settings/info"

cat("Navigating to GEDCOM download screen\n")

remDr$navigate(httr::build_url(ancestry_list))
Sys.sleep(5)

# <button class="ancBtn sml" id="exportTreeLink" onclick="exportGedcom();" type="button">Export tree</button>
  
export_element <- remDr$findElement(using = "id", value = "exportTreeLink")
export_element$clickElement()

Sys.sleep(15)

# <a id="ctl05_ctl00_gedcomexport_downloadButtonLink" class="ancBtn full320 icon iconDownload" href="https://mediasvc.ancestry.com/v2/stream/namespaces/61515/media/64364eb5-4167-43e1-9f42-734d8d01acb6.ged?Client=Ancestry.Trees&amp;filename=Carnell+-+Rettgers.ged">Download your GEDCOM file</a>

download_element <- remDr$findElement(using = "id", value = "ctl05_ctl00_gedcomexport_downloadButtonLink")
file_link <- download_element$getElementAttribute("href")[[1]]

cat("Downloading...\n")
download.file(url = file_link, destfile = "test.ged")

if (!file.exists("test.ged"))
{
  remDr$close()
  stop("Download did not complete properly")
}

Sys.sleep(5)

remDr$close()
