# shinyUI(fluidPage(theme = "bootstrap.css",
#                   
#                   titlePanel("My Application"),
#                   dygraphOutput("dygraph")
#                   # application UI              
# ))
shinyUI(
  navbarPage("MAKE BRYAN RUN", 
             theme = "bootstrap.css",
             inverse = TRUE,
             tabPanel("progress",
                      fluidPage(
                        
                        fluidRow(
                          column(1),
                          column(4, "donaters are short $100", class = "alert alert-dismissible alert-danger"),
                          column(2),
                          column(4, "bryan is winning by 4 miles", class = "alert alert-dismissible alert-success"),
                          column(1),
                          tags$style(type='text/css', ".alert {text-align: center}")
                          ),
                        br(),
                        fluidRow(
                          dygraphOutput("dygraph")
                        ),
                        br(),
                        fluidRow(
                          column(3),
                          column(6,
                                 actionButton(inputId="donate", label="donate now", class="btn btn-primary")
                          ), 
                          column(3)
                        ),
                        tags$style(type='text/css', "#donate {width:100%; vertical-align:bottom; margin: auto}")
                      )
             ),
             
             tabPanel("crowdrise"),
             tabPanel("social")
  ))