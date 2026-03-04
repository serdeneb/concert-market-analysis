-- ============================================================
-- SQL Queries: Concert Market Strategy Analysis for Yanghongwon
-- Dataset: Last.fm API data + Economic indicators
-- ============================================================

-- NOTE: These queries are written for SQLite/Snowflake.
-- Tables used:
--   lastfm_artists  (country, artist, listeners, mbid)
--   economic_data   (country, gdp_per_capita, population_millions,
--                    music_streaming_penetration, avg_concert_ticket_price,
--                    korean_diaspora)
--   hiphop_market   (country, hip_hop_tracks_in_top_50, hip_hop_percentage)


-- ============================================================
-- Query 1: GROUP BY — Total listeners and artist count per country
-- How: GROUP BY country, aggregating listeners and counting artists
-- Why: Establishes raw market size — the foundation of any opportunity analysis
-- Output: US has highest total listeners, Japan has lowest avg per artist
-- ============================================================
SELECT
    country,
    COUNT(artist)          AS num_artists,
    SUM(listeners)         AS total_listeners,
    ROUND(AVG(listeners))  AS avg_listeners
FROM lastfm_artists
GROUP BY country
ORDER BY total_listeners DESC;


-- ============================================================
-- Query 2: GROUP BY with ROLLUP — subtotals plus grand total
-- How: UNION ALL appends a grand total row to the grouped result
-- Why: Executives want both country-level and portfolio-level totals in one view
-- Output: Grand total across all 5 countries plus per-country breakdown
-- ============================================================
SELECT country, SUM(listeners) AS total_listeners
FROM lastfm_artists
GROUP BY country

UNION ALL

SELECT 'ALL COUNTRIES' AS country, SUM(listeners)
FROM lastfm_artists
ORDER BY total_listeners DESC;


-- ============================================================
-- Query 3: JOIN — Streaming data combined with economic indicators
-- How: INNER JOIN lastfm_artists with economic_data on country
-- Why: GDP and ticket price only exist in economic_data — joining enriches
--      streaming records for revenue modelling
-- Output: Japan has lowest GDP but lowest competition; US has highest both
-- ============================================================
SELECT
    a.country,
    ROUND(AVG(a.listeners))          AS avg_listeners,
    e.gdp_per_capita,
    e.avg_concert_ticket_price,
    e.korean_diaspora
FROM lastfm_artists  AS a
JOIN economic_data   AS e ON a.country = e.country
GROUP BY a.country
ORDER BY e.gdp_per_capita DESC;


-- ============================================================
-- Query 4: WINDOW FUNCTION — RANK artists by listeners within each country
-- How: RANK() OVER (PARTITION BY country ORDER BY listeners DESC)
-- Why: Reveals how dominant top artists are per market — high gaps signal
--      concentrated markets that are harder for emerging artists to enter
-- Output: Japan's top artist has far fewer listeners than US top artists
-- ============================================================
SELECT
    country,
    artist,
    listeners,
    RANK() OVER (PARTITION BY country ORDER BY listeners DESC) AS country_rank
FROM lastfm_artists
ORDER BY country, country_rank
LIMIT 15;


-- ============================================================
-- Query 5: WINDOW FUNCTION — Cumulative listeners per country
-- How: SUM() OVER with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- Why: Shows what % of market audience the top N artists capture —
--      high concentration means fewer slots for new entrants like Yanghongwon
-- Output: In US, top 3 artists capture majority of total listeners
-- ============================================================
SELECT
    country,
    artist,
    listeners,
    SUM(listeners) OVER (
        PARTITION BY country
        ORDER BY listeners DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_listeners
FROM lastfm_artists
ORDER BY country, listeners DESC
LIMIT 20;


-- ============================================================
-- Query 6: JOIN — Economic data combined with hip-hop market receptiveness
-- How: JOIN economic_data with hiphop_market on country
-- Why: A market with high GDP AND high hip-hop affinity is doubly attractive —
--      this join surfaces that combination in one row
-- Output: US leads hip-hop percentage; Japan lower but higher Korean diaspora
-- ============================================================
SELECT
    e.country,
    e.gdp_per_capita,
    e.avg_concert_ticket_price,
    h.hip_hop_percentage
FROM economic_data  AS e
JOIN hiphop_market  AS h ON e.country = h.country
ORDER BY h.hip_hop_percentage DESC;


-- ============================================================
-- Query 7: SUBQUERY (scalar) — Artists above the global average listeners
-- How: WHERE listeners > (SELECT AVG(listeners) FROM lastfm_artists)
-- Why: These are Yanghongwon's direct competitors in each market — knowing
--      the threshold helps calibrate realistic venue sizing
-- Output: 15 artists across all countries exceed the global average
-- ============================================================
SELECT country, artist, listeners
FROM lastfm_artists
WHERE listeners > (
    SELECT AVG(listeners) FROM lastfm_artists
)
ORDER BY listeners DESC
LIMIT 15;


-- ============================================================
-- Query 8: SUBQUERY (CTE with WITH) — Concentration ratio per country
-- How: CTE computes max/avg per country; outer query calculates ratio
-- Why: Low ratio = audience spread across many similar artists (fragmented
--      market) = easier entry point for Yanghongwon
-- Output: Japan has lowest concentration ratio — most fragmented market
-- ============================================================
WITH country_stats AS (
    SELECT
        country,
        MAX(listeners)          AS max_listeners,
        ROUND(AVG(listeners))   AS avg_listeners,
        COUNT(artist)           AS num_artists
    FROM lastfm_artists
    GROUP BY country
)
SELECT
    country,
    max_listeners,
    avg_listeners,
    num_artists,
    ROUND(avg_listeners * 1.0 / max_listeners, 3) AS concentration_ratio
FROM country_stats
ORDER BY concentration_ratio ASC;


-- ============================================================
-- Query 9: THREE-WAY JOIN — Full opportunity matrix in SQL
-- How: JOIN all three tables on country in one query
-- Why: The comprehensive opportunity score depends on all three data sources —
--      building it in SQL demonstrates full cross-table integration
-- Output: Japan ranks highest on Korean diaspora relative to competition
-- ============================================================
SELECT
    a.country,
    ROUND(AVG(a.listeners))  AS avg_listeners,
    SUM(a.listeners)         AS total_listeners,
    e.gdp_per_capita,
    e.korean_diaspora,
    h.hip_hop_percentage
FROM lastfm_artists  AS a
JOIN economic_data   AS e ON a.country = e.country
JOIN hiphop_market   AS h ON a.country = h.country
GROUP BY a.country
ORDER BY e.korean_diaspora DESC;


-- ============================================================
-- Query 10: WINDOW FUNCTION + CTE — Percentile rank of competition per country
-- How: PERCENT_RANK() OVER inside a CTE, outer query filters bottom 50%
-- Why: Percentile framing is more intuitive for exec audiences —
--      "Japan is in the 10th percentile for competition" is actionable
-- Output: Japan and Brazil are below-median competition — best entry points
-- ============================================================
WITH ranked AS (
    SELECT
        country,
        ROUND(AVG(listeners)) AS avg_listeners,
        PERCENT_RANK() OVER (ORDER BY AVG(listeners) ASC) AS pct_rank
    FROM lastfm_artists
    GROUP BY country
)
SELECT
    country,
    avg_listeners,
    ROUND(pct_rank * 100, 1) AS competition_percentile
FROM ranked
WHERE pct_rank <= 0.5
ORDER BY pct_rank;