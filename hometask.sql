-- Завдання №1

CREATE VIEW marketing_ads AS
SELECT
    source,
    campaign_id,
    adset_id,
    ad_id,
    date,
    spend,
    impressions,
    clicks,
    installs,
    registrations,
    timestamp
FROM
    (SELECT
        *,
        RANK() OVER(PARTITION BY ad_id, date ORDER BY timestamp DESC)
    FROM marketing_ads_raw) t
WHERE rank = 1;


-- Завдання №3

SELECT
    source,
    ROUND(SUM(spend)::numeric, 2) AS total_spend,
    ROUND(SUM(spend)::numeric / SUM(impressions)::numeric * 1000, 2) AS cpm,
    ROUND(SUM(clicks)::numeric / SUM(impressions::numeric) * 100, 2) AS ctr_pct,
    ROUND(SUM(installs)::numeric / SUM(clicks)::numeric * 100, 2) AS "cr_click_install_pct",
    ROUND(SUM(registrations)::numeric / SUM(installs)::numeric * 100, 2) AS "cr_install_reg_pct"
FROM marketing_ads
GROUP BY source;

-- Завдання №4

WITH sources_ltv AS (
    SELECT
        DISTINCT source,
        CASE WHEN source = 'tiktok' THEN 8.50
            WHEN source = 'meta' THEN 6.20
            WHEN source = 'google' THEN 12.40
        END AS ltv
    FROM marketing_ads
),
channel_metrics AS (
    SELECT
        source,
        ROUND(SUM(spend)::numeric, 2) AS total_spend,
        ROUND(SUM(spend)::numeric / SUM(impressions)::numeric * 1000, 2) AS cpm,
        ROUND(SUM(clicks)::numeric / SUM(impressions::numeric) * 100, 2) AS ctr_pct,
        ROUND(SUM(installs)::numeric / SUM(clicks)::numeric * 100, 2) AS "cr_click_install_pct",
        ROUND(SUM(registrations)::numeric / SUM(installs)::numeric * 100, 2) AS "cr_install_reg_pct",
        ROUND(SUM(spend)::numeric / SUM(registrations)::numeric, 2) AS cac
    FROM marketing_ads
    GROUP BY source
)

SELECT
    *,
    ROUND(ltv/cac, 2) AS "ltv / cac"
FROM channel_metrics
JOIN sources_ltv
USING(source);


-- Бонус

WITH monthly AS (
    SELECT
        source,
        date_trunc('month', "date")::date AS month,
        SUM(spend) AS spend,
        SUM(registrations) AS registrations
    FROM marketing_ads
    GROUP BY source, date_trunc('month', "date")::date
)

SELECT
    source,

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-01-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-01-01'), 0)
    )::numeric, 2) AS "2024-01",

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-02-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-02-01'), 0)
    )::numeric, 2) AS "2024-02",

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-03-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-03-01'), 0)
    )::numeric, 2) AS "2024-03",

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-04-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-04-01'), 0)
    )::numeric, 2) AS "2024-04",

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-05-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-05-01'), 0)
    )::numeric, 2) AS "2024-05",

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-06-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-06-01'), 0)
    )::numeric, 2) AS "2024-06",

    ROUND((
        SUM(spend) FILTER (WHERE month = DATE '2024-07-01')
        / NULLIF(SUM(registrations) FILTER (WHERE month = DATE '2024-07-01'), 0)
    )::numeric, 2) AS "2024-07"

FROM monthly
GROUP BY source
ORDER BY source;


