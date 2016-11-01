import pandas as pd
import datetime
from imputing1700 import impute_1700

replay_data = pd.read_csv('ReplayCharacters 2015-12-30 - 2016-01-29.csv')
hero_info = pd.read_csv('hero_info.csv')
replay_info = pd.read_csv('Replays 2015-12-30 - 2016-01-29.csv')

all_games = impute_1700(replay_data, hero_info, replay_info)
all_games = all_games.merge(replay_info, how='left', on='ReplayID')
all_games = all_games.merge(hero_info, how='left', on='HeroID')
print('Merging done')


def change_date(x):
    new_date = datetime.datetime.strptime(x, '%m/%d/%Y %H:%M:%S %p').strftime('%Y-%m-%d')
    return new_date
# Add proper date field for R
all_games['Game Date'] = all_games['Timestamp (UTC)'].apply(change_date)

# MMR rate per hero over time
pd.DataFrame(all_games.groupby(['HeroID', 'Group', 'Game Date'])['Adj MMR Before'].mean()).to_csv('shiny/data/MMR_hero_overtime.csv')

# Hero winrate over time
pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'SubGroup', 'Game Date'])['Is Winner'].mean()).to_csv('shiny/data/Hero_winrate.csv')

# Role presence for each map
winners = pd.DataFrame(all_games[all_games['Is Winner'] == True].groupby(['ReplayID', 'MapID', 'Group'])['Is Winner'].count())
winners['ReplayID'], winners['MapID'], winners['Group'] = [i[0] for i in winners.index.values], [i[1] for i in winners.index.values], [i[2] for i in winners.index.values]
winners.columns = ['Winning_team', 'ReplayID', 'MapID', 'Group']

losers = pd.DataFrame(all_games[all_games['Is Winner'] == False].groupby(['ReplayID', 'MapID', 'Group'])['Is Winner'].count())
losers['ReplayID'], losers['MapID'], losers['Group'] = [i[0] for i in losers.index.values], [i[1] for i in losers.index.values], [i[2] for i in losers.index.values]
losers.columns = ['Losing_team', 'ReplayID', 'MapID', 'Group']

group_games = winners.merge(losers, on=['ReplayID', 'MapID', 'Group'], how='outer').fillna(0)
group_games['Group difference'] = group_games['Winning_team'] - group_games['Losing_team']

pd.DataFrame(group_games.groupby(['MapID', 'Group'])['Group difference'].mean()).to_csv('shiny/data/Group_diff.csv')


# MMR rating of winning/ losing playesr of each hero
pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'Is Winner'])['Adj MMR Before'].mean()).to_csv('shiny/data/WinningMMRperHero.csv')

# hero popularity
pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'Difficulty', 'Game Date'])['Game Date'].size()).to_csv('shiny/data/Popularity.csv')

# Effect of autoselect
a = all_games.head(500000)
a.groupby(['Is Auto Select', 'Is Winner'])['Adj MMR Before'].mean()
pd.DataFrame(all_games.groupby(['PrimaryName', 'Is Auto Select'])['Is Winner'].mean()).to_csv('shiny/data/Auto.csv')