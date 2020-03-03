####BillyGoat Proposal Search Tool for Summit, LLC.
#By John Thomas, July 2019

options(browser = "C:/Program Files/Google/Chrome/Application/chrome.exe")
key_word_path <- "C:/Users/john.thomas/Desktop/BillyGoat"

#GLOBAL

#Necessary Packages
library(shiny)
library(shinyjs)
library(pdfsearch)
library(tidyverse)
library(readxl)
library(shinythemes)
library(shinycssloaders)
library(V8)

####
#Full dataset, updated by proposal team upon each new pdf added to the drive.
pdf_descrip <- read_excel("proposal_info.xlsx")

#DF of information pertinent to the file, outside of qual and bio information
proposal_info <- pdf_descrip %>% 
  select(-c(qual1,qual2,qual3,qual4,qual5,qual6,qual7,qual8,qual9,qual10,qual11,
            bio1,bio2,bio3,bio4,bio5,bio6,bio7,bio8,bio9,bio10,bio11))

#Qual information
qual_info <- pdf_descrip %>% 
  select(c(pdf_name,qual1,qual2,qual3,qual4,qual5,qual6,qual7,qual8,qual9,qual10,qual11)) %>% 
  gather(var,qual,-pdf_name,na.rm=T) %>% # remove NA cases
  select(-var) %>% 
  arrange(qual)

#Bio information
bio_info <- pdf_descrip %>% 
  select(c(pdf_name,bio1,bio2,bio3,bio4,bio5,bio6,bio7,bio8,bio9,bio10,bio11)) %>% 
  gather(var,bio,-pdf_name,na.rm=T) %>% # remove NA fruit cases
  select(-var) %>% 
  arrange(bio)

####


#Use Enter to add a new word (seriously this goes a long way lol).
js_code <- "$(document).keyup(function(event) {
  if ($('#keyword_box').is(':focus') && (event.key == 'Enter')) {
    $('#keyword_new').click();
  }
});"


#Halloween Surprise ;)
if(format(Sys.time(), "%b %d") == "Oct 31"){
  logo <- "cursed_goat.png"
} else{
  logo <- "billygoat.png"
}
