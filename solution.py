import pandas as pd

def load_players(file_path):
    players_rec=pd.read_csv(file_path)
    return players_rec

def load_matches(file_path):
    return pd.read_csv(file_path)

def merge_players_matches(players_df, matches_df):
    merged = pd.merge(players_df, matches_df, on='PlayerID', how='inner')
    return merged

def total_runs_per_team(merged_df):
    res = merged_df.groupby('Team', as_index=False)['Runs'].sum()
    return res

def calculate_strike_rate(merged_df):
    sr = merged_df.copy()
    sr['StrikeRate'] = sr['Runs'] / sr['Balls'] * 100
    return sr[['PlayerID', 'Name', 'Runs', 'Balls', 'StrikeRate']]
    

def runs_agg_per_player(merged_df):
    agg = merged_df.groupby(['PlayerID', 'Name'])['Runs'].agg(['mean', 'max', 'min']).reset_index()
    return agg

def avg_age_by_role(players_df):
    result = players_df.groupby('Role', as_index=False)['Age'].mean()
    return result

def total_matches_per_player(matches_df):
    result = matches_df.groupby('PlayerID', as_index=False)['MatchID'].count()
    result = result.rename(columns={'MatchID': 'MatchCount'})
    return result


    # Step 1: Get counts (index: PlayerID, column: count)
    
    # Step 2: Rename columns explicitly and cleanly
   

    # Ensure columns are in correct order
   
 



def top_wicket_takers(merged_df):
    agg = merged_df.groupby(['PlayerID', 'Name'], as_index=False)['Wickets'].sum()
    high = agg.sort_values('Wickets', ascending=False).head(3).reset_index(drop=True)
    return high

def avg_strike_rate_per_team(merged_df):
    df = merged_df.copy()
    df['StrikeRate'] = df['Runs'] / df['Balls'] * 100
    result = df.groupby('Team', as_index=False)['StrikeRate'].mean()
    return result

def catch_to_match_ratio(merged_df):
    catch = merged_df.groupby('PlayerID', as_index=False).agg({'Catches': 'sum', 'MatchID': 'count'})
    catch['CatchToMatchRatio'] = catch['Catches'] / catch['MatchID']
    result = catch[['PlayerID', 'CatchToMatchRatio']]
    return result
