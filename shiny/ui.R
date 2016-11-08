library(shinyjs)

hero_winrate <- read.csv('data/MMR_hero_overtime.csv')
hero_winrate$Game.Date <-
  as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')
map_names <- list.files('png_files/maps', pattern = '.png')

wellpanelstyle <-
  "background-color: #808080; border-color: #494794;"

shinyUI(fluidPage(
  theme = 'heroes.css',
  useShinyjs(),
  titlePanel("Heroes of the storm"),
  
  fluidRow(
    column(
      wellPanel(
        selectInput(
          'HotsSelectInput',
          'Select:',
          choices = c(
            'Auto selected heroes',
            'Game duration',
            'Hero level',
            'Hero MMR rating',
            'Hero popularity',
            'Win rate per role per map',
            '--about--'
          ),
          selected = 'Auto selected heroes'
        ),
        
        # Conditional options for Hero MMR Rating
        conditionalPanel(condition = "input.HotsSelectInput == 'Hero MMR rating'",
                         
                         radioButtons(
                           'HeroMMRRadio',
                           'View',
                           choices = c('Over time', 'Win vs loose')
                         )),
        
        #Conditional options for Hero Hero popularity
        conditionalPanel(condition = "input.HotsSelectInput == 'Hero popularity'",
                         
                         radioButtons(
                           'PopRadio',
                           'Fill:',
                           choices = c('Group', 'Difficulty')
                         )),
        style = wellpanelstyle
      ),
      width = 3
    ),
    
    # Conditional wellpanel for extra input
    column(
      conditionalPanel(condition = "input.HotsSelectInput == 'Hero MMR rating' & input.HeroMMRRadio == 'Over time'",
                       wellPanel(
                         sliderInput(
                           'HeroMMRSlider',
                           'Date',
                           min = min(hero_winrate$Game.Date),
                           max = max(hero_winrate$Game.Date),
                           animate = T,
                           value = min(hero_winrate$Game.Date)
                         ),
                         style = wellpanelstyle
                       )),
      conditionalPanel(
        condition = "input.HotsSelectInput == 'Game duration'",
        wellPanel(
          selectInput('SelectMap',
                      'Choose map',
                      choices = array(sapply(map_names, function(x)
                        gsub(".png", '', x)))),
          selectInput(
            'SelectMap2',
            'Compare to:',
            choices = array(sapply(map_names, function(x)
              gsub(".png", '', x))),
            selected = array(sapply(map_names, function(x)
              gsub(".png", '', x)))[2]
          ),
          style = wellpanelstyle
        )
        
        
      ),
      width = 3
    ),
    
    
    
    
    column(
      conditionalPanel(
        condition = "input.HotsSelectInput != '--about--'",
        wellPanel(textOutput('helptextbox'),
                  tags$head(
                    tags$style("#helptextbox{
                               font-size: 13px;
                               background-color: #808080;
                               }")
        ),
        style = wellpanelstyle)
                  )
      
      ,
      width = 6
                  )
        ),
  fluidRow(
    plotOutput('hotsplot'),
    column(imageOutput('imagespace1'),
           width = 6),
    column(imageOutput('imagespace2'),
           width = 6),
    conditionalPanel(
      condition = "input.HotsSelectInput == '--about--'",
      column(includeMarkdown("www/1.md"), width = 12)
    )
  )
  

  
    ))