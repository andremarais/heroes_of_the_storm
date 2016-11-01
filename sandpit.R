hots <- read.csv('shiny/data/MMR_hero_overtime.csv')
heroes <- read.csv('shiny/data/hero_info.csv')
hots <- merge(hots, heroes[ ,c('HeroID', 'PrimaryName')], by='HeroID', all.x=T)
# levels(hots$PrimaryName) <- droplevels(hots$PrimaryName)
hots$Game.Date <- as.Date(as.character(hots$Game.Date), '%Y-%m-%d')




ggplot(hots[hots$Game.Date == d, ]) + 
  geom_bar(aes(x = reorder(PrimaryName, -Adj.MMR.Before), y = Adj.MMR.Before), stat = 'identity', fill = 'lightsteelblue1')+
  theme_minimal() %+replace% 
  theme(axis.text.x = element_blank()) +
  scale_fill_manual(values = c('lightsteelblue1', 'lightsteelblue2')) +
  annotate(geom = 'text', 
           x = reorder(hots[hots$Game.Date == d, 'PrimaryName'], -hots[hots$Game.Date == d, 'MMR.Before']), 
           y = 500, 
           label = reorder(hots[hots$Game.Date == d, 'PrimaryName'], -hots[hots$Game.Date == d, 'MMR.Before']), 
           angle = 90,
           col = 'dodgerblue1') +
  xlab('Heroes') +
  ylab('MMR Rating')


win_rate <- read.csv('Hero_winrate.csv')
win_rate <- merge(win_rate, heroes, by='HeroID', all.x=T)
win_rate <- win_rate[order(win_rate$SubGroup), ]
win_rate$Game.Date <- as.Date(as.character(win_rate$Game.Date), '%Y-%m-%d')

d <- sample(win_rate$Game.Date, 1)

ggplot(win_rate[win_rate$Game.Date == d, ]) + 
  geom_bar(aes(x = reorder(PrimaryName,
                           as.numeric(SubGroup)), 
               y = Is.Winner, 
               fill = SubGroup), 
           stat = 'identity') 

reorder(win_rate$PrimaryName, as.numeric(win_rate$SubGroup))


df <- expand.grid(x = 1:10, y=1:10)
df$angle <- runif(100, 0, 2*pi)
df$speed <- runif(100, 0, sqrt(0.1 * df$x))

ggplot(df, aes(x, y)) +
  geom_point() +
  geom_spoke(aes(angle = angle), radius = 0.5)

ggplot(df, aes(x, y)) +
  geom_point() +
  geom_spoke(aes(angle = angle, radius = speed))


WinningMMRperHero <- read.csv('shiny/data/WinningMMRperHero.csv')

ggplot(WinningMMRperHero) + 
  geom_bar(aes(x = reorder(PrimaryName, - Adj.MMR.Before), 
               y = Adj.MMR.Before, fill = Is.Winner, col = Is.Winner), 
           stat = 'identity', position = 'dodge', alpha = .35) +
  annotate(geom = 'text', 
           x = reorder(WinningMMRperHero$PrimaryName, - WinningMMRperHero$Adj.MMR.Before), 
           y = 500, 
           label = reorder(WinningMMRperHero$PrimaryName, - WinningMMRperHero$Adj.MMR.Before), 
           angle = 90,
           col = 'black') +
  theme_minimal() %+replace%
  theme(axis.text.x = element_blank(),
        legend.position = 'none') + 
  scale_fill_manual(values = c('indianred1','royalblue1')) +
  scale_color_manual(values = c('indianred1','royalblue1')) +
  ggtitle('Average MMR rating of heores played') +
  xlab('Blue: Won game | Red: Lost game') +
  ylab('MMR Before game')
  

pop <- read.csv('shiny/data/Popularity.csv')
levels(pop$Difficulty) <- c('Easy', 'Medium', 'Hard', 'Very Hard')
pop <- aggregate(data = pop, X0~ PrimaryName + Group + Difficulty, mean)
plot_colors_fill <- c('dodgerblue2',
                      'goldenrod3',
                      'palegreen3',
                      'indianred2')

plot_colors_outline <- c('dodgerblue4',
                         'goldenrod4',
                         'palegreen4',
                         'indianred4')



ggplot(pop) + 
  geom_bar(aes(x = reorder(PrimaryName, -X0), 
               y = X0, 
               fill = Group,
               col = Group), 
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


auto <-read.csv('shiny/data/Auto.csv')
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
           col = 'black') +
  ggtitle('Hero popularity') +
  geom_hline(yintercept = .5, col = 'dodgerblue4') +
  annotate(geom = 'text', 
           x = 0, 
           y = .5, 
           hjust = -1,
           vjust = -1,
           label = '50%',
           size = 5, col = 'dodgerblue4') 


