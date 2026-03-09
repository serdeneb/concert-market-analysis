# concert-market-analysis
# Concert Market Analysis: International Tour Strategy for Yanghongwon

**BUS32120 | Data Analysis with Python and SQL**
**University of Chicago Booth School of Business | 2026**
**Authors: Clara Chang, Sainbayar Erdenebulgan**

---

## Overview

This project uses data-driven analysis to identify optimal international concert markets for Yanghongwon, an emerging South Korean hip-hop artist. Using Last.fm API data combined with economic indicators, we evaluate market size, competition levels, cultural fit, and revenue potential across five countries to produce a ranked market recommendation.

---

## Objective

- Identify high-opportunity international markets for a niche street rapper
- Assess market competition to find entry points for emerging artists
- Evaluate economic factors (GDP per capita, ticket pricing, Korean diaspora) affecting revenue
- Produce specific city and timing recommendations for a concert tour

---

## Data Sources

| Source | Description |
|---|---|
| Last.fm API | Music listening data across 5 countries (100 records via API calls) |
| Economic Indicators | GDP per capita, population, music streaming penetration, avg. concert ticket price, Korean diaspora size |
| Hip-Hop Market Data | Hip-hop track presence in national top 50 charts, hip-hop market share % |

**Countries analysed:** United States, Japan, Germany, Brazil, United Kingdom

---

## Repository Structure
```
concert-market-analysis/
├── LastFM_Concert_Analysis_FIXED (6).ipynb   # Full Python analysis notebook
├── SQL_Queries.sql                            # 10 structured SQL queries
├── Clara_Chang_.pdf                           # Presentation deck
└── README.md
```

---

## Methodology

### Python (Jupyter Notebook)
- **API Data Collection:** Last.fm API calls to retrieve artist listener counts across target countries
- **EDA:** Listener distribution by country, artist tier segmentation (Niche / Mid / Major / Mega)
- **Feature Engineering:** Opportunity score combining listeners, GDP, diaspora, and competition metrics
- **Modelling:**
  - Linear Regression (target: avg. concert ticket price) — R² = 0.857, MAE = $6.35
  - Logistic Regression (target: market viability classification)

### SQL
Ten queries covering:
- `GROUP BY` aggregations for market sizing
- `ROLLUP` for portfolio-level totals
- `JOIN` across three tables (streaming, economic, hip-hop data)
- `WINDOW FUNCTIONS` — `RANK()`, cumulative `SUM()`, `PERCENT_RANK()`
- `CTE` with concentration ratio analysis
- Scalar subqueries to identify above-average competition thresholds

---

## Key Findings

- **Japan** ranks highest on the composite opportunity score: lowest listener competition, significant Korean diaspora, and strong hip-hop market fragmentation
- **United States** has the largest raw market but faces high competition concentration among top artists
- **Germany** offers solid GDP and above-average hip-hop receptiveness with moderate competition
- **Brazil and UK** score lower due to unfavourable combinations of competition and economic factors

---

## Final Recommendation

| Market | Cities | Season | Ticket Price Range |
|---|---|---|---|
| Japan | Tokyo (Shibuya, Harajuku), Osaka, Fukuoka | Spring / Fall | $35 – $55 |
| United States | Los Angeles (Koreatown), New York (Queens) | February | $45 – $65 |
| Germany | Berlin, Frankfurt | Summer | $40 – $60 |

Japan is the primary recommended entry market due to low competition, cultural affinity for Korean music, and a concentrated diaspora audience in major urban centres.

---

## Tools & Libraries

`Python` `pandas` `numpy` `matplotlib` `seaborn` `scikit-learn` `requests` `SQLite`
