# Installing RCurl 

install.packages("RCurl")

# Loading the packages

library(RCurl); library(rvest); library(tidyverse)

# Point 1 -----------------------------------------------------------------------------------------------------------------------

# Inspecting the robots.txt file

browseURL("http://beppegrillo.it/robots.txt") 

# Explanation

# The first line we read is: "User-agent: *". This simply means that the following instructions apply to all robots.

# The following two lines are "Disallow: /wp-admin/" and "Allow: /wp-admin/admin-ajax.php". 
# They are telling us that the site is blocking the wp-admin folder with the exception of the admin-ajax.php file. 
# In other words, we are not allowed to download any page from that folder with the exception of the admin-ajax.php file. 



# Point 2 -----------------------------------------------------------------------------------------------------------------------

# Storing our URL link into an object called url 

url <- "http://www.beppegrillo.it/un-mare-di-plastica-ci-sommergera/"

# Download the page using RCcurl::getURL() while informing the webmaster about my browser details and my e-mail address.

page <- getURL(url, 
               useragent = str_c(R.version$platform,
                                 R.version$version.string,
                                 sep = ", "),
               httpheader = c(From = "jacopomalatesta95@gmail.com")) 

# Saving the page in my directory:
writeLines(page, 
           con = here::here("downloaded_pages", "beppe_grillo_plastica.html")) 


# Point 3 --------------------------------------------------------------------------------------------------------------------

# Downloading all the links in the page 

links <- XML::getHTMLLinks(url)
links

# Creating a tibble with all the links

dat <- tibble(
  links = links
)
dat

# Selecting all the links re-directing to other posts from the beppegrillo.it blog

internal_links <- str_subset(links, "^http://www\\.beppegrillo\\.it")

# Creating a tibble with all the links re-directing to other posts from the beppegrillo.it blog

dat2 <- tibble(
  links = internal_links
)

dat2


# Same thing, this time with rvest

links_rvest <- read_html(here::here("beppe_grillo_plastica.html")) %>% 
  html_nodes(css = "a") %>% 
  html_attr("href")

links_rvest

# Creating a dataframe containing the links

dat3 <- tibble(
  links = links_rvest
)


dat3

# Selecting all the links re-directing to other posts from the beppegrillo.it blog

internal_links_rvest <- str_subset(links, "^http://www\\.beppegrillo\\.it")
internal_links_rvest

# Creating a dataframe containing the links

dat4 <- tibble(
  links = internal_links_rvest
)

dat4







