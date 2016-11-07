import pandas as pd
import datetime
from imputing1700 import impute_1700
import numpy as np
import matplotlib.pyplot as plt

replay_data = pd.read_csv('ReplayCharacters 2015-12-30 - 2016-01-29.csv')
hero_info = pd.read_csv('hero_info.csv')
replay_info = pd.read_csv('Replays 2015-12-30 - 2016-01-29.csv')
map_info = pd.read_csv('map_info.csv')

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
pd.DataFrame(all_games.groupby(['HeroID', 'Group', 'Game Date'])['Adj MMR Before'].mean()).to_csv('shiny/data/MMR_hero_overtime.csv') # added to shiny

# Hero winrate over time
pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'SubGroup', 'Game Date'])['Is Winner'].mean()).to_csv('shiny/data/Hero_winrate.csv') # added to shiny

# Role presence for each map
winners = pd.DataFrame(all_games[all_games['Is Winner'] == True].groupby(['ReplayID', 'MapID', 'Group'])['Is Winner'].count())
winners['ReplayID'], winners['MapID'], winners['Group'] = [i[0] for i in winners.index.values], [i[1] for i in winners.index.values], [i[2] for i in winners.index.values]
winners.columns = ['Winning_team', 'ReplayID', 'MapID', 'Group']

losers = pd.DataFrame(all_games[all_games['Is Winner'] == False].groupby(['ReplayID', 'MapID', 'Group'])['Is Winner'].count())
losers['ReplayID'], losers['MapID'], losers['Group'] = [i[0] for i in losers.index.values], [i[1] for i in losers.index.values], [i[2] for i in losers.index.values]
losers.columns = ['Losing_team', 'ReplayID', 'MapID', 'Group']

group_games = winners.merge(losers, on=['ReplayID', 'MapID', 'Group'], how='outer').fillna(0)
group_games['Group difference'] = group_games['Winning_team'] - group_games['Losing_team']
group_games = group_games.merge(map_info, on = 'MapID')

pd.DataFrame(group_games.groupby(['Map Name', 'Group'])['Group difference'].mean()).to_csv('shiny/data/Group_diff.csv') # added to shiny


# MMR rating of winning/ losing players of each hero
pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'Is Winner'])['Adj MMR Before'].mean()).to_csv('shiny/data/WinningMMRperHero.csv')

# hero popularity
pd.DataFrame(all_games.groupby(['PrimaryName', 'Group', 'Difficulty', 'Game Date'])['Game Date'].size()).to_csv('shiny/data/Popularity.csv') # added to shiny

# Effect of autoselect
pd.DataFrame(all_games.groupby(['PrimaryName', 'Is Auto Select'])['Is Winner'].mean()).to_csv('shiny/data/Auto.csv') # added to shiny


# MMR adjustment
MMR_hist = pd.DataFrame()
bins = int((max(all_games['MMR Before']) - min(all_games['MMR Before']))/8)
MMR_hist['x'] = [item for item in np.histogram(all_games['MMR Before'], bins)[1]][1:]
MMR_hist['Before'] = [item for item in np.histogram(all_games['MMR Before'], bins)[0]]
MMR_hist['Adjusted'] = [item for item in np.histogram(all_games['Adj MMR Before'], bins)[0]]
MMR_hist.to_csv('MMRAdj.csv') # TODO still need to add this - about page
plt.close('all')
# hero level info
plt.hexbin(all_games['Hero Level'], all_games['Adj MMR Before'], gridsize=20, cmap=plt.cm.gnuplot2)
plt.title("MMR (adjusted) vs Hero level")
plt.xlabel('Hero level')
plt.ylabel('MMR Rating')
plt.ylim(0,)
plt.savefig('shiny/png_files/MMR_herolvl.png') # added to shiny


# match length stats
def time_to_sec(x):
    sec = int(x[-2:]) + int(x[3:-3]) * 60 + int(x[:2]) * 3600
    return sec

all_games['game_time_seconds'] = all_games['Replay Length'].apply(time_to_sec)

winner_gl = pd.DataFrame(all_games[all_games['Is Winner']].groupby(['ReplayID', 'MapID', 'game_time_seconds'])['Adj MMR Before'].mean())
winner_gl['ReplayID'], winner_gl['MapID'], winner_gl['game_time_seconds'] = [i[0] for i in winner_gl.index.values], [i[1] for i in winner_gl.index.values], [i[2] for i in winner_gl.index.values]
winner_gl.columns = ['Winning_team_MMR', 'ReplayID', 'MapID', 'game_time_seconds']

