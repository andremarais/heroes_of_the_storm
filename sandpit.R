library(reshape2)

auto <-read.csv('shiny/data/Auto.csv')

pop <- read.csv('shiny/data/Popularity.csv')
pop <- aggregate(data = pop, X0~ PrimaryName + Group + Difficulty, mean)


auto2 <- dcast(auto, PrimaryName ~ Is.Auto.Select, value.var = 'Is.Winner')
auto2$diff <- auto2$True - auto2$False

pop <- merge(pop, auto2, by = 'PrimaryName', type = 'inner')

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

ggplot(pop) + 
  geom_bar(aes_string(x = reorder(pop$PrimaryName, -pop$X0), 
                      y = pop$X0, 
                      fill = 'diff',
                      col = 'diff'), 
           stat = 'identity',
           alpha = .85) +
  theme_minimal() %+replace%
  theme(axis.text.x = element_blank(),
        axis.title.y = element_blank(),
        plot.background = element_rect(fill = '#808080', color = '#494794'),
        panel.grid.major = element_line(colour = '#009cff'),
        panel.grid.minor = element_line(colour = '#009cff'))+
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



Group_diff <- read.csv('shiny/data/Group_diff.csv')
ggplot(Group_diff) + 
  geom_bar(aes(x = Group, y = Group.difference, fill = Group.difference, col = Group.difference), stat = 'identity', position = 'dodge') +
  facet_grid(.~Map.Name) +
  scale_fill_continuous(low = 'indianred1', high = 'royalblue1') +
  scale_color_continuous(low = 'indianred3', high = 'royalblue3') +
  theme_light() %+replace% 
  theme(axis.text.x = element_text(angle = 90,
                                   color = 'black'), 
        # strip.text.x = element_text(color = '#009cff', lineheight = 15, size = 15),
        # strip.background = element_rect(fill = 'red', heightDetails),
        legend.position = 'none', 
        axis.text.y = element_blank(),
        plot.background = element_rect(fill = '#808080', color = '#494794'),
        panel.background = element_rect(fill = '#808080', color = '#494794'),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_line(colour = '#009cff')) +
  ylab('Team composition') +
  xlab('Role') + 
  ggtitle('Team composition over maps') + coord_flip()