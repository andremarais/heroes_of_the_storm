hero_winrate <- read.csv('../MMR_hero_overtime.csv')
hero_winrate$Game.Date <- as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')

shinyUI(fluidPage(
  titlePanel("hots"),
  
  fluidRow(
    column(
      wellPanel(selectInput('HotsSelectInput',
                            'Select:',
                            choices = c('Hero MMR rating over time',
                                        'Win rate per role per map'),
                            selected = 'Hero MMR rating over time'
      )
      ),
      width = 3),
    
    

  
  column(
    conditionalPanel(
      condition = "input.HotsSelectInput == 'Hero MMR rating over time'",
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