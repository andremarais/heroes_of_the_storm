import pandas as pd
import numpy as np
from sklearn.feature_extraction import DictVectorizer
import time
import random
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import AdaBoostRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error


pd.options.mode.chained_assignment = None


def impute_1700(raplay_data, hero_info, replay_info):
    print('Start')
    s_time = time.time()

    all_games = raplay_data

    # sample of n games for modelling
    games_ss = all_games[all_games['ReplayID'].isin(np.random.choice(np.unique(all_games['ReplayID']), 10000))]

    # import replay games info and hero info
    replays = replay_info
    heroes_info = hero_info

    # print('Imported data', round(time.time() - s_time, 2)); s_time = time.time()

    games_ss = games_ss.merge(heroes_info, how='left', on='HeroID')
    games_ss = games_ss[np.isfinite(games_ss['MMR Before'])]
    games_ss = games_ss.merge(replays, how='left', on='ReplayID')

    Ave_MMR = pd.DataFrame([games_ss.groupby(['ReplayID', 'Is Winner'])['MMR Before'].mean()]).transpose()
    Ave_MMR['ReplayID'] = [item[0] for item in Ave_MMR.index.values]
    Ave_MMR['Is Winner'] = [item[1] for item in Ave_MMR.index.values]
    Ave_MMR.columns = [u'AveTeamMMR', u'ReplayID', u'Is Winner']
    games_ss = games_ss.merge(Ave_MMR, how='inner', on=['ReplayID', 'Is Winner'])
    print('Added Ave Team MMR field', round(time.time() - s_time, 2)); s_time = time.time()
    games_ss.HeroID = games_ss.HeroID.astype('category')

    # model building
    clf_lin = LinearRegression(n_jobs=200)  # Linear model
    clf_ada = AdaBoostRegressor(n_estimators=200)  # Adaboost
    clf_rf = RandomForestRegressor(n_estimators=200, n_jobs = 8)   # RF

    vec = DictVectorizer()

    # Vectorize the date for modelling - Python is not as dynamic as R when it comes to modelling :(
    feature_data = [dict(r.iteritems()) for _, r in games_ss[['Is Auto Select',
                                                                  'Hero Level',
                                                                  'Is Winner',
                                                                  'Group',
                                                                  'SubGroup',
                                                                  'Difficulty',
                                                                  'AveTeamMMR']].iterrows()]

    vectorized_sparse = vec.fit_transform(feature_data)
    vectorized_array = pd.DataFrame(vectorized_sparse.toarray().astype(int))

    # Create training rows
    mask = np.zeros(len(games_ss), np.bool)
    mask[random.sample(list(np.arange(0, len(mask))), int(games_ss.shape[0]*.8))] = True
    mask[games_ss[games_ss['MMR Before'] == 1700].index.tolist()] = False  # remove the 1700s

    print('Model train start', round(time.time() - s_time, 2)); s_time = time.time()
    # Fit model
    clf_lin.fit(X=vectorized_array[mask], y=games_ss['MMR Before'].iloc[mask])
    clf_ada.fit(X=vectorized_array[mask], y=games_ss['MMR Before'].iloc[mask])
    clf_rf.fit(X=vectorized_array[mask], y=games_ss['MMR Before'].iloc[mask])

    models = [clf_lin, clf_ada, clf_rf]
    models_RMSE = []
    for m in models:
        models_RMSE.append( mean_squared_error(games_ss['MMR Before'].iloc[~mask], m.predict(vectorized_array[~mask]))**0.5)
    print("RMSE", models_RMSE)
    best_model = models[models_RMSE.index(min(models_RMSE))]
    print('Model used:', models[models_RMSE.index(min(models_RMSE))])

    # Select all replays where there was a player with a 1700 rating
    print('1700 model data prep', round(time.time() - s_time, 2)); s_time = time.time()
    games_1700 = all_games[all_games['ReplayID'].isin(np.unique(all_games.loc[all_games['MMR Before'] == 1700]['ReplayID']))]

    # Repeat merging process as above
    games_1700 = games_1700.merge(heroes_info, how='left', on='HeroID')
    games_1700 = games_1700[np.isfinite(games_1700['MMR Before'])]
    games_1700 = games_1700.merge(replays, how='left', on='ReplayID')

    Ave_MMR_1700 = pd.DataFrame([games_1700.groupby(['ReplayID', 'Is Winner'])['MMR Before'].mean()]).transpose()
    Ave_MMR_1700['ReplayID'] = [item[0] for item in Ave_MMR_1700.index.values]
    Ave_MMR_1700['Is Winner'] = [item[1] for item in Ave_MMR_1700.index.values]
    Ave_MMR_1700.columns = [u'AveTeamMMR', u'ReplayID', u'Is Winner']
    games_1700 = games_1700.merge(Ave_MMR_1700, how='inner', on=['ReplayID', 'Is Winner'])

    games_1700.HeroID = games_1700.HeroID.astype('category')
    feature_data_1700 = [dict(r.iteritems()) for _, r in games_1700[['Is Auto Select',
                                                                  'Hero Level',
                                                                  'Is Winner',
                                                                  'Group',
                                                                  'SubGroup',
                                                                  'Difficulty',
                                                                  'AveTeamMMR']].loc[games_1700['MMR Before'] == 1700].iterrows()]

    vectorized_sparse_1700 = vec.fit_transform(feature_data_1700)
    vectorized_array_1700 = pd.DataFrame(vectorized_sparse_1700.toarray().astype(int))
    print('1700 model data pred', round(time.time() - s_time, 2)); s_time = time.time()
    all_games['Adj MMR Before'] = all_games['MMR Before']

    all_games['Adj MMR Before'].loc[all_games['Adj MMR Before'] == 1700] = best_model.predict(vectorized_array_1700)

    print('Done')
    return all_games


