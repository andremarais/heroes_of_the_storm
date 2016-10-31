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

all_games['Game Date'] = all_games['Timestamp (UTC)'].apply(change_date)

pd.DataFrame(all_games.groupby(['HeroID', 'Group', 'Game Date'])['Adj MMR Before'].mean()).to_csv('MMR_hero_overtime.csv')

pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'SubGroup', 'Game Date'])['Is Winner'].mean()).to_csv('Hero_winrate.csv')


winners = pd.DataFrame(all_games[all_games['Is Winner'] == True].groupby(['ReplayID', 'MapID', 'Group'])['Is Winner'].count())
winners['ReplayID'], winners['MapID'], winners['Group'] = [i[0] for i in winners.index.values], [i[1] for i in winners.index.values], [i[2] for i in winners.index.values]
winners.columns = ['Winning_team', 'ReplayID', 'MapID', 'Group']

losers = pd.DataFrame(all_games[all_games['Is Winner'] == False].groupby(['ReplayID', 'MapID', 'Group'])['Is Winner'].count())
losers['ReplayID'], losers['MapID'], losers['Group'] = [i[0] for i in losers.index.values], [i[1] for i in losers.index.values], [i[2] for i in losers.index.values]
losers.columns = ['Losing_team', 'ReplayID', 'MapID', 'Group']

group_games = winners.merge(losers, on=['ReplayID', 'MapID', 'Group'], how='outer').fillna(0)
group_games['Group difference'] = group_games['Winning_team'] - group_games['Losing_team']

pd.DataFrame(group_games.groupby(['MapID', 'Group'])['Group difference'].mean()).to_csv('Group_diff.csv')

"""
winners_sub = pd.DataFrame(all_games[all_games['Is Winner'] == True].groupby(['ReplayID', 'MapID', 'SubGroup'])['Is Winner'].count())
winners_sub['ReplayID'], winners_sub['MapID'], winners_sub['SubGroup'] = [i[0] for i in winners_sub.index.values], [i[1] for i in winners_sub.index.values], [i[2] for i in winners_sub.index.values]
winners_sub.columns = ['Winning_team', 'ReplayID', 'MapID', 'SubGroup']

losers_sub = pd.DataFrame(all_games[all_games['Is Winner'] == False].groupby(['ReplayID', 'MapID', 'SubGroup'])['Is Winner'].count())
losers_sub['ReplayID'], losers_sub['MapID'], losers_sub['SubGroup'] = [i[0] for i in losers_sub.index.values], [i[1] for i in losers_sub.index.values], [i[2] for i in losers_sub.index.values]
losers_sub.columns = ['Losing_team', 'ReplayID', 'MapID', 'SubGroup']

group_games_sub = winners_sub.merge(losers_sub, on=['ReplayID', 'MapID', 'SubGroup'], how='outer').fillna(0)
group_games_sub['Subgroup difference'] = group_games_sub['Winning_team'] - group_games_sub['Losing_team']

pd.DataFrame(group_games_sub.groupby(['MapID', 'SubGroup'])['Subgroup difference'].mean()).to_csv('Subgroup_diff.csv')

# doesnt add much value
"""

a = all_games.head(10000)
pd.DataFrame(all_games.groupby(['Group', 'SubGroup'])['Is Winner'].mean()).to_csv('Role_winrate.csv')
all_games.groupby(['Difficulty'])['Adj MMR Before'].mean()