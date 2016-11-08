library(ggplot2)
library(scales)
source('www/multiplot.R')

hero_winrate <- read.csv('data/MMR_hero_overtime.csv')
hero_winrate$Game.Date <-
  as.Date(as.character(hero_winrate$Game.Date), '%Y-%m-%d')
heroes <- read.csv('data/hero_info.csv')
hero_winrate <-
  merge(hero_winrate, heroes[, c('HeroID', 'PrimaryName')], by = 'HeroID', all.x =
          T)
WinningMMRperHero <- read.csv('data/WinningMMRperHero.csv')
auto <- read.csv('data/Auto.csv')

HeroLevel_MMR <- read.csv('data/HeroLevel_MMR.csv')
HeroLevel_Diff <- read.csv('data/HeroLevel_Diff.csv')
levels(HeroLevel_Diff$Difficulty) <-
  c('Easy', 'Medium', 'Hard', 'Very Hard')
HeroLevel_Group <- read.csv('data/HeroLevel_Group.csv')
HeroLevel_SubGroup <- read.csv('data/HeroLevel_SubGroup.csv')

pop <- read.csv('data/Popularity.csv')
levels(pop$Difficulty) <- c('Easy', 'Medium', 'Hard', 'Very Hard')
pop <-
  aggregate(data = pop, X0 ~ PrimaryName + Group + Difficulty, mean)


Group_diff <- read.csv('data/Group_diff.csv')


plot_colors_fill <- c('dodgerblue2',
                      'indianred2',
                      'goldenrod3',
                      'palegreen3')

plot_colors_outline <- c('dodgerblue4',
                         'indianred4',
                         'goldenrod4',
                         'palegreen4')

