import pandas as pd

replay_data = pd.read_csv('ReplayCharacters 2015-12-30 - 2016-01-29.csv')
hero_info = pd.read_csv('hero_info.csv')
replay_info = pd.read_csv('Replays 2015-12-30 - 2016-01-29.csv')
map_info = pd.read_csv('map_info.csv')

all_games = replay_data.merge(replay_info, how='left', on='ReplayID')
all_games = all_games.merge(hero_info, how='left', on='HeroID')
print('Merging done')


a = all_games.head(100000)

a[['ReplayID', 'PrimaryName']].loc[a['PrimaryName'] == 'Leoric'].groupby([])