library(ggplot2)

hero_winrate <- read.csv('../MMR_hero_overtime.csv')
hero_winrate$Game.Date <- as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')
heroes <- read.csv('../hero_info.csv')
hero_winrate <- merge(hero_winrate, heroes[ ,c('HeroID', 'PrimaryName')], by='HeroID', all.x=T)

Group_diff <- read.csv('../Group_diff.csv')


plot_colors_fill <- c('dodgerblue2',
                 'goldenrod3',
                 'palegreen3',
                 'indianred2')

plot_colors_outline <- c('dodgerblue4',
                      'goldenrod4',
                      'palegreen4',
                      'indianred4')

shinyServer(
  function(input, output) {
    output$hotsplot <- renderPlot ({
      
      if (input$HotsSelectInput == 'Hero MMR rating over time') {
      
      ggplot(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, ]) + 
        geom_bar(aes(x = reorder(PrimaryName, -Adj.MMR.Before), y = Adj.MMR.Before, fill = Group, col = Group), stat = 'identity')+
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
        
      } else if (input$HotsSelectInput == 'Win rate per role per map') {
        
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


