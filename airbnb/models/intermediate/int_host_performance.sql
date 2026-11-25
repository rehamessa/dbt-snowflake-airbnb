{{ config(materialized = 'table') }}

WITH hosts AS (
    SELECT * FROM {{ ref('dim_hosts_cleansed') }}
),

listings AS (
    SELECT * FROM {{ ref('dim_listings_cleansed') }}
),

-- The data is a historical snapshot, so tenure is measured
-- against the latest date in the data, not today's date
reference_date AS (
    SELECT MAX(updated_at) AS ref_date FROM hosts
),

listing_metrics AS (
    SELECT
        host_id,
        COUNT(*)                                  AS total_listings,
        ROUND(AVG(price), 2)                      AS avg_listing_price,
        MIN(price)                                AS min_listing_price,
        MAX(price)                                AS max_listing_price,
        COUNT_IF(room_type = 'Entire home/apt')   AS entire_home_count,
        COUNT_IF(room_type = 'Private room')      AS private_room_count,
        COUNT_IF(room_type = 'Shared room')       AS shared_room_count,
        COUNT_IF(room_type = 'Hotel room')        AS hotel_room_count,
        ROUND(AVG(minimum_nights), 1)             AS avg_minimum_nights
    FROM listings
    GROUP BY host_id
)

SELECT
    h.host_id,
    h.host_name,
    h.is_superhost,
    COALESCE(m.total_listings, 0)     AS total_listings,
    m.avg_listing_price,
    m.min_listing_price,
    m.max_listing_price,
    COALESCE(m.entire_home_count, 0)  AS entire_home_count,
    COALESCE(m.private_room_count, 0) AS private_room_count,
    COALESCE(m.shared_room_count, 0)  AS shared_room_count,
    COALESCE(m.hotel_room_count, 0)   AS hotel_room_count,
    m.avg_minimum_nights,

    CASE
        WHEN COALESCE(m.total_listings, 0) = 0 THEN 'inactive'
        WHEN m.total_listings = 1  THEN 'single_listing'
        WHEN m.total_listings <= 5 THEN 'small_portfolio'
        WHEN m.total_listings <= 15 THEN 'medium_portfolio'
        ELSE 'large_portfolio'
    END AS portfolio_size,

    CASE WHEN h.is_superhost = 't' THEN 'superhost' ELSE 'standard' END AS host_status,

    CASE
        WHEN DATEDIFF('day', h.created_at, r.ref_date) < 365     THEN 'new_host'
        WHEN DATEDIFF('day', h.created_at, r.ref_date) < 3 * 365 THEN 'experienced_host'
        ELSE 'veteran_host'
    END AS host_tenure,

    CASE
        WHEN m.total_listings IS NULL THEN NULL
        WHEN m.entire_home_count >= GREATEST(m.private_room_count, m.shared_room_count, m.hotel_room_count) THEN 'Entire home/apt'
        WHEN m.private_room_count >= GREATEST(m.shared_room_count, m.hotel_room_count) THEN 'Private room'
        WHEN m.shared_room_count >= m.hotel_room_count THEN 'Shared room'
        ELSE 'Hotel room'
    END AS dominant_room_type

FROM hosts h
CROSS JOIN reference_date r
LEFT JOIN listing_metrics m ON h.host_id = m.host_id