loser_gl = pd.DataFrame(all_games[~all_games['Is Winner']].groupby(['ReplayID', 'MapID', 'game_time_seconds'])['Adj MMR Before'].mean())
loser_gl['ReplayID'], loser_gl['MapID'], loser_gl['game_time_seconds'] = [i[0] for i in loser_gl.index.values], [i[1] for i in loser_gl.index.values], [i[2] for i in loser_gl.index.values]
loser_gl.columns = ['Losing_team_MMR', 'ReplayID', 'MapID', 'game_time_seconds']

time_vs_MMR = pd.DataFrame(winner_gl.merge(loser_gl, on=['ReplayID', 'game_time_seconds', 'MapID']))
time_vs_MMR['Team MMR difference'] = time_vs_MMR['Winning_team_MMR'] - time_vs_MMR['Losing_team_MMR']
# time_vs_MMR.to_csv('Game_time_vs_MMR.csv') # don't need this data


time_vs_MMR = time_vs_MMR.merge(map_info, on='MapID')

for m in time_vs_MMR['Map Name'].unique():
    plt.close('all')
    plt.hexbin(time_vs_MMR['Team MMR difference'].loc[time_vs_MMR['Map Name'] == m], time_vs_MMR['game_time_seconds'].loc[time_vs_MMR['Map Name'] == m], gridsize=500, cmap=plt.cm.gnuplot2)
    plt.title(m)
    plt.xlabel('Team MMR difference')
    plt.ylabel('Game time (in seconds)')
    plt.xlim(time_vs_MMR['Team MMR difference'].loc[time_vs_MMR['Map Name'] == m].quantile(q=.025),
             time_vs_MMR['Team MMR difference'].loc[time_vs_MMR['Map Name'] == m].quantile(q=.975))
    plt.ylim(time_vs_MMR['game_time_seconds'].loc[time_vs_MMR['Map Name'] == m].quantile(q=.025),
             time_vs_MMR['game_time_seconds'].loc[time_vs_MMR['Map Name'] == m].quantile(q=.975))
    plt.savefig('shiny/png_files/maps/' + m + '.png')
    print(m + ' done')

pd.DataFrame(all_games.groupby(['Hero Level'])['Adj MMR Before'].mean()).to_csv('shiny/data/HeroLevel_MMR.csv')
pd.DataFrame(all_games.groupby(['Difficulty'])['Hero Level'].mean()).to_csv('shiny/data/HeroLevel_Diff.csv')
pd.DataFrame(all_games.groupby(['Group'])['Hero Level'].mean()).to_csv('shiny/data/HeroLevel_Group.csv')
pd.DataFrame(all_games.groupby(['SubGroup'])['Hero Level'].mean()).to_csv('shiny/data/HeroLevel_SubGroup.csv')

a = all_games.head(100000)

unique_heroes = a['PrimaryName'].unique()


def hero_to_bin(unique_heroes, game):
    unique_heroes = np.unique(unique_heroes) # Just to make sure
    hero_list = unique_heroes[unique_heroes.sort()]

    win_heroes = game[game['Is Winner'] == True]
    loose_heroes = game[game['Is Winner'] == False]

    win_array = loose_array = np.zeros(hero_list.shape[1]).astype(int)

    for h in win_heroes['PrimaryName']:
        win_array[np.where(hero_list == h)[1][0]] = 1
    for h in loose_heroes['PrimaryName']:
        loose_array[np.where(hero_list == h)[1][0]] = 1
    win_array = ''.join(win_array.astype(str))
    loose_array = ''.join(loose_array.astype(str))
    to_return = pd.DataFrame({'Win_array': win_array,
                              'Loose_array': loose_array,
                              'Game_type':  game['GameMode(3=Quick Match 4=Hero League 5=Team League)'].unique()[0],
                              'Map': game['MapID'].unique()[0]},
                              index= [game['ReplayID'].unique()[0]])
    return to_return

games_df = pd.DataFrame()

for r in all_games['ReplayID'].unique():
    games_df = games_df.append(hero_to_bin(unique_heroes, all_games[all_games['ReplayID'] == r]))

print('Done')