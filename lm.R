library(randomForest)
library(caret)
library(xgboost)


ave_MMR_per_side <-  aggregate(data = games,  MMR.Before ~ Is.Winner + ReplayID, mean)
colnames(ave_MMR_per_side)[3] <- 'Ave.team.MMR'

games <- merge(games, ave_MMR_per_side, by = c('ReplayID', 'Is.Winner'))
colnames(games)[ncol(games)] <- 'Same.team.MMR'

levels(ave_MMR_per_side$Is.Winner) <- c('True', 'False')
colnames(ave_MMR_per_side)[3] <- 'Opp.team.MMR'
games <- merge(games, ave_MMR_per_side, by = c('ReplayID', 'Is.Winner'))

model_replays <- sample(unique(games$ReplayID), length(unique(games$ReplayID))*.01)

model_data <- games[games$ReplayID %in% model_replays, ]

training_rows <- sample(nrow(model_data), nrow(model_data) * .8)

train_data <- games[training_rows, ]
test_data <- games[-training_rows, ]

MMR_model <- lm(data = games, MMR.Before ~  Is.Auto.Select + Hero.Level + Is.Winner + Same.team.MMR + Opp.team.MMR)
train_data <- NULL
test_data <- NULL
model_data <- NULL
gc()

games$MMR.Before.2 <- games$MMR.Before
games$MMR.Before.2[games$MMR.Before == 1700] <- predict(MMR_model, games[games$MMR.Before == 1700, ])

write.csv(games, 'games.csv', row.names = F)
