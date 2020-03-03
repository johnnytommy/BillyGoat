####BillyGoat Proposal Search Tool for Summit, LLC.
#By John Thomas, July 2019

##User Interface
ui <-
  fluidPage(
    theme = shinytheme("paper"),
    shinyjs::useShinyjs(),
    
    #Tab icon
    title = tags$head(
      tags$link(rel = 'icon',
                type = 'image/png',
                href = 'icon_goat.png'),
      tags$title('Billygoat by Summit, LLC.')),
    
    #Backdoor solution to make links open PDF files within table.
    shinyjs::extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),
    tags$head(
      tags$style(HTML("

                    .hiddenLink {
                      visibility: hidden;
                    }

                    "))
    ),
    br(),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      ####BillyGoat logo; created by yours truly!
      fluidRow(
        column(12, align="center",
               img(src = logo, height = 200, width = 900))),
      tags$head(tags$script(HTML(js_code))),
      br(),
      
      #Pull down of quals to restrict search.      
      h4("Choose a qualification below or leave blank to search all proposals."),
      fluidRow(
        column(12,selectInput("qual_choice", label = NULL, 
                              choices = c("All Proposals",qual_info$qual)))),    
      br(),
      
      #Pull down of bios to restrict search.      
      h4("Choose an employee below or leave blank to search all proposals."),
      fluidRow(
        column(12,selectInput("bio_choice", label = NULL, 
                              choices = c("All Bios",bio_info$bio)))),   
      
      br(),
      
      #Write in words for search.
      h4("Enter keyword below. To add multiple key words, select Add Keyword."),
      
      fluidRow(
        column(2,textInput("keyword_box", label = NULL, 
                           placeholder = "Enter keyword..."))),
      
      actionButton("keyword_new", "Add Keyword"),
      br(),
      br(),
      verbatimTextOutput('list'),
      br(),
      fluidRow(column(3,actionButton("submit","Submit")),
               column(5, actionButton("new_search","Reset Search"))),
      br(),
      
      #Return Table of results.
      dataTableOutput("tableSummit"), #the good good
      uiOutput("the_downloads")
      
    )
  )
