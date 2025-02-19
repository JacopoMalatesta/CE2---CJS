# Installing RCurl 

install.packages("RCurl")

# Loading the packages

library(RCurl); library(rvest); library(tidyverse); library(stringr)

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

links_rvest <- read_html(here::here("downloaded_pages", "beppe_grillo_plastica.html")) %>% 
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
prossimo_link <- read_html(here::here("downloaded_pages", "beppe_grillo_plastica.html")) %>% 
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
dir.create(here::here("downloaded_pages/prossimo articolo"))
all_prossimo_links [[1]] <- url
for (i in 1:4) {
  all_prossimo_links[[i+1]] <- read_html(all_prossimo_links[i]) %>% html_nodes(".td-post-next-post a") %>% html_attr("href") 
  Sys.sleep(2)
}

# 2. Downloading the pages and scraping the text 
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

# Point 5---------------------------------------------------------------------------------------------------------------
# 1. Getting the links of 47 pages 
archivepages <-list()
url2016 <- "https://www.beppegrillo.it/category/archivio/2016/"
archivepages[[1]] <- url2016
for (i in 1:46) {
  archivepages[[i+1]] <- read_html(archivepages[[i]]) %>% html_nodes(".last+ a") %>% html_attr("href") 
  Sys.sleep(2)
}
# The css path of "next page" on the 46th page is different, so we scrape the link of the 47th page alone
archivepages[[47]] <- read_html(archivepages[[46]]) %>% html_nodes(".page+ a") %>% html_attr("href")

# 2. Getting all the articles links on 47 pages
articlelinks <- list()
for (i in 1:47) {
  articlelinks[(1+(i-1)*10):(i*10)] <- read_html(archivepages[[i]]) %>%
    html_nodes(".td_module_10 .td-module-title a") %>% html_attr("href") 
  Sys.sleep(2)
}
articlelinks[[470]] <- NULL

# 3. Downloading all the article pages
dir.create(here::here("downloaded_pages/articles"))
for (i in 1:149) {
  cat("Iteration:", i)
  filepath2 <- here::here("articles",str_c("page_", i, ".html"))
  download.file(articlelinks[[i]], filepath2)
  Sys.sleep(2) }
articlelinks[[150]] <- NULL
for (i in 150:212) {
  cat("Iteration:", i)
  filepath2 <- here::here("articles",str_c("page_", i, ".html"))
  download.file(articlelinks[[i]], filepath2)
  Sys.sleep(2) }
articlelinks[[213]] <- NULL
for (i in 213:419) {
  cat("Iteration:", i)
  filepath2 <- here::here("articles",str_c("page_", i, ".html"))
  download.file(articlelinks[[i]], filepath2)
  Sys.sleep(2) }
articlelinks[[420]] <- NULL
for (i in 420:466) {
  cat("Iteration:", i)
  filepath2 <- here::here("articles",str_c("page_", i, ".html"))
  download.file(articlelinks[[i]], filepath2)
  Sys.sleep(2) }

# 4.scraping the text
text <- list()

for (i in 1:466) {
  cat("Iteration:", i)
  filepath3 <- here::here("articles",str_c("page_", i, ".html"))
  text[[i]] <- read_html(filepath3) %>%
    html_nodes("p") %>% 
    html_text() }

# Point 6--------------------------------------------------------------------------------------------------------------

# Crawling means looking at all the content and codes on a page, analyzing and downloading them. This can be done for 
# different purposes, the main one being web indexing. A web spider is a program that automatically browses and downloads 
# Web pages by following hyperlinks in a methodical and automated manner. They are usually used for web indexing, but 
# can also be used for web scraping. 


# Building a spider scraper
# The function we use to build the scraper spider is Rcrawler
# arguments: 1.Website: to idicate the website
# 2. Obeyrobots: if TRUE, the crawler will parse the website’s robots.txt file and obey its ruhow many processes will execute the taskles allowed and disallowed directories.
# 3. ExtractCSSPat: to extract one element per pattern for every page
# 4. ManyPerPattern: to extract multiple elements per pattern, we need to set ManyPerPattern = T
# 5. no_cores: specify how many processes will execute the task
# 6. no_conn: specify how many HTTP requests will be sent simultaneously (in parallel).