shinyServer(function(input, output) {
  output$hotsplot <- renderPlot({
    # Plot for Hero MMR rating over time
    if (input$HotsSelectInput == 'Hero MMR rating' &
        input$HeroMMRRadio == 'Over time') {
      ggplot(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider,]) +
        geom_bar(
          aes(
            x = reorder(PrimaryName,-Adj.MMR.Before),
            y = Adj.MMR.Before,
            fill = Group,
            col = Group
          ),
          stat = 'identity',
          alpha = .55
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        annotate(
          geom = 'text',
          x = reorder(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'PrimaryName'],-hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'Adj.MMR.Before']),
          y = 500,
          label = reorder(hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'PrimaryName'],-hero_winrate[hero_winrate$Game.Date == input$HeroMMRSlider, 'Adj.MMR.Before']),
          angle = 90,
          col = 'black',
          size = 5
        ) +
        xlab('Heroes') +
        ylab('MMR Rating') +
        scale_fill_manual(values = plot_colors_fill) +
        scale_color_manual(values = plot_colors_outline)
      
    }
    
    # Plot for Hero MMR rating over win rate
    else if (input$HotsSelectInput == 'Hero MMR rating' &
             input$HeroMMRRadio == 'Win vs loose') {
      ggplot(WinningMMRperHero) +
        geom_bar(
          aes(
            x = reorder(PrimaryName,-Adj.MMR.Before),
            y = Adj.MMR.Before,
            fill = Is.Winner,
            col = Is.Winner
          ),
          stat = 'identity',
          position = 'dodge',
          alpha = .55
        ) +
        annotate(
          geom = 'text',
          x = reorder(
            WinningMMRperHero$PrimaryName,
            -WinningMMRperHero$Adj.MMR.Before
          ),
          y = 500,
          label = reorder(
            WinningMMRperHero$PrimaryName,
            -WinningMMRperHero$Adj.MMR.Before
          ),
          angle = 90,
          col = 'black',
          size = 5
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          legend.position = 'none',
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        scale_fill_manual(values = plot_colors_fill) +
        scale_color_manual(values = plot_colors_outline) +
        ggtitle('Average MMR rating of heores played') +
        xlab('Blue: Won game | Red: Lost game') +
        ylab('MMR Before game')
      
      
    }
    
    # Plot for auto select over win rate
    else if (input$HotsSelectInput == 'Auto selected heroes') {
      ggplot(auto) +
        geom_bar(
          aes(
            x = reorder(PrimaryName,-Is.Winner),
            y = Is.Winner,
            fill = Is.Auto.Select,
            col = Is.Auto.Select
          ),
          stat = 'identity',
          position = 'dodge',
          alpha = .65
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          axis.title.y = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        scale_fill_manual(values = plot_colors_fill) +
        scale_color_manual(values = plot_colors_outline) +
        scale_y_continuous(labels = percent) +
        xlab('Hero') +
        annotate(
          geom = 'text',
          x = reorder(auto$PrimaryName,-auto$Is.Winner),
          y = max(auto$Is.Winner) * .01,
          hjust = 0,
          label = reorder(auto$PrimaryName,-auto$Is.Winner),
          angle = 90,
          col = 'black',
          size = 5
        ) +
        ggtitle('Win rate of auto selected heroes') +
        geom_hline(yintercept = .5, col = 'dodgerblue4') +
        annotate(
          geom = 'text',
          x = 0,
          y = .5,
          hjust = -1,
          vjust = -1,
          label = '50%',
          size = 5,
          col = 'dodgerblue4'
        )
      
      
    }
    
    # Plot for Hero popularity
    else if (input$HotsSelectInput == 'Hero popularity') {
      ggplot(pop) +
        geom_bar(
          aes_string(
            x = reorder(pop$PrimaryName,-pop$X0),
            y = pop$X0,
            fill = input$PopRadio,
            col = input$PopRadio
          ),
          stat = 'identity',
          alpha = .55
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          axis.title.y = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        scale_fill_manual(values = plot_colors_fill) +
        scale_color_manual(values = plot_colors_outline) +
        xlab('Hero') +
        annotate(
          geom = 'text',
          x = reorder(pop$PrimaryName,-pop$X0),
          y = max(pop$X0) * .01,
          hjust = 0,
          label = reorder(pop$PrimaryName,-pop$X0),
          angle = 90,
          col = 'black'
        ) +
        ggtitle('Hero popularity')
      
      
      
    }
    
    
    else if (input$HotsSelectInput == 'Win rate per role per map') {
      ggplot(Group_diff) +
        geom_bar(
          aes(
            x = Group,
            y = Group.difference,
            fill = Group.difference,
            col = Group.difference
          ),
          stat = 'identity',
          position = 'dodge'
        ) +
        facet_grid(. ~ Map.Name) +
        scale_fill_continuous(low = 'indianred1', high = 'royalblue1') +
        scale_color_continuous(low = 'indianred3', high = 'royalblue3') +
        theme_light() %+replace%
        theme(
          axis.text.x = element_text(angle = 90,
                                     color = 'black'),
          # strip.text.x = element_text(color = '#009cff', lineheight = 15, size = 15),
          # strip.background = element_rect(fill = 'red', heightDetails),
          legend.position = 'none',
          axis.text.y = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        ylab('Team composition') +
        xlab('Role') +
        ggtitle('Team composition over maps')
      
      
    }
    
    else if (input$HotsSelectInput == 'Hero level') {
      HM <- ggplot(HeroLevel_MMR) +
        geom_bar(
          aes(x = Hero.Level, y = Adj.MMR.Before),
          stat = 'identity',
          fill = 'dodgerblue2',
          col = 'dodgerblue4',
          alpha = .55
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          axis.title = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        xlab('Hero Level') +
        ylab('Average MMR') +
        ggtitle('Average MMR over hero level') +
        annotate(
          geom = 'text',
          x = 0:4 * 5,
          label = 0:4 * 5,
          y = 0,
          vjust = 0,
          size = 5
        )
      
      HD <- ggplot(HeroLevel_Diff) +
        geom_bar(
          aes(x = Difficulty, y = Hero.Level),
          stat = 'identity',
          fill = 'dodgerblue2',
          col = 'dodgerblue4',
          alpha = .55
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          axis.title = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        xlab('Difficulty') +
        ylab('Average hero level') +
        ggtitle('Average hero level over difficulty') +
        annotate(
          geom = 'text',
          x = HeroLevel_Diff$Difficulty,
          label = HeroLevel_Diff$Difficulty,
          y = 0,
          hjust = 0,
          angle = 90,
          size = 5
        )
      
      HG <- ggplot(HeroLevel_Group) +
        geom_bar(
          aes(x = reorder(Group,-Hero.Level), y = Hero.Level),
          stat = 'identity',
          fill = 'dodgerblue2',
          col = 'dodgerblue4',
          alpha = .55
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          axis.title = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        xlab('Role') +
        ylab('Average hero level') +
        ggtitle('Average hero level over hero role') +
        annotate(
          geom = 'text',
          x = reorder(HeroLevel_Group$Group,-HeroLevel_Group$Hero.Level),
          label = reorder(HeroLevel_Group$Group,-HeroLevel_Group$Hero.Level),
          y = 0,
          hjust = 0,
          angle = 90,
          size = 5
        )
      
      HS <- ggplot(HeroLevel_SubGroup) +
        geom_bar(
          aes(x = reorder(SubGroup,-Hero.Level),
              y = Hero.Level),
          stat = 'identity',
          fill = 'dodgerblue2',
          col = 'dodgerblue4',
          alpha = .55
        ) +
        theme_minimal() %+replace%
        theme(
          axis.text.x = element_blank(),
          axis.title = element_blank(),
          plot.background = element_rect(fill = '#808080', color = '#494794'),
          panel.grid.major = element_line(colour = '#009cff'),
          panel.grid.minor = element_line(colour = '#009cff')
        ) +
        xlab('Sub-role') +
        ylab('Average hero level') +
        ggtitle('Average hero level over hero sub-role') +
        annotate(
          geom = 'text',
          x = reorder(
            HeroLevel_SubGroup$SubGroup,
            -HeroLevel_SubGroup$Hero.Level
          ),
          label = reorder(
            HeroLevel_SubGroup$SubGroup,
            -HeroLevel_SubGroup$Hero.Level
          ),
          y = 0,
          hjust = 0,
          angle = 90,
          size = 5
        )
      
      
      multiplot(HM, HD, HG, HS, cols = 2)
      
      
    }
    
  })
  
  
  output$imagespace1 <- renderImage({
    fm <- normalizePath(file.path('png_files/blank.png'))
    if (input$HotsSelectInput == "Game duration")  {
      # fm <- normalizePath(file.path('png_files/MMR_herolvl.png'))
      fm <-
        normalizePath(file.path(
          paste('png_files/maps/', input$SelectMap, '.png', sep = '')
        ))
      
    }
    list(src = fm)
  },
  deleteFile = F)
  
  output$imagespace2 <- renderImage({
    fm <- normalizePath(file.path('png_files/blank.png'))
    if (input$HotsSelectInput == "Game duration")  {
      # fm <- normalizePath(file.path('png_files/MMR_herolvl.png'))
      fm <-
        normalizePath(file.path(
          paste('png_files/maps/', input$SelectMap2, '.png', sep = '')
        ))
      
    }
    list(src = fm)
  },
  deleteFile = F)
  
  
  output$helptextbox <- renderText({
    if (input$HotsSelectInput == 'Auto selected heroes')
      "For the given date range, it seems like Graymane and ChoGall weren't part of the auto-select pool.
    The difference in the win-rate between auto-select True and False can be seen as an indication of how difficult it can be to learn how to play the hero."
    else if (input$HotsSelectInput == 'Game duration')
      "The heatmaps plot game duration (y-axis) over the teams' average MMR difference (x-axis). The brightness of the cells indicate density.
    Most of the heatmaps have a horizontal stretch, indicating that games where the teams are of equal strength tend to last longer.
    Battlefield of Eternity and Infernal Shrines are two maps where there's an interesting split divide in game duration
    I haven't played HoTS in many many months, so I don't know how these maps work :("
    else if (input$HotsSelectInput == 'Hero level')
      "The two graphs on the right shows what people in general prefer. Top left graph shows there's a correlation between hero level and MMR.
    It might sound duh, but if you see someone with a hero master skin, you're already a bit more cautious ;) Point is, the more you play, the better you'll become."
    else if (input$HotsSelectInput == 'Hero MMR rating')
      "This graph shows the average MMR of all the players per hero. In essence it shows what the hero preference is of higher skilled players.
    I've added a ticker to show how this changes over time, but the time period is too short to see any cool trends.
    I was hoping to see something cool when I split the average MMR over win/ loose, but I think the difference you see is just due to noise."
    else if (input$HotsSelectInput == 'Hero popularity')
      "Simple graph, but it's still interesting. The difficulty level for each hero is from the actual game."
    else if (input$HotsSelectInput == 'Win rate per role per map')
      "I really like this graph, it shows the team composition over the different maps.
    For example, in Battlefield of Eternity, the losing team has more support/ warriors whereas at Infernal Shrine the winning team has more assassins.
    One thing that is clear from this graph, is that not having a specialist is bad mkay. "
    
  })
  
  observeEvent(input$HotsSelectInput,
               if (input$HotsSelectInput == 'Game duration') {
                 hide('hotsplot')
                 show('imagespace1')
                 show('imagespace2')
                 show('helptextbox')
               } else if (input$HotsSelectInput ==  "--about--") {
                 
                 hide('hotsplot')
                 hide('imagespace1')
                 hide('imagespace2')
                 hide('helptextbox')
                 
               } else
               {
                 show('hotsplot')
                 hide('imagespace1')
                 hide('imagespace2')
                 show('helptextbox')
               } 
               
               
               
               )
  
  # observeEvent(input$HotsSelectInput,
  #              if (input$HotsSelectInput == '--about--') {
  #                hide('helptextbox')
  # } else if (input$HotsSelectInput != '--about--') {
  #     show('helptextbox')
  #   })
  
  
})
