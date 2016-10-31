library(plyr)
library(ggplot2)
library(magrittr)
library(scales)
library(jsonlite)

games <- read.csv('ReplayCharacters 2015-12-30 - 2016-01-29.csv')
games <- games[games$ReplayID %in% unique(games$ReplayID)[sample(length(unique(games$ReplayID)), 10000)], ]
gc()
games_info <- read.csv('Replays 2015-12-30 - 2016-01-29.csv')
games_info$Timestamp..UTC. <- as.Date(substring(games_info$Timestamp..UTC., 1, 10), '%m/%d/%Y')

hero.info <- read.csv('hero_info.csv')
games <- merge(games, hero.info, by ="HeroID")
games <- merge(games, games_info[, c('ReplayID', 'Timestamp..UTC.')], by = 'ReplayID')
games <- games[!is.na(games$MMR.Before), ]
games <- games[order(games$ReplayID, games$Is.Winner),]


# kak plot
role_agg <- 
  count(df = games, vars =  c("ReplayID", "Is.Winner", "Role")) 
aggregate(data = role_agg,freq ~ Role + Is.Winner, mean)  %>%
  ggplot() + geom_bar(aes(y = freq, x = Role), stat = 'identity') + facet_grid(Is.Winner ~.)

# MMR rating of 1700 is a problem, it might be the starting rating
# imputing it makes sense to smooth the ratings 

source('lm.R')


heroes$MMR.Before.adj <- heroes$MMR.Before
heroes$MMR.Before.adj[heroes$MMR.Before == 1700] <- predict(MMR_model, heroes[heroes$MMR.Before == 1700, ])

ggplot(heroes) +
  geom_density(aes(x = MMR.Before), fill = 'dodgerblue', alpha = .65) +
  geom_density(aes(x = MMR.Before.adj), fill = 'indianred', alpha = .65) +
  theme_minimal()

ggplot() + 
  geom_density(data = heroes[heroes$Is.Winner == 'True', ], 
               aes(x = MMR.Before.adj), fill = 'dodgerblue', alpha = .65) +
  geom_density(data = heroes[heroes$Is.Winner == 'False', ], 
               aes(x = MMR.Before.adj), fill = 'indianred', alpha = .65) +
  theme_minimal()

hero.win.rate <- aggregate(data = heroes, Is.Winner == 'True' ~ HeroID, mean) 
  
colnames(hero.win.rate) <- c("Hero", "WR")
ggplot(hero.win.rate) + 
  geom_bar(aes(x = reorder(Hero, -WR), y = WR), stat = 'identity', fill = 'lightsteelblue1') +
  theme_minimal() %+replace% 
  theme(axis.text.x = element_blank(),
        axis.text.y = element_text()) + 
  annotate(geom = 'text', 
           x = reorder(hero.win.rate$Hero, -hero.win.rate$WR), 
           y = 0.1, 
           label = reorder(hero.win.rate$Hero, -hero.win.rate$WR), 
           angle = 90,
           col = 'lightsteelblue4') +
  annotate(geom = 'text', 
           x = levels(reorder(hero.win.rate$Hero, -hero.win.rate$WR))[1], 
           y = 0.51, 
           label = '50%',
           col = 'lightsteelblue4') +
  geom_hline(yintercept = .5, col = 'lightsteelblue3')+
  xlab('Heroes') +
  ylab('Win rate')

hero_mmr_winrate <- 
  aggregate(data = heroes, MMR.Before ~ Hero + Is.Winner, mean) 

ggplot(hero_mmr_winrate) + 
  geom_bar(aes(x = reorder(Hero, -MMR.Before), y = MMR.Before, fill = Is.Winner), stat = 'identity', position = 'dodge')+
  theme_minimal() %+replace% 
  theme(axis.text.x = element_blank()) +
  scale_fill_manual(values = c('lightsteelblue1', 'lightsteelblue2')) +
  annotate(geom = 'text', 
           x = reorder(hero_mmr_winrate$Hero, -hero_mmr_winrate$MMR.Before), 
           y = 200, 
           label = reorder(hero_mmr_winrate$Hero, -hero_mmr_winrate$MMR.Before), 
           angle = 90,
           col = 'lightsteelblue4') +
  xlab('Heroes') +
  ylab('MMR Rating')



Group_diff <- read.csv('Group_diff.csv')

ggplot(Group_diff) + 
  geom_bar(aes(x = Group, y = Group.difference, fill = Group.difference, col = Group.difference), stat = 'identity', position = 'dodge') +
  facet_grid(.~MapID) +
  scale_fill_continuous(low = 'royalblue1', high = 'indianred1') +
  scale_color_continuous(low = 'royalblue3', high = 'indianred3') +
  theme_light() %+replace% 
  theme(axis.text.x = element_text(angle = 90), legend.position = 'none', axis.text.y = element_blank()) +
  ylab('Team composition') +
  xlab('Role') + 
  ggtitle('Team composition over maps') 



Role_winrate <- read.csv('Role_winrate.csv')
ggplot(Role_winrate) +
  geom_bar(aes(x = reorder(SubGroup, as.numeric(Group)), y = Is.Winner, fill = Group), stat = 'identity', position = 'dodge')
