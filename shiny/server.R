library(ggplot2)

hero_winrate <- read.csv('data/MMR_hero_overtime.csv')
hero_winrate$Game.Date <- as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')
heroes <- read.csv('data/hero_info.csv')
hero_winrate <- merge(hero_winrate, heroes[ ,c('HeroID', 'PrimaryName')], by='HeroID', all.x=T)
WinningMMRperHero <- read.csv('data/WinningMMRperHero.csv')


pop <- read.csv('data/Popularity.csv')
levels(pop$Difficulty) <- c('Easy', 'Medium', 'Hard', 'Very Hard')
pop <- aggregate(data = pop, X0~ PrimaryName + Group + Difficulty, mean)


Group_diff <- read.csv('data/Group_diff.csv')


plot_colors_fill <- c('dodgerblue2',
                      'indianred2',
                 'goldenrod3',
                 'palegreen3'
                 )

plot_colors_outline <- c('dodgerblue4',
                         'indianred4',
                      'goldenrod4',
                      'palegreen4'
                      )

shinyServer(
  function(input, output) {
    output$hotsplot <- renderPlot({

      if (input$HotsSelectInput == 'Hero MMR rating' & input$MMROverTime) {
      
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
      
      else if (input$HotsSelectInput == 'Hero MMR rating' & !input$MMROverTime){
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
      
      else if (input$HotsSelectInput == 'Hero popularity'){
        ggplot(pop) + 
          geom_bar(aes_string(x = reorder(pop$PrimaryName, -pop$X0), 
                       y = pop$X0, 
                       fill = input$PopRatio,
                       col = input$PopRatio), 
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
          facet_grid(.~MapID) +
          scale_fill_continuous(low = 'indianred1', high = 'royalblue1') +
          scale_color_continuous(low = 'indianred3', high = 'royalblue3') +
          theme_light() %+replace% 
          theme(axis.text.x = element_text(angle = 90), legend.position = 'none', axis.text.y = element_blank()) +
          ylab('Team composition') +
          xlab('Role') + 
          ggtitle('Team composition over maps') 
        
        
      }
      

      
    })
    
  }
)


                          
                          