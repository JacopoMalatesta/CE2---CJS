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

# Point 4 ----------------------------------------------------------------------------------------------------------------
# Scraping the link of "prossimo articolo"
prossimo_link <- read_html("beppegrillo.html") %>% 
  html_nodes(".td-post-next-post a") %>% html_attr("href") 
# Downloading the page of following article
download.file(prossimo_link,destfile = here::here("downloaded_pages", "prossimo_articolo"))
# Scraping the text of the article
articolo <- read_html("prossimo_articolo.html") %>%
  html_nodes("p:nth-child(5) , p:nth-child(3) , p:nth-child(2) , p:nth-child(1) , .td-pb-padding-side .entry-title") %>% 
  html_text()
articolo <- articolo[1:5]

# How to use previous and following links to scrape more post?
# 1. First, creating a loop to get the previous links and following links. The times of iteration are based on
# how many previous and following articles you'd like to scrape.
# For example, we set "http://www.beppegrillo.it/un-mare-di-plastica-ci-sommergera/" as our initial page, and we want to
# scrape 4 following pages:
all_prossimo_links <-vector(mode = "character", length = 5)
dir.create(here::here("downloaded_pages/articles"))
all_prossimo_links [[1]] <- url
for (i in 1:4) {
  all_prossimo_links[[i+1]] <- read_html(all_prossimo_links[i]) %>% html_nodes(".td-post-next-post a") %>% html_attr("href") 
  Sys.sleep(2)
}

# 2. Downloading the pages with the links we obtained above and scraping the text 
article_description <-list()
for (i in 1:5) {  
  file_path <- here::here("articles",str_c("article_", i, ".html"))
  download.file(all_prossimo_link[[i]],destfile =file_path)
  article_description[[i]] <- read_html(file_path) %>% 
    html_nodes("p") %>% 
    html_text() 
  Sys.sleep(2)
}  
# 3. Scraping the previous links and articles is the same, just to replace the css path in the first with ".td-post-next-prev-content a"  




