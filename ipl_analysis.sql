-- Q1: How many matches did each team win?
SELECT match_winner, COUNT(*) AS wins
FROM matches
WHERE match_result = 'completed'
GROUP BY match_winner
ORDER BY wins DESC;

-- Q2: Top 5 run scorers
SELECT striker, SUM(runs_of_bat) AS total_runs
FROM deliveries
GROUP BY striker
ORDER BY total_runs DESC
LIMIT 5;

-- Q3: Did winning the toss help?
SELECT
  SUM(CASE WHEN toss_winner = match_winner THEN 1 ELSE 0 END) AS toss_winner_won,
  COUNT(*) AS completed_matches,
  ROUND(100 * SUM(CASE WHEN toss_winner = match_winner THEN 1 ELSE 0 END) / COUNT(*), 1) AS win_pct
FROM matches
WHERE match_result = 'completed';

-- Q4: Top 5 wicket-takers (run-outs, retired hurt and obstructing the field are not the bowler's wickets)
SELECT bowler, COUNT(*) AS wickets
FROM deliveries
WHERE wicket_type IS NOT NULL
  AND wicket_type <> ''
  AND wicket_type NOT IN ('runout', 'retired hurt', 'obstructing the field')
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 5;

-- Q5: Average first-innings score at each venue (venues with at least 3 completed matches)
SELECT venue, COUNT(*) AS matches_played, ROUND(AVG(first_ings_score), 1) AS avg_first_innings
FROM matches
WHERE match_result = 'completed'
GROUP BY venue
HAVING COUNT(*) >= 3
ORDER BY avg_first_innings DESC;

-- Q6: Runs per over and wickets in each phase of the innings
SELECT
  CASE
    WHEN FLOOR(`over`) <= 5 THEN '1 Powerplay (overs 1-6)'
    WHEN FLOOR(`over`) <= 14 THEN '2 Middle (overs 7-15)'
    ELSE '3 Death (overs 16-20)'
  END AS phase,
  SUM(runs_of_bat + extras) AS total_runs,
  COUNT(CASE WHEN wicket_type IS NOT NULL AND wicket_type <> '' THEN 1 END) AS wickets,
  COUNT(DISTINCT CONCAT(match_no, '-', innings, '-', FLOOR(`over`))) AS overs_bowled,
  ROUND(SUM(runs_of_bat + extras) / COUNT(DISTINCT CONCAT(match_no, '-', innings, '-', FLOOR(`over`))), 2) AS runs_per_over
FROM deliveries
GROUP BY phase
ORDER BY phase;

-- Q7: Do teams win more often chasing or defending?
SELECT
  SUM(CASE WHEN second_ings_score > first_ings_score THEN 1 ELSE 0 END) AS won_chasing,
  SUM(CASE WHEN second_ings_score <= first_ings_score THEN 1 ELSE 0 END) AS won_defending,
  COUNT(*) AS completed_matches
FROM matches
WHERE match_result = 'completed';

-- Q8: Do teams hit more sixes in matches they win than in matches they lose?
-- JOIN deliveries to matches (only matches 1 to 39 exist in the matches table)
SELECT
  result,
  COUNT(*) AS team_innings,
  SUM(sixes) AS total_sixes,
  ROUND(SUM(sixes) / COUNT(*), 2) AS sixes_per_innings
FROM (
  SELECT
    d.match_no,
    d.batting_team,
    CASE WHEN d.batting_team = m.match_winner THEN 'Won' ELSE 'Lost' END AS result,
    SUM(CASE WHEN d.runs_of_bat = 6 THEN 1 ELSE 0 END) AS sixes
  FROM deliveries d
  JOIN matches m ON d.match_no = m.match_id
  WHERE m.match_result = 'completed'
  GROUP BY d.match_no, d.batting_team, result
) AS innings
GROUP BY result;

-- Q9: Top 3 run scorers inside each team (window function)
SELECT batting_team, striker, total_runs, team_rank
FROM (
  SELECT
    batting_team,
    striker,
    SUM(runs_of_bat) AS total_runs,
    RANK() OVER (PARTITION BY batting_team ORDER BY SUM(runs_of_bat) DESC) AS team_rank
  FROM deliveries
  GROUP BY batting_team, striker
) AS ranked
WHERE team_rank <= 3
ORDER BY batting_team, team_rank;

-- Q10: Do home teams win more often at their home ground?
-- The venue names differ between tables, so the JOIN matches on the start of the name
SELECT
  v.home_team,
  COUNT(*) AS home_matches,
  SUM(CASE WHEN m.match_winner = v.home_team THEN 1 ELSE 0 END) AS home_wins,
  ROUND(100 * SUM(CASE WHEN m.match_winner = v.home_team THEN 1 ELSE 0 END) / COUNT(*), 1) AS home_win_pct
FROM matches m
JOIN venues v ON m.venue LIKE CONCAT(v.venue_stadium, '%')
WHERE m.match_result = 'completed'
  AND v.home_team IN (m.team1, m.team2)
GROUP BY v.home_team
ORDER BY home_wins DESC, v.home_team;

## Sample results

![Q8: sixes in wins vs losses](Q8.png)

![Q9: top 3 batters per team](Q9.png)
