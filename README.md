# IPL 2026 SQL Analysis

An SQL project that answers 10 business-style questions about the IPL 2026 season using MySQL: team wins, top batters and bowlers, toss impact, venue scoring, phases of an innings, chasing vs defending, and home advantage.

**Tools:** MySQL 8.0, MySQL Workbench
**SQL skills shown:** GROUP BY, HAVING, CASE, subqueries, JOINs, window functions (`RANK() OVER`), data cleaning checks

## Dataset

[IPL 2026 - Complete Dataset](https://www.kaggle.com/) by Data Knight on Kaggle (9 files). I used four of them:

| File | Rows | Used for |
|---|---|---|
| `deliveries.csv` | 17,477 | Ball-by-ball data |
| `matches.csv` | 39 | One row per match |
| `venues.csv` | 12 | Stadium and home team |
| `squads.csv` | 257 | Players and roles |

The CSV files are not included in this repo. Download them from Kaggle and import them into a database called `ipl2026`.

## How to run it

1. Download the dataset from Kaggle and create a database: `CREATE DATABASE ipl2026;`
2. Import `deliveries.csv`, `venues.csv` and `squads.csv` with the Table Data Import Wizard in MySQL Workbench.
3. Run `fix_matches.sql` to create and fill the `matches` table (see "Data problems" below for why).
4. Open `ipl_analysis.sql` and run each query.

## Questions and findings

| # | Question | Finding |
|---|---|---|
| 1 | Wins per team | RCB and PBKS lead with 6 wins each, then SRH with 5 |
| 2 | Top 5 run scorers | Vaibhav Sooryavanshi (776), Shubman Gill (732), Sai Sudharsan (722) |
| 3 | Did winning the toss help? | Toss winners won 21 of 38 matches (55.3%), a small edge |
| 4 | Top 5 wicket-takers | Kagiso Rabada (29), Bhuvneshwar Kumar (28), Jofra Archer (25) |
| 5 | Average first-innings score by venue | Wankhede, Mumbai is highest (215.5); Ekana, Lucknow is lowest (154.8) |
| 6 | Runs per over by phase | Death overs are fastest (10.40), then powerplay (10.06), then middle (9.28) |
| 7 | Chasing vs defending | Chasing teams won 22 matches, defending teams won 16 |
| 8 | Sixes in wins vs losses | Winning teams hit 10.71 sixes per innings vs 7.47 in losses |
| 9 | Top 3 batters inside each team | Window function with `RANK() OVER (PARTITION BY ...)` |
| 10 | Home advantage | Home teams won 21 of 38 matches (about 55%) |

Several findings are based on small samples (38 completed matches), so they show patterns and do not prove cause and effect.

## Data problems I found and handled

- **Incomplete import.** MySQL Workbench's Import Wizard loaded only 22 of the 39 rows of `matches.csv` without showing an error. I caught it by comparing row counts and win totals with the CSV, then rebuilt the table with a SQL script (`fix_matches.sql`) using proper column types.
- **Files cover different periods.** `deliveries` has 74 matches but `matches` has only 39, so JOINs between them cover matches 1 to 39. The leaderboard files (`batting_stats.csv` and others) are an earlier snapshot, so I calculated all statistics from `deliveries`.
- **Venue names differ between tables** (for example `M. Chinnaswamy Stadium, Bangalore` vs `M. Chinnaswamy Stadium`), so I joined on the start of the name with `LIKE CONCAT(...)`.
- **Player names are inconsistent.** KL Rahul's runs are recorded under the name `Rahul` in `deliveries`.
- **Blank cells** were stored as NULL, and run-outs, retired hurt and obstructing the field were excluded from bowlers' wicket counts.

## What I learned

- Check row counts after every import, because a wizard can fail silently.
- Compare results with an independent source before trusting them.
- Window functions make "top N per group" questions much simpler.

## About me

Sai Krishna, an aspiring data analyst (MTech in AI).
[LinkedIn](https://www.linkedin.com/in/sai-krishna-80253831b) | [Portfolio](https://saikrishna483.github.io)
