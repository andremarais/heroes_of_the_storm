library(ggplot2)
library(scales)

hero_winrate <- read.csv('data/MMR_hero_overtime.csv')
hero_winrate$Game.Date <- as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')
heroes <- read.csv('data/hero_info.csv')
hero_winrate <- merge(hero_winrate, heroes[ ,c('HeroID', 'PrimaryName')], by='HeroID', all.x=T)
WinningMMRperHero <- read.csv('data/WinningMMRperHero.csv')
auto <-read.csv('data/Auto.csv')

pop <- read.csv('data/Popularity.csv')
levels(pop$Difficulty) <- c('Easy', 'Medium', 'Hard', 'Very Hard')
pop <- aggregate(data = pop, X0~ PrimaryName + Group + Difficulty, mean)


Group_diff <- read.csv('data/Group_diff.csv')


plot_colors_fill <- c('dodgerblue2',
                      'indianred2',
                      'goldenrod3',
                      'palegreen3'
)

plot_colors_outline <- c('dodgerblue2',
                         'indianred2',
                         'goldenrod3',
                         'palegreen3'
)

shinyServer(
  function(input, output) {
    output$hotsplot <- renderPlot({
      
      # Plot for Hero MMR rating over time
      if (input$HotsSelectInput == 'Hero MMR rating' & input$HeroMMRRadio == 'Over time') {
        
        ggplot(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, ]) + 
          geom_bar(aes(x = reorder(PrimaryName, -Adj.MMR.Before), y = Adj.MMR.Before, fill = Group, col = Group), stat = 'identity', alpha = .55)+
          theme_minimal() %+replace% 
          theme(axis.text.x = element_blank()) +
          # scale_fill_manual(values = c('lightsteelblue1', 'lightsteelblue2')) +
          annotate(geom = 'text', 
                   x = reorder(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'PrimaryName'], -hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'Adj.MMR.Before']), 
                   y = 500, 
                   label = reorder(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'PrimaryName'], -hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'Adj.MMR.Before']), 
                   angle = 90,
                   col = 'black', size = 5) +
          xlab('Heroes') +
          ylab('MMR Rating') + 
          scale_fill_manual(values = plot_colors_fill) +
          scale_color_manual(values = plot_colors_outline)
        
      } 
      
      # Plot for Hero MMR rating over win rate
      else if (input$HotsSelectInput == 'Hero MMR rating' & input$HeroMMRRadio == 'Win vs loose' ){
        ggplot(WinningMMRperHero) + 
          geom_bar(aes(x = reorder(PrimaryName, - Adj.MMR.Before), 
                       y = Adj.MMR.Before, fill = Is.Winner, col = Is.Winner), 
                   stat = 'identity', position = 'dodge', alpha = .55) +
          annotate(geom = 'text', 
                   x = reorder(WinningMMRperHero$PrimaryName, - WinningMMRperHero$Adj.MMR.Before), 
                   y = 500, 
                   label = reorder(WinningMMRperHero$PrimaryName, - WinningMMRperHero$Adj.MMR.Before), 
                   angle = 90,
                   col = 'black', size = 5) +
          theme_minimal() %+replace%
          theme(axis.text.x = element_blank(),
                legend.position = 'none') + 
          scale_fill_manual(values = c('indianred1','royalblue1')) +
          scale_color_manual(values = c('indianred1','royalblue1')) +
          ggtitle('Average MMR rating of heores played') +
          xlab('Blue: Won game | Red: Lost game') +
          ylab('MMR Before game')
        
        
      }
      
      # Plot for auto select over win rate
      else if (input$HotsSelectInput == 'Auto selected heroes'){
        ggplot(auto) + 
          geom_bar(aes(x = reorder(PrimaryName, -Is.Winner), 
                       y = Is.Winner, 
                       fill = Is.Auto.Select,
                       col = Is.Auto.Select), 
                   stat = 'identity', position = 'dodge',
                   alpha = .55)+
          theme_minimal() %+replace%
          theme(axis.text.x = element_blank(),
                axis.title.y = element_blank())+
          scale_fill_manual(values = plot_colors_fill) + 
          scale_color_manual(values = plot_colors_outline) +
          scale_y_continuous(labels = percent)+
          xlab('Hero') +
          annotate(geom = 'text', 
                   x = reorder(auto$PrimaryName, -auto$Is.Winner), 
                   y = max(auto$Is.Winner)*.01, 
                   hjust = 0,
                   label = reorder(auto$PrimaryName, -auto$Is.Winner), 
                   angle = 90,
                   col = 'black',
                   size = 5) +
          ggtitle('Win rate of auto selected heroes') +
          geom_hline(yintercept = .5, col = 'dodgerblue4') +
          annotate(geom = 'text', 
                   x = 0, 
                   y = .5, 
                   hjust = -1,
                   vjust = -1,
                   label = '50%',
                   size = 5, col = 'dodgerblue4') 
        
        
      }
      
      # Plot for Hero popularity
      else if (input$HotsSelectInput == 'Hero popularity'){
        ggplot(pop) + 
          geom_bar(aes_string(x = reorder(pop$PrimaryName, -pop$X0), 
                              y = pop$X0, 
                              fill = input$PopRadio,
                              col = input$PopRadio), 
                   stat = 'identity',
                   alpha = .55) +
          theme_minimal() %+replace%
          theme(axis.text.x = element_blank(),
                axis.title.y = element_blank())+
          scale_fill_manual(values = plot_colors_fill) + 
          scale_color_manual(values = plot_colors_outline) +
          xlab('Hero') +
          annotate(geom = 'text', 
                   x = reorder(pop$PrimaryName, -pop$X0), 
                   y = max(pop$X0)*.01, 
                   hjust = 0,
                   label = reorder(pop$PrimaryName, -pop$X0), 
                   angle = 90,
                   col = 'black') +
          ggtitle('Hero popularity')
        
        
        
      }
      
      
      else if (input$HotsSelectInput == 'Win rate per role per map') {
        
        ggplot(Group_diff) + 
          geom_bar(aes(x = Group, y = Group.difference, fill = Group.difference, col = Group.difference), stat = 'identity', position = 'dodge') +
          facet_grid(.~Map.Name) +
          scale_fill_continuous(low = 'indianred1', high = 'royalblue1') +
          scale_color_continuous(low = 'indianred3', high = 'royalblue3') +
          theme_light() %+replace% 
          theme(axis.text.x = element_text(angle = 90), legend.position = 'none', axis.text.y = element_blank()) +
          ylab('Team composition') +
          xlab('Role') + 
          ggtitle('Team composition over maps') 
        
        
      }
      
      
      
    })
    
    
    
    output$imagespace <- renderImage({
      fm <- c()
      if (input$HotsSelectInput == "Game duration")  {
        fm <- normalizePath(file.path('png_files/MMR_herolvl.png'))
        
      }
      list(src = fm)
    }
    
    , deleteFile = FALSE)
    
  }
)



