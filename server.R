####BillyGoat Proposal Search Tool for Summit, LLC.
#By John Thomas, July 2019

##Server
server <- function(input, output) {
  
  myValues <- reactiveValues()
  #User needs to see the words they've entered; this returns list of previous words.
  observe({
    if(input$keyword_new > 0){
      myValues$dList <- c(isolate(myValues$dList), isolate(input$keyword_box))
    }
  })
  output$list<-renderPrint({
    myValues$dList
  })
  
  
  observeEvent(input$keyword_new, {
    shinyjs::reset("keyword_box")
  }) #NEW KEYWORD
  
  observeEvent(input$new_search, {
    shinyjs::js$refresh() #REFRESH PAGE
  })
  
  #Now we create a table of the pdfs that have info as requested.
  observeEvent(input$submit,{
    withProgress(message = "Searching Proposals...",value = 0,{ 
      incProgress(amount = .9) #This tells the user it is currently running, but will stay at .9 complete until it is finished searching.
      
      #If we have words to search we utilize the pdfsearch package and search the pdfs, else just search based on proposal_info.
      if(length(myValues$dList) != 0){  
        data <- pdfsearch::keyword_directory(key_word_path, 
                                             keyword = myValues$dList,
                                             surround_lines = 1, 
                                             full_names = TRUE,
                                             ignore_case = TRUE)
        
        #Base dataframe returned if no words return
        if(nrow(data) == 0){
          data <- data.frame(File =character(),
                             Date = character(),
                             Organization=character(),
                             Won = character(),
                             Link=character(),
                             stringsAsFactors=FALSE) %>% 
            rename("File Name"         = File,
                   "Link to File"      = Link,
                   "Won?"              = Won)
          
          return(data)
        } 
        
        #Take data frame, collect # of distinct words and order for most matches on top.
        data <- data %>% 
          group_by(pdf_name) %>% 
          summarise(n_matches = n_distinct(keyword),n_keywords = n()) %>% 
          mutate(pdf_name = as.character(pdf_name)) %>% 
          arrange(desc(n_matches), desc(n_keywords))
        
        #Join with bio, qual, and proposal info from excel sheet.
        data <- bio_info %>% 
          full_join(qual_info,  by = "pdf_name") %>%
          full_join(proposal_info, by = "pdf_name") %>%
          right_join(data, by = "pdf_name")
        
        #Limit search to specified bio.
        if (input$bio_choice != "All Bios"){
          data <-
            data %>%
            filter(bio == input$bio_choice)
        }
        
        #Limit search to specified qual.
        if (input$qual_choice != "All Proposals"){
          data <-
            data %>%
            filter(qual == input$qual_choice)
        }
        
        #getting the links clickable.
        lapply(1:nrow(data), function(i) {
          output[[paste0("downloadData",i)]] <- downloadHandler(
            filename = function() {
              paste0(data$pdf_name[i], sep="")
            },
            content = function(file) {
              file.copy(from = data$pdf_name[i], to = file)
            }
          )
        })
        
        #Backdoor hidden link for pdfs to open on click.
        output$the_downloads <- renderUI(
          lapply(1:nrow(data), function(i) downloadLink(paste0("downloadData", i), "download", class = "hiddenLink"))
        )
        
          data2 <- data %>% 
            mutate(link = lapply(1:n(),
                                 function(i)
                                   paste0('<a href="#" onClick=document.getElementById("downloadData',i,'").click() >Download</a>')
            )) %>% 
            rename("Distinct Keywords" = n_keywords,
                   "Number of Keywords"= n_matches,
                   "File Name"         = pdf_name,
                   "Link to File"      = link) %>%
            select(-c(extension,qual,bio))  %>% 
            mutate(`Date Submitted` = as.character(`Date Submitted`)) %>% 
            distinct(`File Name`, .keep_all = TRUE)
      }
      else{
        #If they just want to search pdfs without specific words.
        data <- proposal_info %>% 
          full_join(qual_info,  by = "pdf_name") %>%
          full_join(bio_info, by = "pdf_name") %>% 
          mutate(pdf_name = as.character(pdf_name))
        
        #Searching just based on bio.
        if (input$bio_choice != "All Bios"){
          data <-
            data %>%
            filter(bio == input$bio_choice)
        }
        
        #Limit search to specified qual.
        if (input$qual_choice != "All Proposals"){
          data <-
            data %>%
            filter(qual == input$qual_choice)
        }
        
        if(nrow(data) == 0){
          data <- data.frame(File =character(),
                             Date = character(),
                             Organization=character(),
                             Won = character(),
                             Link=character(),
                             stringsAsFactors=FALSE) %>% 
            rename("File Name"         = File,
                   "Link to File"      = Link,
                   "Won?"              = Won)
          
          return(data)
        }
        
        #Dowload Handler for each row in table.
        lapply(1:nrow(data), function(i) {
          output[[paste0("downloadData",i)]] <- downloadHandler(
            filename = function() {
              paste0(data$pdf_name[i], sep="")
            },
            content = function(file) {
              file.copy(from = data$pdf_name[i], to = file)
            }
          )
        })
        
        output$the_downloads <- renderUI(
          lapply(1:nrow(data), function(i) downloadLink(paste0("downloadData", i), "download", class = "hiddenLink"))
        )
        
        
          data2 <- data %>% 
            mutate(link = lapply(1:n(),
                                 function(i)
                                   paste0('<a href="#" onClick=document.getElementById("downloadData',i,'").click() >Download</a>')
            )) %>% 
            rename("File Name"         = pdf_name,
                   "Link to File"      = link) %>% 
            select(-c(extension,qual,bio))  %>% 
            mutate( `Date Submitted` = as.character(`Date Submitted`)) %>% 
            distinct(`File Name`, .keep_all = TRUE)
          
          
      }
      
    }) 
    
    if(nrow(data) == 0){  #if they put some nonsense we got it covered.
      output$tableSummit <- renderDataTable(data
                                            ,escape = FALSE)
      return(NULL)
    } 
    
    output$tableSummit <- renderDataTable(data2
                                          ,escape = FALSE)}
    ,ignoreInit = F)
  
} 
