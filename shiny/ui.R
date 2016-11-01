hero_winrate <- read.csv('data/MMR_hero_overtime.csv')
hero_winrate$Game.Date <- as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')

shinyUI(fluidPage(
  titlePanel("hots"),
  
  fluidRow(
    column(
      wellPanel(selectInput('HotsSelectInput',
                            'Select:',
                            choices = c('Hero popularity',
                                        'Hero MMR rating',
                                        'Win rate per role per map'),
                            selected = 'Hero MMR rating over time'
      ),
      conditionalPanel(
        condition = "input.HotsSelectInput == 'Hero MMR rating'",
      
      checkboxInput('MMROverTime',
                    'Over time')
      ),
      conditionalPanel(
        condition = "input.HotsSelectInput == 'Hero popularity'",
        
        radioButtons('PopRatio',
                      'Fill:',
                     choices = c('Group', 'Difficulty'))
      )
    ),
    width = 3),
  
  column(
    conditionalPanel(
      condition = "input.HotsSelectInput == 'Hero MMR rating' & input.MMROverTime",
      wellPanel(sliderInput('HeroMMRSlider',
                            'Date',
                            min = min(hero_winrate$Game.Date),
                            max = max(hero_winrate$Game.Date),
                            animate = T,
                            value = min(hero_winrate$Game.Date)))
    ),
    width = 3)
),
fluidRow(
  
  plotOutput('hotsplot')
  
)


))