source('shiny/www/multiplot.R')

HeroLevel_MMR <- read.csv('shiny/data/HeroLevel_MMR.csv')
HeroLevel_Diff <- read.csv('shiny/data/HeroLevel_Diff.csv')
levels(HeroLevel_Diff$Difficulty) <- c('Easy', 'Medium', 'Hard', 'Very Hard')
HeroLevel_Group <- read.csv('shiny/data/HeroLevel_Group.csv')
HeroLevel_SubGroup <- read.csv('shiny/data/HeroLevel_SubGroup.csv')


HM <- ggplot(HeroLevel_MMR) + 
  geom_bar(aes(x = Hero.Level, y = Adj.MMR.Before), stat = 'identity', 
           fill = 'dodgerblue2', col = 'dodgerblue2', alpha = .55) + 
  theme_minimal() %+replace%
  theme(axis.text.x = element_blank(),
        axis.title = element_blank())+
  xlab('Hero Level') +
  ylab('Average MMR') + 
  ggtitle('Average MMR over hero level') +
  annotate(geom = 'text',
           x = 0:4*5,
           label = 0:4*5,
           y = 0,
           vjust = 0)

HD <- ggplot(HeroLevel_Diff) + 
  geom_bar(aes(x = Difficulty, y = Hero.Level), stat = 'identity', 
           fill = 'dodgerblue2', col = 'dodgerblue2', alpha = .55) + 
  theme_minimal() %+replace%
  theme(axis.text.x = element_blank(),
        axis.title = element_blank())+
  xlab('Difficulty') +
  ylab('Average hero level') + 
  ggtitle('Average hero level over difficulty') +
  annotate(geom = 'text',
           x = HeroLevel_Diff$Difficulty,
           label = HeroLevel_Diff$Difficulty,
           y = 0,
           hjust = 0,
           angle = 90)

HG <- ggplot(HeroLevel_Group) + 
  geom_bar(aes(x = reorder(Group, -Hero.Level), y = Hero.Level), stat = 'identity', 
           fill = 'dodgerblue2', col = 'dodgerblue2', alpha = .55) + 
  theme_minimal() %+replace%
  theme(axis.text.x = element_blank(),
        axis.title = element_blank())+
  xlab('Role') +
  ylab('Average hero level') + 
  ggtitle('Average hero level over hero role') +
  annotate(geom = 'text',
           x = reorder(HeroLevel_Group$Group, -HeroLevel_Group$Hero.Level),
           label = reorder(HeroLevel_Group$Group, -HeroLevel_Group$Hero.Level),
           y = 0,
           hjust = 0,
           angle = 90)

HS <- ggplot(HeroLevel_SubGroup) +
  geom_bar(aes(x = reorder(SubGroup, -Hero.Level), 
               y = Hero.Level), stat = 'identity', 
           fill = 'dodgerblue2', col = 'dodgerblue2', alpha = .55) + 
  theme_minimal() %+replace%
  theme(axis.text.x = element_blank(),
        axis.title = element_blank())+
  xlab('Sub-role') +
  ylab('Average hero level') + 
  ggtitle('Average hero level over hero sub-role')+
  annotate(geom = 'text',
           x = reorder(HeroLevel_SubGroup$SubGroup, -HeroLevel_SubGroup$Hero.Level),
           label = reorder(HeroLevel_SubGroup$SubGroup, -HeroLevel_SubGroup$Hero.Level),
           y = 0,
           hjust = 0,
           angle = 90)


multiplot(HM,HD,HG,HS, cols=2)
